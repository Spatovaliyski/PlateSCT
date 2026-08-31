local _, BD = ...

local Anim = BD.Anim
local pool = {}
local active = {}

local DEFAULT_SPAWN_LANES = {
    { 0, 0 },
    { 16, 0 },
    { -16, 0 },
    { 0, 16 },
    { 16, 14 },
    { -16, 14 },
    { 0, 28 },
}

local CRIT_LABEL_GAP = 3
local CLASSIC_LAYOUT_PAD = 9
local ROLLING_AVERAGE_WINDOW = 10
local ROLLING_AVERAGE_MAX_AGE = 8.0

local damageSamples = {}
local rollingDamageAverage = 0
local lastClassicRelayoutTime = -1

local function IsClassicShoveFrame(frame)
    return frame.usesClassicShove and frame.animMode == "classicPow"
end

local function PushDamageSample(amount)
    if not amount or not BD.CanAccessValue(amount) or amount <= 0 then
        return
    end
    local now = GetTime()
    damageSamples[#damageSamples + 1] = { amount = amount, time = now }
    for index = #damageSamples, 1, -1 do
        if (now - damageSamples[index].time) > ROLLING_AVERAGE_MAX_AGE then
            table.remove(damageSamples, index)
        end
    end
    local total, count = 0, 0
    local startIndex = math.max(1, #damageSamples - ROLLING_AVERAGE_WINDOW + 1)
    for index = startIndex, #damageSamples do
        total = total + damageSamples[index].amount
        count = count + 1
    end
    if count > 0 then
        rollingDamageAverage = total / count
    end
end

function BD.ComputeClassicAmountScale(amount)
    if not amount or not BD.CanAccessValue(amount) or amount <= 0 then
        return 1
    end
    PushDamageSample(amount)
    local average = rollingDamageAverage
    if not average or average <= 0 then
        return 1
    end
    local ok, ratio = pcall(function()
        return amount / average
    end)
    if not ok or not ratio or ratio <= 0 then
        return 1
    end
    local logBonus = math.log(ratio) / math.log(10)
    local extra = 1 + (0.15 * logBonus)
    if extra < 0.85 then
        return 0.85
    end
    if extra > 1.3 then
        return 1.3
    end
    return extra
end

local function ComputeIntroScale(frame)
    local introDuration = 0
    local motionStyle = frame.motionStyle or "platesct"
    local useExtraPath = BD.IsExtraMotionPath(motionStyle)

    if frame.isCrit then
        if frame.animMode == "classicPow" then
            introDuration = frame.critPowDuration or 0.22
            return Anim.ComputeClassicPowScale(
                frame.elapsed,
                introDuration,
                frame.critPowStartScale or 1,
                frame.critPowPeakScale or 2,
                frame.critRestScale or 1.4
            ), introDuration
        end
        introDuration = frame.critSlapDuration or 0
        return Anim.ComputeRetailPopScale(
            frame.elapsed,
            introDuration,
            frame.critPopStartScale or 0.72,
            frame.critSlapScale or 1.50,
            frame.critRestScale or 1.26
        ), introDuration
    end

    return Anim.ComputeNormalScale(frame.elapsed, frame.popDuration, frame.popScale), introDuration
end

local function GetVisualHalfExtents(frame)
    local introScale = ComputeIntroScale(frame)
    local amountScale = frame.amountScale or 1
    local scale = introScale * amountScale
    local textW = frame.text:GetStringWidth() or 0
    local textH = frame.text:GetStringHeight() or 0
    local width = textW
    local height = textH
    if frame.critLabel and frame.critLabel:IsShown() then
        width = width + (frame.critLabel:GetStringWidth() or 0) + CRIT_LABEL_GAP
        height = math.max(height, frame.critLabel:GetStringHeight() or 0)
    end
    if frame.icon:IsShown() then
        local iconW = frame.icon:GetWidth() or 0
        width = width + iconW + 4
        height = math.max(height, frame.icon:GetHeight() or 0)
    end
    return (width * scale) * 0.5, (height * scale) * 0.5, scale
end

local function CollectClassicCluster(anchor, wantCritCluster)
    local frames = {}
    for frame in pairs(active) do
        if frame.anchor == anchor and IsClassicShoveFrame(frame) then
            local isCritCluster = frame.isCrit and frame.critsHold
            if isCritCluster == wantCritCluster then
                frames[#frames + 1] = frame
            end
        end
    end
    table.sort(frames, function(a, b)
        if a.elapsed == b.elapsed then
            return tostring(a) < tostring(b)
        end
        return a.elapsed < b.elapsed
    end)
    return frames
end

local function RelayoutClassicCluster(frames, isCritCluster)
    local center = frames[1]
    if not center then
        return
    end

    local centerHalfW, centerHalfH = GetVisualHalfExtents(center)
    local baseX = center.classicBaseX or 0

    for index, frame in ipairs(frames) do
        frame.classicHidden = false
        if index == 1 then
            frame.startX = baseX
            if isCritCluster then
                frame.startY = frame.classicBaseY or center.startY
            end
        elseif isCritCluster then
            local selfHalfW, selfHalfH = GetVisualHalfExtents(frame)
            if index == 2 then
                frame.startX = baseX + centerHalfW + selfHalfW + CLASSIC_LAYOUT_PAD
                frame.startY = center.startY
            elseif index == 3 then
                frame.startX = baseX - centerHalfW - selfHalfW - CLASSIC_LAYOUT_PAD
                frame.startY = center.startY
            elseif index == 4 then
                frame.startX = baseX
                frame.startY = center.startY + centerHalfH + selfHalfH + CLASSIC_LAYOUT_PAD
            elseif index == 5 then
                frame.startX = baseX
                frame.startY = center.startY - centerHalfH - selfHalfH - CLASSIC_LAYOUT_PAD
            else
                frame.classicHidden = true
            end
        else
            local selfHalfW = select(1, GetVisualHalfExtents(frame))
            local ring = math.ceil((index - 1) / 2)
            local side = (index % 2 == 0) and 1 or -1
            frame.startX = baseX + (side * ring * (centerHalfW + selfHalfW + CLASSIC_LAYOUT_PAD))
        end
    end
end

local function RelayoutClassicAnchor(anchor)
    RelayoutClassicCluster(CollectClassicCluster(anchor, true), true)
    RelayoutClassicCluster(CollectClassicCluster(anchor, false), false)
end

local function MaybeRelayoutClassic()
    local now = GetTime()
    if now == lastClassicRelayoutTime then
        return
    end
    lastClassicRelayoutTime = now

    local anchors = {}
    for frame in pairs(active) do
        if IsClassicShoveFrame(frame) and frame.anchor then
            anchors[frame.anchor] = true
        end
    end
    for anchor in pairs(anchors) do
        RelayoutClassicAnchor(anchor)
    end
end

local function ComputeMotion(frame)
    local progress = 0
    if frame.duration and frame.duration > 0 then
        progress = math.min(frame.elapsed / frame.duration, 1)
    end

    local scale, introDuration = ComputeIntroScale(frame)
    scale = scale * (frame.amountScale or 1)
    local extraY = 0
    local motionStyle = frame.motionStyle or "platesct"
    local useExtraPath = BD.IsExtraMotionPath(motionStyle)

    if frame.isCrit and frame.animMode ~= "classicPow" and introDuration > 0 and frame.elapsed < introDuration then
        extraY = (1 - Anim.EaseOutCubic(frame.elapsed / introDuration)) * (frame.critSlapDrop or 0)
    end

    local floatProgress = progress
    if frame.isCrit and introDuration > 0 and frame.duration and frame.duration > introDuration and frame.critsHold and not useExtraPath then
        local introRatio = introDuration / frame.duration
        floatProgress = math.max(0, (progress - introRatio) / (1 - introRatio))
    end

    local floatDistance = frame.floatDistance or 0
    if frame.isCrit and frame.critsHold and not useExtraPath then
        floatDistance = 0
    end

    if useExtraPath then
        local dx, dy = 0, 0
        if motionStyle == "fountain" then
            dx, dy = Anim.ComputeFountain(progress, frame.arcX, frame.arcTop, frame.arcBottom)
        elseif motionStyle == "rainfall" then
            dx, dy = Anim.ComputeRainfall(progress, frame.rainDistance, frame.rainX, frame.rainStartY)
        elseif motionStyle == "verticalDown" then
            dx, dy = Anim.ComputeVertical(progress, -(floatDistance > 0 and floatDistance or 20))
        end
        local x = (frame.startX or 0) + dx
        local y = (frame.startY or 0) + extraY + dy
        return x, y, scale, Anim.ComputeAlpha(frame, progress)
    end

    if frame.floatEase == "outQuad" then
        floatProgress = Anim.EaseOutQuad(floatProgress)
    elseif frame.floatEase == "outCubic" then
        floatProgress = Anim.EaseOutCubic(floatProgress)
    end

    local x = (frame.startX or 0) + (frame.driftX or 0) * floatProgress
    local y = (frame.startY or 0) + extraY + floatDistance * floatProgress
    return x, y, scale, Anim.ComputeAlpha(frame, progress)
end

local function IsUsableAnchor(region)
    if not region then
        return false
    end
    if region == UIParent then
        return true
    end
    local ok, forbidden = pcall(function()
        return region.IsForbidden and region:IsForbidden()
    end)
    if not ok or forbidden then
        return false
    end
    return true
end

local function SafeSetPoint(frame, point, relTo, relPoint, x, y)
    if not relTo or (relTo ~= UIParent and not IsUsableAnchor(relTo)) then
        relTo = UIParent
        point = "CENTER"
        relPoint = "CENTER"
    end
    return pcall(frame.SetPoint, frame, point, relTo, relPoint, x or 0, y or 0)
end

local function DetachFrameToScreen(frame)
    if frame.detached or frame.incoming or frame.isPreview then
        return frame.detached and true or false
    end

    local anchor = frame.anchor
    if not anchor then
        return false
    end

    local motionX, motionY = ComputeMotion(frame)

    pcall(frame.SetParent, frame, UIParent)
    pcall(frame.SetIgnoreParentScale, frame, true)
    pcall(function()
        frame:SetIgnoreParentAlpha(true)
    end)
    pcall(frame.SetFrameStrata, frame, "HIGH")
    pcall(frame.Show, frame)
    pcall(frame.ClearAllPoints, frame)

    local point, relTo, relPoint, xOfs, yOfs
    if IsUsableAnchor(anchor) then
        point = "CENTER"
        relTo = anchor
        relPoint = frame.anchorRelPoint or "TOP"
        xOfs, yOfs = motionX, motionY
        if not SafeSetPoint(frame, point, relTo, relPoint, xOfs, yOfs) then
            relTo = nil
        end
    end

    if not relTo then
        point = "CENTER"
        relTo = UIParent
        relPoint = "CENTER"
        xOfs, yOfs = motionX, motionY
        SafeSetPoint(frame, point, relTo, relPoint, xOfs, yOfs)
    end

    frame.detachPoint = point
    frame.detachRelTo = relTo
    frame.detachRelPoint = relPoint
    frame.detachScreenX = xOfs
    frame.detachScreenY = yOfs
    frame.detachMotionX = motionX
    frame.detachMotionY = motionY
    frame.detached = true
    frame.unitToken = nil
    frame.anchor = nil
    return true
end

local function ReleaseFrame(frame)
    frame:SetScript("OnUpdate", nil)
    frame:Hide()
    frame:SetAlpha(0)
    frame:SetScale(1)
    frame.text:SetText("")
    frame.text:SetShadowOffset(0, 0)
    frame.icon:SetTexture(nil)
    frame.icon:Hide()
    frame.icon:ClearAllPoints()
    if frame.critLabel then
        frame.critLabel:SetText("")
        frame.critLabel:Hide()
        frame.critLabel:ClearAllPoints()
    end
    frame.isPreview = nil
    frame.anchor = nil
    frame.unitToken = nil
    frame.incoming = nil
    frame.motionStyle = nil
    frame.anchorRelPoint = nil
    frame.usesClassicShove = nil
    frame.classicBaseX = nil
    frame.classicBaseY = nil
    frame.amountScale = nil
    frame.classicHidden = nil
    frame.detached = nil
    frame.detachMotionX = nil
    frame.detachMotionY = nil
    frame.detachScreenX = nil
    frame.detachScreenY = nil
    frame.detachPoint = nil
    frame.detachRelTo = nil
    frame.detachRelPoint = nil
    frame:ClearAllPoints()
    frame:SetParent(UIParent)
    frame:SetIgnoreParentScale(false)
    active[frame] = nil
    table.insert(pool, frame)
end

local function PickClearSpawn(anchor, frame, baseX, baseY, isCrit)
    local lanes = frame.spawnLanes or DEFAULT_SPAWN_LANES
    local minDist = isCrit and (frame.spawnMinDistCrit or 26) or (frame.spawnMinDist or 20)
    local minDistSq = minDist * minDist
    local jitter = frame.spawnJitter or 10

    for _, lane in ipairs(lanes) do
        local cx = baseX + lane[1]
        local cy = baseY + lane[2]
        local blocked = false
        for other in pairs(active) do
            if other ~= frame and other.anchor == anchor then
                local ox, oy = ComputeMotion(other)
                local dx = cx - ox
                local dy = cy - oy
                if (dx * dx + dy * dy) < minDistSq then
                    blocked = true
                    break
                end
            end
        end
        if not blocked then
            return cx, cy
        end
    end

    return baseX + math.random(-jitter, jitter), baseY + math.random(0, jitter)
end

local function FrameOnUpdate(frame, elapsed)
    frame.elapsed = frame.elapsed + elapsed
    if frame.elapsed / frame.duration >= 1 then
        ReleaseFrame(frame)
        return
    end

    if not frame.detached then
        if not frame.anchor then
            ReleaseFrame(frame)
            return
        end

        local ok, shown = pcall(function()
            return frame.anchor:IsShown()
        end)
        if not ok or not shown then
            if frame.isPreview then
                ReleaseFrame(frame)
                return
            end
            if not DetachFrameToScreen(frame) then
                ReleaseFrame(frame)
                return
            end
        end
    end

    MaybeRelayoutClassic()

    local x, y, scale, alpha = ComputeMotion(frame)
    if frame.classicHidden then
        alpha = 0
    end
    if frame.detached then
        local dx = x - (frame.detachMotionX or 0)
        local dy = y - (frame.detachMotionY or 0)
        local relTo = frame.detachRelTo or UIParent
        if relTo ~= UIParent and not IsUsableAnchor(relTo) then
            relTo = UIParent
            frame.detachRelTo = UIParent
            frame.detachPoint = "CENTER"
            frame.detachRelPoint = "CENTER"
        end
        frame:ClearAllPoints()
        SafeSetPoint(
            frame,
            frame.detachPoint or "CENTER",
            relTo,
            frame.detachRelPoint or "CENTER",
            (frame.detachScreenX or 0) + dx,
            (frame.detachScreenY or 0) + dy
        )
    else
        local relPoint = frame.anchorRelPoint or "TOP"
        frame:ClearAllPoints()
        if not SafeSetPoint(frame, "CENTER", frame.anchor, relPoint, x, y) then
            if not DetachFrameToScreen(frame) then
                ReleaseFrame(frame)
                return
            end
        end
    end
    frame:SetScale(scale)
    frame:SetAlpha(alpha)
end

local function CreatePooledFrame()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(150, 36)
    frame:Hide()
    frame:SetAlpha(0)

    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    text:SetPoint("CENTER")
    frame.text = text

    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetPoint("RIGHT", text, "LEFT", -4, 0)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    icon:Hide()
    frame.icon = icon

    local critLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    critLabel:Hide()
    frame.critLabel = critLabel

    frame.elapsed = 0
    frame.duration = 1
    frame.startX = 0
    frame.startY = 0
    frame.floatDistance = 40

    return frame
end

local function AcquireFrame()
    local frame = table.remove(pool)
    if not frame then
        frame = CreatePooledFrame()
    end
    active[frame] = true
    frame.elapsed = 0
    frame:SetScript("OnUpdate", FrameOnUpdate)
    return frame
end

for _ = 1, BD.POOL_SIZE do
    table.insert(pool, CreatePooledFrame())
end

local function ReleasePreviewFrames(anchor)
    for frame in pairs(active) do
        if frame.isPreview and (not anchor or frame.anchor == anchor) then
            ReleaseFrame(frame)
        end
    end
end

BD.Pool = {
    Acquire = AcquireFrame,
    Release = ReleaseFrame,
    PickClearSpawn = PickClearSpawn,
    RelayoutClassic = RelayoutClassicAnchor,
    ReleasePreviewFrames = ReleasePreviewFrames,
}

function BD:DetachFramesForUnit(unit)
    for frame in pairs(active) do
        if frame.unitToken == unit and not frame.detached then
            DetachFrameToScreen(frame)
        end
    end
end

function BD:ReleaseFramesForUnit(unit)
    for frame in pairs(active) do
        if frame.unitToken == unit then
            ReleaseFrame(frame)
        end
    end
end
