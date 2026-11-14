local _, BD = ...

-- Readability floor for settings text, spell icon counters and the debug window.
BD.MIN_FONT_SIZE = 13
-- Smallest Font size setting for combat numbers. Critical labels follow the number down.
BD.MIN_NUMBER_FONT_SIZE = 8

BD.DEFAULTS = {
    enabled = true,
    minDamage = 0,
    abbreviate = false,
    thousandSeparator = "none", -- "none" | "comma" | "dot"
    showSpellIcon = false,
    iconPosition = "left",
    fontSize = 14,
    duration = 1.0,
    floatDistance = 20,
    scrollSpeed = 1.0,
    fontFace = "game",
    incomingFontFace = "game",
    incomingFontSize = 14,
    onlyCriticalDamage = false,
    showMisses = true,
    hideBlizzardFCT = true,
    onlyMyDamage = true,
    allNameplates = false,
    includePetDamage = true,
    showDamageOverTime = true, -- Classic: SPELL_PERIODIC_DAMAGE; Modern Personal: hits past the cast window
    showHealing = false,
    showIncoming = false,
    combineHits = false,
    combineWindow = 0.5,
    combineMode = "spell", -- "spell" | "target"
    combineShowCount = true,
    combinePulse = true, -- pop the number again each time a hit merges in
    displayMode = "nameplates", -- "nameplates" | "screen": where outgoing numbers appear (Layout.lua)
    -- Screen area ids for each kind of number; the areas themselves are db.screenAreas.
    routeOutgoingHit = "outgoing",
    routeOutgoingCrit = "outgoing",
    routeOutgoingHeal = "outgoing",
    routeOutgoingMiss = "outgoing",
    routeIncomingHit = "incoming",
    routeIncomingCrit = "incoming",
    routeIncomingMiss = "incoming",
    debug = false,
    numberStyle = "retail", -- "retail", "classic", "impact": number styles, not API clients
    screenStyle = "linear", -- Legacy global style, retained for old settings strings; areas own animation now.
    retailOffsetX = 0,
    retailOffsetY = 0,
    classicOffsetX = 0,
    classicOffsetY = 0,
    impactOffsetX = 0,
    impactOffsetY = 0,
    impactPosition = "side",
    useSchoolColors = false,
    whiteAutoAttacks = true, -- auto attacks (melee swings, Auto Shot, wand Shoot) in BD.AUTO_ATTACK_COLOR
    animHit = "platesct",
    animCrit = "platesct",
    animMiss = "platesct",
    showCritLabel = false,
    showImpactCritLabel = true,
    showOptionsPreview = true,
    settingsAnimations = true,
    welcomeSeen = false,
    showMinimapButton = true,
    minimapAngle = 200,
    locale = "auto",
    layoutRevision = 17,
    attributionAuto = true,
    attributionManual = "balanced",
    attributionOpenWorld = "loose",
    attributionDungeon = "balanced",
    attributionRaid = "veryStrict",
    attributionBattleground = "strict",
    attributionArena = "balanced",
    critSoundEnabled = false,
    critSoundThreshold = 250,
    critSoundChannel = "Dialog",
    hugeCritSoundEnabled = false,
    hugeCritSoundThreshold = 3000,
    hugeCritSoundChannel = "Dialog",
    schoolFilterEnabled = false,
    schoolFilterRecommended = true,
    schoolFilterPhysical = true,
    schoolFilterHoly = true,
    schoolFilterFire = true,
    schoolFilterNature = true,
    schoolFilterFrost = true,
    schoolFilterShadow = true,
    schoolFilterArcane = true,
}

BD.INCOMING_COLOR = { 1.0, 0.32, 0.28 }
BD.HEAL_COLOR = { 0.25, 0.95, 0.35 }
BD.AUTO_ATTACK_COLOR = { 1.0, 1.0, 1.0 }

-- Built-in font faces. Paths are under the WoW install; "game" uses STANDARD_TEXT_FONT.
BD.BUILTIN_FONTS = {
    { id = "game", labelKey = "Game default" },
    { id = "friz", labelKey = "Friz Quadrata", path = "Fonts\\FRIZQT__.TTF" },
    { id = "arialn", labelKey = "Arial Narrow", path = "Fonts\\ARIALN.TTF" },
    { id = "skurri", labelKey = "Skurri", path = "Fonts\\skurri.ttf" },
    { id = "morpheus", labelKey = "Morpheus", path = "Fonts\\MORPHEUS.TTF" },
}

BD.ANIM_STYLES = {
    { id = "platesct", labelKey = "Vertical Up", recommended = true },
    { id = "fountain", labelKey = "Fountain" },
    { id = "rainfall", labelKey = "Rainfall" },
    { id = "verticalDown", labelKey = "Vertical Down" },
}

-- Crit dropdown includes Classic Slap (Classic grow-and-settle pow on Modern).
BD.ANIM_STYLES_CRIT = {
    { id = "platesct", labelKey = "Vertical Up", recommended = true },
    { id = "classicSlap", labelKey = "Classic Slap" },
    { id = "fountain", labelKey = "Fountain" },
    { id = "rainfall", labelKey = "Rainfall" },
    { id = "verticalDown", labelKey = "Vertical Down" },
}

BD.ICON_POSITIONS = {
    { id = "left", labelKey = "Left", recommended = true },
    { id = "right", labelKey = "Right" },
    { id = "top", labelKey = "Top" },
    { id = "bottom", labelKey = "Bottom" },
}

-- Scale pulse when a hit merges into a live number.
BD.COMBINE_PULSE_DURATION = 0.15
BD.COMBINE_PULSE_SCALE = 0.2

BD.COMBINE_MODES = {
    { id = "spell", labelKey = "Same spell" },
    { id = "target", labelKey = "All hits" },
}

BD.THOUSAND_SEPARATORS = {
    { id = "none", labelKey = "Off" },
    { id = "comma", labelKey = "Comma (10,000)" },
    { id = "dot", labelKey = "Dot (10.000)" },
}

BD.SOUND_CHANNELS = {
    { id = "Dialog", labelKey = "Dialog" },
    { id = "SFX", labelKey = "SFX" },
    { id = "Ambience", labelKey = "Ambience" },
    { id = "Music", labelKey = "Music" },
}

BD.STYLE_PRESETS = {
    -- Screen areas only (MSBT-style): steady scroll, no pop on hits, crits start large and
    -- settle, then everything fades over the last fifth of its trip.
    linear = {
        fontFlags = "OUTLINE",
        fontScale = 1.0,
        popScale = 1.0,
        popDuration = 0,
        fadeMode = "linear",
        fadeInRatio = 0,
        driftX = 0,
        useSchoolColors = false,
        defaultColor = { 1.0, 0.93, 0.0 },
        critColor = { 1.0, 0.93, 0.0 },
        critPopStartScale = 1.7,
        critSlapScale = 1.7,
        critRestScale = 1.3,
        critSlapDuration = 0.18,
        critSlapDrop = 0,
        durationMult = 1.0,
        critDurationMult = 1.0,
        floatMult = 1.0,
        animMode = "linear",
        critsHold = false,
        spawnLanes = {
            { 0, 0 },
            { 0, 18 },
            { 0, -18 },
            { 0, 36 },
            { 0, -36 },
        },
        spawnMinDist = 22,
        spawnMinDistCrit = 28,
        spawnJitter = 6,
        shadowOffset = { 1, -1 },
    },
    impact = {
        fontFlags = "OUTLINE",
        fontScale = 1.0,
        popScale = 1.0,
        popDuration = 0,
        fadeMode = "impact",
        fadeInRatio = 0,
        driftX = 0,
        useSchoolColors = false,
        defaultColor = { 1.0, 0.93, 0.0 },
        critColor = { 1.0, 0.93, 0.0 },
        critPopStartScale = 1.0,
        critSlapScale = 1.4,
        critRestScale = 1.2,
        durationMult = 1.0,
        critDurationMult = 1.1,
        floatMult = 1.0,
        animMode = "impactSlam",
        critsHold = false,
        spawnBaseX = 44,
        spawnBaseY = -26,
        spawnTopY = 26,
        spawnJitter = 3,
        shadowOffset = { 1, -1 },
    },
    retail = {
        fontFlags = "OUTLINE",
        fontScale = 1.0,
        popScale = 1.06,
        popDuration = 0.12,
        fadeMode = "smooth",
        fadePower = 1.35,
        fadeInRatio = 0.12,
        driftX = 0,
        useSchoolColors = false,
        defaultColor = { 1.0, 0.93, 0.0 },
        critColor = { 1.0, 0.93, 0.0 },
        critPopStartScale = 0.72,
        critRestScale = 1.26,
        critSlapScale = 1.50,
        critSlapDuration = 0.18,
        critSlapDrop = 0,
        durationMult = 1.0,
        floatMult = 1.85,
        critDurationMult = 1.1,
        animMode = "retailPop",
        critsHold = false,
        floatEase = "outCubic",
        spawnBaseY = -10,
        spawnLanes = {
            { 0, 0 },
            { 0, 14 },
            { 16, 6 },
            { -16, 6 },
            { 0, 26 },
            { 22, 18 },
            { -22, 18 },
        },
        spawnMinDist = 22,
        spawnMinDistCrit = 28,
        spawnJitter = 12,
        shadowOffset = { 1, -1 },
    },
    classic = {
        fontFlags = "THICKOUTLINE",
        fontScale = 1.0,
        popScale = 1.0,
        popDuration = 0,
        fadeMode = "inExpo",
        fadeInRatio = 0.3,
        driftX = 0,
        useSchoolColors = false,
        defaultColor = { 1.0, 0.93, 0.0 },
        critColor = { 1.0, 0.93, 0.0 },
        animMode = "classicPow",
        critsHold = true,
        critRestScale = 1.4,
        critPowStartScale = 1.0,
        critPowPeakScale = 2.0,
        critPowDuration = 0.2,
        durationMult = 1.0,
        floatMult = 1.0,
        critDurationMult = 1.6,
        floatEase = "outQuad",
        spawnBaseY = 36,
        spawnCritY = 8,
        -- Modest lanes: enough to unstack AOE without flinging off the plate.
        spawnLanes = {
            { 0, 0 },
            { 18, 0 },
            { -18, 0 },
            { 0, 16 },
            { 14, 12 },
            { -14, 12 },
            { 0, 28 },
            { 24, 8 },
            { -24, 8 },
            { 12, 22 },
            { -12, 22 },
        },
        spawnMinDist = 22,
        spawnMinDistCrit = 28,
        spawnJitter = 10,
        shadowOffset = { 2, -2 },
    },
}

BD.BLIZZ_FCT_CVARS = {
    "enableFloatingCombatText",
    "floatingCombatTextCombatDamage_v2",
    "floatingCombatTextCombatDamageAllAutos_v2",
    "floatingCombatTextCombatHealing_v2",
    "floatingCombatTextCombatHealingAbsorbSelf_v2",
    "floatingCombatTextCombatHealingAbsorbTarget_v2",
    "floatingCombatTextCombatLogPeriodicSpells_v2",
    "floatingCombatTextPetMeleeDamage_v2",
    "floatingCombatTextPetSpellDamage_v2",
    "floatingCombatTextDodgeParryMiss_v2",
    "floatingCombatTextDamageReduction_v2",
    "floatingCombatTextAuras_v2",
    "floatingCombatTextAuraFade_v2",
    "floatingCombatTextHonorGains_v2",
    "floatingCombatTextEnergyGains_v2",
    "floatingCombatTextPeriodicEnergyGains_v2",
    "floatingCombatTextReactives_v2",
    "floatingCombatTextFriendlyHealers_v2",
    "floatingCombatTextComboPoints_v2",
    "floatingCombatTextLowManaHealth_v2",
    "floatingCombatTextRepChanges_v2",
    "floatingCombatTextCombatState_v2",
    "floatingCombatTextFloatMode_v2",
    "floatingCombatTextCombatDamageDirectionalScale_v2",
    "floatingCombatTextCombatDamage",
    "floatingCombatTextCombatHealing",
    "floatingCombatTextCombatLogPeriodicSpells",
    "floatingCombatTextPetMeleeDamage",
    "floatingCombatTextPetSpellDamage",
}

BD.MISS_ACTIONS = {
    BLOCK = true,
    DODGE = true,
    PARRY = true,
    MISS = true,
    IMMUNE = true,
    DEFLECT = true,
    REFLECT = true,
    RESIST = true,
    ABSORB = true,
    EVADE = true,
}

BD.DAMAGE_SCHOOL_COLORS = {
    [1] = { 1.0, 0.93, 0.0 },
    [2] = { 1.0, 0.90, 0.50 },
    [4] = { 1.0, 0.50, 0.0 },
    [8] = { 0.30, 1.0, 0.30 },
    [16] = { 0.50, 1.0, 1.0 },
    [32] = { 0.50, 0.50, 1.0 },
    [64] = { 1.0, 0.50, 1.0 },
}

-- Physical=1, Holy=2, Fire=4, Nature=8, Frost=16, Shadow=32, Arcane=64
BD.DAMAGE_SCHOOLS = {
    { id = "physical", bit = 1, dbKey = "schoolFilterPhysical", labelKey = "Physical" },
    { id = "holy", bit = 2, dbKey = "schoolFilterHoly", labelKey = "Holy" },
    { id = "fire", bit = 4, dbKey = "schoolFilterFire", labelKey = "Fire" },
    { id = "nature", bit = 8, dbKey = "schoolFilterNature", labelKey = "Nature" },
    { id = "frost", bit = 16, dbKey = "schoolFilterFrost", labelKey = "Frost" },
    { id = "shadow", bit = 32, dbKey = "schoolFilterShadow", labelKey = "Shadow" },
    { id = "arcane", bit = 64, dbKey = "schoolFilterArcane", labelKey = "Arcane" },
}

BD.SCHOOL_MASK_ALL = 127
BD.SCHOOL_MASK_FIRE = 4
BD.SCHOOL_MASK_SHADOW = 32

-- Class-union Recommended masks (UnitClass file name). Unknown → all seven.
BD.CLASS_SCHOOL_MASKS = {
    DEATHKNIGHT = 1 + 16 + 32, -- Physical, Frost, Shadow
    DEMONHUNTER = 1 + 4 + 32, -- Physical, Fire, Shadow
    DRUID = 1 + 8 + 64, -- Physical, Nature, Arcane
    EVOKER = 4 + 8 + 64, -- Fire, Nature, Arcane
    HUNTER = 1 + 4 + 8 + 32 + 64, -- Physical, Fire, Nature, Shadow, Arcane
    MAGE = 4 + 16 + 64, -- Fire, Frost, Arcane
    MONK = 1 + 4 + 8, -- Physical, Fire, Nature
    PALADIN = 1 + 2 + 4, -- Physical, Holy, Fire
    PRIEST = 2 + 32, -- Holy, Shadow
    ROGUE = 1 + 8 + 32, -- Physical, Nature, Shadow
    SHAMAN = 1 + 4 + 8 + 16, -- Physical, Fire, Nature, Frost
    WARLOCK = 1 + 4 + 32, -- Physical, Fire, Shadow
    WARRIOR = 1 + 4 + 8, -- Physical, Fire, Nature
}

BD.AUTO_ATTACK_SPELL_ID = 6603
BD.AUTO_SHOT_SPELL_ID = 75
-- Your repeating attacks: Auto Attack, Auto Shot and wand Shoot. Their hits are auto attacks.
BD.AUTO_REPEAT_SPELL_IDS = {
    [6603] = true,
    [75] = true,
    [5019] = true,
}
-- Abilities that wait for your next melee swing and replace it (Classic-era ranks, as on Forever):
-- Heroic Strike, Cleave, Raptor Strike, Maul.
BD.NEXT_MELEE_SPELL_IDS = {}
for _, id in ipairs({
    78, 284, 285, 1608, 11564, 11565, 11566, 11567, 25286,
    845, 7369, 11608, 11609, 20569,
    2973, 14260, 14261, 14262, 14263, 14264, 14265, 14266,
    6807, 6808, 6809, 8972, 9745, 9880, 9881,
}) do
    BD.NEXT_MELEE_SPELL_IDS[id] = true
end
BD.GENERIC_PET_ICON = "Interface\\Icons\\Ability_Hunter_BeastTaming"
BD.POOL_SIZE = 24
-- Live numbers at most per enemy, on your target, and in total (Cap.lua).
BD.MAX_NUMBERS_PER_PLATE = 3
BD.MAX_NUMBERS_TARGET = 15
BD.MAX_NUMBERS = 40
-- Live numbers at most in one screen area; past it the oldest normal number gives way.
BD.MAX_NUMBERS_PER_AREA = 15
-- Seconds between checks that a number's plate still shows the same unit (Classic reuse signal).
BD.GUID_CHECK_INTERVAL = 0.1
-- Seconds between reads of a number's world position (kept for when its enemy dies; a fresh
-- one is also taken when its nameplate is removed).
BD.SNAPSHOT_INTERVAL = 0.25
BD.METER_PROBE_MAX_SPELLS = 6
BD.PENDING_CAP = 8

BD.STRICTNESS = {
    loose = {
        instantWindow = 0.80,
        castWindow = 0.60,
        hitsLeft = 8,
        linger = 8.0,
        destRequired = false,
        autoFallback = true,
        autoFallbackGap = 0.9,
        useThreatGate = false,
    },
    balanced = {
        instantWindow = 0.45,
        castWindow = 0.40,
        hitsLeft = 4,
        linger = 4.0,
        destRequired = false,
        autoFallback = true,
        autoFallbackGap = 1.2,
        useThreatGate = true,
    },
    strict = {
        instantWindow = 0.30,
        castWindow = 0.25,
        hitsLeft = 2,
        linger = 0,
        destRequired = true,
        autoFallback = false,
        autoFallbackGap = 1.2,
        useThreatGate = true,
    },
    veryStrict = {
        instantWindow = 0.18,
        castWindow = 0.15,
        hitsLeft = 1,
        linger = 0,
        destRequired = true,
        autoFallback = false,
        autoFallbackGap = 1.2,
        useThreatGate = true,
    },
}

BD.SCENARIO_DB_KEYS = {
    openWorld = "attributionOpenWorld",
    dungeon = "attributionDungeon",
    raid = "attributionRaid",
    battleground = "attributionBattleground",
    arena = "attributionArena",
}

BD.SCENARIO_ORDER = {
    "openWorld",
    "dungeon",
    "raid",
    "battleground",
    "arena",
}

BD.STRICTNESS_ORDER = {
    "loose",
    "balanced",
    "strict",
    "veryStrict",
}

if BD.API and BD.API.ApplyFlavorDefaults then
    BD.API.ApplyFlavorDefaults(BD.DEFAULTS)
end
BD.DEFAULTS.incomingFontSize = BD.DEFAULTS.fontSize
