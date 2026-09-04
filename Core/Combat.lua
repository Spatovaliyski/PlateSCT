local _, BD = ...

-- UNIT_COMBAT repeats the same wound on every alias (nameplateN, target, …).
-- UnitIsUnit is often unusable on Modern, so aliases cannot be merged by token.
-- Compare nameplate frames instead, and ignore non-nameplate tokens entirely.
local lastPersonalPlate
local lastPersonalTime = 0
local lastPersonalAmount
local lastPersonalCrit
local PERSONAL_DUP_WINDOW = 0.05

local function AmountsEqual(a, b)
    return BD.ValuesEqual(a, b)
end

local function IsDuplicatePersonalHit(plate, amount, isCrit)
    if not plate or plate ~= lastPersonalPlate then
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

local function RememberPersonalHit(plate, amount, isCrit)
    lastPersonalPlate = plate
    lastPersonalTime = GetTime()
    lastPersonalAmount = amount
    lastPersonalCrit = isCrit
end

local function ShowPersonalDamage(unit, amount, isCrit, schoolMask)
    if not BD.IsNameplateUnit(unit) then
        return false
    end
    local plate = BD.GetNamePlateFrame(unit)
    if not plate then
        return false
    end
    if IsDuplicatePersonalHit(plate, amount, isCrit) then
        BD:DebugPrint("personal skip, duplicate")
        return false
    end
    if not BD.PassesThreshold(amount, BD.db.minDamage) then
        return false
    end

    local spellID, usedAuto = BD:MatchOutgoingHit(unit, schoolMask)
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
    BD:DebugPrint("personal", unit, display, hitKind, usedAuto and "auto" or spellID)
    RememberPersonalHit(plate, amount, isCrit)
    -- Modern-only: spellId comes from attribution, not UNIT_COMBAT.
    BD:ShowOnNameplate(unit, display, r, g, b, amount, isCrit, false, nil, hitKind, spellID)
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

function BD:HandleUnitCombat(unit, action, flagText, amount, schoolMask)
    BD.API.AssertModern("Combat.HandleUnitCombat")
    if not self.db.enabled then
        return
    end
    if not BD.SafeUnitBoolean(InCombatLockdown) then
        return
    end

    -- Incoming on the player is independent of outgoing filters.
    if unit == "player" then
        HandleIncoming(self, action, flagText, amount)
        return
    end

    local isCrit = (flagText == "CRITICAL")
    if self.db.onlyMyDamage then
        if action ~= "WOUND" then
            return
        end
        -- Nameplate token only. Do not accept "target": GetNamePlateForUnit
        -- maps it to the same frame, and UnitIsUnit cannot prove the alias.
        if not BD.IsNameplateUnit(unit) then
            return
        end
        if not BD.GetNamePlateFrame(unit) then
            return
        end
        ShowPersonalDamage(unit, amount, isCrit, schoolMask)
        return
    end

    if not BD.IsNameplateUnit(unit) then
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
        local display = BD.FormatAmount(amount, self.db.abbreviate)
        local r, g, b = BD.GetSchoolColor(schoolMask)
        local hitKind = isCrit and "crit" or "hit"
        self:ShowOnNameplate(unit, display, r, g, b, amount, isCrit, false, nil, hitKind)
        return
    end

    if self.MISS_ACTIONS[action] then
        if not self:ShouldShowOutgoingHit(unit) then
            return
        end
        self:ShowOnNameplate(unit, action, 1, 0.85, 0.2, nil, false, false, nil, "miss")
    end
end
