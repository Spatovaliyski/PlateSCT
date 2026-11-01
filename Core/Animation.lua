local _, BD = ...

local Anim = {}
BD.Anim = Anim

function Anim.Clamp01(t)
    if t < 0 then
        return 0
    end
    if t > 1 then
        return 1
    end
    return t
end

function Anim.EaseOutCubic(t)
    t = Anim.Clamp01(t)
    return 1 - ((1 - t) ^ 3)
end

function Anim.EaseOutQuad(t)
    t = Anim.Clamp01(t)
    return 1 - (1 - t) * (1 - t)
end

function Anim.EaseOutQuint(t)
    t = Anim.Clamp01(t)
    local u = 1 - t
    return 1 - (u * u * u * u * u)
end

function Anim.EaseOutCirc(t)
    t = Anim.Clamp01(t) - 1
    return math.sqrt(1 - t * t)
end

function Anim.EaseInCirc(t)
    t = Anim.Clamp01(t)
    return 1 - math.sqrt(1 - t * t)
end

function Anim.EaseInExpo(t)
    t = Anim.Clamp01(t)
    if t <= 0 then
        return 0
    end
    if t >= 1 then
        return 1
    end
    return 2 ^ (10 * (t - 1))
end

function Anim.ComputeRetailPopScale(elapsed, duration, startScale, peakScale, restScale)
    if not duration or duration <= 0 or elapsed >= duration then
        return restScale or 1.26
    end
    local t = elapsed / duration
    if t < 0.38 then
        return startScale + (peakScale - startScale) * Anim.EaseOutCubic(t / 0.38)
    end
    return peakScale + (restScale - peakScale) * Anim.EaseOutCubic((t - 0.38) / 0.62)
end

function Anim.ComputeClassicPowScale(elapsed, duration, startScale, peakScale, restScale)
    if not duration or duration <= 0 or elapsed >= duration then
        return restScale
    end
    local t = elapsed / duration
    if t < 0.1 then
        return startScale + (peakScale - startScale) * Anim.EaseOutCirc(t / 0.1)
    end
    return peakScale + (restScale - peakScale) * Anim.EaseInCirc((t - 0.1) / 0.9)
end

function Anim.ComputeNormalScale(elapsed, popDuration, popScale)
    if not popDuration or popDuration <= 0 or not popScale or popScale <= 1 then
        return 1
    end
    local t = math.min(elapsed / popDuration, 1)
    local eased = Anim.EaseOutCubic(t)
    return popScale + (1 - popScale) * eased
end

Anim.IMPACT_ENTRANCE_DURATION = 0.12
local IMPACT_SLAM_DURATION = 0.08
local IMPACT_START_X, IMPACT_START_Y, IMPACT_OVERSHOOT = 20, 8, 2

function Anim.ComputeImpactEntrance(elapsed, spacingScale)
    if elapsed < IMPACT_SLAM_DURATION then
        local t = Anim.EaseOutQuint(elapsed / IMPACT_SLAM_DURATION)
        local scale = spacingScale or 1
        return (IMPACT_START_X - (IMPACT_START_X + IMPACT_OVERSHOOT) * t) * scale,
            (IMPACT_START_Y - (IMPACT_START_Y + IMPACT_OVERSHOOT) * t) * scale
    end
    local settle = Anim.IMPACT_ENTRANCE_DURATION - IMPACT_SLAM_DURATION
    local offset = -IMPACT_OVERSHOOT * (1 - Anim.EaseOutCubic((elapsed - IMPACT_SLAM_DURATION) / settle)) * (spacingScale or 1)
    return offset, offset
end

function Anim.ComputeImpactScale(elapsed, isCrit, peakScale, restScale)
    if not isCrit then
        return 1
    end
    local peak, rest = peakScale or 1.4, restScale or 1.2
    if elapsed < 0.04 then
        return 1 + (peak - 1) * Anim.EaseOutCubic(elapsed / 0.04)
    end
    return peak + (rest - peak) * Anim.EaseOutCubic((elapsed - 0.04) / 0.08)
end

function Anim.ComputeImpactTravel(elapsed, duration, distance, scrollSpeed)
    local span = duration - Anim.IMPACT_ENTRANCE_DURATION
    if span <= 0 then
        return 0
    end
    local progress = Anim.Clamp01((elapsed - Anim.IMPACT_ENTRANCE_DURATION) / span * math.max(0.01, scrollSpeed or 1))
    return (distance or 0) * Anim.EaseOutQuad(progress)
end

function Anim.GetImpactMotionBounds(spacingScale, distance)
    local scale = spacingScale or 1
    return -IMPACT_OVERSHOOT * scale, IMPACT_START_X * scale,
        math.min(-IMPACT_OVERSHOOT * scale, distance or 0), math.max(IMPACT_START_Y * scale, distance or 0)
end

function Anim.ComputeImpactLabelAlpha(elapsed)
    local t = Anim.Clamp01(elapsed / Anim.IMPACT_ENTRANCE_DURATION)
    -- One opacity dip, with no repeated flashing or forced color change.
    return 1 - 0.55 * math.sin(math.pi * t) ^ 2
end

function Anim.ComputeAlpha(frame, progress)
    local fadePower = frame.fadePower or 1
    local baseAlpha = frame.baseAlpha or 1
    local fadeIn = frame.fadeInRatio or 0

    if frame.fadeMode == "linear" then
        -- Fully visible for most of the trip, then a straight fade over the last fifth.
        return baseAlpha * (1 - Anim.Clamp01((progress - 0.8) / 0.2))
    end

    if frame.fadeMode == "impact" then
        local t = Anim.Clamp01((progress - 0.55) / 0.45)
        return baseAlpha * (1 - t * t * (3 - 2 * t))
    end

    if fadeIn > 0 and progress < fadeIn then
        return Anim.EaseOutQuint(progress / fadeIn) * baseAlpha
    end

    if frame.fadeMode == "inExpo" then
        return baseAlpha * (1 - Anim.EaseInExpo(progress))
    end

    if frame.fadeMode == "smooth" then
        local fadeStart = fadeIn
        local span = 1 - fadeStart
        if span <= 0 then
            return 0
        end
        local fadeT = (progress - fadeStart) / span
        return Anim.EaseOutQuad(1 - fadeT) * baseAlpha
    end

    local fadeStart = fadeIn
    if frame.isCrit and frame.animMode ~= "classicPow" and frame.critSlapDuration and frame.duration > 0 then
        fadeStart = math.max(fadeStart, frame.critSlapDuration / frame.duration)
        if progress <= fadeStart then
            return baseAlpha
        end
    end

    local span = 1 - fadeStart
    if span <= 0 then
        return 0
    end
    local fadeT = (progress - fadeStart) / span
    return ((1 - fadeT) ^ fadePower) * baseAlpha
end

function Anim.ComputeFountain(progress, arcX, arcTop, arcBottom)
    local p = Anim.EaseOutCubic(progress)
    local dx = p * (arcX or 0)
    local top = arcTop or 20
    local bottom = arcBottom or -12
    local dy = -(4 * top - 2 * bottom) * p * p + (4 * top - bottom) * p
    return dx, dy
end

function Anim.ComputeRainfall(progress, distance, rainX, rainStartY)
    local p = Anim.EaseOutCubic(progress)
    return rainX or 0, (rainStartY or 0) - (distance or 0) * p
end

function Anim.ComputeVertical(progress, distance)
    return 0, (distance or 0) * Anim.EaseOutCubic(progress)
end

-- Screen areas scroll at a constant speed so spacing between numbers holds for the whole
-- trip; a curved path bows sideways by `curve` at the middle and returns.
function Anim.ComputeAreaPath(progress, travel, curve)
    local p = Anim.Clamp01(progress)
    return (curve or 0) * 4 * p * (1 - p), (travel or 0) * p
end

Anim.fountainArcDir = 1

function Anim.NextFountainArcX()
    local dir = Anim.fountainArcDir
    Anim.fountainArcDir = -dir
    return dir * math.random(28, 56)
end
