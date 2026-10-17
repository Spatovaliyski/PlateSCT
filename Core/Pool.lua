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

local CLASSIC_LAYOUT_PAD = 4
local CLASSIC_LAYOUT_CELL = 64
local classicWorldSpace = {}
local ROLLING_AVERAGE_WINDOW = 10
local ROLLING_AVERAGE_MAX_AGE = 8.0
local IMPACT_PUSH_DURATION = 0.08
local IMPACT_STACK_OFFSET = 32

local damageSamples = {}
local rollingDamageAverage = 0
local lastClassicRelayoutTime = -1
local lastClassicLayout
local spawnOrder = 0

-- Only crits use the classic grow-and-settle shove grid. Normal hits keep
-- their clear-spawn offsets so multi-target AOE does not pile in one stack.
local function IsClassicShoveFrame(frame)
    return frame.usesClassicShove
        and frame.animMode == "classicPow"
        and frame.isCrit
        and frame.critsHold
end

local function IsClassicStyleFrame(frame)
    return frame.usesClassicShove and frame.animMode == "classicPow" and frame.classicReady
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

local function ComputeImpactPush(frame)
    local target = frame.impactPushTo or 0
    if not frame.impactPushStarted then
        return target
    end
    local progress = (frame.elapsed - frame.impactPushStarted) / IMPACT_PUSH_DURATION
    local from = frame.impactPushFrom or 0
    return from + (target - from) * Anim.EaseOutCubic(progress)
end

local function ComputeMotion(frame)
    local progress = 0
    if frame.duration and frame.duration > 0 then
        progress = math.min(frame.elapsed / frame.duration, 1)
    end

    -- Scroll speed advances travel sooner; fade still follows full display duration.
    local scrollSpeed = frame.scrollSpeed or 1
    if scrollSpeed < 0.01 then
        scrollSpeed = 0.01
    end
    local motionProgress = math.min(1, progress * scrollSpeed)

    if frame.animMode == "impactSlam" then
        local dx, dy = Anim.ComputeImpactEntrance(frame.elapsed, frame.impactSpacingScale)
        dy = dy + Anim.ComputeImpactTravel(frame.elapsed, frame.duration, frame.floatDistance, scrollSpeed)
        dy = dy + ComputeImpactPush(frame)
        local scale = Anim.ComputeImpactScale(frame.elapsed, frame.isCrit, frame.critSlapScale, frame.critRestScale)
        return (frame.startX or 0) + dx, (frame.startY or 0) + dy, scale, Anim.ComputeAlpha(frame, progress)
    end

    local scale, introDuration = ComputeIntroScale(frame)
    scale = scale * (frame.amountScale or 1)
    local extraY = 0
    local motionStyle = frame.motionStyle or "platesct"
    local useExtraPath = BD.IsExtraMotionPath(motionStyle)

    if frame.isCrit and frame.animMode ~= "classicPow" and introDuration > 0 and frame.elapsed < introDuration then
        extraY = (1 - Anim.EaseOutCubic(frame.elapsed / introDuration)) * (frame.critSlapDrop or 0)
    end

    local floatProgress = motionProgress
    if frame.isCrit and introDuration > 0 and frame.duration and frame.duration > introDuration and frame.critsHold and not useExtraPath then
        local introRatio = introDuration / frame.duration
        floatProgress = math.max(0, (motionProgress - introRatio) / (1 - introRatio))
    end

    local floatDistance = frame.floatDistance or 0
    if frame.isCrit and frame.critsHold and not useExtraPath then
        floatDistance = 0
    end

    if useExtraPath then
        local dx, dy = 0, 0
        if motionStyle == "fountain" then
            dx, dy = Anim.ComputeFountain(motionProgress, frame.arcX, frame.arcTop, frame.arcBottom)
        elseif motionStyle == "rainfall" then
            dx, dy = Anim.ComputeRainfall(motionProgress, frame.rainDistance, frame.rainX, frame.rainStartY)
        elseif motionStyle == "verticalDown" then
            dx, dy = Anim.ComputeVertical(motionProgress, -(floatDistance > 0 and floatDistance or 20))
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

local lingerHosts = {}

local function IsUsableAnchor(region)
    if not region then
        return false
    end
    if region == UIParent or region == WorldFrame then
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
    if not relTo or not IsUsableAnchor(relTo) then
        return false
    end
    return pcall(frame.SetPoint, frame, point, relTo, relPoint, x or 0, y or 0)
end

local function AnchorIsShown(anchor)
    if not anchor then
        return false
    end
    local ok, shown = pcall(function()
        return anchor:IsShown()
    end)
    return ok and shown
end

local function AcquireLingerHost()
    local host = table.remove(lingerHosts)
    if not host then
        host = CreateFrame("Frame", nil, WorldFrame)
        host:SetSize(8, 8)
    end
    host:SetParent(WorldFrame)
    host:Show()
    return host
end

local function ReleaseLingerHost(host)
    if not host then
        return
    end
    host:Hide()
    host:ClearAllPoints()
    host:SetParent(WorldFrame)
    table.insert(lingerHosts, host)
end

local function GetWorldScaleFactor(region)
    local worldScale = WorldFrame:GetEffectiveScale()
    if not BD.CanAccessValue(worldScale) or not worldScale or worldScale == 0 then
        return nil
    end
    local okScale, scale = pcall(region.GetEffectiveScale, region)
    if not okScale or not BD.CanAccessValue(scale) or not scale or scale == 0 then
        scale = worldScale
    end
    return scale / worldScale
end

local function ReadWorldBottomLeft(region)
    if not region then
        return nil
    end
    local factor = GetWorldScaleFactor(region)
    if not factor then
        return nil
    end
    local ok, left, bottom = pcall(function()
        return region:GetLeft(), region:GetBottom()
    end)
    if not ok or not BD.CanAccessValue(left) or not BD.CanAccessValue(bottom)
        or left == nil or bottom == nil then
        return nil
    end
    return left * factor, bottom * factor
end

local function ReadWorldCenter(region)
    if not region then
        return nil
    end
    local factor = GetWorldScaleFactor(region)
    if not factor then
        return nil
    end
    local ok, x, y = pcall(region.GetCenter, region)
    if ok and BD.CanAccessValue(x) and BD.CanAccessValue(y) and x ~= nil and y ~= nil then
        return x * factor, y * factor
    end
    local left, bottom = ReadWorldBottomLeft(region)
    if left == nil then
        return nil
    end
    local okW, width = pcall(region.GetWidth, region)
    local okH, height = pcall(region.GetHeight, region)
    local w = ((okW and BD.CanAccessValue(width) and width) or 0) * factor
    local h = ((okH and BD.CanAccessValue(height) and height) or 0) * factor
    return left + w * 0.5, bottom + h * 0.5
end

local function StoreLingerWorldCenter(frame, x, y)
    if BD.CanAccessValue(x) and BD.CanAccessValue(y) and x ~= nil and y ~= nil then
        frame.lingerWorldX = x
        frame.lingerWorldY = y
    end
end

-- Read our frames first. Nameplate GetCenter is often nil on Classic *children*,
-- but the plate widget itself can still report a center while shown.
-- After reuse that center is the neighbor - allowPlate only while GUID matches.
local function SnapshotLingerHost(frame, allowPlate)
    local host = frame.lingerHost
    if host then
        local cx, cy = ReadWorldCenter(host)
        if cx ~= nil then
            StoreLingerWorldCenter(frame, cx, cy)
            return true
        end
    end
    local nx, ny = ReadWorldCenter(frame)
    if nx ~= nil then
        local mx, my = ComputeMotion(frame)
        local factor = GetWorldScaleFactor(frame) or 1
        if frame.classicReady or frame.animMode == "impactSlam" then
            factor = factor / frame:GetScale()
        end
        StoreLingerWorldCenter(frame, nx - mx * factor, ny - my * factor)
        if frame.lingerWorldX ~= nil then
            return true
        end
    end
    if allowPlate and frame.anchor then
        local cx, cy = ReadWorldCenter(frame.anchor)
        if cx ~= nil then
            local factor = GetWorldScaleFactor(frame.anchor)
            local okH, height = pcall(frame.anchor.GetHeight, frame.anchor)
            if factor and okH and BD.CanAccessValue(height) and height then
                cy = cy + height * factor * 0.5
            end
            if frame.anchorRelPoint == "TOPRIGHT" then
                local okW, width = pcall(frame.anchor.GetWidth, frame.anchor)
                if not factor or not okW or not BD.CanAccessValue(width) or not width then
                    return false
                end
                cx = cx + width * factor * 0.5
            end
            StoreLingerWorldCenter(frame, cx, cy)
            return true
        end
    end
    return false
end

local function PinLingerHostWorld(frame)
    local host = frame.lingerHost
    local x, y = frame.lingerWorldX, frame.lingerWorldY
    if not host or x == nil or y == nil then
        return false
    end
    host:SetParent(WorldFrame)
    host:ClearAllPoints()
    return SafeSetPoint(host, "CENTER", WorldFrame, "BOTTOMLEFT", x, y) and true or false
end

-- Follow while live via relative point (layout works even when GetLeft does not).
-- Recycle is handled by freeze, not by pinning to the plate's Lua coords.
local function BindLingerHostToPlate(frame, plate)
    local host = frame.lingerHost
    if not host or not plate then
        return false
    end
    host:SetParent(WorldFrame)
    host:ClearAllPoints()
    local relPoint = frame.anchorRelPoint or "TOP"
    if not SafeSetPoint(host, "CENTER", plate, relPoint, 0, 0) then
        return false
    end
    return true
end

local function FreezeLingerHost(frame)
    if frame.lingerFrozen then
        return true
    end
    -- Do not read the plate. Recycle may already have moved it.
    if frame.lingerWorldX == nil or frame.lingerWorldY == nil then
        SnapshotLingerHost(frame, false)
    end
    -- Only strip the relative point when we can pin in world space.
    -- ClearAllPoints with no pin is what made death linger vanish.
    if PinLingerHostWorld(frame) then
        frame.anchor = nil
        frame.unitToken = nil
        frame.lingerFrozen = true
        return true
    end
    -- No pin yet: keep the relative point so the number stays drawn.
    -- Drop plate identity so Classic shove cannot cluster onto a neighbor.
    frame.anchor = nil
    frame.unitToken = nil
    frame.lingerFrozen = true
    return true
end

local function GetPlateUnitToken(plate)
    if not plate then
        return nil
    end
    local ok, token = pcall(function()
        return plate.namePlateUnitToken
    end)
    if ok and type(token) == "string" then
        return token
    end
    return nil
end

local function AnchorGuidChanged(frame)
    -- Classic-only reuse signal. Modern UnitGUID is often secret - ValuesNotEqual
    -- returns false; orphan via plate hide / NAME_PLATE_UNIT_REMOVED instead.
    -- Compare the plate widget's current token; stored nameplateN can lag reuse.
    if not frame.anchorGuid then
        return false
    end
    local token = GetPlateUnitToken(frame.anchor) or frame.unitToken
    if not token then
        return false
    end
    return BD.ValuesNotEqual(UnitGUID(token), frame.anchorGuid)
end

local function AttachLingerHost(frame, plate)
    if not frame.lingerHost then
        frame.lingerHost = AcquireLingerHost()
    end
    frame.lingerFrozen = nil
    BindLingerHostToPlate(frame, plate)
end

local function ReleaseFrame(frame)
    if frame.classicReady then
        lastClassicLayout = nil
    end
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
        frame.critLabel:SetAlpha(1)
        frame.critLabel:Hide()
        frame.critLabel:ClearAllPoints()
    end
    frame.isPreview = nil
    frame.anchor = nil
    frame.unitToken = nil
    frame.incoming = nil
    frame.motionStyle = nil
    frame.animMode = nil
    frame.numberStyle = nil
    frame.impactSpacingScale = nil
    frame.impactPushFrom = nil
    frame.impactPushTo = nil
    frame.impactPushStarted = nil
    frame.anchorRelPoint = nil
    frame.usesClassicShove = nil
    frame.classicReady = nil
    frame.classicBounds = nil
    frame.classicBaseX = nil
    frame.classicBaseY = nil
    frame.amountScale = nil
    frame.spawnOrder = nil
    frame.spreadX, frame.spreadY = nil, nil
    frame.spreadHalfW, frame.spreadHalfH, frame.spreadMeasuredAt = nil, nil, nil
    frame.spreadSeeded = nil
    frame.spreadTX, frame.spreadTY = nil, nil
    frame.spawnTime = nil
    frame.lingerFrozen = nil
    frame.lingerWorldX = nil
    frame.lingerWorldY = nil
    frame.anchorGuid = nil
    if frame.lingerHost then
        ReleaseLingerHost(frame.lingerHost)
        frame.lingerHost = nil
    end
    frame:ClearAllPoints()
    frame:SetParent(UIParent)
    frame:SetFrameLevel(0)
    frame:SetIgnoreParentScale(false)
    active[frame] = nil
    table.insert(pool, frame)
end

local function ApproxFrameWorldPos(frame, sx, sy)
    sx = sx or frame.startX or 0
    sy = sy or frame.startY or 0
    local host = frame.lingerHost or frame.anchor
    local hx, hy = ReadWorldCenter(host)
    if hx ~= nil then
        return hx + sx, hy + sy
    end
    if frame.lingerWorldX ~= nil and frame.lingerWorldY ~= nil then
        return frame.lingerWorldX + sx, frame.lingerWorldY + sy
    end
    return nil, nil
end

local function GetClassicLayoutScale(frame)
    local scale = ComputeIntroScale(frame)
    if frame.isCrit and frame.elapsed < (frame.critPowDuration or 0.22) then
        scale = math.max(scale, frame.critPowStartScale or 1,
            frame.critPowPeakScale or 2, frame.critRestScale or 1.4)
    elseif not frame.isCrit and frame.elapsed < (frame.popDuration or 0) then
        scale = math.max(scale, 1, frame.popScale or 1)
    end
    return scale * (frame.amountScale or 1)
end

local function ClassicOrigin(frame)
    if frame.isPreview or frame.incoming then
        return nil, nil, 1
    end
    -- Measure our host, never the nameplate. Remove the frame's animation
    -- scale: offsets and the layout gap are in unscaled frame coordinates.
    local okScale, factor = pcall(function()
        return GetWorldScaleFactor(frame) / frame:GetScale()
    end)
    if not okScale or not BD.CanAccessValue(factor) or not factor or factor <= 0 then
        factor = 1
    end
    if frame.lingerHost then
        local ok, x, y = pcall(ReadWorldCenter, frame.lingerHost)
        if ok and BD.CanAccessValue(x) and BD.CanAccessValue(y) and x and y then
            return x, y, factor
        end
    end
    local x, y = frame.lingerWorldX, frame.lingerWorldY
    if BD.CanAccessValue(x) and BD.CanAccessValue(y) and x and y then
        return x, y, factor
    end
    return nil, nil, 1
end

local function BuildClassicEntries(frames)
    local entries, localAnchors = {}, {}
    for _, frame in ipairs(frames) do
        local ox, oy, factor = ClassicOrigin(frame)
        if not ox and frame.anchor and not frame.isPreview and not frame.incoming then
            localAnchors[frame.anchor] = true
        end
        entries[#entries + 1] = {
            frame = frame, ox = ox, oy = oy, factor = factor,
            order = frame.spawnOrder, anchor = frame.anchor,
            preview = frame.isPreview, incoming = frame.incoming,
            frozen = frame.lingerFrozen, shove = IsClassicShoveFrame(frame),
        }
    end
    for _, entry in ipairs(entries) do
        local frame = entry.frame
        if localAnchors[frame.anchor] then
            entry.ox, entry.oy, entry.factor = nil, nil, 1
        end
        local x, y = ComputeMotion(frame)
        local scale = GetClassicLayoutScale(frame) * entry.factor
        local bounds = frame.classicBounds
        entry.left, entry.right = bounds[1] * scale, bounds[2] * scale
        entry.bottom, entry.top = bounds[3] * scale, bounds[4] * scale
        entry.dx, entry.dy = x - (frame.startX or 0), y - (frame.startY or 0)
        entry.x = (entry.ox or 0) + x * entry.factor
        entry.y = (entry.oy or 0) + y * entry.factor
    end
    return entries
end

local function ClassicSpace(obstacles, entry, create)
    local frame = entry.frame
    local domain = frame.isPreview and obstacles.preview
        or (frame.incoming and obstacles.incoming or obstacles.outgoing)
    local key = entry.ox and classicWorldSpace or frame.anchor or frame
    local space = domain[key]
    if not space and create then
        space = { entries = {}, cells = {} }
        domain[key] = space
    end
    return space
end

local function AddClassicObstacle(obstacles, entry)
    local space = ClassicSpace(obstacles, entry, true)
    space.entries[#space.entries + 1] = entry
    local gap = CLASSIC_LAYOUT_PAD * entry.factor
    local minX = math.floor((entry.x + entry.left - gap) / CLASSIC_LAYOUT_CELL)
    local maxX = math.floor((entry.x + entry.right + gap) / CLASSIC_LAYOUT_CELL)
    local minY = math.floor((entry.y + entry.bottom - gap) / CLASSIC_LAYOUT_CELL)
    local maxY = math.floor((entry.y + entry.top + gap) / CLASSIC_LAYOUT_CELL)
    for x = minX, maxX do
        for y = minY, maxY do
            local key = x .. ":" .. y
            local cell = space.cells[key]
            if not cell then
                cell = {}
                space.cells[key] = cell
            end
            cell[#cell + 1] = entry
        end
    end
end

local function ClassicObstacles(entries)
    local obstacles = { preview = {}, incoming = {}, outgoing = {}, query = 0 }
    for _, entry in ipairs(entries or {}) do
        AddClassicObstacle(obstacles, entry)
    end
    return obstacles
end

local function ClassicSlotBlocked(entry, x, y, obstacles)
    local space = ClassicSpace(obstacles, entry, false)
    if not space then
        return false
    end
    -- Only test rectangles in nearby cells. Keep the exact rectangle test;
    -- the index changes lookup cost, never the chosen spacing or burst limit.
    obstacles.query = obstacles.query + 1
    local query = obstacles.query
    local pad = CLASSIC_LAYOUT_PAD * entry.factor
    local minX = math.floor((x + entry.left - pad) / CLASSIC_LAYOUT_CELL)
    local maxX = math.floor((x + entry.right + pad) / CLASSIC_LAYOUT_CELL)
    local minY = math.floor((y + entry.bottom - pad) / CLASSIC_LAYOUT_CELL)
    local maxY = math.floor((y + entry.top + pad) / CLASSIC_LAYOUT_CELL)
    for cx = minX, maxX do
        for cy = minY, maxY do
            local cell = space.cells[cx .. ":" .. cy]
            for _, other in ipairs(cell or {}) do
                if other.lastQuery ~= query then
                    other.lastQuery = query
                    local gap = CLASSIC_LAYOUT_PAD * math.max(entry.factor, other.factor)
                    if x + entry.right > other.x + other.left - gap + 0.001
                        and x + entry.left < other.x + other.right + gap - 0.001
                        and y + entry.top > other.y + other.bottom - gap + 0.001
                        and y + entry.bottom < other.y + other.top + gap - 0.001 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function FindClassicSlot(entry, x, y, obstacles)
    if not ClassicSlotBlocked(entry, x, y, obstacles) then
        return x, y
    end
    local bestX, bestY, bestDistance
    local function Try(cx, cy)
        local distance = (cx - x) ^ 2 + (cy - y) ^ 2
        if (not bestDistance or distance < bestDistance)
            and not ClassicSlotBlocked(entry, cx, cy, obstacles) then
            bestX, bestY, bestDistance = cx, cy, distance
        end
    end
    local space = ClassicSpace(obstacles, entry, false)
    for _, other in ipairs(space.entries) do
        local gap = CLASSIC_LAYOUT_PAD * math.max(entry.factor, other.factor)
        local right = other.x + other.right + gap - entry.left
        local left = other.x + other.left - gap - entry.right
        local top = other.y + other.top + gap - entry.bottom
        local bottom = other.y + other.bottom - gap - entry.top
        -- Stable tie order; corners fill compact adjoining rings after
        -- the first cross. An outer edge always provides an uncapped slot.
        Try(right, y)
        Try(left, y)
        Try(x, top)
        Try(x, bottom)
        Try(right, top)
        Try(left, top)
        Try(right, bottom)
        Try(left, bottom)
    end
    return bestX, bestY
end

local function NewestClassicFirst(a, b)
    return (a.frame.spawnOrder or 0) > (b.frame.spawnOrder or 0)
end

local function ClassicLayoutUnchanged(entries)
    if not lastClassicLayout or lastClassicLayout.count ~= #entries then
        return false
    end
    for _, entry in ipairs(entries) do
        local old = lastClassicLayout[entry.frame]
        if not old or old.order ~= entry.order or old.anchor ~= entry.anchor
            or old.preview ~= entry.preview or old.incoming ~= entry.incoming
            or old.frozen ~= entry.frozen or old.shove ~= entry.shove
            or old.ox ~= entry.ox or old.oy ~= entry.oy or old.factor ~= entry.factor
            or old.left ~= entry.left or old.right ~= entry.right
            or old.bottom ~= entry.bottom or old.top ~= entry.top
            or old.dx ~= entry.dx or old.dy ~= entry.dy
            or ((not entry.shove or entry.frozen) and (old.x ~= entry.x or old.y ~= entry.y)) then
            return false
        end
    end
    return true
end

local function LayoutClassicFrames(frames, useCache)
    local entries = BuildClassicEntries(frames)
    if useCache and ClassicLayoutUnchanged(entries) then
        return entries
    end
    table.sort(entries, NewestClassicFirst)
    local obstacles, crits = ClassicObstacles(), {}
    local domains = { preview = {}, incoming = {}, outgoing = {} }
    for _, entry in ipairs(entries) do
        if IsClassicShoveFrame(entry.frame) and not entry.frame.lingerFrozen then
            crits[#crits + 1] = entry
        else
            AddClassicObstacle(obstacles, entry)
        end
    end
    for _, entry in ipairs(crits) do
        local frame = entry.frame
        local clusters = frame.isPreview and domains.preview
            or (frame.incoming and domains.incoming or domains.outgoing)
        local cluster = clusters[frame.anchor]
        local x = (entry.ox or 0) + (frame.classicBaseX or 0) * entry.factor
        local y = (entry.oy or 0) + (frame.classicBaseY or 0) * entry.factor
        if cluster then
            cluster.count = cluster.count + 1
            local center = cluster.center
            local gap = CLASSIC_LAYOUT_PAD * math.max(entry.factor, center.factor)
            x, y = center.x, center.y
            if cluster.count == 2 then
                x = center.x + center.right + gap - entry.left
            elseif cluster.count == 3 then
                x = center.x + center.left - gap - entry.right
            elseif cluster.count == 4 then
                y = center.y + center.top + gap - entry.bottom
            elseif cluster.count == 5 then
                y = center.y + center.bottom - gap - entry.top
            end
        end
        entry.x, entry.y = FindClassicSlot(entry, x, y, obstacles)
        frame.startX = (entry.x - (entry.ox or 0)) / entry.factor - entry.dx
        frame.startY = (entry.y - (entry.oy or 0)) / entry.factor - entry.dy
        if not cluster then
            clusters[frame.anchor] = { center = entry, count = 1 }
        end
        AddClassicObstacle(obstacles, entry)
    end
    if useCache then
        lastClassicLayout = { count = #entries }
        for _, entry in ipairs(entries) do
            lastClassicLayout[entry.frame] = entry
        end
    end
    return entries
end

local function ActiveClassicFrames(now)
    local frames = {}
    for frame in pairs(active) do
        if IsClassicStyleFrame(frame) then
            frame.elapsed = math.max(0, now - frame.spawnTime)
            if frame.elapsed < frame.duration then
                frames[#frames + 1] = frame
            end
        end
    end
    return frames
end

local function RelayoutClassic()
    local frames = ActiveClassicFrames(GetTime())
    LayoutClassicFrames(frames, true)
    for _, frame in ipairs(frames) do
        if IsClassicShoveFrame(frame) and not frame.lingerFrozen then
            local anchor = frame.lingerHost or frame.anchor
            local relPoint = frame.lingerHost and "CENTER" or (frame.anchorRelPoint or "TOP")
            local x, y, scale = ComputeMotion(frame)
            frame:SetScale(scale)
            frame:ClearAllPoints()
            SafeSetPoint(frame, "CENTER", anchor, relPoint, x / scale, y / scale)
        end
    end
end

local function MaybeRelayoutClassic()
    local now = GetTime()
    if now ~= lastClassicRelayoutTime then
        lastClassicRelayoutTime = now
        RelayoutClassic()
    end
end

local function PickClassicSpawn(frame, baseX, baseY, frames)
    frame.classicBaseX, frame.classicBaseY = baseX, baseY
    frame.startX, frame.startY = baseX, baseY
    if IsClassicShoveFrame(frame) then
        return baseX, baseY
    end
    frames[#frames + 1] = frame
    local entries = BuildClassicEntries(frames)
    frames[#frames] = nil
    local entry = table.remove(entries)
    table.sort(entries, NewestClassicFirst)
    local x, y = FindClassicSlot(entry, entry.x, entry.y, ClassicObstacles(entries))
    return (x - (entry.ox or 0)) / entry.factor - entry.dx,
        (y - (entry.oy or 0)) / entry.factor - entry.dy
end

local function GetClassicPreviewBounds(samples, stagger)
    local left, right, bottom, top = 0, 0, 0, 0
    local maxDuration, maxWidth, maxHeight = 0, 0, 0
    local allHeld = #samples > 0
    for _, sample in ipairs(samples) do
        maxDuration = math.max(maxDuration, sample.duration)
        local scale = GetClassicLayoutScale(sample)
        local bounds = sample.classicBounds
        maxWidth = math.max(maxWidth, (bounds[2] - bounds[1]) * scale)
        maxHeight = math.max(maxHeight, (bounds[4] - bounds[3]) * scale)
        allHeld = allHeld and IsClassicShoveFrame(sample)
    end
    local count = math.max(1, math.ceil(maxDuration / stagger))
    -- FindClassicSlot tries both ends of every blocked interval on each axis.
    -- The nearer end is at most half their total length away. Each obstacle
    -- contributes at most two maximum dimensions plus two gaps, so this
    -- radius covers every packing choice, including later preview cycles and
    -- variable amount scales. A finite simulation cannot guarantee that.
    local radius = (count - 1) * (math.min(maxWidth, maxHeight) + CLASSIC_LAYOUT_PAD)
    for _, sample in ipairs(samples) do
        local scale = GetClassicLayoutScale(sample)
        local bounds = sample.classicBounds
        local reachX, reachY = radius, radius
        if IsClassicShoveFrame(sample) then
            -- Held crits prefer the newest center, then its measured cross.
            -- A hit obstacle can move the center by another packing radius.
            local centerReach = allHeld and 0 or radius
            reachX = centerReach + (count > 1 and maxWidth + CLASSIC_LAYOUT_PAD or 0)
            reachY = centerReach + (count > 3 and maxHeight + CLASSIC_LAYOUT_PAD or 0)
            -- The first three crits are separated horizontally by construction.
            if not allHeld or count > 3 then
                reachX, reachY = reachX + radius, reachY + radius
            end
        end
        local travel = sample.previewTravel or { 0, 0, 0, 0 }
        local y = sample.classicBaseY
        left = math.min(left, -reachX + travel[1] + bounds[1] * scale)
        right = math.max(right, reachX + travel[2] + bounds[2] * scale)
        bottom = math.min(bottom, y - reachY + travel[3] + bounds[3] * scale)
        top = math.max(top, y + reachY + travel[4] + bounds[4] * scale)
    end
    return left - CLASSIC_LAYOUT_PAD, right + CLASSIC_LAYOUT_PAD,
        bottom - CLASSIC_LAYOUT_PAD, top + CLASSIC_LAYOUT_PAD
end

local function SpawnSlotBlocked(frame, anchor, cx, cy, minDistSq, acrossAnchors)
    local selfHostX, selfHostY = ReadWorldCenter(frame.lingerHost or anchor)
    local candWX, candWY
    if acrossAnchors and selfHostX ~= nil then
        candWX, candWY = selfHostX + cx, selfHostY + cy
    end

    for other in pairs(active) do
        if other ~= frame then
            local sameAnchor = other.anchor == anchor
            -- Across anchors with no readable plate center: treat plates as
            -- stacked (AOE pack) and block on relative offsets globally.
            local check = acrossAnchors or sameAnchor
            if check then
                local ox, oy = ComputeMotion(other)
                if acrossAnchors and candWX ~= nil then
                    local owx, owy = ApproxFrameWorldPos(other, ox, oy)
                    if owx ~= nil then
                        local dx = candWX - owx
                        local dy = candWY - owy
                        if (dx * dx + dy * dy) < minDistSq then
                            return true
                        end
                    else
                        local dx = cx - ox
                        local dy = cy - oy
                        if (dx * dx + dy * dy) < minDistSq then
                            return true
                        end
                    end
                else
                    local dx = cx - ox
                    local dy = cy - oy
                    if (dx * dx + dy * dy) < minDistSq then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function PushImpactFrames(anchor, frame)
    frame.impactPushTo = 0
    for other in pairs(active) do
        if other ~= frame and other.animMode == "impactSlam" and other.impactPushTo ~= nil
            and other.anchor == anchor and other.anchorRelPoint == frame.anchorRelPoint
            and other.isPreview == frame.isPreview and not other.lingerFrozen
            and other.elapsed < other.duration then
            -- Keep each push fixed in logical pixels, independent of font or crit size.
            other.impactPushFrom = ComputeImpactPush(other)
            other.impactPushTo = other.impactPushTo + IMPACT_STACK_OFFSET
            other.impactPushStarted = other.elapsed
        end
    end
end

--- Classic style uses measured rectangles; Modern style keeps its spawn lanes.
local function PickClearSpawn(anchor, frame, baseX, baseY, isCrit, acrossAnchors)
    if frame.animMode == "impactSlam" then
        local jitter = frame.spawnJitter or 0
        local x, y = baseX + (math.random() * 2 - 1) * jitter, baseY + (math.random() * 2 - 1) * jitter
        PushImpactFrames(anchor, frame)
        return x, y
    end
    if frame.usesClassicShove and frame.classicBounds then
        return PickClassicSpawn(frame, baseX, baseY, ActiveClassicFrames(GetTime()))
    end
    local lanes = frame.spawnLanes or DEFAULT_SPAWN_LANES
    local minDist = isCrit and (frame.spawnMinDistCrit or 26) or (frame.spawnMinDist or 20)
    local minDistSq = minDist * minDist
    local jitter = frame.spawnJitter or 10

    for _, lane in ipairs(lanes) do
        local cx = baseX + lane[1]
        local cy = baseY + lane[2]
        if not SpawnSlotBlocked(frame, anchor, cx, cy, minDistSq, false) then
            return cx, cy
        end
    end

    return baseX + math.random(-jitter, jitter), baseY + math.random(0, jitter)
end

local function RelayerImpact(parent)
    local frames = {}
    for frame in pairs(active) do
        if frame.animMode == "impactSlam" and frame:GetParent() == parent then
            frames[#frames + 1] = frame
        end
    end
    table.sort(frames, function(a, b) return a.spawnOrder < b.spawnOrder end)
    local baseLevel = math.max(100, parent:GetFrameLevel() + 1)
    for index, frame in ipairs(frames) do
        frame:SetFrameLevel(baseLevel + index - 1)
    end
end

-- Spread overlapping numbers (boids-style separation) ------------------------------------
-- Each live number is a measured box in screen pixels (number, icon, CRITICAL, spell name),
-- so numbers on neighbouring nameplates (cleave, AoE) push apart as well. Each overlapping
-- pair is pushed apart along the axis of least overlap, and the pushes build a smoothed
-- offset on top of the normal motion. Classic-style crits keep their own grid and Impact
-- keeps its deliberate stacking, so neither is moved; others move around them.
--
-- Cost control: runs at most SPREAD_RATE times a second, re-measures a box at most every
-- SPREAD_MEASURE_INTERVAL, compares only neighbours (sorted by left edge), skips nearly
-- faded numbers, and allocates nothing per pass.
local SPREAD_GAP = 4                -- screen px kept between boxes
local SPREAD_SPEED = 24             -- share of an overlap resolved per second (targets)
local SPREAD_EASE = 12              -- how quickly the shown offset follows its target
local SPREAD_GLIDE = 300            -- fastest the shown offset moves, screen px per second
local SPREAD_MAX = 80               -- furthest a number is pushed from its own path, screen px
local SPREAD_RATE = 30              -- passes per second at most
local SPREAD_MEASURE_INTERVAL = 0.2 -- seconds between text re-measures of one number
local SPREAD_MIN_ALPHA = 0.08       -- fainter numbers neither push nor get pushed
local SPREAD_ICON_GAP = 4
local SPREAD_SEED_OFFSETS = {
    { 0, 0 }, { 0, 1 }, { 0, -1 }, { 0, 2 }, { 0, -2 }, { 1, 0 }, { -1, 0 },
    { 1, 1 }, { -1, 1 }, { 1, -1 }, { -1, -1 }, { 0, 3 }, { 0, -3 },
}
local spreadNextAt, spreadLastAt = 0, nil
local spreadItems, spreadCount = {}, 0

local function MeasureRegion(region, fallbackW, fallbackH)
    local ok, w = pcall(region.GetStringWidth, region)
    -- Never inspect secret text metrics; a fixed box is close enough.
    if not ok or type(w) ~= "number" or BD.IsSecret(w) then
        w = fallbackW
    end
    local okH, h = pcall(region.GetStringHeight, region)
    if not okH or type(h) ~= "number" or BD.IsSecret(h) then
        h = fallbackH
    end
    return w, h
end

-- Half width and height of a number's visible group, in its own (unscaled) units.
-- Cached per frame: text only changes when a hit merges in, so a short refresh interval is enough.
local function SpreadBox(frame, now)
    if frame.spreadMeasuredAt and now - frame.spreadMeasuredAt < SPREAD_MEASURE_INTERVAL then
        return frame.spreadHalfW, frame.spreadHalfH
    end
    local w, h = MeasureRegion(frame.text, 60, 16)
    local icon = frame.icon
    if icon and icon:IsShown() then
        local size = icon:GetWidth() or 0
        local point = icon:GetPoint(1)
        if point == "TOP" or point == "BOTTOM" then
            w, h = math.max(w, size), h + size + SPREAD_ICON_GAP
        else
            w, h = w + size + SPREAD_ICON_GAP, math.max(h, size)
        end
    end
    local crit = frame.critLabel
    if crit and crit:IsShown() then
        local cw, ch = MeasureRegion(crit, 0, 0)
        if frame.animMode == "impactSlam" then
            w, h = math.max(w, cw), h + ch + 3
        else
            w = w + cw + 3
        end
    end
    -- Spell name labels record their span here when that feature is present.
    local extent = frame.nameExtent
    if extent then
        if extent.pos == "left" or extent.pos == "right" then
            w = w + extent.w
        else
            w, h = math.max(w, extent.w), h + extent.h
        end
    end
    frame.spreadHalfW, frame.spreadHalfH, frame.spreadMeasuredAt = w * 0.5, h * 0.5, now
    return frame.spreadHalfW, frame.spreadHalfH
end

-- How readily a number moves: 0 never (it keeps its own layout), crits less than hits.
local function SpreadWeight(frame)
    if frame.animMode == "impactSlam" or IsClassicShoveFrame(frame) then
        return 0
    end
    return frame.isCrit and 0.4 or 1
end

local function SpreadDirection(delta, a, b)
    if delta > 0 then
        return 1
    elseif delta < 0 then
        return -1
    end
    -- Exactly on top of each other: the newer number goes up / right.
    return (a.frame.spawnOrder or 0) < (b.frame.spawnOrder or 0) and 1 or -1
end

-- A new number starts in the first free nearby spot instead of on top of others: stacking
-- above or below first (numbers are wide), then sideways, within the cap. Runs in the
-- number's first update, before it is ever drawn, so the choice is never visible as a jump.
-- Numbers seeded since the last pass, which its item list does not include yet (reused tables).
local seedFresh, seedFreshCount = {}, 0

local function SpotTaken(x, y, hw, hh)
    for index = 1, spreadCount do
        local o = spreadItems[index]
        if o.frame and math.abs(o.x - x) < o.hw + hw and math.abs(o.y - y) < o.hh + hh then
            return true
        end
    end
    for index = 1, seedFreshCount do
        local o = seedFresh[index]
        if math.abs(o.x - x) < o.hw + hw and math.abs(o.y - y) < o.hh + hh then
            return true
        end
    end
    return false
end

-- Checks candidate spots against the boxes the last pass collected (at most 1/SPREAD_RATE old)
-- plus numbers seeded since then, so it reads no other frame's position.
local function SeedSpread(frame, now)
    frame.spreadSeeded = true
    if not (BD.db and BD.db.spreadNumbers) or frame.isPreview or SpreadWeight(frame) == 0 then
        return
    end
    local cx, cy = frame:GetCenter()
    if not cx then
        return
    end
    local eff = frame:GetEffectiveScale()
    local hw, hh = SpreadBox(frame, now)
    hw, hh = hw * eff + SPREAD_GAP * 0.5, hh * eff + SPREAD_GAP * 0.5
    local x0, y0 = cx * eff, cy * eff
    local chosenX, chosenY = 0, 0
    for _, c in ipairs(SPREAD_SEED_OFFSETS) do
        local ox, oy = c[1] * hw * 2, c[2] * hh * 2
        if ox * ox + oy * oy <= SPREAD_MAX * SPREAD_MAX and not SpotTaken(x0 + ox, y0 + oy, hw, hh) then
            chosenX, chosenY = ox, oy
            break
        end
    end
    frame.spreadX, frame.spreadY, frame.spreadTX, frame.spreadTY = chosenX, chosenY, chosenX, chosenY
    seedFreshCount = seedFreshCount + 1
    local fresh = seedFresh[seedFreshCount]
    if not fresh then
        fresh = {}
        seedFresh[seedFreshCount] = fresh
    end
    fresh.x, fresh.y, fresh.hw, fresh.hh = x0 + chosenX, y0 + chosenY, hw, hh
end

local function ByLeftEdge(a, b)
    return a.left < b.left
end

local function RunSpread(now)
    if not (BD.db and BD.db.spreadNumbers) or now < spreadNextAt then
        return
    end
    local dt = spreadLastAt and math.min(0.1, now - spreadLastAt) or (1 / SPREAD_RATE)
    spreadNextAt, spreadLastAt = now + 1 / SPREAD_RATE, now
    seedFreshCount = 0

    local count = 0
    for frame in pairs(active) do
        if frame:IsShown() and not frame.isPreview and frame.spreadSeeded
            and frame:GetAlpha() >= SPREAD_MIN_ALPHA then
            local cx, cy = frame:GetCenter()
            if cx and cy then
                local eff = frame:GetEffectiveScale()
                local hw, hh = SpreadBox(frame, now)
                count = count + 1
                local item = spreadItems[count]
                if not item then
                    item = {}
                    spreadItems[count] = item
                end
                item.frame = frame
                item.x = cx * eff + (frame.spreadTX or 0) - (frame.spreadX or 0)
                item.y = cy * eff + (frame.spreadTY or 0) - (frame.spreadY or 0)
                item.hw, item.hh = hw * eff + SPREAD_GAP * 0.5, hh * eff + SPREAD_GAP * 0.5
                item.left = item.x - item.hw
                item.weight, item.px, item.py = SpreadWeight(frame), 0, 0
            end
        end
    end
    -- Unused tail items: drop frame references and sort them last.
    for index = count + 1, math.max(spreadCount, #spreadItems) do
        local item = spreadItems[index]
        if item then
            item.frame, item.left = nil, math.huge
        end
    end
    spreadCount = count
    if count < 2 then
        return
    end

    -- Sweep: sorted by left edge, a pair can only overlap while the next box starts
    -- before this one's right edge, so most pairs are never compared.
    table.sort(spreadItems, ByLeftEdge)
    for i = 1, count - 1 do
        local a = spreadItems[i]
        local right = a.x + a.hw
        for j = i + 1, count do
            local b = spreadItems[j]
            if b.left >= right then
                break
            end
            local total = a.weight + b.weight
            if total > 0 then
                local dx, dy = b.x - a.x, b.y - a.y
                local overlapX = a.hw + b.hw - math.abs(dx)
                local overlapY = a.hh + b.hh - math.abs(dy)
                if overlapX > 0 and overlapY > 0 then
                    local shareA, shareB = a.weight / total, b.weight / total
                    if overlapY <= overlapX then
                        local dir = SpreadDirection(dy, a, b)
                        a.py, b.py = a.py - dir * overlapY * shareA, b.py + dir * overlapY * shareB
                    else
                        local dir = SpreadDirection(dx, a, b)
                        a.px, b.px = a.px - dir * overlapX * shareA, b.px + dir * overlapX * shareB
                    end
                end
            end
        end
    end

    local rate = math.min(1, dt * SPREAD_SPEED)
    for index = 1, count do
        local item = spreadItems[index]
        if item.px ~= 0 or item.py ~= 0 then
            local frame = item.frame
            local sx = (frame.spreadTX or 0) + item.px * rate
            local sy = (frame.spreadTY or 0) + item.py * rate
            local length = math.sqrt(sx * sx + sy * sy)
            if length > SPREAD_MAX then
                sx, sy = sx * SPREAD_MAX / length, sy * SPREAD_MAX / length
            end
            frame.spreadTX, frame.spreadTY = sx, sy
            frame.spreadX, frame.spreadY = frame.spreadX or 0, frame.spreadY or 0
        end
    end
end

-- Glide a number's shown spread offset toward its target, at most SPREAD_GLIDE px per second.
local function GlideSpread(frame, elapsed)
    local tx, ty = frame.spreadTX, frame.spreadTY
    if not tx then
        return
    end
    local dx, dy = tx - frame.spreadX, ty - frame.spreadY
    if dx == 0 and dy == 0 then
        return
    end
    local share = math.min(1, elapsed * SPREAD_EASE)
    local mx, my = dx * share, dy * share
    local step = math.sqrt(mx * mx + my * my)
    local limit = SPREAD_GLIDE * elapsed
    if step > limit then
        mx, my = mx * limit / step, my * limit / step
    end
    frame.spreadX, frame.spreadY = frame.spreadX + mx, frame.spreadY + my
end

local function ApplyFrameMotion(frame)
    local x, y, scale, alpha = ComputeMotion(frame)
    if frame.classicReady or frame.animMode == "impactSlam" then
        -- Keep placement in logical pixels while text size changes.
        frame:SetScale(scale)
        x, y = x / scale, y / scale
    end
    if frame.spreadX then
        -- The spread offset is in screen pixels; anchor offsets are scaled by the frame.
        local parentScale = frame:GetEffectiveScale() / math.max(0.01, frame:GetScale())
        local units = scale * parentScale
        x, y = x + frame.spreadX / units, y + frame.spreadY / units
    end
    local motionAnchor = frame.lingerHost or frame.anchor
    if motionAnchor then
        local relPoint = frame.lingerHost and "CENTER" or (frame.anchorRelPoint or "TOP")
        frame:ClearAllPoints()
        SafeSetPoint(frame, "CENTER", motionAnchor, relPoint, x, y)
    end
    frame:SetScale(scale)
    frame:SetAlpha(alpha)
    if frame.animMode == "impactSlam" and frame.critLabel then
        frame.critLabel:SetAlpha(Anim.ComputeImpactLabelAlpha(frame.elapsed))
    end
end

local function FrameOnUpdate(frame, elapsed)
    if IsClassicStyleFrame(frame) then
        frame.elapsed = math.max(0, GetTime() - frame.spawnTime)
    else
        frame.elapsed = frame.elapsed + elapsed
    end
    if frame.elapsed / frame.duration >= 1 then
        ReleaseFrame(frame)
        return
    end

    if frame.isPreview then
        if not frame.anchor or not AnchorIsShown(frame.anchor) then
            ReleaseFrame(frame)
            return
        end
    elseif not frame.incoming and not frame.lingerFrozen then
        -- Death / hide / reuse: freeze at last world pin so the number cannot
        -- ride a recycled plate. GUID check before rebind.
        if AnchorGuidChanged(frame) or not frame.anchor or not AnchorIsShown(frame.anchor) then
            FreezeLingerHost(frame)
        else
            -- Previous bind is still laid out - snapshot before we ClearAllPoints.
            SnapshotLingerHost(frame, true)
            BindLingerHostToPlate(frame, frame.anchor)
        end
    end

    MaybeRelayoutClassic()

    -- Separation is shared by every live number and rate-limited inside.
    local now = GetTime()
    if not frame.spreadSeeded then
        SeedSpread(frame, now)
    end
    RunSpread(now)
    GlideSpread(frame, elapsed)

    ApplyFrameMotion(frame)

    if not frame.incoming and not frame.isPreview and not frame.lingerFrozen then
        SnapshotLingerHost(frame, true)
    end
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
    spawnOrder = spawnOrder + 1
    frame.spawnOrder = spawnOrder
    frame.spawnTime = GetTime()
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
    ApplyMotion = ApplyFrameMotion,
    RelayerImpact = RelayerImpact,
    RelayoutClassic = RelayoutClassic,
    GetClassicPreviewBounds = GetClassicPreviewBounds,
    ReleasePreviewFrames = ReleasePreviewFrames,
    AttachLingerHost = AttachLingerHost,
    SnapshotLingerHost = SnapshotLingerHost,
}

function BD:OrphanFramesForUnit(unit)
    for frame in pairs(active) do
        if not frame.incoming and not frame.isPreview and not frame.lingerFrozen then
            local matches = frame.unitToken == unit
            if not matches then
                matches = GetPlateUnitToken(frame.anchor) == unit
            end
            if matches then
                FreezeLingerHost(frame)
            end
        end
    end
end

function BD:ReleaseFramesForUnit(unit)
    for frame in pairs(active) do
        if frame.unitToken == unit and not frame.incoming then
            ReleaseFrame(frame)
        end
    end
end
