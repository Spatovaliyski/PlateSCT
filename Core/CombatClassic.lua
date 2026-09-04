local _, BD = ...

-- Classic-only: CLEU ingestion for unrestricted clients (Era / TBC / Mists).
-- Pet detection follows Classic combat-log conventions (LibThreatClassic / Recount):
--   - Live UnitGUID("pet") only (Pet- prefix is a type, not ownership — raid pets share it)
--   - 0x1111 sourceFlags mask (Mine + Friendly + Player-controlled + Pet)
--   - Mine + Guardian, Mine + Pet- GUID, or Mine + Player-controlled NPC (some hunter pets)
--   - SPELL_SUMMON destinations owned by the player

local playerGUID
local guidToToken = {}
local ownedPetGUIDs = {}
local playerSummonGUIDs = {}

local AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE or 0x00000001
local CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER or 0x00000100
local TYPE_NPC = COMBATLOG_OBJECT_TYPE_NPC or 0x00000800
local TYPE_PET = COMBATLOG_OBJECT_TYPE_PET or 0x00001000
local TYPE_GUARDIAN = COMBATLOG_OBJECT_TYPE_GUARDIAN or 0x00002000
local PET_SOURCE_MASK = 0x1111

local SWING_SUBEVENTS = {
    SWING_DAMAGE = true,
    SWING_MISSED = true,
}

local SPELL_SUBEVENTS = {
    SPELL_DAMAGE = true,
    SPELL_PERIODIC_DAMAGE = true,
    SPELL_BUILDING_DAMAGE = true,
    RANGE_DAMAGE = true,
    SPELL_MISSED = true,
    RANGE_MISSED = true,
}

local MISS_DISPLAY = {
    ABSORB = "ABSORB",
    BLOCK = "BLOCK",
    DEFLECT = "DEFLECT",
    DODGE = "DODGE",
    EVADE = "EVADE",
    IMMUNE = "IMMUNE",
    MISS = "MISS",
    PARRY = "PARRY",
    REFLECT = "REFLECT",
    RESIST = "RESIST",
}

local function NormalizeFlags(flags)
    if type(flags) == "number" then
        return flags
    end
    if type(flags) == "string" then
        return tonumber(flags, 16) or tonumber(flags) or 0
    end
    return 0
end

local function FlagHasAll(flags, mask)
    flags = NormalizeFlags(flags)
    mask = NormalizeFlags(mask)
    if CombatLog_Object_IsA then
        return CombatLog_Object_IsA(flags, mask)
    end
    return bit.band(flags, mask) == mask
end

local function RefreshPlayerGUID()
    playerGUID = UnitGUID("player")
end

local function RememberOwnedPetGUID(guid)
    if guid then
        ownedPetGUIDs[guid] = true
    end
end

local function RememberPlayerSummonGUID(guid)
    if guid then
        playerSummonGUIDs[guid] = true
        RememberOwnedPetGUID(guid)
    end
end

local function RefreshOwnedPetGUIDs()
    RememberOwnedPetGUID(UnitGUID("pet"))
end

local function LivePetGUID()
    if UnitExists("pet") then
        return UnitGUID("pet")
    end
    return nil
end

local function HasPetGUIDPrefix(guid)
    return guid and guid:sub(1, 4) == "Pet-"
end

local function IsPetGUID(guid)
    if not guid then
        return false
    end
    local petGUID = LivePetGUID()
    return petGUID and guid == petGUID
end

local function IsKnownPetGUID(guid)
    if not guid then
        return false
    end
    if ownedPetGUIDs[guid] or playerSummonGUIDs[guid] then
        return true
    end
    if IsPetGUID(guid) then
        RememberOwnedPetGUID(guid)
        return true
    end
    return false
end

local function IsPlayerGUID(guid)
    if not guid or not playerGUID then
        return false
    end
    return guid == playerGUID
end

local function IsPetSource(sourceGUID, sourceFlags)
    if not sourceGUID or IsPlayerGUID(sourceGUID) then
        return false
    end

    if IsKnownPetGUID(sourceGUID) then
        return true
    end

    sourceFlags = NormalizeFlags(sourceFlags)
    if sourceFlags == 0 then
        return false
    end

    if FlagHasAll(sourceFlags, PET_SOURCE_MASK) then
        RememberOwnedPetGUID(sourceGUID)
        return true
    end

    if bit.band(sourceFlags, AFFILIATION_MINE) == 0 then
        return false
    end

    -- Pet- GUID is a type check only. Ownership is AFFILIATION_MINE (raid pets are RAID/PARTY).
    if HasPetGUIDPrefix(sourceGUID) then
        RememberOwnedPetGUID(sourceGUID)
        return true
    end

    if bit.band(sourceFlags, TYPE_GUARDIAN) ~= 0 then
        RememberOwnedPetGUID(sourceGUID)
        return true
    end

    -- Some Classic hunter pets report as player-controlled NPCs, not TYPE_PET.
    if bit.band(sourceFlags, TYPE_NPC) ~= 0 and bit.band(sourceFlags, CONTROL_PLAYER) ~= 0 then
        RememberOwnedPetGUID(sourceGUID)
        return true
    end

    if bit.band(sourceFlags, TYPE_PET) ~= 0 then
        RememberOwnedPetGUID(sourceGUID)
        return true
    end

    return false
end

local function IsAllowedSource(sourceGUID, sourceFlags)
    if IsPlayerGUID(sourceGUID) then
        return true
    end
    if BD.db and BD.db.includePetDamage and IsPetSource(sourceGUID, sourceFlags) then
        return true
    end
    return false
end

local function CacheNameplateToken(unit)
    if not unit or not BD.IsNameplateUnit(unit) then
        return
    end
    local guid = UnitGUID(unit)
    if guid then
        guidToToken[guid] = unit
    end
end

local function UncacheNameplateToken(unit)
    if not unit then
        return
    end
    -- Clear by token: UnitGUID can already be gone on REMOVED, and nameplate
    -- tokens are reused — a GUID-only clear leaves stale maps to neighbors.
    for guid, token in pairs(guidToToken) do
        if token == unit then
            guidToToken[guid] = nil
        end
    end
end

local function GetNameplateTokenForGUID(guid)
    if not guid then
        return nil
    end
    local cached = guidToToken[guid]
    if cached then
        if BD.GetNamePlateFrame(cached) and UnitGUID(cached) == guid then
            return cached
        end
        guidToToken[guid] = nil
    end
    if C_NamePlate and C_NamePlate.GetNamePlates then
        local ok, plates = pcall(C_NamePlate.GetNamePlates)
        if ok and plates then
            for _, plate in ipairs(plates) do
                local token = plate.namePlateUnitToken
                if token then
                    local plateGUID = UnitGUID(token)
                    if plateGUID then
                        guidToToken[plateGUID] = token
                        if plateGUID == guid then
                            return token
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function HandleIncomingMiss(missType)
    if not BD.db.showIncoming then
        return
    end
    local color = BD.INCOMING_COLOR
    local display = MISS_DISPLAY[missType] or missType or "MISS"
    BD:DebugPrint("incoming miss", display)
    BD:ShowIncoming(display, color[1], color[2], color[3], nil, false, "miss")
end

local function HandleIncomingDamage(amount, isCrit, school)
    if not BD.db.showIncoming then
        return
    end
    local color = BD.INCOMING_COLOR
    local display = BD.FormatAmount(amount, BD.db.abbreviate)
    local hitKind = isCrit and "crit" or "hit"
    BD:DebugPrint("incoming", display, hitKind)
    BD:ShowIncoming(display, color[1], color[2], color[3], nil, isCrit, hitKind)
end

local function IconForOutgoing(sourceGUID, spellId)
    if IsPlayerGUID(sourceGUID) then
        return spellId, nil
    end
    if not spellId or spellId == BD.AUTO_ATTACK_SPELL_ID then
        return nil, BD.GetPetIconTexture(sourceGUID)
    end
    return spellId, nil
end

local function ShowOutgoingOnPlate(unit, text, amount, isCrit, school, spellId, hitKind, spellIcon)
    if not BD:ShouldShowOutgoingHit(unit) then
        return
    end
    if hitKind ~= "miss" and not BD.PassesThreshold(amount, BD.db.minDamage) then
        return
    end

    local preset = BD:GetStylePreset()
    local r, g, b = BD.GetSchoolColor(school)
    if not BD:ShouldUseSchoolColors() then
        r, g, b = preset.defaultColor[1], preset.defaultColor[2], preset.defaultColor[3]
    end

    -- Classic: spellId from CLEU; pet melee uses the pet icon, not auto-attack.
    BD:ShowOnNameplate(unit, text, r, g, b, amount, isCrit, false, spellIcon, hitKind, spellId)
end

local function HandleSummon(sourceGUID, destGUID)
    if IsPlayerGUID(sourceGUID) and destGUID then
        RememberPlayerSummonGUID(destGUID)
        BD:DebugPrint("classic summon", destGUID)
    end
end

local function HandleSwing(subEvent, sourceGUID, sourceFlags, destGUID, amount, overkill, school, resisted, blocked, absorbed, critical)
    if not IsAllowedSource(sourceGUID, sourceFlags) then
        return
    end

    if IsPlayerGUID(destGUID) then
        if subEvent == "SWING_MISSED" then
            HandleIncomingMiss(amount)
        else
            HandleIncomingDamage(amount, critical, school)
        end
        return
    end

    local unit = GetNameplateTokenForGUID(destGUID)
    if not unit then
        return
    end

    if subEvent == "SWING_MISSED" then
        local display = MISS_DISPLAY[amount] or amount or "MISS"
        local missSpellId, missIcon = IconForOutgoing(sourceGUID, nil)
        ShowOutgoingOnPlate(unit, display, nil, false, school, missSpellId, "miss", missIcon)
        return
    end

    local display = BD.FormatAmount(amount, BD.db.abbreviate)
    local swingSpellId, swingIcon = IconForOutgoing(sourceGUID, BD.AUTO_ATTACK_SPELL_ID)
    ShowOutgoingOnPlate(unit, display, amount, critical, school, swingSpellId, critical and "crit" or "hit", swingIcon)
end

local function HandleSpell(subEvent, sourceGUID, sourceFlags, destGUID, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand, missType)
    if not IsAllowedSource(sourceGUID, sourceFlags) then
        return
    end

    if IsPlayerGUID(destGUID) then
        if subEvent == "SPELL_MISSED" or subEvent == "RANGE_MISSED" then
            HandleIncomingMiss(missType)
        else
            HandleIncomingDamage(amount, critical, school or spellSchool)
        end
        return
    end

    local unit = GetNameplateTokenForGUID(destGUID)
    if not unit then
        return
    end

    if subEvent == "SPELL_MISSED" or subEvent == "RANGE_MISSED" then
        local display = MISS_DISPLAY[missType] or missType or "MISS"
        local missSpellId, missIcon = IconForOutgoing(sourceGUID, spellId)
        ShowOutgoingOnPlate(unit, display, nil, false, spellSchool, missSpellId, "miss", missIcon)
        return
    end

    local display = BD.FormatAmount(amount, BD.db.abbreviate)
    local outSpellId, outIcon = IconForOutgoing(sourceGUID, spellId)
    ShowOutgoingOnPlate(unit, display, amount, critical, school or spellSchool, outSpellId, critical and "crit" or "hit", outIcon)
end

function BD:HandleClassicCombatLog()
    BD.API.AssertClassic("CombatClassic.HandleClassicCombatLog")

    if not self.db.enabled then
        return
    end

    if self.db.includePetDamage and UnitExists("pet") then
        RememberOwnedPetGUID(UnitGUID("pet"))
        BD.CacheLivePetIcon()
    end

    local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
        destGUID, destName, destFlags, destRaidFlags,
        arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24 =
        CombatLogGetCurrentEventInfo()

    if subEvent == "SPELL_SUMMON" then
        HandleSummon(sourceGUID, destGUID)
        return
    end

    if SWING_SUBEVENTS[subEvent] then
        HandleSwing(subEvent, sourceGUID, sourceFlags, destGUID, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
        return
    end

    if SPELL_SUBEVENTS[subEvent] then
        HandleSpell(
            subEvent,
            sourceGUID,
            sourceFlags,
            destGUID,
            arg12,
            arg13,
            arg14,
            arg15,
            arg16,
            arg17,
            arg18,
            arg19,
            arg20,
            arg21,
            arg22,
            arg23,
            arg24
        )
    end
end

function BD:OnClassicNamePlateAdded(unit)
    BD.API.AssertClassic("CombatClassic.OnClassicNamePlateAdded")
    CacheNameplateToken(unit)
end

function BD:OnClassicNamePlateRemoved(unit)
    BD.API.AssertClassic("CombatClassic.OnClassicNamePlateRemoved")
    UncacheNameplateToken(unit)
    BD:OrphanFramesForUnit(unit)
end

function BD:OnClassicPlayerLogin()
    BD.API.AssertClassic("CombatClassic.OnClassicPlayerLogin")
    RefreshPlayerGUID()
    RefreshOwnedPetGUIDs()
    BD.CacheLivePetIcon()
    wipe(guidToToken)
    wipe(playerSummonGUIDs)
    if C_NamePlate and C_NamePlate.GetNamePlates then
        local ok, plates = pcall(C_NamePlate.GetNamePlates)
        if ok and plates then
            for _, plate in ipairs(plates) do
                CacheNameplateToken(plate.namePlateUnitToken)
            end
        end
    end
end

function BD:OnClassicPlayerEnteringWorld()
    BD.API.AssertClassic("CombatClassic.OnClassicPlayerEnteringWorld")
    RefreshPlayerGUID()
    RefreshOwnedPetGUIDs()
end

function BD:OnClassicPetChanged()
    BD.API.AssertClassic("CombatClassic.OnClassicPetChanged")
    RefreshOwnedPetGUIDs()
    BD.CacheLivePetIcon()
end
