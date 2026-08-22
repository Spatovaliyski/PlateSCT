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
L["Show hits on your current target when you recently cast or auto-attacked. Midnight cannot prove who dealt the hit in a group."] =
    "Show hits on your current target when you recently cast or auto-attacked. Midnight cannot prove who dealt the hit in a group."
L["Experimental"] = "Experimental"
L["Best effort on your current target. Other players hitting the same mob can still show up. Off-target cleave and DoTs are not shown."] =
    "Best effort on your current target. Other players hitting the same mob can still show up. Off-target cleave and DoTs are not shown."
L["All engaged nameplates"] = "All engaged nameplates"
L["Show every hit on every visible hostile nameplate. This is the accurate Midnight mode; it includes damage from every source."] =
    "Show every hit on every visible hostile nameplate. This is the accurate Midnight mode; it includes damage from every source."
L["Available when Only my damage is off. Use this to see numbers on every enemy plate."] =
    "Available when Only my damage is off. Use this to see numbers on every enemy plate."
L["Include pet damage"] = "Include pet damage"
L["In Only my damage mode, also treat a recent pet cast as your hit."] =
    "In Only my damage mode, also treat a recent pet cast as your hit."

-- Display
L["Number style"] = "Number style"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."] =
    "Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."
L["Modern"] = "Modern"
L["Classic"] = "Classic"
L["Color by damage school"] = "Color by damage school"
L["Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."] =
    "Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."
L["Show spell icon"] = "Show spell icon"
L["Display the spell's icon to the left of the damage number. Uses your last cast or auto-attack."] =
    "Display the spell's icon to the left of the damage number. Uses your last cast or auto-attack."
L["Uses your last spell in Only my damage mode. Left of the number."] =
    "Uses your last spell in Only my damage mode. Left of the number."
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
