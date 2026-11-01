local ADDON_NAME, BD = ...
local L, W = BD.L, BD.OptionsWidgets

local WINDOW_WIDTH, WINDOW_HEIGHT = 840, 640
local SIDEBAR_WIDTH, HEADER_HEIGHT = 200, 64
local BAR_HEIGHT, STAGE_HEIGHT = 44, 176
-- Previews are never smaller than this, whatever the style or layout.
local PREVIEW_SCALE, AREA_EDGE_INSET = 0.7, 4
local C = W.COLORS or {}
local GOLD = C.accent or { 0.85, 0.68, 0.37 }
local PAGE_ICONS = {
    general = "General", combat = "Combat", appearance = "Appearance", animation = "Animation",
    placement = "Placement", sounds = "Sounds", modern = "Modern",
    help = "Help", diagnostics = "Diagnostics", transfer = "Transfer",
}
local session = { page = "general", tabs = {}, scroll = {} }

-- Lua 5.1's lower() only folds ASCII. Keep search usable in the supported locales.
local searchCase = {}
local function AddSearchCase(upper, lower)
    local uppercase, lowercase = {}, {}
    for char in upper:gmatch("[%z\1-\127\194-\244][\128-\191]*") do uppercase[#uppercase + 1] = char end
    for char in lower:gmatch("[%z\1-\127\194-\244][\128-\191]*") do lowercase[#lowercase + 1] = char end
    for index, char in ipairs(uppercase) do searchCase[char] = lowercase[index] end
end
AddSearchCase("ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝŸŒ", "àáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿœ")
AddSearchCase("АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ", "абвгдеёжзийклмнопрстуфхцчшщъыьэюя")
local function SearchText(text)
    -- Folding individual ASCII letters avoids C-locale conversion corrupting UTF-8 bytes.
    return ((text or ""):gsub("[A-Z]", string.lower):gsub("[%z\1-\127\194-\244][\128-\191]*", searchCase))
end

StaticPopupDialogs["PLATESCT_RESET_CONFIRM"] = {
    text = L["Reset PlateSCT settings to defaults?"],
    button1 = YES, button2 = NO,
    OnAccept = function() BD:ResetToDefaults() end,
    timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}

local function Version()
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or ""
    end
    return GetAddOnMetadata and GetAddOnMetadata(ADDON_NAME, "Version") or ""
end

local function FlavorLabel()
    if BD.API.IsModern() then return L["Modern API - Midnight & Forever"] end
    if BD.API.IsClassic() then return L["Classic API - Era/TBC/Wrath/MoP"] end
    return L["Unsupported client - combat text unavailable"]
end

local function StopMotion(frame)
    frame.highlightGeneration = (frame.highlightGeneration or 0) + 1
    for _, group in ipairs(frame.motionGroups) do group:Stop() end
    for _, target in ipairs(frame.motionTargets) do target:SetAlpha(1) end
    if frame.views then
        for _, view in pairs(frame.views) do
            if view.motionActive then view:ResetMotion() end
        end
    end
    frame:SetAlpha(1)
    if frame.searchHighlight then frame.searchHighlight:Hide() end
end

local function EaseOut(t)
    return 1 - (1 - t) * (1 - t) * (1 - t)
end

-- Slight overshoot so the page settles instead of stopping dead.
local function EaseOutBack(t)
    local u, c1, c3 = t - 1, 1.35, 2.35
    return 1 + c3 * u * u * u + c1 * u * u
end

local function PlaceView(view, x, y)
    view:ClearAllPoints()
    view:SetPoint("TOPLEFT", x, y)
    view:SetPoint("BOTTOMRIGHT", x, y)
end

local function ResetViewMotion(view)
    view.motionActive = nil
    view:SetScript("OnUpdate", nil)
    view:ClearAllPoints()
    view:SetAllPoints()
    view:SetAlpha(1)
end

local function Reveal(frame, view, ox, oy)
    if not BD.db.settingsAnimations then return end
    ox, oy = ox or 0, oy or -28
    view.motionActive = true
    view.ResetMotion = ResetViewMotion
    local elapsedTotal, duration = 0, 0.28
    view:SetAlpha(0)
    PlaceView(view, ox, oy)
    view:SetScript("OnUpdate", function(self, elapsed)
        if not self.motionActive then return end
        elapsedTotal = elapsedTotal + elapsed
        local t = elapsedTotal / duration
        if t >= 1 then
            self:ResetMotion()
            return
        end
        local e = EaseOutBack(math.min(1, t))
        self:SetAlpha(math.min(1, EaseOut(t)))
        PlaceView(self, ox * (1 - e), oy * (1 - e))
    end)
end

local function Dismiss(view, ox, oy)
    view.motionActive = true
    view.ResetMotion = ResetViewMotion
    local elapsedTotal, duration = 0, 0.2
    view:SetAlpha(1)
    PlaceView(view, 0, 0)
    view:SetScript("OnUpdate", function(self, elapsed)
        if not self.motionActive then return end
        elapsedTotal = elapsedTotal + elapsed
        local t = elapsedTotal / duration
        if t >= 1 then
            self:ResetMotion()
            self:Hide()
            return
        end
        local e = EaseOut(math.min(1, t))
        self:SetAlpha(1 - e)
        PlaceView(self, ox * e, oy * e)
    end)
end

local function CreateScrollView(parent, root)
    local host = CreateFrame("Frame", nil, parent)
    host:SetAllPoints(); host:Hide()
    local scroll = CreateFrame("ScrollFrame", nil, host)
    scroll:SetPoint("TOPLEFT"); scroll:SetPoint("BOTTOMRIGHT", -18, 0)
    scroll:EnableMouseWheel(true)
    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(598, 1)
    scroll:SetScrollChild(child)
    child.GetRootPanel = function() return root end
    local track = CreateFrame("Frame", nil, host)
    track:SetWidth(8); track:SetPoint("TOPRIGHT", -4, -8); track:SetPoint("BOTTOMRIGHT", -4, 8)
    track:EnableMouse(true); track:EnableMouseWheel(true)
    local thumb = CreateFrame("Button", nil, track)
    thumb:SetWidth(6); thumb:RegisterForDrag("LeftButton")
    W.Paint(thumb, C.edge, 3)
    thumb:SetScript("OnEnter", function(self) W.Paint(self, C.radio, 3) end)
    thumb:SetScript("OnLeave", function(self) W.Paint(self, C.edge, 3) end)
    local function MaxScroll() return math.max(0, child:GetHeight() - scroll:GetHeight()) end
    local function Update()
        local maximum, height = MaxScroll(), track:GetHeight()
        local position = math.min(maximum, math.max(0, scroll:GetVerticalScroll()))
        if position ~= scroll:GetVerticalScroll() then scroll:SetVerticalScroll(position) end
        track:SetShown(maximum > 0 and height > 0)
        if maximum <= 0 or height <= 0 then return end
        local size = math.min(height, math.max(28, height * scroll:GetHeight() / child:GetHeight()))
        thumb:SetHeight(size); thumb:ClearAllPoints()
        thumb:SetPoint("TOP", track, "TOP", 0, -(height - size) * position / maximum)
    end
    local function SetScroll(value)
        scroll:SetVerticalScroll(math.min(MaxScroll(), math.max(0, value)))
        Update()
    end
    local function Wheel(_, delta)
        if root.pageScrollLocked then return end
        SetScroll(scroll:GetVerticalScroll() - delta * 40)
    end
    scroll:SetScript("OnMouseWheel", Wheel)
    child:EnableMouseWheel(true); child:SetScript("OnMouseWheel", Wheel)
    track:SetScript("OnMouseWheel", Wheel)
    scroll:SetScript("OnVerticalScroll", Update)
    scroll:SetScript("OnScrollRangeChanged", Update)
    scroll:SetScript("OnSizeChanged", function(_, width)
        if width and width > 0 then child:SetWidth(width) end
        Update()
    end)
    child:SetScript("OnSizeChanged", Update)
    thumb:SetScript("OnDragStart", function(self)
        if root.pageScrollLocked then return end
        local _, cursor = GetCursorPosition()
        self.startCursor, self.startScroll = cursor / root:GetEffectiveScale(), scroll:GetVerticalScroll()
        self:SetScript("OnUpdate", function()
            local _, current = GetCursorPosition()
            local travel = math.max(1, track:GetHeight() - thumb:GetHeight())
            SetScroll(self.startScroll + (self.startCursor - current / root:GetEffectiveScale()) * MaxScroll() / travel)
        end)
    end)
    thumb:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    host:SetScript("OnHide", function() thumb:SetScript("OnUpdate", nil) end)
    track:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" or root.pageScrollLocked or not thumb:IsShown() then return end
        local _, cursor = GetCursorPosition()
        local _, center = thumb:GetCenter()
        if center then SetScroll(scroll:GetVerticalScroll() + (cursor / root:GetEffectiveScale() > center and -1 or 1) * scroll:GetHeight() * 0.8) end
    end)
    host.scroll, host.child, host.UpdateScroll = scroll, child, Update
    host.SetScroll = function(_, value) SetScroll(value) end
    return host
end

-- The drawer: a bar with the preview toggle and target test, and the sample stage beneath it.
-- Collapsed, only the bar remains along the bottom of the window.
local function CreatePreview(root, content, bar)
    local pane = CreateFrame("Frame", nil, content)
    pane:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, 0)
    pane:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 0)
    W.Paint(pane, C.drawer, 9, nil, "124")
    local scaleLabel = W.Text(pane, string.format(L["Preview scale: %d%%"], math.floor(PREVIEW_SCALE * 100 + 0.5)), 0, 0, nil, nil, C.dim)
    scaleLabel:ClearAllPoints()
    scaleLabel:SetPoint("LEFT", root.previewToggle, "RIGHT", 6, 0)
    scaleLabel:SetWordWrap(false)
    local areaLabel = W.Text(pane, "", 0, 0, nil, nil, C.muted)
    areaLabel:ClearAllPoints()
    areaLabel:SetPoint("LEFT", scaleLabel, "RIGHT", 12, 0)
    areaLabel:SetWordWrap(false)
    local note = W.Text(pane, L["Appearance only · Test on Target checks gameplay size."], 0, 0, nil, nil, C.dim)
    note:ClearAllPoints()
    note:SetPoint("BOTTOMRIGHT", pane, "BOTTOMRIGHT", -20, 12)
    note:SetJustifyH("RIGHT")
    note:SetWordWrap(false)
    local columnsHost = CreateFrame("Frame", nil, pane)
    columnsHost:SetPoint("TOPLEFT", 20, -10)
    columnsHost:SetPoint("BOTTOMRIGHT", -20, 36)
    pane.stage, pane.viewport, pane.columns = columnsHost, columnsHost, {}
    local function LayoutColumns()
        local width = columnsHost:GetWidth()
        local count = #pane.columns
        if width <= 0 or count == 0 then return end
        local gap = 16
        local colWidth = (width - gap * (count - 1)) / count
        for index, column in ipairs(pane.columns) do
            column:ClearAllPoints()
            column:SetPoint("TOPLEFT", columnsHost, "TOPLEFT", (index - 1) * (colWidth + gap), 0)
            column:SetPoint("BOTTOMLEFT", columnsHost, "BOTTOMLEFT", (index - 1) * (colWidth + gap), 0)
            column:SetWidth(colWidth)
        end
    end
    for index, entry in ipairs({ { "hit", "Hit" }, { "crit", "Crit" }, { "miss", "Miss" } }) do
        local column = CreateFrame("Frame", nil, columnsHost)
        column.kind = entry[1]
        if index > 1 then
            local divider = column:CreateTexture(nil, "ARTWORK")
            divider:SetWidth(1)
            divider:SetPoint("TOPLEFT", -8, -4)
            divider:SetPoint("BOTTOMLEFT", -8, 4)
            divider:SetColorTexture(C.line[1], C.line[2], C.line[3], 1)
        end
        local caption = W.Text(column, L[entry[2]], 0, 0, nil, nil, C.dim)
        W.SetFont(caption, "semibold", 13)
        caption:ClearAllPoints()
        caption:SetPoint("TOP", 0, -2)
        caption:SetJustifyH("CENTER")
        caption:SetWordWrap(false)
        local clip = CreateFrame("Frame", nil, column)
        clip:SetPoint("TOPLEFT", 2, -22)
        clip:SetPoint("BOTTOMRIGHT", -2, 2)
        clip:SetClipsChildren(true)
        local stage = CreateFrame("Frame", nil, clip)
        stage:SetSize(1, 1)
        stage:SetPoint("CENTER")
        column.clip, column.stage = clip, stage
        pane.columns[index] = column
    end
    function pane:FitStage()
        LayoutColumns()
        local area = BD:GetOptionsPreviewArea()
        note:SetText(area and L["Scaled preview · Test selected area shows actual size."]
            or L["Appearance only · Test on Target checks gameplay size."])
        -- Every preview plays at a locked scale, never shrunk to fit the drawer.
        local scale = PREVIEW_SCALE
        local offsetX, offsetY = BD:GetNumberStyleOffsets()
        for _, column in ipairs(self.columns) do
            local clip, stage = column.clip, column.stage
            if clip:GetWidth() <= 0 or clip:GetHeight() <= 0 then return end
            stage:ClearAllPoints()
            stage:SetScale(scale)
            if area then
                -- An area taller than the drawer keeps its spawn edge in view, so each number
                -- appears and starts to travel; held crits gather at the area's center.
                stage:SetSize(area.width, area.height)
                local impact = area.animation == "impact"
                local held = column.kind == "crit" and area.stickyCrits and not impact
                if held or area.height * scale <= clip:GetHeight() then
                    stage:SetPoint("CENTER", clip, "CENTER", 0, 0)
                elseif area.direction == "down" and not impact then
                    stage:SetPoint("TOP", clip, "TOP", 0, -AREA_EDGE_INSET)
                else
                    stage:SetPoint("BOTTOM", clip, "BOTTOM", 0, AREA_EDGE_INSET)
                end
            else
                -- Motion bounds use the default spawn; account for the saved offsets.
                local left, right, bottom, top = BD:GetOptionsPreviewBounds(column.kind)
                left, right = math.min(-32, left + offsetX), math.max(32, right + offsetX)
                bottom, top = math.min(-3, bottom + offsetY), math.max(3, top + offsetY)
                stage:SetSize(1, 1)
                stage:SetPoint("CENTER", clip, "CENTER", -(left + right) * 0.5 * scale, -(bottom + top) * 0.5 * scale)
            end
        end
        scaleLabel:SetText(string.format(L["Preview scale: %d%%"], math.floor(scale * 100 + 0.5)))
        areaLabel:SetText(area and string.format(L["Selected area: %s"], BD:GetScreenAreaLabel(area)) or "")
    end
    function pane:UpdateLayout()
        local open = BD.db.showOptionsPreview and true or false
        self:SetShown(open)
        bar:ClearAllPoints()
        bar:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 0, open and STAGE_HEIGHT or 0)
        bar:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, open and STAGE_HEIGHT or 0)
        W.Paint(bar, C.drawer, 9, nil, open and "1234" or "124")
        root.pageArea:ClearAllPoints()
        root.pageArea:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(root.pageContentTop or 96))
        root.pageArea:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", 0, 0)
        local toggle = root.previewToggle
        toggle:SetText(open and L["Hide preview"] or L["Show preview"])
        W.SetIcon(toggle.optionsIcon, open and "ChevronDown" or "ChevronUp")
        toggle:SetWidth(toggle:GetFontString():GetStringWidth() + 50)
        for _, view in pairs(root.views) do view:UpdateScroll() end
    end
    columnsHost:SetScript("OnSizeChanged", function() if pane:IsShown() then pane:FitStage() end end)
    return pane
end

-- The default size is the minimum; the maximum is the screen area FitToScreen allows.
local function ApplyResizeBounds(frame, maxWidth, maxHeight)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(WINDOW_WIDTH, WINDOW_HEIGHT, maxWidth, maxHeight)
    else
        if frame.SetMinResize then frame:SetMinResize(WINDOW_WIDTH, WINDOW_HEIGHT) end
        if frame.SetMaxResize then frame:SetMaxResize(maxWidth, maxHeight) end
    end
end

local function CreateSettingsTransferDialog(root)
    local dialog = CreateFrame("Frame", nil, root)
    dialog:Hide(); dialog:SetAllPoints(root); dialog:EnableMouse(true)
    dialog:SetFrameLevel(root:GetFrameLevel() + 100)
    local shade = dialog:CreateTexture(nil, "BACKGROUND")
    shade:SetAllPoints(); shade:SetColorTexture(0, 0, 0, 0.65)
    local panel = CreateFrame("Frame", nil, dialog, "BackdropTemplate")
    panel:SetSize(640, 480); panel:SetPoint("CENTER"); panel:EnableMouse(true)
    W.Backdrop(panel, "window")
    local title = W.Text(panel, "", 24, -22, 560, "GameFontNormalLarge", C.bright or GOLD)
    if W.SetFont then W.SetFont(title, "display", 18) end
    local instruction = W.Text(panel, "", 24, -56, 592, nil, C.muted)
    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 24, -90); scroll:SetSize(570, 180)
    W.Backdrop(scroll, "control")
    local input = W.EditBox(scroll, 570, 180)
    input:SetMultiLine(true)
    -- Stay inside a 16-bit letter cap. The wire format is a few thousand characters.
    input:SetMaxLetters(math.min(BD.SETTINGS_STRING_MAX_BYTES, 32767))
    input:SetTextInsets(8, 8, 8, 8); input:SetSpacing(3)
    -- Multiline height follows the text, so this backdrop's bottom edge cuts the viewport.
    if W.Unpaint then W.Unpaint(input) end
    if input.SetBackdrop then input:SetBackdrop(nil) end
    scroll:SetScrollChild(input)
    -- A tall multiline child otherwise keeps the mouse over the buttons below the viewport.
    if scroll.SetClipsChildren then scroll:SetClipsChildren(true) end
    local status = W.Text(panel, "", 24, -290, 592, nil, C.text)
    local apply, validate
    local holdingFocus = false
    local function SettingsText()
        return (input:GetText() or ""):gsub("%s+", "")
    end
    local function ReleaseInput()
        holdingFocus = true
        input:ClearFocus()
        holdingFocus = false
    end
    -- Focus loss cancels OnClick after MouseDown. Run the action on MouseUp.
    local function ClickDespiteFocus(button, action)
        local function Chain(event, handler)
            if button.GetScript then
                local previous = button:GetScript(event)
                button:SetScript(event, function(self, ...)
                    if previous then previous(self, ...) end
                    handler(self, ...)
                end)
            elseif button.SetScript then
                button:SetScript(event, handler)
            end
        end
        Chain("OnMouseUp", function(self)
            if not self:IsEnabled() then return end
            self.transferClick = true
            action()
        end)
        if button.GetScript then
            local previousClick = button:GetScript("OnClick")
            button:SetScript("OnClick", function(self, ...)
                if self.transferClick then self.transferClick = nil; return end
                if previousClick then previousClick(self, ...) end
            end)
        end
    end
    local function PaintApply(enabled)
        apply:SetEnabled(enabled and true or false)
        -- The action face already dims a disabled button's label.
        if W.PaintAction then W.PaintAction(apply, "idle") end
    end
    local function Invalidate()
        dialog.validatedText = nil
        PaintApply(false)
        status:SetText("")
    end
    local function ShowError(err)
        Invalidate()
        status:SetTextColor(1, 0.45, 0.3)
        status:SetText(err or "")
    end
    local function ValidateInput()
        local text = SettingsText()
        local preview, err = BD:PreviewSettingsImport(text)
        if not preview then ShowError(err); ReleaseInput(); return end
        dialog.validatedText = text
        local source = preview.source == "modern" and L["Modern API - Midnight & Forever"] or L["Classic API - Era/TBC/Wrath/MoP"]
        local lines = {
            string.format(L["Source: %s (PlateSCT %s)"], source, preview.addonVersion),
            string.format(L["Changes: %d shared, %d Modern API. Ignored: %d."], preview.sharedCount, preview.modernCount, #preview.ignored),
            L["Missing settings stay unchanged."],
        }
        if preview.preservesModern then lines[#lines + 1] = L["Your Modern API settings will stay unchanged."] end
        if preview.recommendedSchools then lines[#lines + 1] = L["Recommended damage schools will follow your current class."] end
        status:SetTextColor(0.93, 0.90, 0.85)
        status:SetText(table.concat(lines, "\n"))
        -- A disabled Button never receives hover, tooltip, or clicks.
        PaintApply(true)
        ReleaseInput()
    end
    -- Above the scrolling edit box, which otherwise keeps the click over Apply.
    local footer = CreateFrame("Frame", nil, dialog)
    if footer.SetFrameStrata then footer:SetFrameStrata("FULLSCREEN_DIALOG") end
    footer:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT")
    footer:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT")
    footer:SetHeight(60)
    validate = W.Button(footer, L["Validate string"], 184, 34, ValidateInput, "flat")
    ClickDespiteFocus(validate, ValidateInput)
    validate:SetPoint("BOTTOMLEFT", 24, 20)
    local function ApplyInput()
        if not dialog.validatedText or dialog.validatedText ~= SettingsText() then Invalidate(); return end
        local result, err = BD:ImportSettings(dialog.validatedText)
        if not result then
            ShowError(err)
            -- A failed refresh may have closed this dialog; keep the outcome visible.
            if not dialog:IsShown() then print("PlateSCT: " .. err) end
            return
        end
        dialog:Hide()
        local message = #result.changes == 0 and L["No settings changed."] or L["Settings imported."]
        print("PlateSCT: " .. message)
    end
    apply = W.Button(footer, L["Apply settings"], 184, 34, ApplyInput)
    ClickDespiteFocus(apply, ApplyInput)
    apply:SetPoint("BOTTOM", 0, 20); PaintApply(false)
    local function CancelInput() dialog:Hide() end
    local cancel = W.Button(footer, CANCEL, 184, 34, CancelInput, "flat")
    ClickDespiteFocus(cancel, CancelInput)
    cancel:SetPoint("BOTTOMRIGHT", -24, 20)
    local buttonLevel = panel:GetFrameLevel() + 40
    if footer.SetFrameLevel then footer:SetFrameLevel(buttonLevel) end
    if validate.SetFrameLevel then validate:SetFrameLevel(buttonLevel + 2) end
    if apply.SetFrameLevel then apply:SetFrameLevel(buttonLevel + 2) end
    if cancel.SetFrameLevel then cancel:SetFrameLevel(buttonLevel + 2) end
    local close = W.CloseButton(panel, function() dialog:Hide() end)
    close:SetPoint("TOPRIGHT", -14, -14)
    local validateSerial = 0
    local function ScheduleValidate()
        validateSerial = validateSerial + 1
        local serial = validateSerial
        local later = C_Timer and C_Timer.After
        if not later then ValidateInput(); return end
        later(1, function()
            if serial ~= validateSerial or not dialog:IsShown() then return end
            if SettingsText() == "" then return end
            ValidateInput()
        end)
    end
    input:SetScript("OnTextChanged", function(_, userInput)
        scroll:UpdateScrollChildRect()
        if holdingFocus or not userInput then return end
        if dialog.validatedText and SettingsText() == dialog.validatedText then return end
        Invalidate()
        if SettingsText() == "" then validateSerial = validateSerial + 1; return end
        ScheduleValidate()
    end)
    input:SetScript("OnCursorChanged", function(_, _, y, _, height)
        scroll:UpdateScrollChildRect()
        local top = -y
        local offset = scroll:GetVerticalScroll()
        if top < offset then scroll:SetVerticalScroll(math.max(0, top))
        elseif top + height > offset + scroll:GetHeight() then
            scroll:SetVerticalScroll(math.max(0, top + height - scroll:GetHeight()))
        end
    end)
    scroll:SetScript("OnMouseDown", function() input:SetFocus() end)
    input:SetScript("OnEscapePressed", function() dialog:Hide() end)
    dialog:SetScript("OnHide", function()
        validateSerial = validateSerial + 1
        input:ClearFocus(); input:SetText(""); dialog.validatedText = nil
        if root.transientMenu == dialog then root.transientMenu, root.pageScrollLocked = nil, false end
    end)
    function dialog:Open(importing)
        root:DismissTransient()
        root.searchBox:ClearFocus()
        root.transientMenu, root.pageScrollLocked = self, true
        title:SetText(importing and L["Import Settings"] or L["Export Settings"])
        instruction:SetText(importing and L["Paste a settings string, then validate it before applying."]
            or L["Press Ctrl+C to copy the settings string."])
        validate:SetShown(importing); apply:SetShown(importing)
        cancel:SetText(importing and CANCEL or L["Close"])
        self:Show(); input:SetText(""); Invalidate()
        if not importing then
            local text, err = BD:ExportSettings()
            if not text then ShowError(err); return end
            input:SetText(text)
        end
        input:SetFocus(); input:HighlightText(); scroll:SetVerticalScroll(0)
    end
    return dialog
end

local function PageLabel(page)
    return page.label and page.label() or L[page.labelKey]
end

local function BuildConfigFrame()
    local frame = CreateFrame("Frame", "PlateSCTConfigFrame", UIParent, "BackdropTemplate")
    frame:Hide(); frame:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT); frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG"); frame:SetToplevel(true); frame:SetClampedToScreen(true)
    frame:EnableMouse(true); frame:SetMovable(true)
    -- ESC closes the window through the game's special-frames list. Capturing the keyboard
    -- instead needs SetPropagateKeyboardInput, which is blocked in combat and could swallow keys.
    tinsert(UISpecialFrames, "PlateSCTConfigFrame")
    W.Backdrop(frame, "window")
    frame.controls, frame.searchIndex, frame.refreshers = {}, {}, {}
    frame.views, frame.pages, frame.navButtons = {}, {}, {}
    frame.utilityButtons = {}
    frame.motionGroups, frame.motionTargets, frame.tabButtons = {}, {}, {}
    function frame:RegisterControl(control, meta)
        self.controls[#self.controls + 1] = control
        meta.control = control
        control.searchMeta = meta
        local aliases = { damageMode = L["Only my damage"] .. " " .. L["All engaged nameplates"], fontSize = L["Text size"], floatDistance = L["Scroll offset"] }
        meta.searchText = SearchText(table.concat({ meta.label or "", meta.tip or "", meta.section or "", aliases[meta.id] or "" }, " "))
        self.searchIndex[#self.searchIndex + 1] = meta
        return meta
    end
    function frame:DismissTransient()
        local dismissed = false
        if self.transientMenu then
            local menu = self.transientMenu
            if menu.Dismiss then menu:Dismiss() else menu:Hide() end
            self.transientMenu, self.pageScrollLocked = nil, false
            dismissed = true
        end
        if self.searchResults and self.searchResults:IsShown() then
            self.searchResults:Hide(); dismissed = true
        end
        return dismissed
    end
    function frame:ConfirmReset() StaticPopup_Show("PLATESCT_RESET_CONFIRM") end
    function frame:ShowSettingsTransfer(importing)
        if not self.transferDialog then self.transferDialog = CreateSettingsTransferDialog(self) end
        self.transferDialog:Open(importing)
    end
    function frame:Refresh()
        if self.refreshing or self.disposed then return end
        StopMotion(self)
        self.refreshing = true
        for _, control in ipairs(self.controls) do control:Refresh() end
        for _, refresh in ipairs(self.refreshers) do refresh() end
        self.refreshing = false
        if self.previewPane then BD:RequestOptionsPreview() end
    end
    frame.UpdateDependentStates = frame.Refresh
    -- Header: identity on the left, layout switch and close on the right.
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetPoint("TOPLEFT", 1, -1); titleBar:SetPoint("TOPRIGHT", -1, -1); titleBar:SetHeight(HEADER_HEIGHT)
    titleBar:EnableMouse(true)
    -- Move from mouse down/up: dragging a child shifts the parent cursor offset.
    titleBar:SetScript("OnMouseDown", function(_, button) if button == "LeftButton" then frame:StartMoving(true) end end)
    titleBar:SetScript("OnMouseUp", function() frame:StopMovingOrSizing(); frame:SetUserPlaced(false) end)
    local headerLine = W.Line(titleBar, C.line)
    headerLine:SetHeight(1)
    headerLine:SetPoint("BOTTOMLEFT"); headerLine:SetPoint("BOTTOMRIGHT")
    local logo = titleBar:CreateTexture(nil, "ARTWORK")
    logo:SetTexture("Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\psct-logo-mini.png")
    logo:SetSize(32, 32); logo:SetPoint("LEFT", 20, 0)
    local name = W.Text(titleBar, "PlateSCT", 64, -15, 200, nil, C.bright)
    W.SetFont(name, "semibold", 15)
    local version = Version()
    frame.apiLabel = W.Text(titleBar, (version ~= "" and (version .. "  ·  ") or "") .. FlavorLabel(), 64, -34, 360, nil, C.muted)
    frame.apiLabel:SetWordWrap(false)
    local close = W.CloseButton(frame, function() frame:Hide() end)
    close:SetPoint("TOPRIGHT", -16, -16)
    close:SetFrameLevel(titleBar:GetFrameLevel() + 5)
    W.Tooltip(close, L["Close"])
    -- Segmented layout switch; the same choice as the General page cards.
    local layoutBadge = CreateFrame("Frame", nil, titleBar)
    layoutBadge:SetHeight(36)
    layoutBadge:SetPoint("RIGHT", close, "LEFT", -12, 0)
    W.Paint(layoutBadge, C.field, 9)
    frame.layoutBadge, frame.layoutButtons = layoutBadge, {}
    for _, mode in ipairs({ { "nameplates", "Nameplates" }, { "screen", "Screen" } }) do
        local id = mode[1]
        local segment = W.Button(layoutBadge, L[mode[2]], 100, 30, function()
            if BD.db.displayMode == id then return end
            BD.db.displayMode = id
            BD:RefreshScreenAreas()
            frame:Refresh()
        end, "segment")
        segment.optionsRadius = 7
        frame.layoutButtons[id] = segment
    end
    frame.layoutCaption = W.Text(titleBar, L["Active layout"], 0, 0, nil, nil, C.muted)
    frame.layoutCaption:ClearAllPoints()
    frame.layoutCaption:SetPoint("RIGHT", layoutBadge, "LEFT", -10, 0)
    frame.layoutCaption:SetWordWrap(false)
    -- Text widths are only reliable once the bundled fonts have loaded, so size the header
    -- controls again whenever the window opens.
    frame.chromeTexts = { name, frame.apiLabel, frame.layoutCaption }
    function frame:SizeChrome()
        for _, text in ipairs(self.chromeTexts) do W.RefreshText(text) end
        local x = 3
        for _, id in ipairs({ "nameplates", "screen" }) do
            local segment = self.layoutButtons[id]
            W.RefreshText(segment:GetFontString())
            local width = math.ceil(segment:GetFontString():GetStringWidth() + 28)
            segment:SetWidth(width)
            segment:ClearAllPoints()
            segment:SetPoint("LEFT", self.layoutBadge, "LEFT", x, 0)
            x = x + width + 2
        end
        self.layoutBadge:SetWidth(x + 1)
        if self.targetTest then
            W.RefreshText(self.targetTest:GetFontString())
            self.targetTest:SetWidth(math.ceil(self.targetTest:GetFontString():GetStringWidth() + 32))
        end
        if self.previewToggle then
            W.RefreshText(self.previewToggle:GetFontString())
            self.previewToggle:SetWidth(self.previewToggle:GetFontString():GetStringWidth() + 50)
        end
        for _, button in pairs(self.cachedTabs or {}) do
            W.RefreshText(button:GetFontString())
            button:SetWidth(math.ceil(button:GetFontString():GetStringWidth() + 32))
        end
    end

    -- Sidebar: search, pages, then quiet utilities pinned to the bottom.
    local sidebar = CreateFrame("Frame", nil, frame)
    sidebar:SetWidth(SIDEBAR_WIDTH)
    sidebar:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
    sidebar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
    W.Paint(sidebar, C.sidebar, 9, nil, "123")
    local sidebarLine = W.Line(sidebar, C.line)
    sidebarLine:SetWidth(1)
    sidebarLine:SetPoint("TOPRIGHT"); sidebarLine:SetPoint("BOTTOMRIGHT")
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 0, 0); content:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.pageTitle = W.Text(content, "", 32, -24, 560, nil, C.bright)
    W.SetFont(frame.pageTitle, "display", 22)
    frame.pageTitle:SetWordWrap(false)
    frame.subtitle = W.Text(content, "", 32, -52, 560, nil, C.muted)
    frame.tabBar = CreateFrame("Frame", nil, content)
    frame.tabBar:SetPoint("TOPLEFT", 32, -96); frame.tabBar:SetHeight(36)
    W.Paint(frame.tabBar, C.field, 9)
    frame.pageArea = CreateFrame("Frame", nil, content)
    frame.pageArea:SetClipsChildren(true)
    local previewBar = CreateFrame("Frame", nil, content)
    previewBar:SetHeight(BAR_HEIGHT)
    local barLine = W.Line(previewBar, C.line)
    barLine:SetHeight(1)
    barLine:SetPoint("TOPLEFT"); barLine:SetPoint("TOPRIGHT")
    frame.previewBar = previewBar
    frame.previewToggle = W.NavButton(previewBar, L["Show preview"], "ChevronUp", 140, 30, function()
        BD.db.showOptionsPreview = not BD.db.showOptionsPreview
        frame:Refresh()
    end, "ghost")
    frame.previewToggle:SetPoint("LEFT", 12, 0)
    W.Tooltip(frame.previewToggle, L["Show sample hits, crits, and misses inside this window."])
    -- A quiet secondary button: the preview bar is a utility strip, not a call to action.
    local targetTest = W.Button(previewBar, L["Test on Target"], 140, 30, function() BD:ShowTestNumbers() end, "flat")
    targetTest:GetFontString():SetJustifyH("CENTER")
    targetTest:SetPoint("RIGHT", -16, 0)
    W.Tooltip(targetTest, function()
        return BD.Layout.IsScreen() and L["Spawn sample numbers in your screen areas."]
            or L["Target an enemy, then spawn sample numbers on its nameplate."]
    end)
    frame.targetTest = targetTest
    -- Screen areas need no target, so the button names what it does in each layout.
    frame.refreshers[#frame.refreshers + 1] = function()
        targetTest:SetText(BD.Layout.IsScreen() and L["Test numbers"] or L["Test on Target"])
        targetTest:SetWidth(math.ceil(targetTest:GetFontString():GetStringWidth() + 32))
    end
    local hint = W.Text(sidebar, L["/platesct  ·  ESC to close"], 0, 0, 176, nil, C.dim)
    hint:ClearAllPoints()
    hint:SetPoint("BOTTOMLEFT", 22, 14)
    hint:SetWordWrap(false)
    frame.chromeTexts[#frame.chromeTexts + 1] = hint
    frame.chromeTexts[#frame.chromeTexts + 1] = frame.subtitle
    frame.chromeTexts[#frame.chromeTexts + 1] = frame.pageTitle
    local divider = W.Line(sidebar, C.line)
    divider:SetHeight(1)
    divider:SetPoint("BOTTOMLEFT", 16, 176); divider:SetPoint("BOTTOMRIGHT", -16, 176)

    local search = W.EditBox(sidebar, SIDEBAR_WIDTH - 24, 34)
    search:SetPoint("TOPLEFT", 12, -16)
    search:SetTextInsets(32, 10, 0, 0)
    W.SetFont(search, "regular", 13)
    local searchIcon = W.Icon(search, "Search", 15, C.dim, "OVERLAY")
    searchIcon:SetPoint("LEFT", 10, 0)
    local placeholder = W.Text(search, L["Find a setting"], 0, 0, SIDEBAR_WIDTH - 70, nil, C.dim)
    placeholder:ClearAllPoints()
    placeholder:SetPoint("LEFT", 32, 0)
    placeholder:SetWordWrap(false)
    search.placeholder = placeholder
    frame.searchBox = search
    local results = CreateFrame("Frame", nil, frame)
    results:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 8, -16); results:SetSize(420, 1)
    results:SetFrameLevel(frame:GetFrameLevel() + 40); results:EnableMouse(true)
    W.Backdrop(results, "menu"); results:Hide()
    local resultView = CreateScrollView(results, frame)
    resultView:ClearAllPoints(); resultView:SetPoint("TOPLEFT", 6, -6); resultView:SetPoint("BOTTOMRIGHT", -6, 6)
    resultView:Show()
    frame.searchResults, frame.resultButtons, frame.searchMatches = results, {}, {}
    frame.searchSelection = 1

    local function SaveScroll()
        if frame.activeView then session.scroll[frame.activeView.key] = frame.activeView.scroll:GetVerticalScroll() end
    end
    function frame:SelectPage(pageId, tabId, immediate)
        local page = self.pages[pageId]
        if not page or (page.visible and not page.visible()) then pageId, page = "general", self.pages.general end
        if not page then return end
        local previous, previousPage = self.activeView, session.page
        self:DismissTransient(); SaveScroll(); StopMotion(self)
        for _, button in ipairs(self.tabButtons) do button:Hide() end
        self.tabButtons = {}
        local tabs = page.tabs or { { id = "main" } }
        tabId = tabId or session.tabs[pageId] or tabs[1].id
        local view = self.views[pageId .. ":" .. tabId] or self.views[pageId .. ":" .. tabs[1].id]
        tabId = view.tab
        local ox, oy = 0, -28
        if previous and previous ~= view and previousPage == pageId and page.tabs then
            local oldIndex, newIndex
            for index, tab in ipairs(page.tabs) do
                if tab.id == previous.tab then oldIndex = index end
                if tab.id == view.tab then newIndex = index end
            end
            if oldIndex and newIndex and oldIndex ~= newIndex then
                ox, oy = (newIndex > oldIndex and 48 or -48), 0
            end
        end
        session.page, session.tabs[pageId] = pageId, tabId
        local animate = not immediate and BD.db.settingsAnimations
        local departing = animate and previous and previous ~= view
        for _, other in pairs(self.views) do
            other:SetShown(other == view or (departing and other == previous))
        end
        if departing then
            previous:SetFrameLevel(self.pageArea:GetFrameLevel() + 1)
            view:SetFrameLevel(self.pageArea:GetFrameLevel() + 2)
            Dismiss(previous, -ox * 0.7, -oy * 0.7)
        end
        self.activeView = view
        self.pageTitle:SetText(PageLabel(page)); self.subtitle:SetText(L[page.subtitleKey or ""])
        local tabY = 52 + math.max(17, self.subtitle:GetStringHeight()) + 16
        self.tabBar:ClearAllPoints()
        self.tabBar:SetPoint("TOPLEFT", 32, -tabY)
        self.tabBar:SetShown(page.tabs ~= nil)
        self.pageContentTop = page.tabs and (tabY + 36 + 20) or tabY
        for id, button in pairs(self.navButtons) do W.SetSelected(button, id == pageId) end
        for id, button in pairs(self.utilityButtons) do W.SetSelected(button, id == pageId) end
        if page.tabs then
            local x = 3
            for _, tab in ipairs(tabs) do
                local tabKey = pageId .. ":" .. tab.id
                local button = self.cachedTabs[tabKey]
                if not button then
                    local id = tab.id
                    button = W.Button(self.tabBar, L[tab.labelKey], 120, 30, function() self:SelectPage(pageId, id) end, "segment")
                    button.optionsRadius = 7
                    button:SetWidth(math.ceil(button:GetFontString():GetStringWidth() + 32))
                    self.cachedTabs[tabKey] = button
                end
                button:ClearAllPoints()
                button:SetPoint("LEFT", self.tabBar, "LEFT", x, 0)
                x = x + button:GetWidth() + 2
                W.SetSelected(button, tab.id == tabId)
                button:Show(); self.tabButtons[#self.tabButtons + 1] = button
            end
            self.tabBar:SetWidth(x + 1)
        end
        if self.previewPane then self.previewPane:UpdateLayout() end
        view:SetScroll(session.scroll[view.key] or 0)
        if animate then Reveal(self, view, ox, oy) end
        if self.previewPane then BD:RequestOptionsPreview() end
    end
    frame.cachedTabs = {}
    local NAV_TOP, NAV_STEP, NAV_HEIGHT = 62, 38, 36
    local UTILITY_STEP, UTILITY_HEIGHT = 32, 30
    local definitions = {}
    for _, page in ipairs(BD.OptionsPages) do definitions[#definitions + 1] = page end
    for _, page in ipairs(BD.OptionsUtilities) do definitions[#definitions + 1] = page end
    local utilityCount = #BD.OptionsUtilities + 1
    for index, page in ipairs(definitions) do
        if not page.supported or page.supported() then
            frame.pages[page.id] = page
            local id = page.id
            local utility = index > #BD.OptionsPages
            local width = SIDEBAR_WIDTH - 24
            local button
            if utility then
                local slot = index - #BD.OptionsPages
                button = W.NavButton(sidebar, PageLabel(page), PAGE_ICONS[id] or "Help", width, UTILITY_HEIGHT,
                    function() frame:SelectPage(id) end, "utility")
                button:SetPoint("BOTTOMLEFT", 12, 38 + (utilityCount - slot) * UTILITY_STEP)
                frame.utilityButtons[id] = button
            else
                button = W.NavButton(sidebar, PageLabel(page), PAGE_ICONS[id] or "General", width, NAV_HEIGHT,
                    function() frame:SelectPage(id) end, "nav")
                button:SetPoint("TOPLEFT", 12, -NAV_TOP - (index - 1) * NAV_STEP)
                frame.navButtons[id] = button
            end
            local tabs = page.tabs or { { id = "main" } }
            for _, tab in ipairs(tabs) do
                local view = CreateScrollView(frame.pageArea, frame)
                view.key, view.tab = id .. ":" .. tab.id, tab.id
                frame.views[view.key] = view
                page.build(view.child, frame, tab.id)
            end
        end
    end
    frame.utilityButtons.resetDefaults = W.NavButton(sidebar, L["Reset Defaults"], "Reset", SIDEBAR_WIDTH - 24,
        UTILITY_HEIGHT, function() frame:ConfirmReset() end, "utility")
    frame.utilityButtons.resetDefaults:SetPoint("BOTTOMLEFT", 12, 38)
    W.Tooltip(frame.utilityButtons.resetDefaults, L["Restore every PlateSCT setting to its default."])
    frame.refreshers[#frame.refreshers + 1] = function()
        local index = 0
        for _, page in ipairs(BD.OptionsPages) do
            local button = frame.navButtons[page.id]
            if button then
                local visible = not page.visible or page.visible()
                button:SetShown(visible)
                button:SetText(PageLabel(page))
                if visible then
                    button:ClearAllPoints()
                    button:SetPoint("TOPLEFT", 12, -NAV_TOP - index * NAV_STEP)
                    index = index + 1
                end
            end
        end
        local screen = BD.Layout.IsScreen()
        W.SetSelected(frame.layoutButtons.nameplates, not screen)
        W.SetSelected(frame.layoutButtons.screen, screen)
        local page = frame.pages[session.page]
        if not page or (page.visible and not page.visible()) then frame:SelectPage("general", nil, true) end
        page = frame.pages[session.page]
        frame.pageTitle:SetText(PageLabel(page))
    end
    frame.previewPane = CreatePreview(frame, content, previewBar)
    frame.previewPane:UpdateLayout()

    function frame:ChooseSearchResult(index)
        local meta = self.searchMatches[index]
        if not meta then return end
        self:SelectPage(meta.page, meta.tab, true)
        local row = meta.control.row or meta.control
        search:SetText(""); search:ClearFocus()
        self.activeView:SetScroll(math.max(0, -(meta.y or 0) - 14))
        if not row.searchHighlight then
            local highlight = row:CreateTexture(nil, "BACKGROUND")
            highlight:SetAllPoints(); highlight:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.12)
            row.searchHighlight = highlight
        end
        local highlight = row.searchHighlight
        highlight:Show(); self.searchHighlight = highlight
        if BD.db.settingsAnimations then
            if not highlight.fade then
                highlight.fade = highlight:CreateAnimationGroup()
                local alpha = highlight.fade:CreateAnimation("Alpha")
                alpha:SetFromAlpha(1); alpha:SetToAlpha(0); alpha:SetDuration(0.8)
                highlight.fade:SetScript("OnFinished", function() highlight:Hide() end)
                self.motionGroups[#self.motionGroups + 1] = highlight.fade
            end
            highlight.fade:Play()
        else
            local generation = self.highlightGeneration
            C_Timer.After(0.8, function()
                if self.highlightGeneration == generation then highlight:Hide() end
            end)
        end
    end
    local function UpdatePlaceholder()
        search.placeholder:SetShown((search:GetText() or "") == "" and not search:HasFocus())
    end
    local RESULT_STEP = 38
    local function PaintResults()
        for index, button in ipairs(frame.resultButtons) do W.SetSelected(button, index == frame.searchSelection) end
    end
    local function UpdateSearch()
        UpdatePlaceholder()
        local query = SearchText((search:GetText() or ""):match("^%s*(.-)%s*$"))
        for _, button in ipairs(frame.resultButtons) do button:Hide() end
        frame.searchMatches, frame.searchSelection = {}, 1
        if query == "" then results:Hide(); return end
        if frame.transientMenu then frame:DismissTransient() end
        for _, meta in ipairs(frame.searchIndex) do
            local aliases = meta.control.searchAliases
            if type(aliases) == "table" then aliases = table.concat(aliases, " ") end
            local searchable = meta.searchText .. " " .. SearchText(aliases or "")
            local row = meta.control.row or meta.control
            local page = frame.pages[meta.page]
            local available = not row.isVisible or row.isVisible()
            if page and (not page.visible or page.visible()) and available and searchable:find(query, 1, true) then
                frame.searchMatches[#frame.searchMatches + 1] = meta
            end
        end
        local matches = frame.searchMatches
        for index, meta in ipairs(matches) do
            local button = frame.resultButtons[index]
            if not button then
                local resultIndex = index
                button = W.Button(resultView.child, "", 380, 36, function() frame:ChooseSearchResult(resultIndex) end, "result")
                button.optionsRadius = 6
                button:SetPoint("TOPLEFT", 0, -(index - 1) * RESULT_STEP)
                frame.resultButtons[index] = button
            end
            local page = frame.pages[meta.page]
            button:SetText((meta.label or "") .. "   |cff8c8475" .. PageLabel(page) .. "|r")
            button:Show()
        end
        PaintResults()
        if not results.empty then results.empty = W.Text(resultView.child, L["No matching settings"], 12, -10, 368, nil, C.muted) end
        results.empty:SetShown(#matches == 0)
        resultView.child:SetHeight(#matches == 0 and 36 or #matches * RESULT_STEP)
        results:SetHeight(#matches == 0 and 48 or 12 + math.min(8, #matches) * RESULT_STEP)
        resultView:SetScroll(0); results:Show()
    end
    frame.refreshers[#frame.refreshers + 1] = UpdateSearch
    search:SetScript("OnTextChanged", UpdateSearch)
    search:SetScript("OnEnterPressed", function() frame:ChooseSearchResult(frame.searchSelection) end)
    search:SetScript("OnEscapePressed", function() frame:DismissTransient(); search:ClearFocus() end)
    search:SetScript("OnArrowPressed", function(_, direction)
        if #frame.searchMatches == 0 then return end
        frame.searchSelection = math.max(1, math.min(#frame.searchMatches, frame.searchSelection + (direction == "UP" and -1 or 1)))
        PaintResults()
        local selectedTop = (frame.searchSelection - 1) * RESULT_STEP
        local top = resultView.scroll:GetVerticalScroll()
        if selectedTop < top then resultView:SetScroll(selectedTop)
        elseif selectedTop + RESULT_STEP > top + resultView.scroll:GetHeight() then
            resultView:SetScroll(selectedTop + RESULT_STEP - resultView.scroll:GetHeight())
        end
    end)
    search:SetScript("OnEditFocusGained", function()
        W.Backdrop(search, "focus")
        UpdateSearch()
    end)
    search:SetScript("OnEditFocusLost", function()
        W.Backdrop(search, "control")
        UpdatePlaceholder()
    end)
    frame:SetScript("OnMouseDown", function() frame:DismissTransient(); search:ClearFocus() end)
    function frame:FitToScreen()
        local availableWidth, availableHeight = UIParent:GetWidth() * 0.94, UIParent:GetHeight() * 0.94
        local scale = math.min(1, availableWidth / WINDOW_WIDTH, availableHeight / WINDOW_HEIGHT)
        self:SetScale(scale)
        -- Restore the saved size within what fits on screen at this scale.
        local maxWidth = math.max(WINDOW_WIDTH, availableWidth / scale)
        local maxHeight = math.max(WINDOW_HEIGHT, availableHeight / scale)
        ApplyResizeBounds(self, maxWidth, maxHeight)
        local db = BD.db or {}
        self:SetSize(math.min(maxWidth, math.max(WINDOW_WIDTH, db.settingsWidth or WINDOW_WIDTH)),
            math.min(maxHeight, math.max(WINDOW_HEIGHT, db.settingsHeight or WINDOW_HEIGHT)))
        if session.left and session.top then
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", session.left / self:GetEffectiveScale(), session.top / self:GetEffectiveScale())
        end
    end
    frame:SetScript("OnEvent", function(self, event, cvar)
        if event == "CVAR_UPDATE" and cvar ~= "nameplateShowEnemies" then return end
        if event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then self:FitToScreen() end
        self:Refresh()
    end)
    frame:SetScript("OnShow", function(self)
        self:RegisterEvent("UI_SCALE_CHANGED"); self:RegisterEvent("DISPLAY_SIZE_CHANGED")
        self:RegisterEvent("CVAR_UPDATE")
        self:RegisterEvent("PLAYER_ENTERING_WORLD"); self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        self:FitToScreen(); self:SizeChrome()
        self:SelectPage(session.page, session.tabs[session.page], true); self:Refresh()
        -- Measure again next frame, after any font loaded during this one.
        C_Timer.After(0, function()
            if not self:IsShown() or self.disposed then return end
            self:SizeChrome(); self:SelectPage(session.page, session.tabs[session.page], true)
        end)
        if BD.db.settingsAnimations then
            if not self.openFade then
                local group = self:CreateAnimationGroup()
                local alpha = group:CreateAnimation("Alpha")
                alpha:SetFromAlpha(0.35); alpha:SetToAlpha(1); alpha:SetDuration(0.16)
                self.openFade = group; self.motionGroups[#self.motionGroups + 1] = group
            end
            self.openFade:Play(); Reveal(self, self.activeView)
        end
        if SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION then pcall(PlaySound, SOUNDKIT.IG_MAINMENU_OPTION) end
    end)
    frame:SetScript("OnHide", function(self)
        if self.resizeGrip and self.resizeGrip:GetButtonState() == "PUSHED" then
            BD.db.settingsWidth = math.floor(self:GetWidth() + 0.5)
            BD.db.settingsHeight = math.floor(self:GetHeight() + 0.5)
        end
        self:StopMovingOrSizing(); SaveScroll()
        if self:GetLeft() and self:GetTop() then
            session.left, session.top = self:GetLeft() * self:GetEffectiveScale(), self:GetTop() * self:GetEffectiveScale()
        end
        self:DismissTransient(); search:ClearFocus(); StopMotion(self)
        self:UnregisterAllEvents(); BD:ReleaseMotionPreviews()
        if SOUNDKIT and SOUNDKIT.IG_MAINMENU_CLOSE then pcall(PlaySound, SOUNDKIT.IG_MAINMENU_CLOSE) end
    end)
    frame:SetResizable(true)
    -- Resize grip in the bottom-right corner. The size is kept between sessions;
    -- double-click returns to the default size.
    local grip = CreateFrame("Button", nil, frame)
    grip:SetSize(16, 16)
    grip:SetPoint("BOTTOMRIGHT", -3, 3)
    grip:SetFrameLevel(frame:GetFrameLevel() + 50)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    local function SaveSize()
        BD.db.settingsWidth = math.floor(frame:GetWidth() + 0.5)
        BD.db.settingsHeight = math.floor(frame:GetHeight() + 0.5)
    end
    grip:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" then return end
        frame:DismissTransient(); search:ClearFocus()
        frame:StartSizing("BOTTOMRIGHT")
    end)
    grip:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing(); frame:SetUserPlaced(false)
        SaveSize()
    end)
    grip:SetScript("OnDoubleClick", function()
        BD.db.settingsWidth, BD.db.settingsHeight = nil, nil
        frame:FitToScreen()
    end)
    W.Tooltip(grip, L["Drag to resize. Double-click to restore the default size."])
    frame.resizeGrip = grip
    frame:FitToScreen(); frame:SelectPage(session.page, session.tabs[session.page], true)
    return frame
end

local function RegisterSettingsStub()
    if not Settings or not Settings.RegisterCanvasLayoutCategory then return end
    local stub = CreateFrame("Frame")
    stub.name = ADDON_NAME; stub:Hide()
    local heading = W.Text(stub, "PlateSCT", 20, -20, 520, "GameFontNormalLarge", GOLD)
    local body = W.Text(stub, L["PlateSCT uses its own settings window.\n\nType /platesct in chat, or click the button below."], 20, -58, 520, "GameFontHighlight")
    local open = W.Button(stub, L["Open PlateSCT"], 200, 26, function()
        if SettingsPanel then HideUIPanel(SettingsPanel) end
        BD:OpenOptions()
    end)
    open:SetPoint("TOPLEFT", body, "BOTTOMLEFT", 0, -20)
    BD.settingsStubTexts = { heading = heading, body = body, open = open }
    local category = Settings.RegisterCanvasLayoutCategory(stub, ADDON_NAME, ADDON_NAME)
    if category then Settings.RegisterAddOnCategory(category); BD.settingsCategory = category end
end

function BD:RegisterOptionsPanel()
    if self.configFrame then return end
    self.configFrame = BuildConfigFrame(); self.optionsPanel = self.configFrame
    if not self.settingsCategory then RegisterSettingsStub() end
end

function BD:RebuildOptionsPanel()
    local old = self.configFrame
    local shown = old and old:IsShown()
    if old then
        old:Hide(); old:DismissTransient(); old.disposed = true; old.retired = true
        old:UnregisterAllEvents(); old:SetParent(nil)
    end
    self:ReleaseMotionPreviews()
    self.configFrame, self.optionsPanel = nil, nil
    self:RegisterOptionsPanel()
    if shown then self.configFrame:Show(); self.configFrame:Raise() end
end

function BD:OpenOptions()
    self.db.welcomeSeen = true
    if self.welcomeFrame then self.welcomeFrame:Hide() end
    if not self.configFrame then self:RegisterOptionsPanel() end
    if self.configFrame:IsShown() then self.configFrame:Hide(); return end
    self.configFrame:Show(); self.configFrame:Raise()
end

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function()
    BD:RegisterOptionsPanel()
    C_Timer.After(0, function()
        if not BD.db.welcomeSeen then BD:OpenWelcome() end
    end)
end)
SLASH_PLATESCT1, SLASH_PLATESCT2 = "/platesct", "/psct"
SlashCmdList["PLATESCT"] = function(message)
    message = string.lower(strtrim(message or ""))
    if message == "welcome" then BD:OpenWelcome(); return end
    if message == "perf" then
        BD:TogglePerf()
        return
    end
    if message == "probe" or message == "meter" then
        if BD.API.IsModern() then BD:DumpDamageMeterProbe()
        else print("|cffff6600PlateSCT:|r " .. L["Meter probe requires Modern API - Midnight & Forever."]) end
        return
    end
    BD:OpenOptions()
end
