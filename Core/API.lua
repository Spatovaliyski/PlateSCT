local _, BD = ...

--[[
PlateSCT API flavor lock — source of truth for Modern vs Classic version boundaries.
Do not add a root README for this contract (release zips pack the folder).

=============================================================================
ARCHITECTURE: one infra + two flavor APIs
=============================================================================
  INFRA (shared, flavor-agnostic where possible)
    Pool, Animation, Display layout/fonts/icons, Options shell, locales,
    Constants UI defaults. May call BD.IsSecret / ValuesEqual / CanAccessValue.
    Must not: parse CLEU, register UNIT_COMBAT for numbers, assume plaintext
    GUID/amount ownership, or call AssertModern/AssertClassic combat parsers.

  MODERN FLAVOR — Core/Combat.lua, Attribution.lua, Probe.lua
    Entry points: AssertModern(...). Owns UNIT_COMBAT, attribution, secrets.

  CLASSIC FLAVOR — Core/CombatClassic.lua
    Entry points: AssertClassic(...). Owns CLEU, GUID↔plate, pet flags, spellId.

  Flavor may call infra (ShowOnNameplate, OrphanFramesForUnit, …).
  Infra must not call flavor combat ingest.

=============================================================================
TWO WOW APIs
=============================================================================
  Modern API — Midnight / Forever
    Midnight: WOW_PROJECT_MAINLINE (1), interface >= 120000 (TOC 120100).
    Forever:  interface 16001 (1.60.x band 16000–16999). Project is
              WOW_PROJECT_CAMELOT (18) or, on some builds, MAINLINE (1).
    Same flavor: combat restrictions, UNIT_COMBAT, secret values.

  Classic API — Era / TBC / Wrath / MoP
    Era:   WOW_PROJECT_CLASSIC (2), TOC 11509, interface 11000–11999.
    TBC:   WOW_PROJECT_BURNING_CRUSADE_CLASSIC (5), TOC 20506, 20000–29999.
    Wrath: WOW_PROJECT_WRATH_CLASSIC (11), interface 30000–39999.
    MoP:   WOW_PROJECT_MISTS_CLASSIC (19), TOC 50504, interface 50000–59999.
    Same flavor: unrestricted CLEU, plaintext GUID and amount.

=============================================================================
TERMINOLOGY (chat + comments)
=============================================================================
  Classic version / Modern version = which WoW API the client runs.
    Modern version = Midnight or Forever (Modern API). API.IsModern().
    Classic version = Era, TBC, Wrath, or MoP (Classic API). API.IsClassic().
  Classic style / Modern style = numberStyle "classic" vs "retail" (any client).
  Never say "Classic" or "Modern" alone when client vs style could be mixed.

=============================================================================
MODERN API (Midnight / Forever — combat restrictions)
=============================================================================
  Allowed:
    UNIT_COMBAT for numbers; issecretvalue/canaccessvalue via Util helpers only;
    C_CurveUtil threshold (secret amounts → visual hide, not Lua skip-by-compare);
    attribution heuristic + onlyMyDamage/allNameplates; C_DamageMeter probe;
    C_Spell first, then legacy spell APIs;
    plate orphan on hide / NAME_PLATE_UNIT_REMOVED (no GUID identity compare);
    relative linger follow; freeze from last world pin (not plate GetLeft).

  Forbidden:
    COMBAT_LOG_EVENT_UNFILTERED for numbers;
    treating amount / school / UnitGUID / source as plaintext;
    raw == ~= < > <= >= concat tostring sort on unchecked combat values;
    storing secret UnitGUID (or other secrets) on frames as compare identity;
    assuming source GUID is yours; Classic CLEU payload layout;
    Classic pet flag / SPELL_SUMMON ownership model.

=============================================================================
CLASSIC API (Era / TBC / Wrath / MoP — no restrictions)
=============================================================================
  Allowed:
    COMBAT_LOG_EVENT_UNFILTERED + CombatLogGetCurrentEventInfo;
    source GUID / live UnitGUID("pet") / Pet- prefix only with Mine affiliation /
      0x1111 sourceFlags; SPELL_SUMMON dest GUID cache;
    Mine+Guardian or Mine+Player NPC pets;
    GetSpellInfo/GetSpellTexture (and C_Spell if present);
    plaintext GUID compare for plate reuse when CanAccessValue;
    relative linger follow + freeze at last world pin (plate widgets recycle).

  Forbidden:
    UNIT_COMBAT for numbers; issecretvalue/canaccessvalue/C_DamageMeter/C_CurveUtil
      for real Classic logic (helpers may no-op false);
    attribution windows / threat-as-source; gating pet on onlyMyDamage;
    MatchOutgoingHit or cast-tracking for spell icons (use CLEU spellId instead).

=============================================================================
SECRET VALUES — what belongs / does not
=============================================================================
  Belongs (Modern, via Util):
    BD.IsSecret / ValuePresent / CanAccessValue / ValuesEqual / ValuesNotEqual;
    pass secret amounts into Display / threshold curve Evaluate;
    treat presence without reading plaintext.

  Does not belong:
    guid == x, amount < minDamage, school == n without CanAccessValue;
    frame.anchorGuid = UnitGUID(unit) when secret (Modern: orphan via plate events);
    using CLEU source GUID for "mine" on Modern;
    putting Classic-only GUID compares in shared Pool without ValuesEqual;
    Classic combat logic that requires issecretvalue to be meaningful.

  If a value might be secret: use helpers, or do not compare / store for identity.

Call sites in flavor-owned files must use AssertModern / AssertClassic at entry.
]]

local API = {}
BD.API = API

local FLAVOR_MODERN = "modern"
local FLAVOR_CLASSIC = "classic"
local FLAVOR_UNSUPPORTED = "unsupported"

local flavor = FLAVOR_UNSUPPORTED
local projectId
local interfaceVersion
local warnedMismatch = false

local function GetInterfaceVersion()
    local _, _, _, interface = GetBuildInfo()
    return tonumber(interface) or 0
end

local function DetectFlavor()
    projectId = WOW_PROJECT_ID
    interfaceVersion = GetInterfaceVersion()

    local modernProject = WOW_PROJECT_MAINLINE or 1
    local foreverProject = WOW_PROJECT_CAMELOT or 18
    local eraProject = WOW_PROJECT_CLASSIC or 2
    local tbcProject = WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5
    local wrathProject = WOW_PROJECT_WRATH_CLASSIC or 11
    local mistsProject = WOW_PROJECT_MISTS_CLASSIC or 19

    -- Forever build 16001 (1.60.x). Same Modern API as Midnight.
    -- Project is CAMELOT (18), or MAINLINE (1) on builds that still report 1.
    local foreverInterface = interfaceVersion >= 16000 and interfaceVersion < 17000
    if projectId == foreverProject or foreverInterface then
        return FLAVOR_MODERN
    end
    if projectId == modernProject and interfaceVersion >= 120000 then
        return FLAVOR_MODERN
    end

    if projectId == eraProject and interfaceVersion >= 11000 and interfaceVersion < 12000 then
        return FLAVOR_CLASSIC
    end
    if projectId == tbcProject and interfaceVersion >= 20000 and interfaceVersion < 30000 then
        return FLAVOR_CLASSIC
    end
    if projectId == wrathProject and interfaceVersion >= 30000 and interfaceVersion < 40000 then
        return FLAVOR_CLASSIC
    end
    if projectId == mistsProject and interfaceVersion >= 50000 and interfaceVersion < 60000 then
        return FLAVOR_CLASSIC
    end

    return FLAVOR_UNSUPPORTED
end

flavor = DetectFlavor()

local function WarnOnce(message)
    if warnedMismatch then
        return
    end
    warnedMismatch = true
    print("|cffff6600PlateSCT:|r " .. message)
end

if flavor == FLAVOR_UNSUPPORTED then
    WarnOnce(
        "unsupported client (project="
            .. tostring(projectId)
            .. ", interface="
            .. tostring(interfaceVersion)
            .. "). Combat events disabled."
    )
elseif flavor == FLAVOR_MODERN then
    if not issecretvalue or not canaccessvalue then
        WarnOnce("Modern client missing combat restriction APIs; staying on Modern path.")
    end
elseif flavor == FLAVOR_CLASSIC then
    if issecretvalue or canaccessvalue then
        WarnOnce("Classic client exposes combat restriction APIs; staying on Classic path.")
    end
end

function API.GetFlavor()
    return flavor
end

function API.IsModern()
    return flavor == FLAVOR_MODERN
end

function API.IsClassic()
    return flavor == FLAVOR_CLASSIC
end

function API.IsSupported()
    return flavor == FLAVOR_MODERN or flavor == FLAVOR_CLASSIC
end

function API.HasCombatRestrictions()
    return flavor == FLAVOR_MODERN
end

function API.HasDirectSpellAttribution()
    return flavor == FLAVOR_CLASSIC
end

function API.AssertModern(where)
    if flavor ~= FLAVOR_MODERN then
        error("PlateSCT: Modern-only API called from " .. tostring(where) .. " on " .. flavor)
    end
end

function API.AssertClassic(where)
    if flavor ~= FLAVOR_CLASSIC then
        error("PlateSCT: Classic-only API called from " .. tostring(where) .. " on " .. flavor)
    end
end

function API.ApplyFlavorDefaults(defaults)
    if flavor == FLAVOR_CLASSIC and defaults then
        defaults.numberStyle = "classic"
        defaults.fontSize = 18
    end
end
