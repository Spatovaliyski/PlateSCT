# Settings transfer verification

Run `lua tests/SettingsTransfer.lua` from the addon root with Lua 5.1. The suite
uses WoW API stubs, real defaults/helpers, and fixed v1/v2 strings encoded
independently. It checks the four client combinations, missing
and unknown settings, limits and malformed strings, all current preferences,
class recommendations, refresh rollback, login persistence, translations, Lua
syntax, and dialog interactions. UI stubs cannot prove in-game rendering.

## In-game smoke test (Midnight and a Classic API client)

1. Open `/platesct`, then the footer's Import & Export → Export Settings. Copy the full
   selection with Ctrl+C. Check that the long string scrolls and the dialog fits
   at the current UI scale. Exporting and closing must change no preferences.
2. On both clients, use distinct fonts, all three styles' saved offsets, sound
   thresholds, minimap positions, and language preferences. Import a string from
   each client into each client. Validate first; check the summary and ignored
   count, then Apply. Shared choices should transfer in every combination.
3. Record Midnight damage mode, attribution, and school choices before importing
   a Classic API string. Those choices must remain unchanged. A Modern API string
   imported on Classic must ignore all 18 Modern API preferences.
4. With a Modern API string, test manual school choices and recommended schools
   on a different class. Manual choices transfer exactly; recommendations follow
   the receiving character. Confirm Classic imports never recompute these choices.
5. Confirm immediate language/preview/minimap changes, threshold filtering, and
   Blizzard floating combat text in both directions. A missing SharedMedia font
   must use the game fallback while keeping its saved selection.
6. Validate a valid string, edit it, and confirm Apply becomes disabled. Try an
   incomplete string. Cancel and Escape must leave preferences unchanged. Apply
   a valid import, reload, and verify the choices persist.
7. Add a custom screen area with a name containing a comma, percent sign and
   non-Latin letters, move the built-in areas, route crits to the custom area and
   switch to Screen mode. Import that string on the other client: areas, names,
   routes and display mode must match. An older string (no area records) must
   leave the receiver's areas alone.
8. Under General, switch layouts while Placement/Areas or Animation is selected.
   Check the layout header, six shared pages plus Modern API on Modern clients, renamed Placement/Areas button,
   retained page destination, and search results. Enable incoming hits in Combat;
   choose Incoming area in Animation, then switch to Placement and confirm the
   same destination remains selected. No Incoming sidebar page appears. Modern API
   owns Damage mode, Attribution and Schools, and is absent on Classic API clients.
9. Give different areas different animations, timing, alignment and spacing.
   Check Animation for motion and Placement/Areas for geometry and routing, held crit bursts, selected-area testing,
   and the scaled preview. Changing Nameplate duration or speed must not affect
   those areas. Check movers and readable settings at UI scales 0.64 and 1.0.
10. Verify there are no plus/minus expand/collapse buttons. Combining details
    appear directly when Combine rapid hits is enabled; motion, critical-text,
    routing and interface controls appear under headings when relevant. Search
    should navigate directly to their rows. Changing destinations preserves saved
    values. Test Full numbers / Thousands separators / Abbreviated against old
    imports; formatting still uses the existing saved fields and transfer IDs.
11. Check the persistent Active layout badge at the top right and click it to
    open General. API text uses 18-point type. Settings text, damage fonts,
    CRITICAL labels and hit counts have a 13-point base minimum. UI scale and
    combat animation transforms still apply. Import old 10–12 point preferences
    and confirm both outgoing and incoming fonts become 13 without losing other settings.

## Format maintenance

New exports use format 2: `PSCT2`, a Base62 payload, and an eight-digit Adler-32
checksum of `PSCT2` plus the raw payload bytes. The entire string contains only
ASCII letters and numbers. The payload starts with source flavor (one byte:
0 Classic API, 1 Modern API), addon-version length (one byte), and version text.
Each setting then stores its permanent one-byte ID, a type/scope tag, and value.
Tags 0/1 are false/true; 2 is a decimal number with one-byte length; 3 is a UTF-8
string with a two-byte big-endian length. Add 128 to the tag for Modern API scope.
Numbers keep enough decimal digits to round-trip exactly; all applicable settings
are included, even when equal to defaults. No compression library is required.

Base62 uses `0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz`. Each
four-byte big-endian block becomes six characters with leading zero digits.
Final blocks of 1/2/3 bytes use 2/3/5 characters. Overflow, invalid lengths,
duplicate IDs, and incorrect field ownership are rejected. Unknown IDs are skipped.
IDs in the settings schema must never be renumbered or reused, and their scope
must never change. New settings receive unused IDs. String length varies with
the preferences; do not truncate or pad to a fixed character count.

The original format 1 remains importable. It uses `!PlateSCT:1!` followed by semicolon-separated `name=typedValue`
records and `!` plus an eight-digit Adler-32 checksum of the preceding bytes.
`source` and `addon` are required metadata. Setting names use `shared.key` or
`modern.key`. Values use `b:0`/`b:1`, finite decimal `n:value`, or `s:value` with
all bytes outside `A-Z a-z 0-9 _ . ~ -` percent-encoded. Export sorts records;
import accepts any order. Whitespace anywhere in the string is ignored. Unknown fields are
reported and discarded; known fields cannot change ownership through the string.

Keep the fixed v1 and v2 fixtures when extending the schema or adding a new format.
Update the explicit schema whenever adding a user preference. Retain old readers
and add an explicit conversion if a previously exported value changes meaning.
Screen areas (Core/Layout.lua) travel as IDs 80-89, one record per saved area in list
order: `id,name,x,y,width,height,direction,path,sticky`, with `%` and `,` in the name
written as `%25` and `%2C`. One record per area keeps every string record well under
the 1024-byte reader limit, so older releases skip these IDs as unknown. A string with
area records replaces the receiver's list (missing built-in areas return with defaults);
one without them keeps it. Route settings (IDs 73-79) must name an area that exists after
the import, or validation fails. The legacy global screen number style (`linear`
or `impact`) remains ID 90; it is used when upgrading old area records, not by
the current renderer. IDs 91-100 supplement area records with
`id,animation,duration,spacing,alignment`. Animations are `straight`, `curveLeft`,
`curveRight`, `static`, and `impact`; alignment is `left`, `center`, or `right`.
Each supplemental record must identify an area in the imported list; duplicate
area identities, invalid enums, nonfinite timing, and invalid spacing are rejected.
Supplemental records without base area records are rejected. Older readers skip
these IDs and retain their legacy rendering behavior. New readers derive missing
motion from the imported legacy style, duration, speed and area geometry, using
defaults for omitted legacy fields. Imports without area records retain all local
area motion, even if they change legacy global settings.

New areas use 2.4 seconds, 4 px spacing and centered alignment. The editor offers
0.5–8 seconds; migrated timings outside that range remain stored and displayed
until edited. The data format accepts 0.01–48 seconds to preserve legacy timing.
IDs 18 and 19 (the retired incoming offsets) stay
reserved and are still read: when a string has them but no area records, they move the
Incoming area exactly as layout revision 15 does on login.

Never transfer or replay `layoutRevision`. Language, settings-window animation, the live preview toggle, and the welcome screen's first-visit marker stay on the local character. New exports omit them. Older strings ignore them. Resetting appearance preferences preserves the first-visit marker; `/psct welcome` always opens the welcome screen.

Layout revision 16 upgrades existing Screen areas to per-area motion while
preserving the old duration formula, geometry, routes, direction and crit hold.
Layout revision 17 raises saved outgoing and incoming font sizes below 13 to 13.
Font transfer IDs 7 and 63 still accept historical 10–12 point records and normalize
them to 13 before preview/application; new exports use the same minimum. Larger
font sizes and all other preferences retain their values. Reverting leaves an ordinary
PlateSCTDB that the previous release can read. Failed validation makes
no changes; a failed runtime refresh restores the previous preference values
and attempts to restore runtime effects before reporting the failure.
