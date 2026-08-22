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
        return restScale or 1.18
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

function Anim.ComputeAlpha(frame, progress)
    local fadePower = frame.fadePower or 1
    local baseAlpha = frame.baseAlpha or 1
    local fadeIn = frame.fadeInRatio or 0

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
