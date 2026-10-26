local _, BD = ...
local L, W = BD.L, BD.OptionsWidgets
local GOLD = { 0.92, 0.76, 0.42 }
local WIDTH, SAMPLE_HEIGHT, SAMPLE_SCALE, SAMPLE_INTERVAL = 840, 216, 0.85, 0.8

local function AddSampleScene(card, y)
    local row = CreateFrame("Frame", nil, card)
    row:SetSize(228, SAMPLE_HEIGHT); row:SetPoint("TOPLEFT", 12, y)
    local viewport = CreateFrame("Frame", nil, row)
    viewport:SetAllPoints()
    viewport:SetClipsChildren(true)
    local origin = CreateFrame("Frame", nil, viewport)
    origin:SetSize(1, 1)
    local stage = CreateFrame("Frame", nil, origin)
    stage:SetSize(1, 1); stage:SetPoint("CENTER"); stage:SetScale(SAMPLE_SCALE)
    row.viewport, row.origin, row.stage = viewport, origin, stage
    return row
end

local function BuildWelcome()
    local frame = CreateFrame("Frame", "PlateSCTWelcomeFrame", UIParent, "BackdropTemplate")
    frame:Hide(); frame:SetWidth(WIDTH); frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG"); frame:SetToplevel(true); frame:SetClampedToScreen(true)
    frame:EnableMouse(true); frame:SetMovable(true)
    W.Backdrop(frame, "window")
    if not tContains(UISpecialFrames, "PlateSCTWelcomeFrame") then
        tinsert(UISpecialFrames, "PlateSCTWelcomeFrame")
    end
    local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    header:SetPoint("TOPLEFT", 2, -2); header:SetPoint("TOPRIGHT", -2, -2); header:SetHeight(52)
    W.Backdrop(header, "inset"); header:EnableMouse(true)
    W.Text(header, L["Welcome to PlateSCT"], 22, -16, WIDTH - 80, "GameFontNormalLarge", GOLD)
    header:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then frame:StartMoving() end
    end)
    header:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
    frame.header = header
    local close = W.CloseButton(frame, function() frame:Hide() end)
    close:SetPoint("TOPRIGHT", -4, -4); close:SetFrameLevel(header:GetFrameLevel() + 5)

    local y = -66
    local function Paragraph(text)
        local label = W.Text(frame, text, 24, y, WIDTH - 48)
        y = y - label:GetStringHeight() - 28
        return label
    end
    local function Heading(text)
        y = y - 10
        local label = W.Text(frame, text, 24, y, WIDTH - 48, "GameFontNormal", GOLD)
        y = y - label:GetStringHeight() - 8
    end
    Paragraph(L["Damage numbers, right on enemy nameplates. Choose a number style to get started, or open settings to make it your own."])
    if BD.API.IsModern() then
        Heading(L["Modern API: Secrets & restrictions"])
        frame.restrictions = Paragraph(L["WoW hides some combat data as Secret values. Addons cannot reliably identify every damage source or spell. Personal mode estimates ownership; unreadable data limits filters, hit combining, icons, and sounds."])
    end
    Heading(L["Choose your number style"])
    Paragraph(L["All number styles are available on every supported WoW API."])
    local styles = {
        { "retail", "Modern number style", "Smooth upward motion with a small critical pop." },
        { "classic", "Classic number style", "Grow-and-settle numbers with bold critical hits." },
        { "impact", "Impact number style", "A quick slam followed by upward motion." },
    }
    frame.cards = {}
    local descriptionHeight = 0
    for index, entry in ipairs(styles) do
        local style = entry[1]
        local card = CreateFrame("Button", nil, frame, "BackdropTemplate")
        card:SetWidth(252); card:SetPoint("TOPLEFT", 24 + (index - 1) * 270, y)
        W.Backdrop(card, "inset")
        card:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
        local highlight = card:GetHighlightTexture()
        if highlight then highlight:SetVertexColor(GOLD[1], GOLD[2], GOLD[3], 0.12) end
        card.style = style
        local heading = W.Text(card, L[entry[2]], 12, -16, 228, "GameFontNormal", GOLD)
        local description = W.Text(card, L[entry[3]], 12, -22 - heading:GetStringHeight(), 228)
        descriptionHeight = math.max(descriptionHeight, heading:GetStringHeight() + description:GetStringHeight())
        card:SetScript("OnClick", function() frame:SelectStyle(style) end)
        frame.cards[index] = card
    end
    local sampleY = -40 - descriptionHeight
    local cardHeight = -sampleY + SAMPLE_HEIGHT + 36
    for _, card in ipairs(frame.cards) do
        card:SetHeight(cardHeight)
        card.sample = AddSampleScene(card, sampleY)
        -- Keep the key beneath the motion area; both kinds share a live spawn point.
        W.Text(card, L["Hit"] .. " 1234", 12, -cardHeight + 24, 108)
        local crit = W.Text(card, L["Crit"] .. " 5678", 132, -cardHeight + 24, 108)
        crit:SetJustifyH("RIGHT")
    end
    y = y - cardHeight - 24
    local apply = W.Button(frame, L["Apply"], 160, 32, function()
        if not frame.pendingStyle then return end
        BD.db.numberStyle = frame.pendingStyle
        frame:Hide()
        if BD.configFrame then BD.configFrame:Refresh() end
    end)
    apply:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -24, y)
    local open = W.TextLink(frame, L["I want to customize instead"], function() BD:OpenOptions() end)
    open:SetPoint("RIGHT", apply, "LEFT", -18, 0)
    frame.apply, frame.openSettings = apply, open
    y = y - 60
    Paragraph(L["Open settings anytime from the minimap icon or by typing /psct. Reopen this screen with /psct welcome."])
    frame:SetHeight(-y)

    function frame:UpdateSelection()
        local selected = self.pendingStyle or BD.db.numberStyle
        for _, card in ipairs(self.cards) do
            card.selected = card.style == selected
            card:SetBackdropBorderColor(unpack(card.selected and GOLD or { 0.36, 0.28, 0.17 }))
        end
        self.apply:SetEnabled(self.pendingStyle ~= nil)
        W.PaintAction(self.apply, "idle")
    end
    function frame:SelectStyle(style)
        if not BD.STYLE_PRESETS[style] then return end
        self.pendingStyle = style
        self:UpdateSelection()
    end
    function frame:LayoutSamples()
        for _, card in ipairs(self.cards) do
            local row = card.sample
            local l, r, b, t = BD:GetStyleSampleBounds(card.style, "mixed", SAMPLE_INTERVAL)
            row.origin:ClearAllPoints()
            row.origin:SetPoint("CENTER", row.viewport, "CENTER", -(l + r) * 0.5 * SAMPLE_SCALE, -(b + t) * 0.5 * SAMPLE_SCALE)
        end
    end
    function frame:FitToScreen()
        self:SetScale(math.min(1, UIParent:GetWidth() * 0.94 / WIDTH,
            UIParent:GetHeight() * 0.94 / self:GetHeight()))
        self:LayoutSamples()
    end
    frame:SetScript("OnShow", function(self)
        BD.db.welcomeSeen = true
        self.pendingStyle = nil; self:UpdateSelection()
        self:RegisterEvent("UI_SCALE_CHANGED"); self:RegisterEvent("DISPLAY_SIZE_CHANGED")
        self:FitToScreen()
        self.previewGeneration = (self.previewGeneration or 0) + 1
        local generation = self.previewGeneration
        local kind = "hit"
        local function PlaySamples()
            if not self:IsShown() or generation ~= self.previewGeneration then return end
            for _, card in ipairs(self.cards) do
                BD:ShowStyleSample(card.sample.stage, card.style, kind)
            end
            -- Incoming hits overlap the previous fade, as they do in combat.
            kind = kind == "hit" and "crit" or "hit"
            C_Timer.After(SAMPLE_INTERVAL, PlaySamples)
        end
        C_Timer.After(0, PlaySamples)
    end)
    frame:SetScript("OnHide", function(self)
        self:StopMovingOrSizing(); self:UnregisterAllEvents()
        self.previewGeneration = (self.previewGeneration or 0) + 1
        for _, card in ipairs(self.cards) do
            BD.Pool.ReleasePreviewFrames(card.sample.stage)
        end
    end)
    frame:SetScript("OnEvent", function(self) self:FitToScreen() end)
    frame.locale = BD:ResolveLocaleCode()
    return frame
end

function BD:OpenWelcome()
    if self.configFrame then self.configFrame:Hide() end
    if self.welcomeFrame and self.welcomeFrame.locale ~= self:ResolveLocaleCode() then
        self.welcomeFrame:Hide()
        self.welcomeFrame = nil
    end
    if not self.welcomeFrame then self.welcomeFrame = BuildWelcome() end
    self.welcomeFrame:Show(); self.welcomeFrame:Raise()
end
