local _, BD = ...
local L = BD.L
local W = BD.OptionsWidgets

-- Shared destination selection, area editors, and unlock mode, where each relevant area shows
-- as a rectangle to drag and resize while sample numbers scroll through it.
local Areas = { selected = "outgoing", nameplateTarget = "outgoing", newIncoming = {} }
BD.OptionsAreas = Areas

local movers, toolbar = {}, nil
local reopenOptions = false
local testSession

local function Available(area)
    if BD.Layout.IsScreen() then
        if area.id ~= "incoming" or BD.db.showIncoming then return true end
        for _, route in ipairs(BD.SCREEN_ROUTES) do
            if route.fallback == "outgoing" and BD.db[route.key] == area.id then return true end
        end
        return false
    end
    if area.id == "incoming" or Areas.newIncoming[area.id] then return true end
    for _, route in ipairs(BD.SCREEN_ROUTES) do
        if route.fallback == "incoming" and BD.db[route.key] == area.id then return true end
    end
    return false
end

local function RoutingOptions()
    local options = {}
    for _, area in ipairs(BD.db.screenAreas or {}) do
        if Available(area) or not BD.SCREEN_AREA_BUILTIN[area.id] then
            options[#options + 1] = { id = area.id, label = BD:GetScreenAreaLabel(area) }
        end
    end
    return options
end

local function Selected()
    if not BD.db.screenAreas then
        BD:EnsureScreenAreas()
    end
    local area = BD.FindScreenArea(BD.db, Areas.selected)
    if not area or not Available(area) then
        Areas.selected = BD.Layout.IsScreen() and "outgoing" or "incoming"
        area = BD.FindScreenArea(BD.db, Areas.selected)
    end
    return area
end

local function CustomSelected()
    return not BD.SCREEN_AREA_BUILTIN[Selected().id]
end

local function LinearStyle()
    return Selected().animation ~= "impact"
end

local function AreaOptions()
    local options = {}
    for _, area in ipairs(BD.db.screenAreas or {}) do
        if Available(area) then options[#options + 1] = { id = area.id, label = BD:GetScreenAreaLabel(area) } end
    end
    return options
end

-- A setting of the area chosen in the editor.
local function AreaBinding(field)
    return {
        id = "screenArea." .. field,
        get = function() return Selected()[field] end,
        set = function(value) Selected()[field] = value end,
    }
end

local function Apply()
    BD:RefreshScreenAreas()
    Areas.RefreshMovers()
end

local function PixelValue(value)
    return string.format(L["%d px"], value)
end

function Areas.Selected()
    return Selected()
end

function Areas.UsesArea()
    return BD.Layout.IsScreen() or (BD.db.showIncoming and Areas.nameplateTarget == "incoming")
end

function Areas.BuildSelector(layout)
    layout:When(function() return not BD.Layout.IsScreen() and BD.db.showIncoming end, function()
        layout:Choice({ id = "editingDestination", get = function() return Areas.nameplateTarget end,
            set = function(value) Areas.nameplateTarget = value end }, L["Editing"], {
            { id = "outgoing", labelKey = "Outgoing nameplates" },
            { id = "incoming", labelKey = "Incoming area" },
        }, L["Keep the same destination when switching between Animation and Placement."])
    end)
    layout:When(Areas.UsesArea, function()
        layout:Choice({ id = "selectedArea", get = function() return Selected().id end,
            set = function(id) Areas.selected = id; Areas.RefreshMovers() end },
            L["Edit area"], AreaOptions, L["Choose the area the settings below change."])
        layout:Action("testSelectedArea", L["Test selected area"], nil, function()
            BD:ShowScreenAreaTest(Selected().id, not BD.Layout.IsScreen())
        end)
    end)
end

function Areas.BuildMotion(layout)
    layout:Heading(L["Motion"])
    layout:Choice(AreaBinding("animation"), L["Animation"], BD.SCREEN_AREA_ANIMATIONS, nil, nil, Apply)
    layout:When(LinearStyle, function()
        layout:Choice(AreaBinding("direction"), L["Direction"], BD.SCREEN_AREA_DIRECTIONS, nil, nil, Apply)
        layout:Choice({ id = "screenArea.stickyCrits", get = function()
            return Selected().stickyCrits and "hold" or "follow"
        end, set = function(value) Selected().stickyCrits = value == "hold" end }, L["Critical hits"], {
            { id = "follow", labelKey = "Follow area motion" },
            { id = "hold", labelKey = "Pop and hold in center" },
        }, nil, nil, Apply)
    end)
    layout:When(function() return Selected().animation ~= "static" end, function()
        layout:Slider(AreaBinding("duration"), L["Travel time"], 0.5, 8, 0.1,
            function(value) return string.format(L["%.1fs"], value) end, nil, Apply)
    end)
    layout:When(function() return Selected().animation == "static" end, function()
        layout:Slider(AreaBinding("duration"), L["Display duration"], 0.5, 8, 0.1,
            function(value) return string.format(L["%.1fs"], value) end, nil, Apply)
    end)
end

function Areas.BuildRouting(layout)
    for _, route in ipairs(BD.SCREEN_ROUTES) do
        layout:When(function()
            return route.fallback == "outgoing" and BD.Layout.IsScreen()
                or route.fallback == "incoming" and BD.db.showIncoming
        end, function()
            layout:Choice(route.key, L[route.labelKey], RoutingOptions, nil, nil, Apply)
        end)
    end
    layout:Action("testRoutes", L["Test routes"], nil, function()
        BD:ShowScreenAreaTest(nil, not BD.Layout.IsScreen())
    end)
end

function Areas.BuildPlacement(layout)
    layout:Heading(L["Screen areas"])
    layout:Action("unlockAreas", L["Unlock areas"],
        L["Show every area on screen to drag and resize it while sample numbers play."], function()
            Areas.Unlock()
        end)
    layout:Action("addArea", L["New area"], L["Add a custom area, then route numbers to it under Routing."],
        function()
            local area = BD:AddScreenArea()
            if area then
                Areas.selected = area.id
                if not BD.Layout.IsScreen() then Areas.newIncoming[area.id] = true end
            end
            Apply()
        end, function() return #(BD.db.screenAreas or {}) < BD.SCREEN_AREA_LIMIT end,
        string.format(L["You can have up to %d areas."], BD.SCREEN_AREA_LIMIT))
    layout:TextInput({
        id = "screenArea.name",
        get = function() return BD:GetScreenAreaLabel(Selected()) end,
        set = function(value) Selected().name = value end,
    }, L["Area name"], L["Rename the selected custom area."], BD.SCREEN_AREA_NAME_MAX, Apply, CustomSelected,
        L["Built-in areas keep their names."])
    layout:Action("deleteArea", L["Delete area"],
        L["Remove the selected custom area. Numbers routed to it return to the built-in areas."], function()
            BD:DeleteScreenArea(Selected().id)
            Areas.selected = BD.Layout.IsScreen() and "outgoing" or "incoming"
            Apply()
        end, CustomSelected, L["Built-in areas cannot be deleted."])

    layout:Heading(L["Position and size"])
    local ranges = BD.SCREEN_AREA_RANGES
    layout:Slider(AreaBinding("x"), L["X offset"], ranges.x[1], ranges.x[2], 1, PixelValue, nil, Apply)
    layout:Slider(AreaBinding("y"), L["Y offset"], ranges.y[1], ranges.y[2], 1, PixelValue, nil, Apply)
    layout:Slider(AreaBinding("width"), L["Width"], ranges.width[1], ranges.width[2], 1, PixelValue, nil, Apply)
    layout:Slider(AreaBinding("height"), L["Height"], ranges.height[1], ranges.height[2], 1, PixelValue, nil, Apply)
    layout:Note(L["Offsets are from the screen center and ignore the UI scale. Unlock areas to drag them instead."])

    layout:Slider(AreaBinding("spacing"), L["Line spacing"], 0, 24, 1, PixelValue, nil, Apply)
    layout:Choice(AreaBinding("alignment"), L["Alignment"], BD.SCREEN_AREA_ALIGNMENTS, nil, nil, Apply)
end

-- Unlock mode ---------------------------------------------------------------------------------

-- Movers ignore the UI scale like the numbers, so their center converts straight to area units.
local function MoverOffsets(mover)
    local x, y = mover:GetCenter()
    local ux, uy = UIParent:GetCenter()
    local ratio = UIParent:GetEffectiveScale() / mover:GetEffectiveScale()
    return math.floor(x - ux * ratio + 0.5), math.floor(y - uy * ratio + 0.5)
end

local function PlaceMover(mover, area)
    mover:ClearAllPoints()
    mover:SetPoint("CENTER", UIParent, "CENTER", area.x, area.y)
    mover:SetSize(area.width, area.height)
    mover.label:SetText(BD:GetScreenAreaLabel(area))
    mover.coords:SetText(string.format("%d, %d  ·  %d × %d", area.x, area.y, area.width, area.height))
    W.Backdrop(mover.background, area.id == Areas.selected and "selected" or "inset")
end

local function SaveMover(mover)
    mover:StopMovingOrSizing()
    -- Saved in PlateSCT's settings, not the game's frame layout cache.
    mover:SetUserPlaced(false)
    local area = BD.FindScreenArea(BD.db, mover.areaId)
    if not area then
        return
    end
    area.x, area.y = MoverOffsets(mover)
    area.width, area.height = math.floor(mover:GetWidth() + 0.5), math.floor(mover:GetHeight() + 0.5)
    Areas.selected = area.id
    Apply()
    if BD.configFrame then
        BD.configFrame:Refresh()
    end
end

local function Mover(index)
    if movers[index] then
        return movers[index]
    end
    local ranges = BD.SCREEN_AREA_RANGES
    local mover = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    mover:SetIgnoreParentScale(true)
    mover:SetFrameStrata("DIALOG")
    -- Fade only the surface, below the scrolling numbers; labels and handles stay opaque.
    mover.background = CreateFrame("Frame", nil, mover)
    mover.background:SetAllPoints()
    mover.background:SetFrameStrata("HIGH")
    mover.background:SetFrameLevel(0)
    mover.background:SetAlpha(0.45)
    mover:SetClampedToScreen(true)
    mover:EnableMouse(true)
    mover:SetMovable(true)
    mover:SetResizable(true)
    if mover.SetResizeBounds then
        mover:SetResizeBounds(ranges.width[1], ranges.height[1], ranges.width[2], ranges.height[2])
    else
        mover:SetMinResize(ranges.width[1], ranges.height[1])
        mover:SetMaxResize(ranges.width[2], ranges.height[2])
    end
    mover.label = W.Text(mover, "", 8, -6, nil, "GameFontNormal", { 0.88, 0.72, 0.43 })
    mover.coords = W.Text(mover, "", 8, -24, nil, "GameFontDisableSmall")
    mover:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then
            return
        end
        Areas.selected = self.areaId
        Areas.RefreshMovers()
        self:StartMoving()
    end)
    mover:SetScript("OnMouseUp", SaveMover)
    local grip = CreateFrame("Button", nil, mover)
    grip:SetSize(16, 16)
    grip:SetPoint("BOTTOMRIGHT", -2, 2)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grip:SetScript("OnMouseDown", function()
        Areas.selected = mover.areaId
        mover:StartSizing("BOTTOMRIGHT")
    end)
    grip:SetScript("OnMouseUp", function() SaveMover(mover) end)
    movers[index] = mover
    return mover
end

local function Toolbar()
    if toolbar then
        return toolbar
    end
    toolbar = CreateFrame("Frame", "PlateSCTScreenAreasToolbar", UIParent, "BackdropTemplate")
    toolbar:SetSize(380, 100)
    toolbar:SetPoint("TOP", UIParent, "TOP", 0, -96)
    toolbar:SetFrameStrata("FULLSCREEN_DIALOG")
    toolbar:SetClampedToScreen(true)
    toolbar:EnableMouse(true)
    toolbar:SetMovable(true)
    toolbar:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    toolbar:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
        self:SetUserPlaced(false)
    end)
    W.Backdrop(toolbar, "window")
    W.Text(toolbar, L["Screen areas unlocked"], 14, -12, 352, "GameFontNormal", { 0.88, 0.72, 0.43 })
    W.Text(toolbar, L["Drag an area to move it. Drag its corner to resize it."], 14, -32, 352, "GameFontDisableSmall")
    local test = W.Button(toolbar, L["Test"], 120, 26, function()
        BD:ShowScreenAreaTest(nil, not BD.Layout.IsScreen(), testSession, BD.Layout.IsScreen())
    end)
    test:SetPoint("BOTTOMLEFT", 14, 12)
    local done = W.Button(toolbar, L["Done"], 120, 26, function() toolbar:Hide() end)
    done:SetPoint("BOTTOMRIGHT", -14, 12)
    -- ESC closes the toolbar through the game's special-frames list, which locks the areas.
    tinsert(UISpecialFrames, "PlateSCTScreenAreasToolbar")
    toolbar:SetScript("OnHide", function() Areas.Lock() end)
    return toolbar
end

function Areas.RefreshMovers()
    if not Areas.unlocked then
        return
    end
    local areas = {}
    for _, area in ipairs(BD.db.screenAreas or {}) do
        if Available(area) then areas[#areas + 1] = area end
    end
    for index, area in ipairs(areas) do
        local mover = Mover(index)
        mover.areaId = area.id
        PlaceMover(mover, area)
        mover:Show()
    end
    for index = #areas + 1, #movers do
        movers[index]:Hide()
    end
end

local function StopPreview()
    if not testSession then return end
    testSession.active = false
    BD.Pool.ReleasePreviewFrames(testSession)
    testSession = nil
end

function Areas.RefreshPreview()
    StopPreview()
    local config = BD.configFrame
    if not Areas.unlocked and not (BD.Layout.IsScreen() and config and config:IsShown()) then return end
    BD:EnsureScreenAreas()
    local session = { active = true }
    testSession = session
    local function Replay()
        if not session.active then return end
        BD:ShowScreenAreaTest(nil, not BD.Layout.IsScreen(), session, BD.Layout.IsScreen())
        C_Timer.After(2, Replay)
    end
    Replay()
end

function Areas.Unlock()
    if Areas.unlocked then
        return
    end
    BD:EnsureScreenAreas()
    local config = BD.configFrame
    reopenOptions = config and config:IsShown() and true or false
    if config then
        config:Hide()
    end
    Areas.unlocked = true
    Areas.RefreshMovers()
    Toolbar():Show()
    Areas.RefreshPreview()
end

function Areas.Lock()
    if not Areas.unlocked then
        return
    end
    Areas.unlocked = false
    StopPreview()
    for _, mover in ipairs(movers) do
        mover:Hide()
    end
    if toolbar and toolbar:IsShown() then
        toolbar:Hide()
    end
    if reopenOptions then
        reopenOptions = false
        BD:OpenOptions()
    end
end
