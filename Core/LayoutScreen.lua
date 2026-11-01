local _, BD = ...
local Render = BD.Render

-- Screen layout: numbers scroll inside rectangles the player places (Layout.lua keeps the saved
-- areas, motion and routes). Every scrolling number in an area moves at the same speed, so a new one
-- only pushes older ones ahead in time to keep them apart; no layout pass is needed.
-- Incoming numbers always use this layout; outgoing ones when the display mode is "screen".

local OUTGOING_LEVEL, INCOMING_LEVEL = 110, 120
local CURVE_SHARE = 0.3 -- a curved path bows up to this share of the area width to its side

local OUTGOING_ROUTES = { hit = "routeOutgoingHit", crit = "routeOutgoingCrit", miss = "routeOutgoingMiss" }
local INCOMING_ROUTES = { hit = "routeIncomingHit", crit = "routeIncomingCrit", miss = "routeIncomingMiss" }

local runtimes = {} -- area id -> { anchor, sticky, frames (oldest first), area }
local destinationIds = setmetatable({}, { __mode = "k" })
local nextDestinationId = 0

local function MotionKey(area)
    return table.concat({ area.animation, area.direction, area.duration, area.spacing, area.alignment,
        area.stickyCrits and "1" or "0", area.width, area.height }, ":")
end

local function ApplyGeometry(runtime, area)
    if runtime.x ~= area.x or runtime.y ~= area.y or runtime.width ~= area.width or runtime.height ~= area.height then
        local anchor = runtime.anchor
        anchor:ClearAllPoints()
        anchor:SetPoint("CENTER", UIParent, "CENTER", area.x, area.y)
        anchor:SetSize(area.width, area.height)
        runtime.x, runtime.y, runtime.width, runtime.height = area.x, area.y, area.width, area.height
    end
    runtime.area = area
    runtime.motionKey = MotionKey(area)
end

local function Runtime(area)
    local runtime = runtimes[area.id]
    if not runtime then
        -- Unscaled like the numbers themselves, so saved positions mean the same at any UI scale.
        local anchor = CreateFrame("Frame", nil, UIParent)
        anchor:SetIgnoreParentScale(true)
        -- Held crits gather around the center, apart from the scrolling numbers.
        local sticky = CreateFrame("Frame", nil, anchor)
        sticky:SetSize(1, 1)
        sticky:SetPoint("CENTER", anchor, "CENTER", 0, 0)
        runtime = { anchor = anchor, sticky = sticky, frames = {} }
        runtimes[area.id] = runtime
    end
    ApplyGeometry(runtime, area)
    return runtime
end

-- The area's live numbers, oldest first. Released or recycled frames drop out here.
local function LiveFrames(runtime)
    local frames, write = runtime.frames, 1
    for read = 1, #frames do
        local frame = frames[read]
        if frame.areaRuntime == runtime and frame:IsShown() then
            frames[write] = frame
            write = write + 1
        end
    end
    for index = write, #frames do
        frames[index] = nil
    end
    return frames
end

-- Past the area's limit the oldest normal number gives way (the oldest crit when all are crits).
local function MakeRoom(runtime)
    local frames = LiveFrames(runtime)
    while #frames >= BD.MAX_NUMBERS_PER_AREA do
        local victim = frames[1]
        for _, frame in ipairs(frames) do
            if not frame.isCrit then
                victim = frame
                break
            end
        end
        BD.Pool.Release(victim)
        frames = LiveFrames(runtime)
    end
    return frames
end

local function Scrolls(frame)
    return frame.areaTravel ~= 0 and not (frame.isCrit and frame.critsHold)
end

-- A new number starts the path: push older ones ahead just far enough to clear the one behind.
local function Spread(frames, newest)
    local position, line = 0, newest.areaLine
    for index = #frames, 1, -1 do
        local frame = frames[index]
        if frame ~= newest and Scrolls(frame) then
            local need = position + (line + frame.areaLine) * 0.5
            local travel = math.abs(frame.areaTravel)
            local travelled = travel * math.min(1, frame.elapsed / frame.duration)
            if travelled >= need then
                break
            end
            frame.elapsed = math.min(frame.duration, need / travel * frame.duration)
            position, line = need, frame.areaLine
        end
    end
end

-- Painted bounds are secret-safe and include icons and critical labels.
local function AreaMetrics(frame, area)
    local bounds = frame.areaBounds
    local peak = frame.isCrit and math.max(1, frame.critSlapScale or 1, frame.critRestScale or 1) or 1
    peak = peak * (1 + BD.COMBINE_PULSE_SCALE)
    frame.areaLine = (bounds[4] - bounds[3]) * peak + area.spacing
    local left = -area.width * 0.5 - bounds[1] * peak
    local right = area.width * 0.5 - bounds[2] * peak
    local curve = 0
    if not frame.critsHold then
        local bow = math.min(area.width * CURVE_SHARE, math.max(0, right - left))
        if area.animation == "curveLeft" then curve = -bow
        elseif area.animation == "curveRight" then curve = bow end
    end
    frame.areaCurve = curve
    -- Align the entire swept path, including the peak text/icon bounds, inside the rectangle.
    left, right = left - math.min(0, curve), right - math.max(0, curve)
    if left <= right and not frame.critsHold then
        if area.alignment == "left" then return left end
        if area.alignment == "right" then return right end
    end
    return (left + right) * 0.5
end

function BD:RefreshAreaNumber(frame)
    local runtime = frame.areaRuntime
    if not runtime or not runtime.area then return end
    frame.startX = AreaMetrics(frame, runtime.area)
    if Scrolls(frame) then
        local frames = LiveFrames(runtime)
        if #frames > 0 then Spread(frames, frames[#frames]) end
    end
end

-- Static areas stack: older numbers step away from the start, and leave past the far edge.
local function Stack(frames, newest, direction, height)
    for _, frame in ipairs(frames) do
        if not (frame.isCrit and frame.critsHold) then
            frame.areaStack = (frame.areaStack or 0) + direction * newest.areaLine
            if math.abs(frame.areaStack) > height then
                BD.Pool.Release(frame)
            end
        end
    end
end

local function DestinationId(destKey)
    if type(destKey) == "table" then
        local id = destinationIds[destKey]
        if not id then
            nextDestinationId = nextDestinationId + 1
            id = "plate" .. nextDestinationId
            destinationIds[destKey] = id
        end
        return id
    end
    -- Classic GUIDs are plaintext; Modern keys are a plate or "target", never a secret.
    if type(destKey) == "string" then
        return destKey
    end
    return "any"
end

-- Place a configured frame in its area. Returns the frame, or nil when the threshold hid it.
local function Spawn(self, area, frame, preset, numberStyle, text, r, g, b, amount, icon, level,
    combineKey, combineOwner, previewRuntime)
    local runtime = previewRuntime or Runtime(area)
    local frames = MakeRoom(runtime)
    -- Impact stacks: each number slams in at the bottom and pushes older ones up, so its areas
    -- always rise and keep crits in the stack. Linear follows the area's direction and path.
    local impact = frame.animMode == "impactSlam"
    local direction = (not impact and area.direction == "down") and -1 or 1
    local held = not impact and frame.isCrit and area.stickyCrits and true or false

    frame.areaRuntime = runtime
    frame.areaSpacing = area.spacing
    frame.staticAnchor = true
    frame.critsHold = held
    frame.fixedSpawn = not impact and true or nil
    frame.spawnJitter = 0
    frame.fadeMode = "linear"
    -- Area timing is independent of nameplate duration and scroll speed.
    frame.scrollSpeed = 1
    frame.duration = area.duration
    Render.ParentToScreen(frame, level)
    if previewRuntime then
        frame.isPreview = true
        frame.previewOwner = runtime.anchor
        frame:SetParent(runtime.anchor)
        frame:SetIgnoreParentScale(false)
        frame:SetFrameLevel(runtime.anchor:GetFrameLevel() + 1)
    end

    local fontSize, fontPath, layoutOpts = Render.Paint(self, frame, preset, numberStyle, text, r, g, b, amount, icon)
    if not fontSize then
        return nil
    end
    local baseX = AreaMetrics(frame, area)

    local anchor, baseY = runtime.anchor, 0
    frame.areaTravel = 0
    if held then
        anchor = runtime.sticky
        frame.anchorRelPoint = "CENTER"
    elseif impact then
        -- Pool pushes the stack on spawn; the whole stack drifts up through the area.
        frame.anchorRelPoint = "BOTTOM"
        local inset = math.min(area.height * 0.5, frame.areaLine * 0.5)
        baseY = inset
        frame.floatDistance = math.max(0, area.height - inset * 2)
    else
        frame.anchorRelPoint = direction > 0 and "BOTTOM" or "TOP"
        local inset = math.min(area.height * 0.5, frame.areaLine * 0.5)
        baseY = direction * inset
        if area.animation ~= "static" then
            frame.areaTravel = direction * math.max(0, area.height - inset * 2)
        end
    end
    frame.anchor = anchor

    if combineKey then
        Render.RememberCombine(self, frame, combineOwner, combineKey, amount, icon, fontSize, fontPath, preset,
            layoutOpts)
    end
    if held then
        -- A central crit lane stacks away from the center instead of covering earlier crits.
        local offset, line = 0, frame.areaLine
        for index = #frames, 1, -1 do
            local other = frames[index]
            if other.critsHold then
                offset = math.max(other.areaStack or 0, offset + (line + other.areaLine) * 0.5)
                other.areaStack, line = offset, other.areaLine
                if offset + other.areaLine * 0.5 > area.height * 0.5 then BD.Pool.Release(other) end
            end
        end
    elseif not impact then
        if area.animation == "static" then
            Stack(frames, frame, direction, area.height)
        else
            Spread(frames, frame)
        end
    end
    frames[#frames + 1] = frame
    Render.Present(self, frame, anchor, baseX, baseY)
    return frame
end

-- Outgoing numbers in screen mode (BD:ShowOutgoing). destKey separates enemies for combining.
function BD:ShowInArea(destKey, text, r, g, b, amountForThreshold, isCrit, isHeal, spellIcon, hitKind, spellId)
    if not Render.PassesFilters(self, hitKind, isCrit, isHeal) then
        return
    end
    local kind = hitKind
    if not kind then
        kind = isCrit and "crit" or "hit"
    end
    local route = isHeal and "routeOutgoingHeal" or OUTGOING_ROUTES[kind] or OUTGOING_ROUTES.hit
    local area = self:GetRoutedArea(route, "outgoing")
    local runtime = Runtime(area)

    local combined, combineKey = Render.Combine(self, runtime, kind, isHeal, spellIcon, spellId, amountForThreshold,
        DestinationId(destKey))
    if combined then
        return
    end

    local frame, preset, numberStyle = Render.Begin(self, kind, isCrit, isHeal, false, "area", area)
    r, g, b = Render.OutgoingColor(self, preset, r, g, b, isHeal)
    local icon = self:ResolveOutgoingSpellIcon(spellIcon, spellId)
    if not Spawn(self, area, frame, preset, numberStyle, text, r, g, b, amountForThreshold, icon, OUTGOING_LEVEL,
        combineKey, runtime) then
        return
    end
    if not isHeal and kind ~= "miss" then
        Render.CritSound(self, frame, amountForThreshold, combineKey)
    end
end

-- Damage and misses on the player, in every display mode.
function BD:ShowIncoming(text, r, g, b, amountForThreshold, isCrit, hitKind)
    if not Render.PassesFilters(self, hitKind, isCrit, false) then
        return
    end
    local kind = hitKind
    if not kind then
        kind = isCrit and "crit" or "hit"
    end
    local area = self:GetRoutedArea(INCOMING_ROUTES[kind] or INCOMING_ROUTES.hit, "incoming")
    local frame, preset, numberStyle = Render.Begin(self, kind, isCrit, false, true, "area", area)
    local color = BD.INCOMING_COLOR
    Spawn(self, area, frame, preset, numberStyle, text, r or color[1], g or color[2], b or color[3],
        amountForThreshold, nil, INCOMING_LEVEL)
end

-- Reapply saved geometry after a settings change. Numbers in a deleted area are released.
function BD:RefreshScreenAreas()
    if not self.db then
        return
    end
    self:EnsureScreenAreas()
    for id, runtime in pairs(runtimes) do
        local area = BD.FindScreenArea(self.db, id)
        if area then
            if runtime.motionKey ~= MotionKey(area) then
                for _, frame in ipairs(LiveFrames(runtime)) do BD.Pool.Release(frame) end
            end
            ApplyGeometry(runtime, area)
        else
            for _, frame in ipairs(LiveFrames(runtime)) do
                BD.Pool.Release(frame)
            end
            runtime.area = nil
        end
    end
end

-- Live area tests: routed samples, optionally including areas without any routes yet.
local TEST_SAMPLES = {
    { route = "routeOutgoingHit", fallback = "outgoing", kind = "hit", amount = 12400 },
    { route = "routeOutgoingCrit", fallback = "outgoing", kind = "crit", amount = 48600 },
    { route = "routeOutgoingHeal", fallback = "outgoing", kind = "hit", amount = 9100, heal = true },
    { route = "routeOutgoingMiss", fallback = "outgoing", kind = "miss", text = "MISS" },
    { route = "routeIncomingHit", fallback = "incoming", kind = "hit", amount = 3200, incoming = true },
    { route = "routeIncomingCrit", fallback = "incoming", kind = "crit", amount = 7400, incoming = true },
    { route = "routeIncomingMiss", fallback = "incoming", kind = "miss", text = "DODGE", incoming = true },
}

function BD:ShowScreenAreaTest(areaId, incomingOnly, session, includeUnused)
    local function Queue(sample, index, destination)
        C_Timer.After((index - 1) * 0.15, function()
            if session and not session.active then return end
            if sample.incoming and not self.db.showIncoming then return end
            local area = BD.FindScreenArea(self.db, destination)
            if not area then return end
            local isCrit = sample.kind == "crit"
            local frame, preset, numberStyle = Render.Begin(self, sample.kind, isCrit, sample.heal, sample.incoming,
                "area", area)
            if session then frame.isPreview, frame.previewOwner = true, session end
            local r, g, b
            if sample.incoming then
                local color = BD.INCOMING_COLOR
                r, g, b = color[1], color[2], color[3]
            elseif sample.kind == "miss" then
                r, g, b = 1, 0.85, 0.2
            else
                r, g, b = Render.OutgoingColor(self, preset, nil, nil, nil, sample.heal)
            end
            local text = sample.text or BD.FormatAmount(sample.amount, self.db.abbreviate)
            local shown = Spawn(self, area, frame, preset, numberStyle, text, r, g, b, nil, nil,
                sample.incoming and INCOMING_LEVEL or OUTGOING_LEVEL)
            -- Settings may overlap an area: keep its live preview above the window.
            if shown and session then shown:SetFrameStrata("DIALOG") end
        end)
    end
    local covered = {}
    for index, sample in ipairs(TEST_SAMPLES) do
        if (not incomingOnly or sample.incoming) and (not sample.incoming or self.db.showIncoming) then
            local area
            if areaId then area = BD.FindScreenArea(self.db, areaId)
            else area = self:GetRoutedArea(sample.route, sample.fallback) end
            if area then
                covered[area.id] = true
                Queue(sample, index, area.id)
            end
        end
    end
    if includeUnused then
        for _, area in ipairs(self.db.screenAreas or {}) do
            if not covered[area.id] and (area.id ~= "incoming" or self.db.showIncoming) then
                local incoming = area.id == "incoming" or (incomingOnly and true or false)
                for index, sample in ipairs(TEST_SAMPLES) do
                    if (sample.incoming and true or false) == incoming then Queue(sample, index, area.id) end
                end
            end
        end
    end
end

-- The options drawer uses the same spawn, geometry, spacing and animation as live areas.
function BD:ShowScreenAreaPreview(anchor, kind, area, incoming)
    local runtime = anchor.areaPreviewRuntime
    if not runtime then
        local sticky = CreateFrame("Frame", nil, anchor)
        sticky:SetSize(1, 1)
        sticky:SetPoint("CENTER", anchor, "CENTER", 0, 0)
        runtime = { anchor = anchor, sticky = sticky, frames = {} }
        anchor.areaPreviewRuntime = runtime
    end
    local crit = kind == "crit"
    runtime.area = area
    local frame, preset, style = Render.Begin(self, kind, crit, false, incoming, "area", area)
    local color = incoming and BD.INCOMING_COLOR or preset.defaultColor
    local text = kind == "miss" and "MISS" or BD.FormatAmount(crit and 48600 or 12400, self.db.abbreviate)
    local icon = not incoming and kind ~= "miss" and self:ResolveOutgoingSpellIcon(BD.GENERIC_PET_ICON)
    return Spawn(self, area, frame, preset, style, text, color[1], color[2], color[3], nil, icon,
        OUTGOING_LEVEL, nil, nil, runtime)
end
