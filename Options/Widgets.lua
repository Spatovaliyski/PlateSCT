local ADDON_NAME, BD = ...
local W = {}
BD.OptionsWidgets = W

local MEDIA = "Interface\\AddOns\\" .. (ADDON_NAME or "PlateSCT") .. "\\Media\\"
local WHITE = "Interface\\Buttons\\WHITE8X8"
local ROUND = MEDIA .. "UI\\Round.png"
local CONTROL_WIDTH = 220
local CONTROL_HEIGHT = 32
local ROW_PAD = 12
local ROW_MINIMUM = 48
local REASON_GAP = 8

-- Version A ("Ember") palette: warm near-black surfaces, one gold accent.
local C = {
    window = { 0.071, 0.063, 0.051, 1 },
    sidebar = { 0.055, 0.047, 0.039, 1 },
    drawer = { 0.043, 0.039, 0.031, 1 },
    edge = { 0.180, 0.157, 0.122, 1 },
    line = { 0.141, 0.122, 0.094, 1 },
    rule = { 0.125, 0.110, 0.086, 1 },
    field = { 0.106, 0.094, 0.075, 1 },
    fieldHover = { 0.133, 0.118, 0.094, 1 },
    fieldOpen = { 0.141, 0.122, 0.090, 1 },
    selected = { 0.169, 0.145, 0.106, 1 },
    navActive = { 0.133, 0.114, 0.086, 1 },
    hover = { 0.098, 0.086, 0.067, 1 },
    menu = { 0.118, 0.102, 0.078, 1 },
    menuHover = { 0.165, 0.141, 0.106, 1 },
    card = { 0.090, 0.078, 0.059, 1 },
    cardHover = { 0.106, 0.094, 0.071, 1 },
    cardSelected = { 0.110, 0.094, 0.063, 1 },
    warning = { 0.141, 0.106, 0.055, 1 },
    accent = { 0.851, 0.682, 0.373, 1 },
    accentHover = { 0.902, 0.741, 0.439, 1 },
    accentDown = { 0.722, 0.573, 0.306, 1 },
    accentSoft = { 0.851, 0.682, 0.373, 0.55 },
    onAccent = { 0, 0, 0 },
    text = { 0.929, 0.902, 0.847 },
    bright = { 0.945, 0.918, 0.863 },
    navText = { 0.788, 0.753, 0.690 },
    muted = { 0.639, 0.604, 0.541 },
    dim = { 0.549, 0.518, 0.459 },
    disabledText = { 0.45, 0.42, 0.37 },
    warningText = { 0.922, 0.796, 0.576 },
    warningIcon = { 0.914, 0.706, 0.373 },
    reasonText = { 0.835, 0.706, 0.506 },
    switchOff = { 0.180, 0.157, 0.125, 1 },
    switchOffHover = { 0.216, 0.192, 0.153, 1 },
    switchDisabled = { 0.122, 0.106, 0.082, 1 },
    switchOnDisabled = { 0.400, 0.325, 0.192, 1 },
    knobOn = { 0.078, 0.067, 0.047, 1 },
    knobOff = { 0.549, 0.518, 0.459, 1 },
    knobDisabled = { 0.227, 0.200, 0.165, 1 },
    black = { 0, 0, 0, 1 },
    blackHover = { 0.075, 0.067, 0.055, 1 },
    radio = { 0.353, 0.318, 0.267, 1 },
    health = { 0.722, 0.196, 0.165, 1 },
    number = { 1, 0.827, 0.302 },
}
W.COLORS = C
local GOLD, TEXT, MUTED = C.accent, C.text, C.muted

local function Localize(text)
    return BD.L and BD.L[text] or text
end

local function Hook(frame, event, handler)
    if frame.HookScript then
        frame:HookScript(event, handler)
    else
        local previous = frame:GetScript(event)
        frame:SetScript(event, function(self, ...)
            if previous then previous(self, ...) end
            handler(self, ...)
        end)
    end
end

local function RGB(color) return color[1], color[2], color[3] end

-- Fonts -------------------------------------------------------------------------------------

-- Inter and Marcellus cover Latin and (Inter only) Cyrillic. Korean and Chinese use the
-- client font, which also keeps user-entered names in those scripts readable.
local FONT_FILES = {
    regular = "Inter-Regular.ttf", medium = "Inter-Medium.ttf",
    semibold = "Inter-SemiBold.ttf", display = "Marcellus-Regular.ttf",
}
local CJK = { koKR = true, zhCN = true, zhTW = true }

function W.FontPath(role)
    local code = BD.ResolveLocaleCode and BD:ResolveLocaleCode()
    local client = GetLocale and GetLocale()
    if CJK[code] or CJK[client] then
        return BD.GetDefaultFontPath and BD.GetDefaultFontPath() or STANDARD_TEXT_FONT
    end
    if role == "display" and (code == "ruRU" or client == "ruRU") then role = "semibold" end
    return MEDIA .. "Fonts\\" .. (FONT_FILES[role] or FONT_FILES.regular)
end

-- The client loads a font file on first use. Text laid out before that can stay blank, so
-- touch every bundled font while the addon loads, well before the settings window is built.
if CreateFrame then
    local loader = CreateFrame("Frame")
    loader:Hide()
    for _, file in pairs(FONT_FILES) do
        local probe = loader:CreateFontString(nil, "ARTWORK")
        if probe.SetFont then pcall(probe.SetFont, probe, MEDIA .. "Fonts\\" .. file, 13, "") end
        probe:SetText("Aa")
    end
end

-- Re-lay text whose font may have loaded after it was set.
function W.RefreshText(region)
    local text = region:GetText()
    if not text then return end
    region:SetText("")
    region:SetText(text)
end

-- Supporting text under a label (descriptions, notes, disabled reasons) sits one step below
-- the 13pt label size. This floor applies to the settings window only; combat text keeps
-- BD.MIN_FONT_SIZE.
W.SMALL_SIZE = 12

local function FontFloor(region)
    return region.optionsSmall and W.SMALL_SIZE or BD.MIN_FONT_SIZE
end

local function ApplyFont(region, path, size, flags)
    if size >= BD.MIN_FONT_SIZE then
        BD.SafeSetFont(region, path, size, flags)
        return
    end
    -- SafeSetFont clamps to the combat-text minimum, so set the small size directly.
    local ok, loaded = pcall(region.SetFont, region, path, size, flags or "")
    if not ok or loaded == false then
        pcall(region.SetFont, region, BD.GetDefaultFontPath and BD.GetDefaultFontPath() or STANDARD_TEXT_FONT, size, flags or "")
    end
end

-- Clamp only addon-owned regions; never change shared Blizzard FontObjects.
function W.SetFont(region, role, size, flags)
    region.optionsRole = role or "regular"
    size = math.max(FontFloor(region), size or BD.MIN_FONT_SIZE)
    region.optionsSize = size
    ApplyFont(region, W.FontPath(region.optionsRole), size, flags)
end

function W.ReadableFont(region, sizeOverride)
    local _, size, flags = region:GetFont()
    size = math.max(FontFloor(region), sizeOverride or region.optionsSize or size or BD.MIN_FONT_SIZE)
    region.optionsSize = size
    ApplyFont(region, W.FontPath(region.optionsRole or "regular"), size, flags)
end

-- Make a text region supporting text: smaller than the label it explains.
function W.SetSmall(region)
    region.optionsSmall = true
    W.SetFont(region, region.optionsRole or "regular", W.SMALL_SIZE)
    region:SetSpacing(3)
    return region
end

local TEMPLATE_ROLES = {
    GameFontNormalLarge = "semibold", GameFontNormalHuge = "semibold",
    GameFontNormal = "medium", GameFontNormalSmall = "medium",
}

-- Uppercase for section labels. Lua's upper() only folds ASCII, so map Latin-1 and Cyrillic too.
local upperCase = {}
do
    local lower = "àáâãäåæçèéêëìíîïðñòóôõöøùúûüýœабвгдеёжзийклмнопрстуфхцчшщъыьэюя"
    local upper = "ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝŒАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
    local from, to = {}, {}
    for char in lower:gmatch("[%z\1-\127\194-\244][\128-\191]*") do from[#from + 1] = char end
    for char in upper:gmatch("[%z\1-\127\194-\244][\128-\191]*") do to[#to + 1] = char end
    for index, char in ipairs(from) do upperCase[char] = to[index] end
end
-- Section headings use title case in English ("Display Mode"). Other languages keep their
-- own capitalization, which title case would make wrong.
local MINOR_WORDS = {
    a = true, an = true, ["and"] = true, as = true, at = true, but = true, by = true, ["for"] = true,
    from = true, ["in"] = true, into = true, of = true, on = true, ["or"] = true, per = true,
    the = true, to = true, via = true, vs = true, with = true,
}
function W.Title(text)
    text = text or ""
    local code = BD.ResolveLocaleCode and BD:ResolveLocaleCode() or "enUS"
    if code ~= "enUS" then return text end
    local index = 0
    return (text:gsub("[%w'%-]+", function(word)
        index = index + 1
        if index > 1 and MINOR_WORDS[word:lower()] then return word:lower() end
        return word:sub(1, 1):upper() .. word:sub(2)
    end))
end

function W.Upper(text)
    if CJK[BD.ResolveLocaleCode and BD:ResolveLocaleCode() or ""] then return text or "" end
    return ((text or ""):gsub("[a-z]", string.upper):gsub("[\194-\244][\128-\191]*", upperCase))
end

-- Rounded shapes ----------------------------------------------------------------------------

-- A shape is four quarter-circle corners and three strips, tinted with vertex colors.
-- Every fill is opaque, so the strips may abut without visible seams.
local CORNERS = {
    { "TOPLEFT", 1, -1, 0, 0.5, 0, 0.5 },
    { "TOPRIGHT", -1, -1, 0.5, 1, 0, 0.5 },
    { "BOTTOMRIGHT", -1, 1, 0.5, 1, 0.5, 1 },
    { "BOTTOMLEFT", 1, 1, 0, 0.5, 0.5, 1 },
}

local function NoSnap(texture)
    if texture.SetSnapToPixelGrid then texture:SetSnapToPixelGrid(false) end
    if texture.SetTexelSnappingBias then texture:SetTexelSnappingBias(0) end
end

local function NewShape(frame, sublevel)
    local shape = { frame = frame, parts = {} }
    for index = 1, 7 do
        local texture = frame:CreateTexture(nil, "BACKGROUND", nil, sublevel)
        NoSnap(texture)
        shape.parts[index] = texture
    end
    return shape
end

local function LayoutShape(shape, radius, inset, square)
    local key = radius .. ":" .. inset .. ":" .. (square or "")
    if shape.key == key then return end
    shape.key = key
    local frame, parts = shape.frame, shape.parts
    for index, spec in ipairs(CORNERS) do
        local corner = parts[index]
        corner:ClearAllPoints()
        corner:SetPoint(spec[1], frame, spec[1], spec[2] * inset, spec[3] * inset)
        corner:SetSize(radius, radius)
        if square and square:find(tostring(index), 1, true) then
            corner:SetTexture(WHITE); corner:SetTexCoord(0, 1, 0, 1)
        else
            corner:SetTexture(ROUND); corner:SetTexCoord(spec[4], spec[5], spec[6], spec[7])
        end
    end
    local top, middle, bottom = parts[5], parts[6], parts[7]
    for _, strip in ipairs({ top, middle, bottom }) do strip:SetTexture(WHITE); strip:ClearAllPoints() end
    top:SetPoint("TOPLEFT", frame, "TOPLEFT", inset + radius, -inset)
    top:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -inset - radius, -inset)
    top:SetHeight(math.max(radius, 0.01))
    bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", inset + radius, inset)
    bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -inset - radius, inset)
    bottom:SetHeight(math.max(radius, 0.01))
    middle:SetPoint("TOPLEFT", frame, "TOPLEFT", inset, -inset - radius)
    middle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -inset, inset + radius)
    shape.rounded = radius > 0
end

local function ColorShape(shape, color)
    for index, part in ipairs(shape.parts) do
        part:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
        part:SetShown(shape.rounded or index == 6)
    end
end

local function HideShape(shape)
    if not shape then return end
    for _, part in ipairs(shape.parts) do part:Hide() end
end

-- Paint a rounded fill, with an optional 1px ring. `square` lists corners (1 TL, 2 TR,
-- 3 BR, 4 BL) that stay square where a panel meets the window edge.
function W.Paint(frame, fill, radius, ring, square)
    radius = radius or 8
    frame.optionsFillShape = frame.optionsFillShape or NewShape(frame, -6)
    if ring then
        frame.optionsRingShape = frame.optionsRingShape or NewShape(frame, -7)
        LayoutShape(frame.optionsRingShape, radius, 0, square)
        ColorShape(frame.optionsRingShape, ring)
        LayoutShape(frame.optionsFillShape, math.max(0, radius - 1), 1, square)
    else
        HideShape(frame.optionsRingShape)
        LayoutShape(frame.optionsFillShape, radius, 0, square)
    end
    ColorShape(frame.optionsFillShape, fill)
    frame.optionsFill = fill
end

function W.Unpaint(frame)
    HideShape(frame.optionsFillShape)
    HideShape(frame.optionsRingShape)
    frame.optionsFill = nil
end

function W.Icon(parent, name, size, color, layer)
    local icon = parent:CreateTexture(nil, layer or "ARTWORK")
    icon:SetTexture(MEDIA .. "UI\\Icons\\" .. name .. ".png")
    icon:SetSize(size or 16, size or 16)
    NoSnap(icon)
    if color then icon:SetVertexColor(color[1], color[2], color[3], color[4] or 1) end
    return icon
end

function W.SetIcon(icon, name)
    icon:SetTexture(MEDIA .. "UI\\Icons\\" .. name .. ".png")
end

function W.Line(parent, color, layer)
    local line = parent:CreateTexture(nil, layer or "BORDER")
    line:SetColorTexture(RGB(color or C.line))
    return line
end

local function Circle(parent, size, color, layer, sublevel)
    local circle = parent:CreateTexture(nil, layer or "ARTWORK", nil, sublevel)
    circle:SetTexture(ROUND)
    circle:SetSize(size, size)
    NoSnap(circle)
    if color then circle:SetVertexColor(color[1], color[2], color[3], color[4] or 1) end
    return circle
end

-- Surfaces ----------------------------------------------------------------------------------

local KINDS = {
    window = { fill = C.window, radius = 10, ring = C.edge },
    inset = { fill = C.sidebar, radius = 8 },
    control = { fill = C.field, radius = 8 },
    button = { fill = C.field, radius = 8 },
    focus = { fill = C.fieldOpen, radius = 8, ring = C.accentSoft },
    selected = { fill = C.selected, radius = 8, ring = C.accent },
    card = { fill = C.card, radius = 10 },
    cardSelected = { fill = C.cardSelected, radius = 10, ring = C.accent },
    menu = { fill = C.menu, radius = 10, ring = C.edge },
    warning = { fill = C.warning, radius = 8 },
    drawer = { fill = C.drawer, radius = 0 },
}

-- Action buttons are filled gold pills; every state changes only the fill and label color.
local ACTION_FACES = {
    idle = { fill = C.accent, text = C.onAccent },
    hover = { fill = C.accentHover, text = C.onAccent },
    down = { fill = C.accentDown, text = C.onAccent },
    selected = { fill = C.accentHover, text = C.onAccent },
    disabled = { fill = { 0.200, 0.176, 0.141, 1 }, text = C.disabledText },
    disabledHover = { fill = { 0.235, 0.208, 0.165, 1 }, text = C.muted },
}

function W.PaintAction(frame, mode)
    if mode == "idle" and frame.IsMouseOver and frame:IsMouseOver() then mode = "hover" end
    if frame.IsEnabled and not frame:IsEnabled() then
        mode = mode == "hover" and "disabledHover" or "disabled"
    end
    local face = ACTION_FACES[mode] or ACTION_FACES.idle
    W.Paint(frame, face.fill, frame.optionsRadius or 8)
    local font = frame.GetFontString and frame:GetFontString()
    if font and face.text then font:SetTextColor(RGB(face.text)) end
end

function W.Backdrop(frame, kind, radius)
    frame.optionsBackdropKind = kind
    if frame.optionsStyle == "action" and (kind == "action" or kind == "selected") then
        W.PaintAction(frame, kind == "selected" and "selected" or "idle")
        return
    end
    local spec = KINDS[kind]
    if not spec then W.Unpaint(frame); return end
    W.Paint(frame, spec.fill, radius or spec.radius, spec.ring)
end

-- Text --------------------------------------------------------------------------------------

function W.Text(parent, text, x, y, width, template, color)
    local label = parent:CreateFontString(nil, "ARTWORK", template or "GameFontHighlight")
    label.optionsRole = TEMPLATE_ROLES[template or ""] or "regular"
    W.ReadableFont(label)
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", x or 0, y or 0)
    if width then label:SetWidth(width) end
    label:SetJustifyH("LEFT")
    label:SetJustifyV("TOP")
    label:SetSpacing(4)
    label:SetWordWrap(true)
    label:SetText(text or "")
    label:SetTextColor(RGB(color or TEXT))
    return label
end

function W.Tooltip(owner, text)
    if not text then return end
    Hook(owner, "OnEnter", function(self)
        local message = type(text) == "function" and text(self) or text
        if not message or message == "" or not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(message, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    Hook(owner, "OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
    end)
    Hook(owner, "OnHide", function(self)
        if GameTooltip and GameTooltip.IsOwned and GameTooltip:IsOwned(self) then
            GameTooltip:Hide()
        end
    end)
end

-- Buttons -----------------------------------------------------------------------------------

-- Non-action styles: "flat" (filled field), "nav" (sidebar page), "utility" (quiet sidebar
-- link), "ghost" (no fill until hovered) and "menu" (dropdown entry).
local function PaintButton(button)
    local style = button.optionsStyle
    if style == "action" then
        W.PaintAction(button, button.optionsSelected and "selected" or "idle")
        return
    end
    local enabled = not button.IsEnabled or button:IsEnabled()
    local over = enabled and button.IsMouseOver and button:IsMouseOver()
    local selected, open = button.optionsSelected, button.optionsOpen
    local fill, text, icon
    if style == "flat" then
        fill = open and C.fieldOpen or selected and C.selected or over and C.fieldHover or C.field
        text = not enabled and C.disabledText or selected and C.accent or C.bright
        icon = not enabled and C.disabledText or C.muted
    elseif style == "menu" then
        fill = over and C.menuHover or nil
        text = selected and C.accent or over and C.bright or C.text
    elseif style == "result" then
        fill = (selected or over) and C.menuHover or nil
        text = C.bright
    elseif style == "black" then
        fill = over and C.blackHover or C.black
        text = enabled and C.bright or C.disabledText
    elseif style == "segment" then
        fill = selected and C.selected or over and C.navActive or nil
        text = selected and C.accent or over and C.bright or C.muted
    elseif style == "nav" then
        fill = selected and C.navActive or over and C.hover or nil
        text = selected and C.accent or over and C.bright or C.navText
        icon = selected and C.accent or over and C.navText or C.dim
    else -- utility, ghost
        fill = selected and C.navActive or over and C.hover or nil
        text = selected and C.accent or over and C.bright or C.muted
        icon = text
    end
    if fill then W.Paint(button, fill, button.optionsRadius or 8, style == "black" and C.edge or nil) else W.Unpaint(button) end
    local font = button:GetFontString()
    if font then font:SetTextColor(RGB(text)) end
    if button.optionsIcon and icon then button.optionsIcon:SetVertexColor(RGB(icon)) end
    if button.optionsTrailing then button.optionsTrailing:SetVertexColor(RGB(icon or text)) end
end
W.PaintButton = PaintButton

function W.SetSelected(button, selected)
    button.optionsSelected = selected and true or false
    PaintButton(button)
end

function W.Button(parent, label, width, height, onClick, style)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width or 160, height or 32)
    style = style or "action"
    button.optionsStyle = style
    local font = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button:SetFontString(font)
    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontNormal")
    button:SetDisabledFontObject("GameFontDisable")
    button:SetText(label or "")
    local role = (style == "action" or style == "black") and "semibold" or "medium"
    if style == "utility" or style == "menu" or style == "result" then role = "regular" end
    local size = 13
    W.SetFont(font, role, size)
    font:ClearAllPoints()
    local centered = style == "action" or style == "segment" or style == "black"
    local inset = centered and 14 or 12
    font:SetPoint("LEFT", inset, 0)
    font:SetPoint("RIGHT", -inset, 0)
    font:SetJustifyH(centered and "CENTER" or "LEFT")
    font:SetWordWrap(false)
    if button.SetMotionScriptsWhileDisabled then button:SetMotionScriptsWhileDisabled(true) end
    Hook(button, "OnEnter", function(self)
        if self.optionsStyle == "action" then W.PaintAction(self, "hover") else PaintButton(self) end
    end)
    Hook(button, "OnLeave", PaintButton)
    Hook(button, "OnEnable", PaintButton)
    Hook(button, "OnDisable", PaintButton)
    Hook(button, "OnShow", PaintButton)
    if style == "action" then
        Hook(button, "OnMouseDown", function(self)
            if self:IsEnabled() then W.PaintAction(self, "down") end
        end)
        Hook(button, "OnMouseUp", PaintButton)
    end
    button:SetScript("OnClick", function(self, ...)
        if self:IsEnabled() and onClick then onClick(self, ...) end
    end)
    -- Font objects reapply on state changes; keep the addon font and readable size.
    for _, event in ipairs({ "OnEnter", "OnLeave", "OnEnable", "OnDisable", "OnShow", "OnMouseUp" }) do
        Hook(button, event, function() W.ReadableFont(font) end)
    end
    PaintButton(button)
    return button
end

-- Sidebar page with a leading icon.
function W.NavButton(parent, label, icon, width, height, onClick, style)
    local button = W.Button(parent, label, width, height, onClick, style or "nav")
    local iconSize = button.optionsStyle == "nav" and 16 or 15
    button.optionsIcon = W.Icon(button, icon, iconSize)
    button.optionsIcon:SetPoint("LEFT", 10, 0)
    local font = button:GetFontString()
    font:ClearAllPoints()
    font:SetPoint("LEFT", 36, 0)
    font:SetPoint("RIGHT", -8, 0)
    PaintButton(button)
    return button
end

function W.TextLink(parent, label, onClick)
    local link = CreateFrame("Button", nil, parent)
    local font = link:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    link:SetFontString(font); link:SetText(label)
    W.SetFont(font, "medium", 13)
    font:SetPoint("CENTER"); font:SetWordWrap(false); font:SetTextColor(RGB(GOLD))
    link:SetSize(font:GetStringWidth() + 8, font:GetStringHeight() + 8)
    local underline = link:CreateTexture(nil, "ARTWORK")
    underline:SetPoint("TOPLEFT", font, "BOTTOMLEFT", 0, -1)
    underline:SetPoint("TOPRIGHT", font, "BOTTOMRIGHT", 0, -1)
    underline:SetHeight(1); underline:SetColorTexture(RGB(GOLD)); underline:Hide()
    link:SetScript("OnEnter", function() font:SetTextColor(RGB(C.accentHover)); underline:Show() end)
    link:SetScript("OnLeave", function() font:SetTextColor(RGB(GOLD)); underline:Hide() end)
    link:SetScript("OnHide", function() font:SetTextColor(RGB(GOLD)); underline:Hide() end)
    link:SetScript("OnClick", function(self) if self:IsEnabled() then onClick() end end)
    return link
end

function W.CloseButton(parent, onClick)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(32, 32)
    button.optionsStyle = "ghost"
    local icon = W.Icon(button, "Close", 16, C.muted)
    icon:SetPoint("CENTER")
    button.icon = icon
    button:SetScript("OnEnter", function(self)
        W.Paint(self, C.hover, 8); self.icon:SetVertexColor(RGB(C.bright))
    end)
    button:SetScript("OnLeave", function(self)
        W.Unpaint(self); self.icon:SetVertexColor(RGB(C.muted))
    end)
    button:SetScript("OnClick", function(self, ...)
        if onClick then onClick(self, ...) end
    end)
    return button
end

function W.EditBox(parent, width, height)
    local box = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
    box:SetSize(width or CONTROL_WIDTH, height or CONTROL_HEIGHT)
    box:SetAutoFocus(false)
    W.Backdrop(box, "control")
    box:SetFontObject("GameFontHighlight")
    W.SetFont(box, "medium", 13)
    box:SetTextInsets(12, 12, 0, 0)
    box:SetJustifyH("LEFT")
    box:SetTextColor(RGB(C.bright))
    return box
end

-- Settings rows -----------------------------------------------------------------------------

local function GetBinding(binding)
    if type(binding) == "table" then return binding.get() end
    return BD.db and BD.db[binding]
end

local function SetBinding(binding, value)
    if type(binding) == "table" then
        binding.set(value)
    else
        BD.db[binding] = value
    end
end

local function BindingId(binding)
    return type(binding) == "table" and binding.id or binding
end

local function Evaluate(value, control)
    if type(value) == "function" then return value(control) end
    return value
end

local function Changed(root, binding, value, onChanged)
    SetBinding(binding, value)
    if onChanged then onChanged(value) end
    if not root.retired then root:Refresh() end
end

local function SetAvailable(control)
    local available = not control.isEnabled or control.isEnabled()
    control.available = available and true or false
    control:SetEnabled(available and true or false)
    control.label:SetTextColor(RGB(available and TEXT or C.dim))
    local row = control.row
    if row and row.layoutDescription then
        local description = Evaluate(row.descriptionSource, control)
        row.layoutDescription:SetText(description or "")
        row.layoutDescription:SetShown(description ~= nil and description ~= "")
        row.layoutDescription:SetTextColor(RGB(available and MUTED or C.dim))
    end
    if control.layoutType == "input" or control.layoutType == "amount" then
        control:SetTextColor(RGB(available and C.bright or C.dim))
    end
    if control.reason then
        local reason = Evaluate(control.disabledReason, control)
        control.reason:SetText(not available and reason or "")
        control.reason:SetShown(not available and reason and reason ~= "")
    end
    if not available and control.menu and control.menu:IsShown() then
        control.menu:Hide()
    end
    if control.Paint then control:Paint() end
    return available
end

local function OptionsFor(control)
    if (control.binding == "fontFace" or control.binding == "incomingFontFace") and BD.GetFontFaceOptions then
        control.options = BD.GetFontFaceOptions()
    end
    return type(control.options) == "function" and control.options() or control.options or {}
end

local function OptionText(option)
    return option.label or (option.labelKey and Localize(option.labelKey)) or tostring(option.id or "")
end

local function OptionDisplay(option)
    local text = OptionText(option)
    if option.recommended then
        text = text .. " |cffa39a8a(" .. Localize("Recommended") .. ")|r"
    end
    return text
end

local function HideFontPreview(menu, owner)
    local preview = menu.fontPreview
    if preview and (not owner or preview.owner == owner) then
        preview.owner = nil
        preview:Hide()
    end
end

local function ShowFontPreview(menu, entry)
    if not menu.owner or (menu.owner.binding ~= "fontFace" and menu.owner.binding ~= "incomingFontFace")
        or not menu:IsShown() then return end
    if GameTooltip then GameTooltip:Hide() end
    local preview = menu.fontPreview
    if not preview then
        preview = CreateFrame("Frame", nil, menu, "BackdropTemplate")
        preview:SetFrameStrata("TOOLTIP")
        preview:SetFrameLevel(menu:GetFrameLevel() + 4)
        preview:SetClampedToScreen(true)
        preview:EnableMouse(false)
        W.Backdrop(preview, "menu")
        preview.label = W.Text(preview, "", 14, -12, nil, nil, C.muted)
        preview.label:SetWordWrap(false)
        preview.number = preview:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
        preview.number:SetPoint("TOPLEFT", 14, -36)
        preview.number:SetWordWrap(false)
        menu.fontPreview = preview
    end
    local incoming = menu.owner.binding == "incomingFontFace"
    local preset = BD:GetStylePreset(incoming and BD.db.numberStyle == "impact" and "retail" or nil)
    local size = ((incoming and BD.db.incomingFontSize) or BD.db.fontSize or BD.DEFAULTS.fontSize) * preset.fontScale
    BD.SafeSetFont(preview.number, BD.ResolveFontPath(entry.optionId), size, preset.fontFlags)
    local shadow = preset.shadowOffset
    preview.number:SetShadowOffset(shadow and shadow[1] or 0, shadow and shadow[2] or 0)
    preview.number:SetShadowColor(0, 0, 0, 1)
    preview.number:SetTextColor(unpack(preset.defaultColor))
    preview.number:SetText("12345")
    preview.label:SetWidth(0)
    preview.label:SetText(entry:GetText())
    local width = math.max(120, preview.label:GetStringWidth(), preview.number:GetStringWidth()) + 28
    local screenWidth = UIParent:GetWidth() * UIParent:GetEffectiveScale() / preview:GetEffectiveScale()
    width = math.min(width, math.max(120, screenWidth - 24))
    preview.label:SetWidth(width - 28)
    preview:SetSize(width, 50 + math.max(size, preview.number:GetStringHeight()))
    preview:ClearAllPoints()
    preview:SetPoint("TOPLEFT", entry, "TOPRIGHT", 12, 0)
    preview.owner = entry
    preview:Show()
end

local MENU_ROW, MENU_PAD = 32, 6

local function CreateMenu(root)
    local layer = CreateFrame("Button", nil, UIParent)
    layer:SetAllPoints(UIParent)
    layer:SetFrameStrata("FULLSCREEN_DIALOG")
    layer:EnableMouse(true)
    layer:EnableMouseWheel(true)
    layer:Hide()
    local menu = CreateFrame("Frame", nil, layer, "BackdropTemplate")
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:SetFrameLevel(layer:GetFrameLevel() + 2)
    menu:SetClampedToScreen(true)
    menu:EnableMouse(true)
    menu:EnableMouseWheel(true)
    W.Backdrop(menu, "menu")
    menu.entries = {}
    menu.layer = layer
    local scroll = CreateFrame("ScrollFrame", nil, menu)
    scroll:SetPoint("TOPLEFT", MENU_PAD, -MENU_PAD)
    scroll:SetPoint("BOTTOMRIGHT", -MENU_PAD - 8, MENU_PAD)
    scroll:EnableMouseWheel(true)
    local child = CreateFrame("Frame", nil, scroll)
    scroll:SetScrollChild(child)
    menu.scroll = scroll
    menu.child = child
    local thumb = CreateFrame("Frame", nil, menu)
    thumb:SetWidth(4)
    W.Paint(thumb, C.edge, 2)
    menu.thumb = thumb
    local function UpdateThumb()
        HideFontPreview(menu)
        local full = child:GetHeight()
        local view = scroll:GetHeight()
        local maximum = math.max(0, full - view)
        if maximum <= 0 or view <= 0 then thumb:Hide(); return end
        local height = math.max(18, view * view / full)
        thumb:ClearAllPoints()
        thumb:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -5, -MENU_PAD - (view - height) * scroll:GetVerticalScroll() / maximum)
        thumb:SetHeight(height)
        thumb:Show()
    end
    local function MouseWheel(_, delta)
        local maximum = math.max(0, child:GetHeight() - scroll:GetHeight())
        scroll:SetVerticalScroll(math.max(0, math.min(maximum, scroll:GetVerticalScroll() - delta * MENU_ROW)))
        UpdateThumb()
    end
    menu.MouseWheel = MouseWheel
    menu.UpdateThumb = UpdateThumb
    layer:SetScript("OnMouseWheel", function() end)
    layer:SetScript("OnClick", function() menu:Hide() end)
    menu:SetScript("OnMouseWheel", MouseWheel)
    scroll:SetScript("OnMouseWheel", MouseWheel)
    scroll:SetScript("OnVerticalScroll", UpdateThumb)
    function menu:Dismiss() self:Hide() end
    menu:SetScript("OnHide", function(self)
        HideFontPreview(self)
        layer:Hide()
        if self.owner then
            self.owner.optionsOpen = nil
            if self.owner.optionsTrailing then W.SetIcon(self.owner.optionsTrailing, "ChevronDown") end
            PaintButton(self.owner)
        end
        self.owner = nil
        if root.transientMenu == self then root.transientMenu = nil end
        root.pageScrollLocked = false
    end)
    return menu
end

local function OpenMenu(control, root)
    if not control:IsEnabled() then return end
    if control.menu and control.menu:IsShown() then control.menu:Hide(); return end
    root:DismissTransient()
    local menu = control.menu or CreateMenu(root)
    control.menu = menu
    menu.layer:SetScale(root:GetScale())
    menu.owner = control
    local options = OptionsFor(control)
    local selected = GetBinding(control.binding)
    for _, entry in ipairs(menu.entries) do entry:Hide() end
    local width = control:GetWidth()
    for index, option in ipairs(options) do
        local entry = menu.entries[index]
        if not entry then
            entry = W.Button(menu.child, "", width - 20, MENU_ROW, nil, "menu")
            entry.optionsRadius = 6
            entry:EnableMouseWheel(true)
            entry:SetScript("OnMouseWheel", menu.MouseWheel)
            local font = entry:GetFontString()
            font:SetPoint("LEFT", 10, 0)
            font:SetPoint("RIGHT", -30, 0)
            entry.check = W.Icon(entry, "Check", 15, GOLD, "OVERLAY")
            entry.check:SetPoint("RIGHT", -10, 0)
            Hook(entry, "OnEnter", function(self) ShowFontPreview(menu, self) end)
            Hook(entry, "OnLeave", function(self) HideFontPreview(menu, self) end)
            Hook(entry, "OnHide", function(self) HideFontPreview(menu, self) end)
            menu.entries[index] = entry
        end
        entry.optionId = option.id
        entry:SetText(OptionDisplay(option))
        entry.check:SetShown(option.id == selected)
        W.SetSelected(entry, option.id == selected)
        local optionId = option.id
        entry:SetScript("OnClick", function()
            menu:Hide()
            if control:IsEnabled() then Changed(root, control.binding, optionId, control.onChanged) end
        end)
        entry:ClearAllPoints()
        entry:SetPoint("TOPLEFT", 0, -(index - 1) * MENU_ROW)
        entry:Show()
        width = math.max(width, (entry:GetFontString():GetStringWidth() or 0) + 60)
    end
    -- Clamp long translations while preserving a useful viewport on small UI scales.
    local screenScale = root:GetScale()
    width = math.min(width, math.max(CONTROL_WIDTH, UIParent:GetWidth() / screenScale - 40))
    local fullHeight = math.max(MENU_ROW, #options * MENU_ROW)
    local viewHeight = math.min(fullHeight, 8 * MENU_ROW, math.max(MENU_ROW * 2, UIParent:GetHeight() / screenScale - 80))
    menu:SetSize(width, viewHeight + MENU_PAD * 2)
    menu.child:SetSize(width - MENU_PAD * 2 - 8, fullHeight)
    for _, entry in ipairs(menu.entries) do entry:SetWidth(width - MENU_PAD * 2 - 8) end
    menu:ClearAllPoints()
    local bottom = control:GetBottom()
    if bottom and bottom < viewHeight + 24 then
        menu:SetPoint("BOTTOMRIGHT", control, "TOPRIGHT", 0, 6)
    else
        menu:SetPoint("TOPRIGHT", control, "BOTTOMRIGHT", 0, -6)
    end
    root.transientMenu = menu
    root.pageScrollLocked = true
    control.optionsOpen = true
    if control.optionsTrailing then W.SetIcon(control.optionsTrailing, "ChevronUp") end
    PaintButton(control)
    menu.layer:Show()
    menu:Show()
    menu.scroll:SetVerticalScroll(0)
    -- Keep the current font/choice in view when lists exceed the popup viewport.
    for index, option in ipairs(options) do
        if option.id == selected then
            menu.scroll:SetVerticalScroll(math.min(math.max(0, fullHeight - viewHeight), (index - 1) * MENU_ROW))
            break
        end
    end
    menu.UpdateThumb()
    menu:Raise()
end

local function FormatAmount(number)
    number = tonumber(number) or 0
    if number >= 1000000 and number % 1000000 == 0 then return string.format("%.0fm", number / 1000000) end
    if number >= 1000000 then return string.format("%.1fm", number / 1000000) end
    if number >= 1000 and number % 1000 == 0 then return string.format("%.0fk", number / 1000) end
    if number >= 1000 then return string.format("%.1fk", number / 1000) end
    return tostring(number)
end

local function ParseAmount(text)
    text = string.gsub(string.lower(text or ""), "%s", "")
    if text == "" then return 0 end
    local number, suffix = string.match(text, "^([%d%.]+)([km]?)$")
    number = tonumber(number or text)
    if not number or number ~= number or number == math.huge or number == -math.huge then return nil end
    if suffix == "k" then number = number * 1000 end
    if suffix == "m" then number = number * 1000000 end
    if number == math.huge then return nil end
    return math.floor(math.max(0, number))
end

-- Typed slider values keep digits, one leading minus when the range allows it, and one
-- decimal point on fractional sliders. A comma is read as the decimal point.
local function SanitizeEntry(text, allowNegative, allowDecimal)
    text = string.gsub(text or "", ",", ".")
    local negative = allowNegative and string.sub(text, 1, 1) == "-"
    local clean = string.gsub(text, allowDecimal and "[^%d%.]" or "%D", "")
    local point = allowDecimal and string.find(clean, ".", 1, true)
    if point then
        clean = string.sub(clean, 1, point) .. string.gsub(string.sub(clean, point + 1), "%.", "")
    end
    return (negative and "-" or "") .. clean
end

-- Rounds to the slider's display precision and clamps to its range, but not to its step.
local function ParseEntry(text, minimum, maximum, decimals)
    local number = tonumber(text)
    if not number then return nil end
    local scale = 10 ^ decimals
    number = math.floor(number * scale + 0.5) / scale
    return math.max(minimum, math.min(maximum, number))
end

local function StepDecimals(step)
    local decimals = 0
    while decimals < 4 do
        local scaled = step * 10 ^ decimals
        if math.abs(scaled - math.floor(scaled + 0.5)) < 1e-9 then break end
        decimals = decimals + 1
    end
    return decimals
end

local function CreateValueEntry(root)
    local layer = CreateFrame("Button", nil, UIParent)
    layer:SetAllPoints(UIParent)
    layer:SetFrameStrata("FULLSCREEN_DIALOG")
    layer:EnableMouse(true)
    layer:EnableMouseWheel(true)
    layer:Hide()
    local popup = CreateFrame("Frame", nil, layer, "BackdropTemplate")
    popup:SetFrameStrata("FULLSCREEN_DIALOG")
    popup:SetFrameLevel(layer:GetFrameLevel() + 2)
    popup:SetClampedToScreen(true)
    popup:EnableMouse(true)
    W.Backdrop(popup, "menu")
    popup.layer = layer
    local input = W.EditBox(popup, 110, 32)
    input:SetPoint("TOPLEFT", 12, -12)
    input:SetMaxLetters(10)
    popup.input = input
    local function PaintInput(focused)
        W.Backdrop(input, focused and "focus" or "control")
    end
    PaintInput(false)
    local apply = W.Button(popup, Localize("Apply"), 76, 32, function() popup:Commit() end)
    apply:SetPoint("TOPRIGHT", -12, -12)
    local range = W.Text(popup, "", 12, -54, nil, nil, MUTED)
    range:SetWordWrap(false)
    popup.range = range
    layer:SetScript("OnMouseWheel", function() end)
    layer:SetScript("OnClick", function() popup:Hide() end)
    input:SetScript("OnTextChanged", function(self, userInput)
        if not userInput or not popup.request then return end
        local text = self:GetText()
        local request = popup.request
        local clean = SanitizeEntry(text, request.minimum < 0, request.decimals > 0)
        if clean == text then return end
        local cursor = self:GetCursorPosition() - (#text - #clean)
        self:SetText(clean)
        self:SetCursorPosition(math.max(0, math.min(#clean, cursor)))
    end)
    input:SetScript("OnEnterPressed", function() popup:Commit() end)
    input:SetScript("OnEscapePressed", function() popup:Hide() end)
    input:SetScript("OnEditFocusGained", function() PaintInput(true) end)
    input:SetScript("OnEditFocusLost", function() PaintInput(false) end)
    function popup:Commit()
        local request = self.request
        local value = request and ParseEntry(input:GetText(), request.minimum, request.maximum, request.decimals)
        self:Hide()
        if value ~= nil then request.apply(value) end
    end
    popup:SetScript("OnHide", function(self)
        layer:Hide()
        input:ClearFocus()
        self.owner, self.request = nil, nil
        if root.transientMenu == self then root.transientMenu = nil end
        root.pageScrollLocked = false
    end)
    return popup
end

local function OpenValueEntry(control, root, request)
    if not control:IsEnabled() then return end
    root:DismissTransient()
    local popup = root.valueEntry or CreateValueEntry(root)
    root.valueEntry = popup
    popup.layer:SetScale(root:GetScale())
    popup.owner, popup.request = control, request
    popup.range:SetText(request.range)
    popup:SetSize(math.max(222, popup.range:GetStringWidth() + 24), 80)
    popup:ClearAllPoints()
    local anchor = control.entryButton
    local bottom = anchor:GetBottom()
    if bottom and bottom < 104 then
        popup:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", 0, 6)
    else
        popup:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -6)
    end
    root.transientMenu = popup
    root.pageScrollLocked = true
    popup.layer:Show()
    popup:Show()
    popup:Raise()
    popup.input:SetText(string.format("%." .. request.decimals .. "f", request.value))
    popup.input:SetFocus()
    popup.input:HighlightText()
end

-- Display-mode card artwork, drawn with textures so it needs no extra image files.
local function ArtNumber(parent, text, size, x, y, alpha)
    local number = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    W.SetFont(number, "semibold", size, "OUTLINE")
    number:SetText(text)
    number:SetTextColor(C.number[1], C.number[2], C.number[3], alpha or 1)
    number:SetPoint("BOTTOM", parent, "BOTTOM", x, y)
    return number
end

local ART = {
    nameplates = function(art)
        local bar = CreateFrame("Frame", nil, art)
        bar:SetSize(96, 8); bar:SetPoint("BOTTOM", 0, 18)
        local back = bar:CreateTexture(nil, "ARTWORK"); back:SetAllPoints(); back:SetColorTexture(0, 0, 0, 1)
        local health = bar:CreateTexture(nil, "OVERLAY")
        health:SetPoint("TOPLEFT", 1, -1); health:SetPoint("BOTTOMLEFT", 1, 1); health:SetWidth(60)
        health:SetColorTexture(RGB(C.health))
        ArtNumber(art, "9,120", 14, -58, 32)
        ArtNumber(art, "24,800", 21, 4, 40)
        ArtNumber(art, "3,404", 13, -34, 66, 0.5)
    end,
    screen = function(art)
        local screen = CreateFrame("Frame", nil, art)
        screen:SetSize(150, 68); screen:SetPoint("CENTER")
        W.Paint(screen, C.drawer, 6, C.radio)
        for side = -1, 1, 2 do
            local column = CreateFrame("Frame", nil, screen)
            column:SetSize(30, 52); column:SetPoint("CENTER", side * 46, 0)
            W.Paint(column, { 0.118, 0.102, 0.078, 1 }, 3)
            for line = 1, 3 do
                local bar = column:CreateTexture(nil, "ARTWORK")
                bar:SetSize(line == 2 and 12 or 18, 4); bar:SetPoint("BOTTOM", 0, 6 + (line - 1) * 8)
                bar:SetColorTexture(0.43, 0.39, 0.33, 1)
            end
        end
    end,
}
W.ART = ART

function W.NewLayout(parent, root, pageId, tabId, width)
    local PAD_LEFT, PAD_RIGHT, TOP = 32, 14, -4
    local layout = { parent = parent, root = root, page = pageId, tab = tabId, x = PAD_LEFT, y = TOP,
        width = math.max(200, (width or parent:GetWidth()) - PAD_LEFT - PAD_RIGHT), rows = {} }
    parent.rows = layout.rows

    local function ControlWidth(total)
        return math.min(CONTROL_WIDTH, math.floor(total * 0.44))
    end

    function layout:Gap(amount)
        amount = amount or 14
        self.pendingGap = (self.pendingGap or 0) + amount
        self.y = self.y - amount
    end

    function layout:AddRow(row, caption, kind)
        row.layoutCaption, row.layoutKind = caption, kind
        local previous = self.rows[#self.rows]
        -- Notes and warnings that follow a setting sit a little below its rule.
        if (kind == "note" or kind == "warning") and previous and previous.layoutKind ~= "heading"
            and previous.layoutKind ~= "note" and not self.pendingGap then
            self.pendingGap = 10
        end
        row.layoutGap = self.pendingGap or 0
        self.pendingGap = nil
        self.rows[#self.rows + 1] = row
    end

    function layout:When(predicate, build)
        local first = #self.rows + 1
        build(self)
        for index = first, #self.rows do
            local row = self.rows[index]
            local previous = row.isVisible
            row.isVisible = function() return predicate() and (not previous or previous()) end
        end
    end

    function layout:Heading(text)
        if #self.rows > 0 then self:Gap(28) end
        self.section = text
        local row = CreateFrame("Frame", nil, parent)
        row:SetSize(self.width, 28)
        row:SetPoint("TOPLEFT", self.x, self.y)
        local label = W.Text(row, W.Title(text), 0, -2, self.width, nil, GOLD)
        W.SetFont(label, "semibold", 14)
        local line = row:CreateTexture(nil, "ARTWORK")
        line:SetPoint("BOTTOMLEFT", 0, 2)
        line:SetPoint("BOTTOMRIGHT", 0, 2)
        line:SetHeight(1)
        line:SetColorTexture(RGB(C.line))
        self:AddRow(row, label, "heading")
        self.y = self.y - math.max(24, label:GetStringHeight() + 12)
        return label
    end

    function layout:Note(text)
        local previous = self.rows[#self.rows]
        if previous and previous.layoutKind == "heading" then self:Gap(8) end
        local row = CreateFrame("Frame", nil, parent)
        row:SetPoint("TOPLEFT", self.x, self.y)
        row:SetWidth(self.width)
        local label = W.SetSmall(W.Text(row, text, 0, -2, self.width, nil, MUTED))
        local height = math.max(16, label:GetStringHeight()) + 12
        row:SetHeight(height)
        label.row = row
        self:AddRow(row, label, "note")
        self.y = self.y - height
        return label
    end

    function layout:Warning(text)
        local row = CreateFrame("Frame", nil, parent)
        row:SetPoint("TOPLEFT", self.x, self.y)
        row:SetWidth(self.width)
        W.Backdrop(row, "warning")
        local icon = W.Icon(row, "Warning", 16, C.warningIcon)
        icon:SetPoint("TOPLEFT", 14, -13)
        local label = W.Text(row, text, 40, -12, self.width - 54, nil, C.warningText)
        local height = math.max(18, label:GetStringHeight()) + 24
        row:SetHeight(height)
        label.row = row
        self:AddRow(row, label, "warning")
        self.y = self.y - height - 10
        return label
    end

    function layout:NewRow(label, minimum, disabledReason, tip)
        local row = CreateFrame("Frame", nil, parent)
        row:SetWidth(self.width)
        row:SetPoint("TOPLEFT", self.x, self.y)
        row:EnableMouse(true)
        local rule = row:CreateTexture(nil, "BACKGROUND")
        rule:SetHeight(1)
        rule:SetPoint("BOTTOMLEFT"); rule:SetPoint("BOTTOMRIGHT")
        rule:SetColorTexture(RGB(C.rule))
        row.rule = rule
        local controlWidth = ControlWidth(self.width)
        local textWidth = self.width - controlWidth - 24
        local caption = W.Text(row, label, 0, -ROW_PAD, textWidth, nil, TEXT)
        W.SetFont(caption, "medium", 13)
        local description = W.SetSmall(W.Text(row, Evaluate(tip) or "", 0, 0, textWidth, nil, MUTED))
        description:SetShown(description:GetText() ~= nil)
        row.layoutDescription, row.descriptionSource = description, tip
        local reason
        if disabledReason then
            reason = W.SetSmall(W.Text(row, Evaluate(disabledReason) or "", 0, 0, textWidth, nil, C.reasonText))
        end
        row.minimumHeight, row.layoutReason = minimum or ROW_MINIMUM, reason
        self:AddRow(row, caption, "control")
        local y = self.y
        local height = row.minimumHeight
        row:SetHeight(height)
        self.y = self.y - height
        return row, caption, reason, controlWidth, y
    end

    function layout:Register(control, binding, row, caption, reason, y, tip, enabled, onChanged, disabledReason)
        control.row, control.label, control.reason = row, caption, reason
        row.layoutControl = control
        control.binding, control.isEnabled, control.onChanged = binding, enabled, onChanged
        control.disabledReason = disabledReason
        -- Descriptions are written under each label, so rows need no hover tooltip.
        local meta = { id = BindingId(binding), label = caption:GetText(), tip = Evaluate(tip, control),
            page = pageId, tab = tabId, section = self.section, y = y }
        control.searchMeta = meta
        root:RegisterControl(control, meta)
        return control
    end

    function layout:Checkbox(key, label, tip, enabledPredicate, onChanged, disabledReason)
        local row, caption, reason, _, y = self:NewRow(label, ROW_MINIMUM, disabledReason, tip)
        -- A switch: native CheckButton behavior with a painted track and knob.
        local control = CreateFrame("CheckButton", nil, row)
        control:SetSize(40, 24)
        control:SetPoint("TOPRIGHT", 0, -ROW_PAD)
        control.layoutType = "switch"
        if control.SetHitRectInsets then control:SetHitRectInsets(-6, -6, -8, -8) end
        local knob = Circle(control, 18, C.knobOff, "ARTWORK")
        control.knob = knob
        self:Register(control, key, row, caption, reason, y, tip, enabledPredicate, onChanged, disabledReason)
        function control:Paint()
            local on = self:GetChecked() and true or false
            local enabled = self:IsEnabled()
            local over = enabled and self.IsMouseOver and self:IsMouseOver()
            local track = not enabled and (on and C.switchOnDisabled or C.switchDisabled)
                or on and (over and C.accentHover or C.accent) or (over and C.switchOffHover or C.switchOff)
            W.Paint(self, track, 12)
            local knobColor = not enabled and C.knobDisabled or on and C.knobOn or C.knobOff
            self.knob:SetVertexColor(RGB(knobColor))
            self.knob:ClearAllPoints()
            self.knob:SetPoint("LEFT", self, "LEFT", on and 19 or 3, 0)
        end
        control:SetScript("OnClick", function(self)
            if self:IsEnabled() then Changed(root, key, self:GetChecked() and true or false, onChanged) end
            self:Paint()
        end)
        control:SetScript("OnEnter", function(self) self:Paint() end)
        control:SetScript("OnLeave", function(self) self:Paint() end)
        row:SetScript("OnMouseUp", function(_, mouseButton)
            if mouseButton == "LeftButton" and control:IsEnabled() then
                Changed(root, key, not GetBinding(key), onChanged)
            end
        end)
        function control:Refresh()
            self:SetChecked(GetBinding(key) and true or false)
            SetAvailable(self)
        end
        control:Refresh()
        return control
    end

    function layout:Slider(key, label, minimum, maximum, step, formatter, enabledPredicate, onChanged, disabledReason)
        local row, caption, reason, controlWidth, y = self:NewRow(label, ROW_MINIMUM, disabledReason)
        local control = CreateFrame("Slider", nil, row)
        if control.SetOrientation then control:SetOrientation("HORIZONTAL") end
        control:SetSize(controlWidth - 64, 20)
        control:SetMinMaxValues(minimum, maximum)
        control:SetValueStep(step)
        if control.SetObeyStepOnDrag then control:SetObeyStepOnDrag(true) end
        if control.SetHitRectInsets then control:SetHitRectInsets(-4, -4, -8, -8) end
        control:EnableMouseWheel(true)
        if control.SetThumbTexture then
            control:SetThumbTexture(ROUND)
            local thumb = control.GetThumbTexture and control:GetThumbTexture()
            if thumb then thumb:SetSize(16, 16); thumb:SetVertexColor(RGB(C.bright)); NoSnap(thumb) end
            control.thumb = thumb
        end
        local rail = CreateFrame("Frame", nil, control)
        rail:SetHeight(4)
        rail:SetPoint("LEFT", 0, 0); rail:SetPoint("RIGHT", 0, 0)
        if rail.SetFrameLevel and control.GetFrameLevel then rail:SetFrameLevel(math.max(0, control:GetFrameLevel() - 1)) end
        W.Paint(rail, C.switchOff, 2)
        local fill = CreateFrame("Frame", nil, rail)
        fill:SetPoint("TOPLEFT"); fill:SetPoint("BOTTOMLEFT")
        W.Paint(fill, GOLD, 2)
        control.rail, control.fill = rail, fill
        local valueText = W.Text(row, "", 0, 0, 52, nil, C.bright)
        W.SetFont(valueText, "medium", 13)
        valueText:ClearAllPoints()
        valueText:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, -ROW_PAD)
        valueText:SetJustifyH("RIGHT")
        valueText:SetWordWrap(false)
        control.valueText = valueText
        control.layoutType = "slider"
        self:Register(control, key, row, caption, reason, y, nil, enabledPredicate, onChanged, disabledReason)
        local function Normalize(value)
            value = math.max(minimum, math.min(maximum, value))
            local rounded = minimum + math.floor((value - minimum) / step + 0.5) * step
            return math.max(minimum, math.min(maximum, rounded))
        end
        local function Format(value)
            return formatter and formatter(value) or tostring(value)
        end
        -- Clicking the readout types an exact value. It clamps to the range but not the step.
        local entry = CreateFrame("Button", nil, row)
        entry:SetPoint("TOPRIGHT", valueText, "TOPRIGHT", 4, 4)
        local underline = entry:CreateTexture(nil, "ARTWORK")
        underline:SetPoint("BOTTOMLEFT", 4, 2)
        underline:SetPoint("BOTTOMRIGHT", -4, 2)
        underline:SetHeight(1)
        underline:SetColorTexture(RGB(GOLD))
        underline:Hide()
        local function RestEntry()
            valueText:SetTextColor(RGB(control:IsEnabled() and C.bright or C.dim))
            underline:Hide()
        end
        entry:SetScript("OnEnter", function()
            if not control:IsEnabled() then return end
            valueText:SetTextColor(RGB(GOLD))
            underline:Show()
        end)
        entry:SetScript("OnLeave", RestEntry)
        entry:SetScript("OnHide", function()
            RestEntry()
            if root.valueEntry and root.valueEntry.owner == control then root.valueEntry:Hide() end
        end)
        local decimals = StepDecimals(step)
        entry:SetScript("OnClick", function()
            OpenValueEntry(control, root, {
                value = tonumber(GetBinding(key)) or minimum,
                minimum = minimum,
                maximum = maximum,
                decimals = decimals,
                range = string.format(Localize("Range: %s to %s"), Format(minimum), Format(maximum)),
                apply = function(value)
                    if control:IsEnabled() and value ~= GetBinding(key) then
                        Changed(root, key, value, onChanged)
                    end
                end,
            })
        end)
        W.Tooltip(entry, function()
            if control:IsEnabled() then return Localize("Click to type an exact value.") end
            return Evaluate(control.disabledReason, control)
        end)
        control.entryButton = entry
        function control:PaintFill(value)
            local width = self:GetWidth()
            if not width or width <= 0 then return end
            local ratio = maximum > minimum and (math.max(minimum, math.min(maximum, value)) - minimum) / (maximum - minimum) or 0
            self.fill:SetWidth(math.max(4, 8 + ratio * (width - 16)))
        end
        local function Display(value)
            valueText:SetText(Format(value))
            entry:SetSize(math.max(24, valueText:GetStringWidth() + 8), valueText:GetStringHeight() + 8)
            control:PaintFill(value)
        end
        function control:Paint()
            local enabled = self:IsEnabled()
            W.Paint(self.fill, enabled and GOLD or C.switchOnDisabled, 2)
            if self.thumb then self.thumb:SetVertexColor(RGB(enabled and C.bright or C.knobDisabled)) end
            valueText:SetTextColor(RGB(enabled and C.bright or C.dim))
        end
        control:SetScript("OnValueChanged", function(self, value)
            if self.refreshing or not self:IsEnabled() then return end
            value = Normalize(value)
            Display(value)
            if value ~= GetBinding(key) then Changed(root, key, value, onChanged) end
        end)
        control:SetScript("OnMouseWheel", function(self, delta)
            if root.pageScrollLocked or not self:IsEnabled() then return end
            self:SetValue(Normalize((tonumber(GetBinding(key)) or minimum) + step * delta))
        end)
        control:SetScript("OnSizeChanged", function(self) self:PaintFill(tonumber(GetBinding(key)) or minimum) end)
        function control:Refresh()
            local value = tonumber(GetBinding(key)) or minimum
            self.refreshing = true
            self:SetValue(Normalize(value))
            self.refreshing = nil
            Display(value)
            SetAvailable(self)
        end
        control:Refresh()
        return control
    end

    function layout:Choice(key, label, options, tip, enabledPredicate, onChanged, disabledReason)
        local row, caption, reason, controlWidth, y = self:NewRow(label, ROW_MINIMUM, disabledReason, tip)
        local control = W.Button(row, "", controlWidth, CONTROL_HEIGHT, nil, "flat")
        control.layoutType = "choice"
        control:SetPoint("TOPRIGHT", 0, -ROW_PAD)
        local font = control:GetFontString()
        font:SetPoint("LEFT", 12, 0)
        font:SetPoint("RIGHT", -32, 0)
        font:SetJustifyH("LEFT")
        font:SetWordWrap(false)
        control.optionsTrailing = W.Icon(control, "ChevronDown", 16, C.muted, "OVERLAY")
        control.optionsTrailing:SetPoint("RIGHT", -10, 0)
        control.options = options
        self:Register(control, key, row, caption, reason, y, tip, enabledPredicate, onChanged, disabledReason)
        control:SetScript("OnClick", function() OpenMenu(control, root) end)
        Hook(control, "OnHide", function() if control.menu then control.menu:Hide() end end)
        control.Paint = PaintButton
        function control:Refresh()
            local value = GetBinding(key)
            local text = tostring(value or "")
            for _, option in ipairs(OptionsFor(self)) do
                if option.id == value then text = OptionDisplay(option); break end
            end
            self:SetText(text)
            SetAvailable(self)
        end
        control:Refresh()
        return control
    end

    local function FocusPaint(self) W.Backdrop(self, "focus") end

    function layout:Input(key, label, tip, onChanged, enabledPredicate, disabledReason)
        local row, caption, reason, _, y = self:NewRow(label, ROW_MINIMUM, disabledReason, tip)
        local control = W.EditBox(row, 120, CONTROL_HEIGHT)
        control:SetPoint("TOPRIGHT", 0, -ROW_PAD)
        control:SetMaxLetters(12)
        control:SetNumeric(false)
        control:SetJustifyH("RIGHT")
        control.layoutType = "amount"
        self:Register(control, key, row, caption, reason, y, tip, enabledPredicate, onChanged, disabledReason)
        local function Commit(self)
            if self.refreshing or not self:IsEnabled() then return end
            if not self.dirty then return end
            local value = ParseAmount(self:GetText())
            self.dirty = nil
            if value == nil then self:Refresh(); return end
            if value ~= GetBinding(key) then
                Changed(root, key, value, onChanged)
            else
                self:Refresh()
            end
        end
        control:SetScript("OnEnterPressed", function(self) Commit(self); self:ClearFocus() end)
        control:SetScript("OnEscapePressed", function(self)
            self.cancelling = true
            self.dirty = nil
            self:Refresh()
            self:ClearFocus()
            self.cancelling = nil
        end)
        control:SetScript("OnEditFocusGained", FocusPaint)
        control:SetScript("OnEditFocusLost", function(self)
            W.Backdrop(self, "control")
            if not self.cancelling then Commit(self) end
        end)
        control:SetScript("OnTextChanged", function(self, userInput)
            if userInput and not self.refreshing then self.dirty = true end
        end)
        function control:Refresh()
            -- Passive refreshes must not discard a threshold being typed.
            if self.dirty and self:HasFocus() then SetAvailable(self); return end
            self.refreshing = true
            self:SetText(FormatAmount(GetBinding(key)))
            self.dirty = nil
            self.refreshing = nil
            SetAvailable(self)
        end
        control:Refresh()
        return control
    end

    -- A secondary button. Its description, when present, sits to the left.
    function layout:Action(id, label, tip, callback, enabledPredicate, disabledReason)
        local row, caption, reason, _, y = self:NewRow(label, ROW_MINIMUM, disabledReason, tip)
        local control = W.Button(row, label, 160, CONTROL_HEIGHT, function()
            root:DismissTransient()
            if callback then callback() end
            root:Refresh()
        end, "flat")
        local font = control:GetFontString()
        font:ClearAllPoints(); font:SetPoint("LEFT", 14, 0); font:SetPoint("RIGHT", -14, 0)
        font:SetJustifyH("CENTER")
        W.SetFont(font, "medium", 13)
        caption:Hide()
        control:SetPoint("TOPRIGHT", 0, -ROW_PAD)
        control.layoutType = "action"
        self:Register(control, id, row, caption, reason, y, tip, enabledPredicate, nil, disabledReason)
        control.Paint = PaintButton
        function control:Refresh()
            if self.isEnabled then SetAvailable(self) end
            local description = Evaluate(row.descriptionSource, self)
            row.layoutDescription:SetText(description or "")
            row.layoutDescription:SetShown(description ~= nil and description ~= "")
        end
        control:Refresh()
        return control
    end

    -- Free text such as a name, committed on Enter or focus loss (Input parses amounts instead).
    function layout:TextInput(key, label, tip, maxLetters, onChanged, enabledPredicate, disabledReason)
        local row, caption, reason, controlWidth, y = self:NewRow(label, ROW_MINIMUM, disabledReason, tip)
        local control = W.EditBox(row, controlWidth, CONTROL_HEIGHT)
        control:SetPoint("TOPRIGHT", 0, -ROW_PAD)
        control:SetMaxLetters(maxLetters or 24)
        control:SetNumeric(false)
        control.layoutType = "input"
        self:Register(control, key, row, caption, reason, y, tip, enabledPredicate, onChanged, disabledReason)
        local function Commit(self)
            if self.refreshing or not self:IsEnabled() or not self.dirty then return end
            self.dirty = nil
            local value = (self:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")
            if value == "" or value == GetBinding(key) then self:Refresh(); return end
            Changed(root, key, value, onChanged)
        end
        control:SetScript("OnEnterPressed", function(self) Commit(self); self:ClearFocus() end)
        control:SetScript("OnEscapePressed", function(self)
            self.cancelling = true
            self.dirty = nil
            self:Refresh()
            self:ClearFocus()
            self.cancelling = nil
        end)
        control:SetScript("OnEditFocusGained", FocusPaint)
        control:SetScript("OnEditFocusLost", function(self)
            W.Backdrop(self, "control")
            if not self.cancelling then Commit(self) end
        end)
        control:SetScript("OnTextChanged", function(self, userInput)
            if userInput and not self.refreshing then self.dirty = true end
        end)
        function control:Refresh()
            if self.dirty and self:HasFocus() then SetAvailable(self); return end
            self.refreshing = true
            self:SetText(tostring(GetBinding(key) or ""))
            self.dirty = nil
            self.refreshing = nil
            SetAvailable(self)
        end
        control:Refresh()
        return control
    end

    -- Picture cards side by side that pick one value, e.g. the display mode. Each card is
    -- { id, title, body, image, art }; title and body are already localized. `art` (or the
    -- id) names built-in artwork; otherwise `image` is shown.
    function layout:Cards(key, cards, onChanged)
        local previous = self.rows[#self.rows]
        if previous and previous.layoutKind == "heading" then self:Gap(12) elseif previous then self:Gap(10) end
        local row = CreateFrame("Frame", nil, parent)
        row:SetPoint("TOPLEFT", self.x, self.y)
        row:SetWidth(self.width)
        row.cards = {}
        local titles = {}
        for index, info in ipairs(cards) do
            local card = CreateFrame("Button", nil, row, "BackdropTemplate")
            local art = CreateFrame("Frame", nil, card)
            W.Paint(art, C.sidebar, 8)
            local draw = ART[info.art or info.id]
            if draw then
                draw(art)
            elseif info.image then
                local image = art:CreateTexture(nil, "ARTWORK")
                image:SetPoint("TOPLEFT", 1, -1)
                image:SetPoint("BOTTOMRIGHT", -1, 1)
                pcall(image.SetTexture, image, info.image)
            end
            card.art = art
            card.radio = Circle(card, 16, C.radio, "ARTWORK", 1)
            card.hole = Circle(card, 12, C.card, "ARTWORK", 2)
            card.hole:SetPoint("CENTER", card.radio, "CENTER")
            card.badge = Circle(card, 6, C.knobOn, "ARTWORK", 3)
            card.badge:SetPoint("CENTER", card.radio, "CENTER")
            card.title = W.Text(card, info.title, 40, 0, nil, nil, C.bright)
            W.SetFont(card.title, "semibold", 14)
            card.body = W.SetSmall(W.Text(card, info.body, 16, 0, nil, nil, MUTED))
            card.id = info.id
            card:SetScript("OnClick", function()
                if GetBinding(key) ~= info.id then Changed(root, key, info.id, onChanged) end
            end)
            card:SetScript("OnEnter", function(self) self:Paint() end)
            card:SetScript("OnLeave", function(self) self:Paint() end)
            function card:Paint()
                local selected = self.id == GetBinding(key)
                local over = self.IsMouseOver and self:IsMouseOver()
                if selected then
                    W.Backdrop(self, "cardSelected")
                else
                    W.Paint(self, over and C.cardHover or C.card, 10)
                end
                self.radio:SetVertexColor(RGB(selected and GOLD or C.radio))
                self.hole:SetVertexColor(RGB(over and not selected and C.cardHover or C.card))
                self.hole:SetShown(not selected)
                self.badge:SetShown(selected)
                self.title:SetTextColor(RGB(selected and C.bright or C.text))
            end
            row.cards[index] = card
            titles[index] = info.title
        end
        function row:Refresh()
            for _, card in ipairs(self.cards) do card:Paint() end
        end
        -- Lay the cards out across the page width; returns the row height.
        function row:LayoutCards(width)
            local gap, count = 14, #self.cards
            local cardWidth = math.floor((width - gap * (count - 1)) / count)
            local artHeight = 96
            local tallest = 0
            for index, card in ipairs(self.cards) do
                card:ClearAllPoints()
                card:SetPoint("TOPLEFT", (index - 1) * (cardWidth + gap), 0)
                card:SetWidth(cardWidth)
                card.art:ClearAllPoints()
                card.art:SetPoint("TOPLEFT", 6, -6)
                card.art:SetSize(cardWidth - 12, artHeight)
                card.title:SetWidth(cardWidth - 56)
                card.title:ClearAllPoints()
                card.title:SetPoint("TOPLEFT", card, "TOPLEFT", 40, -(artHeight + 20))
                card.radio:ClearAllPoints()
                card.radio:SetPoint("TOPLEFT", card, "TOPLEFT", 16, -(artHeight + 20))
                card.body:ClearAllPoints()
                card.body:SetPoint("TOPLEFT", card, "TOPLEFT", 16, -(artHeight + 28 + card.title:GetStringHeight()))
                card.body:SetWidth(cardWidth - 32)
                tallest = math.max(tallest, artHeight + 44 + card.title:GetStringHeight() + card.body:GetStringHeight())
            end
            for _, card in ipairs(self.cards) do card:SetHeight(tallest) end
            return tallest
        end
        row.label = row.cards[1].title
        self:AddRow(row, row.cards[1].title, "cards")
        local meta = { id = BindingId(key), label = table.concat(titles, " / "), page = pageId, tab = tabId,
            section = self.section, y = self.y }
        row.searchMeta = meta
        root:RegisterControl(row, meta)
        row:Refresh()
        self.y = self.y - row:LayoutCards(self.width)
        return row
    end

    -- Size a setting row to its label, description and control; returns its height.
    local function PlaceControlRow(row, width)
        local caption, control = row.layoutCaption, row.layoutControl
        local controlWidth = ControlWidth(width)
        local controlHeight = CONTROL_HEIGHT
        local textWidth = width - controlWidth - 24
        if control.layoutType == "action" then
            control:SetWidth(math.min(width, math.max(120, control:GetFontString():GetStringWidth() + 32)))
            textWidth = width - control:GetWidth() - 24
            caption:SetWidth(textWidth)
        elseif control.layoutType == "switch" then
            textWidth = width - 40 - 24
            controlHeight = 24
        elseif control.layoutType == "amount" then
            textWidth = width - control:GetWidth() - 24
        elseif control.layoutType == "slider" then
            control:SetWidth(controlWidth - 64)
            controlHeight = 20
        elseif control.layoutType then
            control:SetWidth(controlWidth)
        end
        caption:SetWidth(textWidth)
        local description = row.layoutDescription
        local textHeight = 0
        if caption:IsShown() then textHeight = caption:GetStringHeight() end
        if description and description:IsShown() then
            description:SetWidth(textWidth)
            description:ClearAllPoints()
            local top = ROW_PAD + (textHeight > 0 and textHeight + 4 or 0)
            description:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -top)
            textHeight = top - ROW_PAD + description:GetStringHeight()
        end
        local compact = math.max(row.minimumHeight, ROW_PAD * 2 + math.max(textHeight, controlHeight))
        row.compactHeight = compact
        -- Center the control against short text; on long descriptions, align it to the label.
        local controlY = -math.floor((compact - controlHeight) / 2 + 0.5)
        if textHeight > controlHeight + 28 and caption:IsShown() then
            controlY = -math.floor(ROW_PAD + caption:GetStringHeight() / 2 - controlHeight / 2 + 0.5)
        end
        local described = description and description:IsShown()
        if control.layoutType == "action" and described and not caption:IsShown() then
            -- A lone description reads as the button's label: center the two on one line.
            description:ClearAllPoints()
            description:SetPoint("TOPLEFT", row, "TOPLEFT", 0,
                -math.max(ROW_PAD, math.floor((compact - description:GetStringHeight()) / 2 + 0.5)))
        end
        if control.layoutType == "action" and not described then
            control:ClearAllPoints()
            control:SetPoint("TOPLEFT", row, "TOPLEFT", 0, controlY)
        elseif control.layoutType == "slider" then
            control:ClearAllPoints()
            control:SetPoint("TOPRIGHT", row, "TOPRIGHT", -64, controlY)
            control.valueText:ClearAllPoints()
            control.valueText:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, controlY + 1)
            control.valueText:SetWidth(52)
            control:PaintFill(tonumber(control:GetValue()) or 0)
        else
            control:ClearAllPoints()
            control:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, controlY)
        end
        local height = compact
        if row.layoutReason then
            row.layoutReason:SetWidth(textWidth)
            row.layoutReason:ClearAllPoints()
            row.layoutReason:SetPoint("TOPLEFT", 0, -(compact - ROW_PAD + REASON_GAP))
            if row.layoutReason:IsShown() then
                height = compact + REASON_GAP + math.max(16, row.layoutReason:GetStringHeight())
            end
        end
        return height
    end

    function layout:Reflow()
        local y = TOP
        for _, row in ipairs(self.rows) do
            local visible = not row.isVisible or row.isVisible()
            row:SetShown(visible)
            if visible then
                y = y - row.layoutGap
                local caption = row.layoutCaption
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", self.x, y)
                row:SetWidth(self.width)
                local height
                if row.layoutKind == "heading" then
                    caption:SetWidth(self.width)
                    height = math.max(24, caption:GetStringHeight() + 12)
                elseif row.layoutKind == "note" then
                    caption:SetWidth(self.width)
                    height = math.max(16, caption:GetStringHeight()) + 12
                elseif row.layoutKind == "warning" then
                    caption:SetWidth(self.width - 54)
                    height = math.max(18, caption:GetStringHeight()) + 24
                elseif row.layoutKind == "cards" then
                    height = row:LayoutCards(self.width)
                    row.searchMeta.y = y
                else
                    height = PlaceControlRow(row, self.width)
                    row.layoutControl.searchMeta.y = y
                end
                row:SetHeight(height)
                y = y - height - (row.layoutKind == "warning" and 10 or 0)
            end
        end
        self.y = y
        parent:SetHeight(math.max(1, -y + 24))
        if parent.UpdateScrollBar then parent:UpdateScrollBar() end
        return -y + 24
    end

    function layout:Finish()
        if not self.finished then
            self.finished = true
            root.refreshers = root.refreshers or {}
            root.refreshers[#root.refreshers + 1] = function() self:Reflow() end
            -- Resizing the settings window changes the page width: rewrap every row to it.
            -- Reflow only changes the page height, so it cannot retrigger this.
            parent:HookScript("OnSizeChanged", function(_, width)
                local newWidth = math.max(200, (width or 0) - PAD_LEFT - PAD_RIGHT)
                if width and width > 0 and math.abs(newWidth - self.width) >= 1 then
                    self.width = newWidth
                    self:Reflow()
                end
            end)
        end
        return self:Reflow()
    end
    return layout
end
