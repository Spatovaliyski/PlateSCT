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
local CLASSIC_LAYOUT_PAD = 10
-- Crits: fill center / right / left / up / down around newest.
-- Normal classic hits use PickClearSpawn instead (AOE packs must spread).
local CLASSIC_HIT_COLUMNS = 3
local ROLLING_AVERAGE_WINDOW = 10
local ROLLING_AVERAGE_MAX_AGE = 8.0
-- Keep AOE spread near the plate; deconflict must not fling numbers off-screen.
local CLASSIC_AOE_MIN_DIST = 26
local CLASSIC_AOE_MIN_DIST_CRIT = 30
local CLASSIC_DECONFLICT_NEED = 30
local CLASSIC_MAX_DRIFT = 40

local damageSamples = {}
local rollingDamageAverage = 0
local lastClassicRelayoutTime = -1
-- Rotating spiral so simultaneous AOE hits never share one screen slot.
local classicFanIndex = 0
local CLASSIC_GOLDEN_ANGLE = 2.39996322972865332

-- Only crits use the classic grow-and-settle shove grid. Normal hits keep
-- their clear-spawn offsets so multi-target AOE does not pile in one stack.
local function IsClassicShoveFrame(frame)
    return frame.usesClassicShove
        and frame.animMode == "classicPow"
        and frame.isCrit
        and frame.critsHold
end

local function IsClassicStyleFrame(frame)
    return frame.usesClassicShove and frame.animMode == "classicPow" and not frame.incoming
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
    local baseY = center.classicBaseY or center.startY or 0

    for index, frame in ipairs(frames) do
        frame.classicHidden = false
        if index == 1 then
            frame.startX = baseX
            if isCritCluster then
                frame.startY = frame.classicBaseY or center.startY
            else
                frame.startY = baseY
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
            local slot = index - 1
            local row = math.floor(slot / CLASSIC_HIT_COLUMNS)
            local col = slot % CLASSIC_HIT_COLUMNS
            local xOff = 0
            if col == 1 then
                xOff = centerHalfW + selfHalfW + CLASSIC_LAYOUT_PAD
            elseif col == 2 then
                xOff = -(centerHalfW + selfHalfW + CLASSIC_LAYOUT_PAD)
            end
            local yOff = row * (centerHalfH * 2 + CLASSIC_LAYOUT_PAD)
            frame.startX = baseX + xOff
            frame.startY = baseY + yOff
        end
    end
end

local function RelayoutClassicAnchor(anchor)
    RelayoutClassicCluster(CollectClassicCluster(anchor, true), true)
    RelayoutClassicCluster(CollectClassicCluster(anchor, false), false)
end

local function ApplyClassicFramePoint(frame)
    local motionAnchor = frame.lingerHost or frame.anchor
    if not motionAnchor then
        return
    end
    local relPoint = frame.lingerHost and "CENTER" or (frame.anchorRelPoint or "TOP")
    frame:ClearAllPoints()
    pcall(frame.SetPoint, frame, "CENTER", motionAnchor, relPoint, frame.startX or 0, frame.startY or 0)
end

-- Never call GetCenter raw: measuring through a restricted nameplate errors/taints.
local function SafeFrameCenter(frame)
    if not frame then
        return nil, nil
    end
    local ok, x, y = pcall(frame.GetCenter, frame)
    if ok and x ~= nil and y ~= nil then
        return x, y
    end
    return nil, nil
end

local function ClampClassicDrift(frame)
    local bx = frame.classicBaseX or 0
    local by = frame.classicBaseY or 0
    local sx = frame.startX or 0
    local sy = frame.startY or 0
    local dx = sx - bx
    local dy = sy - by
    local distSq = dx * dx + dy * dy
    local maxD = CLASSIC_MAX_DRIFT
    if distSq > maxD * maxD and distSq > 0 then
        local dist = math.sqrt(distSq)
        frame.startX = bx + dx / dist * maxD
        frame.startY = by + dy / dist * maxD
    end
end

-- Soft push for overlapping Classic number-style hits only. Caps drift so
-- numbers stay near their plate. Modern number style never enters this path.
local function DeconflictClassicScreen()
    local list = {}
    for frame in pairs(active) do
        if IsClassicStyleFrame(frame) and not frame.classicHidden and not frame.isPreview then
            list[#list + 1] = frame
        end
    end
    if #list < 2 then
        return
    end

    for i = 1, #list do
        ApplyClassicFramePoint(list[i])
    end

    -- Prefer screen centers when every frame can be measured. If any plate
    -- chain is restricted, fall back to relative startX/startY only.
    local posX, posY = {}, {}
    local useScreen = true
    for i = 1, #list do
        local x, y = SafeFrameCenter(list[i])
        if not x then
            useScreen = false
            break
        end
        posX[i] = x
        posY[i] = y
    end
    if not useScreen then
        for i = 1, #list do
            posX[i] = list[i].startX or 0
            posY[i] = list[i].startY or 0
        end
    end

    local need = CLASSIC_DECONFLICT_NEED
    for _ = 1, 2 do
        local moved = false
        for i = 1, #list do
            local a = list[i]
            local ax, ay = posX[i], posY[i]
            for j = i + 1, #list do
                local b = list[j]
                local bx, by = posX[j], posY[j]
                local dx = ax - bx
                local dy = ay - by
                local distSq = dx * dx + dy * dy
                if distSq < 1 then
                    local angle = (a.classicFanIndex or i) * CLASSIC_GOLDEN_ANGLE
                    local push = need * 0.4
                    local px = math.cos(angle) * push
                    local py = math.sin(angle) * push
                    a.startX = (a.startX or 0) + px
                    a.startY = (a.startY or 0) + py
                    b.startX = (b.startX or 0) - px
                    b.startY = (b.startY or 0) - py
                    ClampClassicDrift(a)
                    ClampClassicDrift(b)
                    if useScreen then
                        posX[i] = ax + px
                        posY[i] = ay + py
                        posX[j] = bx - px
                        posY[j] = by - py
                    else
                        posX[i] = a.startX or 0
                        posY[i] = a.startY or 0
                        posX[j] = b.startX or 0
                        posY[j] = b.startY or 0
                    end
                    ax, ay = posX[i], posY[i]
                    moved = true
                elseif distSq < need * need then
                    local dist = math.sqrt(distSq)
                    local push = (need - dist) * 0.35
                    local nx = dx / dist
                    local ny = dy / dist
                    a.startX = (a.startX or 0) + nx * push
                    a.startY = (a.startY or 0) + ny * push
                    b.startX = (b.startX or 0) - nx * push
                    b.startY = (b.startY or 0) - ny * push
                    ClampClassicDrift(a)
                    ClampClassicDrift(b)
                    if useScreen then
                        posX[i] = ax + nx * push
                        posY[i] = ay + ny * push
                        posX[j] = bx - nx * push
                        posY[j] = by - ny * push
                    else
                        posX[i] = a.startX or 0
                        posY[i] = a.startY or 0
                        posX[j] = b.startX or 0
                        posY[j] = b.startY or 0
                    end
                    ax, ay = posX[i], posY[i]
                    moved = true
                end
            end
        end
        if not moved then
            break
        end
    end

    for i = 1, #list do
        ClampClassicDrift(list[i])
        ApplyClassicFramePoint(list[i])
    end
end

local function MaybeRelayoutClassic()
    local now = GetTime()
    if now == lastClassicRelayoutTime then
        return
    end
    lastClassicRelayoutTime = now

    local anchors = {}
    local hasClassic = false
    for frame in pairs(active) do
        if IsClassicStyleFrame(frame) then
            hasClassic = true
            if IsClassicShoveFrame(frame) and frame.anchor then
                anchors[frame.anchor] = true
            end
        end
    end
    for anchor in pairs(anchors) do
        RelayoutClassicAnchor(anchor)
    end
    if hasClassic then
        DeconflictClassicScreen()
    end
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
    if not worldScale or worldScale == 0 then
        return nil
    end
    local okScale, scale = pcall(region.GetEffectiveScale, region)
    if not okScale or not scale or scale == 0 then
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
    if not ok or left == nil or bottom == nil then
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
    if ok and x ~= nil and y ~= nil then
        return x * factor, y * factor
    end
    local left, bottom = ReadWorldBottomLeft(region)
    if left == nil then
        return nil
    end
    local okW, width = pcall(region.GetWidth, region)
    local okH, height = pcall(region.GetHeight, region)
    local w = ((okW and width) or 0) * factor
    local h = ((okH and height) or 0) * factor
    return left + w * 0.5, bottom + h * 0.5
end

local function StoreLingerWorldCenter(frame, x, y)
    if x ~= nil and y ~= nil then
        frame.lingerWorldX = x
        frame.lingerWorldY = y
    end
end

-- Read our frames first. Nameplate GetCenter is often nil on Classic *children*,
-- but the plate widget itself can still report a center while shown.
-- After reuse that center is the neighbor — allowPlate only while GUID matches.
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
            if factor and okH and height then
                cy = cy + height * factor * 0.5
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
    -- Classic-only reuse signal. Modern UnitGUID is often secret — ValuesNotEqual
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
    frame.classicFanIndex = nil
    frame.amountScale = nil
    frame.classicHidden = nil
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

--- acrossAnchors: also avoid numbers on other nameplates (AOE packs).
--- Uses a golden-angle spiral so packed plates still fan out on screen.
local function PickClearSpawn(anchor, frame, baseX, baseY, isCrit, acrossAnchors)
    local lanes = frame.spawnLanes or DEFAULT_SPAWN_LANES
    local minDist = isCrit and (frame.spawnMinDistCrit or 26) or (frame.spawnMinDist or 20)
    if acrossAnchors then
        minDist = math.max(minDist, isCrit and CLASSIC_AOE_MIN_DIST_CRIT or CLASSIC_AOE_MIN_DIST)
    end
    local minDistSq = minDist * minDist
    local jitter = frame.spawnJitter or 10

    if acrossAnchors then
        classicFanIndex = classicFanIndex + 1
        frame.classicFanIndex = classicFanIndex
        -- Tight spiral near the plate (about 10-36px), not screen-wide.
        for n = 0, 11 do
            local idx = classicFanIndex + n
            local angle = idx * CLASSIC_GOLDEN_ANGLE
            local ring = 10 + (n % 6) * 5
            local cx = baseX + math.cos(angle) * ring
            local cy = baseY + math.sin(angle) * ring
            if not SpawnSlotBlocked(frame, anchor, cx, cy, minDistSq, true) then
                return cx, cy
            end
        end
        local angle = classicFanIndex * CLASSIC_GOLDEN_ANGLE
        local ring = 14 + (classicFanIndex % 6) * 4
        return baseX + math.cos(angle) * ring, baseY + math.sin(angle) * ring
    end

    for _, lane in ipairs(lanes) do
        local cx = baseX + lane[1]
        local cy = baseY + lane[2]
        if not SpawnSlotBlocked(frame, anchor, cx, cy, minDistSq, false) then
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
            -- Previous bind is still laid out — snapshot before we ClearAllPoints.
            SnapshotLingerHost(frame, true)
            BindLingerHostToPlate(frame, frame.anchor)
        end
    end

    MaybeRelayoutClassic()

    local x, y, scale, alpha = ComputeMotion(frame)
    if frame.classicHidden then
        alpha = 0
    end
    local motionAnchor = frame.lingerHost or frame.anchor
    if motionAnchor then
        local relPoint = frame.lingerHost and "CENTER" or (frame.anchorRelPoint or "TOP")
        frame:ClearAllPoints()
        SafeSetPoint(frame, "CENTER", motionAnchor, relPoint, x, y)
    end
    frame:SetScale(scale)
    frame:SetAlpha(alpha)

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
    RelayoutClassic = function(anchor)
        RelayoutClassicAnchor(anchor)
        DeconflictClassicScreen()
    end,
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
