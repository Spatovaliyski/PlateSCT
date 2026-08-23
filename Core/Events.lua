local _, BD = ...

function BD:ResetToDefaults()
    for key, value in pairs(self.DEFAULTS) do
        if type(value) == "table" then
            if type(self.db[key]) ~= "table" then
                self.db[key] = {}
            end
            BD.CopyDefaults(self.db[key], value)
        else
            self.db[key] = value
        end
    end
    self:ApplyLocale()
    self:RebuildThresholdCurve()
    self:ApplyBlizzardFCTSetting()
    self:RefreshScenario()
    if self.ClearAttributionState then
        self:ClearAttributionState()
    end
    if self.RebuildOptionsPanel then
        self:RebuildOptionsPanel()
    elseif self.optionsPanel and self.optionsPanel.Refresh then
        self.optionsPanel:Refresh()
    end
end

local function ApplyLayoutMigrations()
    if (BD.db.layoutRevision or 1) < 2 then
        BD.db.fontSize = BD.DEFAULTS.fontSize
        BD.db.floatDistance = BD.DEFAULTS.floatDistance
        BD.db.duration = BD.DEFAULTS.duration
        BD.db.layoutRevision = 2
    end
    if (BD.db.layoutRevision or 1) < 3 then
        BD.db.allNameplates = true
        BD.db.layoutRevision = 3
    end
    if (BD.db.layoutRevision or 1) < 4 then
        if BD.db.onlyMyDamage then
            BD.db.allNameplates = false
        end
        BD.db.layoutRevision = 4
    end
    if (BD.db.layoutRevision or 1) < 5 then
        BD.db.attributionAuto = BD.DEFAULTS.attributionAuto
        BD.db.attributionManual = BD.DEFAULTS.attributionManual
        BD.db.attributionOpenWorld = BD.DEFAULTS.attributionOpenWorld
        BD.db.attributionDungeon = BD.DEFAULTS.attributionDungeon
        BD.db.attributionRaid = BD.DEFAULTS.attributionRaid
        BD.db.attributionBattleground = BD.DEFAULTS.attributionBattleground
        BD.db.attributionArena = BD.DEFAULTS.attributionArena
        BD.db.layoutRevision = 5
    end
    if (BD.db.layoutRevision or 1) < 6 then
        BD.db.animHit = BD.DEFAULTS.animHit
        BD.db.animCrit = BD.DEFAULTS.animCrit
        BD.db.animMiss = BD.DEFAULTS.animMiss
        BD.db.iconPosition = BD.DEFAULTS.iconPosition
        BD.db.showIncoming = BD.DEFAULTS.showIncoming
        BD.db.incomingOffsetX = BD.DEFAULTS.incomingOffsetX
        BD.db.incomingOffsetY = BD.DEFAULTS.incomingOffsetY
        BD.db.layoutRevision = 6
    end
    if (BD.db.layoutRevision or 1) < 7 then
        -- Match NameplateSCT: UIParent center fallback, not PlayerFrame.
        if BD.db.incomingOffsetY == nil or BD.db.incomingOffsetY == -36 then
            BD.db.incomingOffsetY = BD.DEFAULTS.incomingOffsetY
        end
        BD.db.layoutRevision = 7
    end
    if BD.db.onlyMyDamage then
        BD.db.allNameplates = false
    end
end

local trackFrame = CreateFrame("Frame")
pcall(function()
    trackFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
end)
pcall(function()
    trackFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player", "pet")
end)
pcall(function()
    trackFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player", "pet")
end)

trackFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "UNIT_SPELLCAST_SENT" then
        local unit, destName, castGUID, spellID = ...
        BD:NoteOutgoingSent(unit, destName, castGUID, spellID)
        return
    end
    if event == "UNIT_SPELLCAST_START" then
        local unit, castGUID, spellID = ...
        BD:NoteOutgoingStart(unit, castGUID, spellID)
        return
    end
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, castGUID, spellID = ...
        BD:NoteOutgoingSpell(unit, castGUID, spellID)
    end
end)

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        if not PlateSCTDB and BetterDamageDB then
            PlateSCTDB = BetterDamageDB
        end
        PlateSCTDB = BD.CopyDefaults(PlateSCTDB or {}, BD.DEFAULTS)
        BD.db = PlateSCTDB
        ApplyLayoutMigrations()
        BD:ApplyLocale()
        BD:RebuildThresholdCurve()
        BD:RefreshScenario()
        C_Timer.After(0, function()
            BD:ApplyBlizzardFCTSetting()
        end)
        return
    end

    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        BD:RefreshScenario()
        if event == "PLAYER_ENTERING_WORLD" then
            C_Timer.After(0, function()
                BD:ApplyBlizzardFCTSetting()
            end)
        end
        return
    end

    if event == "UNIT_COMBAT" then
        local unit, action, flagText, amount, schoolMask = ...
        BD:HandleUnitCombat(unit, action, flagText, amount, schoolMask)
        return
    end

    if event == "NAME_PLATE_UNIT_REMOVED" then
        local unit = ...
        BD:ReleaseFramesForUnit(unit)
    end
end)

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("UNIT_COMBAT")
eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
