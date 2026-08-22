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
    if self.RebuildOptionsPanel then
        self:RebuildOptionsPanel()
    elseif self.optionsPanel and self.optionsPanel.Refresh then
        self.optionsPanel:Refresh()
    end
end

local trackFrame = CreateFrame("Frame")
pcall(function()
    trackFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player", "pet")
end)

trackFrame:SetScript("OnEvent", function(_, event, unit, _, spellID)
    if event ~= "UNIT_SPELLCAST_SUCCEEDED" then
        return
    end
    BD:NoteOutgoingSpell(unit, spellID)
end)

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        if not PlateSCTDB and BetterDamageDB then
            PlateSCTDB = BetterDamageDB
        end
        PlateSCTDB = BD.CopyDefaults(PlateSCTDB or {}, BD.DEFAULTS)
        BD.db = PlateSCTDB
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
        if BD.db.onlyMyDamage then
            BD.db.allNameplates = false
        end
        BD:ApplyLocale()
        BD:RebuildThresholdCurve()
        C_Timer.After(0, function()
            BD:ApplyBlizzardFCTSetting()
        end)
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(0, function()
            BD:ApplyBlizzardFCTSetting()
        end)
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
eventFrame:RegisterEvent("UNIT_COMBAT")
eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
