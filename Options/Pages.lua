local _, BD = ...
local L = BD.L
local W = BD.OptionsWidgets

local TRANSLATION_ISSUES_URL = "https://github.com/Spatovaliyski/PlateSCT/issues"

StaticPopupDialogs["PLATESCT_TRANSLATION_ISSUES_URL"] = {
    text = L["Press Ctrl+C to copy the URL."],
    button1 = CLOSE,
    hasEditBox = true,
    editBoxWidth = 360,
    OnShow = function(self)
        local editBox = self.GetEditBox and self:GetEditBox() or self.editBox or self.EditBox
        editBox:SetText(TRANSLATION_ISSUES_URL)
        editBox:SetFocus()
        editBox:HighlightText()
    end,
    EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function IsModernAPI()
    return BD.API and BD.API.IsModern()
end

local function NewLayout(parent, root, pageId, tabId)
    return W.NewLayout(parent, root, pageId, tabId, parent:GetWidth())
end

local function PersonalModeAvailable()
    return not IsModernAPI() or BD.db.onlyMyDamage
end

local function ModernNumberStyle()
    return (BD.db.numberStyle or "retail") == "retail"
end

local function ImpactNumberStyle()
    return BD.db.numberStyle == "impact"
end

local function PixelValue(value)
    return string.format(L["%d px"], value)
end

local function PercentValue(value)
    return string.format(L["%d%%"], math.floor(value * 100 + 0.5))
end

local function RefreshScenario()
    if BD.RefreshScenario then
        BD:RefreshScenario()
    end
end

local function EnemyNameplatesEnabled()
    local reader = (C_CVar and (C_CVar.GetCVarBool or C_CVar.GetCVar)) or GetCVarBool or GetCVar
    if not reader then
        return true
    end
    local ok, enabled = pcall(reader, "nameplateShowEnemies")
    return not ok or enabled == nil or (enabled ~= false and enabled ~= "0" and enabled ~= 0)
end

-- On Modern only Engaged nameplates shows other enemies: Current target never does, and Personal
-- attributes hits only to the cast's target, so off-target styling would have nothing to style.
local function OffTargetAvailable()
    return not IsModernAPI() or (not BD.db.onlyMyDamage and BD.db.allNameplates)
end

local function BuildCombat(parent, root)
    local layout = NewLayout(parent, root, "combat")
    layout:Heading(L["Combat text"])
    layout:Checkbox("enabled", L["Enable PlateSCT"], L["Show floating damage numbers on nameplates."])
    layout:Checkbox("hideBlizzardFCT", L["Hide Blizzard floating combat text"],
        L["Turns off default in-world damage numbers."], nil, function(checked)
            if checked then
                BD:ApplyBlizzardFCTSetting()
            else
                BD:RestoreBlizzardFCTSetting()
            end
        end)
    layout:Checkbox("showMinimapButton", L["Show minimap button"],
        L["Show the PlateSCT icon on the minimap. Click it to open settings."], nil, function()
            BD:RefreshMinimapButton()
        end)

    local nameplateNote = layout:Note(L["PlateSCT needs enemy nameplates. Press V (default) or enable them in the game's nameplate settings."])
    root.refreshers[#root.refreshers + 1] = function()
        if EnemyNameplatesEnabled() then
            nameplateNote:SetTextColor(0.65, 0.61, 0.53)
        else
            nameplateNote:SetTextColor(1, 0.48, 0.25)
        end
    end

    layout:Heading(L["Who to show"])
    if IsModernAPI() then
        layout:Note(L["Choose whose damage to display under Modern API → Damage mode. Personal mode is experimental."])
    else
        layout:Note(L["Shows your damage on hostile nameplates. Source is read from the combat log."])
    end
    layout:Checkbox("includePetDamage", L["Include pet damage"],
        IsModernAPI() and L["In Only my damage mode, also treat a recent pet cast as your hit."]
            or L["Also show damage from your pet and guardians on nameplates."],
        PersonalModeAvailable, nil,
        L["Choose Personal - experimental under Modern API → Damage mode to use pet matching."])
    layout:Choice("offTargetMode", L["Other nameplates"], BD.OFF_TARGET_MODES,
        L["How numbers look on enemies you are not targeting. Dim makes them smaller and fainter so your target stands out."],
        OffTargetAvailable, nil, L["Only Engaged nameplates mode shows numbers on enemies you are not targeting. Change it under Modern API → Damage mode."])
    layout:When(function() return BD.db.offTargetMode == "dim" and OffTargetAvailable() end, function()
        layout:Slider("offTargetScale", L["Off-target size"], 0.4, 1, 0.05, PercentValue)
        layout:Slider("offTargetAlpha", L["Off-target opacity"], 0.1, 1, 0.05, PercentValue)
    end)

    layout:Heading(L["Healing"])
    layout:Checkbox("showHealing", L["Show healing"],
        L["Show your outgoing heals on the recipient's nameplate. Friendly nameplates must be enabled in the game."])
    layout:Note(L["Uses the same size, motion, duration, icons, and threshold as damage. Skips heals on you."])

    layout:Heading(L["Incoming"])
    layout:Checkbox("showIncoming", L["Show incoming hits"],
        L["Show damage you take near your character. Independent of the outgoing damage mode."])
    layout:Note(L["Uses your personal nameplate when available; otherwise floats near screen center."])
    local incomingEnabled = function() return BD.db.showIncoming end
    local incomingReason = L["Enable Show incoming hits to adjust its position."]
    layout:Slider("incomingOffsetX", L["Incoming X"], -200, 200, 2, PixelValue,
        incomingEnabled, nil, incomingReason)
    layout:Slider("incomingOffsetY", L["Incoming Y"], -200, 200, 2, PixelValue,
        incomingEnabled, nil, incomingReason)

    -- Everything that limits how many numbers appear lives under one heading.
    layout:Heading(L["Reduce clutter"])
    layout:Input("minDamage", L["Minimum damage threshold"],
        L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."], function()
            BD:RebuildThresholdCurve()
        end)
    layout:Note(L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."])
    if IsModernAPI() then
        layout:Note(L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."])
    end
    layout:Checkbox("critsOnly", L["Crits only"],
        L["Show only critical hits. Normal hits and heals are hidden; miss text such as Immune still shows."])
    layout:Checkbox("shrinkSmallHits", L["Shrink small hits"],
        L["Show hits well below your recent average smaller instead of hiding them."])
    layout:When(function() return BD.db.shrinkSmallHits end, function()
        layout:Slider("smallHitPercent", L["Small hit below"], 0.1, 0.9, 0.05, function(value)
            return string.format(L["%s of average"], PercentValue(value))
        end)
    end)

    layout:Checkbox("combineHits", L["Combine rapid hits"],
        L["Add hits that land in quick succession on the same nameplate into one number instead of stacking many."])
    layout:When(function() return BD.db.combineHits end, function()
        layout:Slider("combineWindow", L["Combine window"], 0.1, 1, 0.05,
            function(value) return string.format(L["%.2fs"], value) end)
        layout:Choice("combineMode", L["Combine"], BD.COMBINE_MODES,
            L["Same spell keeps each spell's number separate. All hits merges every hit on the target; its icon shows the spell that did the most damage."])
        layout:Checkbox("combineShowCount", L["Show hit count"],
            L["Show how many hits were combined, e.g. 37,200 (3). With spell icons on, the count sits on the icon."])
        layout:Checkbox("combinePulse", L["Pop on each merge"],
            L["Briefly enlarge the number every time another hit merges into it. Turn off for a calmer display."])
        layout:Note(IsModernAPI()
            and L["Crits, normal hits, and heals combine separately. Secret amounts cannot be added, so those hits still show individually."]
            or L["Crits, normal hits, and heals combine separately."])
    end)

    layout:Heading(L["Ignored spells"])
    layout:TextInput("ignoredSpells", L["Ignore these spells"],
        L["Spell names or IDs, separated by commas. Their hits, crits, and misses are not shown."])
    layout:Note(IsModernAPI()
        and L["Example: Auto Attack, 133. Modern API knows the spell only in Personal - experimental mode."]
        or L["Example: Auto Attack, 133."])
    layout:Finish()
end

local function BuildAppearance(parent, root)
    local layout = NewLayout(parent, root, "appearance")
    layout:Heading(L["Text style"])
    layout:Choice("fontFace", L["Font"], BD.GetFontFaceOptions(),
        L["Game fonts, plus SharedMedia fonts when that library is loaded by another addon."])
    layout:Note(L["Hover over a font to preview 12345."])
    layout:Note(L["Only fonts inside the WoW folder can load. SharedMedia fonts appear when another addon provides them."])
    layout:Slider("fontSize", L["Font size"], 10, 48, 1, tostring)
    layout:Checkbox("useSchoolColors", L["Color by damage school"],
        L["Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."])
    layout:Checkbox({
        id = "showCritLabel",
        get = function() return BD:GetCritLabelSetting() end,
        set = function(value)
            local _, key = BD:GetCritLabelSetting()
            BD.db[key] = value
        end,
    }, L["Show CRITICAL"],
        L["Show CRITICAL on critical hits. Impact saves its own choice, enabled by default."])

    layout:Heading(L["Number formatting"])
    layout:Checkbox("abbreviate", L["Abbreviate numbers"],
        L["Display large numbers as 214k or 1.2M. Disables thousand separators."])
    layout:Choice("thousandSeparator", L["Thousand separators"], BD.THOUSAND_SEPARATORS,
        L["Group digits by thousands."], function() return not BD.db.abbreviate end,
        nil, L["Unavailable while Abbreviate numbers is on."])

    layout:Heading(L["Spell icons"])
    layout:Checkbox("showSpellIcon", L["Show spell icon"],
        IsModernAPI() and L["Display the spell's icon next to the damage number. Uses the matched cast or auto-attack."]
            or L["Display the spell's icon next to the damage number. Uses the spell from the combat log."],
        PersonalModeAvailable, nil,
        L["Choose Personal - experimental under Modern API → Damage mode to use spell icons."])
    layout:Choice("iconPosition", L["Icon position"], BD.ICON_POSITIONS,
        L["Place the spell icon beside, above, or below the number."], function()
            return PersonalModeAvailable() and BD.db.showSpellIcon
        end, nil, L["Enable Show spell icon to choose its position."])
    layout:Note(IsModernAPI()
        and L["Spell icons use matched casts in Personal mode; Modern API cannot identify a spell for every hit."]
        or L["Spell icons use the spell from the combat log."])
    layout:Finish()
end

local function BuildAnimation(parent, root)
    local layout = NewLayout(parent, root, "animation")
    layout:Heading(L["Number style"])
    layout:Choice("numberStyle", L["Number style"], {
        { id = "retail", labelKey = "Modern number style" },
        { id = "classic", labelKey = "Classic number style" },
        { id = "impact", labelKey = "Impact number style" },
    }, L["All number styles are available on every supported WoW API."])
    layout:Note(L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."])
    layout:Note(L["Impact slams outgoing damage beside or above the nameplate, then floats up. New hits layer in front; crits amplify and CRITICAL flashes above when enabled."])
    layout:Note(L["Impact uses Modern for incoming damage, healing, and miss text, preserving saved Modern motions."])

    layout:Heading(L["Number position"])
    layout:Slider({
        id = "numberOffsetX",
        get = function()
            local x = BD:GetNumberStyleOffsets()
            return x
        end,
        set = function(value)
            local _, _, key = BD:GetNumberStyleOffsets()
            BD.db[key] = value
        end,
    }, L["X offset"], -200, 200, 1, PixelValue)
    layout:Slider({
        id = "numberOffsetY",
        get = function()
            local _, y = BD:GetNumberStyleOffsets()
            return y
        end,
        set = function(value)
            local _, _, _, key = BD:GetNumberStyleOffsets()
            BD.db[key] = value
        end,
    }, L["Y offset"], -200, 200, 1, PixelValue)
    layout:Note(L["Offsets are saved separately for each number style. Positive X moves right; positive Y moves up. Incoming uses its own position controls."])

    layout:Heading(L["Timing and movement"])
    layout:Slider("floatDistance", L["Scroll offset"], 10, 120, 5, PixelValue)
    layout:Slider("duration", L["Display duration"], 0.5, 4, 0.1,
        function(value) return string.format(L["%.1fs"], value) end)
    layout:Slider("scrollSpeed", L["Scroll speed"], 0.5, 3, 0.1,
        function(value) return string.format(L["%.1fx"], value) end)

    layout:When(ModernNumberStyle, function()
        layout:Heading(L["Modern number style motion"])
        layout:Choice("animHit", L["Normal hits"], BD.ANIM_STYLES,
            L["Motion used for normal damage numbers."], ModernNumberStyle)
        layout:Choice("animCrit", L["Critical hits"], BD.ANIM_STYLES_CRIT,
            L["Motion used for critical hits. Classic Slap uses the Classic grow-and-settle pow."], ModernNumberStyle)
        layout:Choice("animMiss", L["Miss / Parry / Dodge"], BD.ANIM_STYLES,
            L["Motion used for miss, parry, dodge, and similar outcomes."], ModernNumberStyle)
    end)
    layout:When(ImpactNumberStyle, function()
        layout:Heading(L["Impact style position"])
        layout:Choice("impactPosition", L["Damage position"], {
            { id = "side", labelKey = "Side", recommended = true },
            { id = "top", labelKey = "Top" },
        }, L["Place Impact damage to the right of the nameplate or centered above it."], ImpactNumberStyle)
    end)
    layout:Finish()
end

local function BuildSounds(parent, root)
    local layout = NewLayout(parent, root, "sounds")
    layout:Note(L["Outgoing critical hits play a sound when damage is above the threshold you type. Huge crit takes priority over the normal crit sound."])
    if IsModernAPI() then
        layout:Note(L["Modern API: unreadable damage amounts cannot trigger threshold sounds."])
    end
    local thresholdTip = L["Supports k/m suffixes, e.g. 20k or 2m. The critical strike damage must be higher than this value."]

    layout:Heading(L["Crit sound"])
    layout:Checkbox("critSoundEnabled", L["Enable crit sound"],
        L["Play a sound when an outgoing critical hit is above the damage threshold."])
    local critEnabled = function() return BD.db.critSoundEnabled end
    local critReason = L["Enable crit sound to adjust its threshold and channel."]
    layout:Input("critSoundThreshold", L["Damage threshold"], thresholdTip, nil, critEnabled, critReason)
    layout:Choice("critSoundChannel", L["Channel"], BD.SOUND_CHANNELS,
        L["Which game sound channel plays this effect."], critEnabled, nil, critReason)
    layout:Action("playCrit", L["Play crit sound"], L["Preview this sound effect."], function()
        BD:PlayCritSoundPreview("crit")
    end)

    layout:Heading(L["Huge crit sound"])
    layout:Checkbox("hugeCritSoundEnabled", L["Enable huge crit sound"],
        L["Play a louder sound when an outgoing critical hit is above the huge damage threshold."])
    local hugeEnabled = function() return BD.db.hugeCritSoundEnabled end
    local hugeReason = L["Enable huge crit sound to adjust its threshold and channel."]
    layout:Input("hugeCritSoundThreshold", L["Damage threshold"], thresholdTip, nil, hugeEnabled, hugeReason)
    layout:Choice("hugeCritSoundChannel", L["Channel"], BD.SOUND_CHANNELS,
        L["Which game sound channel plays this effect."], hugeEnabled, nil, hugeReason)
    layout:Action("playHugeCrit", L["Play huge crit sound"], L["Preview this sound effect."], function()
        BD:PlayCritSoundPreview("huge")
    end)
    layout:Finish()
end

local damageMode = {
    id = "damageMode",
    get = function()
        if BD.db.onlyMyDamage then return "personal" end
        return BD.db.allNameplates and "engaged" or "target"
    end,
    set = function(value)
        BD.db.onlyMyDamage = value == "personal"
        BD.db.allNameplates = value == "engaged"
    end,
}

local strictnessKeys = {
    loose = "Loose", balanced = "Balanced", strict = "Strict", veryStrict = "Very Strict",
}
local scenarioKeys = {
    openWorld = "Open world", dungeon = "Dungeon", raid = "Raid",
    battleground = "Battleground", arena = "Arena",
}

local function StrictnessOptions(recommended)
    local options = {}
    for _, id in ipairs({ "loose", "balanced", "strict", "veryStrict" }) do
        local label = L[strictnessKeys[id]]
        if id == recommended then
            label = label .. " |cffffcc00(" .. L["Recommended"] .. ")|r"
        end
        options[#options + 1] = { id = id, label = label }
    end
    return options
end

local function BuildModernMode(layout)
    layout:Heading(L["Damage mode"])
    local control = layout:Choice(damageMode, L["Damage mode"], {
        { id = "personal", labelKey = "Personal - experimental" },
        { id = "target", labelKey = "Current target" },
        { id = "engaged", labelKey = "Engaged nameplates" },
    }, L["Personal matches recent casts. Current target and Engaged nameplates show damage from all sources."])
    control.searchAliases = { L["Only my damage"], L["All engaged nameplates"] }
    layout:Note(L["Personal - experimental: best-effort matching by destination and timing. Other players' hits on the same target can appear."])
    layout:Note(L["Current target: all-source numbers on your target. Engaged nameplates: all-source numbers on engaged enemies."])
    layout:Heading(L["Attribution limitations"])
    layout:Note(L["Best effort: matches your casts to nameplates by destination and timing. Dest-matched cleave can show. Other players on the same target can still appear. Mythic+ uses the Dungeon profile."])
    layout:Note(L["Pet matching and spell icons require Personal mode. Choose their appearance and visibility under Combat and Appearance."])
end

local function BuildAttribution(layout, root)
    layout:Heading(L["Attribution profiles"])
    layout:Note(L["How strict PlateSCT is when guessing which hits are yours. Auto-switch follows the instance type."])
    layout:Note(L["Profiles affect Personal mode. They cannot prove who dealt a hit on Modern API."])
    local readout = layout:Note(L["Active: %s (%s)"])
    readout:SetTextColor(1, 0.82, 0.45)
    root.refreshers[#root.refreshers + 1] = function()
        RefreshScenario()
        local scenario = BD.scenario or "openWorld"
        local strictness = BD:GetActiveStrictnessId()
        readout:SetText(string.format(L["Active: %s (%s)"],
            L[scenarioKeys[scenario] or "Open world"], L[strictnessKeys[strictness] or "Balanced"]))
    end
    layout:Checkbox("attributionAuto", L["Auto-switch by instance"],
        L["Pick Open world, Dungeon, Raid, Battleground, or Arena settings from the zone you are in."],
        nil, RefreshScenario)
    layout:Choice("attributionManual", L["Manual strictness"], StrictnessOptions(),
        L["Used when Auto-switch is off."], function() return not BD.db.attributionAuto end,
        RefreshScenario, L["Turn off Auto-switch by instance to choose manual strictness."])
    layout:Heading(L["Instance profiles"])
    local profiles = {
        { "attributionOpenWorld", "Open world", "Loose: longer windows, more numbers.", "loose" },
        { "attributionDungeon", "Dungeon", "Balanced: medium windows and cleave hits.", "balanced" },
        { "attributionRaid", "Raid", "Very Strict: shortest windows, destination required, one hit per cast.", "veryStrict" },
        { "attributionBattleground", "Battleground", "Strict: short windows, fewer foreign hits.", "strict" },
        { "attributionArena", "Arena", "Balanced: medium windows and cleave hits.", "balanced" },
    }
    for _, profile in ipairs(profiles) do
        layout:Choice(profile[1], L[profile[2]], StrictnessOptions(profile[4]), L[profile[3]],
            function() return BD.db.attributionAuto end, RefreshScenario,
            L["Enable Auto-switch by instance to edit the instance profiles."])
    end
end

local function BuildSchools(layout, root)
    layout:Heading(L["Damage schools"])
    layout:Note(L["Show damage from schools checked below. Same-school hits from other players can still appear. Secret or unreadable schools are always shown."])
    layout:Checkbox("schoolFilterEnabled", L["Filter by damage school"],
        L["Show damage from schools checked below. Same-school hits from other players can still appear. Secret or unreadable schools are always shown."],
        nil, function(checked)
            if checked and BD.db.schoolFilterRecommended then BD:ApplySchoolFilterRecommended() end
        end)
    local schoolEnabled = function() return BD.db.schoolFilterEnabled end
    local schoolReason = L["Enable Filter by damage school to choose allowed schools."]
    local recommended = layout:Checkbox("schoolFilterRecommended", BD:GetRecommendedSchoolFilterLabel(),
        L["Use the schools your class typically deals."], schoolEnabled, function(checked)
            if checked then BD:ApplySchoolFilterRecommended() end
        end, schoolReason)
    root.refreshers[#root.refreshers + 1] = function()
        recommended.label:SetText(BD:GetRecommendedSchoolFilterLabel())
    end
    for _, school in ipairs(BD.DAMAGE_SCHOOLS) do
        layout:Checkbox(school.dbKey, L[school.labelKey], L[school.labelKey], schoolEnabled, function()
            BD.db.schoolFilterRecommended = BD:SchoolFilterMatchesClass()
        end, schoolReason)
    end
end

local function BuildModern(parent, root, tabId)
    local layout = NewLayout(parent, root, "modern", tabId)
    if tabId == "attribution" then
        BuildAttribution(layout, root)
    elseif tabId == "schools" then
        BuildSchools(layout, root)
    else
        BuildModernMode(layout)
    end
    layout:Finish()
end

local function BuildPreferences(layout, root)
    layout:Heading(L["Language"])
    local localeOptions = {}
    for _, option in ipairs(BD.LOCALE_OPTIONS) do
        localeOptions[#localeOptions + 1] = { id = option.id, label = BD:GetLocaleOptionLabel(option) }
    end
    layout:Choice({ id = "locale", get = function() return BD.db.locale end,
        set = function(value) BD:SetLocalePreference(value) end },
        L["Language"], localeOptions, L["Choose the language used by PlateSCT panels and messages."])
    local localeCode = BD:ResolveLocaleCode()
    if localeCode == "zhCN" or localeCode == "zhTW" or localeCode == "koKR" then
        layout:Note(L["This translation was generated with AI. If you find inconsistent terminology or incorrect wording, please report it through GitHub Issues. Thank you for your help! Translation contributors will be credited."])
        layout:Action("translationIssues", L["Open Link"],
            L["Press Ctrl+C to copy the URL."], function()
                StaticPopup_Show("PLATESCT_TRANSLATION_ISSUES_URL")
            end)
    end
    layout:Heading(L["Settings window"])
    layout:Checkbox("settingsAnimations", L["Animate settings"],
        L["Use gentle fades and row reveals in this settings window. Combat animation is unaffected."])
    layout:Checkbox("showOptionsPreview", L["Show live preview"],
        L["Show sample hits, crits, and misses in the bottom preview drawer."])
    layout:Note(L["The preview shows appearance only. It does not prove attribution or simulate damage filtering."])
    layout:Action("testTarget", L["Test on Target"], L["Show sample damage numbers on your target."], function()
        BD:ShowTestNumbers()
    end)
    layout:Heading(L["Maintenance"])
    layout:Action("resetDefaults", L["Reset Defaults"], L["Restore every PlateSCT setting to its default."], function()
        root:ConfirmReset()
    end)
end

local function BuildDiagnostics(layout)
    layout:Heading(L["Your WoW API"])
    if IsModernAPI() then
        layout:Note(L["Modern API - Midnight & Forever"])
        layout:Note(L["Modern clients restrict combat information. Personal mode estimates ownership; all-source modes display target or engaged-nameplate damage."])
        layout:Note(L["Unreadable amounts cannot trigger threshold sounds. Unreadable damage schools are always allowed by the school filter."])
    else
        layout:Note(L["Classic API - Era/TBC/Wrath/MoP"])
        layout:Note(L["Classic clients read damage ownership and spells directly from the combat log. Modern attribution and school-filter options do not apply."])
    end
    layout:Heading(L["Diagnostics"])
    layout:Checkbox("debug", L["Debug mode"], L["Print combat events to chat for troubleshooting."])
    if IsModernAPI() then
        layout:Note(C_DamageMeter and C_DamageMeter.GetCombatSessionSourceFromType
            and L["Damage meter probe is available. Capture a snapshot while hitting a target."]
            or L["This client does not expose the damage meter API. A snapshot can still report which fields are unavailable."])
        layout:Action("dumpMeter", L["Dump meter now"],
            L["Open a copyable snapshot of C_DamageMeter fields. Use this in combat while hitting a target."], function()
                BD:DumpDamageMeterProbe()
            end)
    end
end

local function BuildWhatsNew(layout)
    layout:Heading(L["Less clutter"])
    layout:Note(L["Dim or hide numbers on enemies you are not targeting, show crits only, shrink small hits, and ignore chosen spells. Find them on the Combat page."])
    layout:Heading(L["Combine hits"])
    layout:Note(L["Rapid hits on the same nameplate can merge into one growing number with a hit count. Turn it on under Combat → Combine hits."])
    layout:Heading(L["Impact number style"])
    layout:Note(L["Impact slams outgoing damage beside or above the nameplate, then floats up. New hits layer in front; crits amplify and CRITICAL flashes above when enabled."])
    layout:Note(L["Impact uses Modern for incoming damage, healing, and miss text, preserving saved Modern motions."])
    layout:Heading(L["Settings redesign"])
    layout:Note(L["A new WoW-inspired settings window with clear sections, searchable controls, and gentle animations."])
    layout:Note(L["Modern API options now have their own page. Damage mode combines Only my damage and All engaged nameplates without changing saved preferences."])
    layout:Note(L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. All number styles remain available on every API."])
    layout:Heading(L["Existing features"])
    layout:Note(L["Outgoing healing, incoming damage, font selection, scroll speed, school colors, spell icons, and critical-hit sounds remain available."])
end

local function BuildHelp(parent, root, tabId)
    local layout = NewLayout(parent, root, "help", tabId)
    if tabId == "diagnostics" then
        BuildDiagnostics(layout)
    elseif tabId == "whatsNew" then
        BuildWhatsNew(layout)
    else
        BuildPreferences(layout, root)
    end
    layout:Finish()
end

BD.OptionsPages = {
    { id = "combat", labelKey = "Combat", subtitleKey = "Choose the combat text you want to see.", build = BuildCombat },
    { id = "appearance", labelKey = "Appearance", subtitleKey = "Fonts, colors, numbers, and spell icons.", build = BuildAppearance },
    { id = "animation", labelKey = "Animation", subtitleKey = "Number style, timing, and movement.", build = BuildAnimation },
    { id = "sounds", labelKey = "Sounds", subtitleKey = "Audio cues for outgoing critical hits.", build = BuildSounds },
}
if IsModernAPI() then
    BD.OptionsPages[#BD.OptionsPages + 1] = {
        id = "modern", labelKey = "Modern API", subtitleKey = "Midnight & Forever damage modes and attribution.",
        tabs = {
            { id = "mode", labelKey = "Damage mode" },
            { id = "attribution", labelKey = "Attribution" },
            { id = "schools", labelKey = "Schools" },
        }, build = BuildModern,
    }
end
BD.OptionsPages[#BD.OptionsPages + 1] = {
    id = "help", labelKey = "Help & Settings", subtitleKey = "Preferences, API information, and diagnostics.",
    tabs = {
        { id = "preferences", labelKey = "Preferences" },
        { id = "diagnostics", labelKey = "Diagnostics" },
        { id = "whatsNew", labelKey = "What's new?" },
    }, build = BuildHelp,
}
