local _, BD = ...

local pending = {}
local pendingPool = {}
local castMeta = {}
local lastAutoAttackFallbackTime = 0

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

local function TryMatchPending(unit, now, strict)
    ExpireStale(now)
    local bestIndex
    local preferDest = false

    for index = 1, #pending do
        local entry = pending[index]
        if entry.source == "pet" and not (BD.db and BD.db.includePetDamage) then
            -- skip
        else
            local age = now - (entry.t0 or 0)
            local window = entry.window or 0
            local linger = entry.linger or 0
            local inWindow = age <= window
            local inLinger = linger > window and age <= linger
            if (inWindow or inLinger) and CanUsePendingOnUnit(entry, unit, strict) then
                local destMatch = DestMatches(entry, unit)
                if destMatch then
                    bestIndex = index
                    preferDest = true
                    break
                end
                if not preferDest and not bestIndex then
                    bestIndex = index
                end
            end
        end
    end

    if not bestIndex then
        return nil
    end

    local entry = pending[bestIndex]
    local age = now - (entry.t0 or 0)
    local window = entry.window or 0
    local linger = entry.linger or 0
    local inLingerOnly = age > window and linger > window

    if not inLingerOnly and (entry.hitsLeft or 0) > 0 then
        entry.hitsLeft = entry.hitsLeft - 1
        if entry.hitsLeft <= 0 and not (linger > window) then
            table.remove(pending, bestIndex)
            local spellID = entry.spellID
            ReleasePending(entry)
            return spellID, false
        end
        if entry.hitsLeft <= 0 then
            entry.hitsLeft = 0
        end
    end

    return entry.spellID, false
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

--- Returns spellID, usedAuto (or nil if no match).
function BD:MatchOutgoingHit(unit, schoolMask)
    BD.API.AssertModern("Attribution.MatchOutgoingHit")
    local now = GetTime()
    local strict = self:GetActiveStrictness()
    local spellID = TryMatchPending(unit, now, strict)
    if spellID then
        return spellID, false
    end

    if not IsLikelySpellSchool(schoolMask) and CanUseAutoAttackFallback(now, strict) then
        if BD.UnitsMatch(unit, "target") or unit == "target" then
            lastAutoAttackFallbackTime = now
            return BD.AUTO_ATTACK_SPELL_ID, true
        end
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
    for index = #pending, 1, -1 do
        ReleasePending(pending[index])
        pending[index] = nil
    end
    wipe(castMeta)
    lastAutoAttackFallbackTime = 0
end
