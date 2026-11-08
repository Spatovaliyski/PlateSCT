local _, BD = ...

-- UNIT_COMBAT repeats the same wound on every alias (nameplateN, target, …).
-- UnitIsUnit is often unusable on Modern, so aliases cannot be merged by token.
-- BD.OutgoingUnitKey accepts nameplate tokens (keyed by their plate frame) and, in screen
-- mode, "target" only while it has no plate; every other token is ignored.
local lastPersonalKey
local lastPersonalTime = 0
local lastPersonalAmount
local lastPersonalCrit
local lastPersonalSpell
local lastPersonalPaired = false
local PERSONAL_DUP_WINDOW = 0.05

local function AmountsEqual(a, b)
    return BD.ValuesEqual(a, b)
end

local function IsDuplicatePersonalHit(key, amount, isCrit)
    if not key or key ~= lastPersonalKey then
        return false
    end
    if (GetTime() - lastPersonalTime) > PERSONAL_DUP_WINDOW then
        return false
    end
    if lastPersonalCrit ~= isCrit then
        return false
    end
    if BD.IsSecret(amount) or BD.IsSecret(lastPersonalAmount) then
        return true
    end
    return AmountsEqual(amount, lastPersonalAmount)
end

-- Forever reports the swing a next-melee ability replaces (Raptor Strike, Heroic Strike, Maul,
-- Cleave) as a hit of 0 beside the real hit, in either order. Both amounts are secret, so they
-- cannot be told apart: a hit may bring one companion that shares its spell match, and
-- Render.Paint hides the 0.
local function IsNextMeleeCompanion(key, amount)
    if not key or key ~= lastPersonalKey or lastPersonalPaired or not lastPersonalSpell then
        return false
    end
    if not BD.IsSecret(amount) or not BD.IsSecret(lastPersonalAmount) or not BD.API.IsForever() then
        return false
    end
    return (GetTime() - lastPersonalTime) <= PERSONAL_DUP_WINDOW
end

local function RememberPersonalHit(key, amount, isCrit, spellID, paired)
    lastPersonalKey = key
    lastPersonalTime = GetTime()
    lastPersonalAmount = amount
    lastPersonalCrit = isCrit
    lastPersonalSpell = spellID
    lastPersonalPaired = paired and true or false
end

local function ShowPersonalDamage(unit, key, amount, isCrit, schoolMask)
    if key == lastPersonalKey then
        BD:DebugPrint("personal gap", GetTime() - lastPersonalTime)
    end
    local companion = IsNextMeleeCompanion(key, amount)
    if not companion and IsDuplicatePersonalHit(key, amount, isCrit) then
        BD:DebugPrint("personal skip, duplicate")
        return false
    end
    if not BD.PassesThreshold(amount, BD.db.minDamage) then
        return false
    end
    if not BD:PassesSchoolFilter(schoolMask) then
        BD:DebugPrint("personal skip, school filter")
        return false
    end

    local spellID, usedAuto
    if companion then
        -- Must not spend a cast's hit or the auto-attack gap, or whichever arrives second is lost.
        spellID = lastPersonalSpell
    else
        spellID, usedAuto = BD:MatchOutgoingHit(unit, schoolMask)
    end
    if not spellID then
        BD:DebugPrint("personal skip, no outgoing match")
        return false
    end

    local preset = BD:GetStylePreset()
    local display = BD.FormatAmount(amount, BD.db.abbreviate)
    local r, g, b = BD.GetSchoolColor(schoolMask)
    if not BD:ShouldUseSchoolColors() then
        r, g, b = preset.defaultColor[1], preset.defaultColor[2], preset.defaultColor[3]
    end
    local hitKind = isCrit and "crit" or "hit"
    BD:DebugPrint("personal", unit, display, hitKind, usedAuto and "auto" or spellID, companion and "companion" or "")
    RememberPersonalHit(key, amount, isCrit, spellID, companion)
    -- Modern-only: spellId comes from attribution, not UNIT_COMBAT.
    BD:ShowOutgoing(unit, key, display, r, g, b, amount, isCrit, false, nil, hitKind, spellID)
    return true
end

local function ShowPersonalHeal(unit, key, amount, isCrit, schoolMask)
    if BD.UnitsMatch(unit, "player") then
        return false
    end
    if IsDuplicatePersonalHit(key, amount, isCrit) then
        BD:DebugPrint("personal heal skip, duplicate")
        return false
    end
    if not BD.PassesThreshold(amount, BD.db.minDamage) then
        return false
    end
    if not BD:PassesSchoolFilter(schoolMask) then
        BD:DebugPrint("personal heal skip, school filter")
        return false
    end

    local spellID, usedAuto = BD:MatchOutgoingHit(unit, schoolMask, true)
    -- Heals must match a cast; auto-attack fallback is damage-only.
    if not spellID or usedAuto then
        BD:DebugPrint("personal heal skip, no outgoing match")
        return false
    end

    local display = BD.FormatAmount(amount, BD.db.abbreviate)
    local r, g, b = BD.GetSchoolColor(schoolMask)
    local hitKind = isCrit and "crit" or "hit"
    BD:DebugPrint("personal heal", unit, display, hitKind, spellID)
    RememberPersonalHit(key, amount, isCrit)
    BD:ShowOutgoing(unit, key, display, r, g, b, amount, isCrit, true, nil, hitKind, spellID)
    return true
end

local function HandleIncoming(self, action, flagText, amount)
    if not self.db.showIncoming then
        return
    end

    local isCrit = (flagText == "CRITICAL")
    local color = BD.INCOMING_COLOR

    if action == "WOUND" then
        local display = BD.FormatAmount(amount, self.db.abbreviate)
        local hitKind = isCrit and "crit" or "hit"
        self:DebugPrint("incoming", display, hitKind)
        -- Incoming ignores minDamage threshold (no amountForThreshold).
        self:ShowIncoming(display, color[1], color[2], color[3], nil, isCrit, hitKind)
        return
    end

    if self.MISS_ACTIONS[action] then
        self:DebugPrint("incoming miss", action)
        self:ShowIncoming(action, color[1], color[2], color[3], nil, false, "miss")
    end
end

-- The hit that starts a fight (often a melee opener) can reach UNIT_COMBAT just before
-- PLAYER_REGEN_DISABLED, while InCombatLockdown() is still false. Hold hits seen out of
-- combat in a small ring and replay the recent ones when combat starts; hits from fights
-- the player never joins are overwritten or expire unseen.
local HOLD_WINDOW = 0.3
local HOLD_SIZE = 16
local held, heldNext = {}, 1
for index = 1, HOLD_SIZE do
    held[index] = {}
end

local function HoldPreCombatHit(unit, action, flagText, amount, schoolMask)
    local entry = held[heldNext]
    entry.time, entry.unit, entry.action = GetTime(), unit, action
    entry.flagText, entry.amount, entry.schoolMask = flagText, amount, schoolMask
    heldNext = heldNext % HOLD_SIZE + 1
end

local ProcessUnitCombat

function BD:HandleUnitCombat(unit, action, flagText, amount, schoolMask)
    BD.API.AssertModern("Combat.HandleUnitCombat")
    if not self.db.enabled then
        return
    end
    if not BD.SafeUnitBoolean(InCombatLockdown) then
        HoldPreCombatHit(unit, action, flagText, amount, schoolMask)
        return
    end
    ProcessUnitCombat(self, unit, action, flagText, amount, schoolMask)
end

-- PLAYER_REGEN_DISABLED. InCombatLockdown() is still false while this event runs, so the
-- held hits skip the lockdown check. Oldest first, so dedupe and attribution see real order.
function BD:ReplayPreCombatHits()
    BD.API.AssertModern("Combat.ReplayPreCombatHits")
    local now = GetTime()
    for offset = 0, HOLD_SIZE - 1 do
        local entry = held[(heldNext - 1 + offset) % HOLD_SIZE + 1]
        local time = entry.time
        local unit, action, flagText, amount, schoolMask =
            entry.unit, entry.action, entry.flagText, entry.amount, entry.schoolMask
        entry.time, entry.unit, entry.action, entry.flagText, entry.amount, entry.schoolMask =
            nil, nil, nil, nil, nil, nil
        if time and now - time <= HOLD_WINDOW and self.db.enabled then
            self:DebugPrint("replay pre-combat", unit, action)
            ProcessUnitCombat(self, unit, action, flagText, amount, schoolMask)
        end
    end
end

ProcessUnitCombat = function(self, unit, action, flagText, amount, schoolMask)
    -- Incoming on the player is independent of outgoing filters.
    if unit == "player" then
        HandleIncoming(self, action, flagText, amount)
        return
    end

    local isCrit = (flagText == "CRITICAL")
    -- A plate, or "target" without one in screen mode. Never both for one unit:
    -- GetNamePlateForUnit maps "target" to the same frame, and UnitIsUnit cannot prove the alias.
    local key = BD.OutgoingUnitKey(unit)
    if not key then
        return
    end
    if self.db.onlyMyDamage then
        if action == "HEAL" then
            if not self.db.showHealing then
                return
            end
            ShowPersonalHeal(unit, key, amount, isCrit, schoolMask)
            return
        end
        if action ~= "WOUND" then
            return
        end
        ShowPersonalDamage(unit, key, amount, isCrit, schoolMask)
        return
    end

    self:DebugPrint("UNIT_COMBAT", unit, action, flagText, amount, schoolMask)

    if action == "WOUND" then
        if not self:ShouldShowOutgoingHit(unit) then
            return
        end
        if not BD.PassesThreshold(amount, self.db.minDamage) then
            return
        end
        if not self:PassesSchoolFilter(schoolMask) then
            return
        end
        local display = BD.FormatAmount(amount, self.db.abbreviate)
        local r, g, b = BD.GetSchoolColor(schoolMask)
        local hitKind = isCrit and "crit" or "hit"
        self:ShowOutgoing(unit, key, display, r, g, b, amount, isCrit, false, nil, hitKind)
        return
    end

    if action == "HEAL" then
        if not self.db.showHealing then
            return
        end
        if not self:ShouldShowOutgoingHeal(unit) then
            return
        end
        if not BD.PassesThreshold(amount, self.db.minDamage) then
            return
        end
        if not self:PassesSchoolFilter(schoolMask) then
            return
        end
        local display = BD.FormatAmount(amount, self.db.abbreviate)
        local r, g, b = BD.GetSchoolColor(schoolMask)
        local hitKind = isCrit and "crit" or "hit"
        self:ShowOutgoing(unit, key, display, r, g, b, amount, isCrit, true, nil, hitKind)
        return
    end

    if self.MISS_ACTIONS[action] then
        if not self:ShouldShowOutgoingHit(unit) then
            return
        end
        self:ShowOutgoing(unit, key, action, 1, 0.85, 0.2, nil, false, false, nil, "miss")
    end
end
