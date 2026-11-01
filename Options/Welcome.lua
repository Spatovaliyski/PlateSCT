local _, BD = ...
local L, W = BD.L, BD.OptionsWidgets
local C = W.COLORS
local GOLD = C.accent
local WIDTH, PAD, GAP = 840, 24, 18
local SAMPLE_HEIGHT, SCENE_HEIGHT, SAMPLE_SCALE, SAMPLE_INTERVAL = 216, 232, 0.85, 0.8
local PLATE_TOP = 34
-- Sample areas are smaller than the defaults so their numbers can play at full size.
local SAMPLE_AREA_WIDTH, SAMPLE_AREA_HEIGHT = 160, 200
-- Previews are never smaller than this (the settings drawer uses the same floor).
local MIN_SCALE = 0.7
local AREA_FILL = { 0.118, 0.102, 0.078, 1 }

-- Two steps: pick a layout, then set it up. Nothing is saved until Apply.
local STEP_NUMBERS = { layout = 1, nameplates = 2, screen = 2 }
local MOTIONS = {
    { id = "straight", title = "Straight", body = "Numbers scroll up at a steady speed, then fade." },
    { id = "curveRight", title = "Curve right", body = "Numbers arc outward as they rise." },
    { id = "impact", title = "Impact", body = "Each hit slams in and pushes older numbers up." },
}
local STYLES = {
    { id = "retail", title = "Modern number style", body = "Smooth upward motion with a small critical pop." },
    { id = "classic", title = "Classic number style", body = "Grow-and-settle numbers with bold critical hits." },
    { id = "impact", title = "Impact number style", body = "A quick slam followed by upward motion." },
}

local function SampleArea(id, animation)
    for _, builtin in ipairs(BD.DEFAULT_SCREEN_AREAS) do
        if builtin.id == id then
            local area = BD.NormalizeScreenArea(builtin)
            area.animation = animation or area.animation
            area.width, area.height = SAMPLE_AREA_WIDTH, SAMPLE_AREA_HEIGHT
            return area
        end
    end
end

local function CurrentMotion()
    local area = BD.FindScreenArea(BD.db, "outgoing")
    for _, motion in ipairs(MOTIONS) do
        if area and area.animation == motion.id then return motion.id end
    end
    return "straight"
end

-- Scenes ----------------------------------------------------------------------------------------
-- A clipped viewport where live samples play. Each scene has Layout, Play(kind) and Release.

local function Viewport(parent, x, y, width, height, painted)
    local viewport = CreateFrame("Frame", nil, parent)
    viewport:SetSize(width, height); viewport:SetPoint("TOPLEFT", x, y)
    viewport:SetClipsChildren(true)
    if painted then W.Paint(viewport, C.sidebar, 8) end
    return viewport
end

-- Number style samples, centered or resting on a drawn nameplate. style is an id or a function.
local function StyleScene(parent, x, y, width, height, style, plate)
    local viewport = Viewport(parent, x, y, width, height, plate)
    local origin = CreateFrame("Frame", nil, viewport)
    origin:SetSize(1, 1)
    local stage = CreateFrame("Frame", nil, origin)
    stage:SetSize(1, 1); stage:SetPoint("CENTER"); stage:SetScale(SAMPLE_SCALE)
    if plate then
        local bar = CreateFrame("Frame", nil, viewport)
        bar:SetSize(120, 9); bar:SetPoint("BOTTOM", 0, PLATE_TOP - 9)
        local back = bar:CreateTexture(nil, "ARTWORK"); back:SetAllPoints(); back:SetColorTexture(0, 0, 0, 1)
        local health = bar:CreateTexture(nil, "OVERLAY")
        health:SetPoint("TOPLEFT", 1, -1); health:SetPoint("BOTTOMLEFT", 1, 1); health:SetWidth(76)
        health:SetColorTexture(C.health[1], C.health[2], C.health[3], 1)
    end
    local scene = { viewport = viewport, origin = origin, stage = stage }
    function scene:Style()
        return type(style) == "function" and style() or style
    end
    function scene:Layout()
        local l, r, b, t = BD:GetStyleSampleBounds(self:Style(), "mixed", SAMPLE_INTERVAL)
        origin:ClearAllPoints()
        if plate then
            -- Samples rise from just above the plate at full size; the far end of the motion
            -- may clip at the top, as it would above a real plate.
            stage:SetScale(1)
            origin:SetPoint("CENTER", viewport, "BOTTOM", -(l + r) * 0.5, PLATE_TOP + 4 - b)
        else
            origin:SetPoint("CENTER", viewport, "CENTER", -(l + r) * 0.5 * SAMPLE_SCALE, -(b + t) * 0.5 * SAMPLE_SCALE)
        end
    end
    function scene:Play(kind)
        BD:ShowStyleSample(stage, self:Style(), kind)
    end
    function scene:Release()
        BD.Pool.ReleasePreviewFrames(stage)
    end
    return scene
end

-- Screen areas drawn as boxes; samples play through the live area spawn. Each slot is
-- { area, incoming, offset } where offset is a share of the viewport width from its center.
local function AreaScene(parent, x, y, width, height, slots, painted)
    local viewport = Viewport(parent, x, y, width, height, painted)
    local scene = { viewport = viewport, slots = {} }
    for index, slot in ipairs(slots) do
        local box = CreateFrame("Frame", nil, viewport)
        W.Paint(box, AREA_FILL, 4)
        local stage = CreateFrame("Frame", nil, box)
        stage:SetSize(slot.area.width, slot.area.height); stage:SetPoint("CENTER")
        scene.slots[index] = { box = box, stage = stage, area = slot.area, incoming = slot.incoming,
            offset = slot.offset or 0 }
    end
    function scene:Layout()
        local share = width / #self.slots
        for _, slot in ipairs(self.slots) do
            local area = slot.area
            local scale = math.max(MIN_SCALE, math.min(1, (height - 16) / area.height, (share - 16) / area.width))
            slot.stage:SetScale(scale)
            slot.box:SetSize(area.width * scale, area.height * scale)
            slot.box:ClearAllPoints()
            slot.box:SetPoint("CENTER", viewport, "CENTER", slot.offset * width, 0)
        end
    end
    function scene:Play(kind)
        for _, slot in ipairs(self.slots) do
            BD:ShowScreenAreaSample(slot.stage, slot.area, kind, slot.incoming)
        end
    end
    function scene:Release()
        for _, slot in ipairs(self.slots) do BD.Pool.ReleasePreviewFrames(slot.stage) end
    end
    return scene
end

-- Building blocks -------------------------------------------------------------------------------

-- A row of selectable cards: text on top, then room for a scene. Each entry is
-- { id, title, body, note }, already localized. Returns the cards and the y below the row.
local function CardRow(step, y, entries, sceneHeight, keyLine, onPick)
    local count = #entries
    local width = math.floor((WIDTH - PAD * 2 - GAP * (count - 1)) / count)
    local cards, textHeight = {}, 0
    for index, entry in ipairs(entries) do
        local card = CreateFrame("Button", nil, step, "BackdropTemplate")
        card:SetWidth(width); card:SetPoint("TOPLEFT", PAD + (index - 1) * (width + GAP), y)
        W.Backdrop(card, "card")
        -- Inset so the square hover wash stays inside the rounded corners.
        card:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
        local highlight = card:GetHighlightTexture()
        if highlight then
            highlight:SetVertexColor(1, 1, 1, 0.025)
            if highlight.ClearAllPoints then
                highlight:ClearAllPoints(); highlight:SetPoint("TOPLEFT", 8, -8); highlight:SetPoint("BOTTOMRIGHT", -8, 8)
            end
        end
        card.id = entry.id
        local heading = W.Text(card, entry.title, 16, -16, width - 32, "GameFontNormal", C.bright)
        local bodyY = -22 - heading:GetStringHeight()
        local body = W.Text(card, entry.body, 16, bodyY, width - 32, nil, C.muted)
        local used = heading:GetStringHeight() + body:GetStringHeight()
        if entry.note then
            local note = W.Text(card, entry.note, 16, bodyY - body:GetStringHeight() - 8, width - 32, nil, C.dim)
            used = used + 8 + note:GetStringHeight()
        end
        textHeight = math.max(textHeight, used)
        card:SetScript("OnClick", function() onPick(entry.id) end)
        cards[index] = card
    end
    local sceneY = -40 - textHeight
    local cardHeight = -sceneY + sceneHeight + (keyLine and 36 or 12)
    for _, card in ipairs(cards) do
        card:SetHeight(cardHeight)
        card.sceneY, card.sceneWidth = sceneY, width - 24
        if keyLine then
            -- Keep the key beneath the motion area; both kinds share a live spawn point.
            W.Text(card, L["Hit"] .. " 1234", 16, -cardHeight + 28, 104, nil, C.dim)
            local crit = W.Text(card, L["Crit"] .. " 5678", width - 120, -cardHeight + 28, 104, nil, C.dim)
            crit:SetJustifyH("RIGHT")
        end
    end
    return cards, y - cardHeight
end

local function PaintCards(cards, selected)
    for _, card in ipairs(cards) do
        card.selected = card.id == selected
        W.Backdrop(card, card.selected and "cardSelected" or "card")
    end
end

-- "Show incoming hits", kept pending until Apply. Returns the switch and the y below the row.
local function IncomingRow(frame, step, y)
    local row = CreateFrame("Frame", nil, step)
    row:SetPoint("TOPLEFT", PAD, y); row:SetWidth(WIDTH - PAD * 2)
    row:EnableMouse(true)
    local label = W.Text(row, L["Show incoming hits"], 0, -2, WIDTH - PAD * 2 - 64, nil, C.bright)
    W.SetFont(label, "medium", 14)
    local tip = W.SetSmall(W.Text(row, L["Incoming hits use screen areas in either layout."], 0,
        -8 - label:GetStringHeight(), WIDTH - PAD * 2 - 64, nil, C.muted))
    local switch = W.Switch(row)
    switch:SetPoint("TOPRIGHT", 0, 0)
    local function Toggle(checked)
        frame.pending.incoming = checked
        switch:SetChecked(checked)
        switch.animateNext = true
        switch:Paint()
    end
    switch:SetScript("OnClick", function(self) Toggle(self:GetChecked() and true or false) end)
    row:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then Toggle(not frame.pending.incoming) end
    end)
    local height = 10 + label:GetStringHeight() + tip:GetStringHeight()
    row:SetHeight(math.max(24, height))
    return switch, y - math.max(24, height) - 24
end

-- Action buttons fit their label once the bundled fonts have loaded.
local function FitButton(button)
    local font = button:GetFontString()
    W.RefreshText(font)
    button:SetWidth(math.max(button.minWidth or 120, math.ceil(font:GetStringWidth() + 40)))
end

-- The footer: optional Back on the left; actions and the customize link on the right; then the
-- reopen hint. actions run right to left: { label, onClick, style }.
local function Tail(frame, step, back, actions)
    local tail = CreateFrame("Frame", nil, step)
    tail:SetWidth(WIDTH)
    step.buttons = {}
    local previous
    for index, action in ipairs(actions) do
        local button = W.Button(tail, action[1], 160, 34, action[2], action[3])
        button.minWidth = 160
        if previous then
            button:SetPoint("RIGHT", previous, "LEFT", -10, 0)
        else
            button:SetPoint("TOPRIGHT", tail, "TOPRIGHT", -PAD, 0)
        end
        step.buttons[index], previous = button, button
    end
    step.primary = step.buttons[1]
    step.openSettings = W.TextLink(tail, L["I want to customize instead"], function() BD:OpenOptions() end)
    step.openSettings:SetPoint("RIGHT", previous, "LEFT", -18, 0)
    if back then
        step.back = W.Button(tail, L["Back"], 100, 34, function() frame:ShowStep("layout") end, "ghost")
        step.back.minWidth = 100
        step.back:SetPoint("TOPLEFT", tail, "TOPLEFT", PAD, 0)
        step.buttons[#step.buttons + 1] = step.back
    end
    local hint = W.Text(tail, L["Open settings anytime from the minimap icon or by typing /psct. Reopen this screen with /psct welcome."],
        PAD, -60, WIDTH - PAD * 2)
    tail:SetHeight(60 + hint:GetStringHeight() + 28)
    step.tail = tail
    return tail
end

local function NewStep(frame)
    local step = CreateFrame("Frame", nil, frame)
    step:SetPoint("TOPLEFT"); step:SetWidth(WIDTH); step:Hide()
    step.scenes = {}
    local y = -66
    function step:Paragraph(text, color)
        local label = W.Text(self, text, PAD, y, WIDTH - PAD * 2, nil, color)
        y = y - label:GetStringHeight() - 28
        return label
    end
    function step:Heading(text)
        y = y - 10
        local label = W.Text(self, text, PAD, y, WIDTH - PAD * 2, "GameFontNormal", GOLD)
        y = y - label:GetStringHeight() - 8
        return label
    end
    function step:Y(value)
        if value then y = value end
        return y
    end
    -- Place the optional rows and the footer; the step's height follows.
    function step:Relayout()
        local bottom = self.bodyY
        if self.warning then
            local shown = self.ShowWarning()
            self.warning:SetShown(shown)
            if shown then
                self.warning:ClearAllPoints()
                self.warning:SetPoint("TOPLEFT", PAD, bottom)
                bottom = bottom - self.warning:GetHeight() - 24
            end
        end
        self.tail:ClearAllPoints()
        self.tail:SetPoint("TOPLEFT", 0, bottom)
        self.height = -bottom + self.tail:GetHeight()
    end
    return step
end

-- Steps -----------------------------------------------------------------------------------------

local function BuildLayoutStep(frame)
    local step = NewStep(frame)
    step.intro = step:Paragraph(L["Scrolling combat text for your hits, on enemy nameplates or in screen areas. Pick a layout to get started, or open settings to make it your own."])
    if BD.API.IsModern() then
        step.restrictionsHeading = step:Heading(L["Modern API: Secrets & restrictions"])
        frame.restrictions = step:Paragraph(L["WoW hides some combat data as Secret values. Addons cannot reliably identify every damage source or spell. Personal mode estimates ownership; unreadable data limits filters, hit combining, icons, and sounds."])
    end
    step:Heading(L["Choose your layout"])
    local cards, y = CardRow(step, step:Y(), {
        { id = "nameplates", title = L["Nameplates"],
            body = L["Numbers rise from each enemy's nameplate and follow it. Needs enemy nameplates."],
            note = L["Best for seeing which enemy each hit lands on."] },
        { id = "screen", title = L["Screen"],
            body = L["Numbers scroll through areas you place on the screen, like classic combat text addons."],
            note = L["Best for a steady readout in one place you choose."] },
    }, SCENE_HEIGHT, false, function(id)
        frame.pending.layout = id
        PaintCards(step.cards, id)
    end)
    step.cards = cards
    local plate, screen = cards[1], cards[2]
    step.scenes[1] = StyleScene(plate, 12, plate.sceneY, plate.sceneWidth, SCENE_HEIGHT,
        function() local _, style = BD:GetStylePreset(); return style end, true)
    step.scenes[2] = AreaScene(screen, 12, screen.sceneY, screen.sceneWidth, SCENE_HEIGHT, {
        { area = SampleArea("incoming"), incoming = true, offset = -0.25 },
        { area = SampleArea("outgoing"), offset = 0.25 },
    }, true)
    step.bodyY = y - 24
    Tail(frame, step, false, { { L["Next"], function() frame:ShowStep(frame.pending.layout) end } })
    function step:Refresh() PaintCards(self.cards, frame.pending.layout) end
    return step
end

local function BuildNameplateStep(frame)
    local step = NewStep(frame)
    step:Heading(L["Choose your number style"])
    step:Paragraph(L["All number styles are available on every supported WoW API."])
    local entries = {}
    for index, style in ipairs(STYLES) do
        entries[index] = { id = style.id, title = L[style.title], body = L[style.body] }
    end
    local cards, y = CardRow(step, step:Y(), entries, SAMPLE_HEIGHT, true, function(id)
        if not BD.STYLE_PRESETS[id] then return end
        frame.pending.style = id
        PaintCards(step.cards, id)
    end)
    step.cards = cards
    for index, card in ipairs(cards) do
        step.scenes[index] = StyleScene(card, 12, card.sceneY, card.sceneWidth, SAMPLE_HEIGHT, card.id)
    end
    step.incoming, step.bodyY = IncomingRow(frame, step, y - 24)
    step.warning = W.WarningBox(step,
        L["Enemy nameplates are off. Press V (default) to enable outgoing hits from nameplates."], WIDTH - PAD * 2)
    step.ShowWarning = function() return not BD.Layout.EnemyNameplatesShown() end
    Tail(frame, step, true, { { L["Apply"], function() frame:Apply() end } })
    step.apply = step.primary
    function step:Refresh()
        PaintCards(self.cards, frame.pending.style)
        self.incoming:SetChecked(frame.pending.incoming); self.incoming:Paint()
    end
    return step
end

local function BuildScreenStep(frame)
    local step = NewStep(frame)
    step:Heading(L["Choose how numbers move"])
    step:Paragraph(L["This sets the Outgoing area. Fine-tune each area's motion, size, and routing later under Layout → Areas."])
    local entries = {}
    for index, motion in ipairs(MOTIONS) do
        entries[index] = { id = motion.id, title = L[motion.title], body = L[motion.body] }
    end
    local cards, y = CardRow(step, step:Y(), entries, SAMPLE_HEIGHT, false, function(id)
        frame.pending.motion = id
        PaintCards(step.cards, id)
    end)
    step.cards = cards
    for index, card in ipairs(cards) do
        step.scenes[index] = AreaScene(card, 12, card.sceneY, card.sceneWidth, SAMPLE_HEIGHT,
            { { area = SampleArea("outgoing", card.id) } })
    end
    step.incoming, y = IncomingRow(frame, step, y - 24)
    if BD.API.IsModern() then
        local box = W.WarningBox(step, L["Midnight and Forever report damage only for enemies with nameplates, plus your target. Keep enemy nameplates on in Screen mode."],
            WIDTH - PAD * 2)
        box:SetPoint("TOPLEFT", PAD, y)
        y = y - box:GetHeight() - 24
        step.apiNote = box
    else
        step:Y(y)
        step.apiNote = step:Paragraph(L["Classic API clients read every hit from the combat log, so screen areas work with nameplates off."], C.muted)
        y = step:Y()
    end
    step.bodyY = y
    Tail(frame, step, true, {
        { L["Apply and place areas"], function() frame:Apply(true) end },
        { L["Apply"], function() frame:Apply() end, "black" },
    })
    step.place, step.apply = step.buttons[1], step.buttons[2]
    function step:Refresh()
        PaintCards(self.cards, frame.pending.motion)
        self.incoming:SetChecked(frame.pending.incoming); self.incoming:Paint()
    end
    return step
end

-- Window ----------------------------------------------------------------------------------------

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
    header:SetPoint("TOPLEFT", 1, -1); header:SetPoint("TOPRIGHT", -1, -1); header:SetHeight(53)
    header:EnableMouse(true)
    local headerLine = W.Line(header, C.line)
    headerLine:SetHeight(1); headerLine:SetPoint("BOTTOMLEFT"); headerLine:SetPoint("BOTTOMRIGHT")
    local title = W.Text(header, L["Welcome to PlateSCT"], 24, -15, WIDTH - 240, "GameFontNormalLarge", C.bright)
    W.SetFont(title, "display", 18)
    header:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then frame:StartMoving() end
    end)
    header:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
    frame.header = header
    local close = W.CloseButton(frame, function() frame:Hide() end)
    close:SetPoint("TOPRIGHT", -12, -11); close:SetFrameLevel(header:GetFrameLevel() + 5)
    frame.stepLabel = W.Text(header, "", 0, 0, nil, nil, C.muted)
    frame.stepLabel:ClearAllPoints()
    frame.stepLabel:SetPoint("RIGHT", close, "LEFT", -12, 0)
    frame.stepLabel:SetWordWrap(false)

    frame.pending = {}
    frame.steps = {
        layout = BuildLayoutStep(frame),
        nameplates = BuildNameplateStep(frame),
        screen = BuildScreenStep(frame),
    }

    function frame:Reset()
        local db = BD.db
        local _, style = BD:GetStylePreset()
        self.pending = { layout = BD.Layout.Mode(), style = style, incoming = db.showIncoming and true or false,
            motion = CurrentMotion() }
    end
    function frame:ReleaseScenes()
        self.previewGeneration = (self.previewGeneration or 0) + 1
        for _, step in pairs(self.steps) do
            for _, scene in ipairs(step.scenes) do scene:Release() end
        end
    end
    function frame:LayoutScenes()
        for _, scene in ipairs(self.step.scenes) do scene:Layout() end
    end
    function frame:FitToScreen()
        self:SetScale(math.min(1, UIParent:GetWidth() * 0.94 / WIDTH,
            UIParent:GetHeight() * 0.94 / self:GetHeight()))
        self:LayoutScenes()
    end
    -- One loop plays the open step's scenes. Hits and crits alternate; new samples overlap the
    -- previous fade, as they do in combat.
    function frame:PlayScenes()
        self.previewGeneration = (self.previewGeneration or 0) + 1
        local generation = self.previewGeneration
        local kind = "hit"
        local function PlaySamples()
            if not self:IsShown() or generation ~= self.previewGeneration then return end
            for _, scene in ipairs(self.step.scenes) do scene:Play(kind) end
            kind = kind == "hit" and "crit" or "hit"
            C_Timer.After(SAMPLE_INTERVAL, PlaySamples)
        end
        C_Timer.After(0, PlaySamples)
    end
    function frame:ShowStep(id)
        self:ReleaseScenes()
        for key, step in pairs(self.steps) do step:SetShown(key == id) end
        local step = self.steps[id]
        self.step, self.stepId = step, id
        step:Refresh()
        for _, button in ipairs(step.buttons) do FitButton(button) end
        step:Relayout()
        step:SetHeight(step.height)
        self:SetHeight(step.height)
        self.stepLabel:SetText(string.format(L["Step %d of %d"], STEP_NUMBERS[id], 2))
        self:FitToScreen()
        self:PlayScenes()
    end
    function frame:Apply(placeAreas)
        local db, pending = BD.db, self.pending
        db.displayMode = pending.layout
        db.showIncoming = pending.incoming
        if pending.layout == "screen" then
            BD:EnsureScreenAreas()
            BD.FindScreenArea(db, "outgoing").animation = pending.motion
        else
            db.numberStyle = pending.style
        end
        BD:RefreshScreenAreas()
        self:Hide()
        if BD.configFrame then BD.configFrame:Refresh() end
        if placeAreas then BD.OptionsAreas.Unlock() end
    end

    frame:SetScript("OnShow", function(self)
        BD.db.welcomeSeen = true
        self:RegisterEvent("UI_SCALE_CHANGED"); self:RegisterEvent("DISPLAY_SIZE_CHANGED")
        self:Reset()
        self:ShowStep("layout")
    end)
    frame:SetScript("OnHide", function(self)
        self:StopMovingOrSizing(); self:UnregisterAllEvents()
        self:ReleaseScenes()
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
