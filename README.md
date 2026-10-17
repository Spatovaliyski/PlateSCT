# PlateSCT

Nameplate scrolling combat text for World of Warcraft.

PlateSCT displays outgoing combat numbers on nameplates and supports incoming player combat text, configurable number styles, animations, fonts, colors, and critical-hit sounds.

**Author:** Limitedby

## Features

- Outgoing combat text anchored to nameplates.
- Incoming player combat text.
- Spell labels: show the spell's icon, its name, or both next to each number, with name position, size, and length options.
- Separate motion for auto-attacks.
- Classic style with a grow-and-settle animation and Modern style with a pop animation.
- Configurable fonts, outlines, custom colors, critical-hit presentation, and damage thresholds.
- Animation options, including fountain and rainfall motion, with settings previews.
- Optional hit combining: rapid hits on the same nameplate merge into one growing number with a hit count, grouped by spell or by target.
- Classic API client support for player and pet combat-log events, with spell icons taken from combat-log spell IDs.
- Modern API client attribution and school-filter settings.
- English, French, German, Spanish, Russian, Italian, Brazilian Portuguese, Simplified Chinese, Traditional Chinese, and Korean localization.

## Supported clients and number styles

Client compatibility and number style are separate settings:

| Client family | Combat API | Default number style |
| --- | --- | --- |
| Era, TBC, Wrath, MoP | Classic API | Classic style |
| Midnight, Forever | Modern API | Modern style |

Both number styles are available on either client family. Selecting Classic style does not switch the addon to the Classic combat API.

Classic API clients use the unrestricted combat log. Modern API clients use `UNIT_COMBAT` and attribution logic within the client's combat-data restrictions, so their combat-data paths differ.

## Installation

Install PlateSCT using either option:

- **CurseForge:** install [PlateSCT](https://www.curseforge.com/wow/addons/platesct) through the CurseForge app, or download it from the website and extract the `PlateSCT` folder into your game client's `Interface/AddOns` directory.
- **Tagged release:** download the addon archive from a [tagged release](https://github.com/Spatovaliyski/PlateSCT/releases) and extract the `PlateSCT` folder into your game client's `Interface/AddOns` directory.

For a manual installation, check that the resulting path is `Interface/AddOns/PlateSCT/PlateSCT.toc`, without an extra nested folder.

You can install while the game is running. After installation, type `/reload` in chat to load the addon. Make sure **PlateSCT** is enabled in the AddOns list.

Enable the nameplates you want to see outgoing numbers on in the game's settings.

## Configuration

Use the minimap button or addon compartment entry to access PlateSCT's options.

The settings cover combat text, appearance, animations, critical-hit sounds, and Modern API client behavior.

Hit combining is off by default. Turn on **Combat → Combine hits → Combine rapid hits** to merge hits that land on the same nameplate within the combine window (0.5 seconds by default). **Same spell** keeps each spell separate; **All hits** merges everything on the target and shows the icon of the spell that dealt the most damage. The hit count appears as `37,200 (3)`, or on the spell icon when icons are on. Crits, normal hits, and heals combine separately, and each hit must still pass the damage threshold. On Modern API clients, secret amounts cannot be added together, so those hits still show individually. Use the number and motion previews to check changes. Preferences and diagnostics are available in the Help page.

The locale preference can follow the game client automatically or select a supported language. Missing translations fall back to English.

Settings are stored in the `PlateSCTDB` saved variable. On login, if `PlateSCTDB` is missing and legacy `BetterDamageDB` settings exist, the addon copies those settings once. Existing PlateSCT settings take precedence.

## Troubleshooting

- **The addon is missing from the AddOns list:** check the folder name and confirm that `PlateSCT.toc` is directly inside `Interface/AddOns/PlateSCT` for the correct game client.
- **Outgoing numbers are missing:** confirm that nameplates are visible, then check combat-text settings and the damage threshold. On Modern API clients, also check attribution and school-filter settings.
- **Blizzard combat text overlaps PlateSCT:** review PlateSCT's Blizzard floating-combat-text setting.
- **Numbers look different between clients:** the client families have different default number styles. Choose the same style explicitly to compare their appearance.

When reporting a problem, include the game client and interface version, PlateSCT version, selected number style, steps to reproduce it, and any Lua error text. For pet-related issues, include the pet or summon and the spell involved.

## Repository structure

The addon uses Lua 5.1. World of Warcraft loads only the files listed in `PlateSCT.toc`, in their listed order.

| Path | Responsibility |
| --- | --- |
| `PlateSCT.toc` | Addon metadata, supported interface declarations, saved variables, and file load order |
| `Core/API.lua` | Client-family detection and flavor defaults |
| `Core/CombatClassic.lua` | Classic API combat-log handling, pet ownership, GUID-to-nameplate tracking, and spell icons |
| `Core/Combat.lua` | Modern API `UNIT_COMBAT` handling and personal-hit deduplication |
| `Core/Attribution.lua` | Modern API spell matching, scenarios, and attribution strictness |
| `Core/Probe.lua` | Modern API damage-meter diagnostics |
| `Core/Display.lua` | Combat text, icons, colors, and previews |
| `Core/Pool.lua` | Frame allocation, positioning, overlap, linger, and detachment |
| `Core/Animation.lua` | Number animation behavior |
| `Core/Util.lua` | Value-safety helpers, formatting, thresholds, schools, fonts, and sounds |
| `Core/Constants.lua` | Defaults, style presets, colors, and shared constants |
| `Core/Events.lua` | Event registration, login initialization, and saved-setting migrations |
| `Core/Minimap.lua` | Minimap button and addon compartment integration |
| `Options/` | Settings pages, controls, and panel behavior |
| `Locales/` | Locale registry and translated strings |
| `Media/` | Bundled visual and sound assets |
