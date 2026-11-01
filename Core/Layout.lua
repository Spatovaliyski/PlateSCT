local _, BD = ...

-- Display layouts. One global choice places outgoing numbers on enemy nameplates or in
-- screen areas; incoming numbers always use screen areas. Ingest and settings ask here
-- what the current layout can do instead of testing the mode or the client themselves.
local Layout = {}
BD.Layout = Layout

Layout.MODES = {
    { id = "nameplates", labelKey = "Nameplates" },
    { id = "screen", labelKey = "Screen" },
}

function Layout.Mode()
    return BD.db and BD.db.displayMode == "screen" and "screen" or "nameplates"
end

function Layout.IsScreen()
    return Layout.Mode() == "screen"
end

-- Which units can carry an outgoing number:
--   "plate"          nameplate tokens with a plate (nameplate layout)
--   "plateOrTarget"  also your target while it has no plate (screen layout, Modern API)
--   "any"            any combat log destination (screen layout, Classic API)
function Layout.OutgoingSource()
    if not Layout.IsScreen() then
        return "plate"
    end
    if BD.API.IsModern() then
        return "plateOrTarget"
    end
    return "any"
end

-- Features that belong to one layout. Anything not listed works in both.
local FEATURES = {
    styleOffsets = "nameplates", -- per-style X/Y offsets from the plate
    motionChoices = "nameplates", -- Modern motion paths (fountain, rainfall, ...)
    impactStyle = "nameplates", -- Impact's plate-relative placement
    outgoingRoutes = "screen", -- outgoing numbers follow the area routes
}

function Layout.Supports(feature)
    local mode = FEATURES[feature]
    return mode == nil or mode == Layout.Mode()
end

-- The nameplate layout draws on enemy plates. On Modern clients the screen layout needs them
-- too: their UNIT_COMBAT events are where outgoing numbers come from.
function Layout.NeedsEnemyNameplates()
    return not Layout.IsScreen() or BD.API.IsModern()
end

-- Whether the game shows enemy nameplates. Unknown counts as shown.
function Layout.EnemyNameplatesShown()
    local reader = (C_CVar and (C_CVar.GetCVarBool or C_CVar.GetCVar)) or GetCVarBool or GetCVar
    if not reader then
        return true
    end
    local ok, enabled = pcall(reader, "nameplateShowEnemies")
    return not ok or enabled == nil or (enabled ~= false and enabled ~= "0" and enabled ~= 0)
end

-- Accept a unit token as an outgoing destination. Returns the key that identifies the enemy
-- for dedupe and combining (its plate, or "target" for a target without a plate), or nil.
function BD.OutgoingUnitKey(unit)
    if BD.IsNameplateUnit(unit) then
        return BD.GetNamePlateFrame(unit)
    end
    -- UNIT_COMBAT repeats one wound on every alias. Taking "target" only while it has no plate
    -- means a hit can never arrive through two accepted tokens.
    if unit == "target" and Layout.OutgoingSource() == "plateOrTarget" and not BD.GetNamePlateFrame("target") then
        return "target"
    end
    return nil
end

-- Outgoing number entry point for both combat flavors. destKey identifies the enemy for screen
-- areas (a plate, a Classic GUID, or "target"); the nameplate layout needs the unit's plate.
function BD:ShowOutgoing(unit, destKey, text, r, g, b, amount, isCrit, isHeal, spellIcon, hitKind, spellId)
    if Layout.IsScreen() then
        self:ShowInArea(destKey or unit, text, r, g, b, amount, isCrit, isHeal, spellIcon, hitKind, spellId)
    elseif unit then
        self:ShowOnNameplate(unit, text, r, g, b, amount, isCrit, isHeal, spellIcon, hitKind, spellId)
    end
end

-- Screen areas. db.screenAreas is a list kept outside DEFAULTS so CopyDefaults cannot bring back
-- an area the player deleted. Positions are the area center from screen center, in unscaled UI
-- units (numbers ignore the UI scale). The two built-in areas cannot be deleted or renamed.
BD.SCREEN_AREA_LIMIT = 10
BD.SCREEN_AREA_NAME_MAX = 24
BD.SCREEN_AREA_BUILTIN = { outgoing = "Outgoing", incoming = "Incoming" }
BD.SCREEN_AREA_RANGES = {
    x = { -1400, 1400 },
    y = { -600, 600 },
    width = { 40, 800 },
    height = { 40, 600 },
}
BD.SCREEN_STYLES = {
    { id = "linear", labelKey = "Linear", recommended = true },
    { id = "impact", labelKey = "Impact" },
}
BD.SCREEN_AREA_DIRECTIONS = {
    { id = "up", labelKey = "Up" },
    { id = "down", labelKey = "Down" },
}
BD.SCREEN_AREA_PATHS = {
    { id = "straight", labelKey = "Straight" },
    { id = "curveLeft", labelKey = "Curve left" },
    { id = "curveRight", labelKey = "Curve right" },
    { id = "static", labelKey = "Static" },
}
BD.SCREEN_AREA_ANIMATIONS = {
    { id = "straight", labelKey = "Straight" },
    { id = "curveLeft", labelKey = "Curve left" },
    { id = "curveRight", labelKey = "Curve right" },
    { id = "static", labelKey = "Static" },
    { id = "impact", labelKey = "Impact" },
}
BD.SCREEN_AREA_ALIGNMENTS = {
    { id = "left", labelKey = "Left" },
    { id = "center", labelKey = "Center" },
    { id = "right", labelKey = "Right" },
}
BD.DEFAULT_SCREEN_AREAS = {
    { id = "outgoing", x = 220, y = 40, width = 180, height = 240, direction = "up", path = "straight",
        stickyCrits = true },
    { id = "incoming", x = -220, y = 40, width = 180, height = 240, direction = "up", path = "straight",
        stickyCrits = false },
}

-- Where each kind of number goes. Unknown or deleted areas fall back to the stream's built-in area.
BD.SCREEN_ROUTES = {
    { key = "routeOutgoingHit", fallback = "outgoing", labelKey = "Outgoing hits" },
    { key = "routeOutgoingCrit", fallback = "outgoing", labelKey = "Outgoing crits" },
    { key = "routeOutgoingHeal", fallback = "outgoing", labelKey = "Outgoing heals" },
    { key = "routeOutgoingMiss", fallback = "outgoing", labelKey = "Outgoing misses" },
    { key = "routeIncomingHit", fallback = "incoming", labelKey = "Incoming hits" },
    { key = "routeIncomingCrit", fallback = "incoming", labelKey = "Incoming crits" },
    { key = "routeIncomingMiss", fallback = "incoming", labelKey = "Incoming misses" },
}

local function ValidChoice(options, value)
    for _, option in ipairs(options) do
        if option.id == value then
            return true
        end
    end
    return false
end

-- Cut to maxBytes without splitting a UTF-8 character.
local function TruncateUtf8(text, maxBytes)
    if #text <= maxBytes then
        return text
    end
    local cut = maxBytes
    while cut > 0 and text:byte(cut + 1) >= 128 and text:byte(cut + 1) < 192 do
        cut = cut - 1
    end
    return text:sub(1, cut)
end

function BD.IsScreenAreaId(id)
    return type(id) == "string" and #id <= 16 and id:match("^[a-z][a-z0-9]*$") ~= nil
end

-- Convert only missing fields. Used by login and legacy imports before normalization.
function BD.UpgradeScreenAreaMotion(area, settings)
    if type(area) ~= "table" then return end
    settings = settings or {}
    if not area.animation then
        area.animation = settings.screenStyle == "impact" and "impact" or area.path or "straight"
    end
    if not area.duration then
        local base = tonumber(settings.duration) or 1
        local speed = math.max(0.1, tonumber(settings.scrollSpeed) or 1)
        area.duration = area.path == "static" and base * 2
            or math.max(base, base * (tonumber(area.height) or 240) / 100) / speed
    end
end

-- A clean copy of a saved or imported area, clamped to the supported ranges, or nil.
function BD.NormalizeScreenArea(area)
    if type(area) ~= "table" or not BD.IsScreenAreaId(area.id) then
        return nil
    end
    local defaults = BD.DEFAULT_SCREEN_AREAS[1]
    for _, builtin in ipairs(BD.DEFAULT_SCREEN_AREAS) do
        if builtin.id == area.id then
            defaults = builtin
        end
    end
    local clean = { id = area.id }
    if not BD.SCREEN_AREA_BUILTIN[area.id] then
        local name = type(area.name) == "string" and area.name or ""
        name = TruncateUtf8(name:gsub("[%z\1-\31\127]", ""), BD.SCREEN_AREA_NAME_MAX)
        clean.name = name ~= "" and name or area.id
    end
    for field, range in pairs(BD.SCREEN_AREA_RANGES) do
        local value = tonumber(area[field])
        if not value or value ~= value then
            value = defaults[field]
        end
        clean[field] = math.floor(math.max(range[1], math.min(range[2], value)) + 0.5)
    end
    clean.direction = ValidChoice(BD.SCREEN_AREA_DIRECTIONS, area.direction) and area.direction or defaults.direction
    clean.path = ValidChoice(BD.SCREEN_AREA_PATHS, area.path) and area.path or defaults.path
    clean.stickyCrits = area.stickyCrits == true
    clean.animation = ValidChoice(BD.SCREEN_AREA_ANIMATIONS, area.animation) and area.animation or clean.path
    clean.alignment = ValidChoice(BD.SCREEN_AREA_ALIGNMENTS, area.alignment) and area.alignment or "center"
    local duration = tonumber(area.duration)
    -- Legacy travel times can exceed the editor's 0.5–8 second range. Keep them on upgrade.
    clean.duration = duration and duration == duration and math.max(0.01, math.min(48, duration)) or 2.4
    local spacing = tonumber(area.spacing)
    clean.spacing = spacing and spacing == spacing and math.floor(math.max(0, math.min(24, spacing)) + 0.5) or 4
    return clean
end

-- A valid list: known fields only, unique ids, built-ins first, at most SCREEN_AREA_LIMIT.
function BD.NormalizeScreenAreas(list)
    local clean, seen = {}, {}
    for _, builtin in ipairs(BD.DEFAULT_SCREEN_AREAS) do
        local saved
        for _, area in ipairs(type(list) == "table" and list or {}) do
            if type(area) == "table" and area.id == builtin.id then
                saved = area
                break
            end
        end
        clean[#clean + 1] = BD.NormalizeScreenArea(saved or builtin)
        seen[builtin.id] = true
    end
    for _, area in ipairs(type(list) == "table" and list or {}) do
        local normalized = BD.NormalizeScreenArea(area)
        if normalized and not seen[normalized.id] and #clean < BD.SCREEN_AREA_LIMIT then
            clean[#clean + 1] = normalized
            seen[normalized.id] = true
        end
    end
    return clean
end

function BD:EnsureScreenAreas(db)
    db = db or self.db
    if (db.layoutRevision or 1) < 16 then
        for _, area in ipairs(type(db.screenAreas) == "table" and db.screenAreas or {}) do
            if type(area) == "table" then BD.UpgradeScreenAreaMotion(area, db) end
        end
    end
    db.screenAreas = BD.NormalizeScreenAreas(db.screenAreas)
    for _, route in ipairs(BD.SCREEN_ROUTES) do
        if not self.FindScreenArea(db, db[route.key]) then
            db[route.key] = route.fallback
        end
    end
    return db.screenAreas
end

function BD.FindScreenArea(db, id)
    for _, area in ipairs(db and db.screenAreas or {}) do
        if area.id == id then
            return area
        end
    end
    return nil
end

function BD:GetRoutedArea(routeKey, fallback)
    local db = self.db
    return BD.FindScreenArea(db, db[routeKey]) or BD.FindScreenArea(db, fallback)
        or BD.FindScreenArea(db, "outgoing") or BD.DEFAULT_SCREEN_AREAS[1]
end

function BD:GetScreenAreaLabel(area)
    if not area then
        return ""
    end
    local builtin = BD.SCREEN_AREA_BUILTIN[area.id]
    if builtin then
        return BD.L[builtin]
    end
    return area.name or area.id
end

-- Add a custom area just above the screen center. Returns it, or nil at the limit.
function BD:AddScreenArea()
    local areas = self:EnsureScreenAreas()
    if #areas >= BD.SCREEN_AREA_LIMIT then
        return nil
    end
    local index = 1
    while BD.FindScreenArea(self.db, "custom" .. index) do
        index = index + 1
    end
    local area = BD.NormalizeScreenArea({ id = "custom" .. index,
        name = string.format(BD.L["Area %d"], index), x = 0, y = 160, width = 200, height = 160,
        direction = "up", path = "straight", stickyCrits = false })
    areas[#areas + 1] = area
    return area
end

-- Delete a custom area; routes that used it return to their built-in area.
function BD:DeleteScreenArea(id)
    if BD.SCREEN_AREA_BUILTIN[id] then
        return false
    end
    local areas = self.db.screenAreas or {}
    for index = #areas, 1, -1 do
        if areas[index].id == id then
            table.remove(areas, index)
        end
    end
    self:EnsureScreenAreas()
    return true
end

-- Before screen areas, incoming numbers used fixed offsets from screen center (unscaled units,
-- like areas). A custom position keeps its spot: the Incoming area starts where those numbers
-- appeared and rises as they did. The old default leaves the area alone.
function BD.PlaceIncomingAreaAtOffsets(area, offsetX, offsetY)
    if not area or (offsetX == 0 and offsetY == -100) then
        return
    end
    area.x, area.y, area.height = offsetX, offsetY + 60, 120
    area.direction, area.path = "up", "straight"
end

-- Import/export: one record per area, "id,name,x,y,width,height,direction,path,sticky".
-- Names escape "%" and "," as %XX so the separators stay unambiguous.
local function EscapeName(name)
    return (name:gsub("[%%,]", function(char) return string.format("%%%02X", char:byte()) end))
end

local function UnescapeName(text)
    -- Every "%" must start a two-digit escape.
    if text:gsub("%%%x%x", ""):find("%%") then
        return nil
    end
    local name = text:gsub("%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end)
    if name:find("[%z\1-\31\127]") then
        return nil
    end
    return name
end

function BD.EncodeScreenArea(area)
    area = BD.NormalizeScreenArea(area)
    if not area then
        return nil
    end
    return table.concat({ area.id, EscapeName(area.name or ""), area.x, area.y, area.width, area.height,
        area.direction, area.animation ~= "impact" and area.animation or area.path,
        area.stickyCrits and "1" or "0" }, ",")
end

-- Supplementary records keep the original nine-field area format readable by older releases.
function BD.EncodeScreenAreaMotion(area)
    area = BD.NormalizeScreenArea(area)
    if not area then return nil end
    return table.concat({ area.id, area.animation, string.format("%.15g", area.duration), area.spacing,
        area.alignment }, ",")
end

function BD.DecodeScreenAreaMotion(text)
    if type(text) ~= "string" then return nil end
    local id, animation, duration, spacing, alignment = text:match("^([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)$")
    duration, spacing = tonumber(duration), tonumber(spacing)
    if not BD.IsScreenAreaId(id) or not ValidChoice(BD.SCREEN_AREA_ANIMATIONS, animation)
        or not ValidChoice(BD.SCREEN_AREA_ALIGNMENTS, alignment)
        or not duration or duration ~= duration or duration < 0.01 or duration > 48
        or not spacing or spacing ~= spacing or spacing < 0 or spacing > 24 or spacing % 1 ~= 0 then
        return nil
    end
    return { id = id, animation = animation, duration = duration, spacing = spacing, alignment = alignment }
end

-- Returns the area, or nil unless the record is exactly what EncodeScreenArea writes.
function BD.DecodeScreenArea(text)
    if type(text) ~= "string" then
        return nil
    end
    local fields = {}
    for field in (text .. ","):gmatch("(.-),") do
        fields[#fields + 1] = field
    end
    if #fields ~= 9 or not BD.IsScreenAreaId(fields[1]) then
        return nil
    end
    local name = UnescapeName(fields[2])
    if not name or #name > BD.SCREEN_AREA_NAME_MAX then
        return nil
    end
    local area = { id = fields[1], name = name, direction = fields[7], path = fields[8],
        stickyCrits = fields[9] == "1" }
    for index, field in ipairs({ "x", "y", "width", "height" }) do
        local raw = fields[index + 2]
        local range = BD.SCREEN_AREA_RANGES[field]
        local value = raw:match("^%-?%d+$") and tonumber(raw)
        if not value or value < range[1] or value > range[2] then
            return nil
        end
        area[field] = value
    end
    if fields[9] ~= "0" and fields[9] ~= "1" then
        return nil
    end
    local normalized = BD.NormalizeScreenArea(area)
    if not normalized or normalized.direction ~= area.direction or normalized.path ~= area.path then
        return nil
    end
    return normalized
end
