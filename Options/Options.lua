local ADDON_NAME, BD = ...
local L, W = BD.L, BD.OptionsWidgets

local WINDOW_WIDTH, WINDOW_HEIGHT = 840, 640
local SIDEBAR_WIDTH, DRAWER_HEIGHT = 176, 220
local GOLD = { 0.92, 0.76, 0.42 }
local session = { page = "combat", tabs = {}, scroll = {} }

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
    local track = CreateFrame("Frame", nil, host, "BackdropTemplate")
    track:SetWidth(8); track:SetPoint("TOPRIGHT", -3, -8); track:SetPoint("BOTTOMRIGHT", -3, 8)
    W.Backdrop(track, "inset")
    track:EnableMouse(true); track:EnableMouseWheel(true)
    local thumb = CreateFrame("Button", nil, track, "BackdropTemplate")
    thumb:SetWidth(6); thumb:RegisterForDrag("LeftButton")
    W.Backdrop(thumb, "button")
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

local function CreatePreview(root, content)
    local pane = CreateFrame("Frame", nil, content, "BackdropTemplate")
    pane:SetPoint("BOTTOMLEFT"); pane:SetPoint("BOTTOMRIGHT"); pane:SetHeight(DRAWER_HEIGHT)
    W.Backdrop(pane, "inset")
    W.Text(pane, L["Appearance preview"], 14, -12, 200, "GameFontNormal", GOLD)
    local scaleLabel = W.Text(pane, string.format(L["Preview scale: %d%%"], 70), 0, 0, nil, "GameFontDisableSmall")
    scaleLabel:ClearAllPoints()
    scaleLabel:SetPoint("TOPLEFT", root.previewToggle, "TOPRIGHT", 12, 12)
    scaleLabel:SetPoint("TOPRIGHT", pane, "BOTTOMRIGHT", -12, 38)
    local note = W.Text(pane, L["Appearance only · Test on Target checks gameplay size."], 0, 0, nil, "GameFontDisableSmall")
    note:ClearAllPoints()
    note:SetPoint("TOPLEFT", root.previewToggle, "TOPRIGHT", 12, -4)
    note:SetPoint("TOPRIGHT", pane, "BOTTOMRIGHT", -12, 22)
    local columnsHost = CreateFrame("Frame", nil, pane)
    columnsHost:SetPoint("TOPLEFT", 12, -36)
    columnsHost:SetPoint("BOTTOMRIGHT", -12, 44)
    pane.stage, pane.viewport, pane.columns = columnsHost, columnsHost, {}
    local function LayoutColumns()
        local width = columnsHost:GetWidth()
        local count = #pane.columns
        if width <= 0 or count == 0 then return end
        local gap = 10
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
            divider:SetPoint("TOPLEFT", -5, -2)
            divider:SetPoint("BOTTOMLEFT", -5, 2)
            divider:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.2)
        end
        local caption = column:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        caption:SetPoint("TOP", 0, -2)
        caption:SetText(L[entry[2]])
        caption:SetTextColor(unpack(GOLD))
        local rule = column:CreateTexture(nil, "ARTWORK")
        rule:SetHeight(1)
        rule:SetPoint("TOPLEFT", 8, -18)
        rule:SetPoint("TOPRIGHT", -8, -18)
        rule:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.22)
        local clip = CreateFrame("Frame", nil, column)
        clip:SetPoint("TOPLEFT", 2, -22)
        clip:SetPoint("BOTTOMRIGHT", -2, 2)
        clip:SetClipsChildren(true)
        local stage = CreateFrame("Frame", nil, clip)
        stage:SetSize(1, 1)
        stage:SetPoint("CENTER")
        local plateMarker = stage:CreateTexture(nil, "BACKGROUND")
        plateMarker:SetSize(64, 6)
        plateMarker:SetPoint("CENTER")
        plateMarker:SetColorTexture(0.60, 0.57, 0.48, 0.75)
        column.clip, column.stage = clip, stage
        pane.columns[index] = column
    end
    function pane:FitStage()
        LayoutColumns()
        local scale = 0.7
        local offsetX, offsetY = BD:GetNumberStyleOffsets()
        local bounds = {}
        for index, column in ipairs(self.columns) do
            local clip = column.clip
            if clip:GetWidth() <= 0 or clip:GetHeight() <= 0 then return end
            -- Motion bounds use the default spawn; keep the marker at the unshifted origin.
            local left, right, bottom, top = BD:GetOptionsPreviewBounds(column.kind)
            left, right = math.min(-32, left + offsetX), math.max(32, right + offsetX)
            bottom, top = math.min(-3, bottom + offsetY), math.max(3, top + offsetY)
            bounds[index] = { left, right, bottom, top }
            scale = math.min(scale,
                math.max(1, clip:GetWidth() - 16) / math.max(1, right - left),
                math.max(1, clip:GetHeight() - 16) / math.max(1, top - bottom))
        end
        for index, column in ipairs(self.columns) do
            local clip, stage = column.clip, column.stage
            local left, right, bottom, top = unpack(bounds[index])
            stage:ClearAllPoints()
            stage:SetScale(scale)
            stage:SetPoint("CENTER", clip, "CENTER", -(left + right) * 0.5 * scale, -(bottom + top) * 0.5 * scale)
        end
        scaleLabel:SetText(string.format(L["Preview scale: %d%%"], math.floor(scale * 100 + 0.5)))
    end
    function pane:UpdateLayout()
        local open = BD.db.showOptionsPreview and true or false
        self:SetShown(open)
        root.pageArea:ClearAllPoints()
        root.pageArea:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -74)
        root.pageArea:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, open and DRAWER_HEIGHT + 8 or 34)
        root.previewToggle:SetText(open and L["Hide preview"] or L["Show preview"])
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

local function BuildConfigFrame()
    local frame = CreateFrame("Frame", "PlateSCTConfigFrame", UIParent, "BackdropTemplate")
    frame:Hide(); frame:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT); frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG"); frame:SetToplevel(true); frame:SetClampedToScreen(true)
    frame:EnableMouse(true); frame:SetMovable(true); frame:EnableKeyboard(true)
    W.Backdrop(frame, "window")
    frame.controls, frame.searchIndex, frame.refreshers = {}, {}, {}
    frame.views, frame.pages, frame.navButtons = {}, {}, {}
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
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetPoint("TOPLEFT", 2, -2); titleBar:SetPoint("TOPRIGHT", -2, -2); titleBar:SetHeight(48)
    titleBar:EnableMouse(true)
    -- Move from mouse down/up: dragging a child shifts the parent cursor offset.
    titleBar:SetScript("OnMouseDown", function(_, button) if button == "LeftButton" then frame:StartMoving(true) end end)
    titleBar:SetScript("OnMouseUp", function() frame:StopMovingOrSizing(); frame:SetUserPlaced(false) end)
    local logo = titleBar:CreateTexture(nil, "ARTWORK")
    logo:SetTexture("Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\psct-logo-mini.png")
    logo:SetSize(32, 32); logo:SetPoint("LEFT", 12, 0)
    W.Text(titleBar, "PlateSCT", 52, -9, 135, "GameFontNormalLarge", GOLD)
    W.Text(titleBar, Version(), 52, -29, 130, "GameFontDisableSmall")
    W.Text(titleBar, FlavorLabel(), 216, -18, 520, "GameFontHighlightSmall", GOLD)
    local close = W.CloseButton(frame, function() frame:Hide() end)
    close:SetPoint("TOPRIGHT", -4, -4)
    close:SetFrameLevel(titleBar:GetFrameLevel() + 5)
    W.Tooltip(close, L["Close"])
    local sidebar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    sidebar:SetWidth(SIDEBAR_WIDTH); sidebar:SetPoint("TOPLEFT", 12, -60); sidebar:SetPoint("BOTTOMLEFT", 12, 12)
    W.Backdrop(sidebar, "inset")
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 12, 0); content:SetPoint("BOTTOMRIGHT", -12, 12)
    frame.pageTitle = W.Text(content, "", 16, -4, 590, "GameFontNormalLarge", GOLD)
    frame.subtitle = W.Text(content, "", 16, -28, 590, "GameFontDisableSmall")
    frame.tabBar = CreateFrame("Frame", nil, content)
    frame.tabBar:SetPoint("TOPLEFT", 16, -48); frame.tabBar:SetPoint("TOPRIGHT", -16, -48); frame.tabBar:SetHeight(24)
    frame.pageArea = CreateFrame("Frame", nil, content)
    frame.pageArea:SetClipsChildren(true)
    frame.previewToggle = W.Button(content, L["Show preview"], 130, 24, function()
        BD.db.showOptionsPreview = not BD.db.showOptionsPreview
        frame:Refresh()
    end)
    frame.previewToggle:SetPoint("BOTTOMLEFT", 0, 2)
    W.Tooltip(frame.previewToggle, L["Show sample hits, crits, and misses inside this window."])
    local targetTest = W.Button(sidebar, L["Test on Target"], 152, 26, function() BD:ShowTestNumbers() end)
    targetTest:SetPoint("BOTTOMLEFT", 12, 48)
    W.Tooltip(targetTest, L["Target an enemy, then spawn sample numbers on its nameplate."])
    local hint = W.Text(sidebar, L["/platesct  ·  ESC to close"], 12, -532, 154, "GameFontDisableSmall")
    -- Pinned to the bottom so it stays under the test button when the window is taller.
    hint:ClearAllPoints()
    hint:SetPoint("BOTTOMLEFT", 12, 22)
    local footer = sidebar:CreateTexture(nil, "ARTWORK")
    footer:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.25); footer:SetHeight(1)
    footer:SetPoint("BOTTOMLEFT", 12, 88); footer:SetPoint("BOTTOMRIGHT", -12, 88)

    local search = W.EditBox(sidebar, 152, 26)
    search:SetPoint("TOPLEFT", 12, -32)
    W.Text(sidebar, L["Find a setting"], 12, -12, 152, "GameFontDisableSmall")
    frame.searchBox = search
    local results = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    results:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 12, -30); results:SetSize(410, 1)
    results:SetFrameLevel(frame:GetFrameLevel() + 40); results:EnableMouse(true)
    W.Backdrop(results, "window"); results:Hide()
    local resultView = CreateScrollView(results, frame)
    resultView:ClearAllPoints(); resultView:SetPoint("TOPLEFT", 8, -8); resultView:SetPoint("BOTTOMRIGHT", -8, 8)
    resultView:Show()
    frame.searchResults, frame.resultButtons, frame.searchMatches = results, {}, {}
    frame.searchSelection = 1

    local function SaveScroll()
        if frame.activeView then session.scroll[frame.activeView.key] = frame.activeView.scroll:GetVerticalScroll() end
    end
    function frame:SelectPage(pageId, tabId, immediate)
        local page = self.pages[pageId]
        if not page then pageId, page = "combat", self.pages.combat end
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
        self.pageTitle:SetText(L[page.labelKey]); self.subtitle:SetText(L[page.subtitleKey or ""])
        for id, button in pairs(self.navButtons) do
            button:SetBackdropBorderColor(unpack(id == pageId and GOLD or { 0.35, 0.28, 0.17 }))
        end
        if page.tabs then
            for index, tab in ipairs(tabs) do
                local tabKey = pageId .. ":" .. tab.id
                local button = self.cachedTabs[tabKey]
                if not button then
                    local id = tab.id
                    button = W.Button(self.tabBar, L[tab.labelKey], 176, 24, function() self:SelectPage(pageId, id) end, "flat")
                    button:SetPoint("TOPLEFT", (index - 1) * 184, 0)
                    self.cachedTabs[tabKey] = button
                end
                button:SetBackdropBorderColor(unpack(tab.id == tabId and GOLD or { 0.35, 0.28, 0.17 }))
                button:Show(); self.tabButtons[#self.tabButtons + 1] = button
            end
        end
        view:SetScroll(session.scroll[view.key] or 0)
        if animate then Reveal(self, view, ox, oy) end
    end
    frame.cachedTabs = {}
    for index, page in ipairs(BD.OptionsPages) do
        if not page.supported or page.supported() then
            frame.pages[page.id] = page
            local id = page.id
            local button = W.Button(sidebar, L[page.labelKey], 152, 34, function() frame:SelectPage(id) end, "flat")
            button:SetPoint("TOPLEFT", 12, -76 - (index - 1) * 42)
            frame.navButtons[id] = button
            local tabs = page.tabs or { { id = "main" } }
            for _, tab in ipairs(tabs) do
                local view = CreateScrollView(frame.pageArea, frame)
                view.key, view.tab = id .. ":" .. tab.id, tab.id
                frame.views[view.key] = view
                page.build(view.child, frame, tab.id)
            end
        end
    end
    frame.previewPane = CreatePreview(frame, content)
    frame.previewPane:UpdateLayout()

    function frame:ChooseSearchResult(index)
        local meta = self.searchMatches[index]
        if not meta then return end
        self:SelectPage(meta.page, meta.tab, true)
        search:SetText(""); search:ClearFocus()
        self.activeView:SetScroll(math.max(0, -(meta.y or 0) - 14))
        local row = meta.control.row or meta.control
        if not row.searchHighlight then
            local highlight = row:CreateTexture(nil, "BACKGROUND")
            highlight:SetAllPoints(); highlight:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.22)
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
    local function UpdateSearch()
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
            if row:IsShown() and searchable:find(query, 1, true) then
                frame.searchMatches[#frame.searchMatches + 1] = meta
            end
        end
        local matches = frame.searchMatches
        for index, meta in ipairs(matches) do
            local button = frame.resultButtons[index]
            if not button then
                local resultIndex = index
                button = W.Button(resultView.child, "", 368, 38, function() frame:ChooseSearchResult(resultIndex) end, "flat")
                button:SetPoint("TOPLEFT", 2, -(index - 1) * 42)
                frame.resultButtons[index] = button
            end
            local page = frame.pages[meta.page]
            button:SetText((meta.label or "") .. "  |cffb8a784" .. L[page.labelKey] .. "|r")
            button:SetBackdropBorderColor(unpack(index == 1 and GOLD or { 0.35, 0.28, 0.17 }))
            button:Show()
        end
        if not results.empty then results.empty = W.Text(resultView.child, L["No matching settings"], 4, -8, 368, "GameFontHighlightSmall") end
        results.empty:SetShown(#matches == 0)
        resultView.child:SetHeight(#matches == 0 and 32 or #matches * 42)
        results:SetHeight(#matches == 0 and 48 or 16 + math.min(8, #matches) * 42)
        resultView:SetScroll(0); results:Show()
    end
    frame.refreshers[#frame.refreshers + 1] = UpdateSearch
    search:SetScript("OnTextChanged", UpdateSearch)
    search:SetScript("OnEnterPressed", function() frame:ChooseSearchResult(frame.searchSelection) end)
    search:SetScript("OnEscapePressed", function() frame:DismissTransient(); search:ClearFocus() end)
    search:SetScript("OnArrowPressed", function(_, direction)
        if #frame.searchMatches == 0 then return end
        frame.searchSelection = math.max(1, math.min(#frame.searchMatches, frame.searchSelection + (direction == "UP" and -1 or 1)))
        for index, button in ipairs(frame.resultButtons) do
            button:SetBackdropBorderColor(unpack(index == frame.searchSelection and GOLD or { 0.35, 0.28, 0.17 }))
        end
        local selectedTop = (frame.searchSelection - 1) * 42
        local top = resultView.scroll:GetVerticalScroll()
        if selectedTop < top then resultView:SetScroll(selectedTop)
        elseif selectedTop + 42 > top + resultView.scroll:GetHeight() then
            resultView:SetScroll(selectedTop + 42 - resultView.scroll:GetHeight())
        end
    end)
    search:SetScript("OnEditFocusGained", function()
        W.Backdrop(search, "selected")
        UpdateSearch()
    end)
    search:SetScript("OnEditFocusLost", function()
        W.Backdrop(search, "control")
    end)
    frame:SetScript("OnMouseDown", function() frame:DismissTransient(); search:ClearFocus() end)
    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            if not self:DismissTransient() then self:Hide() end
            self:SetPropagateKeyboardInput(false)
        else self:SetPropagateKeyboardInput(true) end
    end)
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
        self:FitToScreen(); self:SelectPage(session.page, session.tabs[session.page], true); self:Refresh()
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
    if not self.configFrame then self:RegisterOptionsPanel() end
    if self.configFrame:IsShown() then self.configFrame:Hide(); return end
    self.configFrame:Show(); self.configFrame:Raise()
end

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function() BD:RegisterOptionsPanel() end)
SLASH_PLATESCT1, SLASH_PLATESCT2 = "/platesct", "/psct"
SlashCmdList["PLATESCT"] = function(message)
    message = string.lower(strtrim(message or ""))
    if message == "probe" or message == "meter" then
        if BD.API.IsModern() then BD:DumpDamageMeterProbe()
        else print("|cffff6600PlateSCT:|r " .. L["Meter probe requires Modern API - Midnight & Forever."]) end
        return
    end
    BD:OpenOptions()
end
