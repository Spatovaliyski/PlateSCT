local _, BD = ...

local thresholdCurve = nil

function BD:GetStylePreset(styleOverride)
    local style = styleOverride or self.db.numberStyle or "retail"
    if not self.STYLE_PRESETS[style] then
        style = "retail"
    end
    return self.STYLE_PRESETS[style], style
end

-- Colors are saved as "RRGGBB" hex strings: scalars reset cleanly with the other defaults.
function BD.HexToRGB(hex)
    hex = tostring(hex or ""):gsub("^#", "")
    local r, g, b = hex:match("^(%x%x)(%x%x)(%x%x)$")
    if not r then
        return 1, 1, 1
    end
    return tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255
end

function BD.RGBToHex(r, g, b)
    local function channel(value)
        return math.max(0, math.min(255, math.floor((tonumber(value) or 0) * 255 + 0.5)))
    end
    return string.format("%02X%02X%02X", channel(r), channel(g), channel(b))
end

-- Number color for outgoing damage text when school colors are off.
function BD:GetNumberColor(kind, preset)
    if self.db and self.db.useCustomColors then
        local key = kind == "crit" and "critColor" or kind == "miss" and "missColor" or "hitColor"
        return BD.HexToRGB(self.db[key] or self.DEFAULTS[key])
    end
    local color = preset.defaultColor
    return color[1], color[2], color[3]
end

local OUTLINE_FLAGS = { none = "", thin = "OUTLINE", thick = "THICKOUTLINE" }

-- Font flags for a style preset: the player's outline choice, or the style's own outline.
function BD:GetFontFlags(preset)
    local choice = self.db and self.db.fontOutline
    local flags = OUTLINE_FLAGS[choice]
    if flags then
        return flags
    end
    return preset and preset.fontFlags or "OUTLINE"
end

function BD:GetNumberStyleOffsets(styleOverride)
    local _, style = self:GetStylePreset(styleOverride)
    local xKey, yKey = style .. "OffsetX", style .. "OffsetY"
    return self.db[xKey] or self.DEFAULTS[xKey] or 0,
        self.db[yKey] or self.DEFAULTS[yKey] or 0, xKey, yKey
end

function BD:IsClassicNumberStyle()
    return (self.db.numberStyle or "retail") == "classic"
end

-- Impact keeps its label choice separate from Classic/Modern.
function BD:GetCritLabelSetting(styleOverride)
    local style = styleOverride or self.db.numberStyle or "retail"
    local key = style == "impact" and "showImpactCritLabel" or "showCritLabel"
    return self.db[key], key
end

local FALLBACK_FONT = "Fonts\\FRIZQT__.TTF"

function BD.GetDefaultFontPath()
    return STANDARD_TEXT_FONT or FALLBACK_FONT
end

--- Resolve a saved fontFace id to a disk path. Supports built-ins and optional LibSharedMedia.
function BD.ResolveFontPath(fontFace)
    local face = fontFace or (BD.db and BD.db.fontFace) or "game"
    if face == "game" or not face then
        return BD.GetDefaultFontPath()
    end

    if type(face) == "string" and face:sub(1, 4) == "lsm:" then
        local name = face:sub(5)
        local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
        if LSM and name ~= "" then
            local path = LSM:Fetch("font", name)
            if path then
                return path
            end
        end
        return BD.GetDefaultFontPath()
    end

    local fonts = BD.BUILTIN_FONTS
    if fonts then
        for _, entry in ipairs(fonts) do
            if entry.id == face then
                return entry.path or BD.GetDefaultFontPath()
            end
        end
    end

    return BD.GetDefaultFontPath()
end

--- Build dropdown options: built-ins first, then LibSharedMedia fonts when present.
function BD.GetFontFaceOptions()
    local options = {}
    for _, entry in ipairs(BD.BUILTIN_FONTS or {}) do
        options[#options + 1] = {
            id = entry.id,
            labelKey = entry.labelKey,
            recommended = entry.id == "game",
        }
    end

    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then
        local list = LSM:List("font")
        if list then
            table.sort(list)
            for _, name in ipairs(list) do
                options[#options + 1] = {
                    id = "lsm:" .. name,
                    label = name,
                }
            end
        end
    end

    return options
end

function BD.SafeSetFont(fontString, path, size, flags)
    if not fontString then
        return BD.GetDefaultFontPath()
    end
    local usePath = path or BD.GetDefaultFontPath()
    local ok, loaded = pcall(fontString.SetFont, fontString, usePath, size, flags or "")
    if ok and loaded ~= false then
        return usePath
    end
    local fallback = BD.GetDefaultFontPath()
    pcall(fontString.SetFont, fontString, fallback, size, flags or "")
    return fallback
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

function BD.AmountExceeds(amount, threshold)
    if threshold == nil or type(threshold) ~= "number" or threshold < 0 then
        return false
    end
    if not BD.CanAccessValue(amount) then
        return false
    end
    local ok, exceeds = pcall(function()
        return amount > threshold
    end)
    return ok and exceeds
end

local CRIT_SOUND_PATH = "Interface\\AddOns\\PlateSCT\\Media\\Sounds\\Critical.ogg"
local HUGE_CRIT_SOUND_PATH = "Interface\\AddOns\\PlateSCT\\Media\\Sounds\\HugeCritical.ogg"

local function ResolveSoundChannel(channel)
    if type(channel) == "string" and channel ~= "" then
        return channel
    end
    return "Dialog"
end

-- Crit sound tiers: 0 none, 1 critical, 2 huge critical.
function BD:GetCritSoundTier(amount)
    if not self.db then
        return 0
    end
    if self.db.hugeCritSoundEnabled and BD.AmountExceeds(amount, self.db.hugeCritSoundThreshold) then
        return 2
    end
    if self.db.critSoundEnabled and BD.AmountExceeds(amount, self.db.critSoundThreshold) then
        return 1
    end
    return 0
end

function BD:PlayCritSoundTier(tier)
    if tier == 2 then
        pcall(PlaySoundFile, HUGE_CRIT_SOUND_PATH, ResolveSoundChannel(self.db.hugeCritSoundChannel))
    elseif tier == 1 then
        pcall(PlaySoundFile, CRIT_SOUND_PATH, ResolveSoundChannel(self.db.critSoundChannel))
    end
end

-- Returns the tier played so combined crits only replay on a higher tier.
function BD:PlayOutgoingCritSound(amount, isCrit)
    if not isCrit then
        return 0
    end
    local tier = self:GetCritSoundTier(amount)
    self:PlayCritSoundTier(tier)
    return tier
end

function BD:PlayCritSoundPreview(kind)
    local path = (kind == "huge") and HUGE_CRIT_SOUND_PATH or CRIT_SOUND_PATH
    local channel
    if kind == "huge" then
        channel = self.db and self.db.hugeCritSoundChannel
    else
        channel = self.db and self.db.critSoundChannel
    end
    pcall(PlaySoundFile, path, ResolveSoundChannel(channel))
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

-- Spell names never change during a session, so they are cached by ID.
local spellNameCache = {}

local function ReadableSpellID(spellID)
    return type(spellID) == "number" and not BD.IsSecret(spellID) and BD.CanAccessValue(spellID)
end

function BD.GetSpellName(spellID)
    if not ReadableSpellID(spellID) then
        return nil
    end
    local cached = spellNameCache[spellID]
    if cached ~= nil then
        return cached or nil
    end
    local name
    if C_Spell and type(C_Spell.GetSpellName) == "function" then
        local ok, result = pcall(C_Spell.GetSpellName, spellID)
        name = ok and result or nil
    end
    if not name and GetSpellInfo then
        local ok, result = pcall(GetSpellInfo, spellID)
        name = ok and result or nil
    end
    if type(name) ~= "string" or BD.IsSecret(name) or name == "" then
        name = nil
    end
    spellNameCache[spellID] = name or false
    return name
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

-- Ignored spells: a comma-, semicolon- or line-separated list of spell IDs and names
-- (case-insensitive). Parsed again whenever the saved text changes.
local ignoredSource, ignoredIDs, ignoredNames, ignoredAny

local function RebuildIgnoredSpells(source)
    ignoredSource, ignoredIDs, ignoredNames, ignoredAny = source, {}, {}, false
    for entry in tostring(source or ""):gmatch("[^,;\n]+") do
        entry = entry:gsub("^%s+", ""):gsub("%s+$", "")
        local id = tonumber(entry)
        if id then
            ignoredIDs[id] = true
            ignoredAny = true
        elseif entry ~= "" then
            ignoredNames[entry:lower()] = true
            ignoredAny = true
        end
    end
end

function BD:IsSpellIgnored(spellID)
    local source = self.db and self.db.ignoredSpells or ""
    if source ~= ignoredSource then
        RebuildIgnoredSpells(source)
    end
    if not ignoredAny or not ReadableSpellID(spellID) then
        return false
    end
    if ignoredIDs[spellID] then
        return true
    end
    local name = BD.GetSpellName(spellID)
    return name ~= nil and ignoredNames[name:lower()] == true
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

-- Spell label shown with each number: "icon", "name", or "both"; nil when labels are off.
function BD:GetSpellLabelMode()
    if not self.db.showSpellIcon then
        return nil
    end
    return self.db.spellLabel or "icon"
end

-- Cut a name to maxChars characters. UTF-8 aware: multibyte names are never split mid-character.
function BD.ShortenName(name, maxChars)
    if not name or not maxChars or maxChars <= 0 then
        return name
    end
    local count = 0
    for start in name:gmatch("()[%z\1-\127\194-\244][\128-\191]*") do
        count = count + 1
        if count > maxChars then
            return name:sub(1, start - 1) .. "..."
        end
    end
    return name
end

function BD:ResolveOutgoingSpellName(spellId)
    local mode = self:GetSpellLabelMode()
    if mode ~= "name" and mode ~= "both" then
        return nil
    end
    return BD.ShortenName(BD.GetSpellName(spellId), self.db.spellNameMaxLength)
end

function BD:ResolveOutgoingSpellIcon(spellIcon, spellId)
    if not self.db.showSpellIcon or self.db.spellLabel == "name" then
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

local function CountSchoolBits(mask)
    local count = 0
    local remaining = mask
    while remaining > 0 do
        if bit.band(remaining, 1) ~= 0 then
            count = count + 1
        end
        remaining = bit.rshift(remaining, 1)
    end
    return count
end

function BD:GetClassSchoolMask()
    local _, classFile = UnitClass("player")
    if classFile and BD.CLASS_SCHOOL_MASKS[classFile] then
        return BD.CLASS_SCHOOL_MASKS[classFile]
    end
    return BD.SCHOOL_MASK_ALL
end

function BD:GetClassSchoolNames()
    local L = BD.L
    local classMask = self:GetClassSchoolMask()
    local names = {}
    local schools = BD.DAMAGE_SCHOOLS
    for index = 1, #schools do
        local school = schools[index]
        if bit.band(classMask, school.bit) ~= 0 then
            names[#names + 1] = L[school.labelKey]
        end
    end
    return names
end

function BD:GetRecommendedSchoolFilterLabel()
    local L = BD.L
    local names = self:GetClassSchoolNames()
    return string.format(L["Use Recommended (%s)"], table.concat(names, ", "))
end

function BD:GetSchoolFilterMask()
    local mask = 0
    local schools = BD.DAMAGE_SCHOOLS
    if not schools or not self.db then
        return mask
    end
    for index = 1, #schools do
        local school = schools[index]
        if self.db[school.dbKey] then
            mask = bit.bor(mask, school.bit)
        end
    end
    return mask
end

function BD:SchoolFilterMatchesClass()
    return self:GetSchoolFilterMask() == self:GetClassSchoolMask()
end

function BD:ApplySchoolFilterRecommended()
    if not self.db then
        return
    end
    local classMask = self:GetClassSchoolMask()
    local schools = BD.DAMAGE_SCHOOLS
    for index = 1, #schools do
        local school = schools[index]
        self.db[school.dbKey] = bit.band(classMask, school.bit) ~= 0
    end
    self.db.schoolFilterRecommended = true
end

--- Modern school filter. Fail-open when disabled, missing, or secret/inaccessible.
--- 1–2 school bits: overlap with allowed. 3+ bits (Chaos): Fire or Shadow in allowed.
function BD:PassesSchoolFilter(schoolMask)
    if not self.db or not self.db.schoolFilterEnabled then
        return true
    end
    if not BD.ValuePresent(schoolMask) then
        return true
    end
    if BD.IsSecret(schoolMask) and not BD.CanAccessValue(schoolMask) then
        return true
    end
    if not BD.CanAccessValue(schoolMask) then
        return true
    end

    local ok, hitMask = pcall(function()
        return bit.band(schoolMask, BD.SCHOOL_MASK_ALL)
    end)
    if not ok or type(hitMask) ~= "number" then
        return true
    end
    if hitMask == 0 then
        return true
    end

    local allowed = self:GetSchoolFilterMask()
    local bitCount = CountSchoolBits(hitMask)
    if bitCount >= 3 then
        local chaosOk, hasChaosSchool = pcall(function()
            return bit.band(allowed, BD.SCHOOL_MASK_FIRE) ~= 0
                or bit.band(allowed, BD.SCHOOL_MASK_SHADOW) ~= 0
        end)
        return chaosOk and hasChaosSchool and true or false
    end

    local overlapOk, overlaps = pcall(function()
        return bit.band(hitMask, allowed) ~= 0
    end)
    return overlapOk and overlaps and true or false
end

function BD:ShouldUseSchoolColors()
    if self.db.useSchoolColors ~= nil then
        return self.db.useSchoolColors and true or false
    end
    return self:GetStylePreset().useSchoolColors and true or false
end

-- isAutoAttack: a normal auto-attack hit, which may use its own motion (animAuto).
function BD:ResolveMotionStyle(hitKind, styleOverride, isAutoAttack)
    local numberStyle = styleOverride or self.db.numberStyle or "retail"
    if numberStyle == "impact" then
        return "impact"
    end
    if numberStyle == "classic" then
        return "platesct"
    end
    local key = "animHit"
    if hitKind == "crit" then
        key = "animCrit"
    elseif hitKind == "miss" then
        key = "animMiss"
    elseif isAutoAttack and self.db.animAuto and self.db.animAuto ~= "same" then
        key = "animAuto"
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

function BD:IsNameplateInConfiguredScope(unit, allowFriendly)
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

    -- Friendly heals: no threat gate (they are never "engaged").
    if allowFriendly and not BD.UnitLooksHostile(unit) then
        return true
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

function BD:ShouldShowOutgoingHeal(unit)
    if not BD.IsNameplateUnit(unit) then
        return false
    end
    if not BD.GetNamePlateFrame(unit) then
        return false
    end
    if BD.UnitsMatch(unit, "player") then
        return false
    end
    if not self:IsNameplateInConfiguredScope(unit, true) then
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
