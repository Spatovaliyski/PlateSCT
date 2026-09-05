local ADDON_NAME, BD = ...

-- Replace Media/icon.png (same basename) with the real addon art.
BD.ICON_TEXTURE = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\icon"

local L = BD.L
local button
local dragging = false

local MINIMAP_SHAPES = {
    ["ROUND"] = { true, true, true, true },
    ["SQUARE"] = { false, false, false, false },
    ["CORNER-TOPLEFT"] = { false, false, false, true },
    ["CORNER-TOPRIGHT"] = { false, false, true, false },
    ["CORNER-BOTTOMLEFT"] = { true, false, false, false },
    ["CORNER-BOTTOMRIGHT"] = { false, true, false, false },
    ["SIDE-LEFT"] = { true, false, false, true },
    ["SIDE-RIGHT"] = { false, true, true, false },
    ["SIDE-TOP"] = { false, false, true, true },
    ["SIDE-BOTTOM"] = { true, true, false, false },
    ["TRICORNER-TOPLEFT"] = { false, true, false, true },
    ["TRICORNER-TOPRIGHT"] = { false, false, true, true },
    ["TRICORNER-BOTTOMLEFT"] = { true, true, false, false },
    ["TRICORNER-BOTTOMRIGHT"] = { true, true, true, false },
}

local function ShowTooltip(owner)
    GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
    GameTooltip:SetText(ADDON_NAME)
    GameTooltip:AddLine(L["Click to open settings."], 1, 1, 1)
    GameTooltip:Show()
end

local function UpdatePosition()
    if not button then
        return
    end

    local angle = math.rad(BD.db.minimapAngle or BD.DEFAULTS.minimapAngle or 200)
    local x, y, q = math.cos(angle), math.sin(angle), 1
    if x < 0 then
        q = q + 1
    end
    if y > 0 then
        q = q + 2
    end

    local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
    local quad = MINIMAP_SHAPES[shape] or MINIMAP_SHAPES.ROUND
    local w = (Minimap:GetWidth() / 2) + 5
    local h = (Minimap:GetHeight() / 2) + 5

    if quad[q] then
        x, y = x * w, y * h
    else
        local diagW = math.sqrt(2 * (w ^ 2)) - 10
        local diagH = math.sqrt(2 * (h ^ 2)) - 10
        x = math.max(-w, math.min(x * diagW, w))
        y = math.max(-h, math.min(y * diagH, h))
    end

    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function DragUpdate()
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    px, py = px / scale, py / scale
    BD.db.minimapAngle = math.deg(math.atan2(py - my, px - mx))
    UpdatePosition()
end

function BD:RefreshMinimapButton()
    if not button then
        return
    end
    UpdatePosition()
    if BD.db.showMinimapButton then
        button:Show()
    else
        button:Hide()
    end
end

local function CreateMinimapButton()
    if button or not Minimap then
        return
    end

    button = CreateFrame("Button", "PlateSCTMinimapButton", Minimap)
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")
    if button.SetFixedFrameStrata then
        button:SetFixedFrameStrata(true)
    end
    if button.SetFixedFrameLevel then
        button:SetFixedFrameLevel(true)
    end
    if button.SetDontSavePosition then
        button:SetDontSavePosition(true)
    end

    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetPoint("TOPLEFT", 7, -5)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(17, 17)
    icon:SetTexture(BD.ICON_TEXTURE)
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    icon:SetPoint("TOPLEFT", 7, -6)
    button.icon = icon

    button:SetScript("OnEnter", function(self)
        ShowTooltip(self)
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    button:SetScript("OnClick", function()
        if dragging then
            return
        end
        BD:OpenOptions()
    end)
    button:SetScript("OnDragStart", function(self)
        dragging = true
        self:LockHighlight()
        GameTooltip:Hide()
        self:SetScript("OnUpdate", DragUpdate)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        self:UnlockHighlight()
        UpdatePosition()
        C_Timer.After(0, function()
            dragging = false
        end)
    end)

    BD:RefreshMinimapButton()
end

function PlateSCT_OnAddonCompartmentClick()
    BD:OpenOptions()
end

function PlateSCT_OnAddonCompartmentEnter(_, menuButton)
    ShowTooltip(menuButton or UIParent)
end

function PlateSCT_OnAddonCompartmentLeave()
    GameTooltip:Hide()
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    CreateMinimapButton()
end)
