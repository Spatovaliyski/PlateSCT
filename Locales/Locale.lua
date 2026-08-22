local _, BD = ...

BD.LocaleTables = BD.LocaleTables or {}

-- Preference values stored in BD.db.locale. "auto" follows the game client.
BD.LOCALE_OPTIONS = {
    { id = "auto", labelKey = "Auto" },
    { id = "enUS", label = "English" },
    { id = "frFR", label = "Français" },
    { id = "deDE", label = "Deutsch" },
    { id = "esES", label = "Español" },
    { id = "ruRU", label = "Русский" },
    { id = "itIT", label = "Italiano" },
    { id = "ptBR", label = "Português" },
}

local active = {}

local L = setmetatable({}, {
    __index = function(_, key)
        local value = active[key]
        if value ~= nil then
            return value
        end
        local en = BD.LocaleTables.enUS and BD.LocaleTables.enUS[key]
        if en ~= nil then
            return en
        end
        return key
    end,
})

BD.L = L

function BD.RegisterLocale(code, strings)
    BD.LocaleTables[code] = strings
end

function BD:NormalizeLocaleCode(code)
    if not code or code == "" or code == "auto" then
        return "auto"
    end
    if code == "esMX" then
        return "esES"
    end
    if code == "enGB" then
        return "enUS"
    end
    if code == "ptPT" then
        return "ptBR"
    end
    return code
end

function BD:ResolveLocaleCode(preference)
    local code = self:NormalizeLocaleCode(preference or (self.db and self.db.locale) or "auto")
    if code == "auto" then
        code = self:NormalizeLocaleCode(GetLocale())
        if code == "auto" then
            code = "enUS"
        end
    end
    if BD.LocaleTables[code] then
        return code
    end
    return "enUS"
end

function BD:GetLocaleOptionLabel(option)
    if option.label then
        return option.label
    end
    if option.labelKey then
        return L[option.labelKey]
    end
    return option.id
end

function BD:GetLocaleLabelForCode(code)
    code = self:NormalizeLocaleCode(code)
    for _, option in ipairs(self.LOCALE_OPTIONS) do
        if option.id == code then
            return self:GetLocaleOptionLabel(option)
        end
    end
    return code
end

function BD:GetLocalePreferenceLabel(preference)
    preference = self:NormalizeLocaleCode(preference or (self.db and self.db.locale) or "auto")
    if preference == "auto" then
        return L["Auto"] .. " + " .. self:GetLocaleLabelForCode(self:ResolveLocaleCode("auto"))
    end
    return self:GetLocaleLabelForCode(preference)
end

function BD:ApplyLocale(preference)
    if preference ~= nil and self.db then
        self.db.locale = self:NormalizeLocaleCode(preference)
    end

    local code = self:ResolveLocaleCode()
    active = BD.LocaleTables[code] or BD.LocaleTables.enUS or {}

    local popup = StaticPopupDialogs and StaticPopupDialogs["PLATESCT_RESET_CONFIRM"]
    if popup then
        popup.text = L["Reset PlateSCT settings to defaults?"]
    end

    local stub = self.settingsStubTexts
    if stub then
        if stub.body then
            stub.body:SetText(L["PlateSCT uses its own settings window.\n\nType /platesct in chat, or click the button below."])
        end
        if stub.open then
            stub.open:SetText(L["Open PlateSCT"])
        end
    end

    return code
end

function BD:SetLocalePreference(preference)
    preference = self:NormalizeLocaleCode(preference or "auto")
    if self.db then
        self.db.locale = preference
    end
    self:ApplyLocale(preference)
    if self.RebuildOptionsPanel then
        self:RebuildOptionsPanel()
    end
end
