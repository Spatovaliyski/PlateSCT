local _, BD = ...

local L = {}
BD.RegisterLocale("enUS", L)

-- Number position and font preview
L["Number position"] = "Number position"
L["X offset"] = "X offset"
L["Y offset"] = "Y offset"
L["Offsets are saved separately for each number style. Positive X moves right; positive Y moves up. Incoming uses its own position controls."] = "Offsets are saved separately for each number style. Positive X moves right; positive Y moves up. Incoming uses its own position controls."
L["Hover over a font to preview 12345."] = "Hover over a font to preview 12345."
L["Press Ctrl+C to copy the URL."] = "Press Ctrl+C to copy the URL."
L["Open Link"] = "Open Link"

-- Translation feedback
L["This translation was generated with AI. If you find inconsistent terminology or incorrect wording, please report it through GitHub Issues. Thank you for your help! Translation contributors will be credited."] =
    "This translation was generated with AI. If you find inconsistent terminology or incorrect wording, please report it through GitHub Issues. Thank you for your help! Translation contributors will be credited."

-- Impact number style
L["Impact number style"] = "Impact number style"
L["All number styles are available on every supported WoW API."] = "All number styles are available on every supported WoW API."
L["Impact slams outgoing damage beside or above the nameplate, then floats up. New hits layer in front; crits amplify and CRITICAL flashes above when enabled."] = "Impact slams outgoing damage beside or above the nameplate, then floats up. New hits layer in front; crits amplify and CRITICAL flashes above when enabled."
L["Impact style position"] = "Impact style position"
L["Damage position"] = "Damage position"
L["Side"] = "Side"
L["Place Impact damage to the right of the nameplate or centered above it."] = "Place Impact damage to the right of the nameplate or centered above it."
L["Impact uses Modern for incoming damage, healing, and miss text, preserving saved Modern motions."] = "Impact uses Modern for incoming damage, healing, and miss text, preserving saved Modern motions."
L["Pick a motion for each hit type in Modern. Classic and Impact use their own damage animations."] = "Pick a motion for each hit type in Modern. Classic and Impact use their own damage animations."
L["Switch to Modern number style to customize these motions."] = "Switch to Modern number style to customize these motions."
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. All number styles remain available on every API."] = "The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. All number styles remain available on every API."

-- Titles / meta
L["PlateSCT is in Beta"] = "PlateSCT is in Beta"
L["This addon is in Beta mode. Inaccuracies and errors may show up. Please report such issues on the addon's page."] =
    "This addon is in Beta mode. Inaccuracies and errors may show up. Please report such issues on the addon's page."
L["Reset PlateSCT settings to defaults?"] = "Reset PlateSCT settings to defaults?"
L["Addon page"] = "Addon page"
L["Select the URL below, copy it, then paste it in your browser."] =
    "Select the URL below, copy it, then paste it in your browser."
L["Click to open the addon page URL."] = "Click to open the addon page URL."
L["/platesct  ·  ESC to close"] = "/platesct  ·  ESC to close"
L["PlateSCT uses its own settings window.\n\nType /platesct in chat, or click the button below."] =
    "PlateSCT uses its own settings window.\n\nType /platesct in chat, or click the button below."
L["Open PlateSCT"] = "Open PlateSCT"
L["Target something to preview test numbers."] = "Target something to preview test numbers."
L["Meter probe"] = "Meter probe"
L["Click the box, Ctrl+A, then Ctrl+C, and paste it in chat."] =
    "Click the box, Ctrl+A, then Ctrl+C, and paste it in chat."

-- Pages
L["General"] = "General"
L["Display"] = "Display"
L["Damage"] = "Damage"
L["Tools"] = "Tools"
L["Tools & Preview"] = "Tools & Preview"
L["What's new?"] = "What's new?"
L["Choose whose damage and which nameplates to show."] = "Choose whose damage and which nameplates to show."
L["Control how numbers look and how they animate."] = "Control how numbers look and how they animate."
L["Hide small hits so the big numbers stay readable."] = "Hide small hits so the big numbers stay readable."
L["Hide small hits and play sounds on big crits."] = "Hide small hits and play sounds on big crits."
L["Preview numbers and maintain your setup."] = "Preview numbers and maintain your setup."
L["Recent changes in PlateSCT."] = "Recent changes in PlateSCT."
L["Version 1.1.4"] = "Version 1.1.4"
L["NEW"] = "NEW"
L["IMPROVED"] = "IMPROVED"
L["Outgoing healing on the recipient's nameplate. Enable Show healing under General (off by default). Friendly nameplates must be on in the game."] =
    "Outgoing healing on the recipient's nameplate. Enable Show healing under General (off by default). Friendly nameplates must be on in the game."
L["Scroll speed slider - numbers travel faster; fade still follows Display duration."] =
    "Scroll speed slider - numbers travel faster; fade still follows Display duration."
L["Font picker - game fonts, plus SharedMedia fonts when another addon provides them."] =
    "Font picker - game fonts, plus SharedMedia fonts when another addon provides them."
L["Font size up to 48, Scroll offset up to 120 px, Display duration up to 4 seconds."] =
    "Font size up to 48, Scroll offset up to 120 px, Display duration up to 4 seconds."
L["Larger fonts spread out more in Modern number style so hits overlap less."] =
    "Larger fonts spread out more in Modern number style so hits overlap less."

-- Sound Effects
L["Sound effects"] = "Sound effects"
L["Outgoing critical hits play a sound when damage is above the threshold you type. Huge crit takes priority over the normal crit sound."] =
    "Outgoing critical hits play a sound when damage is above the threshold you type. Huge crit takes priority over the normal crit sound."
L["Crit sound"] = "Crit sound"
L["Enable crit sound"] = "Enable crit sound"
L["Play a sound when an outgoing critical hit is above the damage threshold."] =
    "Play a sound when an outgoing critical hit is above the damage threshold."
L["Huge crit sound"] = "Huge crit sound"
L["Enable huge crit sound"] = "Enable huge crit sound"
L["Play a louder sound when an outgoing critical hit is above the huge damage threshold."] =
    "Play a louder sound when an outgoing critical hit is above the huge damage threshold."
L["Damage threshold to play sound. Type 5k or 50k."] = "Damage threshold to play sound. Type 5k or 50k."
L["Supports k/m suffixes, e.g. 20k or 2m."] = "Supports k/m suffixes, e.g. 20k or 2m."
L["Supports k/m suffixes, e.g. 20k or 2m. The critical strike damage must be higher than this value."] =
    "Supports k/m suffixes, e.g. 20k or 2m. The critical strike damage must be higher than this value."
L["Play"] = "Play"
L["Preview this sound effect."] = "Preview this sound effect."
L["Channel"] = "Channel"
L["Which game sound channel plays this effect."] = "Which game sound channel plays this effect."
L["Dialog"] = "Dialog"
L["SFX"] = "SFX"
L["Ambience"] = "Ambience"
L["Music"] = "Music"

-- General
L["Combat text"] = "Combat text"
L["Enable PlateSCT"] = "Enable PlateSCT"
L["Show floating damage numbers on nameplates."] = "Show floating damage numbers on nameplates."
L["Hide Blizzard floating combat text"] = "Hide Blizzard floating combat text"
L["Turns off default in-world damage numbers."] = "Turns off default in-world damage numbers."
L["Show minimap button"] = "Show minimap button"
L["Show the PlateSCT icon on the minimap. Click it to open settings."] =
    "Show the PlateSCT icon on the minimap. Click it to open settings."
L["Click to open settings."] = "Click to open settings."
L["Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."] =
    "Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."
L["Who to show"] = "Who to show"
L["Only my damage"] = "Only my damage"
L["Show hits when a recent cast or auto-attack matches the nameplate. Midnight cannot prove who dealt the hit in a group."] =
    "Show hits when a recent cast or auto-attack matches the nameplate. Midnight cannot prove who dealt the hit in a group."
L["Experimental"] = "Experimental"
L["Best effort: matches your casts to nameplates by destination and timing. Dest-matched cleave can show. Other players on the same target can still appear. Mythic+ uses the Dungeon profile."] =
    "Best effort: matches your casts to nameplates by destination and timing. Dest-matched cleave can show. Other players on the same target can still appear. Mythic+ uses the Dungeon profile."
L["All engaged nameplates"] = "All engaged nameplates"
L["Show every hit on every visible hostile nameplate. This is the accurate Midnight mode; it includes damage from every source."] =
    "Show every hit on every visible hostile nameplate. This is the accurate Midnight mode; it includes damage from every source."
L["Available when Only my damage is off. Use this to see numbers on every enemy plate."] =
    "Available when Only my damage is off. Use this to see numbers on every enemy plate."
L["Include pet damage"] = "Include pet damage"
L["In Only my damage mode, also treat a recent pet cast as your hit."] =
    "In Only my damage mode, also treat a recent pet cast as your hit."
L["Also show damage from your pet and guardians on nameplates."] =
    "Also show damage from your pet and guardians on nameplates."
L["Shows your damage on hostile nameplates. Source is read from the combat log."] =
    "Shows your damage on hostile nameplates. Source is read from the combat log."
L["Display the spell's icon next to the damage number. Uses the spell from the combat log."] =
    "Display the spell's icon next to the damage number. Uses the spell from the combat log."
L["Healing"] = "Healing"
L["Show healing"] = "Show healing"
L["Show your outgoing heals on the recipient's nameplate. Friendly nameplates must be enabled in the game."] =
    "Show your outgoing heals on the recipient's nameplate. Friendly nameplates must be enabled in the game."
L["Uses the same size, motion, duration, icons, and threshold as damage. Skips heals on you."] =
    "Uses the same size, motion, duration, icons, and threshold as damage. Skips heals on you."
L["Attribution profiles"] = "Attribution profiles"
L["How strict PlateSCT is when guessing which hits are yours. Auto-switch follows the instance type."] =
    "How strict PlateSCT is when guessing which hits are yours. Auto-switch follows the instance type."
L["Current profile"] = "Current profile"
L["Auto-switch by instance"] = "Auto-switch by instance"
L["Pick Open world, Dungeon, Raid, Battleground, or Arena settings from the zone you are in."] =
    "Pick Open world, Dungeon, Raid, Battleground, or Arena settings from the zone you are in."
L["Manual strictness"] = "Manual strictness"
L["Used when Auto-switch is off."] = "Used when Auto-switch is off."
L["Open world"] = "Open world"
L["Dungeon"] = "Dungeon"
L["Raid"] = "Raid"
L["Battleground"] = "Battleground"
L["Arena"] = "Arena"
L["Loose"] = "Loose"
L["Balanced"] = "Balanced"
L["Strict"] = "Strict"
L["Very Strict"] = "Very Strict"
L["Loose: longer windows, more numbers."] = "Loose: longer windows, more numbers."
L["Balanced: medium windows and cleave hits."] = "Balanced: medium windows and cleave hits."
L["Strict: short windows, fewer foreign hits."] = "Strict: short windows, fewer foreign hits."
L["Very Strict: shortest windows, destination required, one hit per cast."] =
    "Very Strict: shortest windows, destination required, one hit per cast."
L["Active: %s (%s)"] = "Active: %s (%s)"
L["Recommended"] = "Recommended"
L["Damage schools"] = "Damage schools"
L["Damage Schools"] = "Damage Schools"
L["Filter by damage school"] = "Filter by damage school"
L["Show damage from schools checked below. Same-school hits from other players can still appear. Secret or unreadable schools are always shown."] =
    "Show damage from schools checked below. Same-school hits from other players can still appear. Secret or unreadable schools are always shown."
L["Use Recommended (%s)"] = "Use Recommended (%s)"
L["Use the schools your class typically deals."] = "Use the schools your class typically deals."
L["Physical"] = "Physical"
L["Holy"] = "Holy"
L["Fire"] = "Fire"
L["Nature"] = "Nature"
L["Frost"] = "Frost"
L["Shadow"] = "Shadow"
L["Arcane"] = "Arcane"

-- Display
L["Number style"] = "Number style"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, newest hit takes center, and older numbers snap aside."] =
    "Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, newest hit takes center, and older numbers snap aside."
L["Modern"] = "Modern"
L["Classic"] = "Classic"
L["Show live preview"] = "Show live preview"
L["Show sample hits, crits, and misses beside this window."] =
    "Show sample hits, crits, and misses beside this window."
L["Hide live preview"] = "Hide live preview"
L["Color by damage school"] = "Color by damage school"
L["Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."] =
    "Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."
L["Show spell icon"] = "Show spell icon"
L["Display the spell's icon next to the damage number. Uses the matched cast or auto-attack."] =
    "Display the spell's icon next to the damage number. Uses the matched cast or auto-attack."
L["Uses your matched spell in Only my damage mode. Position is set below."] =
    "Uses your matched spell in Only my damage mode. Position is set below."
L["Icon position"] = "Icon position"
L["Left"] = "Left"
L["Right"] = "Right"
L["Top"] = "Top"
L["Bottom"] = "Bottom"
L["Text style"] = "Text style"
L["Abbreviate numbers"] = "Abbreviate numbers"
L["Display large numbers as 214k or 1.2M."] = "Display large numbers as 214k or 1.2M."
L["Display large numbers as 214k or 1.2M. Disables thousand separators."] =
    "Display large numbers as 214k or 1.2M. Disables thousand separators."
L["Thousand separators"] = "Thousand separators"
L["Group digits by thousands."] = "Group digits by thousands."
L["Unavailable while Abbreviate numbers is on."] = "Unavailable while Abbreviate numbers is on."
L["Off"] = "Off"
L["Comma (10,000)"] = "Comma (10,000)"
L["Dot (10.000)"] = "Dot (10.000)"
L["Animation"] = "Animation"
L["Font"] = "Font"
L["Font size"] = "Font size"
L["Scroll offset"] = "Scroll offset"
L["Scroll speed"] = "Scroll speed"
L["Display duration"] = "Display duration"
L["Game default"] = "Game default"
L["Friz Quadrata"] = "Friz Quadrata"
L["Arial Narrow"] = "Arial Narrow"
L["Skurri"] = "Skurri"
L["Morpheus"] = "Morpheus"
L["Game fonts, plus SharedMedia fonts when that library is loaded by another addon."] =
    "Game fonts, plus SharedMedia fonts when that library is loaded by another addon."
L["Only fonts inside the WoW folder can load. SharedMedia fonts appear when another addon provides them."] =
    "Only fonts inside the WoW folder can load. SharedMedia fonts appear when another addon provides them."
L["Recommended"] = "Recommended"
L["%d px"] = "%d px"
L["%.1fs"] = "%.1fs"
L["%.1fx"] = "%.1fx"
L["Motion (Modern)"] = "Motion (Modern)"
L["Pick a motion for each hit type. Classic number style ignores these and keeps its own animation."] =
    "Pick a motion for each hit type. Classic number style ignores these and keeps its own animation."
L["Classic uses its own animation. Switch to Modern to customize motion."] =
    "Classic uses its own animation. Switch to Modern to customize motion."
L["Normal hits"] = "Normal hits"
L["Critical hits"] = "Critical hits"
L["Miss / Parry / Dodge"] = "Miss / Parry / Dodge"
L["Motion used for normal damage numbers."] = "Motion used for normal damage numbers."
L["Motion used for critical hits."] = "Motion used for critical hits."
L["Motion used for miss, parry, dodge, and similar outcomes."] =
    "Motion used for miss, parry, dodge, and similar outcomes."
L["Vertical Up"] = "Vertical Up"
L["Classic Slap"] = "Classic Slap"
L["Fountain"] = "Fountain"
L["Rainfall"] = "Rainfall"
L["Vertical Down"] = "Vertical Down"
L["Motion used for critical hits."] = "Motion used for critical hits."
L["Motion used for critical hits. Classic Slap uses the Classic grow-and-settle pow."] =
    "Motion used for critical hits. Classic Slap uses the Classic grow-and-settle pow."
L["Show CRITICAL"] = "Show CRITICAL"
L["Show CRITICAL on critical hits. Impact saves its own choice, enabled by default."] =
    "Show CRITICAL on critical hits. Impact saves its own choice, enabled by default."
L["CRITICAL"] = "CRITICAL"

-- Incoming
L["Incoming"] = "Incoming"
L["Show incoming hits"] = "Show incoming hits"
L["Show damage you take near your character. Independent of Only my damage."] =
    "Show damage you take near your character. Independent of Only my damage. Ignores the minimum damage threshold."
L["Uses your personal nameplate when available; otherwise floats near screen center."] =
    "Uses your personal nameplate when available; otherwise floats near screen center."
L["Uses your personal nameplate when available; otherwise sits on your unit frame."] =
    "Uses your personal nameplate when available; otherwise floats near screen center."
L["Incoming X"] = "Incoming X"
L["Incoming Y"] = "Incoming Y"

-- Damage
L["Minimum damage threshold"] = "Minimum damage threshold"
L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."] =
    "Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."
L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."] =
    "Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."
L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."] =
    "In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."

-- Tools
L["Preview"] = "Preview"
L["Updates live as you change options."] = "Updates live as you change options."
L["Target an enemy, then spawn sample numbers on its nameplate."] =
    "Target an enemy, then spawn sample numbers on its nameplate."
L["Test on Target"] = "Test on Target"
L["Show sample damage numbers on your target."] = "Show sample damage numbers on your target."
L["Maintenance"] = "Maintenance"
L["Debug mode"] = "Debug mode"
L["Print combat events to chat for troubleshooting."] = "Print combat events to chat for troubleshooting."
L["Dump meter now"] = "Dump meter now"
L["Open a copyable snapshot of C_DamageMeter fields. Use this in combat while hitting a target."] =
    "Open a copyable snapshot of C_DamageMeter fields. Use this in combat while hitting a target."
L["Reset Defaults"] = "Reset Defaults"
L["Restore every PlateSCT setting to its default."] = "Restore every PlateSCT setting to its default."

-- Language
L["Language"] = "Language"
L["Choose the language used by PlateSCT panels and messages."] =
    "Choose the language used by PlateSCT panels and messages."
L["Auto"] = "Auto"

-- Settings redesign
L["A new WoW-inspired settings window with clear sections, searchable controls, and gentle animations."] = "A new WoW-inspired settings window with clear sections, searchable controls, and gentle animations."
L["Animate settings"] = "Animate settings"

-- Settings window resize
L["Drag to resize. Double-click to restore the default size."] = "Drag to resize. Double-click to restore the default size."

L["Appearance"] = "Appearance"
L["Appearance only · Test on Target checks gameplay size."] = "Appearance only · Test on Target checks gameplay size."
L["Appearance preview"] = "Appearance preview"
L["Attribution"] = "Attribution"
L["Attribution limitations"] = "Attribution limitations"
L["Audio cues for outgoing critical hits."] = "Audio cues for outgoing critical hits."
L["Both number styles are available on every supported WoW API."] = "Both number styles are available on every supported WoW API."
L["Choose Personal - experimental under Modern API → Damage mode to use pet matching."] = "Choose Personal - experimental under Modern API → Damage mode to use pet matching."
L["Choose Personal - experimental under Modern API → Damage mode to use spell icons."] = "Choose Personal - experimental under Modern API → Damage mode to use spell icons."
L["Choose the combat text you want to see."] = "Choose the combat text you want to see."
L["Choose whose damage to display under Modern API → Damage mode. Personal mode is experimental."] = "Choose whose damage to display under Modern API → Damage mode. Personal mode is experimental."
L["Classic API - Era/TBC/Wrath/MoP"] = "Classic API - Era/TBC/Wrath/MoP"
L["Classic clients read damage ownership and spells directly from the combat log. Modern attribution and school-filter options do not apply."] = "Classic clients read damage ownership and spells directly from the combat log. Modern attribution and school-filter options do not apply."
L["Classic number style"] = "Classic number style"
L["Classic number style uses its own animation. Switch to Modern number style to customize motion."] = "Classic number style uses its own animation. Switch to Modern number style to customize motion."
L["Close"] = "Close"
L["Combat"] = "Combat"
L["Crit"] = "Crit"
L["Current target"] = "Current target"
L["Current target: all-source numbers on your target. Engaged nameplates: all-source numbers on engaged enemies."] = "Current target: all-source numbers on your target. Engaged nameplates: all-source numbers on engaged enemies."
L["Damage meter probe is available. Capture a snapshot while hitting a target."] = "Damage meter probe is available. Capture a snapshot while hitting a target."
L["Damage mode"] = "Damage mode"
L["Damage threshold"] = "Damage threshold"
L["Diagnostics"] = "Diagnostics"
L["Enable Auto-switch by instance to edit the instance profiles."] = "Enable Auto-switch by instance to edit the instance profiles."
L["Enable Filter by damage school to choose allowed schools."] = "Enable Filter by damage school to choose allowed schools."
L["Enable Show incoming hits to adjust its position."] = "Enable Show incoming hits to adjust its position."
L["Enable Show spell icon to choose its position."] = "Enable Show spell icon to choose its position."
L["Enable crit sound to adjust its threshold and channel."] = "Enable crit sound to adjust its threshold and channel."
L["Enable huge crit sound to adjust its threshold and channel."] = "Enable huge crit sound to adjust its threshold and channel."
L["Engaged nameplates"] = "Engaged nameplates"
L["Existing features"] = "Existing features"
L["Find a setting"] = "Find a setting"
L["Fonts, colors, numbers, and spell icons."] = "Fonts, colors, numbers, and spell icons."
L["Help & Settings"] = "Help & Settings"
L["Hide preview"] = "Hide preview"
L["Hit"] = "Hit"
L["Instance profiles"] = "Instance profiles"
L["Meter probe requires Modern API - Midnight & Forever."] = "Meter probe requires Modern API - Midnight & Forever."
L["Midnight & Forever damage modes and attribution."] = "Midnight & Forever damage modes and attribution."
L["Miss"] = "Miss"
L["Mixed"] = "Mixed"
L["Modern API"] = "Modern API"
L["Modern API options now have their own page. Damage mode combines Only my damage and All engaged nameplates without changing saved preferences."] = "Modern API options now have their own page. Damage mode combines Only my damage and All engaged nameplates without changing saved preferences."
L["Modern API - Midnight & Forever"] = "Modern API - Midnight & Forever"
L["Modern API: unreadable damage amounts cannot trigger threshold sounds."] = "Modern API: unreadable damage amounts cannot trigger threshold sounds."
L["Modern clients restrict combat information. Personal mode estimates ownership; all-source modes display target or engaged-nameplate damage."] = "Modern clients restrict combat information. Personal mode estimates ownership; all-source modes display target or engaged-nameplate damage."
L["Modern number style"] = "Modern number style"
L["Modern number style motion"] = "Modern number style motion"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."] = "Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."
L["No matching settings"] = "No matching settings"
L["Number formatting"] = "Number formatting"
L["Number style, timing, and movement."] = "Number style, timing, and movement."
L["Outgoing healing, incoming damage, font selection, scroll speed, school colors, spell icons, and critical-hit sounds remain available."] = "Outgoing healing, incoming damage, font selection, scroll speed, school colors, spell icons, and critical-hit sounds remain available."
L["Personal matches recent casts. Current target and Engaged nameplates show damage from all sources."] = "Personal matches recent casts. Current target and Engaged nameplates show damage from all sources."
L["Personal - experimental"] = "Personal - experimental"
L["Personal - experimental: best-effort matching by destination and timing. Other players' hits on the same target can appear."] = "Personal - experimental: best-effort matching by destination and timing. Other players' hits on the same target can appear."
L["Pet matching and spell icons require Personal mode. Choose their appearance and visibility under Combat and Appearance."] = "Pet matching and spell icons require Personal mode. Choose their appearance and visibility under Combat and Appearance."
L["Place the spell icon beside, above, or below the number."] = "Place the spell icon beside, above, or below the number."
L["PlateSCT needs enemy nameplates. Press V (default) or enable them in the game's nameplate settings."] = "PlateSCT needs enemy nameplates. Press V (default) or enable them in the game's nameplate settings."
L["Play crit sound"] = "Play crit sound"
L["Play huge crit sound"] = "Play huge crit sound"
L["Preferences"] = "Preferences"
L["Preferences, API information, and diagnostics."] = "Preferences, API information, and diagnostics."
L["Preview scale: %d%%"] = "Preview scale: %d%%"
L["Profiles affect Personal mode. They cannot prove who dealt a hit on Modern API."] = "Profiles affect Personal mode. They cannot prove who dealt a hit on Modern API."
L["Replay"] = "Replay"
L["Schools"] = "Schools"
L["Settings redesign"] = "Settings redesign"
L["Settings window"] = "Settings window"
L["Show damage you take near your character. Independent of the outgoing damage mode."] = "Show damage you take near your character. Independent of the outgoing damage mode."
L["Show preview"] = "Show preview"
L["Show sample hits, crits, and misses in the bottom preview drawer."] = "Show sample hits, crits, and misses in the bottom preview drawer."
L["Show sample hits, crits, and misses inside this window."] = "Show sample hits, crits, and misses inside this window."
L["Sounds"] = "Sounds"
L["Spell icons"] = "Spell icons"
L["Spell icons use matched casts in Personal mode; Modern API cannot identify a spell for every hit."] = "Spell icons use matched casts in Personal mode; Modern API cannot identify a spell for every hit."
L["Spell icons use the spell from the combat log."] = "Spell icons use the spell from the combat log."
L["Text size"] = "Text size"
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. Both number styles remain available on every API."] = "The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. Both number styles remain available on every API."
L["The preview shows appearance only. It does not prove attribution or simulate damage filtering."] = "The preview shows appearance only. It does not prove attribution or simulate damage filtering."
L["This client does not expose the damage meter API. A snapshot can still report which fields are unavailable."] = "This client does not expose the damage meter API. A snapshot can still report which fields are unavailable."
L["Timing and movement"] = "Timing and movement"
L["Training dummy"] = "Training dummy"
L["Turn off Auto-switch by instance to choose manual strictness."] = "Turn off Auto-switch by instance to choose manual strictness."
L["Unreadable amounts cannot trigger threshold sounds. Unreadable damage schools are always allowed by the school filter."] = "Unreadable amounts cannot trigger threshold sounds. Unreadable damage schools are always allowed by the school filter."
L["Unsupported client - combat text unavailable"] = "Unsupported client - combat text unavailable"
L["Use gentle fades and row reveals in this settings window. Combat animation is unaffected."] = "Use gentle fades and row reveals in this settings window. Combat animation is unaffected."
L["Your WoW API"] = "Your WoW API"
