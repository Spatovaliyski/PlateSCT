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

local function ReleaseFrame(frame)
    frame:SetScript("OnUpdate", nil)
    frame:Hide()
    frame:SetAlpha(0)
    frame:SetScale(1)
    frame.text:SetText("")
    frame.text:SetShadowOffset(0, 0)
    frame.icon:SetTexture(nil)
    frame.icon:Hide()
    frame.anchor = nil
    frame.unitToken = nil
    frame:ClearAllPoints()
    frame:SetParent(UIParent)
    frame:SetIgnoreParentScale(false)
    active[frame] = nil
    table.insert(pool, frame)
end

local function ComputeMotion(frame)
    local progress = 0
    if frame.duration and frame.duration > 0 then
        progress = math.min(frame.elapsed / frame.duration, 1)
    end

    local scale = 1
    local extraY = 0
    local introDuration = 0

    if frame.isCrit then
        if frame.animMode == "classicPow" then
            introDuration = frame.critPowDuration or 0.22
            scale = Anim.ComputeClassicPowScale(
                frame.elapsed,
                introDuration,
                frame.critPowStartScale or 1,
                frame.critPowPeakScale or 4,
                frame.critRestScale or 2
            )
        else
            introDuration = frame.critSlapDuration or 0
            scale = Anim.ComputeRetailPopScale(
                frame.elapsed,
                introDuration,
                frame.critPopStartScale or 0.72,
                frame.critSlapScale or 1.42,
                frame.critRestScale or 1.18
            )
            if introDuration > 0 and frame.elapsed < introDuration then
                extraY = (1 - Anim.EaseOutCubic(frame.elapsed / introDuration)) * (frame.critSlapDrop or 0)
            end
        end
    else
        scale = Anim.ComputeNormalScale(frame.elapsed, frame.popDuration, frame.popScale)
    end

    local floatProgress = progress
    if frame.isCrit and introDuration > 0 and frame.duration and frame.duration > introDuration and frame.critsHold then
        local introRatio = introDuration / frame.duration
        floatProgress = math.max(0, (progress - introRatio) / (1 - introRatio))
    end

    local floatDistance = frame.floatDistance or 0
    if frame.isCrit and frame.critsHold then
        floatDistance = 0
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

    if not frame.anchor then
        ReleaseFrame(frame)
        return
    end

    local x, y, scale, alpha = ComputeMotion(frame)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", frame.anchor, "TOP", x, y)
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

BD.Pool = {
    Acquire = AcquireFrame,
    Release = ReleaseFrame,
    PickClearSpawn = PickClearSpawn,
}

function BD:ReleaseFramesForUnit(unit)
    for frame in pairs(active) do
        if frame.unitToken == unit then
            ReleaseFrame(frame)
        end
    end
end
