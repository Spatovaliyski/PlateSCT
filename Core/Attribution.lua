local addonName, BD = ...

local pending = {}
local pendingPool = {}
local castMeta = {}
local lastAutoAttackFallbackTime = 0
local previousAutoFallbackTime = 0 -- the one before it, for the off hand when dual wielding

-- Learned per spell from hits that only one pending cast could explain: the usual delay from
-- the cast to its first hit (travel time), and the hit's damage school when it is readable.
-- They tell apart several casts that are pending at the same time.
local learnedDelay = {}
local learnedSchool = {}
local learnedSchoolMiss = {}
-- Casts of a spell in a row that got no hit at all (Death Grip, taunts, interrupts): from
-- NO_DAMAGE_AFTER on, the spell ranks like a buff until one of its hits is certain.
local learnedNoHit = {}
-- Damage spell IDs often differ from the cast's (Obliterate's two weapon hits, say): the cast a
-- damage spell the damage meter confirmed belongs to, when only one cast could explain it.
local learnedCastFor = {}

local function NoteFinishedCast(entry)
    local spellID = entry.spellID
    if (entry.hits or 0) == 0 and type(spellID) == "number" and not BD.IsSecret(spellID) then
        learnedNoHit[spellID] = (learnedNoHit[spellID] or 0) + 1
    end
end
local LEARN_RATE = 0.3

local function AcquirePending()
    local entry = table.remove(pendingPool)
    if not entry then
        entry = {}
    end
    return entry
end

local function ReleasePending(entry)
    wipe(entry)
    pendingPool[#pendingPool + 1] = entry
end

local function NormalizeStrictness(id)
    if id and BD.STRICTNESS[id] then
        return id
    end
    return "balanced"
end

function BD:DetectScenario()
    local inInstance, instanceType = IsInInstance()
    if not inInstance or not instanceType or instanceType == "none" then
        return "openWorld"
    end
    if instanceType == "party" then
        return "dungeon"
    end
    if instanceType == "raid" then
        return "raid"
    end
    if instanceType == "pvp" then
        return "battleground"
    end
    if instanceType == "arena" then
        return "arena"
    end
    if instanceType == "scenario" then
        return "dungeon"
    end
    return "openWorld"
end

function BD:GetActiveStrictnessId()
    local db = self.db
    if not db then
        return "balanced"
    end
    if not db.attributionAuto then
        return NormalizeStrictness(db.attributionManual)
    end
    local scenario = self.scenario or self:DetectScenario()
    local key = BD.SCENARIO_DB_KEYS[scenario]
    if key and db[key] then
        return NormalizeStrictness(db[key])
    end
    return "balanced"
end

function BD:GetActiveStrictness()
    return BD.STRICTNESS[self:GetActiveStrictnessId()] or BD.STRICTNESS.balanced
end

function BD:RefreshScenario()
    local scenario = self:DetectScenario()
    self.scenario = scenario
    self.activeStrictnessId = self:GetActiveStrictnessId()
    self.activeStrictness = BD.STRICTNESS[self.activeStrictnessId] or BD.STRICTNESS.balanced
    return scenario
end

local function CaptureDestToken()
    if UnitExists("target") then
        return BD.GetNameplateTokenForUnit("target") or "target"
    end
    return nil
end

local function NoteCastMeta(castGUID, kind, destToken)
    if not castGUID then
        return
    end
    local meta = castMeta[castGUID]
    if not meta then
        meta = {}
        castMeta[castGUID] = meta
    end
    if kind then
        meta.kind = kind
    end
    if destToken and not meta.destToken then
        meta.destToken = destToken
    end
    meta.seenAt = GetTime()
end

local function TakeCastMeta(castGUID)
    if not castGUID then
        return nil
    end
    local meta = castMeta[castGUID]
    castMeta[castGUID] = nil
    return meta
end

local function ExpireStale(now)
    now = now or GetTime()
    for guid, meta in pairs(castMeta) do
        if not meta.seenAt or (now - meta.seenAt) > 12 then
            castMeta[guid] = nil
        end
    end

    local write = 1
    for read = 1, #pending do
        local entry = pending[read]
        local age = now - (entry.t0 or 0)
        local window = entry.window or 0
        local linger = entry.linger or 0
        local maxAge = math.max(window, linger)
        local keep = false
        if age <= maxAge then
            if (entry.hitsLeft or 0) > 0 then
                keep = true
            elseif linger > window and age <= linger then
                keep = true
            end
        end
        if keep then
            if write ~= read then
                pending[write] = entry
            end
            write = write + 1
        else
            NoteFinishedCast(entry)
            ReleasePending(entry)
        end
    end
    for index = write, #pending do
        pending[index] = nil
    end
end

-- Plain spell IDs only: secret values cannot be table keys or compared.
local function Learnable(spellID)
    return type(spellID) == "number" and not BD.IsSecret(spellID)
end

-- A buff or heal that cannot deal damage (Power Word: Shield before the pull, say).
local function IsHelpfulOnly(spellID)
    if not Learnable(spellID) or not C_Spell or type(C_Spell.IsSpellHelpful) ~= "function"
        or type(C_Spell.IsSpellHarmful) ~= "function" then
        return false
    end
    local ok, helpfulOnly = pcall(function()
        return (C_Spell.IsSpellHelpful(spellID) and not C_Spell.IsSpellHarmful(spellID)) and true or false
    end)
    return ok and helpfulOnly
end

local function PushPending(spellID, source, destToken, kind)
    if not BD.ValuePresent(spellID) then
        return
    end
    local strict = BD:GetActiveStrictness()
    local now = GetTime()
    ExpireStale(now)

    while #pending >= BD.PENDING_CAP do
        local oldest = table.remove(pending, 1)
        if oldest then
            ReleasePending(oldest)
        else
            break
        end
    end

    local entry = AcquirePending()
    entry.spellID = spellID
    entry.source = source or "player"
    entry.destToken = destToken
    entry.t0 = now
    entry.kind = kind or "instant"
    entry.window = kind == "cast" and strict.castWindow or strict.instantWindow
    entry.hitsLeft = strict.hitsLeft
    entry.linger = strict.linger or 0
    entry.hits = 0
    entry.helpfulOnly = IsHelpfulOnly(spellID)
    -- A heal cast while an enemy is targeted went to a friend (party frame, mouseover): its
    -- first heal on any friendly plate is it, and that plate becomes its destination.
    entry.anyFriend = nil
    if entry.helpfulOnly and destToken and BD.SafeUnitBoolean(UnitCanAttack, "player", destToken) then
        entry.destToken, entry.anyFriend = nil, true
    end
    pending[#pending + 1] = entry
    BD:DebugPrint("pending+", entry.kind, spellID, entry.destToken or "no-dest", entry.window)
end

function BD:NoteOutgoingSent(unit, destName, castGUID, spellID)
    BD.API.AssertModern("Attribution.NoteOutgoingSent")
    if unit ~= "player" and unit ~= "pet" then
        return
    end
    local destToken = CaptureDestToken()
    -- destName from the event is often a string name; prefer live unit token.
    NoteCastMeta(castGUID, nil, destToken)
end

function BD:NoteOutgoingStart(unit, castGUID, spellID)
    BD.API.AssertModern("Attribution.NoteOutgoingStart")
    if unit ~= "player" and unit ~= "pet" then
        return
    end
    NoteCastMeta(castGUID, "cast", CaptureDestToken())
end

function BD:NoteOutgoingSpell(unit, castGUID, spellID)
    BD.API.AssertModern("Attribution.NoteOutgoingSpell")
    if unit ~= "player" and unit ~= "pet" then
        return
    end
    if unit == "pet" and not (self.db and self.db.includePetDamage) then
        return
    end

    local meta = TakeCastMeta(castGUID)
    local kind = (meta and meta.kind == "cast") and "cast" or "instant"
    local destToken = (meta and meta.destToken) or CaptureDestToken()
    PushPending(spellID, unit, destToken, kind)
end

local function IsLikelySpellSchool(schoolMask)
    if not BD.ValuePresent(schoolMask) then
        return false
    end
    if BD.IsSecret(schoolMask) and not BD.CanAccessValue(schoolMask) then
        return true
    end
    local ok, isPhysical = pcall(function()
        return schoolMask == 1
    end)
    if ok and isPhysical then
        return false
    end
    return ok
end

local function DestMatches(entry, unit)
    if not entry.destToken then
        return false
    end
    if entry.destToken == unit then
        return true
    end
    return BD.UnitsMatch(entry.destToken, unit)
end

local function CanUsePendingOnUnit(entry, unit, strict)
    local destMatch = DestMatches(entry, unit)
    if destMatch then
        return true
    end
    if entry.destToken then
        if strict.destRequired then
            return false
        end
        -- Dest known but different plate: only allow on current target when dest is not required.
        return BD.UnitsMatch(unit, "target") or unit == "target"
    end
    -- No dest recorded: current target only (legacy gate).
    return BD.UnitsMatch(unit, "target") or unit == "target"
end

local function KnownSchool(schoolMask)
    if type(schoolMask) ~= "number" or BD.IsSecret(schoolMask) or not BD.CanAccessValue(schoolMask) then
        return nil
    end
    return schoolMask
end

-- Sets the rank fields of a pending cast that could have caused this hit; false if it cannot.
-- Stage 1: waiting for its first hit. 2: already hit, still in its window (multi-hit spells).
-- 3: only lingering (DoT and channel ticks).
local function RankCandidate(entry, unit, now, strict, school, isHeal)
    if entry.source == "pet" and not (BD.db and BD.db.includePetDamage) then
        return false
    end
    local age = now - (entry.t0 or 0)
    local window, linger = entry.window or 0, entry.linger or 0
    local stage
    if age <= window and (entry.hits or 0) == 0 then
        stage = 1
    elseif age <= window and (entry.hitsLeft or 0) > 0 then
        stage = 2
    elseif linger > window and age <= linger then
        stage = 3
    else
        return false
    end
    -- A buff or heal never explains damage.
    if not isHeal and entry.helpfulOnly then
        return false
    end
    local friendHeal = isHeal and entry.anyFriend and stage <= 2
    if not friendHeal and not CanUsePendingOnUnit(entry, unit, strict) then
        return false
    end
    local spellID = entry.spellID
    local known = Learnable(spellID) and learnedSchool[spellID]
    entry.rankMismatch = (school and known and known ~= school) and 1 or 0
    local noDamage = entry.helpfulOnly
        or (Learnable(spellID) and (learnedNoHit[spellID] or 0) >= BD.NO_DAMAGE_AFTER)
    entry.rankBuff = (not isHeal and noDamage) and 1 or 0
    entry.rankStage = stage
    entry.rankPet = entry.source == "pet" and 1 or 0
    entry.rankOther = DestMatches(entry, unit) and 0 or 1
    if stage == 1 then
        -- When its hit is due: casts in flight resolve in the order their hits arrive.
        entry.rankOrder = (entry.t0 or 0) + ((Learnable(spellID) and learnedDelay[spellID]) or 0)
    else
        -- Newest first, so a new cast is never shadowed by an older one that is still lingering.
        entry.rankOrder = -(entry.t0 or 0)
    end
    return true
end

-- The first difference decides: a learned school that differs from the hit's, a buff that
-- cannot deal damage, the stage, a pet's cast, a cast on another plate (allowed only on your
-- target), order.
local function RanksBefore(a, b)
    if a.rankMismatch ~= b.rankMismatch then
        return a.rankMismatch < b.rankMismatch
    end
    if a.rankBuff ~= b.rankBuff then
        return a.rankBuff < b.rankBuff
    end
    if a.rankStage ~= b.rankStage then
        return a.rankStage < b.rankStage
    end
    if a.rankPet ~= b.rankPet then
        return a.rankPet < b.rankPet
    end
    if a.rankOther ~= b.rankOther then
        return a.rankOther < b.rankOther
    end
    return a.rankOrder < b.rankOrder
end

-- Learn only from the first hit of a cast no other waiting cast could explain. A school is
-- replaced only after two such hits in a row disagree, so one stray hit cannot unlearn it.
-- maybeWhite: a physical hit while you auto-attack may be a swing that landed first, so it
-- teaches no delay, and a first school from it needs a second agreeing hit.
local function Learn(entry, age, school, waiting, maybeWhite)
    local spellID = entry.spellID
    if entry.rankStage ~= 1 or waiting ~= 1 or not Learnable(spellID) then
        return
    end
    if not maybeWhite then
        local delay = learnedDelay[spellID]
        learnedDelay[spellID] = delay and (delay + (age - delay) * LEARN_RATE) or age
    end
    if not school then
        return
    end
    if maybeWhite and learnedSchool[spellID] == nil then
        if learnedSchoolMiss[spellID] == school then
            learnedSchool[spellID], learnedSchoolMiss[spellID] = school, nil
        else
            learnedSchoolMiss[spellID] = school
        end
        return
    end
    if learnedSchool[spellID] == nil or learnedSchool[spellID] == school then
        learnedSchool[spellID], learnedSchoolMiss[spellID] = school, nil
    elseif learnedSchoolMiss[spellID] == school then
        learnedSchool[spellID], learnedSchoolMiss[spellID] = school, nil
    else
        learnedSchoolMiss[spellID] = school
    end
end

-- The hit being matched, set by MatchOutgoingHit: its readable school, whether it is a heal,
-- whether it may be a white hit (you auto-attack, and it is physical on your target), whether
-- the auto-attack fallback can take it now, and whether your swing timer says it is not a swing.
local hitSchool, hitIsHeal, hitMaybeWhite, hitPreferAuto, hitOffBeat

-- Whether a likely white hit goes to the auto-attack fallback instead of this cast: one only
-- lingering, of another school, a buff or a pet's cast; or one that already hit and is not
-- delivering a burst (multi-hit instants land within WHITE_BURST of each other).
local function LeaveToAuto(best, now)
    if best.rankStage == 3 or best.rankMismatch == 1 or best.rankBuff == 1 or best.rankPet == 1 then
        return true
    end
    return best.rankStage == 2 and (now - (best.lastHitAt or best.t0 or 0)) > BD.WHITE_BURST
end

local function TryMatchPending(unit, now, strict)
    local school, isHeal, preferAuto = hitSchool, hitIsHeal, hitPreferAuto
    ExpireStale(now)
    local best, bestIndex
    local waiting = 0

    for index = 1, #pending do
        local entry = pending[index]
        if RankCandidate(entry, unit, now, strict, school, isHeal) then
            if entry.rankStage == 1 then
                waiting = waiting + 1
            end
            if not best or RanksBefore(entry, best) then
                best, bestIndex = entry, index
            end
        end
    end

    if not best then
        return nil
    end
    if preferAuto and LeaveToAuto(best, now) then
        return nil
    end

    local spellID = best.spellID
    local age = now - (best.t0 or 0)
    local uncertain = hitMaybeWhite and not hitOffBeat
    Learn(best, math.min(age, best.window or age), school, waiting, uncertain and school == 1)
    if not uncertain and Learnable(spellID) then
        learnedNoHit[spellID] = nil
    end
    best.hits = (best.hits or 0) + 1
    best.lastHitAt = now
    if best.anyFriend then
        best.destToken, best.anyFriend = unit, nil
    end
    if best.rankStage <= 2 and (best.hitsLeft or 0) > 0 then
        best.hitsLeft = best.hitsLeft - 1
        if best.hitsLeft <= 0 and not ((best.linger or 0) > (best.window or 0)) then
            table.remove(pending, bestIndex)
            ReleasePending(best)
        end
    end
    return spellID
end

-- PLAYER_ENTER_COMBAT / PLAYER_LEAVE_COMBAT: melee auto-attack switched on or off.
local autoAttackOn = false

local function IsAutoAttacking()
    if autoAttackOn then
        return true
    end
    local isCurrent = (C_Spell and C_Spell.IsCurrentSpell) or IsCurrentSpell
    if type(isCurrent) ~= "function" then
        return false
    end
    return BD.SafeUnitBoolean(isCurrent, BD.AUTO_ATTACK_SPELL_ID) or BD.SafeUnitBoolean(isCurrent, BD.AUTO_SHOT_SPELL_ID)
end

--- True while one of your casts is recent enough that its hit may still land. The first hit of a
--- pull often arrives before the client reports combat.
function BD:HasRecentOutgoingCast()
    local now = GetTime()
    for index = #pending, 1, -1 do
        if (now - (pending[index].t0 or 0)) <= BD.PULL_GRACE then
            return true
        end
    end
    return IsAutoAttacking()
end

-- Swing timer. While you auto-attack, your swings land on a beat of your attack speed, one beat
-- per hand, and your pet's melee on a beat of its own speed. Two likely white hits one swing
-- apart confirm a beat. Then a physical hit on your beat is your swing even right after a cast,
-- one on the pet's beat is its melee, and with all your hands confirmed one off every beat is
-- not your swing: a cast's hit, or a guardian's or another player's.
local SOURCE_PET = 3
local swingBeat = {}        -- source (1 main hand, 2 off hand, 3 pet) -> time of its last swing
local swingSpeed = {}       -- source -> current attack speed (reused)
local swingCandidates = {}  -- times of recent likely white hits no beat explains yet

-- Attack speeds turn secret under combat restrictions: then the last readable ones are used.
local cachedSpeed = {}

local function ReadSpeed(unit)
    local ok, main, off = pcall(function()
        local m, o = UnitAttackSpeed(unit)
        if BD.IsSecret(m) or BD.IsSecret(o) then
            error("secret")
        end
        if type(m) ~= "number" or m <= 0 then
            return nil
        end
        if type(o) ~= "number" or o <= 0 then
            o = nil
        end
        return m, o
    end)
    if ok then
        local cache = cachedSpeed[unit] or {}
        cachedSpeed[unit] = cache
        cache[1], cache[2] = main, off
        return main, off
    end
    local cache = cachedSpeed[unit]
    if cache then
        return cache[1], cache[2]
    end
    return nil
end

-- Fills swingSpeed; false when your own attack speed cannot be read.
local function ReadSwingSpeeds()
    local main, off = ReadSpeed("player")
    swingSpeed[1], swingSpeed[2], swingSpeed[SOURCE_PET] = main, off, nil
    if not main then
        return false
    end
    if BD.SafeUnitBoolean(UnitExists, "pet") then
        local pet = ReadSpeed("pet")
        -- A pet swinging at your own speed cannot be told apart by its rhythm.
        local apart = BD.SWING_TOLERANCE * 2
        if pet and math.abs(pet - main) > apart and (not off or math.abs(pet - off) > apart) then
            swingSpeed[SOURCE_PET] = pet
        end
    end
    return true
end

-- Distance in seconds from the nearest beat after `at` (misses skip beats), or nil once
-- SWING_MAX_BEATS beats passed without a swing.
local function BeatOffset(at, speed, now)
    local since = now - at
    if since > speed * BD.SWING_MAX_BEATS + BD.SWING_TOLERANCE then
        return nil
    end
    local beats = math.max(1, math.floor(since / speed + 0.5))
    return math.abs(since - beats * speed)
end

local function ResetSwingTimer()
    wipe(swingBeat)
    wipe(swingCandidates)
end

-- A beat that missed its last swing (or none yet) is open: a wrong one, set by a coincidence of
-- other hits, is replaced by the next two real swings.
local function BeatFresh(source, now)
    local at, speed = swingBeat[source], swingSpeed[source]
    return at ~= nil and speed ~= nil and now - at <= speed + BD.SWING_TOLERANCE
end

-- Whether a cast of yours or your pet's is still waiting for its first hit: a hit then may be
-- that cast's, so it never helps find a beat (abilities on the global cooldown land at steady
-- intervals that could pass for a swing speed).
local function CastWaiting(now)
    for index = 1, #pending do
        local entry = pending[index]
        if (entry.hits or 0) == 0 and now - (entry.t0 or 0) <= (entry.window or 0) then
            return true
        end
    end
    return false
end

-- For a likely white hit: the source whose beat it is on (or that it just confirmed), and
-- whether all your hands have a confirmed beat.
local function ReadSwing(now)
    if not ReadSwingSpeeds() then
        ResetSwingTimer()
        return nil, false
    end
    local onSource, bestOffset
    for source = 1, SOURCE_PET do
        local at, speed = swingBeat[source], swingSpeed[source]
        if at then
            local offset = speed and BeatOffset(at, speed, now)
            if not offset then
                swingBeat[source] = nil
            elseif offset <= BD.SWING_TOLERANCE and (not bestOffset or offset < bestOffset) then
                onSource, bestOffset = source, offset
            end
        end
    end
    if onSource then
        swingBeat[onSource] = now
        return onSource, true
    end

    if CastWaiting(now) then
        return nil, BeatFresh(1, now) and (not swingSpeed[2] or BeatFresh(2, now))
    end

    -- Not on a beat: does it confirm an open beat with an earlier likely white hit? Yours first.
    local keepFor = math.max(swingSpeed[1], swingSpeed[2] or 0, swingSpeed[SOURCE_PET] or 0)
        + BD.SWING_TOLERANCE
    local write = 1
    for read = 1, #swingCandidates do
        local at = swingCandidates[read]
        if now - at <= keepFor then
            swingCandidates[write] = at
            write = write + 1
        end
    end
    for index = write, #swingCandidates do
        swingCandidates[index] = nil
    end
    for source = 1, SOURCE_PET do
        local speed = swingSpeed[source]
        if speed and not BeatFresh(source, now) then
            for index = #swingCandidates, 1, -1 do
                if math.abs((now - swingCandidates[index]) - speed) <= BD.SWING_TOLERANCE then
                    swingBeat[source] = now
                    table.remove(swingCandidates, index)
                    return source, false
                end
            end
        end
    end
    if #swingCandidates >= 8 then
        table.remove(swingCandidates, 1)
    end
    swingCandidates[#swingCandidates + 1] = now
    return nil, BeatFresh(1, now) and (not swingSpeed[2] or BeatFresh(2, now))
end

-- Shortest plausible time between two swings of one hand, and whether you dual wield. Falls
-- back to the strictness gap when the attack speed cannot be read.
local function SwingGap(strict)
    local ok, gap, dualWield = pcall(function()
        local main, off = UnitAttackSpeed("player")
        if type(main) ~= "number" or main <= 0 then
            return nil
        end
        local hasOff = type(off) == "number" and off > 0
        return (hasOff and math.min(main, off) or main) * BD.SWING_GAP_SHARE, hasOff
    end)
    if ok and gap then
        return gap, dualWield
    end
    return strict.autoFallbackGap or 0.9, false
end

-- One auto-attack label per swing gap, per hand when dual wielding, so other physical hits on
-- your target cannot all pass as your swings.
-- A swing the damage meter confirmed: it sets the beat of the hand it is on, or of an open one.
local function FeedSwing(now, firstSource, lastSource)
    if not ReadSwingSpeeds() then
        return
    end
    for source = firstSource, lastSource do
        local at, speed = swingBeat[source], swingSpeed[source]
        local offset = at and speed and BeatOffset(at, speed, now)
        if offset and offset <= BD.SWING_TOLERANCE then
            swingBeat[source] = now
            return
        end
    end
    for source = firstSource, lastSource do
        if swingSpeed[source] and not BeatFresh(source, now) then
            swingBeat[source] = now
            return
        end
    end
end

--- Your pet's swing, confirmed by the damage meter (Meter.lua).
function BD:NoteConfirmedPetSwing(at)
    FeedSwing(at, SOURCE_PET, SOURCE_PET)
end

-- A hit the damage meter confirmed (Meter.lua): it uses up the cast it came from and teaches
-- that cast's delay and school, or sets your swing beat.
local function ConfirmHit(verdict, school, now)
    if verdict.auto then
        previousAutoFallbackTime, lastAutoAttackFallbackTime = lastAutoAttackFallbackTime, now
        FeedSwing(now, 1, 2)
        return BD.AUTO_ATTACK_SPELL_ID, true
    end
    local spellID = verdict.spellID
    if not Learnable(spellID) then
        return spellID, false
    end
    local castID = learnedCastFor[spellID] or spellID
    local entry, waiting, lone = nil, 0, nil
    for index = #pending, 1, -1 do
        local candidate = pending[index]
        local age = now - (candidate.t0 or 0)
        if age >= 0 and Learnable(candidate.spellID) then
            if not entry and candidate.spellID == castID then
                entry = candidate
            end
            if (candidate.hits or 0) == 0 and age <= (candidate.window or 0) then
                waiting, lone = waiting + 1, candidate
            end
        end
    end
    -- No cast of that ID: if exactly one cast is waiting for its first hit, this is its damage.
    if not entry and waiting == 1 then
        entry = lone
        learnedCastFor[spellID] = lone.spellID
    end
    if entry then
        castID = entry.spellID
        if (entry.hits or 0) == 0 then
            local age = math.min(now - (entry.t0 or now), entry.window or 0)
            local delay = learnedDelay[castID]
            learnedDelay[castID] = delay and (delay + (age - delay) * LEARN_RATE) or age
        end
        entry.hits = (entry.hits or 0) + 1
        entry.lastHitAt = now
        if (entry.hitsLeft or 0) > 0 then
            entry.hitsLeft = entry.hitsLeft - 1
        end
        if school then
            learnedSchool[castID], learnedSchoolMiss[castID] = school, nil
        end
        learnedNoHit[castID] = nil
    end
    return spellID, false
end

local function CanUseAutoAttackFallback(now, strict)
    if not strict.autoFallback then
        return false
    end
    local gap, dualWield = SwingGap(strict)
    if lastAutoAttackFallbackTime > 0 and (now - lastAutoAttackFallbackTime) < gap then
        return dualWield and (now - previousAutoFallbackTime) >= gap
    end
    return true
end

--- Returns spellID, usedAuto (or nil if no match).
-- isHeal: the hit is a heal, which a buff cast may explain and the auto-attack fallback never does.
function BD:MatchOutgoingHit(unit, schoolMask, isHeal)
    BD.API.AssertModern("Attribution.MatchOutgoingHit")
    -- A hit held for the damage meter is matched at the time it landed.
    local now = BD.hitTimeOverride or GetTime()
    local strict = self:GetActiveStrictness()
    if BD.meterVerdict and not isHeal then
        return ConfirmHit(BD.meterVerdict, KnownSchool(schoolMask), now)
    end
    local autoCandidate = not isHeal and not IsLikelySpellSchool(schoolMask)
        and (BD.UnitsMatch(unit, "target") or unit == "target")
    hitSchool, hitIsHeal = KnownSchool(schoolMask), isHeal
    hitMaybeWhite = autoCandidate and IsAutoAttacking()
    hitOffBeat = false
    if autoCandidate and not hitMaybeWhite then
        ResetSwingTimer()
    elseif hitMaybeWhite and strict.autoFallback then
        local source, allConfirmed = ReadSwing(now)
        if source == SOURCE_PET then
            -- Your pet's melee: not shown as yours.
            return nil, false
        elseif source then
            previousAutoFallbackTime, lastAutoAttackFallbackTime = lastAutoAttackFallbackTime, now
            return BD.AUTO_ATTACK_SPELL_ID, true
        end
        hitOffBeat = allConfirmed
    end
    hitPreferAuto = hitMaybeWhite and not hitOffBeat and CanUseAutoAttackFallback(now, strict)
    local spellID = TryMatchPending(unit, now, strict)
    if spellID then
        return spellID, false
    end

    -- Off your swing beat and no cast explains it: a pet's or another player's hit.
    if hitOffBeat then
        return nil, false
    end
    -- Only while you auto-attack: a caster's or healer's target takes physical hits from others.
    if hitMaybeWhite and CanUseAutoAttackFallback(now, strict) then
        previousAutoFallbackTime, lastAutoAttackFallbackTime = lastAutoAttackFallbackTime, now
        return BD.AUTO_ATTACK_SPELL_ID, true
    end

    return nil, false
end

function BD:PlayerIsEngagedWith(unit)
    if BD.UnitsMatch(unit, "target") or unit == "target" then
        return true
    end
    if BD.UnitsMatch(unit, "focus") then
        return true
    end
    if UnitExists("pet") and BD.UnitsMatch(unit, "pettarget") then
        return true
    end

    local ok, status = pcall(UnitThreatSituation, "player", unit)
    if not ok then
        return true
    end
    if not BD.CanAccessValue(status) then
        return true
    end
    return status ~= nil
end

function BD:ClearAttributionState()
    previousAutoFallbackTime = 0
    wipe(learnedNoHit)
    ResetSwingTimer()
    wipe(learnedDelay)
    wipe(learnedSchool)
    wipe(learnedSchoolMiss)
    wipe(learnedCastFor)
    for index = #pending, 1, -1 do
        ReleasePending(pending[index])
        pending[index] = nil
    end
    wipe(castMeta)
    lastAutoAttackFallbackTime = 0
end

-- What was learned is kept between sessions (PlateSCTDB.attributionLearned), so the guesswork
-- in instances, where the damage meter cannot be read, starts from what the open world taught.
local LEARNED_TABLES = {
    delay = learnedDelay, school = learnedSchool, noHit = learnedNoHit, castFor = learnedCastFor,
}

local stateFrame = CreateFrame("Frame")
stateFrame:RegisterEvent("ADDON_LOADED")
stateFrame:RegisterEvent("PLAYER_LOGOUT")
stateFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
stateFrame:RegisterEvent("PLAYER_LEAVE_COMBAT")
stateFrame:SetScript("OnEvent", function(_, event, name)
    if event == "PLAYER_ENTER_COMBAT" then
        autoAttackOn = true
    elseif event == "PLAYER_LEAVE_COMBAT" then
        autoAttackOn = false
    elseif event == "ADDON_LOADED" and name == addonName then
        local saved = type(PlateSCTDB) == "table" and PlateSCTDB.attributionLearned
        if type(saved) == "table" then
            for key, into in pairs(LEARNED_TABLES) do
                if type(saved[key]) == "table" then
                    for spellID, value in pairs(saved[key]) do
                        if type(spellID) == "number" and type(value) == "number" then
                            into[spellID] = value
                        end
                    end
                end
            end
        end
    elseif event == "PLAYER_LOGOUT" and type(PlateSCTDB) == "table" then
        local saved = {}
        for key, from in pairs(LEARNED_TABLES) do
            saved[key] = {}
            for spellID, value in pairs(from) do
                saved[key][spellID] = value
            end
        end
        PlateSCTDB.attributionLearned = saved
    end
end)
