local _, BD = ...

local pending = {}
local pendingPool = {}
local castMeta = {}
local lastAutoAttackFallbackTime = 0
-- Your own swing state (PLAYER_ENTER_COMBAT / START_AUTOREPEAT_SPELL). Game state, not evidence:
-- ClearAttributionState leaves it alone.
local autoAttackMelee, autoAttackRanged = false, false
-- Swing clock, one record per hand: each hand swings on a beat, anchor + k * period.
--   anchor  nil means no lock yet (auto attack just started, a reload, or the beat was lost)
--   last    GetTime of the last swing credited to the hand
--   period  the live attack speed, or learned from credited swings while the client hides it
--           (Forever hides it in combat, and a reading from before combat misses haste since)
--   streak  beats credited in a row since the lock; a learned period is settled after a few
local hands = { main = { streak = 0 }, off = { streak = 0 } }
local HAND_ORDER = { "main", "off" }
-- GetTime of the last swing that landed on a beat, for extra attacks that follow it.
local lastSwingAt
-- A swing is reported up to this far from its beat, either way (latency and server batching).
-- Wider only lets more bleed ticks take the white; the debug log prints each swing's offset.
local SWING_TOLERANCE = 0.2
-- Until a learned period settles, the beat is this share of the period wide (either way), so a
-- wrong starting speed (a haste buff that came or went) is still caught and corrected.
local LEARN_TOLERANCE, LEARN_TOLERANCE_MAX = 0.25, 0.45
local LEARN_SETTLED = 3
-- A learned period is the running average of measured intervals since the lock (the first one
-- counts in full), then moves at least this share of the way toward each new one.
local LEARN_RATE = 0.4
local MIN_SWING_SPEED, MAX_SWING_SPEED, DEFAULT_SWING_SPEED = 0.8, 5.0, 2.0
-- No swing credited for this many beats: the beat has moved (range delay, stun), so lock again.
local LOCK_LOST_BEATS = 2
-- Windfury, Sword Specialization, Hand of Justice: an extra swing right after a real one. This
-- also keeps a swing white when a bleed tick took its beat a moment before.
local EXTRA_ATTACK_WINDOW = 0.15
-- Only a cast this fresh may claim a swing's beat as its own hit (melee abilities land at once).
local FRESH_CAST_CLAIM = 0.4
-- With damage over time hidden, a cast may still take one hit this long after it (projectile travel).
local LATE_HIT_WINDOW = 2.0
-- A channel keeps its window open until it ends, plus this much for the last tick to arrive.
local CHANNEL_GRACE = 0.4
-- Auto Shot and wand Shoot: one hit within projectile travel, never the ticks that follow.
local AUTO_REPEAT_WINDOW = 1.5
-- A cast that still reads as current this long after it succeeded is queued on your next swing.
local NEXT_MELEE_CONFIRM = 0.25
-- Such a guessed next-melee cast must find its swing within this many main-hand periods.
local NEXT_MELEE_GUESS_BEATS = 1.5

-- The plain spell ID, or nil when it is missing or secret.
local function PlainSpellID(spellID)
    if not BD.ValuePresent(spellID) or BD.IsSecret(spellID) then
        return nil
    end
    return spellID
end

local function IsAutoRepeatSpellID(spellID)
    local plain = PlainSpellID(spellID)
    return plain ~= nil and BD.AUTO_REPEAT_SPELL_IDS[plain] == true
end

-- A readable physical school. Secret or unreadable schools never count.
local function IsPhysicalSchool(schoolMask)
    if not BD.ValuePresent(schoolMask) then
        return false
    end
    if BD.IsSecret(schoolMask) and not BD.CanAccessValue(schoolMask) then
        return false
    end
    local ok, physical = pcall(function()
        return schoolMask == 1
    end)
    return ok and physical or false
end

local function PlainPositive(value)
    if BD.IsSecret(value) or type(value) ~= "number" or value <= 0 then
        return nil
    end
    return value
end

-- Main- and off-hand swing times in seconds, already hasted, or nil while the client hides them.
local function ReadAttackSpeed()
    if type(UnitAttackSpeed) ~= "function" then
        return nil, nil
    end
    local ok, mainSpeed, offSpeed = pcall(UnitAttackSpeed, "player")
    if not ok then
        return nil, nil
    end
    return PlainPositive(mainSpeed), PlainPositive(offSpeed)
end

-- Sets each hand's period: the live speed when the client shows it ("live"), else the period
-- learned so far, seeded by the last live reading or DEFAULT_SWING_SPEED ("learned").
local function UpdatePeriods()
    local mainSpeed, offSpeed = ReadAttackSpeed()
    if mainSpeed then
        hands.main.period, hands.main.live = mainSpeed, true
        hands.off.period, hands.off.live = offSpeed, true
        return "live"
    end
    for _, name in ipairs(HAND_ORDER) do
        if hands[name].live then
            -- Just hidden (combat began): the last reading may already be out of date.
            hands[name].live, hands[name].streak = false, 0
        end
    end
    hands.main.period = hands.main.period or DEFAULT_SWING_SPEED
    if not hands.off.period and BD.SafeUnitBoolean(IsDualWielding) then
        hands.off.period = hands.main.period
    end
    return "learned"
end

local function Tolerance(hand)
    if hand.live or hand.streak >= LEARN_SETTLED then
        return SWING_TOLERANCE
    end
    return math.min(LEARN_TOLERANCE_MAX, math.max(SWING_TOLERANCE, LEARN_TOLERANCE * hand.period))
end

-- Recent hits that could be swings (physical, on your target, not a fresh cast's), so a hand
-- without a lock can find its beat in them instead of taking whatever hit comes next.
local history = {}
local HISTORY_SIZE, HISTORY_SPAN = 16, 10
-- Fitting: hits this close to a beat line up with it; periods are searched within FIT_RANGE of the
-- current guess (haste buffs stay within about a third); a fit needs FIT_MIN_SCORE points.
local FIT_ALIGN, FIT_RANGE, FIT_STEP, FIT_MIN_SCORE = 0.12, 0.3, 0.02, 3

-- trusted: certainly a swing or an attack that missed (a crit on Forever, a glancing blow, a
-- dodge or parry), never a bleed tick; it counts double when fitting.
local function RememberCandidate(now, trusted)
    while #history > 0 and (#history >= HISTORY_SIZE or now - history[1].t > HISTORY_SPAN) do
        table.remove(history, 1)
    end
    history[#history + 1] = { t = now, trusted = trusted and true or false }
end

local function OnHandBeat(hand, t)
    if not hand.anchor or not hand.period then
        return false
    end
    local beats = math.floor((t - hand.anchor) / hand.period + 0.5)
    return math.abs(t - (hand.anchor + beats * hand.period)) <= SWING_TOLERANCE
end

-- For a hand without a lock: the beat that lines up the most recent hits, as the latest hit on it
-- and the period (a live period is kept; only its phase is searched). Hits on the other hand's
-- beat are left to it. Nil when too few line up; the hand then locks onto the next hit.
local function FitHand(name, now)
    local hand = hands[name]
    local other = hands[name == "main" and "off" or "main"]
    local base = hand.period or DEFAULT_SWING_SPEED
    local steps = hand.live and 0 or math.floor(base * FIT_RANGE / FIT_STEP)
    local bestScore, bestAnchor, bestPeriod = FIT_MIN_SCORE - 0.5, nil, nil
    for step = -steps, steps do
        local period = base + step * FIT_STEP
        if period >= MIN_SWING_SPEED and period <= MAX_SWING_SPEED then
            for i = 1, #history do
                local origin = history[i].t
                if not OnHandBeat(other, origin) then
                    local score, latest = 0, origin
                    for j = 1, #history do
                        local hit = history[j]
                        if not OnHandBeat(other, hit.t) then
                            local beats = math.floor((hit.t - origin) / period + 0.5)
                            if math.abs(hit.t - (origin + beats * period)) <= FIT_ALIGN then
                                score = score + (hit.trusted and 2 or 1)
                                latest = math.max(latest, hit.t)
                            end
                        end
                    end
                    -- On a tie, the period nearest the current guess.
                    score = score - math.abs(step) * 0.001
                    if score > bestScore then
                        bestScore, bestAnchor, bestPeriod = score, latest, period
                    end
                end
            end
        end
    end
    return bestAnchor, bestPeriod
end

-- How far now is from the hand's nearest beat after its anchor (k >= 1), or nil without a lock.
local function BeatOffset(hand, now)
    if not hand.anchor or not hand.period then
        return nil
    end
    local elapsed = now - hand.anchor
    if elapsed > LOCK_LOST_BEATS * hand.period + Tolerance(hand) then
        return nil
    end
    local beats = math.max(1, math.floor(elapsed / hand.period + 0.5))
    return now - (hand.anchor + beats * hand.period)
end

-- Where a hit at now falls: hand name, state, offset, speed source. state is "beat" (inside a
-- hand's beat window; the hand it fits best wins), "acquire" (a hand has no lock, so this hit sets
-- it) or "off" (between beats: not a swing). A missed beat costs nothing: the next one is still
-- anchor + k * period.
local function FindSwing(now)
    local source = UpdatePeriods()
    local bestName, bestOffset, bestScore, acquireName
    for _, name in ipairs(HAND_ORDER) do
        local hand = hands[name]
        if hand.period then
            local offset = BeatOffset(hand, now)
            if not offset then
                local anchor, period = FitHand(name, now)
                if anchor then
                    hand.anchor, hand.last, hand.streak = anchor, anchor, 1
                    if not hand.live then
                        hand.period = period
                    end
                    local beats = math.floor((now - anchor) / hand.period + 0.5)
                    if anchor < now then
                        beats = math.max(1, beats)
                    end
                    offset = now - (anchor + beats * hand.period)
                    BD:DebugPrint("swing fit", name, string.format("%.2f", hand.period))
                end
            end
            if not offset then
                acquireName = acquireName or name
            else
                local score = math.abs(offset) / Tolerance(hand)
                if score <= 1 and (not bestScore or score < bestScore) then
                    bestName, bestOffset, bestScore = name, offset, score
                end
            end
        end
    end
    if bestName then
        return bestName, "beat", bestOffset, source
    end
    if acquireName then
        return acquireName, "acquire", nil, source
    end
    return nil, "off", BeatOffset(hands.main, now), source
end

-- Credit a swing to a hand. On a beat, a learned period moves toward the measured interval; once
-- settled (or live) the anchor moves halfway toward the hit, so report jitter averages out instead
-- of shifting the beat. Acquiring locks onto the hit itself.
local function CreditSwing(name, state, offset, now, landed)
    local hand = hands[name]
    if state == "beat" and offset then
        if not hand.live and hand.last then
            local beats = math.floor((now - hand.last) / hand.period + 0.5)
            if beats >= 1 and beats <= 2 then
                local interval = (now - hand.last) / beats
                local rate = math.max(LEARN_RATE, 1 / (hand.streak + 1))
                hand.period = math.min(MAX_SWING_SPEED, math.max(MIN_SWING_SPEED,
                    hand.period + rate * (interval - hand.period)))
            end
        end
        hand.streak = hand.streak + 1
        hand.anchor = (hand.live or hand.streak > LEARN_SETTLED) and (now - offset / 2) or now
    else
        hand.streak = 0
        hand.anchor = now
    end
    hand.last = now
    if landed then
        lastSwingAt = now
    end
end

-- A hit known to be a swing landed between beats: the beat it belongs to is wrong (it locked onto
-- a bleed, or the swing timer moved). Lock the hand without a lock, else the hand whose beat is
-- nearest, onto this hit, and relearn from here.
local function MoveBeatTo(now)
    local bestName, bestScore
    for _, name in ipairs(HAND_ORDER) do
        local hand = hands[name]
        if hand.period then
            local offset = BeatOffset(hand, now)
            local score = offset and math.abs(offset) / hand.period or -1
            if not bestScore or score < bestScore then
                bestName, bestScore = name, score
            end
        end
    end
    local hand = hands[bestName or "main"]
    hand.anchor, hand.last, hand.streak = now, nil, 0
    lastSwingAt = now
    return bestName or "main"
end

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
            ReleasePending(entry)
        end
    end
    for index = write, #pending do
        pending[index] = nil
    end
end

-- Seconds left in the player's channel of spellID, or nil. Channel ticks are direct hits, so the
-- cast window covers them instead of the linger meant for damage over time.
local function ChannelTimeLeft(source, spellID, now)
    if source ~= "player" or type(UnitChannelInfo) ~= "function" then
        return nil
    end
    local ok, endTimeMS, channelSpellID = pcall(function()
        local _, _, _, _, endMS, _, _, id = UnitChannelInfo("player")
        return endMS, id
    end)
    if not ok or BD.IsSecret(endTimeMS) or type(endTimeMS) ~= "number" then
        return nil
    end
    if not BD.ValuePresent(channelSpellID) or not BD.ValuesEqual(channelSpellID, spellID) then
        return nil
    end
    local left = endTimeMS / 1000 - now
    if left <= 0 then
        return nil
    end
    return left
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
    local channelLeft = ChannelTimeLeft(entry.source, spellID, now)
    if channelLeft and channelLeft + CHANNEL_GRACE > entry.window then
        entry.window = channelLeft + CHANNEL_GRACE
    end
    entry.channel = channelLeft ~= nil
    entry.hitsLeft = strict.hitsLeft
    entry.linger = strict.linger or 0
    entry.matched = 0
    if IsAutoRepeatSpellID(spellID) then
        entry.autoRepeat = true
        entry.window = math.max(entry.window, AUTO_REPEAT_WINDOW)
        entry.hitsLeft = 1
        entry.linger = 0
    end
    pending[#pending + 1] = entry
    BD:DebugPrint("pending+", entry.kind, spellID, entry.destToken or "no-dest", entry.window)
    return entry
end

-- A next-melee ability (Heroic Strike, Raptor Strike, Maul, Cleave) is still current after it
-- succeeds: it waits for your next swing and replaces it.
local function IsQueuedOnSwing(spellID)
    local plain = PlainSpellID(spellID)
    if not plain then
        return false
    end
    local isCurrentSpell = (C_Spell and C_Spell.IsCurrentSpell) or IsCurrentSpell
    return BD.SafeUnitBoolean(isCurrentSpell, plain)
end

-- Stealth, forms, stances and seals also read as current, as long as their aura lasts.
local function IsPlayerAura(spellID)
    local getAura = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID
    if type(getAura) ~= "function" or not spellID then
        return false
    end
    local ok, aura = pcall(getAura, spellID)
    return ok and BD.ValuePresent(aura) or false
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
    if meta and meta.destGone then
        -- Its target's token was released mid-cast; it may already name another enemy.
        return
    end
    if PlainSpellID(spellID) == BD.AUTO_ATTACK_SPELL_ID then
        -- Turning auto attack on. The swing clock credits the swings themselves.
        return
    end
    local kind = (meta and meta.kind == "cast") and "cast" or "instant"
    local destToken = (meta and meta.destToken) or CaptureDestToken()
    local entry = PushPending(spellID, unit, destToken, kind)
    if not entry or unit ~= "player" or entry.autoRepeat or entry.channel then
        return
    end
    local plain = PlainSpellID(spellID)
    if plain and BD.NEXT_MELEE_SPELL_IDS[plain] then
        entry.nextMelee = true
        BD:DebugPrint("pending next melee", plain, "known")
    elseif IsQueuedOnSwing(plain) and C_Timer and C_Timer.After then
        -- Any instant can still read as current while its own event runs, and would then steal your
        -- next swing. A next-melee ability stays current until that swing lands, so ask again later.
        local t0 = entry.t0
        C_Timer.After(NEXT_MELEE_CONFIRM, function()
            if entry.spellID == plain and entry.t0 == t0 and (entry.matched or 0) == 0 and IsQueuedOnSwing(plain)
                and not IsPlayerAura(plain) then
                entry.nextMelee, entry.nextMeleeGuess = true, true
                BD:DebugPrint("pending next melee", plain, "still queued")
            end
        end)
    end
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

-- The pending cast a hit on unit would match, and whether it is inside its direct window.
-- Consumes nothing. lateHits false (damage over time hidden): past its window a cast takes at
-- most one hit, within LATE_HIT_WINDOW, and only if nothing matched it yet. A slow projectile
-- still lands; the bleed and DoT ticks that follow, and other players' hits, no longer borrow
-- the newest cast's icon. physicalHit: a cast whose own first hit was a spell school (a nature
-- proc, a poison, a DoT) never takes a physical hit; those are swings or bleeds.
local function FindPending(unit, now, strict, lateHits, physicalHit)
    ExpireStale(now)
    local bestIndex, bestInWindow

    -- Newest first: an older cast with hits or linger left must not take the
    -- hit of the cast just made, or icons trail one cast behind.
    for index = #pending, 1, -1 do
        local entry = pending[index]
        if entry.source == "pet" and not (BD.db and BD.db.includePetDamage) then
            -- skip
        elseif physicalHit and entry.spellOnly then
            -- skip
        else
            local age = now - (entry.t0 or 0)
            local window = entry.window or 0
            local linger = entry.linger or 0
            local inWindow = age <= window
            local inLinger = linger > window and age <= linger
            if inLinger and not lateHits then
                inLinger = (entry.matched or 0) == 0 and age <= LATE_HIT_WINDOW
            end
            if (inWindow or inLinger) and CanUsePendingOnUnit(entry, unit, strict) then
                if DestMatches(entry, unit) then
                    return index, inWindow
                end
                if not bestIndex then
                    bestIndex, bestInWindow = index, inWindow
                end
            end
        end
    end

    return bestIndex, bestInWindow
end

-- Spends one hit of pending[index] and returns its spell ID.
local function ConsumePending(index, now)
    local entry = pending[index]
    entry.matched = (entry.matched or 0) + 1
    local age = now - (entry.t0 or 0)
    local window = entry.window or 0
    local linger = entry.linger or 0
    local inLingerOnly = age > window and linger > window

    if not inLingerOnly and (entry.hitsLeft or 0) > 0 then
        entry.hitsLeft = entry.hitsLeft - 1
        if entry.hitsLeft <= 0 and not (linger > window) then
            table.remove(pending, index)
            local spellID = entry.spellID
            ReleasePending(entry)
            return spellID
        end
        if entry.hitsLeft <= 0 then
            entry.hitsLeft = 0
        end
    end

    return entry.spellID
end

-- A next-melee ability waiting on unit takes the swing it replaces. One only guessed from
-- IsCurrentSpell must find it within NEXT_MELEE_GUESS_BEATS main-hand periods, the longest a
-- queued ability waits; past that it was something else that stayed current.
local function ClaimNextMelee(unit, now, strict)
    ExpireStale(now)
    local maxGuessAge = NEXT_MELEE_GUESS_BEATS * (hands.main.period or DEFAULT_SWING_SPEED) + SWING_TOLERANCE
    for index = #pending, 1, -1 do
        local entry = pending[index]
        if entry.nextMelee and entry.nextMeleeGuess and now - (entry.t0 or 0) > maxGuessAge then
            entry.nextMelee, entry.nextMeleeGuess = nil, nil
        elseif entry.nextMelee and CanUsePendingOnUnit(entry, unit, strict) then
            entry.nextMelee, entry.nextMeleeGuess = nil, nil
            return ConsumePending(index, now)
        end
    end
    return nil
end

-- A cast that just went off (at most FRESH_CAST_CLAIM ago) and has not hit yet takes the next
-- hit: its own hit arrives first. A shout or buff never hits, so its claim stays short.
local function ClaimFreshCast(unit, now, strict, lateHits)
    local index, inWindow = FindPending(unit, now, strict, lateHits)
    local entry = index and pending[index]
    if entry and inWindow and not entry.autoRepeat and not entry.nextMelee and (entry.matched or 0) == 0
        and now - (entry.t0 or 0) <= FRESH_CAST_CLAIM then
        return ConsumePending(index, now)
    end
    return nil
end

local function CanUseAutoAttackFallback(now, strict)
    if not strict.autoFallback then
        return false
    end
    local gap = strict.autoFallbackGap or 0.9
    if lastAutoAttackFallbackTime > 0 and (now - lastAutoAttackFallbackTime) < gap then
        return false
    end
    return true
end

local function MeleeAutoAttacking()
    if autoAttackMelee then
        return true
    end
    -- Covers a reload mid-swing, before the next PLAYER_ENTER_COMBAT.
    local isCurrentSpell = (C_Spell and C_Spell.IsCurrentSpell) or IsCurrentSpell
    return BD.SafeUnitBoolean(isCurrentSpell, BD.AUTO_ATTACK_SPELL_ID)
end

-- The icon for a ranged auto attack: Auto Shot while it repeats, else the generic swing.
local function RangedAutoSpellID()
    local isAutoRepeat = (C_Spell and C_Spell.IsAutoRepeatSpell) or IsAutoRepeatSpell
    if BD.SafeUnitBoolean(isAutoRepeat, BD.AUTO_SHOT_SPELL_ID) then
        return BD.AUTO_SHOT_SPELL_ID
    end
    return BD.AUTO_ATTACK_SPELL_ID
end

-- Debug log only: the state that decides whether a damage hit counts as your swing.
local function DebugSwingCheck(self, onTarget, strict, melee, hand, state, offset, speedSource, schoolMask, flagText)
    local school = "none"
    if BD.ValuePresent(schoolMask) then
        if BD.IsSecret(schoolMask) and not BD.CanAccessValue(schoolMask) then
            school = "secret"
        else
            school = IsPhysicalSchool(schoolMask) and "physical" or "spell"
        end
    end
    local function Period(name)
        local h = hands[name]
        return h.period and string.format("%.2f/%d", h.period, h.streak) or "-"
    end
    local clock = "-"
    if melee then
        clock = state .. (hand and (" " .. hand) or "")
            .. (offset and string.format(" %+.2f", offset) or "")
    end
    self:DebugPrint("swing check", "target=" .. tostring(onTarget and true or false),
        "meleeOn=" .. tostring(MeleeAutoAttacking()), "rangedOn=" .. tostring(autoAttackRanged),
        "fallback=" .. tostring(strict.autoFallback and true or false),
        "speed=" .. Period("main") .. " " .. Period("off") .. " " .. (speedSource or "-"),
        "clock=" .. clock, "school=" .. school, "flag", flagText)
end

--- Returns spellID, isAutoAttack, swingHand (or nil if no match). isAutoAttack marks your own
--- auto attack, a best guess on Modern API. Heals keep HoT ticks and never use the auto attack.
---
--- Bleeds and other players' melee are physical too, so a physical hit on your target counts as
--- your swing only while your auto attack runs and only on a beat of your swing clock (or as an
--- extra attack right after one). A swing beats the linger of your last cast, except for a
--- next-melee ability waiting for it or a cast that just went off and has not hit yet.
function BD:MatchOutgoingHit(unit, schoolMask, isHeal, flagText)
    BD.API.AssertModern("Attribution.MatchOutgoingHit")
    local now = GetTime()
    local strict = self:GetActiveStrictness()
    local lateHits = isHeal or not (self.db and self.db.showDamageOverTime == false)
    local onTarget = BD.UnitsMatch(unit, "target") or unit == "target"
    local melee = not isHeal and onTarget and strict.autoFallback and MeleeAutoAttacking()
    -- A missing school counts like physical, as in the fallback below; a spell school never does.
    local physical = melee and (IsPhysicalSchool(schoolMask) or not BD.ValuePresent(schoolMask))
    -- Only white swings glance, so a glancing blow is a swing even between beats. Forever follows
    -- Classic rules, where periodic damage never crits: a physical crit that no cast claims is a
    -- swing too, never a bleed tick.
    local glancing = flagText == "GLANCING"
    local critSwing = flagText == "CRITICAL" and BD.API.IsForever and BD.API.IsForever() or false
    if physical and not glancing then
        -- A cast that just went off takes its own hit before anything counts it as a swing.
        local castSpellID = ClaimFreshCast(unit, now, strict, lateHits)
        if castSpellID then
            self:DebugPrint("fresh cast", castSpellID)
            return castSpellID, false
        end
    end
    if physical then
        RememberCandidate(now, glancing or critSwing)
    end
    local hand, state, offset, speedSource
    if melee then
        hand, state, offset, speedSource = FindSwing(now)
    end
    if not isHeal and self.db and self.db.debug then
        DebugSwingCheck(self, onTarget, strict, melee, hand, state, offset, speedSource, schoolMask, flagText)
    end

    if physical then
        local onBeat = state ~= "off"
        local extra = not onBeat and lastSwingAt ~= nil and now - lastSwingAt <= EXTRA_ATTACK_WINDOW
        if onBeat or glancing or critSwing or extra then
            if not glancing and (onBeat or critSwing) then
                local castSpellID = ClaimNextMelee(unit, now, strict)
                if castSpellID then
                    -- It replaced this swing: the beat is spent.
                    if onBeat then
                        CreditSwing(hand, state, offset, now, true)
                    else
                        MoveBeatTo(now)
                    end
                    return castSpellID, false
                end
            end
            lastAutoAttackFallbackTime = now
            if onBeat then
                CreditSwing(hand, state, offset, now, true)
                return BD.AUTO_ATTACK_SPELL_ID, true, hand
            end
            if extra then
                -- Between beats the clock stays put. One extra attack per swing.
                lastSwingAt = nil
                return BD.AUTO_ATTACK_SPELL_ID, true, "extra"
            end
            if critSwing then
                return BD.AUTO_ATTACK_SPELL_ID, true, MoveBeatTo(now) .. " moved"
            end
            return BD.AUTO_ATTACK_SPELL_ID, true, "glancing"
        end
    end

    local readablePhysical = IsPhysicalSchool(schoolMask)
    local index, inWindow = FindPending(unit, now, strict, lateHits, readablePhysical)
    if index then
        local entry = pending[index]
        local autoRepeat = entry.autoRepeat and not isHeal
        if not isHeal and (entry.matched or 0) == 0 and not readablePhysical and IsLikelySpellSchool(schoolMask)
            and not (BD.IsSecret(schoolMask) and not BD.CanAccessValue(schoolMask)) then
            -- Its own hit is a readable spell school: physical hits are not its.
            entry.spellOnly = true
        end
        local spellID = ConsumePending(index, now)
        self:DebugPrint("pending match", spellID, inWindow and "window" or "linger", autoRepeat and "auto repeat" or "")
        return spellID, autoRepeat and true or false
    end

    if isHeal or not onTarget or IsLikelySpellSchool(schoolMask) or not strict.autoFallback then
        return nil, false
    end
    if melee then
        if state ~= "off" then
            -- Unreadable school, but it falls on a swing's beat.
            CreditSwing(hand, state, offset, now, true)
            lastAutoAttackFallbackTime = now
            return BD.AUTO_ATTACK_SPELL_ID, true, hand
        end
        if CanUseAutoAttackFallback(now, strict) then
            -- Off the beat and nothing else claims it: shown as before the swing clock (one per
            -- auto-attack gap) rather than hidden. The clock stays put.
            lastAutoAttackFallbackTime = now
            return BD.AUTO_ATTACK_SPELL_ID, true, "gap"
        end
    elseif autoAttackRanged and CanUseAutoAttackFallback(now, strict) then
        lastAutoAttackFallbackTime = now
        return RangedAutoSpellID(), true
    end
    -- Your pet's attack on its target keeps the swing icon, without your white.
    if self.db and self.db.includePetDamage and BD.SafeUnitBoolean(UnitExists, "pet")
        and BD.UnitsMatch(unit, "pettarget") and CanUseAutoAttackFallback(now, strict) then
        lastAutoAttackFallbackTime = now
        return BD.AUTO_ATTACK_SPELL_ID, false
    end
    -- Last resort, as before spell-school casts gave up physical hits: a hit nothing else explains
    -- still shows under the cast that lingers, rather than not at all.
    if readablePhysical then
        index = FindPending(unit, now, strict, lateHits, false)
        if index then
            local spellID = ConsumePending(index, now)
            self:DebugPrint("pending match", spellID, "last resort")
            return spellID, false
        end
    end

    return nil, false
end

-- An outgoing miss (dodge, parry, block, ...) on your target. A cast that has not hit yet takes
-- it, which frees the swings after it. A miss on a locked beat keeps the anchor fresh; a missed
-- swing brings no extra attack, and a miss never sets a lock (it may be another player's).
function BD:NoteOutgoingSwingMiss(unit)
    BD.API.AssertModern("Attribution.NoteOutgoingSwingMiss")
    if not (BD.UnitsMatch(unit, "target") or unit == "target") then
        return
    end
    local strict = self:GetActiveStrictness()
    if not strict.autoFallback or not MeleeAutoAttacking() then
        return
    end
    local now = GetTime()
    local lateHits = not (self.db and self.db.showDamageOverTime == false)
    if ClaimFreshCast(unit, now, strict, lateHits) then
        return
    end
    -- An attack that missed is never a bleed tick: a strong hint for fitting a beat.
    RememberCandidate(now, true)
    local hand, state, offset = FindSwing(now)
    if state ~= "beat" then
        return
    end
    ClaimNextMelee(unit, now, strict)
    CreditSwing(hand, state, offset, now, false)
    lastAutoAttackFallbackTime = now
    BD:DebugPrint("swing miss", hand, offset and string.format("%+.2f", offset) or "")
end

-- PLAYER_ENTER_COMBAT / PLAYER_LEAVE_COMBAT ("melee") and START_ / STOP_AUTOREPEAT_SPELL ("ranged").
-- Starting or stopping a melee auto attack drops the lock: the next swings set the beat again.
-- Learned periods stay; they are the best guess until a live reading replaces them.
function BD:SetAutoAttackState(kind, active)
    BD.API.AssertModern("Attribution.SetAutoAttackState")
    if kind == "ranged" then
        autoAttackRanged = active and true or false
    else
        autoAttackMelee = active and true or false
        for _, name in ipairs(HAND_ORDER) do
            hands[name].anchor, hands[name].last, hands[name].streak = nil, nil, 0
        end
        lastSwingAt = nil
        -- Often still outside combat lockdown here: take a live reading while it is shown.
        UpdatePeriods()
    end
end

-- PLAYER_REGEN_ENABLED, PLAYER_EQUIPMENT_CHANGED and UNIT_ATTACK_SPEED. Shown speeds replace the
-- learned periods; a change while they are hidden (haste in combat) widens the beat to relearn.
function BD:RefreshSwingSpeed()
    BD.API.AssertModern("Attribution.RefreshSwingSpeed")
    if UpdatePeriods() ~= "live" then
        hands.main.streak, hands.off.streak = 0, 0
        BD:DebugPrint("swing speed changed while hidden")
    end
end

-- NAME_PLATE_UNIT_REMOVED, and PLAYER_TARGET_CHANGED for "target": the token names another unit
-- next, often a distant enemy someone else is fighting. Evidence aimed at it must not follow.
function BD:ForgetAttributionUnit(unit)
    BD.API.AssertModern("Attribution.ForgetAttributionUnit")
    if not unit then
        return
    end
    for index = #pending, 1, -1 do
        local entry = pending[index]
        if entry.destToken == unit then
            table.remove(pending, index)
            ReleasePending(entry)
        end
    end
    for _, meta in pairs(castMeta) do
        if meta.destToken == unit then
            meta.destToken = nil
            meta.destGone = true
        end
    end
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
    -- A secret status cannot be read, so allow it. nil means you are not on the threat table:
    -- check secrets first, since comparing a secret raises an error.
    if BD.IsSecret(status) then
        return true
    end
    return status ~= nil
end

function BD:ClearAttributionState()
    for index = #pending, 1, -1 do
        ReleasePending(pending[index])
        pending[index] = nil
    end
    wipe(castMeta)
    lastAutoAttackFallbackTime = 0
end
