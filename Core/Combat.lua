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
    local hitKind = isCrit and "crit" or "hit"
    BD:DebugPrint("personal", token, display, hitKind, usedAuto and "auto" or spellID)
    BD:ShowOnNameplate(token, display, r, g, b, amount, isCrit, false, spellIcon, hitKind)
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
