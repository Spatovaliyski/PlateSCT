local ADDON_NAME, BD = ...
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

local function RefreshScenario()
    if BD.RefreshScenario then
        BD:RefreshScenario()
    end
end

local function ScreenMode()
    return BD.Layout.IsScreen()
end

-- Settings that only the current layout uses are hidden in the other one.
local function Supports(feature)
    return function() return BD.Layout.Supports(feature) end
end

local function NeedsEnemyNameplates()
    return BD.Layout.NeedsEnemyNameplates()
end

local function EnemyNameplatesEnabled()
    return BD.Layout.EnemyNameplatesShown()
end

local BuildPreferences

local function BuildCombat(parent, root)
    local layout = NewLayout(parent, root, "combat")
    layout:Heading(L["Display settings"])
    layout:Checkbox("onlyCriticalDamage", L["Show only critical damage"],
        L["Hide non-critical outgoing and incoming damage. Healing and miss text are unaffected."])
    layout:Checkbox("showMisses", L["Show misses and avoidance"],
        L["Show miss, dodge, parry, and similar text for outgoing and incoming attacks."])
    if IsModernAPI() then
        layout:When(function() return BD.db.onlyMyDamage and BD.db.showMisses end, function()
            layout:Warning(L["Personal mode can't tell whose attack missed, so misses, dodges, and parries from your attacks are hidden. Misses against you still show when Show incoming hits is on."])
        end)
    end

    layout:Heading(L["Outgoing"])
    if not IsModernAPI() then
        layout:Note(L["Shows your outgoing damage. Source is read from the combat log."])
    end
    layout:Checkbox("includePetDamage", L["Include pet damage"],
        IsModernAPI() and L["In Only my damage mode, also treat a recent pet cast as your hit."]
            or L["Also show damage from your pet and guardians."],
        PersonalModeAvailable, nil,
        L["Choose Personal - experimental under Modern API → Damage mode to use pet matching."])
    if IsModernAPI() then
        layout:When(function() return PersonalModeAvailable() and BD.db.includePetDamage end, function()
            layout:Warning(L["Pet damage is a best guess. The game no longer says which hits came from your pet, so PlateSCT counts hits that land right after your pet casts."])
        end)
    end

    layout:Heading(L["Incoming hits"])
    layout:Checkbox("showIncoming", L["Show incoming hits"], L["Incoming hits use screen areas in either layout."])

    layout:Heading(L["Healing"])
    layout:Checkbox("showHealing", L["Show healing"],
        L["Show your outgoing heals using the selected layout. Heals on you are skipped. Nameplate events require friendly nameplates."])
    layout:Note(L["Screen healing follows its destination area's motion. Fonts, icons, and filters are shared with damage."])

    layout:Heading(L["Reduce clutter"])
    layout:Input("minDamage", L["Minimum damage threshold"],
        L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."], function()
            BD:RebuildThresholdCurve()
        end)
    if IsModernAPI() then
        layout:Note(L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."])
    end

    layout:Heading(L["Combine hits"])
    layout:Checkbox("combineHits", L["Combine rapid hits"],
        L["Combine rapid hits against the same enemy into one number."])
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
    layout:Finish()
end

local function BuildAppearance(parent, root)
    local layout = NewLayout(parent, root, "appearance")
    layout:Heading(L["Outgoing font"])
    layout:Choice("fontFace", L["Font"], BD.GetFontFaceOptions(),
        L["Game fonts, plus SharedMedia fonts when that library is loaded by another addon."])
    layout:Note(L["Hover over a font to preview 12345."])
    layout:Slider("fontSize", L["Font size"], BD.MIN_FONT_SIZE, 48, 1, tostring)
    layout:When(function() return BD.db.showIncoming end, function()
        layout:Heading(L["Incoming font"])
        layout:Choice("incomingFontFace", L["Font"], BD.GetFontFaceOptions(),
            L["Game fonts, plus SharedMedia fonts when that library is loaded by another addon."])
        layout:Slider("incomingFontSize", L["Font size"], BD.MIN_FONT_SIZE, 48, 1, tostring)
    end)
    layout:Heading(L["Text style"])
    layout:Checkbox("useSchoolColors", L["Color by damage school"],
        L["Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."])
    layout:Heading(L["Critical text"])
    layout:Checkbox("showCritLabel", L["Show CRITICAL: scrolling styles"],
        L["Applies to non-Impact numbers in both layouts."])
    layout:Checkbox("showImpactCritLabel", L["Show CRITICAL: Impact"],
        L["Applies to Impact numbers in both layouts."])

    layout:Heading(L["Number formatting"])
    local function NumberFormat()
        if BD.db.abbreviate then return "abbreviated" end
        return BD.db.thousandSeparator ~= "none" and "separators" or "full"
    end
    layout:Choice({ id = "numberFormat", get = NumberFormat, set = function(value)
        BD.db.abbreviate = value == "abbreviated"
        if value == "full" then BD.db.thousandSeparator = "none"
        elseif value == "separators" and BD.db.thousandSeparator == "none" then BD.db.thousandSeparator = "comma" end
    end }, L["Number format"], {
        { id = "full", labelKey = "Full numbers" }, { id = "separators", labelKey = "Thousands separators" },
        { id = "abbreviated", labelKey = "Abbreviated" },
    })
    layout:When(function() return NumberFormat() == "separators" end, function()
        local separators = {}
        for _, option in ipairs(BD.THOUSAND_SEPARATORS) do
            if option.id ~= "none" then separators[#separators + 1] = option end
        end
        layout:Choice("thousandSeparator", L["Thousand separators"], separators, L["Group digits by thousands."])
    end)

    layout:Heading(L["Spell icons"])
    layout:Checkbox("showSpellIcon", L["Show spell icon"],
        IsModernAPI() and L["Display the spell's icon next to the damage number. Uses the matched cast or auto-attack."]
            or L["Display the spell's icon next to the damage number. Uses the spell from the combat log."],
        PersonalModeAvailable, nil,
        L["Choose Personal - experimental under Modern API → Damage mode to use spell icons."])
    if IsModernAPI() then
        layout:When(function() return PersonalModeAvailable() and BD.db.showSpellIcon end, function()
            layout:Warning(L["Spell icons are a best guess. The game no longer says which spell caused a hit, so PlateSCT uses your latest matching cast and may show the wrong icon."])
        end)
    end
    layout:When(function() return PersonalModeAvailable() and BD.db.showSpellIcon end, function()
        layout:Choice("iconPosition", L["Icon position"], BD.ICON_POSITIONS,
            L["Place the spell icon beside, above, or below the number."], function()
                return PersonalModeAvailable() and BD.db.showSpellIcon
            end, nil, L["Enable Show spell icon to choose its position."])
    end)
    if not IsModernAPI() then
        layout:Note(L["Spell icons use the spell from the combat log."])
    end
    layout:Finish()
end

local function BuildNameplateAnimation(layout)
    layout:Heading(L["Number style"])
    layout:Choice("numberStyle", L["Number style"], {
        { id = "retail", labelKey = "Modern number style" },
        { id = "classic", labelKey = "Classic number style" },
        { id = "impact", labelKey = "Impact number style" },
    }, L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."]
        .. "\n\n" .. L["Impact slams outgoing damage beside or above the nameplate, then floats up. New hits layer in front; crits amplify and CRITICAL flashes above when enabled."])
    layout:Note(L["All number styles are available on every supported WoW API."])
    layout:Note(L["Impact uses Modern motions for outgoing healing and misses. Incoming has its own area animation."])

    layout:Heading(L["Timing and movement"])
    layout:Slider("floatDistance", L["Scroll offset"], 10, 120, 5, PixelValue)
    layout:Slider("duration", L["Display duration"], 0.5, 4, 0.1,
        function(value) return string.format(L["%.1fs"], value) end)
    layout:Slider("scrollSpeed", L["Scroll speed"], 0.5, 3, 0.1,
        function(value) return string.format(L["%.1fx"], value) end)

    local modernMotion = function() return ModernNumberStyle() and BD.Layout.Supports("motionChoices") end
    layout:When(modernMotion, function()
        layout:Heading(L["Motion by outcome"])
        layout:Choice("animHit", L["Normal hits"], BD.ANIM_STYLES,
            L["Motion used for normal damage numbers."], modernMotion)
        layout:Choice("animCrit", L["Critical hits"], BD.ANIM_STYLES_CRIT,
            L["Motion used for critical hits. Classic Slap uses the Classic grow-and-settle pow."], modernMotion)
        layout:Choice("animMiss", L["Miss / Parry / Dodge"], BD.ANIM_STYLES,
            L["Motion used for miss, parry, dodge, and similar outcomes."], modernMotion)
    end)
end

local function BuildNameplatePlacement(layout)
    layout:When(Supports("styleOffsets"), function()
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
        }, L["X offset"], -200, 200, 1, PixelValue, Supports("styleOffsets"))
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
        }, L["Y offset"], -200, 200, 1, PixelValue, Supports("styleOffsets"))
        layout:Note(L["Offsets are saved separately for each number style. Positive X moves right; positive Y moves up. Incoming uses its own position controls."])
    end)

    local impactPlacement = function() return ImpactNumberStyle() and BD.Layout.Supports("impactStyle") end
    layout:When(impactPlacement, function()
        layout:Heading(L["Impact style position"])
        layout:Choice("impactPosition", L["Damage position"], {
            { id = "side", labelKey = "Side", recommended = true },
            { id = "top", labelKey = "Top" },
        }, L["Place Impact damage to the right of the nameplate or centered above it."], impactPlacement)
    end)
end

local function BuildAnimation(parent, root)
    local layout = NewLayout(parent, root, "animation")
    BD.OptionsAreas.BuildSelector(layout)
    layout:When(function() return not BD.OptionsAreas.UsesArea() end, function() BuildNameplateAnimation(layout) end)
    layout:When(BD.OptionsAreas.UsesArea, function() BD.OptionsAreas.BuildMotion(layout) end)
    layout:Finish()
end

local function BuildPlacement(parent, root)
    local layout = NewLayout(parent, root, "placement")
    BD.OptionsAreas.BuildSelector(layout)
    layout:When(function() return not BD.OptionsAreas.UsesArea() end, function() BuildNameplatePlacement(layout) end)
    layout:When(BD.OptionsAreas.UsesArea, function() BD.OptionsAreas.BuildPlacement(layout) end)
    layout:When(function() return BD.Layout.IsScreen() or BD.db.showIncoming end, function()
        layout:Heading(L["Routing"])
        BD.OptionsAreas.BuildRouting(layout)
    end)
    layout:Finish()
end

local MEDIA = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\UI\\"

local function BuildDisplayMode(layout)
    layout:Heading(L["Display mode"])
    layout:Note(L["Choose where your outgoing numbers appear. Incoming damage always uses screen areas."])
    layout:Cards("displayMode", {
        { id = "nameplates", title = L["Nameplates"], image = MEDIA .. "layout-nameplates.png",
            body = L["Numbers rise from each enemy's nameplate and follow it. Needs enemy nameplates."] },
        { id = "screen", title = L["Screen"], image = MEDIA .. "layout-screen.png",
            body = L["Numbers scroll through areas you place on the screen, like classic combat text addons."] },
    }, function() BD:RefreshScreenAreas() end)
    layout:When(function() return NeedsEnemyNameplates() and not EnemyNameplatesEnabled() end, function()
        layout:Warning(L["Enemy nameplates are off. Press V (default) to enable outgoing hits from nameplates."])
    end)
    layout:When(ScreenMode, function()
        if IsModernAPI() then
            layout:Warning(L["Midnight and Forever report damage only for enemies with nameplates, plus your target. Keep enemy nameplates on in Screen mode."])
        else
            layout:Note(L["Classic API clients read every hit from the combat log, so screen areas work with nameplates off."])
        end
        layout:Note(L["Configure placement, motion, and routing under Areas."])
    end)
end

local function BuildGeneral(parent, root)
    local layout = NewLayout(parent, root, "general")
    layout:Heading(L["General"])
    layout:Checkbox("enabled", L["Enable PlateSCT"], L["Show combat text using the selected layout."])
    BuildDisplayMode(layout)
    layout:Heading(L["Game integration"])
    layout:Checkbox("hideBlizzardFCT", L["Hide Blizzard floating combat text"],
        L["Turns off default in-world damage numbers."], nil, function(checked)
            if checked then BD:ApplyBlizzardFCTSetting() else BD:RestoreBlizzardFCTSetting() end
        end)
    layout:Checkbox("showMinimapButton", L["Show minimap button"], nil, nil, function() BD:RefreshMinimapButton() end)
    BuildPreferences(layout, root)
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
    layout:When(critEnabled, function()
        layout:Input("critSoundThreshold", L["Damage threshold"], thresholdTip, nil, critEnabled, critReason)
        layout:Choice("critSoundChannel", L["Channel"], BD.SOUND_CHANNELS,
            L["Which game sound channel plays this effect."], critEnabled, nil, critReason)
        layout:Action("playCrit", L["Play crit sound"], L["Preview this sound effect."], function()
            BD:PlayCritSoundPreview("crit")
        end)

    end)

    layout:Heading(L["Huge crit sound"])
    layout:Checkbox("hugeCritSoundEnabled", L["Enable huge crit sound"],
        L["Play a louder sound when an outgoing critical hit is above the huge damage threshold."])
    local hugeEnabled = function() return BD.db.hugeCritSoundEnabled end
    local hugeReason = L["Enable huge crit sound to adjust its threshold and channel."]
    layout:When(hugeEnabled, function()
        layout:Input("hugeCritSoundThreshold", L["Damage threshold"], thresholdTip, nil, hugeEnabled, hugeReason)
        layout:Choice("hugeCritSoundChannel", L["Channel"], BD.SOUND_CHANNELS,
            L["Which game sound channel plays this effect."], hugeEnabled, nil, hugeReason)
        layout:Action("playHugeCrit", L["Play huge crit sound"], L["Preview this sound effect."], function()
            BD:PlayCritSoundPreview("huge")
        end)
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
            label = label .. " |cffa39a8a(" .. L["Recommended"] .. ")|r"
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
    layout:When(function() return BD.db.onlyMyDamage end, function()
        layout:Warning(L["Personal mode estimates ownership from recent casts. Other players' hits may appear, and some of yours may be missed."])
    end)
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
    layout:When(function() return not BD.db.attributionAuto end, function()
        layout:Choice("attributionManual", L["Manual strictness"], StrictnessOptions(),
            L["Used when Auto-switch is off."], function() return not BD.db.attributionAuto end,
            RefreshScenario, L["Turn off Auto-switch by instance to choose manual strictness."])
    end)
    layout:When(function() return BD.db.attributionAuto end, function()
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
    end)
end

local function BuildSchools(layout, root)
    layout:Heading(L["Damage schools"])
    local enabled = function() return BD.db.schoolFilterEnabled end
    layout:Checkbox("schoolFilterEnabled", L["Filter by damage school"],
        L["Show damage from schools checked below. Same-school hits from other players can still appear. Secret or unreadable schools are always shown."],
        nil, function(checked)
            if checked and BD.db.schoolFilterRecommended then BD:ApplySchoolFilterRecommended() end
        end)
    layout:When(enabled, function()
        local recommended = layout:Checkbox("schoolFilterRecommended", BD:GetRecommendedSchoolFilterLabel(),
            L["Use the schools your class typically deals."], enabled, function(checked)
                if checked then BD:ApplySchoolFilterRecommended() end
            end)
        root.refreshers[#root.refreshers + 1] = function()
            recommended.label:SetText(BD:GetRecommendedSchoolFilterLabel())
        end
        layout:When(function() return not BD.db.schoolFilterRecommended end, function()
            for _, school in ipairs(BD.DAMAGE_SCHOOLS) do
                layout:Checkbox(school.dbKey, L[school.labelKey], L[school.labelKey], enabled, function()
                    BD.db.schoolFilterRecommended = BD:SchoolFilterMatchesClass()
                end)
            end
        end)
    end)
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

BuildPreferences = function(layout, root)
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
end

local function BuildTransfer(parent, root)
    local layout = NewLayout(parent, root, "transfer")
    layout:Heading(L["Import & Export"])
    layout:Note(L["Export a settings string to keep a backup or share your setup. Import a string to preview changes before applying them."])
    layout:Action("exportSettings", L["Export Settings"], L["Copy all settings supported by this client."], function()
        root:ShowSettingsTransfer(false)
    end)
    layout:Action("importSettings", L["Import Settings"], L["Preview and apply settings from a string."], function()
        root:ShowSettingsTransfer(true)
    end)
    layout:Finish()
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
    layout:Heading("1.2.5")
    layout:Heading(L["Show misses and avoidance"])
    layout:Note(L["Show or hide outgoing and incoming miss, dodge, parry, and similar text under Combat → Display settings. Enabled by default on Midnight and Classic APIs."])
    layout:Note(L["Midnight Personal mode still omits outgoing misses."])
    layout:Heading(L["Impact number style"])
    layout:Note(L["Impact now leaves room for CRITICAL labels, icons, and enlarged crits when stacking damage numbers."])
end

local function BuildHelp(parent, root, tabId)
    local layout = NewLayout(parent, root, "help", tabId)
    if tabId == "whatsNew" then
        BuildWhatsNew(layout)
    else
        layout:Heading(L["Settings guide"])
        for _, page in ipairs(BD.OptionsPages) do
            local heading = layout:Heading(page.label and page.label() or L[page.labelKey])
            if page.label then root.refreshers[#root.refreshers + 1] = function() heading:SetText(W.Title(page.label())) end end
            layout:Note(L[page.subtitleKey])
        end
    end
    layout:Finish()
end

BD.OptionsPages = {
    { id = "general", labelKey = "General", subtitleKey = "Choose your layout, language, and addon preferences.", build = BuildGeneral },
    { id = "combat", labelKey = "Combat", subtitleKey = "Choose what appears: damage, healing, incoming hits, and filters.", build = BuildCombat },
    { id = "appearance", labelKey = "Appearance", subtitleKey = "Set fonts, colors, number formatting, icons, and critical labels.", build = BuildAppearance },
    { id = "animation", labelKey = "Animation", subtitleKey = "Choose how numbers move, their timing, and critical-hit behavior.", build = BuildAnimation },
    { id = "placement", labelKey = "Placement", label = function() return L[BD.Layout.IsScreen() and "Areas" or "Placement"] end,
        subtitleKey = "Set positions, area sizes, spacing, alignment, and destinations.", build = BuildPlacement },
    { id = "sounds", labelKey = "Sounds", subtitleKey = "Configure critical-hit sounds, thresholds, and channels.", build = BuildSounds },
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
BD.OptionsUtilities = {
    { id = "help", labelKey = "Help", subtitleKey = "Find the right settings page and see what's new.",
        tabs = { { id = "guide", labelKey = "Settings guide" }, { id = "whatsNew", labelKey = "What's new?" } }, build = BuildHelp },
    { id = "diagnostics", labelKey = "Diagnostics", subtitleKey = "Client information and troubleshooting tools.",
        build = function(parent, root)
            local layout = NewLayout(parent, root, "diagnostics")
            BuildDiagnostics(layout)
            layout:Finish()
        end },
    { id = "transfer", labelKey = "Import & Export", subtitleKey = "Back up, share, or restore your settings.", build = BuildTransfer },
}
