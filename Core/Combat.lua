local _, BD = ...

local lastPlayerSpellTime = 0
local lastPlayerSpellID = nil
local lastPetSpellTime = 0
local lastPetSpellID = nil
local lastAutoAttackFallbackTime = 0

function BD:NoteOutgoingSpell(unit, spellID)
    local now = GetTime()
    if unit == "player" then
        lastPlayerSpellTime = now
        lastPlayerSpellID = spellID
    elseif unit == "pet" then
        lastPetSpellTime = now
        lastPetSpellID = spellID
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

local function CanUseAutoAttackFallback(now)
    now = now or GetTime()
    if lastAutoAttackFallbackTime > 0 and (now - lastAutoAttackFallbackTime) < BD.AUTO_ATTACK_FALLBACK_GAP then
        return false
    end
    return true
end

local function HasStrictOutgoingSignal(now, schoolMask)
    now = now or GetTime()
    if BD.ValuePresent(lastPlayerSpellID) and (now - lastPlayerSpellTime) <= BD.OUTGOING_ATTRIBUTION_WINDOW then
        return true
    end
    if BD.db.includePetDamage and BD.ValuePresent(lastPetSpellID) and (now - lastPetSpellTime) <= BD.OUTGOING_ATTRIBUTION_WINDOW then
        return true
    end
    if not IsLikelySpellSchool(schoolMask) and CanUseAutoAttackFallback(now) then
        return true, true
    end
    return false
end

local function ResolveOutgoingSpellID(usedAuto)
    if usedAuto then
        return BD.AUTO_ATTACK_SPELL_ID
    end
    local now = GetTime()
    if BD.ValuePresent(lastPlayerSpellID) and (now - lastPlayerSpellTime) <= BD.OUTGOING_ATTRIBUTION_WINDOW then
        return lastPlayerSpellID
    end
    if BD.db.includePetDamage and BD.ValuePresent(lastPetSpellID) and (now - lastPetSpellTime) <= BD.OUTGOING_ATTRIBUTION_WINDOW then
        return lastPetSpellID
    end
    return nil
end

local function ShowPersonalTargetDamage(unit, amount, isCrit, schoolMask)
    if not BD.UnitsMatch(unit, "target") and unit ~= "target" then
        return false
    end
    local token = BD.GetNameplateTokenForUnit(unit) or BD.GetNameplateTokenForUnit("target") or unit
    if not token or not BD.GetNamePlateFrame(token) then
        return false
    end
    if not BD.PassesThreshold(amount, BD.db.minDamage) then
        return false
    end
    local now = GetTime()
    local hasSignal, usedAuto = HasStrictOutgoingSignal(now, schoolMask)
    if not hasSignal then
        BD:DebugPrint("personal skip, no outgoing signal")
        return false
    end
    if usedAuto then
        lastAutoAttackFallbackTime = now
    end
    local spellIcon = BD.db.showSpellIcon and BD.GetSpellIconTexture(ResolveOutgoingSpellID(usedAuto)) or nil
    local preset = BD:GetStylePreset()
    local display = BD.FormatAmount(amount, BD.db.abbreviate)
    local r, g, b = BD.GetSchoolColor(schoolMask)
    if not BD:ShouldUseSchoolColors() then
        r, g, b = preset.defaultColor[1], preset.defaultColor[2], preset.defaultColor[3]
    end
    BD:DebugPrint("personal", token, display, isCrit and "crit" or "hit")
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
        local onCurrentTarget = unit == "target" or BD.UnitsMatch(unit, "target")
        if not onCurrentTarget then
            return
        end
        if not BD.IsNameplateUnit(unit) then
            return
        end
        ShowPersonalTargetDamage(unit, amount, isCrit, schoolMask)
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
