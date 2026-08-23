local _, BD = ...

local function ShowPersonalDamage(unit, amount, isCrit, schoolMask)
    local token = BD.GetNameplateTokenForUnit(unit) or unit
    if not token or not BD.GetNamePlateFrame(token) then
        return false
    end
    if not BD.PassesThreshold(amount, BD.db.minDamage) then
        return false
    end

    local spellID, usedAuto = BD:MatchOutgoingHit(token, schoolMask)
    if not spellID then
        BD:DebugPrint("personal skip, no outgoing match")
        return false
    end

    local spellIcon = BD.db.showSpellIcon and BD.GetSpellIconTexture(spellID) or nil
    local preset = BD:GetStylePreset()
    local display = BD.FormatAmount(amount, BD.db.abbreviate)
    local r, g, b = BD.GetSchoolColor(schoolMask)
    if not BD:ShouldUseSchoolColors() then
        r, g, b = preset.defaultColor[1], preset.defaultColor[2], preset.defaultColor[3]
    end
    BD:DebugPrint("personal", token, display, isCrit and "crit" or "hit", usedAuto and "auto" or spellID)
    BD:ShowOnNameplate(token, display, r, g, b, amount, isCrit, false, spellIcon)
    return true
end

function BD:HandleUnitCombat(unit, action, flagText, amount, schoolMask)
    if not self.db.enabled then
        return
    end
    if not BD.SafeUnitBoolean(InCombatLockdown) then
        return
    end

    local isCrit = (flagText == "CRITICAL")
    if self.db.onlyMyDamage then
        if action ~= "WOUND" then
            return
        end
        if not BD.IsNameplateUnit(unit) and unit ~= "target" then
            return
        end
        if not BD.GetNamePlateFrame(unit) and not BD.GetNamePlateFrame("target") then
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
        self:ShowOnNameplate(unit, display, r, g, b, amount, isCrit, false)
        return
    end

    if self.MISS_ACTIONS[action] then
        if not self:ShouldShowOutgoingHit(unit) then
            return
        end
        self:ShowOnNameplate(unit, action, 1, 0.85, 0.2, nil, false, false)
    end
end
