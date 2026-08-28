local _, BD = ...

local L = {}
BD.RegisterLocale("enUS", L)

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
L["Choose whose damage and which nameplates to show."] = "Choose whose damage and which nameplates to show."
L["Control how numbers look and how they animate."] = "Control how numbers look and how they animate."
L["Hide small hits so the big numbers stay readable."] = "Hide small hits so the big numbers stay readable."
L["Preview numbers and maintain your setup."] = "Preview numbers and maintain your setup."

-- General
L["Combat text"] = "Combat text"
L["Enable PlateSCT"] = "Enable PlateSCT"
L["Show floating damage numbers on nameplates."] = "Show floating damage numbers on nameplates."
L["Hide Blizzard floating combat text"] = "Hide Blizzard floating combat text"
L["Turns off default in-world damage numbers."] = "Turns off default in-world damage numbers."
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
L["Loose: longer windows, more numbers."] = "Loose: longer windows, more numbers."
L["Balanced: medium windows and cleave hits."] = "Balanced: medium windows and cleave hits."
L["Strict: short windows, fewer foreign hits."] = "Strict: short windows, fewer foreign hits."
L["Active: %s (%s)"] = "Active: %s (%s)"
L["Recommended"] = "Recommended"

-- Display
L["Number style"] = "Number style"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, newest hit takes center, and older numbers snap aside."] =
    "Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, newest hit takes center, and older numbers snap aside."
L["Modern"] = "Modern"
L["Classic"] = "Classic"
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
L["Animation"] = "Animation"
L["Font size"] = "Font size"
L["Scroll offset"] = "Scroll offset"
L["Display duration"] = "Display duration"
L["Recommended"] = "Recommended"
L["%d px"] = "%d px"
L["%.1fs"] = "%.1fs"
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
L["PlateSCT"] = "PlateSCT"
L["Classic Slap"] = "Classic Slap"
L["Fountain"] = "Fountain"
L["Rainfall"] = "Rainfall"
L["Vertical Down"] = "Vertical Down"
L["Motion used for critical hits."] = "Motion used for critical hits."
L["Motion used for critical hits. Classic Slap uses the Classic grow-and-settle pow."] =
    "Motion used for critical hits. Classic Slap uses the Classic grow-and-settle pow."

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
