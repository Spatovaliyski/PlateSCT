local _, BD = ...
local L = BD.L

function BD:ShowOnNameplate(unit, text, r, g, b, amountForThreshold, isCrit, isHeal, spellIcon)
    local plate = BD.GetNamePlateFrame(unit)
    if not plate then
        self:DebugPrint("No nameplate for", unit)
        return
    end

    local preset = self:GetStylePreset()
    local frame = BD.Pool.Acquire()
    frame.anchor = plate
    frame.isCrit = isCrit and true or false
    local durationMult = preset.durationMult
    if frame.isCrit and preset.critDurationMult then
        durationMult = durationMult * preset.critDurationMult
    end
    frame.duration = (self.db.duration or self.DEFAULTS.duration) * durationMult
    frame.floatDistance = (self.db.floatDistance or self.DEFAULTS.floatDistance) * preset.floatMult
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
    frame.critRestScale = preset.critRestScale or 2.0
    frame.critPopStartScale = preset.critPopStartScale or 0.72
    frame.critSlapScale = preset.critSlapScale or 1.42
    frame.critSlapDuration = preset.critSlapDuration or 0
    frame.critSlapDrop = preset.critSlapDrop or 0
    frame.critPowStartScale = preset.critPowStartScale or 1
    frame.critPowPeakScale = preset.critPowPeakScale or 4
    frame.critPowDuration = preset.critPowDuration or 0.22
    frame.spawnLanes = preset.spawnLanes
    frame.spawnMinDist = preset.spawnMinDist
    frame.spawnMinDistCrit = preset.spawnMinDistCrit
    frame.spawnJitter = preset.spawnJitter

    frame:SetParent(plate)
    frame:SetIgnoreParentScale(true)
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel((plate.GetFrameLevel and plate:GetFrameLevel() or 0) + 8)
    frame.unitToken = unit

    local baseY = preset.spawnBaseY or 8
    if frame.isCrit and frame.critsHold then
        baseY = preset.spawnCritY or -8
    end
    frame.startX, frame.startY = BD.Pool.PickClearSpawn(plate, frame, 0, baseY, frame.isCrit)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", plate, "TOP", frame.startX, frame.startY)

    local fontSize = (self.db.fontSize or self.DEFAULTS.fontSize) * preset.fontScale
    local fontPath = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
    frame.text:SetFont(fontPath, fontSize, preset.fontFlags)
    if preset.shadowOffset then
        frame.text:SetShadowOffset(preset.shadowOffset[1], preset.shadowOffset[2])
        frame.text:SetShadowColor(0, 0, 0, 1)
    else
        frame.text:SetShadowOffset(0, 0)
    end
    frame.text:SetText(text)

    frame.text:ClearAllPoints()
    local showIcon = self.db.onlyMyDamage and self.db.showSpellIcon and BD.ValuePresent(spellIcon)
    if showIcon then
        local iconSize = math.max(12, math.floor((fontSize * 1.1) + 0.5))
        frame.icon:SetSize(iconSize, iconSize)
        local ok = pcall(frame.icon.SetTexture, frame.icon, spellIcon)
        if ok then
            frame.text:SetPoint("CENTER", frame, "CENTER", (iconSize + 4) / 2, 0)
            frame.icon:SetVertexColor(1, 1, 1, 1)
            frame.icon:Show()
        else
            showIcon = false
        end
    end
    if not showIcon then
        frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)
        frame.icon:SetTexture(nil)
        frame.icon:Hide()
    end

    if not isHeal then
        if self:ShouldUseSchoolColors() then
            if not r then
                r, g, b = BD.GetSchoolColor(nil)
            end
        else
            r, g, b = preset.defaultColor[1], preset.defaultColor[2], preset.defaultColor[3]
        end
    end
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

    if frame.baseAlpha <= 0 then
        BD.Pool.Release(frame)
        return
    end

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
end

function BD:ShowTestNumbers()
    if not UnitExists("target") then
        print("|cff66ccffPlateSCT:|r", L["Target something to preview test numbers."])
        return
    end

    local samples = {
        { amount = 12400, crit = false, spellID = 6603 },
        { amount = 18650, crit = false, spellID = 133 },
        { amount = 214200, crit = true, spellID = 116 },
        { amount = 842, crit = false, spellID = 585 },
        { amount = 1800000, crit = true, spellID = 686 },
    }
    for index, sample in ipairs(samples) do
        C_Timer.After((index - 1) * 0.12, function()
            local display = BD.FormatAmount(sample.amount, self.db.abbreviate)
            local r, g, b = 1, 0.92, 0.35
            local spellIcon = self.db.showSpellIcon and BD.GetSpellIconTexture(sample.spellID) or nil
            self:ShowOnNameplate("target", display, r, g, b, sample.amount, sample.crit, false, spellIcon)
        end)
    end
end
