local ADDON_NAME, BD = ...
local L = BD.L

local PANEL_WIDTH = 780
local PANEL_HEIGHT = 650
local TITLE_HEIGHT = 44
local SIDEBAR_WIDTH = 188
local FRAME_PAD = 12
local CONTENT_PAD = 26
local CONTENT_WIDTH = 510
local SECTION_GAP = 26
local ROW_GAP = 42
local CHECKBOX_HEIGHT = 26
local NOTE_TOP_GAP = 8
local NOTE_BOTTOM_GAP = 16
local CHECKBOX_LABEL_GAP = 6
local CHECKBOX_LABEL_NUDGE_Y = 2
local AFTER_HEADING = 16
local SLIDER_WIDTH = 220
local SLIDER_GAP = 28
local SLIDER_BLOCK = 68
local NAV_HEIGHT = 36
local NAV_GAP = 8

local function IsModernUI()
    return BD.API and BD.API.IsModern()
end

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
    cb.label:SetPoint("LEFT", cb, "RIGHT", CHECKBOX_LABEL_GAP, CHECKBOX_LABEL_NUDGE_Y)
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
            self.y = self.y - (height + NOTE_BOTTOM_GAP)
            return desc
        end,

        -- Body text indented to match checkbox title (not the check icon).
        Note = function(self, text)
            local checkboxAdvance = ROW_GAP
            local desiredTop = CHECKBOX_HEIGHT + NOTE_TOP_GAP
            if checkboxAdvance > desiredTop then
                self.y = self.y + (checkboxAdvance - desiredTop)
            end
            local inset = self._checkboxTextInset or (26 + CHECKBOX_LABEL_GAP)
            local desc = CreateBody(self.parent, text, self.x + inset, self.y, math.max(40, self.width - inset))
            local height = desc:GetStringHeight()
            if not height or height < 14 then
                height = 16
            end
            self.y = self.y - (height + NOTE_BOTTOM_GAP)
            return desc
        end,

        Checkbox = function(self, label, tooltip, key, onChanged)
            local cb = CreateCheckbox(self.parent, label, tooltip, self.x, self.y, key, onChanged)
            local cbWidth = cb:GetWidth()
            if not cbWidth or cbWidth < 1 then
                cbWidth = 26
            end
            self._checkboxTextInset = cbWidth + CHECKBOX_LABEL_GAP
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
    if IsModernUI() then
        layout:Body(L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."])
    end
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
local attributionMenu
local choiceMenu

local function HideLocaleMenu()
    if localeMenu then
        localeMenu:Hide()
    end
end

local function HideAttributionMenu()
    if attributionMenu then
        attributionMenu:Hide()
    end
end

local function HideChoiceMenu()
    if choiceMenu then
        choiceMenu:Hide()
    end
end

local function CloseOptionsPanel()
    if localeMenu and localeMenu:IsShown() then
        HideLocaleMenu()
        return
    end
    if attributionMenu and attributionMenu:IsShown() then
        HideAttributionMenu()
        return
    end
    if choiceMenu and choiceMenu:IsShown() then
        HideChoiceMenu()
        return
    end
    HideLocaleMenu()
    HideAttributionMenu()
    HideChoiceMenu()
    BD:ReleaseMotionPreviews()
    if BD.configFrame then
        BD.configFrame:Hide()
    end
end

local SCENARIO_LABEL_KEYS = {
    openWorld = "Open world",
    dungeon = "Dungeon",
    raid = "Raid",
    battleground = "Battleground",
    arena = "Arena",
}

local STRICTNESS_LABEL_KEYS = {
    loose = "Loose",
    balanced = "Balanced",
    strict = "Strict",
}

local function ScenarioLabel(id)
    return L[SCENARIO_LABEL_KEYS[id] or "Open world"]
end

local function StrictnessLabel(id)
    return L[STRICTNESS_LABEL_KEYS[id] or "Balanced"]
end

local RECOMMENDED_COLOR = "|cffFFCC00"

local function StrictnessMenuLabel(id, recommendedId)
    local text = StrictnessLabel(id)
    if recommendedId and id == recommendedId then
        return text .. " " .. RECOMMENDED_COLOR .. "(" .. L["Recommended"] .. ")|r"
    end
    return text
end

local function ApplyStrictnessMenuEntry(entry, selected, recommendedId)
    entry.label:SetText(StrictnessMenuLabel(entry.id, recommendedId))
    if selected then
        entry.label:SetTextColor(1, 0.82, 0.45)
    else
        entry.label:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end
end

local function CreateStrictnessDropdown(parent, layout, label, dbKey, tooltip, isEnabled, recommendedId)
    local caption = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    caption:SetPoint("TOPLEFT", layout.x, layout.y)
    caption:SetText(label)

    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetPoint("TOPLEFT", layout.x, layout.y - 18)
    button:SetSize(240, 26)
    button:EnableMouse(true)
    ApplyBackdrop(button, 0.10, 0.10, 0.11, 0.96, 0.38, 0.38, 0.40, 0.95)

    local hover = button:CreateTexture(nil, "BACKGROUND")
    hover:SetPoint("TOPLEFT", 1, -1)
    hover:SetPoint("BOTTOMRIGHT", -1, 1)
    hover:SetColorTexture(1, 1, 1, 0.05)
    hover:Hide()

    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    button.label:SetPoint("LEFT", 12, 0)
    button.label:SetPoint("RIGHT", -12, 0)
    button.label:SetJustifyH("LEFT")
    button.label:SetWordWrap(false)
    button.caption = caption
    button.recommendedId = recommendedId
    button.dbKey = dbKey
    button.isEnabled = isEnabled

    local function SetOpenVisual(isOpen)
        if isOpen then
            ApplyBackdrop(button, 0.14, 0.14, 0.15, 0.98, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 0.85)
            hover:Hide()
        else
            ApplyBackdrop(button, 0.10, 0.10, 0.11, 0.96, 0.38, 0.38, 0.40, 0.95)
        end
    end

    function button:SetOpenVisual(isOpen)
        SetOpenVisual(isOpen)
    end

    local function SyncLabel()
        button.label:SetText(StrictnessLabel(BD.db[dbKey]))
    end

    SyncLabel()
    button.Refresh = function(self)
        SyncLabel()
        local enabled = true
        if self.isEnabled then
            enabled = self.isEnabled() and true or false
        end
        self:SetEnabled(enabled)
        self:SetAlpha(enabled and 1 or 0.55)
        if enabled then
            self.caption:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            self.label:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        else
            self.caption:SetTextColor(0.5, 0.5, 0.5)
            self.label:SetTextColor(0.5, 0.5, 0.5)
        end
    end
    AddControl(button)
    AttachTooltip(button, tooltip)

    button:SetScript("OnEnter", function(self)
        if not self:IsEnabled() then
            return
        end
        if not (attributionMenu and attributionMenu:IsShown() and attributionMenu.owner == self) then
            hover:Show()
            ApplyBackdrop(self, 0.13, 0.13, 0.14, 0.98, 0.48, 0.48, 0.50, 1)
        end
    end)
    button:SetScript("OnLeave", function(self)
        hover:Hide()
        if not (attributionMenu and attributionMenu:IsShown() and attributionMenu.owner == self) then
            SetOpenVisual(false)
        end
    end)

    if not attributionMenu then
        local menu = CreateFrame("Frame", "PlateSCTAttributionMenu", UIParent, "BackdropTemplate")
        menu:SetFrameStrata("FULLSCREEN_DIALOG")
        menu:SetToplevel(true)
        menu:SetClampedToScreen(true)
        menu:EnableMouse(true)
        menu:Hide()
        ApplyBackdrop(menu, 0.08, 0.08, 0.09, 0.98, 0.38, 0.38, 0.40, 0.95)
        attributionMenu = menu
        tinsert(UISpecialFrames, "PlateSCTAttributionMenu")
        menu.entries = {}

        menu:SetScript("OnHide", function(self)
            if self.owner and self.owner.SetOpenVisual then
                self.owner:SetOpenVisual(false)
            end
            self.owner = nil
        end)

        local closeWatcher = CreateFrame("Frame", nil, menu)
        closeWatcher:SetScript("OnUpdate", function()
            if not menu:IsShown() then
                return
            end
            if IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton") then
                if not menu:IsMouseOver() and not (menu.owner and menu.owner:IsMouseOver()) then
                    HideAttributionMenu()
                end
            end
        end)

        for index, id in ipairs(BD.STRICTNESS_ORDER) do
            local entry = CreateFrame("Button", nil, menu)
            entry:SetHeight(26)
            entry:SetPoint("TOPLEFT", 6, -6 - ((index - 1) * 26))
            entry:SetPoint("TOPRIGHT", -6, -6 - ((index - 1) * 26))
            entry.label = entry:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            entry.label:SetPoint("LEFT", 8, 0)
            entry.label:SetJustifyH("LEFT")
            entry.id = id
            menu.entries[index] = entry

            entry:SetScript("OnEnter", function(self)
                ApplyStrictnessMenuEntry(self, menu.owner and BD.db[menu.owner.dbKey] == self.id, menu.owner and menu.owner.recommendedId)
                self.label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
            end)
            entry:SetScript("OnLeave", function(self)
                ApplyStrictnessMenuEntry(self, menu.owner and BD.db[menu.owner.dbKey] == self.id, menu.owner and menu.owner.recommendedId)
            end)
            entry:SetScript("OnClick", function(self)
                if menu.owner and menu.owner.dbKey then
                    BD.db[menu.owner.dbKey] = self.id
                    if BD.RefreshScenario then
                        BD:RefreshScenario()
                    end
                    if menu.owner.Refresh then
                        menu.owner:Refresh()
                    end
                    if parent.GetRootPanel and parent:GetRootPanel().Refresh then
                        parent:GetRootPanel():Refresh()
                    end
                end
                HideAttributionMenu()
            end)
        end
    end

    local function ShowMenu()
        HideLocaleMenu()
        HideChoiceMenu()
        local menu = attributionMenu
        menu.owner = button
        SetOpenVisual(true)
        local width = 180
        local ownerRecommended = button.recommendedId
        for _, entry in ipairs(menu.entries) do
            local selected = BD.db[dbKey] == entry.id
            ApplyStrictnessMenuEntry(entry, selected, ownerRecommended)
            width = math.max(width, (entry.label:GetStringWidth() or 0) + 36)
        end
        menu:SetSize(width, (#BD.STRICTNESS_ORDER * 26) + 12)
        menu:ClearAllPoints()
        menu:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -4)
        menu:Show()
        menu:Raise()
    end

    button:SetScript("OnClick", function(self)
        if not self:IsEnabled() then
            return
        end
        if attributionMenu and attributionMenu:IsShown() and attributionMenu.owner == self then
            HideAttributionMenu()
        else
            ShowMenu()
        end
    end)

    layout.y = layout.y - 52
    return button
end

local MOTION_PREVIEW_X = 256

local function MotionPreviewHitKind(dbKey)
    if dbKey == "animCrit" then
        return "crit"
    end
    if dbKey == "animMiss" then
        return "miss"
    end
    return "hit"
end

local function CreateMotionPreview(parent, firstDropdown, lastDropdown)
    local pane = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    pane:SetPoint("TOPLEFT", firstDropdown.caption, "TOPLEFT", MOTION_PREVIEW_X, 4)
    pane:SetPoint("BOTTOMRIGHT", lastDropdown, "BOTTOMRIGHT", MOTION_PREVIEW_X, 0)
    ApplyBackdrop(pane, 0.06, 0.06, 0.07, 0.55, 0.38, 0.38, 0.40, 0.75)
    pcall(function()
        pane:SetClipsChildren(true)
    end)

    local caption = pane:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    caption:SetPoint("TOPLEFT", 10, -8)
    caption:SetText(L["Preview"])

    local stage = CreateFrame("Frame", nil, pane)
    stage:SetPoint("TOPLEFT", 8, -24)
    stage:SetPoint("BOTTOMRIGHT", -8, 8)
    pane.stage = stage

    function pane:RefreshVisibility()
        local modern = BD.db.numberStyle ~= "classic"
        self:SetShown(modern)
        if not modern then
            BD:ReleaseMotionPreviews()
        end
    end

    pane:RefreshVisibility()
    return pane
end

local function CreateChoiceDropdown(parent, layout, label, dbKey, options, tooltip, isEnabled, onSelect)
    local caption = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    caption:SetPoint("TOPLEFT", layout.x, layout.y)
    caption:SetText(label)

    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetPoint("TOPLEFT", layout.x, layout.y - 18)
    button:SetSize(240, 26)
    button:EnableMouse(true)
    ApplyBackdrop(button, 0.10, 0.10, 0.11, 0.96, 0.38, 0.38, 0.40, 0.95)

    local hover = button:CreateTexture(nil, "BACKGROUND")
    hover:SetPoint("TOPLEFT", 1, -1)
    hover:SetPoint("BOTTOMRIGHT", -1, 1)
    hover:SetColorTexture(1, 1, 1, 0.05)
    hover:Hide()

    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    button.label:SetPoint("LEFT", 12, 0)
    button.label:SetPoint("RIGHT", -12, 0)
    button.label:SetJustifyH("LEFT")
    button.label:SetWordWrap(false)
    button.caption = caption
    button.dbKey = dbKey
    button.options = options
    button.isEnabled = isEnabled

    local function OptionLabel(opt)
        local text = L[opt.labelKey] or opt.id
        if opt.recommended then
            return text .. " " .. RECOMMENDED_COLOR .. "(" .. L["Recommended"] .. ")|r"
        end
        return text
    end

    local function SelectedLabel()
        local current = BD.db[dbKey]
        for _, opt in ipairs(options) do
            if opt.id == current then
                local text = L[opt.labelKey] or opt.id
                if opt.recommended then
                    return text .. " (" .. L["Recommended"] .. ")"
                end
                return text
            end
        end
        return tostring(current or "")
    end

    local function SetOpenVisual(isOpen)
        if isOpen then
            ApplyBackdrop(button, 0.14, 0.14, 0.15, 0.98, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 0.85)
            hover:Hide()
        else
            ApplyBackdrop(button, 0.10, 0.10, 0.11, 0.96, 0.38, 0.38, 0.40, 0.95)
        end
    end

    function button:SetOpenVisual(isOpen)
        SetOpenVisual(isOpen)
    end

    local function SyncLabel()
        button.label:SetText(SelectedLabel())
    end

    SyncLabel()
    button.Refresh = function(self)
        SyncLabel()
        local enabled = true
        if self.isEnabled then
            enabled = self.isEnabled() and true or false
        end
        self:SetEnabled(enabled)
        self:SetAlpha(enabled and 1 or 0.55)
        if enabled then
            self.caption:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            self.label:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        else
            self.caption:SetTextColor(0.5, 0.5, 0.5)
            self.label:SetTextColor(0.5, 0.5, 0.5)
        end
        self:SetShown(true)
    end
    AddControl(button)
    AttachTooltip(button, tooltip)

    button:SetScript("OnEnter", function(self)
        if not self:IsEnabled() then
            return
        end
        if not (choiceMenu and choiceMenu:IsShown() and choiceMenu.owner == self) then
            hover:Show()
            ApplyBackdrop(self, 0.13, 0.13, 0.14, 0.98, 0.48, 0.48, 0.50, 1)
        end
    end)
    button:SetScript("OnLeave", function(self)
        hover:Hide()
        if not (choiceMenu and choiceMenu:IsShown() and choiceMenu.owner == self) then
            SetOpenVisual(false)
        end
    end)

    if not choiceMenu then
        local menu = CreateFrame("Frame", "PlateSCTChoiceMenu", UIParent, "BackdropTemplate")
        menu:SetFrameStrata("FULLSCREEN_DIALOG")
        menu:SetToplevel(true)
        menu:SetClampedToScreen(true)
        menu:EnableMouse(true)
        menu:Hide()
        ApplyBackdrop(menu, 0.08, 0.08, 0.09, 0.98, 0.38, 0.38, 0.40, 0.95)
        choiceMenu = menu
        tinsert(UISpecialFrames, "PlateSCTChoiceMenu")
        menu.entries = {}

        menu:SetScript("OnHide", function(self)
            if self.owner and self.owner.SetOpenVisual then
                self.owner:SetOpenVisual(false)
            end
            self.owner = nil
        end)

        local closeWatcher = CreateFrame("Frame", nil, menu)
        closeWatcher:SetScript("OnUpdate", function()
            if not menu:IsShown() then
                return
            end
            if IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton") then
                if not menu:IsMouseOver() and not (menu.owner and menu.owner:IsMouseOver()) then
                    HideChoiceMenu()
                end
            end
        end)
    end

    local function ShowMenu()
        HideLocaleMenu()
        HideAttributionMenu()
        local menu = choiceMenu
        menu.owner = button
        SetOpenVisual(true)

        for _, entry in ipairs(menu.entries) do
            entry:Hide()
        end

        local width = 200
        local y = -6
        for index, opt in ipairs(options) do
            local entry = menu.entries[index]
            if not entry then
                entry = CreateFrame("Button", nil, menu)
                entry:SetHeight(26)
                entry.label = entry:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                entry.label:SetPoint("LEFT", 8, 0)
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
                menu.entries[index] = entry
            end

            entry:ClearAllPoints()
            entry:SetPoint("TOPLEFT", 6, y)
            entry:SetPoint("TOPRIGHT", -6, y)
            entry.label:SetText(OptionLabel(opt))
            local selected = BD.db[dbKey] == opt.id
            if selected then
                entry.label:SetTextColor(1, 0.82, 0.45)
            else
                entry.label:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            end
            entry:SetScript("OnClick", function()
                BD.db[dbKey] = opt.id
                if button.Refresh then
                    button:Refresh()
                end
                HideChoiceMenu()
                if onSelect then
                    onSelect(dbKey)
                end
            end)
            entry:Show()
            width = math.max(width, (entry.label:GetStringWidth() or 0) + 36)
            y = y - 26
        end

        menu:SetSize(width, (#options * 26) + 12)
        menu:ClearAllPoints()
        menu:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -4)
        menu:Show()
        menu:Raise()
    end

    button:SetScript("OnClick", function(self)
        if not self:IsEnabled() then
            return
        end
        if choiceMenu and choiceMenu:IsShown() and choiceMenu.owner == self then
            HideChoiceMenu()
        else
            ShowMenu()
        end
    end)

    layout.y = layout.y - 52
    return button
end

local function CreateIconPositionSelector(parent, layout)
    local caption = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    caption:SetPoint("TOPLEFT", layout.x, layout.y)
    caption:SetText(L["Icon position"])

    local radios = {}
    local x = layout.x
    local y = layout.y - 22
    local prev

    local function SyncRadios()
        local current = BD.db.iconPosition or "left"
        for _, radio in ipairs(radios) do
            radio:SetChecked(radio.posId == current)
        end
    end

    for _, opt in ipairs(BD.ICON_POSITIONS) do
        local radio = CreateFrame("CheckButton", nil, parent, "UIRadioButtonTemplate")
        if prev then
            radio:SetPoint("LEFT", prev.text, "RIGHT", 18, 0)
        else
            radio:SetPoint("TOPLEFT", x, y)
        end
        radio.text = radio:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        radio.text:SetPoint("LEFT", radio, "RIGHT", 4, 0)
        local label = L[opt.labelKey] or opt.id
        if opt.recommended then
            label = label .. " (" .. L["Recommended"] .. ")"
        end
        radio.text:SetText(label)
        radio:SetHitRectInsets(0, -(radio.text:GetStringWidth() + 8), 0, 0)
        radio.posId = opt.id
        radio:SetScript("OnClick", function()
            BD.db.iconPosition = opt.id
            SyncRadios()
        end)
        radio.Refresh = SyncRadios
        AddControl(radio)
        radios[#radios + 1] = radio
        prev = radio
    end

    layout.y = layout.y - 48
    return {
        caption = caption,
        radios = radios,
        SetEnabled = function(_, enabled)
            caption:SetTextColor(
                enabled and HIGHLIGHT_FONT_COLOR.r or 0.5,
                enabled and HIGHLIGHT_FONT_COLOR.g or 0.5,
                enabled and HIGHLIGHT_FONT_COLOR.b or 0.5
            )
            for _, radio in ipairs(radios) do
                radio:SetEnabled(enabled)
                radio:SetAlpha(enabled and 1 or 0.55)
                if enabled then
                    radio.text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
                else
                    radio.text:SetTextColor(0.5, 0.5, 0.5)
                end
            end
        end,
    }
end

local function CreateLocaleSelector(parent, layout)
    layout:Heading(L["Language"])
    layout:Body(L["Choose the language used by PlateSCT panels and messages."])

    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetPoint("TOPLEFT", layout.x, layout.y)
    button:SetSize(240, 28)
    button:EnableMouse(true)
    ApplyBackdrop(button, 0.10, 0.10, 0.11, 0.96, 0.38, 0.38, 0.40, 0.95)

    local hover = button:CreateTexture(nil, "BACKGROUND")
    hover:SetPoint("TOPLEFT", 1, -1)
    hover:SetPoint("BOTTOMRIGHT", -1, 1)
    hover:SetColorTexture(1, 1, 1, 0.05)
    hover:Hide()
    button.hover = hover

    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    button.label:SetPoint("LEFT", 12, 0)
    button.label:SetPoint("RIGHT", -12, 0)
    button.label:SetJustifyH("LEFT")
    button.label:SetWordWrap(false)

    local function SetOpenVisual(isOpen)
        if isOpen then
            ApplyBackdrop(button, 0.14, 0.14, 0.15, 0.98, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 0.85)
            hover:Hide()
        else
            ApplyBackdrop(button, 0.10, 0.10, 0.11, 0.96, 0.38, 0.38, 0.40, 0.95)
        end
    end

    function button:SetOpenVisual(isOpen)
        SetOpenVisual(isOpen)
    end

    local function SyncLabel()
        button.label:SetText(BD:GetLocalePreferenceLabel(BD.db.locale))
    end

    SyncLabel()
    button.Refresh = SyncLabel
    AddControl(button)

    button:SetScript("OnEnter", function(self)
        if not (localeMenu and localeMenu:IsShown() and localeMenu.owner == self) then
            hover:Show()
            ApplyBackdrop(self, 0.13, 0.13, 0.14, 0.98, 0.48, 0.48, 0.50, 1)
        end
    end)
    button:SetScript("OnLeave", function(self)
        hover:Hide()
        if not (localeMenu and localeMenu:IsShown() and localeMenu.owner == self) then
            SetOpenVisual(false)
        end
    end)

    if not localeMenu then
        local menu = CreateFrame("Frame", "PlateSCTLocaleMenu", UIParent, "BackdropTemplate")
        menu:SetFrameStrata("FULLSCREEN_DIALOG")
        menu:SetToplevel(true)
        menu:SetClampedToScreen(true)
        menu:EnableMouse(true)
        menu:Hide()
        ApplyBackdrop(menu, 0.08, 0.08, 0.09, 0.98, 0.38, 0.38, 0.40, 0.95)
        localeMenu = menu
        tinsert(UISpecialFrames, "PlateSCTLocaleMenu")

        menu:SetScript("OnHide", function(self)
            if self.owner and self.owner.SetOpenVisual then
                self.owner:SetOpenVisual(false)
            end
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
        HideAttributionMenu()
        HideChoiceMenu()
        local menu = localeMenu
        menu.owner = button
        SetOpenVisual(true)

        if menu.buttons then
            for _, entry in ipairs(menu.buttons) do
                entry:Hide()
            end
        else
            menu.buttons = {}
        end

        local selected = BD:NormalizeLocaleCode(BD.db.locale or "auto")
        local y = -6
        local width = math.max(240, button:GetWidth() or 240)

        for index, option in ipairs(BD.LOCALE_OPTIONS) do
            local entry = menu.buttons[index]
            if not entry then
                entry = CreateFrame("Button", nil, menu)
                entry:SetHeight(26)
                entry.label = entry:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                entry.label:SetPoint("LEFT", 12, 0)
                entry.label:SetPoint("RIGHT", -12, 0)
                entry.label:SetJustifyH("LEFT")
                entry.hover = entry:CreateTexture(nil, "BACKGROUND")
                entry.hover:SetAllPoints()
                entry.hover:SetColorTexture(1, 1, 1, 0.08)
                entry.hover:Hide()
                entry.check = entry:CreateTexture(nil, "ARTWORK")
                entry.check:SetSize(2, 14)
                entry.check:SetPoint("LEFT", 4, 0)
                entry.check:SetColorTexture(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
                entry.check:Hide()
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
            entry.label:SetText(BD:GetLocaleOptionLabel(option))
            local isSelected = option.id == selected
            entry.check:SetShown(isSelected)
            if isSelected then
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
            y = y - 26
            width = math.max(width, (entry.label:GetStringWidth() or 0) + 36)
        end

        menu:SetSize(width, (#BD.LOCALE_OPTIONS * 26) + 12)
        menu:ClearAllPoints()
        menu:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -4)
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

    layout.y = layout.y - 44
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
    parent.nameplateWarning:Refresh()
    local warningHeight = parent.nameplateWarning:IsShown() and (parent.nameplateWarning:GetHeight() or 0) or 0
    layout.y = layout.y - math.max(warningHeight, 0) - 14

    layout:Heading(L["Who to show"])
    local onlyMine, allPlates, petDamage

    if IsModernUI() then
        onlyMine = layout:Checkbox(
            L["Only my damage"],
            L["Show hits when a recent cast or auto-attack matches the nameplate. Midnight cannot prove who dealt the hit in a group."],
            "onlyMyDamage",
            function(checked)
                if checked then
                    BD.db.allNameplates = false
                end
                rootPanel:UpdateDependentStates()
            end
        )
        parent.onlyMineTag = CreateTag(parent, L["Experimental"], onlyMine.label)
        parent.onlyMineBody = layout:Note(
            L["Best effort: matches your casts to nameplates by destination and timing. Dest-matched cleave can show. Other players on the same target can still appear. Mythic+ uses the Dungeon profile."]
        )
        allPlates = layout:Checkbox(
            L["All engaged nameplates"],
            L["Show every hit on every visible hostile nameplate. This is the accurate Midnight mode; it includes damage from every source."],
            "allNameplates"
        )
        parent.allPlatesBody = layout:Note(
            L["Available when Only my damage is off. Use this to see numbers on every enemy plate."]
        )
        petDamage = layout:Checkbox(
            L["Include pet damage"],
            L["In Only my damage mode, also treat a recent pet cast as your hit."],
            "includePetDamage"
        )
    else
        layout:Body(L["Shows your damage on hostile nameplates. Source is read from the combat log."])
        petDamage = layout:Checkbox(
            L["Include pet damage"],
            L["Also show damage from your pet and guardians on nameplates."],
            "includePetDamage"
        )
    end

    parent.allPlatesCheckbox = allPlates
    parent.onlyMineCheckbox = onlyMine
    parent.petDamageCheckbox = petDamage

    layout:Gap(SECTION_GAP)
    layout:Heading(L["Incoming"])
    layout:Checkbox(
        L["Show incoming hits"],
        L["Show damage you take near your character. Independent of Only my damage."],
        "showIncoming",
        function()
            rootPanel:UpdateDependentStates()
        end
    )
    parent.incomingBody = layout:Note(
        L["Uses your personal nameplate when available; otherwise floats near screen center."]
    )
    local incomingSliderY = layout.y
    parent.incomingOffsetXSlider = CreateSlider(
        parent,
        L["Incoming X"],
        layout.x,
        incomingSliderY,
        "incomingOffsetX",
        -200,
        200,
        2,
        function(value)
            return string.format(L["%d px"], value)
        end,
        SLIDER_WIDTH,
        0
    )
    parent.incomingOffsetYSlider = CreateSlider(
        parent,
        L["Incoming Y"],
        layout.x + SLIDER_WIDTH + SLIDER_GAP,
        incomingSliderY,
        "incomingOffsetY",
        -200,
        200,
        2,
        function(value)
            return string.format(L["%d px"], value)
        end,
        SLIDER_WIDTH,
        -100
    )
    layout.y = incomingSliderY - SLIDER_BLOCK

    if IsModernUI() then
        layout:Gap(SECTION_GAP)
        layout:Heading(L["Attribution profiles"])
        layout:Body(L["How strict PlateSCT is when guessing which hits are yours. Auto-switch follows the instance type."])

        parent.scenarioReadout = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        parent.scenarioReadout:SetPoint("TOPLEFT", layout.x, layout.y)
        parent.scenarioReadout:SetWidth(CONTENT_WIDTH)
        parent.scenarioReadout:SetJustifyH("LEFT")
        parent.scenarioReadout:SetTextColor(1, 0.82, 0.45)
        parent.scenarioReadout.Refresh = function(self)
            if BD.RefreshScenario then
                BD:RefreshScenario()
            end
            local scenario = BD.scenario or (BD.DetectScenario and BD:DetectScenario()) or "openWorld"
            local strictId = BD.GetActiveStrictnessId and BD:GetActiveStrictnessId() or "balanced"
            self:SetText(string.format(L["Active: %s (%s)"], ScenarioLabel(scenario), StrictnessLabel(strictId)))
        end
        AddControl(parent.scenarioReadout)
        parent.scenarioReadout:Refresh()
        layout.y = layout.y - 28

        layout:Checkbox(
            L["Auto-switch by instance"],
            L["Pick Open world, Dungeon, Raid, Battleground, or Arena settings from the zone you are in."],
            "attributionAuto",
            function()
                if BD.RefreshScenario then
                    BD:RefreshScenario()
                end
                rootPanel:UpdateDependentStates()
            end
        )

        parent.manualStrictness = CreateStrictnessDropdown(
            parent,
            layout,
            L["Manual strictness"],
            "attributionManual",
            L["Used when Auto-switch is off."],
            function()
                return not BD.db.attributionAuto
            end
        )

        parent.profileDropdowns = {}
        local profileSpecs = {
            {
                key = "attributionOpenWorld",
                label = L["Open world"],
                tip = L["Loose: longer windows, more numbers."],
                recommended = "loose",
            },
            {
                key = "attributionDungeon",
                label = L["Dungeon"],
                tip = L["Balanced: medium windows and cleave hits."],
                recommended = "balanced",
            },
            {
                key = "attributionRaid",
                label = L["Raid"],
                tip = L["Strict: short windows, fewer foreign hits."],
                recommended = "strict",
            },
            {
                key = "attributionBattleground",
                label = L["Battleground"],
                tip = L["Strict: short windows, fewer foreign hits."],
                recommended = "strict",
            },
            {
                key = "attributionArena",
                label = L["Arena"],
                tip = L["Balanced: medium windows and cleave hits."],
                recommended = "balanced",
            },
        }
        for _, spec in ipairs(profileSpecs) do
            parent.profileDropdowns[#parent.profileDropdowns + 1] = CreateStrictnessDropdown(
                parent,
                layout,
                spec.label,
                spec.key,
                spec.tip,
                function()
                    return BD.db.attributionAuto and true or false
                end,
                spec.recommended
            )
        end
    end

    if parent.UpdateScrollBar then
        parent:SetHeight(math.max(1, -layout.y + 40))
        C_Timer.After(0, parent.UpdateScrollBar)
    end
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
        IsModernUI()
            and L["Display the spell's icon next to the damage number. Uses the matched cast or auto-attack."]
            or L["Display the spell's icon next to the damage number. Uses the spell from the combat log."],
        "showSpellIcon",
        function()
            rootPanel:UpdateDependentStates()
        end
    )
    parent.spellIconCheckbox = spellIcon
    parent.spellIconBody = layout:Note(
        IsModernUI()
            and L["Uses your matched spell in Only my damage mode. Position is set below."]
            or L["Uses the spell from the combat log. Position is set below."]
    )
    parent.iconPositionSelector = CreateIconPositionSelector(parent, layout)

    layout:Gap(SECTION_GAP)
    layout:Heading(L["Animation"])
    local sliderY = layout.y
    CreateSlider(parent, L["Font size"], layout.x, sliderY, "fontSize", 10, 24, 1, function(value)
        return tostring(value)
    end, SLIDER_WIDTH, BD.DEFAULTS.fontSize)
    CreateSlider(parent, L["Scroll offset"], layout.x + SLIDER_WIDTH + SLIDER_GAP, sliderY, "floatDistance", 10, 40, 5, function(value)
        return string.format(L["%d px"], value)
    end, SLIDER_WIDTH, BD.DEFAULTS.floatDistance)
    layout.y = sliderY - SLIDER_BLOCK
    CreateSlider(parent, L["Display duration"], layout.x, layout.y, "duration", 0.5, 2.0, 0.1, function(value)
        return string.format(L["%.1fs"], value)
    end, SLIDER_WIDTH, BD.DEFAULTS.duration)
    layout.y = layout.y - SLIDER_BLOCK

    layout:Gap(SECTION_GAP)
    layout:Heading(L["Text style"])
    layout:Checkbox(L["Abbreviate numbers"], L["Display large numbers as 214k or 1.2M."], "abbreviate")
    parent.showCritLabelCheckbox = layout:Checkbox(
        L["Show CRITICAL"],
        L["Show the word CRITICAL in small caps next to critical hit numbers."],
        "showCritLabel",
        function()
            if parent.motionPreview and parent.motionPreview:IsShown() then
                local stage = parent.motionPreview.stage or parent.motionPreview
                BD:ShowMotionPreview(stage, "crit")
            end
        end
    )

    layout:Gap(SECTION_GAP)
    parent.motionHeading = CreateHeading(parent, L["Motion (Modern)"], layout.x, layout.y, CONTENT_WIDTH)
    layout.y = layout.y - (16 + 6 + AFTER_HEADING)
    parent.motionBody = layout:Body(
        L["Pick a motion for each hit type. Classic number style ignores these and keeps its own animation."]
    )

    local isModern = function()
        return BD.db.numberStyle ~= "classic"
    end

    local function PlayMotionPreview(dbKey)
        if not parent.motionPreview or not parent.motionPreview:IsShown() then
            return
        end
        local stage = parent.motionPreview.stage or parent.motionPreview
        BD:ShowMotionPreview(stage, MotionPreviewHitKind(dbKey))
    end

    local function MakeMotionSelect(key)
        return function(selectedKey)
            PlayMotionPreview(selectedKey or key)
        end
    end

    parent.motionDropdowns = {}
    parent.motionDropdowns[1] = CreateChoiceDropdown(
        parent,
        layout,
        L["Normal hits"],
        "animHit",
        BD.ANIM_STYLES,
        L["Motion used for normal damage numbers."],
        isModern,
        MakeMotionSelect("animHit")
    )
    parent.motionDropdowns[2] = CreateChoiceDropdown(
        parent,
        layout,
        L["Critical hits"],
        "animCrit",
        BD.ANIM_STYLES_CRIT,
        L["Motion used for critical hits. Classic Slap uses the Classic grow-and-settle pow."],
        isModern,
        MakeMotionSelect("animCrit")
    )
    parent.motionDropdowns[3] = CreateChoiceDropdown(
        parent,
        layout,
        L["Miss / Parry / Dodge"],
        "animMiss",
        BD.ANIM_STYLES,
        L["Motion used for miss, parry, dodge, and similar outcomes."],
        isModern,
        MakeMotionSelect("animMiss")
    )

    parent.motionPreview = CreateMotionPreview(parent, parent.motionDropdowns[1], parent.motionDropdowns[3])

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
    if IsModernUI() then
        layout:Gap(8)
        layout:Button(L["Dump meter now"], 160, L["Open a copyable snapshot of C_DamageMeter fields. Use this in combat while hitting a target."], function()
            BD:DumpDamageMeterProbe()
        end)
    end
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

local function CreatePanelCloseButton(parent, onClick)
    local close
    if IsModernUI() then
        close = CreateFrame("Button", nil, parent, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -6, -6)
    else
        close = CreateFrame("Button", nil, parent)
        close:SetSize(28, 28)
        close:SetPoint("TOPRIGHT", -4, -4)
        local label = close:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        label:SetPoint("CENTER", 1, 0)
        label:SetText("×")
        label:SetTextColor(0.9, 0.9, 0.9)
        local highlight = close:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints()
        highlight:SetColorTexture(1, 1, 1, 0.12)
    end
    close:SetFrameLevel(parent:GetFrameLevel() + 20)
    if IsModernUI() then
        close:SetScript("OnClick", onClick)
    else
        close:SetScript("OnMouseUp", function(_, button)
            if button == "LeftButton" then
                onClick()
            end
        end)
    end
    return close
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
    frame:EnableKeyboard(true)
    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            CloseOptionsPanel()
            self:SetPropagateKeyboardInput(false)
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)

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

    local close = CreatePanelCloseButton(frame, CloseOptionsPanel)

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
    versionFooter:SetPoint("BOTTOMLEFT", 16, 14)
    versionFooter:SetPoint("BOTTOMRIGHT", -16, 14)

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
        if index == 1 or index == 2 then
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

    BuildPageGeneral(pages[1].scrollChild or pages[1], frame)
    BuildPageDisplay(pages[2].scrollChild or pages[2], frame)
    BuildPageDamage(pages[3])
    BuildPageTools(pages[4])

    function frame:UpdateDependentStates()
        local general = pages[1].scrollChild or pages[1]
        local display = pages[2].scrollChild or pages[2]
        if not general then
            return
        end
        if general.nameplateWarning then
            general.nameplateWarning:Refresh()
        end
        if general.scenarioReadout and general.scenarioReadout.Refresh then
            general.scenarioReadout:Refresh()
        end
        if general.manualStrictness and general.manualStrictness.Refresh then
            general.manualStrictness:Refresh()
        end
        if general.profileDropdowns then
            for _, dropdown in ipairs(general.profileDropdowns) do
                if dropdown.Refresh then
                    dropdown:Refresh()
                end
            end
        end
        if not general.allPlatesCheckbox then
            if general.petDamageCheckbox and not IsModernUI() then
                general.petDamageCheckbox:SetEnabled(true)
                general.petDamageCheckbox:SetAlpha(1)
                general.petDamageCheckbox.label:SetTextColor(
                    HIGHLIGHT_FONT_COLOR.r,
                    HIGHLIGHT_FONT_COLOR.g,
                    HIGHLIGHT_FONT_COLOR.b
                )
            end
            if display and display.spellIconCheckbox and not IsModernUI() then
                display.spellIconCheckbox:SetEnabled(true)
                display.spellIconCheckbox:SetAlpha(1)
                display.spellIconCheckbox.label:SetTextColor(
                    HIGHLIGHT_FONT_COLOR.r,
                    HIGHLIGHT_FONT_COLOR.g,
                    HIGHLIGHT_FONT_COLOR.b
                )
                if display.iconPositionSelector then
                    display.iconPositionSelector:SetEnabled(BD.db.showSpellIcon and true or false)
                end
            end
            return
        end
        local onlyMineOn = IsModernUI() and BD.db.onlyMyDamage and true or false
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
        local showIconOn = onlyMineOn and BD.db.showSpellIcon
        if display and display.iconPositionSelector then
            display.iconPositionSelector:SetEnabled(showIconOn and true or false)
        end
        if display and display.motionBody then
            local modern = BD.db.numberStyle ~= "classic"
            if modern then
                display.motionBody:SetText(
                    L["Pick a motion for each hit type. Classic number style ignores these and keeps its own animation."]
                )
                display.motionBody:SetTextColor(0.70, 0.70, 0.72)
            else
                display.motionBody:SetText(
                    L["Classic uses its own animation. Switch to Modern to customize motion."]
                )
                display.motionBody:SetTextColor(0.55, 0.55, 0.56)
            end
        end
        if display and display.motionDropdowns then
            for _, dropdown in ipairs(display.motionDropdowns) do
                if dropdown.Refresh then
                    dropdown:Refresh()
                end
            end
        end
        if display and display.motionPreview and display.motionPreview.RefreshVisibility then
            display.motionPreview:RefreshVisibility()
        end
        if display and display.showCritLabelCheckbox and display.showCritLabelCheckbox.Refresh then
            display.showCritLabelCheckbox:Refresh()
        end
        if general.incomingOffsetXSlider and general.incomingOffsetYSlider then
            local incomingOn = BD.db.showIncoming and true or false
            for _, slider in ipairs({ general.incomingOffsetXSlider, general.incomingOffsetYSlider }) do
                slider:SetEnabled(incomingOn)
                slider:SetAlpha(incomingOn and 1 or 0.55)
            end
        end
        if general.incomingBody then
            if BD.db.showIncoming then
                general.incomingBody:SetTextColor(0.70, 0.70, 0.72)
            else
                general.incomingBody:SetTextColor(0.45, 0.45, 0.46)
            end
        end
    end

    function frame:Refresh()
        RefreshControls(self)
        self:UpdateDependentStates()
    end

    local function HookNameplateWarningEvents()
        local general = pages[1].scrollChild or pages[1]
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
        local general = pages[1].scrollChild or pages[1]
        if not general or not general.nameplateWarning then
            return
        end
        general.nameplateWarning:UnregisterEvent("CVAR_UPDATE")
        general.nameplateWarning:SetScript("OnEvent", nil)
    end

    frame:SetScript("OnShow", function(self)
        self:EnableKeyboard(true)
        if SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION then
            pcall(PlaySound, SOUNDKIT.IG_MAINMENU_OPTION)
        end
        HookNameplateWarningEvents()
        self:Refresh()
        SelectPage(selectedPage or 1)
    end)

    frame:SetScript("OnHide", function()
        UnhookNameplateWarningEvents()
        BD:ReleaseMotionPreviews()
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
    HideAttributionMenu()
    HideChoiceMenu()
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
    HideAttributionMenu()
    HideChoiceMenu()
    if not self.configFrame then
        self:RegisterOptionsPanel()
    end

    if self.configFrame:IsShown() then
        CloseOptionsPanel()
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
        if IsModernUI() then
            BD:DumpDamageMeterProbe()
        else
            print("|cffff6600PlateSCT:|r Meter probe is only available on Midnight.")
        end
        return
    end
    if not BD.configFrame then
        BD:RegisterOptionsPanel()
    end
    BD:OpenOptions()
end
