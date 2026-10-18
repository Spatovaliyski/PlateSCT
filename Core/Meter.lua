local _, BD = ...

-- Damage meter check (Modern). UNIT_COMBAT does not say who hit or with what, but Blizzard's
-- damage meter (C_DamageMeter) keeps your damage per spell, with your pets and guardians
-- apart. While its numbers are readable (not under combat restrictions: instances, encounters,
-- Mythic+, PvP), a personal hit is held for a moment until the total of one of your spells grows
-- by exactly its amount. That settles whose hit it was and which spell it was. A hit the meter
-- does not confirm in time falls back to the guesswork in Attribution.lua, which learns from
-- every confirmed hit for the content where the meter cannot be read.
if not BD.API.IsModern() then
    return
end

local held = {}     -- hits waiting for the meter: { unit, plate, amount, isCrit, schoolMask, at }
local growth = {}   -- meter growth no hit explained yet: { spellID, creature, amount, overkill, at }
local totals = {}   -- creature name ("" for you) -> spellID -> last total
local overkills = {} -- creature name -> spellID -> last overkill total
local readAt, lastReadOk -- the meter is read at most every METER_MIN_READ seconds
local baselined = false
local readableAt
local latency = BD.METER_LATENCY_START
local misses = 0
local grewAt -- last time any of your spells' totals grew
local unreadableUntil = 0 -- after a failed read (secret values), skip reads for a while
local pausedUntil = 0
local tickScheduled = false
local scratch = {}  -- spell rows of one read, committed only if the whole read was readable
local verdict = {}

local function MeterAvailable()
    return C_DamageMeter and type(C_DamageMeter.GetCombatSessionSourceFromType) == "function"
end

local function HoldTime()
    return math.min(BD.METER_HOLD_MAX, math.max(BD.METER_HOLD_MIN, latency * 1.5 + 0.1))
end

local function Rebaseline()
    wipe(totals)
    wipe(overkills)
    wipe(growth)
    baselined = false
end

-- Reads your spells' totals and records how much each grew since the last read. False when the
-- meter cannot be read now (missing, or its values are secret).
-- Each read builds a table of all your spells, so reads are throttled; a meter update that
-- comes too soon after a read is read on the next tick (readSoon), so no growth is lost.
local readSoon = false

local function ReadMeter(now)
    if now < unreadableUntil then
        return false
    end
    if readAt and now - readAt < BD.METER_MIN_READ then
        return lastReadOk
    end
    readAt, lastReadOk, readSoon = now, false, false
    local guid = UnitGUID("player")
    if type(guid) ~= "string" or BD.IsSecret(guid) then
        return false
    end
    local sessionType = (Enum and Enum.DamageMeterSessionType and Enum.DamageMeterSessionType.Overall) or 0
    local meterType = (Enum and Enum.DamageMeterType and Enum.DamageMeterType.DamageDone) or 0
    local count = 0
    -- Reading a secret value is fine, comparing or adding one raises: the pcall catches both.
    local ok = pcall(function()
        local source = C_DamageMeter.GetCombatSessionSourceFromType(sessionType, meterType, guid)
        local spells = source and source.combatSpells
        if type(spells) ~= "table" then
            error("no spells")
        end
        for _, spell in ipairs(spells) do
            local spellID, total = spell.spellID, spell.totalAmount
            local overkill, creature = spell.overkillAmount or 0, spell.creatureName or ""
            if BD.IsSecret(spellID) or BD.IsSecret(total) or BD.IsSecret(overkill) or BD.IsSecret(creature) then
                error("secret")
            end
            if type(spellID) == "number" and type(total) == "number" and total >= 0 then
                count = count + 1
                local row = scratch[count]
                if not row then
                    row = {}
                    scratch[count] = row
                end
                row.spellID, row.total, row.overkill, row.creature = spellID, total, overkill, creature
            end
        end
    end)
    if not ok then
        unreadableUntil = now + BD.METER_RETRY
        return false
    end
    readableAt, lastReadOk = now, true

    -- A total that shrank means the meter was reset: start over from these totals.
    if baselined then
        for index = 1, count do
            local row = scratch[index]
            local last = totals[row.creature] and totals[row.creature][row.spellID]
            if last and row.total < last then
                Rebaseline()
                break
            end
        end
    end
    for index = 1, count do
        local row = scratch[index]
        local byCreature = totals[row.creature]
        if not byCreature then
            byCreature = {}
            totals[row.creature], overkills[row.creature] = byCreature, {}
        end
        local last = byCreature[row.spellID]
        if baselined and row.total > (last or 0) then
            grewAt = now
            growth[#growth + 1] = {
                spellID = row.spellID,
                creature = row.creature,
                amount = row.total - (last or 0),
                overkill = math.max(0, row.overkill - (overkills[row.creature][row.spellID] or 0)),
                at = now,
            }
            BD:DebugPrint("meter +", row.spellID, row.creature ~= "" and row.creature or "you", row.total - (last or 0))
        end
        byCreature[row.spellID], overkills[row.creature][row.spellID] = row.total, row.overkill
    end
    baselined = true
    return true
end

local function Replay(hit, spellID, isAuto)
    if BD.GetNamePlateFrame(hit.unit) ~= hit.plate then
        return -- plate gone or reused
    end
    if spellID then
        verdict.spellID, verdict.auto = spellID, isAuto
        BD.meterVerdict = verdict
    end
    BD.meterReplay, BD.hitTimeOverride = true, hit.at
    local ok, err = pcall(BD.ShowPersonalDamageNow, hit.unit, hit.amount, hit.isCrit, hit.schoolMask)
    BD.meterReplay, BD.hitTimeOverride, BD.meterVerdict = nil, nil, nil
    if not ok then
        geterrorhandler()(err)
    end
end

local function IsAutoAttackSpell(spellID)
    return spellID == BD.AUTO_ATTACK_SPELL_ID or spellID == BD.AUTO_SHOT_SPELL_ID or spellID == 1
end

-- The meter credited this hit to `row`: show it as that spell, or not at all for pet melee (and
-- pet spells when pet damage is off).
local function Resolve(hit, row, now)
    if row.at >= hit.at then
        latency = latency + ((now - hit.at) - latency) * 0.2
    end
    misses = 0
    local isAuto = IsAutoAttackSpell(row.spellID)
    if row.creature ~= "" then
        if isAuto then
            BD:NoteConfirmedPetSwing(hit.at)
        end
        if isAuto or not (BD.db and BD.db.includePetDamage) then
            BD:DebugPrint("meter pet", hit.amount, row.creature)
            return
        end
    end
    BD:DebugPrint("meter confirmed", hit.amount, isAuto and "auto" or row.spellID,
        math.floor((now - hit.at) * 1000) .. "ms")
    -- On other enemies (AoE, cleave) your hits show only as before: when a cast of yours was
    -- aimed there or splash is on. Otherwise AoE would put a number on every enemy for every tick.
    if not hit.onTarget and not (BD.db and BD.db.personalSplash) then
        Replay(hit)
        return
    end
    Replay(hit, row.spellID, isAuto)
end

local function Fits(amount, row)
    return math.abs(amount - row.amount) <= 1
        or (row.overkill > 0 and math.abs(amount - (row.amount + row.overkill)) <= 1)
end

-- Pair meter growth with held hits: one hit of the same amount, or two or three hits whose
-- amounts add up to it (several hits of one spell between two meter updates). Oldest first.
local function Match(now)
    local index = 1
    while index <= #growth do
        local row = growth[index]
        local found1, found2, found3
        for a = 1, #held do
            if Fits(held[a].amount, row) then
                found1 = a
                break
            end
        end
        if not found1 and #held <= BD.METER_COMBINE_HELD then
            for a = 1, #held - 1 do
                for b = a + 1, #held do
                    if math.abs(held[a].amount + held[b].amount - row.amount) <= 2 then
                        found1, found2 = a, b
                        break
                    end
                end
                if found1 then
                    break
                end
            end
        end
        if not found1 and #held <= BD.METER_COMBINE_HELD then
            for a = 1, #held - 2 do
                for b = a + 1, #held - 1 do
                    for c = b + 1, #held do
                        if math.abs(held[a].amount + held[b].amount + held[c].amount - row.amount) <= 3 then
                            found1, found2, found3 = a, b, c
                            break
                        end
                    end
                    if found1 then
                        break
                    end
                end
                if found1 then
                    break
                end
            end
        end
        if found1 then
            local hits = { held[found1], found2 and held[found2], found3 and held[found3] }
            for _, slot in ipairs({ found3, found2, found1 }) do
                if slot then
                    table.remove(held, slot)
                end
            end
            table.remove(growth, index)
            for _, hit in ipairs(hits) do
                if hit then
                    Resolve(hit, row, now)
                end
            end
        else
            index = index + 1
        end
    end
end

-- A hit the meter did not confirm in time: while the meter keeps growing it is not yours (a
-- pet's without a meter entry, another player's) and is dropped; when the meter has gone quiet
-- it goes to the guesswork, and many such hits in a row pause the check. Growth no hit explains
-- (damage on plates you do not see, filtered hits) is dropped.
local function Expire(now)
    local hold = HoldTime()
    while held[1] and now - held[1].at >= hold do
        local hit = table.remove(held, 1)
        if grewAt and now - grewAt <= BD.METER_QUIET and #growth == 0 then
            BD:DebugPrint("meter skip, not yours", hit.amount)
        else
            misses = misses + 1
            BD:DebugPrint("meter timeout", hit.amount)
            Replay(hit)
        end
    end
    while growth[1] and now - growth[1].at > hold do
        table.remove(growth, 1)
    end
    if misses >= BD.METER_MAX_MISSES then
        misses = 0
        pausedUntil = now + BD.METER_PAUSE
        BD:DebugPrint("meter check paused, no confirmations")
    end
end

local Tick
local function ScheduleTick()
    if not tickScheduled and (#held > 0 or #growth > 0 or readSoon) then
        tickScheduled = true
        C_Timer.After(BD.METER_POLL, Tick)
    end
end

Tick = function()
    tickScheduled = false
    local now = GetTime()
    if #held > 0 or readSoon then
        ReadMeter(now)
    end
    Match(now)
    Expire(now)
    ScheduleTick()
end

--- Called for a personal hit that passed the filters. True when it is held for the meter, and
--- shown (or dropped) later; false to handle it right away.
function BD:HoldForMeter(unit, plate, amount, isCrit, schoolMask)
    if BD.meterReplay or not MeterAvailable() then
        return false
    end
    local now = GetTime()
    if now < pausedUntil or type(amount) ~= "number" or BD.IsSecret(amount) then
        return false
    end
    -- Hold only while the meter has been counting your damage lately (it may be unavailable or
    -- switched off; then waiting would only delay the numbers).
    if not ReadMeter(now) or not grewAt or now - grewAt > BD.METER_RECENT then
        return false
    end
    if #held >= BD.METER_MAX_HELD then
        Replay(table.remove(held, 1))
    end
    held[#held + 1] = {
        unit = unit, plate = plate, amount = amount, isCrit = isCrit, schoolMask = schoolMask, at = now,
        onTarget = BD.GetNamePlateFrame("target") == plate,
    }
    Match(now)
    ScheduleTick()
    return true
end

--- Whether the damage meter could be read in the last few seconds (for /psct debug).
function BD:IsMeterReadable()
    return readableAt ~= nil and (GetTime() - readableAt) <= 5
end

local meterFrame = CreateFrame("Frame")
for _, event in ipairs({ "DAMAGE_METER_COMBAT_SESSION_UPDATED", "DAMAGE_METER_RESET" }) do
    pcall(meterFrame.RegisterEvent, meterFrame, event)
end
meterFrame:SetScript("OnEvent", function(_, event)
    if event == "DAMAGE_METER_RESET" then
        Rebaseline()
        return
    end
    -- Read on updates, so each read's growth covers only the hits since the last one.
    local now = GetTime()
    if readAt and now - readAt < BD.METER_MIN_READ then
        readSoon = true
        ScheduleTick()
        return
    end
    if ReadMeter(now) then
        Match(now)
        Expire(now)
        ScheduleTick()
    end
end)
