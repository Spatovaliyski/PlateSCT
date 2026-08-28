local _, BD = ...

--[[
PlateSCT API flavor lock — source of truth for Modern vs Classic version boundaries.

Terminology (chat + comments):
  Classic version / Modern version = WoW client (Era/TBC/Mists vs Midnight).
  Classic style / Modern style     = numberStyle "classic" vs "retail" (any client).
  Never say "Classic" alone when client vs style could be mixed.

MODERN VERSION (Midnight, combat restrictions)
  Allowed:  UNIT_COMBAT for numbers; issecretvalue/canaccessvalue/C_CurveUtil threshold;
            attribution heuristic + onlyMyDamage/allNameplates; C_DamageMeter probe;
            C_Spell first, then legacy spell APIs.
  Forbidden: COMBAT_LOG_EVENT_UNFILTERED for numbers; treating amount/source as plaintext;
            assuming source GUID is yours; Classic version CLEU payload layout.

CLASSIC VERSION (Era 11509 / TBC 20506 / Mists 50504 — no restrictions, one path)
  Allowed:  COMBAT_LOG_EVENT_UNFILTERED + CombatLogGetCurrentEventInfo;
            source GUID / Pet- prefix / UnitGUID("pet") / 0x1111 sourceFlags;
            SPELL_SUMMON dest GUID cache; Mine+Guardian or Mine+Player NPC pets;
            GetSpellInfo/GetSpellTexture (and C_Spell if present).
  Forbidden: UNIT_COMBAT for numbers; issecretvalue/canaccessvalue/C_DamageMeter/C_CurveUtil;
            attribution windows / threat-as-source; gating pet on onlyMyDamage;
            MatchOutgoingHit or cast-tracking for spell icons (use CLEU spellId instead).

Call sites in flavor-owned files must use AssertModern / AssertClassic at entry points.
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
    local eraProject = WOW_PROJECT_CLASSIC or 2
    local tbcProject = WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5
    local mistsProject = WOW_PROJECT_MISTS_CLASSIC or 19

    if projectId == modernProject and interfaceVersion >= 120000 then
        return FLAVOR_MODERN
    end
    if projectId == eraProject and interfaceVersion >= 11000 and interfaceVersion < 12000 then
        return FLAVOR_CLASSIC
    end
    if projectId == tbcProject and interfaceVersion >= 20000 and interfaceVersion < 30000 then
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
