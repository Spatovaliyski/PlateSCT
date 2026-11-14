local _, BD = ...
local Render = BD.Render

-- Nameplate layout: an outgoing number rises from its enemy's plate. A private helper frame
-- follows the plate while it lives and freezes in the world when it dies or is reused (Pool.lua).

local function PlaintextGuid(unit)
    local guid = UnitGUID(unit)
    if guid and BD.CanAccessValue(guid) and not BD.IsSecret(guid) then
        return guid
    end
    return nil
end

function BD:ShowOnNameplate(unit, text, r, g, b, amountForThreshold, isCrit, isHeal, spellIcon, hitKind, spellId,
    isAutoAttack)
    if not Render.PassesFilters(self, hitKind, isCrit, isHeal) then
        return
    end
    local plate = BD.GetNamePlateFrame(unit)
    if not plate then
        self:DebugPrint("No nameplate for", unit)
        return
    end
    if hitKind ~= "miss" and BD.Cap.OverPlateCap(plate, plate == BD.GetNamePlateFrame("target"), isCrit) then
        self:DebugPrint("number cap, skipped")
        return
    end

    local kind = hitKind
    if not kind then
        kind = isCrit and "crit" or "hit"
    end

    local combined, combineKey = Render.Combine(self, plate, kind, isHeal, spellIcon, spellId, amountForThreshold)
    if combined then
        return
    end

    local frame, preset, numberStyle = Render.Begin(self, kind, isCrit, isHeal, false)
    BD.Cap.TrackPlate(plate, frame)

    frame.anchor = plate
    frame.anchorRelPoint = "TOP"
    local baseX, baseY = 0, preset.spawnBaseY or 8
    if frame.animMode == "impactSlam" then
        baseX, baseY, frame.anchorRelPoint = Render.GetImpactPlacement(self, frame.impactSpacingScale)
    end
    -- Parent UIParent. Host follows the plate while live. Death/reuse freezes
    -- at last world pin (do not read the plate). anchorGuid only when plaintext;
    -- Modern secrets: orphan on hide / NAME_PLATE_UNIT_REMOVED (see API.lua).
    frame.anchorGuid = PlaintextGuid(unit)
    Render.ParentToScreen(frame, 100)
    frame.unitToken = unit
    BD.Pool.AttachLingerHost(frame, plate)

    if frame.isCrit and frame.critsHold then
        baseY = frame.spawnCritY or preset.spawnCritY or 8
    end

    r, g, b = Render.OutgoingColor(self, preset, r, g, b, isHeal, isAutoAttack)
    local icon = self:ResolveOutgoingSpellIcon(spellIcon, spellId)
    local fontSize, fontPath, layoutOpts = Render.Paint(self, frame, preset, numberStyle, text, r, g, b,
        amountForThreshold, icon)
    if not fontSize then
        return
    end
    if combineKey then
        Render.RememberCombine(self, frame, plate, combineKey, amountForThreshold, icon, fontSize, fontPath, preset,
            layoutOpts)
    end

    Render.Present(self, frame, plate, baseX, baseY)
    -- Layout exists now. Snapshot before death can hide the plate this frame.
    BD.Pool.SnapshotLingerHost(frame, true)

    if not isHeal and kind ~= "miss" then
        Render.CritSound(self, frame, amountForThreshold, combineKey)
    end
end
