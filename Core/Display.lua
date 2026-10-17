local _, BD = ...
local L = BD.L
local Anim = BD.Anim

local ICON_GAP = 4
local CRIT_LABEL_GAP = 3

local function GetFrameStyle(self, hitKind, isIncoming, isHeal)
    local override
    if self.db.numberStyle == "impact" and (isIncoming or isHeal or hitKind == "miss") then
        override = "retail"
    end
    return self:GetStylePreset(override)
end

local function GetImpactPlacement(self, spacingScale)
    local preset = self.STYLE_PRESETS.impact
    if self.db.impactPosition == "top" then
        return 0, preset.spawnTopY * spacingScale, "TOP"
    end
    return preset.spawnBaseX * spacingScale, preset.spawnBaseY * spacingScale, "TOPRIGHT"
end

local function ImpactTextOffset(self, iconSize, iconPosition)
    if self.db.impactPosition ~= "top" or not iconSize then
        return 0
    end
    local offset = (iconSize + ICON_GAP) * 0.5
    if iconPosition == "right" then
        return -offset
    elseif iconPosition ~= "top" and iconPosition ~= "bottom" then
        return offset
    end
    return 0
end

local function AnchorCritLabel(frame)
    if frame.critLabel and frame.critLabel:IsShown() then
        frame.critLabel:SetPoint("BOTTOMLEFT", frame.text, "BOTTOMRIGHT", CRIT_LABEL_GAP, 0)
    end
end

local function ScaleSpawnLanes(lanes, scale)
    if not lanes or scale == 1 then
        return lanes
    end
    local scaled = {}
    for index, lane in ipairs(lanes) do
        scaled[index] = { lane[1] * scale, lane[2] * scale }
    end
    return scaled
end

local function ClassicTextBounds(textW, textH, labelW, labelH, iconSize, iconPosition)
    local labelSpan = labelW > 0 and labelW + CRIT_LABEL_GAP or 0
    local tx, ty = -labelSpan * 0.5, 0
    if iconSize then
        if iconPosition == "right" then
            tx = -(iconSize + ICON_GAP + labelSpan) * 0.5
        elseif iconPosition == "top" then
            ty = -(iconSize + ICON_GAP) * 0.5
        elseif iconPosition == "bottom" then
            ty = (iconSize + ICON_GAP) * 0.5
        else
            tx = (iconSize + ICON_GAP - labelSpan) * 0.5
        end
    end
    local left, right = tx - textW * 0.5, tx + textW * 0.5
    local bottom, top = ty - textH * 0.5, ty + textH * 0.5
    local textLeft, textRight, textBottom, textTop = left, right, bottom, top
    if labelW > 0 then
        right = math.max(right, textRight + CRIT_LABEL_GAP + labelW)
        top = math.max(top, textBottom + labelH)
    end
    if iconSize then
        local ix, iy = tx, ty
        if iconPosition == "right" then
            ix = right + ICON_GAP + iconSize * 0.5
            if labelW > 0 then
                iy = textBottom + labelH * 0.5
            end
        elseif iconPosition == "top" then
            iy = textTop + ICON_GAP + iconSize * 0.5
        elseif iconPosition == "bottom" then
            iy = textBottom - ICON_GAP - iconSize * 0.5
        else
            ix = textLeft - ICON_GAP - iconSize * 0.5
        end
        left, right = math.min(left, ix - iconSize * 0.5), math.max(right, ix + iconSize * 0.5)
        bottom, top = math.min(bottom, iy - iconSize * 0.5), math.max(top, iy + iconSize * 0.5)
    end
    return { left, right, bottom, top }
end

local function AccessibleTextSize(text, fontSize)
    local ok, width, height = pcall(function()
        return text:GetStringWidth(), text:GetStringHeight()
    end)
    -- Never inspect secret text to estimate its length. Use a conservative
    -- font-based rectangle if the client cannot expose its rendered metrics.
    if not ok or not BD.CanAccessValue(width) or not width then
        width = fontSize * 12
    end
    if not ok or not BD.CanAccessValue(height) or not height then
        height = fontSize
    end
    return width, math.max(fontSize, height)
end

local function RecordClassicBounds(frame, fontSize, iconSize, iconPosition)
    if not frame.usesClassicShove then
        return
    end
    local width, height = AccessibleTextSize(frame.text, fontSize)
    local labelW, labelH = 0, 0
    if frame.critLabel and frame.critLabel:IsShown() then
        labelW, labelH = AccessibleTextSize(frame.critLabel, math.max(8, math.floor(fontSize * 0.55 + 0.5)))
    end
    frame.classicBounds = ClassicTextBounds(width, height, labelW, labelH, iconSize, iconPosition)
end

local function PlaceFrame(frame, anchor, baseX, baseY)
    if not frame.incoming then
        -- Placement follows the selected style, including Impact's Modern-motion fallback.
        local offsetX, offsetY = BD:GetNumberStyleOffsets()
        baseX, baseY = baseX + offsetX, baseY + offsetY
    end
    frame.startX, frame.startY = BD.Pool.PickClearSpawn(anchor, frame, baseX, baseY,
        frame.isCrit, frame.usesClassicShove)
    if frame.animMode == "impactSlam" then
        BD.Pool.RelayerImpact(frame:GetParent())
        BD.Pool.ApplyMotion(frame)
        return
    end
    if frame.usesClassicShove then
        frame.classicReady = true
    end
    frame:ClearAllPoints()
    local at = frame.lingerHost or anchor
    local scale = 1
    if frame.usesClassicShove then
        scale = frame.isCrit and (frame.critPowStartScale or 1) or (frame.popScale or 1)
    end
    frame:SetPoint("CENTER", at, frame.lingerHost and "CENTER" or (frame.anchorRelPoint or "TOP"),
        frame.startX / scale, frame.startY / scale)
end

local function ApplyTextLayout(frame, fontSize, fontPath, fontFlags, preset, layoutOpts)
    layoutOpts = layoutOpts or {}
    local showIcon = layoutOpts.showIcon
    local iconSize = layoutOpts.iconSize
    local iconTexture = layoutOpts.iconTexture
    local iconPosition = layoutOpts.iconPosition or "left"
    local showCritLabel = layoutOpts.showCritLabel
    local r = layoutOpts.r or 1
    local g = layoutOpts.g or 1
    local b = layoutOpts.b or 1

    frame.text:ClearAllPoints()
    frame.icon:ClearAllPoints()
    if frame.critLabel then
        frame.critLabel:ClearAllPoints()
        frame.critLabel:SetAlpha(1)
    end

    local critLabelW = 0
    if showCritLabel and frame.critLabel then
        local critSize = math.max(8, math.floor(fontSize * 0.55 + 0.5))
        BD.SafeSetFont(frame.critLabel, fontPath, critSize, fontFlags)
        frame.critLabel:SetText(L["CRITICAL"])
        frame.critLabel:SetTextColor(r, g, b, 1)
        if preset.shadowOffset then
            frame.critLabel:SetShadowOffset(preset.shadowOffset[1], preset.shadowOffset[2])
            frame.critLabel:SetShadowColor(0, 0, 0, 1)
        else
            frame.critLabel:SetShadowOffset(0, 0)
        end
        frame.critLabel:Show()
        if frame.animMode ~= "impactSlam" then
            critLabelW = (frame.critLabel:GetStringWidth() or 0) + CRIT_LABEL_GAP
        end
    elseif frame.critLabel then
        frame.critLabel:SetText("")
        frame.critLabel:Hide()
    end

    local resolvedIcon = showIcon and iconTexture
    local size = iconSize or math.max(12, math.floor((fontSize * 1.1) + 0.5))
    if resolvedIcon then
        frame.icon:SetSize(size, size)
        local ok = pcall(frame.icon.SetTexture, frame.icon, resolvedIcon)
        if not ok then
            resolvedIcon = nil
        end
    end

    if frame.animMode == "impactSlam" then
        -- Top placement centers the number and side icon together.
        local textX = ImpactTextOffset(BD, resolvedIcon and size, iconPosition)
        frame.text:SetPoint("CENTER", frame, "CENTER", textX, 0)
        local labelAnchor = frame.text
        if resolvedIcon then
            frame.icon:SetVertexColor(1, 1, 1, 1)
            frame.icon:Show()
            if iconPosition == "top" then
                frame.icon:SetPoint("BOTTOM", frame.text, "TOP", 0, ICON_GAP)
                labelAnchor = frame.icon
            elseif iconPosition == "bottom" then
                frame.icon:SetPoint("TOP", frame.text, "BOTTOM", 0, -ICON_GAP)
            elseif iconPosition == "right" then
                frame.icon:SetPoint("LEFT", frame.text, "RIGHT", ICON_GAP, 0)
            else
                frame.icon:SetPoint("RIGHT", frame.text, "LEFT", -ICON_GAP, 0)
            end
        else
            frame.icon:SetTexture(nil)
            frame.icon:Hide()
        end
        if showCritLabel and frame.critLabel then
            frame.critLabel:SetPoint("BOTTOM", labelAnchor, "TOP", 0, CRIT_LABEL_GAP)
        end
        return
    end

    if not resolvedIcon then
        frame.icon:SetTexture(nil)
        frame.icon:Hide()
        frame.text:SetPoint("CENTER", frame, "CENTER", -critLabelW * 0.5, 0)
        AnchorCritLabel(frame)
        RecordClassicBounds(frame, fontSize)
        return
    end

    frame.icon:SetVertexColor(1, 1, 1, 1)
    frame.icon:Show()
    local size = frame.icon:GetWidth() or iconSize

    local pos = iconPosition
    if pos == "right" then
        local shift = (size + ICON_GAP + critLabelW) * 0.5
        frame.text:SetPoint("CENTER", frame, "CENTER", -shift, 0)
        AnchorCritLabel(frame)
        if showCritLabel and frame.critLabel then
            frame.icon:SetPoint("LEFT", frame.critLabel, "RIGHT", ICON_GAP, 0)
        else
            frame.icon:SetPoint("LEFT", frame.text, "RIGHT", ICON_GAP, 0)
        end
    elseif pos == "top" then
        frame.text:SetPoint("CENTER", frame, "CENTER", -critLabelW * 0.5, -(size + ICON_GAP) * 0.5)
        AnchorCritLabel(frame)
        frame.icon:SetPoint("BOTTOM", frame.text, "TOP", 0, ICON_GAP)
    elseif pos == "bottom" then
        frame.text:SetPoint("CENTER", frame, "CENTER", -critLabelW * 0.5, (size + ICON_GAP) * 0.5)
        AnchorCritLabel(frame)
        frame.icon:SetPoint("TOP", frame.text, "BOTTOM", 0, -ICON_GAP)
    else
        local shift = (size + ICON_GAP - critLabelW) * 0.5
        frame.text:SetPoint("CENTER", frame, "CENTER", shift, 0)
        frame.icon:SetPoint("RIGHT", frame.text, "LEFT", -ICON_GAP, 0)
        AnchorCritLabel(frame)
    end
    RecordClassicBounds(frame, fontSize, size, iconPosition)
end

local function ApplyMotionSpawnParams(frame, motionStyle, floatDistance)
    frame.motionStyle = motionStyle or "platesct"
    if frame.motionStyle == "fountain" then
        frame.arcX = Anim.NextFountainArcX()
        frame.arcTop = math.random(10, 28)
        frame.arcBottom = -math.random(8, 22)
    elseif frame.motionStyle == "rainfall" then
        frame.rainDistance = (floatDistance or 20) * 1.2
        frame.rainX = math.random(-18, 18)
        frame.rainStartY = math.random(4, 12)
    end
end

local function ConfigureFrameCommon(self, frame, preset, isCrit, hitKind, isIncoming, measureOnly, numberStyle)
    frame.isCrit = isCrit and true or false
    frame.incoming = isIncoming and true or false
    frame.hitKind = hitKind or (isCrit and "crit" or "hit")
    frame.numberStyle = numberStyle or self.db.numberStyle or "retail"
    frame.usesClassicShove = frame.numberStyle == "classic" and true or nil

    local durationMult = preset.durationMult
    if frame.isCrit and preset.critDurationMult then
        durationMult = durationMult * preset.critDurationMult
    end
    frame.duration = (self.db.duration or self.DEFAULTS.duration) * durationMult
    frame.floatDistance = (self.db.floatDistance or self.DEFAULTS.floatDistance) * preset.floatMult
    frame.scrollSpeed = self.db.scrollSpeed or self.DEFAULTS.scrollSpeed or 1
    frame.baseAlpha = 1
    frame.popScale = preset.popScale
    frame.popDuration = preset.popDuration
    frame.fadePower = preset.fadePower
    frame.fadeMode = preset.fadeMode
    frame.fadeInRatio = preset.fadeInRatio or 0
    frame.driftX = preset.driftX
    frame.floatEase = preset.floatEase
    frame.animMode = preset.animMode
    frame.critsHold = preset.critsHold and true or false
    frame.critRestScale = preset.critRestScale or 1.4
    frame.critPopStartScale = preset.critPopStartScale or 0.72
    frame.critSlapScale = preset.critSlapScale or 1.50
    frame.critSlapDuration = preset.critSlapDuration or 0
    frame.critSlapDrop = preset.critSlapDrop or 0
    frame.critPowStartScale = preset.critPowStartScale or 1
    frame.critPowPeakScale = preset.critPowPeakScale or 2.0
    frame.critPowDuration = preset.critPowDuration or 0.22

    -- Scale Modern-style spawn lanes with font size so larger numbers spread out.
    local defaultFontSize = self.DEFAULTS.fontSize or 14
    if defaultFontSize < 1 then
        defaultFontSize = 14
    end
    local fontSize = self.db.fontSize or defaultFontSize
    local spacingScale = fontSize / defaultFontSize
    frame.impactSpacingScale = frame.numberStyle == "impact" and fontSize / 14 or nil
    if frame.impactSpacingScale then
        spacingScale = frame.impactSpacingScale
    end
    frame.spawnLanes = ScaleSpawnLanes(preset.spawnLanes, spacingScale)
    frame.spawnMinDist = (preset.spawnMinDist or 20) * spacingScale
    frame.spawnMinDistCrit = (preset.spawnMinDistCrit or 26) * spacingScale
    frame.spawnJitter = (preset.spawnJitter or 10) * spacingScale
    frame.spawnCritY = preset.spawnCritY

    local motionStyle = self:ResolveMotionStyle(frame.hitKind, frame.numberStyle)

    -- Classic Slap: Modern look, Classic grow-and-settle crit pow.
    if motionStyle == "classicSlap" and frame.isCrit then
        local classic = self.STYLE_PRESETS.classic
        frame.animMode = "classicPow"
        frame.critsHold = true
        frame.critRestScale = classic.critRestScale or 1.4
        frame.critPowStartScale = classic.critPowStartScale or 1.0
        frame.critPowPeakScale = classic.critPowPeakScale or 2.0
        frame.critPowDuration = classic.critPowDuration or 0.2
        frame.spawnCritY = classic.spawnCritY or 8
        frame.floatEase = classic.floatEase or "outQuad"
        frame.fadeMode = classic.fadeMode or "inExpo"
        frame.fadeInRatio = classic.fadeInRatio or 0.3
        frame.popScale = classic.popScale or 1
        frame.popDuration = classic.popDuration or 0
        -- Match Classic crit duration stretch while keeping Modern float distance base.
        local baseDuration = (self.db.duration or self.DEFAULTS.duration) * (preset.durationMult or 1)
        frame.duration = baseDuration * (classic.critDurationMult or 1.6)
    elseif BD.IsExtraMotionPath(motionStyle) then
        -- Extra Modern paths skip Classic-style crit hold.
        frame.critsHold = false
    end

    if measureOnly then
        frame.motionStyle = motionStyle
    else
        ApplyMotionSpawnParams(frame, motionStyle, frame.floatDistance)
    end
end

-- Combine hits: a new hit folds into a live number on the same plate when it
-- shares the combine key and lands inside the window since that number spawned.
-- Secret amounts cannot be summed, so they always spawn their own number.
local combineTargets = setmetatable({}, { __mode = "k" })

local function CombinableAmount(amount)
    return type(amount) == "number" and not BD.IsSecret(amount) and BD.CanAccessValue(amount)
end

local function CombineKey(self, kind, isHeal, spellIcon, spellId)
    local source = "any"
    if self.db.combineMode ~= "target" then
        if spellId and BD.CanAccessValue(spellId) and not BD.IsSecret(spellId) then
            source = tostring(spellId)
        elseif type(spellIcon) == "number" or type(spellIcon) == "string" then
            source = "icon:" .. tostring(spellIcon)
        end
    end
    return (isHeal and "heal:" or "dmg:") .. kind .. ":" .. source
end

-- With a spell icon showing, the count sits on the icon like an aura stack;
-- otherwise it follows the total in parentheses.
local function CombinedText(self, total, count, onIcon)
    local display = BD.FormatAmount(total, self.db.abbreviate)
    if count > 1 and self.db.combineShowCount and not onIcon then
        return string.format(L["%s (%d)"], display, count)
    end
    return display
end

local function UpdateIconCount(self, frame, onIcon)
    local label = frame.iconCount
    if not onIcon or frame.combineCount < 2 or not self.db.combineShowCount then
        label:SetText("")
        label:Hide()
        return
    end
    local layout = frame.combineLayout
    local size = math.max(9, math.floor((layout.opts.iconSize or 12) * 0.63 + 0.5))
    BD.SafeSetFont(label, layout.fontPath, size, "OUTLINE")
    label:SetText(frame.combineCount)
    label:Show()
end

-- All hits mode merges different spells: keep the icon on whichever spell has
-- contributed the most damage so far.
local function NoteCombineSource(frame, icon, amount)
    local sources = frame.combineSources
    if not sources or not icon or BD.IsSecret(icon) then
        return
    end
    sources[icon] = (sources[icon] or 0) + amount
    local top = frame.combineTopIcon
    if not top or sources[icon] > (sources[top] or 0) then
        frame.combineTopIcon = icon
        local opts = frame.combineLayout.opts
        opts.iconTexture = icon
        opts.showIcon = true
    end
end

-- Fold one more hit into a live number: new total, relaid text, and a pulse.
local function ApplyCombine(self, frame, amount, icon)
    frame.combineTotal = frame.combineTotal + amount
    frame.combineCount = frame.combineCount + 1
    NoteCombineSource(frame, icon, amount)
    local layout = frame.combineLayout
    local onIcon = layout.opts.showIcon and layout.opts.iconTexture ~= nil
    frame.text:SetText(CombinedText(self, frame.combineTotal, frame.combineCount, onIcon))
    ApplyTextLayout(frame, layout.fontSize, layout.fontPath, layout.fontFlags, layout.preset, layout.opts)
    UpdateIconCount(self, frame, onIcon and frame.icon:IsShown())
    if frame.usesClassicShove then
        BD.Pool.RelayoutClassic(frame.anchor)
    end
    if self.db.combinePulse then
        frame.combinePulseAt = frame.elapsed
    end
end

local function TryCombine(self, plate, key, amount, icon)
    local byKey = combineTargets[plate]
    local frame = byKey and byKey[key]
    if not frame then
        return false
    end
    local window = self.db.combineWindow or self.DEFAULTS.combineWindow
    if frame.combineKey ~= key or frame.anchor ~= plate or frame.lingerFrozen
        or not frame:IsShown() or (GetTime() - (frame.spawnTime or 0)) > window then
        byKey[key] = nil
        return false
    end
    ApplyCombine(self, frame, amount, icon)
    -- Combined crits replay the crit sound only when the total reaches a higher tier.
    if frame.combineSoundTier and frame.isCrit then
        local tier = self:GetCritSoundTier(frame.combineTotal)
        if tier > frame.combineSoundTier then
            self:PlayCritSoundTier(tier)
            frame.combineSoundTier = tier
        end
    end
    self:DebugPrint("combined", key, frame.combineCount, frame.combineTotal)
    return true
end

-- Preview bursts: each damage sample is followed by these extra hits, merged
-- into it at these fractions of the combine window.
local PREVIEW_COMBINE_HITS = {
    { at = 0.4, factor = 0.85 },
    { at = 0.8, factor = 1.1 },
}

local previewCombineSerial = 0

local function PreviewCombineActive(self, sample)
    return self.db.combineHits and sample.amount and sample.hitKind ~= "miss"
end

local function PreviewPulseScale(self, sample)
    return PreviewCombineActive(self, sample) and self.db.combinePulse and (1 + BD.COMBINE_PULSE_SCALE) or 1
end

-- Text the sample ends on, so preview bounds fit the combined number.
local function PreviewSampleText(self, sample)
    if sample.text then
        return sample.text
    end
    if not PreviewCombineActive(self, sample) then
        return BD.FormatAmount(sample.amount, self.db.abbreviate)
    end
    local total = sample.amount
    for _, extra in ipairs(PREVIEW_COMBINE_HITS) do
        total = total + math.floor(sample.amount * extra.factor + 0.5)
    end
    -- Preview samples always resolve an icon when spell icons are on.
    return CombinedText(self, total, #PREVIEW_COMBINE_HITS + 1, self.db.showSpellIcon)
end

local function PreviewSpawnY(motionStyle)
    if motionStyle == "verticalDown" or motionStyle == "rainfall" then
        return 18
    end
    if motionStyle == "fountain" or motionStyle == "platesct" or motionStyle == "classicSlap" then
        return -14
    end
    return 0
end

local previewGeneration = 0
local previewReplayGeneration = 0
local previewReplayPending = false
local PREVIEW_STAGGER = 0.45
local PREVIEW_SAMPLES = {
    { hitKind = "hit", amount = 12400, spellID = 6603, school = 1, fallbackIcon = "Interface\\Icons\\INV_Sword_04" },
    { hitKind = "crit", amount = 214200, spellID = 133, school = 4, fallbackIcon = "Interface\\Icons\\Spell_Fire_FlameBolt" },
    { hitKind = "hit", amount = 18650, spellID = 116, school = 16, fallbackIcon = "Interface\\Icons\\Spell_Frost_FrostBolt02" },
    { hitKind = "crit", amount = 1800000, spellID = 686, school = 32, fallbackIcon = "Interface\\Icons\\Spell_Shadow_ShadowBolt" },
    { hitKind = "miss", text = "MISS" },
    { hitKind = "miss", text = "DODGE" },
    { hitKind = "miss", text = "IMMUNE" },
}

local function MatchesPreviewKind(sample, sampleKind)
    if sampleKind ~= "hit" and sampleKind ~= "crit" and sampleKind ~= "miss" then
        return true
    end
    return sample.hitKind == sampleKind
end

local previewMeasureFrame
local previewMeasureText
local function MeasurePreviewText(text, fontPath, fontSize, fontFlags)
    if not previewMeasureText then
        previewMeasureFrame = CreateFrame("Frame", nil, UIParent)
        previewMeasureFrame:Hide()
        previewMeasureText = previewMeasureFrame:CreateFontString(nil, "ARTWORK")
    end
    BD.SafeSetFont(previewMeasureText, fontPath, fontSize, fontFlags)
    previewMeasureText:SetText(text)
    return previewMeasureText:GetStringWidth() or 0, math.max(fontSize, previewMeasureText:GetStringHeight() or 0)
end

local function ClassicPreviewSamples(self, sampleKind)
    local samples = {}
    local preset = self:GetStylePreset()
    local fontSize = (self.db.fontSize or self.DEFAULTS.fontSize) * preset.fontScale
    local fontPath = BD.ResolveFontPath(self.db.fontFace)
    for _, sample in ipairs(PREVIEW_SAMPLES) do
        if MatchesPreviewKind(sample, sampleKind) then
            local frame = { elapsed = 0 }
            local isCrit = sample.hitKind == "crit"
            ConfigureFrameCommon(self, frame, preset, isCrit, sample.hitKind, false, true)
            local text = PreviewSampleText(self, sample)
            local width, height = MeasurePreviewText(text, fontPath, fontSize, preset.fontFlags)
            local labelW, labelH = 0, 0
            if isCrit and self:GetCritLabelSetting("classic") then
                local critSize = math.max(8, math.floor(fontSize * 0.55 + 0.5))
                labelW, labelH = MeasurePreviewText(L["CRITICAL"], fontPath, critSize, preset.fontFlags)
            end
            local icon = sample.hitKind ~= "miss" and
                (self:ResolveOutgoingSpellIcon(nil, sample.spellID)
                    or self:ResolveOutgoingSpellIcon(sample.fallbackIcon, nil))
            local iconSize = icon and math.max(12, math.floor(fontSize * 1.1 + 0.5)) or nil
            frame.classicBounds = ClassicTextBounds(width, height, labelW, labelH, iconSize,
                self.db.iconPosition or "left")
            frame.classicReady, frame.amountScale = true, 1.3 * PreviewPulseScale(self, sample)
            frame.classicBaseY = PreviewSpawnY(frame.motionStyle)
            if not (isCrit and frame.critsHold) then
                frame.classicBaseY = frame.classicBaseY
                    + (preset.spawnBaseY or 36) - (frame.spawnCritY or 8)
            end
            local distance = frame.floatDistance
            if frame.motionStyle == "fountain" then
                frame.previewTravel = { -56, 56, -22, 35 }
            elseif frame.motionStyle == "rainfall" then
                frame.previewTravel = { -18, 18, math.min(0, 4 - distance * 1.2), 12 }
            elseif frame.motionStyle == "verticalDown" then
                frame.previewTravel = { 0, 0, -(distance > 0 and distance or 20), 0 }
            elseif not (isCrit and frame.critsHold) then
                local drift = frame.driftX or 0
                frame.previewTravel = { math.min(0, drift), math.max(0, drift),
                    math.min(0, distance), math.max(0, distance) }
            end
            samples[#samples + 1] = frame
        end
    end
    return samples
end

local function ImpactTextBounds(textW, textH, labelW, labelH, iconSize, iconPosition)
    local left, right, bottom, top = -textW * 0.5, textW * 0.5, -textH * 0.5, textH * 0.5
    local labelBottom = top + CRIT_LABEL_GAP
    if iconSize then
        if iconPosition == "top" or iconPosition == "bottom" then
            left, right = math.min(left, -iconSize * 0.5), math.max(right, iconSize * 0.5)
            if iconPosition == "top" then
                top = top + ICON_GAP + iconSize
                labelBottom = top + CRIT_LABEL_GAP
            else
                bottom = bottom - ICON_GAP - iconSize
            end
        else
            bottom, top = math.min(bottom, -iconSize * 0.5), math.max(top, iconSize * 0.5)
            if iconPosition == "right" then
                right = right + ICON_GAP + iconSize
            else
                left = left - ICON_GAP - iconSize
            end
        end
    end
    if labelW > 0 then
        left, right = math.min(left, -labelW * 0.5), math.max(right, labelW * 0.5)
        top = math.max(top, labelBottom + labelH)
    end
    return left, right, bottom, top
end

local function ImpactPreviewBounds(self, sampleKind)
    local preset = self.STYLE_PRESETS.impact
    local fontSize = (self.db.fontSize or self.DEFAULTS.fontSize) * preset.fontScale
    local fontPath = BD.ResolveFontPath(self.db.fontFace)
    local spacing = fontSize / 14
    local distance = (self.db.floatDistance or self.DEFAULTS.floatDistance) * preset.floatMult
    local dx1, dx2, dy1, dy2 = Anim.GetImpactMotionBounds(spacing, distance)
    local jitter = preset.spawnJitter * spacing
    local x, y = GetImpactPlacement(self, spacing)
    local left, right, bottom, top = 0, 0, 0, 0
    for _, sample in ipairs(PREVIEW_SAMPLES) do
        if sample.hitKind ~= "miss" and MatchesPreviewKind(sample, sampleKind) then
            local text = PreviewSampleText(self, sample)
            local width, height = MeasurePreviewText(text, fontPath, fontSize, preset.fontFlags)
            local labelW, labelH = 0, 0
            if sample.hitKind == "crit" and self:GetCritLabelSetting("impact") then
                labelW, labelH = MeasurePreviewText(L["CRITICAL"], fontPath,
                    math.max(8, math.floor(fontSize * 0.55 + 0.5)), preset.fontFlags)
            end
            local iconSize = self.db.showSpellIcon and math.max(12, math.floor(fontSize * 1.1 + 0.5)) or nil
            local l, r, b, t = ImpactTextBounds(width, height, labelW, labelH, iconSize, self.db.iconPosition)
            local textX = ImpactTextOffset(self, iconSize, self.db.iconPosition)
            l, r = l + textX, r + textX
            local scale = (sample.hitKind == "crit" and preset.critSlapScale or 1) * PreviewPulseScale(self, sample)
            left = math.min(left, x + dx1 - jitter + l * scale - 4)
            right = math.max(right, x + dx2 + jitter + r * scale + 4)
            bottom = math.min(bottom, y + dy1 - jitter + b * scale - 4)
            top = math.max(top, y + dy2 + jitter + t * scale + 4)
        end
    end
    if not sampleKind or sampleKind == "mixed" or sampleKind == "miss" then
        local l, r, b, t = self:GetOptionsPreviewBounds("miss", "retail")
        left, right, bottom, top = math.min(left, l), math.max(right, r), math.min(bottom, b), math.max(top, t)
    end
    return left, right, bottom, top
end

function BD:GetOptionsPreviewBounds(sampleKind, styleOverride)
    local preset, numberStyle = self:GetStylePreset(styleOverride)
    if numberStyle == "impact" then
        return ImpactPreviewBounds(self, sampleKind)
    end
    local classicStyle = numberStyle == "classic"
    if classicStyle then
        return BD.Pool.GetClassicPreviewBounds(ClassicPreviewSamples(self, sampleKind), PREVIEW_STAGGER / 0.75)
    end
    local baseFontSize = self.db.fontSize or self.DEFAULTS.fontSize
    local fontSize = baseFontSize * preset.fontScale
    local fontPath = BD.ResolveFontPath(self.db.fontFace)
    local spacingScale = baseFontSize / math.max(1, self.DEFAULTS.fontSize or 14)
    local left, right, bottom, top = 0, 0, 0, 0
    for _, sample in ipairs(PREVIEW_SAMPLES) do
        if MatchesPreviewKind(sample, sampleKind) then
            local isCrit = sample.hitKind == "crit"
            local motionStyle = self:ResolveMotionStyle(sample.hitKind, numberStyle)
            local critPreset = motionStyle == "classicSlap" and self.STYLE_PRESETS.classic or preset
            local classicPow = isCrit and (preset.animMode == "classicPow" or motionStyle == "classicSlap")
            local holdsCrit = isCrit and (preset.critsHold or motionStyle == "classicSlap")
                and not BD.IsExtraMotionPath(motionStyle)
            local peakScale = math.max(1, preset.popScale or 1)
            if isCrit then
                if classicPow then
                    peakScale = math.max(critPreset.critPowStartScale or 1,
                        critPreset.critPowPeakScale or 2, critPreset.critRestScale or 1.4)
                else
                    peakScale = math.max(preset.critPopStartScale or 0.72,
                        preset.critSlapScale or 1.5, preset.critRestScale or 1.4)
                end
            end

            local text = PreviewSampleText(self, sample)
            local width, height = MeasurePreviewText(text, fontPath, fontSize, preset.fontFlags)
            local critLabelWidth = 0
            local iconYOffset = 0
            if isCrit and self:GetCritLabelSetting(numberStyle) then
                local critSize = math.max(8, math.floor(fontSize * 0.55 + 0.5))
                local labelWidth, labelHeight = MeasurePreviewText(L["CRITICAL"], fontPath, critSize, preset.fontFlags)
                critLabelWidth = labelWidth + CRIT_LABEL_GAP
                width = width + critLabelWidth
                iconYOffset = math.abs(height - labelHeight) * 0.5
                height = math.max(height, labelHeight)
            end
            if sample.hitKind ~= "miss" and self.db.showSpellIcon then
                local iconSize = math.max(12, math.floor(fontSize * 1.1 + 0.5))
                if self.db.iconPosition == "top" or self.db.iconPosition == "bottom" then
                    width = math.max(width, iconSize + critLabelWidth)
                    height = height + iconSize + ICON_GAP
                else
                    width = width + iconSize + ICON_GAP
                    height = math.max(height, iconSize)
                    if self.db.iconPosition == "right" and critLabelWidth > 0 then
                        -- The right icon follows the label's lower baseline.
                        height = height + iconYOffset * 2
                    end
                end
            end
            peakScale = peakScale * PreviewPulseScale(self, sample)
            local halfWidth = width * peakScale * 0.5 + 4
            local halfHeight = height * peakScale * 0.5 + 4
            local spawnY = PreviewSpawnY(motionStyle)
            local minX, maxX, minY, maxY = 0, 0, spawnY, spawnY
            local jitter = (preset.spawnJitter or 10) * spacingScale
            minX, maxX = -jitter, jitter
            maxY = spawnY + jitter
            for _, lane in ipairs(preset.spawnLanes or {}) do
                minX = math.min(minX, lane[1] * spacingScale)
                maxX = math.max(maxX, lane[1] * spacingScale)
                minY = math.min(minY, spawnY + lane[2] * spacingScale)
                maxY = math.max(maxY, spawnY + lane[2] * spacingScale)
            end
            local distance = (self.db.floatDistance or self.DEFAULTS.floatDistance) * preset.floatMult
            if motionStyle == "fountain" then
                -- Fountain's quadratic apex is below 35px for all supported random arcs.
                minX, maxX = minX - 56, maxX + 56
                minY, maxY = minY - 22, maxY + 35
            elseif motionStyle == "rainfall" then
                minX, maxX = minX - 18, maxX + 18
                minY, maxY = minY + math.min(0, 4 - distance * 1.2), maxY + 12
            elseif motionStyle == "verticalDown" then
                minY = minY - (distance > 0 and distance or 20)
            elseif not holdsCrit then
                local drift = preset.driftX or 0
                minX, maxX = minX + math.min(0, drift), maxX + math.max(0, drift)
                minY, maxY = minY + math.min(0, distance), maxY + math.max(0, distance)
            end
            if isCrit and not classicPow then
                local drop = preset.critSlapDrop or 0
                minY, maxY = minY + math.min(0, drop), maxY + math.max(0, drop)
            end
            left, right = math.min(left, minX - halfWidth), math.max(right, maxX + halfWidth)
            bottom, top = math.min(bottom, minY - halfHeight), math.max(top, maxY + halfHeight)
        end
    end
    return left, right, bottom, top
end

local function SpawnMotionPreviewFrame(anchor, sample)
    sample = sample or PREVIEW_SAMPLES[1]
    local kind = sample.hitKind or "hit"
    local isCrit = kind == "crit"
    local isMiss = kind == "miss"

    local preset, numberStyle = GetFrameStyle(BD, kind, false, false)
    local frame = BD.Pool.Acquire()
    ConfigureFrameCommon(BD, frame, preset, isCrit, kind, false, nil, numberStyle)

    frame.isPreview = true
    frame.anchor = anchor
    -- The preview origin represents the selected live plate anchor.
    frame.anchorRelPoint = "CENTER"
    frame:SetParent(anchor)
    frame:SetFrameLevel(anchor:GetFrameLevel() + 1)
    frame:ClearAllPoints()

    -- PreviewSpawnY is the near-plate slot. Classic combat puts crits there
    -- and hits higher (spawnBaseY 36 vs spawnCritY 8); keep that split.
    local spawnY = PreviewSpawnY(frame.motionStyle)
    local spawnX = 0
    if frame.animMode == "impactSlam" then
        spawnX, spawnY = GetImpactPlacement(BD, frame.impactSpacingScale)
    end
    if frame.usesClassicShove then
        if not (frame.isCrit and frame.critsHold) then
            local hitY = preset.spawnBaseY or 36
            local critY = frame.spawnCritY or preset.spawnCritY or 8
            spawnY = spawnY + (hitY - critY)
        end
    end

    local fontSize = (BD.db.fontSize or BD.DEFAULTS.fontSize) * preset.fontScale
    local fontPath = BD.ResolveFontPath(BD.db.fontFace)
    fontPath = BD.SafeSetFont(frame.text, fontPath, fontSize, preset.fontFlags)
    if preset.shadowOffset then
        frame.text:SetShadowOffset(preset.shadowOffset[1], preset.shadowOffset[2])
        frame.text:SetShadowColor(0, 0, 0, 1)
    else
        frame.text:SetShadowOffset(0, 0)
    end

    local r, g, b
    local resolvedIcon
    if isMiss then
        frame.text:SetText(sample.text or "MISS")
        r, g, b = 1, 0.85, 0.2
    else
        frame.text:SetText(BD.FormatAmount(sample.amount, BD.db.abbreviate))
        if BD:ShouldUseSchoolColors() then
            r, g, b = BD.GetSchoolColor(sample.school)
        else
            r, g, b = preset.defaultColor[1], preset.defaultColor[2], preset.defaultColor[3]
        end
        resolvedIcon = BD:ResolveOutgoingSpellIcon(nil, sample.spellID)
        if not resolvedIcon then
            resolvedIcon = BD:ResolveOutgoingSpellIcon(sample.fallbackIcon, nil)
        end
    end

    local iconSize = math.max(12, math.floor((fontSize * 1.1) + 0.5))
    local showCritLabel = isCrit and BD:GetCritLabelSetting(numberStyle) and true or false
    local layoutOpts = {
        showIcon = resolvedIcon ~= nil,
        iconSize = iconSize,
        iconTexture = resolvedIcon,
        iconPosition = BD.db.iconPosition or "left",
        showCritLabel = showCritLabel,
        r = r,
        g = g,
        b = b,
    }
    ApplyTextLayout(frame, fontSize, fontPath, preset.fontFlags, preset, layoutOpts)

    frame.text:SetTextColor(r, g, b, 1)
    frame.baseAlpha = 1
    if frame.usesClassicShove then
        frame.amountScale = BD.ComputeClassicAmountScale(sample.amount, true)
    end

    if PreviewCombineActive(BD, sample) then
        previewCombineSerial = previewCombineSerial + 1
        local token = "preview:" .. previewCombineSerial
        frame.combineKey = token
        frame.combineTotal = sample.amount
        frame.combineCount = 1
        frame.combineLayout = {
            fontSize = fontSize,
            fontPath = fontPath,
            fontFlags = preset.fontFlags,
            preset = preset,
            opts = layoutOpts,
        }
        local window = BD.db.combineWindow or BD.DEFAULTS.combineWindow
        for _, extra in ipairs(PREVIEW_COMBINE_HITS) do
            local amount = math.floor(sample.amount * extra.factor + 0.5)
            C_Timer.After(window * extra.at, function()
                -- The pooled frame may have been released and reused since.
                if frame.combineKey == token and frame:IsShown() then
                    ApplyCombine(BD, frame, amount)
                end
            end)
        end
    end

    PlaceFrame(frame, anchor, spawnX, spawnY)
    frame:SetAlpha(1)
    if frame.isCrit then
        if frame.animMode == "classicPow" then
            frame:SetScale(frame.critPowStartScale or 1)
        else
            frame:SetScale(frame.critPopStartScale or 0.72)
        end
    else
        frame:SetScale(frame.popScale or 1)
    end
    frame:Show()
    if frame.usesClassicShove then
        BD.Pool.RelayoutClassic(anchor)
    end
end

function BD:ShowMotionPreview(columns)
    if type(columns) ~= "table" then
        return
    end

    previewGeneration = previewGeneration + 1
    local generation = previewGeneration
    local stagger = self:IsClassicNumberStyle() and PREVIEW_STAGGER / 0.75 or PREVIEW_STAGGER

    local function PlayColumn(column)
        local anchor = column.stage or column.anchor
        if not anchor or not anchor:IsShown() then
            return
        end
        if self:IsClassicNumberStyle() then
            local samples = {}
            for _, sample in ipairs(PREVIEW_SAMPLES) do
                if MatchesPreviewKind(sample, column.kind) then
                    samples[#samples + 1] = sample
                end
            end
            if #samples == 0 then
                return
            end
            local index = 1
            local function PlaySample()
                if generation ~= previewGeneration or not anchor:IsShown() then
                    return
                end
                SpawnMotionPreviewFrame(anchor, samples[index])
                index = index % #samples + 1
                -- Schedule from the actual spawn: delayed timers cannot bunch
                -- samples together or exceed the bounds' simultaneous count.
                C_Timer.After(stagger, PlaySample)
            end
            C_Timer.After(0, PlaySample)
            return
        end
        local index = 0
        for _, sample in ipairs(PREVIEW_SAMPLES) do
            if MatchesPreviewKind(sample, column.kind) then
                local previewSample, previewAnchor = sample, anchor
                local delay = index * stagger
                index = index + 1
                C_Timer.After(delay, function()
                    if generation ~= previewGeneration then
                        return
                    end
                    if not previewAnchor:IsShown() then
                        return
                    end
                    SpawnMotionPreviewFrame(previewAnchor, previewSample)
                end)
            end
        end
        if index == 0 then
            return
        end
        C_Timer.After(index * stagger, function()
            if generation ~= previewGeneration then
                return
            end
            PlayColumn(column)
        end)
    end

    for _, column in ipairs(columns) do
        local anchor = column.stage or column.anchor
        if anchor then
            BD.Pool.ReleasePreviewFrames(anchor)
        end
        PlayColumn(column)
    end
end

function BD:RequestOptionsPreview()
    local configFrame = self.configFrame
    local pane = configFrame and configFrame.previewPane
    if not pane then
        return
    end
    if not configFrame:IsShown() then
        self:ReleaseMotionPreviews()
        return
    end
    if pane.UpdateLayout then
        pane:UpdateLayout()
    elseif self.db and self.db.showOptionsPreview then
        pane:Show()
    else
        pane:Hide()
    end
    if not (self.db and self.db.showOptionsPreview) then
        self:ReleaseMotionPreviews()
        return
    end
    if not pane:IsShown() or not (pane.stage or pane):IsShown() then
        self:ReleaseMotionPreviews()
        return
    end
    if previewReplayPending then
        return
    end
    previewReplayPending = true
    local generation = previewReplayGeneration
    C_Timer.After(0.08, function()
        if generation ~= previewReplayGeneration then
            return
        end
        previewReplayPending = false
        if BD.configFrame ~= configFrame or configFrame.previewPane ~= pane or not configFrame:IsShown() then
            return
        end
        if not (BD.db and BD.db.showOptionsPreview) or not pane:IsShown() then
            return
        end
        local stage = pane.stage or pane
        if not stage:IsShown() then
            return
        end
        if pane.FitStage then
            pane:FitStage()
        end
        BD:ShowMotionPreview(pane.columns)
    end)
end

function BD:ReleaseMotionPreviews()
    previewGeneration = previewGeneration + 1
    previewReplayGeneration = previewReplayGeneration + 1
    previewReplayPending = false
    BD.Pool.ReleasePreviewFrames()
end

-- Off-target: a plate other than your current target's. With no target, nothing is off-target.
-- Compares nameplate frames, which works on both APIs (UnitIsUnit is unreliable on Modern).
local function IsOffTargetPlate(self, plate)
    if (self.db.offTargetMode or "show") == "show" then
        return false
    end
    local targetPlate = BD.GetNamePlateFrame("target")
    return targetPlate ~= nil and targetPlate ~= plate
end

-- Small hit: a readable normal damage hit below a share of the recent average.
-- Must be checked before this hit joins the average.
local function IsSmallHit(self, amount, kind, isHeal)
    if not self.db.shrinkSmallHits or isHeal or kind ~= "hit" or not CombinableAmount(amount) then
        return false
    end
    local average = BD.GetRecentDamageAverage()
    local share = self.db.smallHitPercent or self.DEFAULTS.smallHitPercent
    return average > 0 and amount < average * share
end

function BD:ShowOnNameplate(unit, text, r, g, b, amountForThreshold, isCrit, isHeal, spellIcon, hitKind, spellId)
    local plate = BD.GetNamePlateFrame(unit)
    if not plate then
        self:DebugPrint("No nameplate for", unit)
        return
    end

    local kind = hitKind
    if not kind then
        kind = isCrit and "crit" or "hit"
    end

    if self:IsSpellIgnored(spellId) then
        return
    end

    -- Crits only keeps crits and miss text (Immune, Dodge, ...); normal hits and heals are dropped.
    if self.db.critsOnly and kind == "hit" then
        return
    end

    local offTarget = IsOffTargetPlate(self, plate)
    if offTarget and self.db.offTargetMode == "hide" then
        return
    end

    local combineKey
    if self.db.combineHits and kind ~= "miss" and CombinableAmount(amountForThreshold) then
        combineKey = CombineKey(self, kind, isHeal, spellIcon, spellId)
        local icon = self.db.combineMode == "target" and self:ResolveOutgoingSpellIcon(spellIcon, spellId) or nil
        if TryCombine(self, plate, combineKey, amountForThreshold, icon) then
            return
        end
    end

    local preset, numberStyle = GetFrameStyle(self, kind, false, isHeal)
    local frame = BD.Pool.Acquire()
    ConfigureFrameCommon(self, frame, preset, isCrit, kind, false, nil, numberStyle)

    frame.anchor = plate
    frame.anchorRelPoint = "TOP"
    local baseX, baseY = 0, preset.spawnBaseY or 8
    if frame.animMode == "impactSlam" then
        baseX, baseY, frame.anchorRelPoint = GetImpactPlacement(self, frame.impactSpacingScale)
    end
    -- Parent UIParent. Host follows the plate while live. Death/reuse freezes
    -- at last world pin (do not read the plate). anchorGuid only when plaintext;
    -- Modern secrets: orphan on hide / NAME_PLATE_UNIT_REMOVED (see API.lua).
    do
        local guid = UnitGUID(unit)
        if guid and BD.CanAccessValue(guid) and not BD.IsSecret(guid) then
            frame.anchorGuid = guid
        else
            frame.anchorGuid = nil
        end
    end
    frame:SetParent(UIParent)
    frame:SetIgnoreParentScale(true)
    pcall(function()
        frame:SetIgnoreParentAlpha(true)
    end)
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(100)
    frame.unitToken = unit
    BD.Pool.AttachLingerHost(frame, plate)

    if frame.isCrit and frame.critsHold then
        baseY = frame.spawnCritY or preset.spawnCritY or 8
    end

    local fontSize = (self.db.fontSize or self.DEFAULTS.fontSize) * preset.fontScale
    if offTarget then
        fontSize = fontSize * (self.db.offTargetScale or self.DEFAULTS.offTargetScale)
    end
    if IsSmallHit(self, amountForThreshold, kind, isHeal) then
        fontSize = fontSize * BD.SMALL_HIT_SCALE
    end
    local fontPath = BD.ResolveFontPath(self.db.fontFace)
    fontPath = BD.SafeSetFont(frame.text, fontPath, fontSize, preset.fontFlags)
    if preset.shadowOffset then
        frame.text:SetShadowOffset(preset.shadowOffset[1], preset.shadowOffset[2])
        frame.text:SetShadowColor(0, 0, 0, 1)
    else
        frame.text:SetShadowOffset(0, 0)
    end
    frame.text:SetText(text)

    local resolvedIcon = self:ResolveOutgoingSpellIcon(spellIcon, spellId)
    local iconSize = math.max(12, math.floor((fontSize * 1.1) + 0.5))
    local showCritLabel = frame.isCrit and self:GetCritLabelSetting(numberStyle) and true or false

    if isHeal then
        if self:ShouldUseSchoolColors() then
            if not r then
                r, g, b = BD.GetSchoolColor(nil)
            end
        else
            local heal = BD.HEAL_COLOR
            r, g, b = heal[1], heal[2], heal[3]
        end
    elseif self:ShouldUseSchoolColors() then
        if not r then
            r, g, b = BD.GetSchoolColor(nil)
        end
    else
        r, g, b = preset.defaultColor[1], preset.defaultColor[2], preset.defaultColor[3]
    end

    local layoutOpts = {
        showIcon = resolvedIcon ~= nil,
        iconSize = iconSize,
        iconTexture = resolvedIcon,
        iconPosition = self.db.iconPosition or "left",
        showCritLabel = showCritLabel,
        r = r,
        g = g,
        b = b,
    }
    ApplyTextLayout(frame, fontSize, fontPath, preset.fontFlags, preset, layoutOpts)

    frame.text:SetTextColor(r, g, b, 1)

    local thresholdCurve = self:GetThresholdCurve()
    if amountForThreshold and self.db.minDamage and self.db.minDamage > 0 and BD.IsSecret(amountForThreshold) and thresholdCurve then
        local ok = pcall(function()
            local color = thresholdCurve:Evaluate(amountForThreshold)
            frame.baseAlpha = select(4, color:GetRGBA())
        end)
        if not ok then
            frame.baseAlpha = 1
        end
    end
    if offTarget then
        frame.baseAlpha = frame.baseAlpha * (self.db.offTargetAlpha or self.DEFAULTS.offTargetAlpha)
    end

    if frame.baseAlpha <= 0 then
        BD.Pool.Release(frame)
        return
    end

    if frame.usesClassicShove then
        frame.amountScale = BD.ComputeClassicAmountScale(amountForThreshold)
    elseif self.db.shrinkSmallHits and not isHeal then
        -- Classic style feeds the average itself; other styles feed it for small-hit shrinking.
        BD.PushDamageSample(amountForThreshold)
    end

    if combineKey then
        frame.combineKey = combineKey
        frame.combineTotal = amountForThreshold
        frame.combineCount = 1
        frame.combineLayout = {
            fontSize = fontSize,
            fontPath = fontPath,
            fontFlags = preset.fontFlags,
            preset = preset,
            opts = layoutOpts,
        }
        if self.db.combineMode == "target" then
            frame.combineSources = {}
            if resolvedIcon and not BD.IsSecret(resolvedIcon) then
                frame.combineSources[resolvedIcon] = amountForThreshold
                frame.combineTopIcon = resolvedIcon
            end
        end
        local byKey = combineTargets[plate]
        if not byKey then
            byKey = {}
            combineTargets[plate] = byKey
        end
        byKey[combineKey] = frame
    end

    PlaceFrame(frame, plate, baseX, baseY)
    frame:SetAlpha(frame.baseAlpha)
    if frame.isCrit then
        if frame.animMode == "classicPow" then
            frame:SetScale(frame.critPowStartScale or 1)
        else
            frame:SetScale(frame.critPopStartScale or 0.72)
        end
    else
        frame:SetScale(frame.popScale or 1)
    end
    frame:Show()
    -- All visible geometry is ready before the shared Classic layout runs.
    if frame.usesClassicShove then
        BD.Pool.RelayoutClassic(plate)
    end
    -- Layout exists now. Snapshot before death can hide the plate this frame.
    BD.Pool.SnapshotLingerHost(frame, true)

    if not isHeal and kind ~= "miss" then
        local tier = self:PlayOutgoingCritSound(amountForThreshold, frame.isCrit)
        if combineKey then
            frame.combineSoundTier = tier
        end
    end
end

function BD:ShowIncoming(text, r, g, b, amountForThreshold, isCrit, hitKind)
    local anchor, relPoint, unitToken = BD.GetIncomingAnchor()
    if not anchor then
        return
    end

    local kind = hitKind
    if not kind then
        kind = isCrit and "crit" or "hit"
    end

    local preset, numberStyle = GetFrameStyle(self, kind, true, false)
    local frame = BD.Pool.Acquire()
    ConfigureFrameCommon(self, frame, preset, isCrit, kind, true, nil, numberStyle)

    frame.anchor = anchor
    frame.anchorRelPoint = relPoint or "CENTER"
    frame:SetParent(UIParent)
    frame:SetIgnoreParentScale(true)
    pcall(function()
        frame:SetIgnoreParentAlpha(true)
    end)
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(120)
    frame.unitToken = unitToken

    local ox = self.db.incomingOffsetX or self.DEFAULTS.incomingOffsetX or 0
    local oy = self.db.incomingOffsetY or self.DEFAULTS.incomingOffsetY or -100
    -- On personal nameplate, keep spawn tight; offsets alone place the cluster.
    -- On UIParent, offsets are the whole placement (default center + Y -100).
    local baseY = 0
    if frame.isCrit and frame.critsHold then
        baseY = (frame.spawnCritY or -8) * 0.15
    end
    local spawnY = oy + baseY

    local fontSize = (self.db.fontSize or self.DEFAULTS.fontSize) * preset.fontScale
    local fontPath = BD.ResolveFontPath(self.db.fontFace)
    fontPath = BD.SafeSetFont(frame.text, fontPath, fontSize, preset.fontFlags)
    if preset.shadowOffset then
        frame.text:SetShadowOffset(preset.shadowOffset[1], preset.shadowOffset[2])
        frame.text:SetShadowColor(0, 0, 0, 1)
    else
        frame.text:SetShadowOffset(0, 0)
    end
    frame.text:SetText(text)

    local color = BD.INCOMING_COLOR
    local textR = r or color[1]
    local textG = g or color[2]
    local textB = b or color[3]
    local showCritLabel = frame.isCrit and self:GetCritLabelSetting(numberStyle) and true or false

    ApplyTextLayout(frame, fontSize, fontPath, preset.fontFlags, preset, {
        showCritLabel = showCritLabel,
        r = textR,
        g = textG,
        b = textB,
    })

    frame.text:SetTextColor(textR, textG, textB, 1)

    local thresholdCurve = self:GetThresholdCurve()
    if amountForThreshold and self.db.minDamage and self.db.minDamage > 0 and BD.IsSecret(amountForThreshold) and thresholdCurve then
        local ok = pcall(function()
            local colorCurve = thresholdCurve:Evaluate(amountForThreshold)
            frame.baseAlpha = select(4, colorCurve:GetRGBA())
        end)
        if not ok then
            frame.baseAlpha = 1
        end
    end

    if frame.baseAlpha <= 0 then
        BD.Pool.Release(frame)
        return
    end

    if frame.usesClassicShove then
        frame.amountScale = BD.ComputeClassicAmountScale(amountForThreshold)
    end

    PlaceFrame(frame, anchor, ox, spawnY)
    frame:SetAlpha(frame.baseAlpha)
    if frame.isCrit then
        if frame.animMode == "classicPow" then
            frame:SetScale(frame.critPowStartScale or 1)
        else
            frame:SetScale(frame.critPopStartScale or 0.72)
        end
    else
        frame:SetScale(frame.popScale or 1)
    end
    frame:Show()
    if frame.usesClassicShove then
        BD.Pool.RelayoutClassic(anchor)
    end
end

function BD:ShowTestNumbers()
    if not UnitExists("target") then
        print("|cff66ccffPlateSCT:|r", L["Target something to preview test numbers."])
        return
    end

    local samples = {
        { amount = 12400, crit = false, spellID = 6603, hitKind = "hit" },
        { amount = 18650, crit = false, spellID = 133, hitKind = "hit" },
        { amount = 214200, crit = true, spellID = 116, hitKind = "crit" },
        { amount = 842, crit = false, spellID = 585, hitKind = "hit" },
        { amount = 1800000, crit = true, spellID = 686, hitKind = "crit" },
        { miss = true, text = "MISS", hitKind = "miss" },
        { miss = true, text = "DODGE", hitKind = "miss" },
        { miss = true, text = "IMMUNE", hitKind = "miss" },
    }
    for index, sample in ipairs(samples) do
        C_Timer.After((index - 1) * 0.12, function()
            if sample.miss then
                self:ShowOnNameplate("target", sample.text, 1, 0.85, 0.2, nil, false, false, nil, "miss")
                return
            end
            local display = BD.FormatAmount(sample.amount, self.db.abbreviate)
            local r, g, b = 1, 0.92, 0.35
            local spellIcon = self.db.showSpellIcon and BD.GetSpellIconTexture(sample.spellID) or nil
            self:ShowOnNameplate("target", display, r, g, b, sample.amount, sample.crit, false, spellIcon, sample.hitKind, sample.spellID)
        end)
    end

    if self.db.showIncoming then
        C_Timer.After(#samples * 0.12, function()
            local display = BD.FormatAmount(8420, self.db.abbreviate)
            local color = BD.INCOMING_COLOR
            self:ShowIncoming(display, color[1], color[2], color[3], 8420, false, "hit")
        end)
    end
end
