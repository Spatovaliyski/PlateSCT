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
    frame.iconCount:SetText("")
    frame.iconCount:Hide()
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
    frame.spawnTime = nil
    frame.lingerFrozen = nil
    frame.lingerWorldX = nil
    frame.lingerWorldY = nil
    frame.anchorGuid = nil
    frame.combineKey = nil
    frame.combineTotal = nil
    frame.combineCount = nil
    frame.combineLayout = nil
    frame.combinePulseAt = nil
    frame.combineSources = nil
    frame.combineTopIcon = nil
    frame.combineSoundTier = nil
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

local function ApplyFrameMotion(frame)
    local x, y, scale, alpha = ComputeMotion(frame)
    -- Combined hit landed: brief scale pulse so the growing total reads as new damage.
    if frame.combinePulseAt then
        local t = (frame.elapsed - frame.combinePulseAt) / BD.COMBINE_PULSE_DURATION
        if t < 1 then
            scale = scale * (1 + BD.COMBINE_PULSE_SCALE * (1 - t))
        else
            frame.combinePulseAt = nil
        end
    end
    if frame.classicReady or frame.animMode == "impactSlam" then
        -- Keep placement in logical pixels while text size changes.
        frame:SetScale(scale)
        x, y = x / scale, y / scale
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

    -- Combined hit count, drawn on the icon like an aura stack number.
    local iconCount = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    iconCount:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
    iconCount:SetJustifyH("RIGHT")
    iconCount:Hide()
    frame.iconCount = iconCount

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
