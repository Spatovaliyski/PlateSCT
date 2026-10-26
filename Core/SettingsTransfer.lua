local ADDON_NAME, BD = ...

-- Export format 2: PSCT2 + Base62 compact records + eight checksum hex digits.
-- Retain the original !PlateSCT:1! reader for strings already shared by users.
-- These are data formats, never Lua programs. layoutRevision is not transferred.
local PREFIX = "!PlateSCT:1!"
local COMPACT_PREFIX = "PSCT2"
local MAX_BYTES, MAX_RECORDS, MAX_STRING = 32768, 256, 1024
BD.SETTINGS_STRING_MAX_BYTES = MAX_BYTES

local function Boolean(id, scope) return { id = id, kind = "boolean", scope = scope or "shared" } end
local function Number(id, minimum, maximum)
    return { id = id, kind = "number", scope = "shared", minimum = minimum, maximum = maximum }
end
local function Choice(id, options, scope)
    local values = {}
    for _, option in ipairs(options) do values[type(option) == "table" and option.id or option] = true end
    return { id = id, kind = "string", scope = scope or "shared", values = values }
end
local strictness = { "loose", "balanced", "strict", "veryStrict" }
-- Wire IDs are permanent: never renumber/reuse them or change their ownership.
-- Add new preferences with unused IDs; unknown IDs are safely skipped by readers.
local schema = {
    enabled = Boolean(1), minDamage = Number(2, 0), abbreviate = Boolean(3),
    combineHits = Boolean(65), combineMode = Choice(66, BD.COMBINE_MODES), combinePulse = Boolean(67),
    combineShowCount = Boolean(68), combineWindow = Number(69, 0.1, 1),
    thousandSeparator = Choice(4, BD.THOUSAND_SEPARATORS),
    showSpellIcon = Boolean(5), iconPosition = Choice(6, BD.ICON_POSITIONS),
    fontSize = Number(7, 10, 48), duration = Number(8, 0.5, 4),
    floatDistance = Number(9, 10, 120), scrollSpeed = Number(10, 0.5, 3),
    fontFace = Choice(11, BD.BUILTIN_FONTS), hideBlizzardFCT = Boolean(12),
    onlyMyDamage = Boolean(13, "modern"), allNameplates = Boolean(14, "modern"),
    includePetDamage = Boolean(15), showHealing = Boolean(16), showIncoming = Boolean(17),
    incomingOffsetX = Number(18, -200, 200), incomingOffsetY = Number(19, -200, 200),
    debug = Boolean(20), numberStyle = Choice(21, { "retail", "classic", "impact" }),
    retailOffsetX = Number(22, -200, 200), retailOffsetY = Number(23, -200, 200),
    classicOffsetX = Number(24, -200, 200), classicOffsetY = Number(25, -200, 200),
    impactOffsetX = Number(26, -200, 200), impactOffsetY = Number(27, -200, 200),
    impactPosition = Choice(28, { "side", "top" }), useSchoolColors = Boolean(29),
    animHit = Choice(30, BD.ANIM_STYLES), animCrit = Choice(31, BD.ANIM_STYLES_CRIT),
    animMiss = Choice(32, BD.ANIM_STYLES), showCritLabel = Boolean(33), showImpactCritLabel = Boolean(34),
    showOptionsPreview = Boolean(35), settingsAnimations = Boolean(36),
    showMinimapButton = Boolean(37), minimapAngle = Number(38), locale = Choice(39, BD.LOCALE_OPTIONS),
    attributionAuto = Boolean(40, "modern"), attributionManual = Choice(41, strictness, "modern"),
    attributionOpenWorld = Choice(42, strictness, "modern"), attributionDungeon = Choice(43, strictness, "modern"),
    attributionRaid = Choice(44, strictness, "modern"), attributionBattleground = Choice(45, strictness, "modern"),
    attributionArena = Choice(46, strictness, "modern"),
    critSoundEnabled = Boolean(47), critSoundThreshold = Number(48, 0), critSoundChannel = Choice(49, BD.SOUND_CHANNELS),
    hugeCritSoundEnabled = Boolean(50), hugeCritSoundThreshold = Number(51, 0), hugeCritSoundChannel = Choice(52, BD.SOUND_CHANNELS),
    schoolFilterEnabled = Boolean(53, "modern"), schoolFilterRecommended = Boolean(54, "modern"),
    schoolFilterPhysical = Boolean(55, "modern"), schoolFilterHoly = Boolean(56, "modern"),
    schoolFilterFire = Boolean(57, "modern"), schoolFilterNature = Boolean(58, "modern"),
    schoolFilterFrost = Boolean(59, "modern"), schoolFilterShadow = Boolean(60, "modern"),
    schoolFilterArcane = Boolean(61, "modern"),
    incomingFontFace = Choice(62, BD.BUILTIN_FONTS), incomingFontSize = Number(63, 10, 48),
    onlyCriticalDamage = Boolean(64),
}

-- Settings-window choices stay on this character. IDs stay reserved so older strings skip them.
local localPreferences = {
    locale = true,
    settingsAnimations = true,
    showOptionsPreview = true,
}

local function Failure(message, key)
    return nil, key and string.format(BD.L[message], key) or BD.L[message]
end

local fieldsById = {}
local function CheckSchema()
    for key, value in pairs(BD.DEFAULTS) do
        if key ~= "layoutRevision" and (not schema[key] or schema[key].kind ~= type(value)) then return false end
    end
    fieldsById = {}
    for key, rule in pairs(schema) do
        if BD.DEFAULTS[key] == nil or type(rule.id) ~= "number" or rule.id < 1 or rule.id > 255
            or rule.id % 1 ~= 0 or fieldsById[rule.id] then return false end
        fieldsById[rule.id] = key
    end
    return true
end

local function Flavor()
    if BD.API.IsModern() then return "modern" end
    if BD.API.IsClassic() then return "classic" end
end

local function Finite(value) return value == value and value > -math.huge and value < math.huge end
local function ValidValue(key, value)
    local rule = schema[key]
    if type(value) ~= rule.kind then return false end
    if rule.kind == "number" then
        return Finite(value) and (not rule.minimum or value >= rule.minimum)
            and (not rule.maximum or value <= rule.maximum)
    elseif rule.kind == "string" then
        if #value > MAX_STRING or value:find("[%z\1-\31\127]") then return false end
        if (key == "fontFace" or key == "incomingFontFace") and value:sub(1, 4) == "lsm:"
            and #value > 4 then return true end
        return rule.values[value] == true
    end
    return true
end

local function Unescape(value)
    local literals = value:gsub("%%[0-9a-fA-F][0-9a-fA-F]", "")
    if literals:find("[^A-Za-z0-9_.~%-]") then return nil end
    local decoded = value:gsub("%%([0-9a-fA-F][0-9a-fA-F])", function(hex) return string.char(tonumber(hex, 16)) end)
    if #decoded > MAX_STRING or decoded:find("[%z\1-\31\127]") then return nil end
    return decoded
end

local function Checksum(text)
    local a, b = 1, 0
    for index = 1, #text do
        a = (a + text:byte(index)) % 65521
        b = (b + a) % 65521
    end
    return string.format("%08x", b * 65536 + a)
end

local function Decode(value)
    local kind, body = value:match("^([bns]):(.*)$")
    if kind == "b" then
        if body == "1" then return true end
        if body == "0" then return false end
    elseif kind == "n" then
        if body:match("^%-?%d+%.?%d*$") or body:match("^%-?%d+%.?%d*[eE][%+%-]?%d+$") then
            local number = tonumber(body)
            if number and Finite(number) then return number end
        end
    elseif kind == "s" then
        return Unescape(body)
    end
end

local function ParseV1(text)
    local version = text:match("^!PlateSCT:(%d+)!")
    if not version then return Failure("Invalid settings string.") end
    if version ~= "1" then return Failure("Unsupported settings format. Update PlateSCT.") end
    local payload, checksum = text:match("^(.*)!([0-9a-fA-F]+)$")
    if not payload or #checksum ~= 8 or Checksum(payload) ~= checksum:lower() then
        return Failure("Settings string is incomplete or damaged.")
    end
    local body = payload:sub(#PREFIX + 1)
    local records, count = {}, 0
    -- Appending a delimiter deliberately exposes empty/trailing records as errors.
    for record in (body .. ";"):gmatch("(.-);") do
        count = count + 1
        if count > MAX_RECORDS then return Failure("Settings string exceeds the supported size limits.") end
        local name, encoded = record:match("^([A-Za-z][A-Za-z0-9_.]*)=(.*)$")
        if not name or #name > 80 then return Failure("Invalid settings string.") end
        if records[name] ~= nil then return Failure("Duplicate or misplaced setting: %s.", name) end
        local value = Decode(encoded)
        if value == nil then return Failure("Invalid setting: %s.", name) end
        records[name] = value
    end
    return records
end

-- Four-byte blocks fit exactly in Lua 5.1 numbers. Fixed-width Base62 blocks
-- preserve leading zero bytes without bit libraries, padding, or punctuation.
local alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
local digitValues, encodedWidths, decodedWidths = {}, { 2, 3, 5, 6 }, { [2] = 1, [3] = 2, [5] = 3, [6] = 4 }
for index = 1, #alphabet do digitValues[alphabet:sub(index, index)] = index - 1 end

local function ToBase62(bytes)
    local parts = {}
    for start = 1, #bytes, 4 do
        local size = math.min(4, #bytes - start + 1)
        local value, digits = 0, {}
        for offset = 0, size - 1 do value = value * 256 + bytes:byte(start + offset) end
        for index = encodedWidths[size], 1, -1 do
            local digit = value % 62
            digits[index] = alphabet:sub(digit + 1, digit + 1)
            value = math.floor(value / 62)
        end
        parts[#parts + 1] = table.concat(digits)
    end
    return table.concat(parts)
end

local function FromBase62(text)
    if text == "" or text:find("[^A-Za-z0-9]") then return nil end
    local parts = {}
    for start = 1, #text, 6 do
        local width = math.min(6, #text - start + 1)
        local size = decodedWidths[width]
        if not size then return nil end
        local value, bytes = 0, {}
        for offset = 0, width - 1 do value = value * 62 + digitValues[text:sub(start + offset, start + offset)] end
        if value >= 256 ^ size then return nil end
        for index = size, 1, -1 do
            bytes[index] = string.char(value % 256)
            value = math.floor(value / 256)
        end
        parts[#parts + 1] = table.concat(bytes)
    end
    return table.concat(parts)
end

local function CompactRecord(key, value)
    local rule = schema[key]
    local tag = rule.scope == "modern" and 128 or 0
    if type(value) == "boolean" then return string.char(rule.id, tag + (value and 1 or 0)) end
    if type(value) == "number" then
        local decimal = tostring(value)
        if tonumber(decimal) ~= value then decimal = string.format("%.17g", value) end
        return string.char(rule.id, tag + 2, #decimal) .. decimal
    end
    return string.char(rule.id, tag + 3, math.floor(#value / 256), #value % 256) .. value
end

local function ParseCompact(text)
    if text:sub(1, 5) ~= COMPACT_PREFIX then return Failure("Unsupported settings format. Update PlateSCT.") end
    local bytes = FromBase62(text:sub(6, -9))
    if not bytes or Checksum(COMPACT_PREFIX .. bytes) ~= text:sub(-8) then
        return Failure("Settings string is incomplete or damaged.")
    end
    local source, versionSize = bytes:byte(1, 2)
    if (source ~= 0 and source ~= 1) or not versionSize or versionSize == 0
        or versionSize > 64 or #bytes < versionSize + 2 then return Failure("Invalid settings string.") end
    local records = { source = source == 0 and "classic" or "modern", addon = bytes:sub(3, 2 + versionSize) }
    local position, count, seen = 3 + versionSize, 2, {}
    while position <= #bytes do
        count = count + 1
        if count > MAX_RECORDS then return Failure("Settings string exceeds the supported size limits.") end
        local id, tag = bytes:byte(position, position + 1)
        if not tag or id == 0 then return Failure("Invalid settings string.") end
        local key = fieldsById[id] or ("unknown" .. id)
        if seen[id] then return Failure("Duplicate or misplaced setting: %s.", key) end
        seen[id] = true
        local scope = tag >= 128 and "modern" or "shared"
        if tag >= 128 then tag = tag - 128 end
        position = position + 2
        local value
        if tag == 0 or tag == 1 then
            value = tag == 1
        elseif tag == 2 or tag == 3 then
            local size = bytes:byte(position)
            if not size then return Failure("Invalid settings string.") end
            position = position + 1
            if tag == 3 then
                local low = bytes:byte(position)
                if not low then return Failure("Invalid settings string.") end
                size, position = size * 256 + low, position + 1
            end
            if size > MAX_STRING then return Failure("Settings string exceeds the supported size limits.") end
            if position + size - 1 > #bytes then return Failure("Invalid settings string.") end
            local raw = bytes:sub(position, position + size - 1)
            position = position + size
            if tag == 2 then value = Decode("n:" .. raw)
            elseif not raw:find("[%z\1-\31\127]") then value = raw end
        end
        if value == nil then return Failure("Invalid setting: %s.", key) end
        records[scope .. "." .. key] = value
    end
    return records
end

local function Parse(text)
    if type(text) ~= "string" then return Failure("Invalid settings string.") end
    -- Multiline edit boxes wrap and copy line breaks into an otherwise unbroken string.
    text = text:gsub("%s+", "")
    if text == "" then return Failure("Invalid settings string.") end
    if #text > MAX_BYTES then return Failure("Settings string exceeds the supported size limits.") end
    local records, err
    if text:sub(1, 4) == "PSCT" then records, err = ParseCompact(text)
    else records, err = ParseV1(text) end
    if not records then return nil, err end
    if records.source ~= "classic" and records.source ~= "modern" then return Failure("Invalid settings string.") end
    if type(records.addon) ~= "string" or #records.addon > 64 or not records.addon:match("^[A-Za-z0-9_.%+%-]+$") then
        return Failure("Invalid settings string.")
    end
    return records
end

function BD:ExportSettings()
    if not CheckSchema() then return Failure("Settings schema is incomplete. Update PlateSCT.") end
    local source = Flavor()
    if not source or not self.db then return Failure("Settings sharing is unavailable on this client.") end
    local reader = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    local version = reader and reader(ADDON_NAME, "Version") or "unknown"
    if type(version) ~= "string" or #version > 64 then return Failure("Invalid settings string.") end
    local records = { string.char(source == "classic" and 0 or 1, #version) .. version }
    for id = 1, 255 do
        local key = fieldsById[id]
        local rule = key and schema[key]
        if rule and not localPreferences[key] and (rule.scope == "shared" or source == "modern") then
            local value = self.db[key]
            if value == nil then value = self.DEFAULTS[key] end
            if not ValidValue(key, value) then return Failure("Invalid setting: %s.", key) end
            records[#records + 1] = CompactRecord(key, value)
        end
    end
    local payload = table.concat(records)
    local text = COMPACT_PREFIX .. ToBase62(payload) .. Checksum(COMPACT_PREFIX .. payload)
    -- Guarantee that every successful export can also pass the applicable rules.
    local preview, err = self:PreviewSettingsImport(text)
    if not preview then return nil, err end
    return text
end

-- Preview values are a patch, not a replacement database. No live state is changed.
function BD:PreviewSettingsImport(text)
    if not CheckSchema() then return Failure("Settings schema is incomplete. Update PlateSCT.") end
    local destination = Flavor()
    if not destination or not self.db then return Failure("Settings sharing is unavailable on this client.") end
    local records, err = Parse(text)
    if not records then return nil, err end
    local result = { source = records.source, addonVersion = records.addon, values = {}, changes = {}, ignored = {},
        sharedCount = 0, modernCount = 0, preservesModern = destination ~= "modern" or records.source ~= "modern" }
    local seenKeys, schoolSettings, modeSettings = {}, false, false
    for name, value in pairs(records) do
        if name ~= "source" and name ~= "addon" then
            local scope, key = name:match("^([a-z]+)%.([A-Za-z][A-Za-z0-9_]*)$")
            if not key then return Failure("Invalid settings string.") end
            if seenKeys[key] then return Failure("Duplicate or misplaced setting: %s.", key) end
            seenKeys[key] = true
            local rule = schema[key]
            if key == "layoutRevision" or (rule and rule.scope ~= scope)
                or (scope == "modern" and records.source ~= "modern") then
                return Failure("Duplicate or misplaced setting: %s.", key)
            end
            if not rule or localPreferences[key] or (scope ~= "shared" and destination ~= "modern") then
                result.ignored[#result.ignored + 1] = name
            else
                if not ValidValue(key, value) then return Failure("Invalid setting: %s.", key) end
                result.values[key] = value
                if key:sub(1, 12) == "schoolFilter" then schoolSettings = true end
                if key == "onlyMyDamage" or key == "allNameplates" then modeSettings = true end
            end
        end
    end
    local candidate = {}
    for key, value in pairs(self.db) do candidate[key] = value end
    for key, value in pairs(result.values) do candidate[key] = value end
    if modeSettings and candidate.onlyMyDamage and candidate.allNameplates then
        return Failure("Invalid setting: %s.", "allNameplates")
    end
    if schoolSettings and candidate.schoolFilterEnabled and candidate.schoolFilterRecommended then
        self:ApplySchoolFilterRecommended(candidate)
        for _, school in ipairs(self.DAMAGE_SCHOOLS) do result.values[school.dbKey] = candidate[school.dbKey] end
        result.recommendedSchools = true
    end
    for key, value in pairs(result.values) do
        if self.db[key] ~= value then
            result.changes[#result.changes + 1] = { key = key, before = self.db[key], after = value }
            local counter = schema[key].scope == "modern" and "modernCount" or "sharedCount"
            result[counter] = result[counter] + 1
        end
    end
    table.sort(result.changes, function(a, b) return a.key < b.key end)
    table.sort(result.ignored)
    return result
end

function BD:ImportSettings(text)
    -- Reparse at Apply time; never trust a preview table supplied by a caller.
    local result, err = self:PreviewSettingsImport(text)
    if not result then return nil, err end
    if #result.changes == 0 then return result end
    for _, change in ipairs(result.changes) do self.db[change.key] = change.after end
    local ok, refreshError = pcall(self.RefreshSettings, self)
    if not ok then
        for _, change in ipairs(result.changes) do self.db[change.key] = change.before end
        -- Restore runtime effects as far as possible, even if the failed UI cannot rebuild.
        pcall(self.RefreshSettings, self)
        return nil, self.L["Settings import failed; previous settings were restored."], refreshError
    end
    return result
end
