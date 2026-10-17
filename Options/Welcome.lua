local ADDON_NAME, BD = ...
local L, W = BD.L, BD.OptionsWidgets

-- First-install welcome: a short greeting and a choice of starting profile.
-- Shown once (BD.db.welcomePending), never during combat, and again on /psct welcome.

local WIDTH, CARD_HEIGHT = 520, 76
local GOLD = { 0.92, 0.76, 0.42 }

local welcome

local function FinishWelcome()
    BD.db.welcomePending = false
    if welcome then welcome:Hide() end
end

local function ChooseProfile(id)
    local profile = BD:ApplyProfile(id)
    FinishWelcome()
    print("|cff66ccffPlateSCT:|r " .. string.format(L["%s profile applied. Type /psct to customize it."], L[profile.labelKey]))
end

local function BuildCard(parent, profile, y)
    local card = CreateFrame("Button", nil, parent, "BackdropTemplate")
    card:SetPoint("TOPLEFT", 20, y)
    card:SetPoint("TOPRIGHT", -20, y)
    card:SetHeight(CARD_HEIGHT)
    W.Backdrop(card, "row")
    local title = W.Text(card, L[profile.labelKey], 14, -12, WIDTH - 68, "GameFontNormalLarge", GOLD)
    local body = W.Text(card, L[profile.descriptionKey], 14, -36, WIDTH - 68, "GameFontHighlightSmall")
    card.title, card.body = title, body
    card:SetScript("OnEnter", function(self) W.Backdrop(self, "selected") end)
    card:SetScript("OnLeave", function(self) W.Backdrop(self, "row") end)
    card:SetScript("OnClick", function() ChooseProfile(profile.id) end)
    return card
end

local function BuildWelcome()
    local frame = CreateFrame("Frame", "PlateSCTWelcomeFrame", UIParent, "BackdropTemplate")
    frame:Hide()
    frame:SetWidth(WIDTH)
    frame:SetPoint("CENTER", 0, 60)
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); self:SetUserPlaced(false) end)
    W.Backdrop(frame, "window")
    tinsert(UISpecialFrames, "PlateSCTWelcomeFrame")

    local logo = frame:CreateTexture(nil, "ARTWORK")
    logo:SetTexture("Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\psct-logo-mini.png")
    logo:SetSize(32, 32)
    logo:SetPoint("TOPLEFT", 18, -16)
    W.Text(frame, L["Welcome to PlateSCT"], 58, -22, WIDTH - 120, "GameFontNormalLarge", GOLD)

    local close = W.CloseButton(frame, FinishWelcome)
    close:SetPoint("TOPRIGHT", -4, -4)
    W.Tooltip(close, L["Close"])

    local y = -62
    for _, text in ipairs({
        L["PlateSCT puts your damage numbers on enemy nameplates, so every hit shows up right where it landed."],
        L["It keeps busy fights readable: rapid hits combine, small hits fade back, and crits stand out."],
        L["It works on Midnight and on Classic clients, within each game version's combat rules."],
    }) do
        local line = W.Text(frame, text, 20, y, WIDTH - 40, "GameFontHighlight")
        y = y - math.max(16, line:GetStringHeight()) - 6
    end
    -- Modern clients only: Classic still has the full combat log, so attribution is exact there.
    if BD.API.IsModern() then
        local caveat = W.Text(frame,
            L["Note: Blizzard's new addon rules hide who dealt each hit, so some numbers can be credited to the wrong source or missed."],
            20, y - 2, WIDTH - 40, "GameFontHighlightSmall", { 0.82, 0.74, 0.6 })
        y = y - 2 - math.max(14, caveat:GetStringHeight()) - 6
    end

    y = y - 8
    W.Text(frame, L["Choose a starting profile. You can change every setting later."], 20, y, WIDTH - 40, "GameFontNormal", GOLD)
    y = y - 26
    frame.cards = {}
    for _, profile in ipairs(BD.PROFILES) do
        frame.cards[#frame.cards + 1] = BuildCard(frame, profile, y)
        y = y - CARD_HEIGHT - 8
    end

    local settings = W.Button(frame, L["Open settings instead"], 180, 24, function()
        FinishWelcome()
        BD:OpenOptions()
    end, "flat")
    settings:SetPoint("TOPRIGHT", -20, y - 4)
    W.Tooltip(settings, L["Keep the Default profile and open the settings window."])

    frame:SetHeight(-y + 44)
    -- Closing with ESC or the close button keeps the Default profile and does not ask again.
    frame:SetScript("OnHide", function() BD.db.welcomePending = false end)
    return frame
end

function BD:ShowWelcome()
    welcome = welcome or BuildWelcome()
    welcome:Show()
    welcome:Raise()
end

-- Waits for combat to end so the dialog never appears mid-fight. One waiter frame is reused.
local combatWaiter

function BD:ShowWelcomeWhenReady()
    if not self.db.welcomePending then
        return
    end
    if InCombatLockdown() then
        if not combatWaiter then
            combatWaiter = CreateFrame("Frame")
            combatWaiter:SetScript("OnEvent", function(self)
                self:UnregisterEvent("PLAYER_REGEN_ENABLED")
                BD:ShowWelcomeWhenReady()
            end)
        end
        combatWaiter:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    self:ShowWelcome()
end
