# Settings transfer verification

Run `lua tests/SettingsTransfer.lua` from the addon root with Lua 5.1. The suite
uses WoW API stubs, real defaults/helpers, and fixed v1/v2 strings encoded
independently. It checks the four client combinations, missing
and unknown settings, limits and malformed strings, all current preferences,
class recommendations, refresh rollback, login persistence, translations, Lua
syntax, and dialog interactions. UI stubs cannot prove in-game rendering.

## In-game smoke test (Midnight and a Classic API client)

1. Open `/platesct`, then Import & Export → Export Settings. Copy the full
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
Never transfer or replay `layoutRevision`. Language, settings-window animation, the live preview toggle, and the welcome screen's first-visit marker stay on the local character. New exports omit them. Older strings ignore them. Resetting appearance preferences preserves the first-visit marker; `/psct welcome` always opens the welcome screen.

No SavedVariables migration is involved. Reverting this feature leaves an
ordinary PlateSCTDB that the previous release can read. Failed validation makes
no changes; a failed runtime refresh restores the previous preference values
and attempts to restore runtime effects before reporting the failure.
