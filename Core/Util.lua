local _, BD = ...

local thresholdCurve = nil

function BD:GetStylePreset()
    local style = self.db.numberStyle or "retail"
    return self.STYLE_PRESETS[style] or self.STYLE_PRESETS.retail
end

function BD:IsClassicNumberStyle()
    return (self.db.numberStyle or "retail") == "classic"
end

function BD:DebugPrint(...)
    if self.db.debug then
        print("|cff66ccffPlateSCT:|r", ...)
    end
end

function BD.CopyDefaults(source, defaults)
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            if type(source[key]) ~= "table" then
                source[key] = {}
            end
            BD.CopyDefaults(source[key], value)
        elseif source[key] == nil then
            source[key] = value
        end
    end
    return source
end

function BD.IsSecret(value)
    -- Classic version: no combat restrictions; stays false when API absent.
    -- See Core/API.lua SECRET VALUES contract.
    if issecretvalue then
        local ok, result = pcall(issecretvalue, value)
        return ok and result
    end
    return false
end

function BD.ValuePresent(value)
    if BD.IsSecret(value) then
        return true
    end
    return value ~= nil
end

function BD.CanAccessValue(value)
    if not BD.ValuePresent(value) then
        return false
    end
    if BD.IsSecret(value) then
        if not canaccessvalue then
            return false
        end
        local ok, accessible = pcall(canaccessvalue, value)
        return ok and accessible and true or false
    end
    return true
end

-- Safe equality for values that may be secret on Modern.
-- Returns false if either side is secret or inaccessible (do not branch on "maybe").
-- Both nil → true. Use instead of raw == / ~= on combat GUIDs, amounts, schools.
function BD.ValuesEqual(a, b)
    if a == nil and b == nil then
        return true
    end
    if a == nil or b == nil then
        return false
    end
    if BD.IsSecret(a) or BD.IsSecret(b) then
        return false
    end
    if not BD.CanAccessValue(a) or not BD.CanAccessValue(b) then
        return false
    end
    local ok, same = pcall(function()
        return a == b
    end)
    return ok and same and true or false
end

function BD.ValuesNotEqual(a, b)
    if a == nil and b == nil then
        return false
    end
    if a == nil or b == nil then
        return true
    end
    if BD.IsSecret(a) or BD.IsSecret(b) then
        return false
    end
    if not BD.CanAccessValue(a) or not BD.CanAccessValue(b) then
        return false
    end
    local ok, different = pcall(function()
        return a ~= b
    end)
    return ok and different and true or false
end

local function SetBlizzardFCTEnabled(enabled)
    local value = enabled and "1" or "0"
    for _, cvar in ipairs(BD.BLIZZ_FCT_CVARS) do
        pcall(function()
            if C_CVar and C_CVar.SetCVar then
                C_CVar.SetCVar(cvar, value)
            else
                SetCVar(cvar, value)
            end
        end)
    end
end

function BD:ApplyBlizzardFCTSetting()
    if self.db.hideBlizzardFCT then
        SetBlizzardFCTEnabled(false)
    end
end

function BD:RestoreBlizzardFCTSetting()
    SetBlizzardFCTEnabled(true)
end

function BD:RebuildThresholdCurve()
    thresholdCurve = nil
    if not C_CurveUtil or not C_CurveUtil.CreateColorCurve then
        return
    end
    if not self.db.minDamage or self.db.minDamage <= 0 then
        return
    end

    local ok, curve = pcall(function()
        local c = C_CurveUtil.CreateColorCurve()
        c:SetType(Enum.LuaCurveType.Step)
        c:AddPoint(0, CreateColor(1, 1, 1, 0))
        c:AddPoint(self.db.minDamage, CreateColor(1, 1, 1, 1))
        return c
    end)

    if ok then
        thresholdCurve = curve
    end
end

function BD:GetThresholdCurve()
    return thresholdCurve
end

function BD.PassesThreshold(amount, minDamage)
    if not minDamage or minDamage <= 0 then
        return true
    end
    if BD.IsSecret(amount) then
        return true
    end
    local ok, passes = pcall(function()
        return amount >= minDamage
    end)
    return ok and passes
end

local THOUSAND_SEPARATOR_CHARS = {
    comma = ",",
    dot = ".",
}

local function BreakUpAmount(amount, sep)
    -- Secret / inaccessible amounts stay raw so FontString can still show them.
    if not BD.CanAccessValue(amount) then
        return amount
    end

    local ok, text = pcall(tostring, amount)
    if not ok or type(text) ~= "string" then
        return amount
    end

    local int = text:match("(%-?%d+)")
    if not int then
        return amount
    end

    local sign = ""
    if int:sub(1, 1) == "-" then
        sign = "-"
        int = int:sub(2)
    end

    local grouped = int:reverse():gsub("(%d%d%d)", "%1" .. sep):reverse()
    if grouped:sub(1, #sep) == sep then
        grouped = grouped:sub(#sep + 1)
    end
    return sign .. grouped
end

function BD.FormatAmount(amount, abbreviate)
    if abbreviate and AbbreviateNumbers then
        local ok, result = pcall(AbbreviateNumbers, amount)
        if ok and result ~= nil then
            return result
        end
    end
    local sep = THOUSAND_SEPARATOR_CHARS[BD.db and BD.db.thousandSeparator]
    if sep then
        return BreakUpAmount(amount, sep)
    end
    return amount
end

function BD.GetSpellIconTexture(spellID)
    if not BD.ValuePresent(spellID) then
        return nil
    end

    local function AcceptTexture(texture)
        if not BD.ValuePresent(texture) then
            return nil
        end
        return texture
    end

    if C_Spell and type(C_Spell.GetSpellTexture) == "function" then
        local ok, texture = pcall(C_Spell.GetSpellTexture, spellID)
        if ok then
            texture = AcceptTexture(texture)
            if texture then
                return texture
            end
        end
    end

    if C_Spell and type(C_Spell.GetSpellInfo) == "function" then
        local ok, texture = pcall(function()
            local info = C_Spell.GetSpellInfo(spellID)
            return info and (info.iconID or info.icon)
        end)
        if ok then
            texture = AcceptTexture(texture)
            if texture then
                return texture
            end
        end
    end

    if type(GetSpellTexture) == "function" then
        local ok, texture = pcall(GetSpellTexture, spellID)
        if ok then
            texture = AcceptTexture(texture)
            if texture then
                return texture
            end
        end
    end

    if type(GetSpellInfo) == "function" then
        local ok, texture = pcall(function()
            local _, _, icon = GetSpellInfo(spellID)
            return icon
        end)
        if ok then
            texture = AcceptTexture(texture)
            if texture then
                return texture
            end
        end
    end

    return nil
end

BD.petIconByGUID = BD.petIconByGUID or {}

function BD.CacheLivePetIcon()
    if not UnitExists("pet") then
        return nil
    end
    local guid = UnitGUID("pet")
    if not guid then
        return nil
    end
    if type(GetPetIcon) == "function" then
        local ok, icon = pcall(GetPetIcon)
        if ok and type(icon) == "string" and icon ~= "" then
            BD.petIconByGUID[guid] = icon
            return icon
        end
    end
    return BD.petIconByGUID[guid]
end

function BD.GetPetIconTexture(sourceGUID)
    if sourceGUID and BD.petIconByGUID[sourceGUID] then
        return BD.petIconByGUID[sourceGUID]
    end
    local live = BD.CacheLivePetIcon()
    if live and (not sourceGUID or sourceGUID == UnitGUID("pet")) then
        return live
    end
    if sourceGUID and BD.petIconByGUID[sourceGUID] then
        return BD.petIconByGUID[sourceGUID]
    end
    return BD.GENERIC_PET_ICON
end

function BD:ResolveOutgoingSpellIcon(spellIcon, spellId)
    if not self.db.showSpellIcon then
        return nil
    end
    if spellIcon and BD.ValuePresent(spellIcon) then
        return spellIcon
    end
    if spellId and BD.ValuePresent(spellId) then
        return BD.GetSpellIconTexture(spellId)
    end
    return nil
end

function BD.GetSchoolColor(schoolMask)
    if not schoolMask then
        return 1.0, 0.93, 0.0
    end
    local color = BD.DAMAGE_SCHOOL_COLORS[schoolMask]
    if color then
        return color[1], color[2], color[3]
    end
    return 1.0, 0.93, 0.0
end

function BD:ShouldUseSchoolColors()
    if self.db.useSchoolColors ~= nil then
        return self.db.useSchoolColors and true or false
    end
    return self:GetStylePreset().useSchoolColors and true or false
end

function BD:ResolveMotionStyle(hitKind)
    if (self.db.numberStyle or "retail") == "classic" then
        return "platesct"
    end
    local key = "animHit"
    if hitKind == "crit" then
        key = "animCrit"
    elseif hitKind == "miss" then
        key = "animMiss"
    end
    local style = self.db[key] or "platesct"
    if style == "fountain" or style == "rainfall" or style == "verticalDown" then
        return style
    end
    if style == "classicSlap" and hitKind == "crit" then
        return "classicSlap"
    end
    return "platesct"
end

function BD.IsExtraMotionPath(motionStyle)
    return motionStyle == "fountain"
        or motionStyle == "rainfall"
        or motionStyle == "verticalDown"
end

function BD.GetIncomingAnchor()
    local plate = BD.GetNamePlateFrame("player")
    if plate then
        return plate, "CENTER", "player"
    end

    -- Some clients expose the personal plate as nameplateN rather than unit "player".
    if C_NamePlate and C_NamePlate.GetNamePlates then
        local ok, plates = pcall(C_NamePlate.GetNamePlates)
        if ok and plates then
            for _, candidate in ipairs(plates) do
                local token = candidate.namePlateUnitToken
                if token and BD.UnitsMatch(token, "player") then
                    return candidate, "CENTER", "player"
                end
            end
        end
    end

    -- No personal nameplate: screen-center on UIParent (not PlayerFrame).
    return UIParent, "CENTER", "player"
end

function BD.GetNamePlateFrame(unit)
    if not unit or not C_NamePlate or not C_NamePlate.GetNamePlateForUnit then
        return nil
    end
    local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
    if ok and plate then
        return plate
    end
    return nil
end

function BD.IsNameplateUnit(unit)
    return type(unit) == "string" and unit:match("^nameplate%d+$") ~= nil
end

function BD.UnitsMatch(unitA, unitB)
    if not unitA or not unitB then
        return false
    end
    if unitA == unitB then
        return true
    end
    local ok, result = pcall(function()
        return UnitIsUnit(unitA, unitB) and true or false
    end)
    return ok and result or false
end

function BD.SafeUnitBoolean(func, ...)
    if type(func) ~= "function" then
        return false
    end
    local ok, value = pcall(func, ...)
    if not ok then
        return false
    end
    local okNormalize, normalized = pcall(function()
        return value and true or false
    end)
    return okNormalize and normalized or false
end

function BD.UnitLooksHostile(unit)
    if BD.SafeUnitBoolean(UnitCanAttack, "player", unit) then
        return true
    end
    if BD.SafeUnitBoolean(UnitIsFriend, "player", unit) then
        return false
    end
    return true
end

function BD:IsNameplateInConfiguredScope(unit)
    if BD.API.IsClassic() then
        return true
    end
    if not self.db.allNameplates then
        if BD.UnitsMatch(unit, "target") then
            return true
        end
        local targetPlate = BD.GetNamePlateFrame("target")
        return targetPlate ~= nil and targetPlate == BD.GetNamePlateFrame(unit)
    end

    local strict = self.GetActiveStrictness and self:GetActiveStrictness()
    if strict and strict.useThreatGate and self.PlayerIsEngagedWith then
        return self:PlayerIsEngagedWith(unit)
    end
    return true
end

function BD:ShouldShowOutgoingHit(unit)
    if not BD.IsNameplateUnit(unit) then
        return false
    end
    if not BD.GetNamePlateFrame(unit) then
        return false
    end
    if not BD.UnitLooksHostile(unit) then
        return false
    end
    if not self:IsNameplateInConfiguredScope(unit) then
        return false
    end
    return true
end

function BD.GetNameplateTokenForUnit(unit)
    if not unit then
        return nil
    end
    if BD.IsNameplateUnit(unit) then
        return unit
    end
    local ok, plates = pcall(C_NamePlate.GetNamePlates)
    if not ok or not plates then
        return nil
    end
    for _, plate in ipairs(plates) do
        local token = plate.namePlateUnitToken
        if token and BD.UnitsMatch(token, unit) then
            return token
        end
    end
    return nil
end
