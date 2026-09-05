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
    if BD.API.IsModern() and self.RefreshScenario then
        self:RefreshScenario()
    end
    if BD.API.IsModern() and self.ClearAttributionState then
        self:ClearAttributionState()
    end
    if self.RebuildOptionsPanel then
        self:RebuildOptionsPanel()
    elseif self.optionsPanel and self.optionsPanel.Refresh then
        self.optionsPanel:Refresh()
    end
    if self.RefreshMinimapButton then
        self:RefreshMinimapButton()
    end
end

local function ApplyLayoutMigrations()
    if (BD.db.layoutRevision or 1) < 2 then
        BD.db.fontSize = BD.DEFAULTS.fontSize
        BD.db.floatDistance = BD.DEFAULTS.floatDistance
        BD.db.duration = BD.DEFAULTS.duration
        BD.db.layoutRevision = 2
    end
    if BD.API.IsModern() then
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
        if BD.db.incomingOffsetY == nil or BD.db.incomingOffsetY == -36 then
            BD.db.incomingOffsetY = BD.DEFAULTS.incomingOffsetY
        end
        BD.db.layoutRevision = 7
    end
    if BD.API.IsClassic() and (BD.db.layoutRevision or 1) < 8 then
        if BD.db.fontSize == nil or BD.db.fontSize == 14 then
            BD.db.fontSize = BD.DEFAULTS.fontSize
        end
        BD.db.layoutRevision = 8
    end
    if (BD.db.layoutRevision or 1) < 9 then
        BD.db.abbreviate = false
        BD.db.layoutRevision = 9
    end
    if (BD.db.layoutRevision or 1) < 10 then
        if BD.db.thousandSeparators then
            BD.db.thousandSeparator = "comma"
        elseif BD.db.thousandSeparator == nil then
            BD.db.thousandSeparator = BD.DEFAULTS.thousandSeparator
        end
        BD.db.thousandSeparators = nil
        BD.db.layoutRevision = 10
    end
    if (BD.db.layoutRevision or 1) < 11 then
        if BD.db.showOptionsPreview == nil then
            BD.db.showOptionsPreview = BD.DEFAULTS.showOptionsPreview
        end
        BD.db.layoutRevision = 11
    end
    if (BD.db.layoutRevision or 1) < 12 then
        BD.db.layoutRevision = 12
    end
    if (BD.db.layoutRevision or 1) < 13 then
        -- Previous Raid recommended default was Strict; move to Very Strict.
        if BD.db.attributionRaid == nil or BD.db.attributionRaid == "strict" then
            BD.db.attributionRaid = BD.DEFAULTS.attributionRaid
        end
        BD.db.layoutRevision = 13
    end
    if BD.API.IsModern() and BD.db.onlyMyDamage then
        BD.db.allNameplates = false
    end
end

local trackFrame = CreateFrame("Frame")
if BD.API.IsModern() then
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
end

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
        if BD.API.IsModern() and BD.RefreshScenario then
            BD:RefreshScenario()
        end
        if BD.API.IsClassic() and BD.OnClassicPlayerLogin then
            BD:OnClassicPlayerLogin()
        end
        C_Timer.After(0, function()
            BD:ApplyBlizzardFCTSetting()
        end)
        return
    end

    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        if BD.API.IsModern() and BD.RefreshScenario then
            BD:RefreshScenario()
        end
        if BD.API.IsClassic() and event == "PLAYER_ENTERING_WORLD" and BD.OnClassicPlayerEnteringWorld then
            BD:OnClassicPlayerEnteringWorld()
        end
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

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        BD:HandleClassicCombatLog()
        return
    end

    if event == "NAME_PLATE_UNIT_ADDED" then
        local unit = ...
        BD:OnClassicNamePlateAdded(unit)
        return
    end

    if event == "UNIT_PET" then
        if BD.API.IsClassic() and BD.OnClassicPetChanged then
            BD:OnClassicPetChanged()
        end
        return
    end

    if event == "PET_ATTACK_START" then
        if BD.API.IsClassic() and BD.OnClassicPetChanged then
            BD:OnClassicPetChanged()
        end
        return
    end

    if event == "NAME_PLATE_UNIT_REMOVED" then
        local unit = ...
        if BD.API.IsClassic() and BD.OnClassicNamePlateRemoved then
            BD:OnClassicNamePlateRemoved(unit)
        else
            BD:OrphanFramesForUnit(unit)
        end
    end
end)

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

if BD.API.IsModern() then
    eventFrame:RegisterEvent("UNIT_COMBAT")
elseif BD.API.IsClassic() then
    eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    pcall(function()
        eventFrame:RegisterUnitEvent("UNIT_PET", "player")
    end)
    pcall(function()
        eventFrame:RegisterEvent("PET_ATTACK_START")
    end)
end
