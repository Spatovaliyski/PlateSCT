local _, BD = ...
local W = {}
BD.OptionsWidgets = W

local GOLD = { 0.88, 0.72, 0.43 }
local TEXT = { 0.88, 0.86, 0.80 }
local MUTED = { 0.60, 0.60, 0.57 }
local WHITE = "Interface\\Buttons\\WHITE8X8"
local GLASS = "Interface\\DialogFrame\\UI-DialogBox-Background"
local CONTROL_WIDTH = 220

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

local ACTION_FACES = {
    idle = {
        bg = { 0.11, 0.09, 0.065, 1 },
        border = { 0.78, 0.62, 0.34, 1 },
        top = { 0.16, 0.13, 0.09, 1 },
        bottom = { 0.07, 0.055, 0.04, 1 },
        line = { 0.88, 0.72, 0.43, 0.18 },
        text = GOLD,
    },
    hover = {
        bg = { 0.17, 0.13, 0.09, 1 },
        border = { 0.96, 0.82, 0.50, 1 },
        top = { 0.24, 0.18, 0.12, 1 },
        bottom = { 0.10, 0.075, 0.05, 1 },
        line = { 0.96, 0.84, 0.55, 0.32 },
        text = { 1, 0.90, 0.62 },
    },
    down = {
        bg = { 0.06, 0.048, 0.034, 1 },
        border = { 0.58, 0.44, 0.24, 1 },
        top = { 0.08, 0.062, 0.042, 1 },
        bottom = { 0.045, 0.035, 0.025, 1 },
        line = { 0.45, 0.34, 0.18, 0.1 },
        text = { 0.70, 0.56, 0.32 },
    },
    selected = {
        bg = { 0.18, 0.13, 0.07, 1 },
        border = { 0.94, 0.78, 0.44, 1 },
        top = { 0.26, 0.19, 0.10, 1 },
        bottom = { 0.11, 0.08, 0.045, 1 },
        line = { 0.96, 0.82, 0.48, 0.35 },
        text = { 1, 0.88, 0.58 },
    },
}

local function PaintGradient(texture, bottom, top)
    if texture.SetGradientAlpha then
        texture:SetGradientAlpha("VERTICAL", bottom[1], bottom[2], bottom[3], bottom[4],
            top[1], top[2], top[3], top[4])
    elseif texture.SetGradient and CreateColor then
        texture:SetGradient("VERTICAL", CreateColor(unpack(bottom)), CreateColor(unpack(top)))
    else
        texture:SetColorTexture(top[1], top[2], top[3], 1)
    end
end

local function EnsureActionFace(frame)
    if frame.optionsActionFill then return end
    local fill = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    fill:SetPoint("TOPLEFT", 1, -1)
    fill:SetPoint("BOTTOMRIGHT", -1, 1)
    fill:SetTexture(WHITE)
    frame.optionsActionFill = fill
    local sheen = frame:CreateTexture(nil, "ARTWORK", nil, 1)
    sheen:SetPoint("TOPLEFT", 2, -2)
    sheen:SetPoint("TOPRIGHT", -2, -2)
    sheen:SetHeight(1)
    frame.optionsActionSheen = sheen
    local lip = frame:CreateTexture(nil, "ARTWORK", nil, 1)
    lip:SetPoint("BOTTOMLEFT", 2, 2)
    lip:SetPoint("BOTTOMRIGHT", -2, 2)
    lip:SetHeight(1)
    frame.optionsActionLip = lip
end

local function HideActionFace(frame)
    if not frame.optionsActionFill then return end
    frame.optionsActionFill:Hide()
    frame.optionsActionSheen:Hide()
    frame.optionsActionLip:Hide()
end

function W.PaintAction(frame, mode)
    local face = ACTION_FACES[mode] or ACTION_FACES.idle
    EnsureActionFace(frame)
    frame:SetBackdropColor(unpack(face.bg))
    frame:SetBackdropBorderColor(unpack(face.border))
    PaintGradient(frame.optionsActionFill, face.bottom, face.top)
    frame.optionsActionFill:Show()
    frame.optionsActionSheen:SetColorTexture(unpack(face.line))
    frame.optionsActionSheen:Show()
    frame.optionsActionLip:SetColorTexture(0, 0, 0, mode == "down" and 0.15 or 0.35)
    frame.optionsActionLip:Show()
    local font = frame:GetFontString()
    if font and face.text then font:SetTextColor(unpack(face.text)) end
end

function W.Backdrop(frame, kind)
    if not frame.SetBackdrop and BackdropTemplateMixin and Mixin then
        Mixin(frame, BackdropTemplateMixin)
    end
    if not frame.SetBackdrop then return end
    local background = { 0.035, 0.033, 0.030, 1 }
    local border = { 0.36, 0.28, 0.17, 0.9 }
    if kind == "control" or kind == "button" then
        background = { 0.07, 0.065, 0.052, 1 }
        border = { 0.42, 0.33, 0.21, 0.9 }
    elseif kind == "action" then
        background = ACTION_FACES.idle.bg
        border = ACTION_FACES.idle.border
    elseif kind == "selected" then
        background = { 0.14, 0.105, 0.053, 1 }
        border = { GOLD[1], GOLD[2], GOLD[3], 0.85 }
    elseif kind == "row" then
        background = { 0.12, 0.105, 0.080, 0.82 }
        border = { 0.45, 0.35, 0.20, 0.08 }
    elseif kind == "window" then
        background = { 0.15, 0.14, 0.13, 1 }
        border = { 0.53, 0.41, 0.24, 0.98 }
    elseif kind == "inset" then
        background = { 0.12, 0.11, 0.10, 1 }
        border = { 0.35, 0.28, 0.19, 0.65 }
    end
    frame.optionsBackdropKind = kind
    frame:SetBackdrop({
        bgFile = (kind == "window" or kind == "inset") and GLASS or WHITE,
        tile = kind == "window" or kind == "inset", tileSize = 64,
        edgeFile = WHITE, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(unpack(background))
    frame:SetBackdropBorderColor(unpack(border))
    if frame.optionsStyle == "action" and (kind == "action" or kind == "selected") then
        W.PaintAction(frame, kind == "selected" and "selected" or "idle")
    else
        HideActionFace(frame)
    end
    if kind == "window" or kind == "inset" then
        -- Blizzard's glass texture contains transparency even at full backdrop alpha.
        if not frame.optionsBacking then
            local backing = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
            backing:SetPoint("TOPLEFT", 1, -1)
            backing:SetPoint("BOTTOMRIGHT", -1, 1)
            frame.optionsBacking = backing
        end
        frame.optionsBacking:SetColorTexture(background[1], background[2], background[3], 1)
        if not frame.optionsSheen then
            local sheen = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
            sheen:SetPoint("TOPLEFT", 1, -1)
            sheen:SetPoint("TOPRIGHT", -1, -1)
            sheen:SetHeight(kind == "window" and 76 or 36)
            sheen:SetTexture(WHITE)
            if sheen.SetGradientAlpha then
                sheen:SetGradientAlpha("VERTICAL", GOLD[1], GOLD[2], GOLD[3], 0,
                    GOLD[1], GOLD[2], GOLD[3], 0.055)
            elseif sheen.SetGradient and CreateColor then
                sheen:SetGradient("VERTICAL", CreateColor(GOLD[1], GOLD[2], GOLD[3], 0),
                    CreateColor(GOLD[1], GOLD[2], GOLD[3], 0.055))
            else
                sheen:SetVertexColor(GOLD[1], GOLD[2], GOLD[3], 0.035)
            end
            frame.optionsSheen = sheen
        end
    end
end

function W.Text(parent, text, x, y, width, template, color)
    local label = parent:CreateFontString(nil, "ARTWORK", template or "GameFontHighlight")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", x or 0, y or 0)
    if width then label:SetWidth(width) end
    label:SetJustifyH("LEFT")
    label:SetJustifyV("TOP")
    label:SetSpacing(3)
    label:SetWordWrap(true)
    label:SetText(text or "")
    label:SetTextColor(unpack(color or TEXT))
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

function W.Button(parent, label, width, height, onClick, style)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width or 160, height or 28)
    local face = style == "flat" and "control" or "action"
    button.optionsStyle = style == "flat" and "flat" or "action"
    W.Backdrop(button, face)
    local fontObject = "GameFontNormal"
    local font = button:CreateFontString(nil, "OVERLAY", fontObject)
    button:SetFontString(font)
    button:SetNormalFontObject(fontObject)
    button:SetHighlightFontObject(face == "action" and "GameFontNormal" or "GameFontHighlight")
    button:SetDisabledFontObject("GameFontDisable")
    button:SetText(label or "")
    font:ClearAllPoints()
    font:SetPoint("LEFT", 8, 0)
    font:SetPoint("RIGHT", -8, 0)
    font:SetJustifyH(face == "action" and "CENTER" or "LEFT")
    font:SetWordWrap(false)
    if face == "action" then font:SetTextColor(unpack(GOLD)) end
    W.Tooltip(button, function(self) return self:GetText() end)
    if face == "action" then
        local function RestoreFace(self)
            local mode = self.optionsBackdropKind == "selected" and "selected" or "idle"
            if self:IsEnabled() and self.IsMouseOver and self:IsMouseOver() then mode = "hover" end
            W.PaintAction(self, mode)
        end
        Hook(button, "OnEnter", function(self)
            if not self:IsEnabled() then return end
            W.PaintAction(self, "hover")
        end)
        Hook(button, "OnLeave", RestoreFace)
        Hook(button, "OnMouseDown", function(self)
            if not self:IsEnabled() then return end
            W.PaintAction(self, "down")
            local labelFont = self:GetFontString()
            if labelFont then
                labelFont:ClearAllPoints()
                labelFont:SetPoint("LEFT", 8, -1)
                labelFont:SetPoint("RIGHT", -8, -1)
            end
        end)
        Hook(button, "OnMouseUp", function(self)
            local labelFont = self:GetFontString()
            if labelFont then
                labelFont:ClearAllPoints()
                labelFont:SetPoint("LEFT", 8, 0)
                labelFont:SetPoint("RIGHT", -8, 0)
            end
            RestoreFace(self)
        end)
    else
        button:SetHighlightTexture(WHITE)
        local highlight = button:GetHighlightTexture()
        if highlight then highlight:SetVertexColor(GOLD[1], GOLD[2], GOLD[3], 0.13) end
        button:SetPushedTexture(WHITE)
        local pushed = button:GetPushedTexture()
        if pushed then pushed:SetVertexColor(GOLD[1], GOLD[2], GOLD[3], 0.23) end
    end
    button:SetScript("OnClick", function(self, ...)
        if self:IsEnabled() and onClick then onClick(self, ...) end
    end)
    return button
end

function W.CloseButton(parent, onClick)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(24, 24)
    local font = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    font:SetPoint("CENTER", 0, 1)
    font:SetText("×")
    font:SetTextColor(unpack(TEXT))
    button.label = font
    button:SetScript("OnEnter", function(self)
        self.label:SetTextColor(unpack(GOLD))
    end)
    button:SetScript("OnLeave", function(self)
        self.label:SetTextColor(unpack(TEXT))
    end)
    button:SetScript("OnClick", function(self, ...)
        if onClick then onClick(self, ...) end
    end)
    return button
end

function W.EditBox(parent, width, height)
    local box = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
    box:SetSize(width or CONTROL_WIDTH, height or 26)
    box:SetAutoFocus(false)
    W.Backdrop(box, "control")
    box:SetFontObject("GameFontHighlight")
    box:SetTextInsets(8, 8, 0, 0)
    box:SetJustifyH("LEFT")
    box:SetTextColor(unpack(TEXT))
    return box
end

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
    control.label:SetTextColor(unpack(available and TEXT or MUTED))
    if control.layoutType == "input" then
        control:SetTextColor(unpack(available and TEXT or MUTED))
    end
    if control.reason then
        local reason = Evaluate(control.disabledReason, control)
        control.reason:SetText(not available and reason or "")
        control.reason:SetShown(not available and reason and reason ~= "")
    end
    if not available and control.menu and control.menu:IsShown() then
        control.menu:Hide()
    end
    return available
end

local function OptionsFor(control)
    if control.binding == "fontFace" and BD.GetFontFaceOptions then
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
        text = text .. " |cffdec080(" .. Localize("Recommended") .. ")|r"
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
    if not menu.owner or menu.owner.binding ~= "fontFace" or not menu:IsShown() then return end
    if GameTooltip then GameTooltip:Hide() end
    local preview = menu.fontPreview
    if not preview then
        preview = CreateFrame("Frame", nil, menu, "BackdropTemplate")
        preview:SetFrameStrata("TOOLTIP")
        preview:SetFrameLevel(menu:GetFrameLevel() + 4)
        preview:SetClampedToScreen(true)
        preview:EnableMouse(false)
        W.Backdrop(preview, "window")
        preview.label = W.Text(preview, "", 12, -10, nil, "GameFontNormal", TEXT)
        preview.label:SetWordWrap(false)
        preview.number = preview:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
        preview.number:SetPoint("TOPLEFT", 12, -32)
        preview.number:SetWordWrap(false)
        menu.fontPreview = preview
    end
    local preset = BD:GetStylePreset()
    local size = (BD.db.fontSize or BD.DEFAULTS.fontSize) * preset.fontScale
    BD.SafeSetFont(preview.number, BD.ResolveFontPath(entry.optionId), size, preset.fontFlags)
    local shadow = preset.shadowOffset
    preview.number:SetShadowOffset(shadow and shadow[1] or 0, shadow and shadow[2] or 0)
    preview.number:SetShadowColor(0, 0, 0, 1)
    preview.number:SetTextColor(unpack(preset.defaultColor))
    preview.number:SetText("12345")
    preview.label:SetWidth(0)
    preview.label:SetText(entry:GetText())
    local width = math.max(100, preview.label:GetStringWidth(), preview.number:GetStringWidth()) + 24
    local screenWidth = UIParent:GetWidth() * UIParent:GetEffectiveScale() / preview:GetEffectiveScale()
    width = math.min(width, math.max(100, screenWidth - 24))
    preview.label:SetWidth(width - 24)
    preview:SetSize(width, 44 + math.max(size, preview.number:GetStringHeight()))
    preview:ClearAllPoints()
    preview:SetPoint("TOPLEFT", entry, "TOPRIGHT", 8, 0)
    preview.owner = entry
    preview:Show()
end

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
    W.Backdrop(menu, "window")
    menu.entries = {}
    menu.layer = layer
    local scroll = CreateFrame("ScrollFrame", nil, menu)
    scroll:SetPoint("TOPLEFT", 5, -5)
    scroll:SetPoint("BOTTOMRIGHT", -14, 5)
    scroll:EnableMouseWheel(true)
    local child = CreateFrame("Frame", nil, scroll)
    scroll:SetScrollChild(child)
    menu.scroll = scroll
    menu.child = child
    local track = menu:CreateTexture(nil, "ARTWORK")
    track:SetPoint("TOPRIGHT", -5, -6)
    track:SetPoint("BOTTOMRIGHT", -5, 6)
    track:SetWidth(3)
    track:SetColorTexture(0.42, 0.33, 0.20, 0.25)
    local thumb = menu:CreateTexture(nil, "OVERLAY")
    thumb:SetWidth(3)
    thumb:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.85)
    menu.thumb = thumb
    local function UpdateThumb()
        HideFontPreview(menu)
        local full = child:GetHeight()
        local view = scroll:GetHeight()
        local maximum = math.max(0, full - view)
        if maximum <= 0 or view <= 0 then thumb:Hide(); return end
        local height = math.max(18, view * view / full)
        thumb:ClearAllPoints()
        thumb:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -5, -5 - (view - height) * scroll:GetVerticalScroll() / maximum)
        thumb:SetHeight(height)
        thumb:Show()
    end
    local function MouseWheel(_, delta)
        local maximum = math.max(0, child:GetHeight() - scroll:GetHeight())
        scroll:SetVerticalScroll(math.max(0, math.min(maximum, scroll:GetVerticalScroll() - delta * 28)))
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
        if self.owner then W.Backdrop(self.owner, "control") end
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
            entry = W.Button(menu.child, "", width - 20, 28, nil, "flat")
            entry:SetNormalFontObject("GameFontHighlight")
            entry:EnableMouseWheel(true)
            entry:SetScript("OnMouseWheel", menu.MouseWheel)
            local font = entry:GetFontString()
            font:SetPoint("LEFT", 9, 0)
            font:SetPoint("RIGHT", -9, 0)
            font:SetJustifyH("LEFT")
            font:SetWordWrap(false)
            Hook(entry, "OnEnter", function(self) ShowFontPreview(menu, self) end)
            Hook(entry, "OnLeave", function(self) HideFontPreview(menu, self) end)
            Hook(entry, "OnHide", function(self) HideFontPreview(menu, self) end)
            menu.entries[index] = entry
        end
        entry.optionId = option.id
        entry:SetText(OptionDisplay(option))
        W.Backdrop(entry, option.id == selected and "selected" or "row")
        entry:GetFontString():SetTextColor(unpack(option.id == selected and GOLD or TEXT))
        local optionId = option.id
        entry:SetScript("OnClick", function()
            menu:Hide()
            if control:IsEnabled() then Changed(root, control.binding, optionId, control.onChanged) end
        end)
        entry:ClearAllPoints()
        entry:SetPoint("TOPLEFT", 0, -(index - 1) * 28)
        entry:Show()
        width = math.max(width, (entry:GetFontString():GetStringWidth() or 0) + 36)
    end
    -- Clamp long translations while preserving a useful viewport on small UI scales.
    local screenScale = root:GetScale()
    width = math.min(width, math.max(CONTROL_WIDTH, UIParent:GetWidth() / screenScale - 40))
    local fullHeight = math.max(28, #options * 28)
    local viewHeight = math.min(fullHeight, 300, math.max(56, UIParent:GetHeight() / screenScale - 80))
    menu:SetSize(width, viewHeight + 10)
    menu.child:SetSize(width - 19, fullHeight)
    for _, entry in ipairs(menu.entries) do entry:SetWidth(width - 19) end
    menu:ClearAllPoints()
    local bottom = control:GetBottom()
    if bottom and bottom < viewHeight + 24 then
        menu:SetPoint("BOTTOMLEFT", control, "TOPLEFT", 0, 4)
    else
        menu:SetPoint("TOPLEFT", control, "BOTTOMLEFT", 0, -4)
    end
    root.transientMenu = menu
    root.pageScrollLocked = true
    W.Backdrop(control, "selected")
    menu.layer:Show()
    menu:Show()
    menu.scroll:SetVerticalScroll(0)
    -- Keep the current font/choice in view when lists exceed the popup viewport.
    for index, option in ipairs(options) do
        if option.id == selected then
            menu.scroll:SetVerticalScroll(math.min(math.max(0, fullHeight - viewHeight), (index - 1) * 28))
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

function W.NewLayout(parent, root, pageId, tabId, width)
    local layout = { parent = parent, root = root, page = pageId, tab = tabId, x = 16, y = -16,
        width = math.max(200, (width or parent:GetWidth()) - 32), rows = {} }
    parent.rows = layout.rows

    function layout:Gap(amount)
        amount = amount or 14
        self.pendingGap = (self.pendingGap or 0) + amount
        self.y = self.y - amount
    end

    function layout:AddRow(row, caption, kind)
        row.layoutCaption, row.layoutKind = caption, kind
        row.layoutGap = self.pendingGap or 0
        self.pendingGap = nil
        self.rows[#self.rows + 1] = row
    end

    function layout:When(predicate, build)
        local first = #self.rows + 1
        build(self)
        for index = first, #self.rows do
            self.rows[index].isVisible = predicate
        end
    end

    function layout:Heading(text)
        if #self.rows > 0 then self:Gap(14) end
        self.section = text
        local row = CreateFrame("Frame", nil, parent)
        row:SetSize(self.width, 28)
        row:SetPoint("TOPLEFT", self.x, self.y)
        local label = W.Text(row, text, 0, -2, self.width, "GameFontNormal", GOLD)
        local line = row:CreateTexture(nil, "ARTWORK")
        line:SetPoint("BOTTOMLEFT", 0, 2)
        line:SetPoint("BOTTOMRIGHT", 0, 2)
        line:SetHeight(1)
        line:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.23)
        self:AddRow(row, label, "heading")
        self.y = self.y - math.max(32, label:GetStringHeight() + 12)
        return label
    end

    function layout:Note(text)
        local previous = self.rows[#self.rows]
        if previous and previous.layoutKind == "heading" then self:Gap(8) end
        local row = CreateFrame("Frame", nil, parent)
        row:SetPoint("TOPLEFT", self.x + 8, self.y)
        row:SetWidth(self.width - 16)
        local label = W.Text(row, text, 0, -2, self.width - 16, "GameFontHighlightSmall", MUTED)
        local height = math.max(16, label:GetStringHeight()) + 12
        row:SetHeight(height)
        label.row = row
        self:AddRow(row, label, "note")
        self.y = self.y - height
        return label
    end

    function layout:NewRow(label, minimum, disabledReason)
        local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        row:SetWidth(self.width)
        row:SetPoint("TOPLEFT", self.x, self.y)
        row:EnableMouse(true)
        W.Backdrop(row, "row")
        local controlWidth = math.min(CONTROL_WIDTH, math.floor(self.width * 0.44))
        local caption = W.Text(row, label, 10, -10, self.width - controlWidth - 36)
        local height = math.max(minimum or 40, caption:GetStringHeight() + 20)
        local reason
        if disabledReason then
            reason = W.Text(row, Evaluate(disabledReason) or "", 10, -height, self.width - 20, "GameFontHighlightSmall", MUTED)
        end
        row:SetHeight(height)
        row.minimumHeight, row.layoutReason = minimum or 40, reason
        self:AddRow(row, caption, "control")
        local y = self.y
        self.y = self.y - height - 3
        return row, caption, reason, controlWidth, y
    end

    function layout:Register(control, binding, row, caption, reason, y, tip, enabled, onChanged, disabledReason)
        control.row, control.label, control.reason = row, caption, reason
        row.layoutControl = control
        control.binding, control.isEnabled, control.onChanged = binding, enabled, onChanged
        control.disabledReason = disabledReason
        W.Tooltip(row, function()
            local description = Evaluate(tip, control) or ""
            local why = control.isEnabled and not control.isEnabled() and Evaluate(disabledReason, control)
            if why and why ~= "" then description = description ~= "" and (description .. "\n\n" .. why) or why end
            return description
        end)
        W.Tooltip(control, function()
            local description = Evaluate(tip, control) or ""
            local why = control.isEnabled and not control.isEnabled() and Evaluate(disabledReason, control)
            if why and why ~= "" then description = description ~= "" and (description .. "\n\n" .. why) or why end
            return description
        end)
        local meta = { id = BindingId(binding), label = caption:GetText(), tip = Evaluate(tip, control),
            page = pageId, tab = tabId, section = self.section, y = y }
        control.searchMeta = meta
        root:RegisterControl(control, meta)
        return control
    end

    function layout:Checkbox(key, label, tip, enabledPredicate, onChanged, disabledReason)
        local row, caption, reason, _, y = self:NewRow(label, 40, disabledReason)
        local control = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        control:SetSize(26, 26)
        control:SetPoint("TOPRIGHT", -10, -7)
        if control.Text then control.Text:Hide() end
        self:Register(control, key, row, caption, reason, y, tip, enabledPredicate, onChanged, disabledReason)
        control:SetScript("OnClick", function(self)
            if self:IsEnabled() then Changed(root, key, self:GetChecked() and true or false, onChanged) end
        end)
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
        local row, caption, reason, controlWidth, y = self:NewRow(label, 56, disabledReason)
        local control = CreateFrame("Slider", nil, row, "MinimalSliderTemplate")
        control:SetSize(controlWidth - 8, 18)
        control:SetPoint("TOPRIGHT", -14, -29)
        control:SetMinMaxValues(minimum, maximum)
        control:SetValueStep(step)
        if control.SetObeyStepOnDrag then control:SetObeyStepOnDrag(true) end
        control:EnableMouseWheel(true)
        local valueText = W.Text(row, "", self.width - controlWidth - 8, -8, controlWidth, "GameFontNormal", GOLD)
        valueText:SetJustifyH("RIGHT")
        control.valueText = valueText
        control.layoutType = "slider"
        self:Register(control, key, row, caption, reason, y, nil, enabledPredicate, onChanged, disabledReason)
        local function Normalize(value)
            value = math.max(minimum, math.min(maximum, value))
            local rounded = minimum + math.floor((value - minimum) / step + 0.5) * step
            return math.max(minimum, math.min(maximum, rounded))
        end
        local function Display(value)
            valueText:SetText(formatter and formatter(value) or tostring(value))
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
        local row, caption, reason, controlWidth, y = self:NewRow(label, 40, disabledReason)
        local control = W.Button(row, "", controlWidth, 26, nil, "flat")
        control.layoutType = "choice"
        control:SetPoint("TOPRIGHT", -10, -7)
        local font = control:GetFontString()
        font:SetPoint("LEFT", 9, 0)
        font:SetPoint("RIGHT", -23, 0)
        font:SetJustifyH("LEFT")
        font:SetWordWrap(false)
        local arrow = control:CreateTexture(nil, "OVERLAY")
        arrow:SetSize(13, 13)
        arrow:SetPoint("RIGHT", -7, 0)
        arrow:SetTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
        arrow:SetTexCoord(0.2, 0.8, 0.2, 0.8)
        control.options = options
        self:Register(control, key, row, caption, reason, y, tip, enabledPredicate, onChanged, disabledReason)
        control:SetScript("OnClick", function() OpenMenu(control, root) end)
        Hook(control, "OnHide", function() if control.menu then control.menu:Hide() end end)
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

    function layout:Input(key, label, tip, onChanged, enabledPredicate, disabledReason)
        local row, caption, reason, controlWidth, y = self:NewRow(label, 40, disabledReason)
        local control = W.EditBox(row, controlWidth, 26)
        control:SetPoint("TOPRIGHT", -10, -7)
        control:SetMaxLetters(12)
        control:SetNumeric(false)
        control.layoutType = "input"
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
        control:SetScript("OnEditFocusGained", function(self)
            W.Backdrop(self, "selected")
        end)
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

    function layout:Action(id, label, tip, callback)
        local row, caption, _, controlWidth, y = self:NewRow(label, 40)
        local control = W.Button(row, label, controlWidth, 26, function()
            root:DismissTransient()
            if callback then callback() end
            root:Refresh()
        end)
        caption:Hide()
        control:SetPoint("TOPRIGHT", -10, -7)
        control.layoutType = "action"
        self:Register(control, id, row, caption, nil, y, tip)
        function control:Refresh() end
        return control
    end

    function layout:Reflow()
        local y = -16
        for _, row in ipairs(self.rows) do
            local visible = not row.isVisible or row.isVisible()
            row:SetShown(visible)
            if visible then
                y = y - row.layoutGap
                local caption, control = row.layoutCaption, row.layoutControl
                local indent = row.layoutKind == "note" and 8 or 0
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", self.x + indent, y)
                row:SetWidth(self.width - indent * 2)
                local height
                if row.layoutKind == "heading" then
                    caption:SetWidth(self.width)
                    height = math.max(32, caption:GetStringHeight() + 12)
                elseif row.layoutKind == "note" then
                    caption:SetWidth(self.width - 16)
                    height = math.max(16, caption:GetStringHeight()) + 12
                else
                    local controlWidth = math.min(CONTROL_WIDTH, math.floor(self.width * 0.44))
                    if control.layoutType == "action" then
                        controlWidth = math.min(self.width - 20,
                            math.max(controlWidth, control:GetFontString():GetStringWidth() + 16))
                        caption:SetWidth(self.width - 20)
                    else
                        caption:SetWidth(self.width - controlWidth - 36)
                    end
                    height = math.max(row.minimumHeight, caption:GetStringHeight() + 20)
                    if control.layoutType == "slider" then
                        control.valueText:SetWidth(controlWidth)
                        local readoutHeight = math.max(14, control.valueText:GetStringHeight())
                        control:ClearAllPoints()
                        control:SetPoint("TOPRIGHT", -14, -15 - readoutHeight)
                        control:SetWidth(controlWidth - 8)
                        height = math.max(height, readoutHeight + 42)
                    elseif control.layoutType then
                        control:SetWidth(controlWidth)
                    end
                    if row.layoutReason then
                        row.layoutReason:SetWidth(self.width - 20)
                        row.layoutReason:ClearAllPoints()
                        row.layoutReason:SetPoint("TOPLEFT", 10, -height)
                        if row.layoutReason:IsShown() then
                            height = height + math.max(16, row.layoutReason:GetStringHeight()) + 8
                        end
                    end
                    control.searchMeta.y = y
                end
                row:SetHeight(height)
                y = y - height - (row.layoutKind == "control" and 3 or 0)
            end
        end
        self.y = y
        parent:SetHeight(math.max(1, -y + 16))
        if parent.UpdateScrollBar then parent:UpdateScrollBar() end
        return -y + 16
    end

    function layout:Finish()
        if not self.finished then
            self.finished = true
            root.refreshers = root.refreshers or {}
            root.refreshers[#root.refreshers + 1] = function() self:Reflow() end
            -- Resizing the settings window changes the page width: rewrap every row to it.
            -- Reflow only changes the page height, so it cannot retrigger this.
            parent:HookScript("OnSizeChanged", function(_, width)
                local newWidth = math.max(200, (width or 0) - 32)
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
