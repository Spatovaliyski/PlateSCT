local ADDON_NAME, BD = ...
local L = BD.L

local IS_BETA = true
local ADDON_PAGE_URL = "https://test.com"

local PANEL_WIDTH = 780
local PANEL_HEIGHT = 650
local TITLE_HEIGHT = 44
local SIDEBAR_WIDTH = 188
local FRAME_PAD = 12
local CONTENT_PAD = 26
local CONTENT_WIDTH = 510
local SECTION_GAP = 26
local ROW_GAP = 42
local AFTER_HEADING = 16
local SLIDER_WIDTH = 220
local SLIDER_GAP = 28
local SLIDER_BLOCK = 68
local NAV_HEIGHT = 36
local NAV_GAP = 8

StaticPopupDialogs["PLATESCT_RESET_CONFIRM"] = {
    text = L["Reset PlateSCT settings to defaults?"],
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        BD:ResetToDefaults()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local PAGE_NAMES = { "General", "Display", "Damage", "Tools" }

local function GetPageName(index)
    return L[PAGE_NAMES[index]]
end

local function GetPageSubtitle(index)
    local keys = {
        "Choose whose damage and which nameplates to show.",
        "Control how numbers look and how they animate.",
        "Hide small hits so the big numbers stay readable.",
        "Preview numbers and maintain your setup.",
    }
    return L[keys[index]]
end

BD:ApplyLocale()

local controls = {}

local function ConvertToNumber(text)
    if not text or text == "" then
        return 0
    end

    text = string.gsub(string.lower(text), "%s", "")

    local number, suffix = string.match(text, "^([%d%.]+)([km]?)$")
    if not number then
        return tonumber(text) or 0
    end

    number = tonumber(number) or 0
    if suffix == "k" then
        return math.floor(number * 1000)
    elseif suffix == "m" then
        return math.floor(number * 1000000)
    end
    return math.floor(number)
end

local function ConvertFromNumber(number)
    if not number or number == 0 then
        return "0"
    end

    if number >= 1000000 and number % 1000000 == 0 then
        return string.format("%.0fm", number / 1000000)
    elseif number >= 1000000 then
        return string.format("%.1fm", number / 1000000)
    elseif number >= 1000 and number % 1000 == 0 then
        return string.format("%.0fk", number / 1000)
    elseif number >= 1000 then
        return string.format("%.1fk", number / 1000)
    end
    return tostring(number)
end

local function AddControl(control)
    controls[#controls + 1] = control
end

local function GetAddonVersion()
    local version = "1.0.0"
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or version
    elseif GetAddOnMetadata then
        version = GetAddOnMetadata(ADDON_NAME, "Version") or version
    end
    return version
end

local function GetAddonPageUrl()
    if type(ADDON_PAGE_URL) == "string" then
        local url = ADDON_PAGE_URL:match("^%s*(.-)%s*$") or ""
        if url ~= "" then
            return url
        end
    end
    return nil
end

local function GetBetaWarningBody()
    return L["This addon is in Beta mode. Inaccuracies and errors may show up. Please report such issues on the addon's page."]
end

local function GetBetaWarningTooltip()
    local url = GetAddonPageUrl()
    if url then
        return GetBetaWarningBody() .. "\n\n" .. url
    end
    return GetBetaWarningBody()
end

local function GetBetaNoticeText()
    local url = GetAddonPageUrl()
    if url then
        return GetBetaWarningBody() .. "\n" .. url
    end
    return GetBetaWarningBody()
end

local function AttachTooltip(widget, text)
    if not text or text == "" then
        return
    end
    widget:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(text, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    widget:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function ApplyBackdrop(frame, r, g, b, a, br, bg, bb, ba)
    if not frame.SetBackdrop then
        Mixin(frame, BackdropTemplateMixin)
    end
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(r, g, b, a)
    frame:SetBackdropBorderColor(br, bg, bb, ba)
end

local urlDialog

local function ShowAddonPageUrlDialog()
    local url = GetAddonPageUrl()
    if not url then
        return
    end

    if not urlDialog then
        local frame = CreateFrame("Frame", "PlateSCTUrlDialog", UIParent, "BackdropTemplate")
        frame:SetSize(440, 156)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("FULLSCREEN_DIALOG")
        frame:SetToplevel(true)
        frame:EnableMouse(true)
        frame:SetMovable(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            self:SetUserPlaced(false)
        end)
        tinsert(UISpecialFrames, "PlateSCTUrlDialog")
        ApplyBackdrop(frame, 0.07, 0.07, 0.08, 0.97, 0.38, 0.38, 0.40, 0.95)

        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -16)
        title:SetText(L["Addon page"])

        local help = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        help:SetPoint("TOP", title, "BOTTOM", 0, -10)
        help:SetWidth(392)
        help:SetJustifyH("CENTER")
        help:SetTextColor(0.75, 0.75, 0.76)
        help:SetText(L["Select the URL below, copy it, then paste it in your browser."])

        local edit = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
        edit:SetSize(372, 24)
        edit:SetPoint("TOP", help, "BOTTOM", 2, -16)
        edit:SetAutoFocus(true)
        edit:SetMaxLetters(512)
        edit:SetScript("OnEscapePressed", function()
            frame:Hide()
        end)
        edit:SetScript("OnEnterPressed", function()
            frame:Hide()
        end)
        edit:SetScript("OnEditFocusGained", function(self)
            self:HighlightText()
        end)
        edit:SetScript("OnMouseUp", function(self)
            self:HighlightText()
        end)
        edit:SetScript("OnTextChanged", function(self, userInput)
            if userInput and self.lockedText and self:GetText() ~= self.lockedText then
                self:SetText(self.lockedText)
                self:HighlightText()
            end
        end)
        frame.edit = edit

        local close = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        close:SetSize(96, 24)
        close:SetPoint("BOTTOM", 0, 16)
        close:SetText(CLOSE)
        close:SetScript("OnClick", function()
            frame:Hide()
        end)

        urlDialog = frame
    end

    urlDialog.edit.lockedText = url
    urlDialog.edit:SetText(url)
    urlDialog:Show()
    urlDialog:Raise()
    urlDialog.edit:SetFocus()
    urlDialog.edit:HighlightText()
end

local function AttachBetaNoticeTooltip(widget)
    widget:EnableMouse(true)
    widget:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["PlateSCT is in Beta"], 1, 0.82, 0)
        GameTooltip:AddLine(GetBetaWarningTooltip(), 1, 1, 1, true)
        if GetAddonPageUrl() then
            GameTooltip:AddLine(L["Click to open the addon page URL."], 0.55, 0.78, 1, true)
        end
        GameTooltip:Show()
    end)
    widget:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    widget:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            GameTooltip:Hide()
            ShowAddonPageUrlDialog()
        end
    end)
end

local function CreateHeading(parent, text, x, y, width)
    local header = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    header:SetPoint("TOPLEFT", x, y)
    header:SetText(text)

    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 0.28)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -6)
    line:SetWidth(width or CONTENT_WIDTH)

    return header
end

local function CreateBody(parent, text, x, y, width)
    local desc = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", x, y)
    desc:SetWidth(width or CONTENT_WIDTH)
    desc:SetJustifyH("LEFT")
    desc:SetSpacing(3)
    desc:SetTextColor(0.70, 0.70, 0.72)
    desc:SetText(text)
    return desc
end

local function CreateTag(parent, text, anchor, x, y)
    local tag = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    tag:SetPoint("LEFT", anchor, "RIGHT", x or 8, y or 0)
    tag:SetText(text)
    tag:SetTextColor(1, 0.82, 0.45)
    return tag
end

local function IsCVarEnabled(name)
    local ok, enabled = pcall(function()
        if C_CVar and C_CVar.GetCVar then
            local value = C_CVar.GetCVar(name)
            if value == nil then
                return nil
            end
            return value == "1" or value == "true"
        end
        local value = GetCVar(name)
        if value == nil then
            return nil
        end
        return value == "1" or value == "true"
    end)
    if ok and enabled ~= nil then
        return enabled
    end
    return nil
end

local function AreEnemyNameplatesEnabled()
    local enemyPlates = IsCVarEnabled("nameplateShowEnemies")
    if enemyPlates == false then
        return false
    end
    return true
end

local function CreateNameplateWarningBox(parent, width)
    local box = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    box:SetWidth(width)
    box:Hide()

    box:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    box:SetBackdropColor(0.18, 0.04, 0.04, 0.92)
    box:SetBackdropBorderColor(0.90, 0.22, 0.22, 1)

    box.icon = box:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    box.icon:SetPoint("TOPLEFT", 12, -10)
    box.icon:SetText("|TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:18:18|t")

    box.text = box:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    box.text:SetPoint("TOPLEFT", box.icon, "TOPRIGHT", 8, 2)
    box.text:SetWidth(width - 44)
    box.text:SetJustifyH("LEFT")
    box.text:SetSpacing(3)
    box.text:SetTextColor(1, 0.82, 0.82)
    box.text:SetText(
        L["Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."]
    )

    function box:Refresh()
        if AreEnemyNameplatesEnabled() then
            self:SetHeight(0.001)
            self:Hide()
            return
        end
        local textHeight = self.text:GetStringHeight()
        if not textHeight or textHeight < 16 then
            textHeight = 32
        end
        self:SetHeight(textHeight + 22)
        self:Show()
    end

    box:Refresh()
    return box
end

local function AddPageHeader(parent, title, subtitle)
    local header = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", CONTENT_PAD, -CONTENT_PAD)
    header:SetText(title)

    local sub = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    sub:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
    sub:SetWidth(CONTENT_WIDTH)
    sub:SetJustifyH("LEFT")
    sub:SetSpacing(2)
    sub:SetTextColor(0.68, 0.68, 0.70)
    sub:SetText(subtitle)

    local subHeight = sub:GetStringHeight()
    if not subHeight or subHeight < 12 then
        subHeight = 14
    end

    return -(CONTENT_PAD + 18 + 8 + subHeight + 18)
end

local function CreatePanelButton(parent, label, x, y, width, tooltip, onClick)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetPoint("TOPLEFT", x, y)
    btn:SetText(label)
    btn:SetSize(width or (btn:GetFontString():GetStringWidth() + 32), 24)
    AttachTooltip(btn, tooltip)
    btn:SetScript("OnClick", onClick)
    return btn
end

local function CreateNavButton(parent, text, y)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetHeight(NAV_HEIGHT)
    btn:SetPoint("TOPLEFT", 10, y)
    btn:SetPoint("TOPRIGHT", -10, y)

    local hover = btn:CreateTexture(nil, "BACKGROUND")
    hover:SetAllPoints()
    hover:SetColorTexture(1, 1, 1, 0.06)
    hover:Hide()
    btn.hover = hover

    local selected = btn:CreateTexture(nil, "BACKGROUND")
    selected:SetAllPoints()
    selected:SetColorTexture(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 0.16)
    selected:Hide()
    btn.selectedBg = selected

    local accent = btn:CreateTexture(nil, "ARTWORK")
    accent:SetPoint("TOPLEFT")
    accent:SetPoint("BOTTOMLEFT")
    accent:SetWidth(3)
    accent:SetColorTexture(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
    accent:Hide()
    btn.accent = accent

    btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.label:SetPoint("LEFT", 14, 0)
    btn.label:SetPoint("RIGHT", -10, 0)
    btn.label:SetJustifyH("LEFT")
    btn.label:SetText(text)
    btn.label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

    btn:SetScript("OnEnter", function()
        if not btn.selected then
            hover:Show()
        end
    end)
    btn:SetScript("OnLeave", function()
        hover:Hide()
    end)

    function btn:SetNavSelected(isSelected)
        self.selected = isSelected and true or false
        self.selectedBg:SetShown(self.selected)
        self.accent:SetShown(self.selected)
        self.hover:Hide()
        if self.selected then
            self.label:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        else
            self.label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
        end
    end

    return btn
end

local function CreateCustomScrollPage(parent)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent)
    scrollFrame:SetPoint("TOPLEFT")
    scrollFrame:SetPoint("BOTTOMRIGHT", -22, 0)
    scrollFrame:EnableMouse(true)
    scrollFrame:EnableMouseWheel(true)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(CONTENT_WIDTH + CONTENT_PAD)
    scrollChild:SetHeight(1)
    scrollChild:EnableMouse(true)
    scrollChild:EnableMouseWheel(true)
    scrollFrame:SetScrollChild(scrollChild)

    local track = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    track:SetPoint("TOPRIGHT", -6, -12)
    track:SetPoint("BOTTOMRIGHT", -6, 12)
    track:SetWidth(10)
    track:SetFrameLevel(parent:GetFrameLevel() + 4)
    track:EnableMouse(true)
    track:EnableMouseWheel(true)
    ApplyBackdrop(track, 0.025, 0.025, 0.03, 0.90, 1, 1, 1, 0.08)

    local thumb = CreateFrame("Button", nil, track, "BackdropTemplate")
    thumb:SetWidth(6)
    thumb:SetFrameLevel(track:GetFrameLevel() + 1)
    thumb:RegisterForDrag("LeftButton")
    ApplyBackdrop(
        thumb,
        NORMAL_FONT_COLOR.r * 0.72,
        NORMAL_FONT_COLOR.g * 0.72,
        NORMAL_FONT_COLOR.b * 0.72,
        0.95,
        NORMAL_FONT_COLOR.r,
        NORMAL_FONT_COLOR.g,
        NORMAL_FONT_COLOR.b,
        0.90
    )

    local function GetMaxScroll()
        return math.max(0, (scrollChild:GetHeight() or 0) - (scrollFrame:GetHeight() or 0))
    end

    local function UpdateThumb()
        local trackHeight = track:GetHeight() or 0
        local viewportHeight = scrollFrame:GetHeight() or 0
        local contentHeight = scrollChild:GetHeight() or 0
        local maxScroll = GetMaxScroll()

        if trackHeight <= 0 or viewportHeight <= 0 or contentHeight <= viewportHeight + 0.5 then
            if scrollFrame:GetVerticalScroll() ~= 0 then
                scrollFrame:SetVerticalScroll(0)
            end
            track:Hide()
            return
        end

        track:Show()
        local thumbHeight = math.max(34, math.min(trackHeight, trackHeight * (viewportHeight / contentHeight)))
        thumb:SetHeight(thumbHeight)

        local travel = math.max(0, trackHeight - thumbHeight)
        local currentScroll = scrollFrame:GetVerticalScroll() or 0
        local scroll = math.min(maxScroll, math.max(0, currentScroll))
        if scroll ~= currentScroll then
            scrollFrame:SetVerticalScroll(scroll)
        end
        local offset = maxScroll > 0 and (scroll / maxScroll) * travel or 0
        thumb:ClearAllPoints()
        thumb:SetPoint("TOP", track, "TOP", 0, -offset)
    end

    local function SetScroll(value)
        local maxScroll = GetMaxScroll()
        scrollFrame:SetVerticalScroll(math.min(maxScroll, math.max(0, value or 0)))
        UpdateThumb()
    end

    local function OnMouseWheel(_, delta)
        SetScroll(scrollFrame:GetVerticalScroll() - (delta * 48))
    end

    scrollFrame:SetScript("OnMouseWheel", OnMouseWheel)
    scrollChild:SetScript("OnMouseWheel", OnMouseWheel)
    track:SetScript("OnMouseWheel", OnMouseWheel)
    scrollFrame:SetScript("OnVerticalScroll", UpdateThumb)
    scrollFrame:SetScript("OnScrollRangeChanged", UpdateThumb)
    scrollFrame:SetScript("OnSizeChanged", function(_, width)
        if width and width > 0 then
            scrollChild:SetWidth(width)
        end
        UpdateThumb()
    end)
    scrollChild:SetScript("OnSizeChanged", UpdateThumb)

    thumb:SetScript("OnEnter", function(self)
        self:SetBackdropColor(
            NORMAL_FONT_COLOR.r,
            NORMAL_FONT_COLOR.g,
            NORMAL_FONT_COLOR.b,
            1
        )
    end)
    thumb:SetScript("OnLeave", function(self)
        if not self.dragging then
            self:SetBackdropColor(
                NORMAL_FONT_COLOR.r * 0.72,
                NORMAL_FONT_COLOR.g * 0.72,
                NORMAL_FONT_COLOR.b * 0.72,
                0.95
            )
        end
    end)
    thumb:SetScript("OnDragStart", function(self)
        self.dragging = true
        local _, cursorY = GetCursorPosition()
        self.dragStartCursorY = cursorY / UIParent:GetEffectiveScale()
        self.dragStartScroll = scrollFrame:GetVerticalScroll()
        self:SetScript("OnUpdate", function(dragThumb)
            local _, currentCursorY = GetCursorPosition()
            currentCursorY = currentCursorY / UIParent:GetEffectiveScale()

            local maxScroll = GetMaxScroll()
            local travel = math.max(1, (track:GetHeight() or 0) - (dragThumb:GetHeight() or 0))
            local cursorDelta = dragThumb.dragStartCursorY - currentCursorY
            SetScroll(dragThumb.dragStartScroll + (cursorDelta * maxScroll / travel))
        end)
    end)
    thumb:SetScript("OnDragStop", function(self)
        self.dragging = false
        self:SetScript("OnUpdate", nil)
        self:SetBackdropColor(
            NORMAL_FONT_COLOR.r * 0.72,
            NORMAL_FONT_COLOR.g * 0.72,
            NORMAL_FONT_COLOR.b * 0.72,
            0.95
        )
    end)

    track:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" or not thumb:IsShown() then
            return
        end
        local _, cursorY = GetCursorPosition()
        cursorY = cursorY / UIParent:GetEffectiveScale()
        local _, thumbY = thumb:GetCenter()
        if not thumbY then
            return
        end
        local page = (scrollFrame:GetHeight() or 0) * 0.82
        if cursorY > thumbY then
            SetScroll(scrollFrame:GetVerticalScroll() - page)
        else
            SetScroll(scrollFrame:GetVerticalScroll() + page)
        end
    end)

    scrollChild.UpdateScrollBar = UpdateThumb
    C_Timer.After(0, UpdateThumb)
    return scrollFrame, scrollChild
end

local function CreateCheckbox(parent, label, tooltip, x, y, key, onChanged)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", x, y)
    if cb.Text then
        cb.Text:Hide()
    end

    cb.label = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    cb.label:SetPoint("LEFT", cb, "RIGHT", 6, 0)
    cb.label:SetJustifyH("LEFT")
    cb.label:SetText(label)

    local hitPad = math.min((cb.label:GetStringWidth() or 120) + 16, CONTENT_WIDTH - 40)
    cb:SetHitRectInsets(0, -hitPad, 0, 0)
    AttachTooltip(cb, tooltip)

    cb:SetScript("OnClick", function(self)
        BD.db[key] = self:GetChecked() and true or false
        if onChanged then
            onChanged(BD.db[key])
        end
        if parent.GetRootPanel and parent:GetRootPanel().Refresh then
            parent:GetRootPanel():Refresh()
        end
    end)

    cb.Refresh = function(self)
        self:SetChecked(BD.db[key] and true or false)
    end

    AddControl(cb)
    return cb
end

local function SliderValueMatchesRecommended(value, recommendedValue, step)
    if recommendedValue == nil then
        return false
    end
    if step and step < 1 then
        return math.abs(value - recommendedValue) < (step * 0.25)
    end
    return value == recommendedValue
end

local function CreateSlider(parent, label, x, y, key, minValue, maxValue, step, formatter, width, recommendedValue)
    width = width or SLIDER_WIDTH

    local caption = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    caption:SetPoint("TOPLEFT", x, y)
    caption:SetText(label)

    local slider = CreateFrame("Slider", nil, parent, "MinimalSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y - 22)
    slider:SetSize(width, 18)
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:EnableMouseWheel(true)

    slider.valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    slider.valueText:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 6)

    slider.recommendedTag = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slider.recommendedTag:SetPoint("RIGHT", slider.valueText, "LEFT", -8, 0)
    slider.recommendedTag:SetText(L["Recommended"])
    slider.recommendedTag:SetTextColor(1, 0.82, 0.45)
    slider.recommendedTag:Hide()

    local function UpdateRecommendedTag(value)
        if SliderValueMatchesRecommended(value, recommendedValue, step) then
            slider.recommendedTag:Show()
        else
            slider.recommendedTag:Hide()
        end
    end

    local function ApplyValue(value)
        value = math.floor(value / step + 0.5) * step
        if step < 1 then
            value = math.floor(value * 10 + 0.5) / 10
        end
        BD.db[key] = value
        slider.valueText:SetText(formatter(value))
        UpdateRecommendedTag(value)
    end

    slider:SetScript("OnValueChanged", function(_, value)
        ApplyValue(value)
    end)

    slider:SetScript("OnMouseWheel", function(self, delta)
        local value = (BD.db[key] or minValue) + (step * delta)
        value = math.min(maxValue, math.max(minValue, value))
        self:SetValue(value)
    end)

    slider.Refresh = function(self)
        local value = BD.db[key] or minValue
        self:SetValue(value)
        self.valueText:SetText(formatter(value))
        UpdateRecommendedTag(value)
    end

    AddControl(slider)
    return slider
end

local function NewLayout(parent, x, y, width)
    return {
        parent = parent,
        x = x,
        y = y,
        width = width or CONTENT_WIDTH,

        Gap = function(self, px)
            self.y = self.y - (px or SECTION_GAP)
        end,

        Heading = function(self, text)
            CreateHeading(self.parent, text, self.x, self.y, self.width)
            self.y = self.y - (16 + 6 + AFTER_HEADING)
        end,

        Body = function(self, text)
            local desc = CreateBody(self.parent, text, self.x, self.y, self.width)
            local height = desc:GetStringHeight()
            if not height or height < 14 then
                height = 16
            end
            self.y = self.y - (height + 14)
            return desc
        end,

        Checkbox = function(self, label, tooltip, key, onChanged)
            local cb = CreateCheckbox(self.parent, label, tooltip, self.x, self.y, key, onChanged)
            self.y = self.y - ROW_GAP
            return cb
        end,

        Button = function(self, label, width, tooltip, onClick)
            local btn = CreatePanelButton(self.parent, label, self.x, self.y, width, tooltip, onClick)
            self.y = self.y - 36
            return btn
        end,
    }
end

local function CreateThresholdInput(parent, layout)
    layout:Heading(L["Minimum damage threshold"])
    layout:Body(L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."])

    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetSize(148, 24)
    box:SetPoint("TOPLEFT", layout.x + 6, layout.y)
    box:SetAutoFocus(false)
    box:SetMaxLetters(12)
    box:SetNumeric(false)
    AttachTooltip(box, L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."])

    local function Commit(self)
        local value = math.max(0, ConvertToNumber(self:GetText()))
        BD.db.minDamage = value
        self:SetText(ConvertFromNumber(value))
        BD:RebuildThresholdCurve()
    end

    box:SetScript("OnEnterPressed", function(self)
        Commit(self)
        self:ClearFocus()
    end)

    box:SetScript("OnEscapePressed", function(self)
        self:SetText(ConvertFromNumber(BD.db.minDamage or 0))
        self:ClearFocus()
    end)

    box:SetScript("OnEditFocusLost", function(self)
        Commit(self)
    end)

    box.Refresh = function(self)
        self:SetText(ConvertFromNumber(BD.db.minDamage or 0))
    end

    AddControl(box)
    layout.y = layout.y - 40
    layout:Body(L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."])
    return box
end

local function CreateStyleSelector(parent, layout, rootPanel)
    layout:Heading(L["Number style"])
    layout:Body(L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."])

    local retail = CreateFrame("CheckButton", nil, parent, "UIRadioButtonTemplate")
    retail:SetPoint("TOPLEFT", layout.x, layout.y)
    retail.text = retail:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    retail.text:SetPoint("LEFT", retail, "RIGHT", 6, 0)
    retail.text:SetText(L["Modern"])
    retail:SetHitRectInsets(0, -(retail.text:GetStringWidth() + 10), 0, 0)

    local classic = CreateFrame("CheckButton", nil, parent, "UIRadioButtonTemplate")
    classic:SetPoint("LEFT", retail.text, "RIGHT", 28, 0)
    classic.text = classic:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    classic.text:SetPoint("LEFT", classic, "RIGHT", 6, 0)
    classic.text:SetText(L["Classic"])
    classic:SetHitRectInsets(0, -(classic.text:GetStringWidth() + 10), 0, 0)

    local function SyncRadios()
        retail:SetChecked(BD.db.numberStyle == "retail")
        classic:SetChecked(BD.db.numberStyle == "classic")
    end

    retail:SetScript("OnClick", function()
        BD.db.numberStyle = "retail"
        SyncRadios()
        rootPanel:Refresh()
    end)

    classic:SetScript("OnClick", function()
        BD.db.numberStyle = "classic"
        SyncRadios()
        rootPanel:Refresh()
    end)

    retail.Refresh = SyncRadios
    classic.Refresh = SyncRadios
    AddControl(retail)
    AddControl(classic)

    layout.y = layout.y - 36
end

local localeMenu

local function HideLocaleMenu()
    if localeMenu then
        localeMenu:Hide()
    end
end

local function CreateLocaleSelector(parent, layout)
    layout:Heading(L["Language"])
    layout:Body(L["Choose the language used by PlateSCT panels and messages."])

    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", layout.x, layout.y)
    button:SetSize(240, 24)

    local function SyncLabel()
        button:SetText(BD:GetLocalePreferenceLabel(BD.db.locale) .. "  v")
    end

    SyncLabel()
    button.Refresh = SyncLabel
    AddControl(button)

    if not localeMenu then
        local menu = CreateFrame("Frame", "PlateSCTLocaleMenu", UIParent, "BackdropTemplate")
        menu:SetFrameStrata("FULLSCREEN_DIALOG")
        menu:SetToplevel(true)
        menu:SetClampedToScreen(true)
        menu:EnableMouse(true)
        menu:Hide()
        ApplyBackdrop(menu, 0.08, 0.08, 0.09, 0.98, 0.38, 0.38, 0.40, 0.95)
        localeMenu = menu

        menu:SetScript("OnHide", function(self)
            self.owner = nil
        end)

        local closeWatcher = CreateFrame("Frame", nil, menu)
        closeWatcher:SetScript("OnUpdate", function()
            if not menu:IsShown() then
                return
            end
            if IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton") then
                if not menu:IsMouseOver() and not (menu.owner and menu.owner:IsMouseOver()) then
                    HideLocaleMenu()
                end
            end
        end)
    end

    local function ShowMenu()
        local menu = localeMenu
        menu.owner = button

        if menu.buttons then
            for _, entry in ipairs(menu.buttons) do
                entry:Hide()
            end
        else
            menu.buttons = {}
        end

        local selected = BD:NormalizeLocaleCode(BD.db.locale or "auto")
        local y = -8
        local width = 220

        for index, option in ipairs(BD.LOCALE_OPTIONS) do
            local entry = menu.buttons[index]
            if not entry then
                entry = CreateFrame("Button", nil, menu)
                entry:SetHeight(24)
                entry.label = entry:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                entry.label:SetPoint("LEFT", 12, 0)
                entry.label:SetPoint("RIGHT", -12, 0)
                entry.label:SetJustifyH("LEFT")
                entry.hover = entry:CreateTexture(nil, "BACKGROUND")
                entry.hover:SetAllPoints()
                entry.hover:SetColorTexture(1, 1, 1, 0.08)
                entry.hover:Hide()
                entry:SetScript("OnEnter", function(self)
                    self.hover:Show()
                end)
                entry:SetScript("OnLeave", function(self)
                    self.hover:Hide()
                end)
                menu.buttons[index] = entry
            end

            entry:ClearAllPoints()
            entry:SetPoint("TOPLEFT", 1, y)
            entry:SetPoint("TOPRIGHT", -1, y)
            entry:SetText("")
            entry.label:SetText(BD:GetLocaleOptionLabel(option))
            if option.id == selected then
                entry.label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
            else
                entry.label:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            end
            entry:SetScript("OnClick", function()
                HideLocaleMenu()
                if BD:NormalizeLocaleCode(BD.db.locale or "auto") ~= option.id then
                    BD:SetLocalePreference(option.id)
                end
            end)
            entry:Show()
            y = y - 24
            width = math.max(width, (entry.label:GetStringWidth() or 0) + 28)
        end

        menu:SetSize(width, (#BD.LOCALE_OPTIONS * 24) + 16)
        menu:ClearAllPoints()
        menu:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -2)
        menu:Show()
        menu:Raise()
    end

    button:SetScript("OnClick", function()
        if localeMenu and localeMenu:IsShown() and localeMenu.owner == button then
            HideLocaleMenu()
        else
            ShowMenu()
        end
    end)

    layout.y = layout.y - 40
    return button
end

local function BuildPageGeneral(parent, rootPanel)
    local layout = NewLayout(parent, CONTENT_PAD, AddPageHeader(parent, GetPageName(1), GetPageSubtitle(1)), CONTENT_WIDTH)

    layout:Heading(L["Combat text"])
    layout:Checkbox(L["Enable PlateSCT"], L["Show floating damage numbers on nameplates."], "enabled")
    layout:Checkbox(
        L["Hide Blizzard floating combat text"],
        L["Turns off default in-world damage numbers."],
        "hideBlizzardFCT",
        function(checked)
            if checked then
                BD:ApplyBlizzardFCTSetting()
            else
                BD:RestoreBlizzardFCTSetting()
            end
        end
    )

    layout:Gap(SECTION_GAP)
    parent.nameplateWarning = CreateNameplateWarningBox(parent, CONTENT_WIDTH)
    parent.nameplateWarning:SetPoint("TOPLEFT", parent, "TOPLEFT", layout.x, layout.y)

    parent.whoSection = CreateFrame("Frame", nil, parent)
    parent.whoSection:SetPoint("TOPLEFT", parent.nameplateWarning, "BOTTOMLEFT", 0, -14)
    parent.whoSection:SetWidth(CONTENT_WIDTH)

    local whoLayout = NewLayout(parent.whoSection, 0, -6, CONTENT_WIDTH)
    whoLayout:Heading(L["Who to show"])
    local onlyMine = whoLayout:Checkbox(
        L["Only my damage"],
        L["Show hits on your current target when you recently cast or auto-attacked. Midnight cannot prove who dealt the hit in a group."],
        "onlyMyDamage",
        function(checked)
            if checked then
                BD.db.allNameplates = false
            end
            rootPanel:UpdateDependentStates()
        end
    )
    parent.onlyMineTag = CreateTag(parent.whoSection, L["Target"], onlyMine.label)
    parent.onlyMineBody = whoLayout:Body(
        L["Best effort on your current target. Other players hitting the same mob can still show up. Off-target cleave and DoTs are not shown."]
    )
    local allPlates = whoLayout:Checkbox(
        L["All engaged nameplates"],
        L["Show every hit on every visible hostile nameplate. This is the accurate Midnight mode; it includes damage from every source."],
        "allNameplates"
    )
    parent.allPlatesBody = whoLayout:Body(
        L["Available when Only my damage is off. Use this to see numbers on every enemy plate."]
    )
    local petDamage = whoLayout:Checkbox(
        L["Include pet damage"],
        L["In Only my damage mode, also treat a recent pet cast as your hit."],
        "includePetDamage"
    )

    parent.allPlatesCheckbox = allPlates
    parent.onlyMineCheckbox = onlyMine
    parent.petDamageCheckbox = petDamage
    parent.whoSection:SetHeight(math.max(-whoLayout.y + 12, 120))
end

local function BuildPageDisplay(parent, rootPanel)
    local layout = NewLayout(parent, CONTENT_PAD, AddPageHeader(parent, GetPageName(2), GetPageSubtitle(2)), CONTENT_WIDTH)

    CreateStyleSelector(parent, layout, rootPanel)
    layout:Checkbox(
        L["Color by damage school"],
        L["Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."],
        "useSchoolColors"
    )
    local spellIcon = layout:Checkbox(
        L["Show spell icon"],
        L["Display the spell's icon to the left of the damage number. Uses your last cast or auto-attack."],
        "showSpellIcon"
    )
    parent.spellIconCheckbox = spellIcon
    parent.spellIconBody = layout:Body(
        L["Uses your last spell in Only my damage mode. Left of the number."]
    )

    layout:Gap(SECTION_GAP)
    layout:Heading(L["Text style"])
    layout:Checkbox(L["Abbreviate numbers"], L["Display large numbers as 214k or 1.2M."], "abbreviate")

    layout:Gap(SECTION_GAP)
    layout:Heading(L["Animation"])
    local sliderY = layout.y
    CreateSlider(parent, L["Font size"], layout.x, sliderY, "fontSize", 10, 24, 1, function(value)
        return tostring(value)
    end, SLIDER_WIDTH, 12)
    CreateSlider(parent, L["Scroll offset"], layout.x + SLIDER_WIDTH + SLIDER_GAP, sliderY, "floatDistance", 10, 40, 5, function(value)
        return string.format(L["%d px"], value)
    end, SLIDER_WIDTH, 20)
    layout.y = sliderY - SLIDER_BLOCK
    CreateSlider(parent, L["Display duration"], layout.x, layout.y, "duration", 0.5, 2.0, 0.1, function(value)
        return string.format(L["%.1fs"], value)
    end, SLIDER_WIDTH, 0.8)
    layout.y = layout.y - SLIDER_BLOCK

    parent:SetHeight(math.max(1, -layout.y + CONTENT_PAD))
    local scrollFrame = parent:GetParent()
    if scrollFrame and scrollFrame.UpdateScrollChildRect then
        scrollFrame:UpdateScrollChildRect()
    end
    if parent.UpdateScrollBar then
        C_Timer.After(0, parent.UpdateScrollBar)
    end
end

local function BuildPageDamage(parent)
    local layout = NewLayout(parent, CONTENT_PAD, AddPageHeader(parent, GetPageName(3), GetPageSubtitle(3)), CONTENT_WIDTH)
    CreateThresholdInput(parent, layout)
end

local function BuildPageTools(parent)
    local layout = NewLayout(parent, CONTENT_PAD, AddPageHeader(parent, GetPageName(4), GetPageSubtitle(4)), CONTENT_WIDTH)

    CreateLocaleSelector(parent, layout)

    layout:Gap(SECTION_GAP)
    layout:Heading(L["Preview"])
    layout:Body(L["Target an enemy, then spawn sample numbers on its nameplate."])
    layout:Button(L["Test on Target"], 160, L["Show sample damage numbers on your target."], function()
        BD:ShowTestNumbers()
    end)

    layout:Gap(SECTION_GAP)
    layout:Heading(L["Maintenance"])
    layout:Checkbox(L["Debug mode"], L["Print combat events to chat for troubleshooting."], "debug")
    layout:Gap(8)
    layout:Button(L["Dump meter now"], 160, L["Open a copyable snapshot of C_DamageMeter fields. Use this in combat while hitting a target."], function()
        BD:DumpDamageMeterProbe()
    end)
    layout:Gap(8)
    layout:Button(L["Reset Defaults"], 160, L["Restore every PlateSCT setting to its default."], function()
        StaticPopup_Show("PLATESCT_RESET_CONFIRM")
    end)
end

local function RefreshControls(panel)
    for _, control in ipairs(controls) do
        if control.Refresh then
            control:Refresh()
        end
    end
    if panel.UpdateDependentStates then
        panel:UpdateDependentStates()
    end
end

local function BuildConfigFrame()
    local frame = CreateFrame("Frame", "PlateSCTConfigFrame", UIParent, "BackdropTemplate")
    frame:Hide()
    frame:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self:SetUserPlaced(false)
    end)
    tinsert(UISpecialFrames, "PlateSCTConfigFrame")

    ApplyBackdrop(frame, 0.07, 0.07, 0.08, 0.97, 0.38, 0.38, 0.40, 0.95)

    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetPoint("TOPLEFT", 1, -1)
    titleBar:SetPoint("TOPRIGHT", -1, -1)
    titleBar:SetHeight(TITLE_HEIGHT)
    titleBar:EnableMouse(true)
    -- Move the parent via OnMouseDown/Up (not OnDrag*). Dragging a parent from a
    -- child's OnDragStart miscomputes the cursor offset, so the frame jumps.
    titleBar:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            frame:StartMoving(true)
        end
    end)
    titleBar:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            frame:StopMovingOrSizing()
            frame:SetUserPlaced(false)
        end
    end)

    local titleBg = titleBar:CreateTexture(nil, "BACKGROUND")
    titleBg:SetAllPoints()
    titleBg:SetColorTexture(1, 1, 1, 0.035)

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", 18, 0)
    title:SetText("PlateSCT")

    local version = titleBar:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    version:SetPoint("LEFT", title, "RIGHT", 10, 0)
    version:SetText(GetAddonVersion())

    if IS_BETA then
        local betaTag = CreateFrame("Frame", nil, titleBar)
        betaTag:SetPoint("LEFT", version, "RIGHT", 10, 1)
        betaTag:SetSize(42, 16)
        betaTag:EnableMouse(true)

        local betaBg = betaTag:CreateTexture(nil, "BACKGROUND")
        betaBg:SetAllPoints()
        betaBg:SetColorTexture(0.82, 0.42, 0.08, 0.95)

        local betaLabel = betaTag:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        betaLabel:SetPoint("CENTER", 0, 0)
        betaLabel:SetText("BETA")
        betaLabel:SetTextColor(1, 0.96, 0.82)

        AttachBetaNoticeTooltip(betaTag)
    end

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -6, -6)
    close:SetScript("OnClick", function()
        frame:Hide()
    end)

    local titleRule = frame:CreateTexture(nil, "ARTWORK")
    titleRule:SetColorTexture(1, 1, 1, 0.08)
    titleRule:SetHeight(1)
    titleRule:SetPoint("TOPLEFT", 1, -(TITLE_HEIGHT + 1))
    titleRule:SetPoint("TOPRIGHT", -1, -(TITLE_HEIGHT + 1))

    local body = CreateFrame("Frame", nil, frame)
    body:SetPoint("TOPLEFT", FRAME_PAD, -(TITLE_HEIGHT + 8))
    body:SetPoint("BOTTOMRIGHT", -FRAME_PAD, FRAME_PAD)

    local sidebar = CreateFrame("Frame", nil, body, "BackdropTemplate")
    sidebar:SetPoint("TOPLEFT")
    sidebar:SetPoint("BOTTOMLEFT")
    sidebar:SetWidth(SIDEBAR_WIDTH)
    ApplyBackdrop(sidebar, 0.04, 0.04, 0.05, 0.65, 1, 1, 1, 0.06)

    local content = CreateFrame("Frame", nil, body, "BackdropTemplate")
    content:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 10, 0)
    content:SetPoint("BOTTOMRIGHT")
    ApplyBackdrop(content, 0.10, 0.10, 0.11, 0.35, 1, 1, 1, 0.06)

    local versionFooter = sidebar:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    versionFooter:SetJustifyH("LEFT")
    versionFooter:SetText(L["/platesct  ·  ESC to close"])

    if IS_BETA then
        local betaNotice = sidebar:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
        betaNotice:SetPoint("BOTTOMLEFT", 16, 14)
        betaNotice:SetWidth(SIDEBAR_WIDTH - 32)
        betaNotice:SetJustifyH("LEFT")
        betaNotice:SetJustifyV("BOTTOM")
        betaNotice:SetSpacing(2)
        betaNotice:SetWordWrap(true)
        betaNotice:SetTextColor(0.95, 0.72, 0.28)
        betaNotice:SetText(GetBetaNoticeText())
        local noticeHeight = betaNotice:GetStringHeight()
        if not noticeHeight or noticeHeight < 48 then
            noticeHeight = 62
        end
        betaNotice:SetHeight(noticeHeight)

        versionFooter:SetPoint("BOTTOMLEFT", betaNotice, "TOPLEFT", 0, 8)
        versionFooter:SetPoint("BOTTOMRIGHT", betaNotice, "TOPRIGHT", 0, 8)

        local noticeHit = CreateFrame("Frame", nil, sidebar)
        noticeHit:SetPoint("BOTTOMLEFT", betaNotice, "BOTTOMLEFT", -4, -4)
        noticeHit:SetPoint("TOPRIGHT", versionFooter, "TOPRIGHT", 4, 4)
        noticeHit:SetFrameLevel(sidebar:GetFrameLevel() + 3)
        AttachBetaNoticeTooltip(noticeHit)
    else
        versionFooter:SetPoint("BOTTOMLEFT", 16, 14)
        versionFooter:SetPoint("BOTTOMRIGHT", -16, 14)
    end

    local pages = {}
    local navButtons = {}
    local selectedPage = 1

    local function SelectPage(index)
        selectedPage = index
        BD.optionsSelectedPage = index
        for i, page in ipairs(pages) do
            page:SetShown(i == index)
            if i == index and page.scrollChild and page.scrollChild.UpdateScrollBar then
                C_Timer.After(0, page.scrollChild.UpdateScrollBar)
            end
            if navButtons[i] then
                navButtons[i]:SetNavSelected(i == index)
            end
        end
    end

    for index, _ in ipairs(PAGE_NAMES) do
        local page = CreateFrame("Frame", nil, content)
        page:SetAllPoints(content)
        page:Hide()
        page.GetRootPanel = function()
            return frame
        end
        if index == 2 then
            page.scrollFrame, page.scrollChild = CreateCustomScrollPage(page)
            page.scrollChild.GetRootPanel = page.GetRootPanel
        end

        pages[index] = page
        local navY = -14 - ((index - 1) * (NAV_HEIGHT + NAV_GAP))
        navButtons[index] = CreateNavButton(sidebar, GetPageName(index), navY)
        navButtons[index]:SetFrameLevel(sidebar:GetFrameLevel() + 2)
        navButtons[index]:SetScript("OnClick", function()
            SelectPage(index)
        end)
    end

    BuildPageGeneral(pages[1], frame)
    BuildPageDisplay(pages[2].scrollChild or pages[2], frame)
    BuildPageDamage(pages[3])
    BuildPageTools(pages[4])

    function frame:UpdateDependentStates()
        local general = pages[1]
        local display = pages[2].scrollChild or pages[2]
        if not general then
            return
        end
        if general.nameplateWarning then
            general.nameplateWarning:Refresh()
        end
        if not general.allPlatesCheckbox then
            return
        end
        local onlyMineOn = BD.db.onlyMyDamage and true or false
        if onlyMineOn then
            BD.db.allNameplates = false
        end
        local allowAllPlates = not onlyMineOn
        general.allPlatesCheckbox:SetEnabled(allowAllPlates)
        general.allPlatesCheckbox:SetChecked(BD.db.allNameplates and true or false)
        general.allPlatesCheckbox:SetAlpha(allowAllPlates and 1 or 0.55)
        if allowAllPlates then
            general.allPlatesCheckbox.label:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        else
            general.allPlatesCheckbox.label:SetTextColor(0.5, 0.5, 0.5)
        end
        if general.allPlatesBody then
            if allowAllPlates then
                general.allPlatesBody:SetTextColor(0.70, 0.70, 0.72)
            else
                general.allPlatesBody:SetTextColor(0.45, 0.45, 0.46)
            end
        end
        if general.petDamageCheckbox then
            general.petDamageCheckbox:SetEnabled(onlyMineOn)
            general.petDamageCheckbox:SetAlpha(onlyMineOn and 1 or 0.55)
            if onlyMineOn then
                general.petDamageCheckbox.label:SetTextColor(
                    HIGHLIGHT_FONT_COLOR.r,
                    HIGHLIGHT_FONT_COLOR.g,
                    HIGHLIGHT_FONT_COLOR.b
                )
            else
                general.petDamageCheckbox.label:SetTextColor(0.5, 0.5, 0.5)
            end
        end
        if display and display.spellIconCheckbox then
            display.spellIconCheckbox:SetEnabled(onlyMineOn)
            display.spellIconCheckbox:SetAlpha(onlyMineOn and 1 or 0.55)
            if onlyMineOn then
                display.spellIconCheckbox.label:SetTextColor(
                    HIGHLIGHT_FONT_COLOR.r,
                    HIGHLIGHT_FONT_COLOR.g,
                    HIGHLIGHT_FONT_COLOR.b
                )
            else
                display.spellIconCheckbox.label:SetTextColor(0.5, 0.5, 0.5)
            end
        end
        if display and display.spellIconBody then
            if onlyMineOn then
                display.spellIconBody:SetTextColor(0.70, 0.70, 0.72)
            else
                display.spellIconBody:SetTextColor(0.45, 0.45, 0.46)
            end
        end
    end

    function frame:Refresh()
        RefreshControls(self)
        self:UpdateDependentStates()
    end

    local function HookNameplateWarningEvents()
        local general = pages[1]
        if not general or not general.nameplateWarning then
            return
        end
        general.nameplateWarning:RegisterEvent("CVAR_UPDATE")
        general.nameplateWarning:SetScript("OnEvent", function(self, _, cvarName)
            if cvarName == "nameplateShowEnemies" then
                self:Refresh()
            end
        end)
    end

    local function UnhookNameplateWarningEvents()
        local general = pages[1]
        if not general or not general.nameplateWarning then
            return
        end
        general.nameplateWarning:UnregisterEvent("CVAR_UPDATE")
        general.nameplateWarning:SetScript("OnEvent", nil)
    end

    frame:SetScript("OnShow", function(self)
        if SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION then
            pcall(PlaySound, SOUNDKIT.IG_MAINMENU_OPTION)
        end
        HookNameplateWarningEvents()
        self:Refresh()
        SelectPage(selectedPage or 1)
    end)

    frame:SetScript("OnHide", function()
        UnhookNameplateWarningEvents()
        if SOUNDKIT and SOUNDKIT.IG_MAINMENU_CLOSE then
            pcall(PlaySound, SOUNDKIT.IG_MAINMENU_CLOSE)
        end
    end)

    frame.pages = pages
    SelectPage(BD.optionsSelectedPage or 1)
    return frame
end

local function RegisterSettingsStub()
    if not Settings or not Settings.RegisterCanvasLayoutCategory then
        return
    end

    local stub = CreateFrame("Frame")
    stub.name = ADDON_NAME
    stub:Hide()

    local heading = stub:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", 20, -20)
    heading:SetText("PlateSCT")

    local body = stub:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    body:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -14)
    body:SetWidth(520)
    body:SetJustifyH("LEFT")
    body:SetSpacing(3)
    body:SetTextColor(0.75, 0.75, 0.76)
    body:SetText(L["PlateSCT uses its own settings window.\n\nType /platesct in chat, or click the button below."])

    local open = CreateFrame("Button", nil, stub, "UIPanelButtonTemplate")
    open:SetSize(200, 26)
    open:SetPoint("TOPLEFT", body, "BOTTOMLEFT", 0, -20)
    open:SetText(L["Open PlateSCT"])
    open:SetScript("OnClick", function()
        if SettingsPanel then
            HideUIPanel(SettingsPanel)
        end
        BD:OpenOptions()
    end)

    BD.settingsStubTexts = {
        heading = heading,
        body = body,
        open = open,
    }

    local category = Settings.RegisterCanvasLayoutCategory(stub, ADDON_NAME, ADDON_NAME)
    if category then
        Settings.RegisterAddOnCategory(category)
        BD.settingsCategory = category
    end
end

function BD:RegisterOptionsPanel()
    if self.configFrame then
        return
    end

    controls = {}
    self.configFrame = BuildConfigFrame()
    self.optionsPanel = self.configFrame
    if not self.settingsCategory then
        RegisterSettingsStub()
    end
end

function BD:RebuildOptionsPanel()
    HideLocaleMenu()
    local wasShown = self.configFrame and self.configFrame:IsShown()
    if self.configFrame then
        self.configFrame:Hide()
        self.configFrame:UnregisterAllEvents()
        self.configFrame:SetParent(nil)
        self.configFrame = nil
        self.optionsPanel = nil
    end
    controls = {}
    self:RegisterOptionsPanel()
    if wasShown and self.configFrame then
        self.configFrame:Show()
        self.configFrame:Raise()
        self.configFrame:Refresh()
    end
end

function BD:OpenOptions()
    HideLocaleMenu()
    if not self.configFrame then
        self:RegisterOptionsPanel()
    end

    if self.configFrame:IsShown() then
        self.configFrame:Hide()
        return
    end

    self.configFrame:Show()
    self.configFrame:Raise()
    self.configFrame:Refresh()
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    BD:RegisterOptionsPanel()
end)

SLASH_PLATESCT1 = "/platesct"
SLASH_PLATESCT2 = "/psct"

SlashCmdList["PLATESCT"] = function(msg)
    msg = string.lower(strtrim(msg or ""))
    if msg == "probe" or msg == "meter" then
        BD:DumpDamageMeterProbe()
        return
    end
    if not BD.configFrame then
        BD:RegisterOptionsPanel()
    end
    BD:OpenOptions()
end
