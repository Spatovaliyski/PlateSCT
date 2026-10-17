local _, BD = ...

BD.DEFAULTS = {
    enabled = true,
    minDamage = 0,
    critsOnly = false,
    shrinkSmallHits = false,
    smallHitPercent = 0.5, -- share of the recent average below which a hit is small
    ignoredSpells = "", -- comma-separated spell IDs or names
    abbreviate = false,
    thousandSeparator = "none", -- "none" | "comma" | "dot"
    showSpellIcon = false,
    spellLabel = "icon", -- "icon" | "name" | "both"
    spellNamePosition = "left", -- "above" | "below" | "left" | "right"
    spellNameScale = 0.7, -- name size relative to the number
    spellNameMaxLength = 0, -- characters before a name is shortened; 0 = never
    iconPosition = "left",
    fontSize = 14,
    duration = 1.0,
    floatDistance = 20,
    scrollSpeed = 1.0,
    fontFace = "game",
    fontOutline = "style", -- "style" | "none" | "thin" | "thick"
    hideBlizzardFCT = true,
    onlyMyDamage = true,
    personalSplash = false,
    allNameplates = false,
    includePetDamage = true,
    offTargetMode = "show", -- "show" | "dim" | "hide"
    offTargetScale = 0.75,
    offTargetAlpha = 0.5,
    showHealing = false,
    showIncoming = false,
    combineHits = false,
    combineWindow = 0.5,
    combineMode = "spell", -- "spell" | "target"
    combineShowCount = true,
    combinePulse = true, -- pop the number again each time a hit merges in
    incomingOffsetX = 0,
    incomingOffsetY = -100,
    debug = false,
    numberStyle = "retail", -- "retail", "classic", "impact": number styles, not API clients
    retailOffsetX = 0,
    retailOffsetY = 0,
    classicOffsetX = 0,
    classicOffsetY = 0,
    impactOffsetX = 0,
    impactOffsetY = 0,
    impactPosition = "side",
    useSchoolColors = false,
    useCustomColors = false,
    hitColor = "FFED00",
    critColor = "FF8C1A",
    missColor = "D9D9D9",
    animHit = "platesct",
    animCrit = "platesct",
    animMiss = "platesct",
    animAuto = "same", -- "same" follows animHit
    showCritLabel = false,
    showImpactCritLabel = true,
    showOptionsPreview = true,
    settingsAnimations = true,
    showMinimapButton = true,
    minimapAngle = 200,
    locale = "auto",
    layoutRevision = 13,
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

-- Auto-attack dropdown: follow normal hits, or pick its own motion.
BD.ANIM_STYLES_AUTO = {
    { id = "same", labelKey = "Same as normal hits", recommended = true },
    { id = "platesct", labelKey = "Vertical Up" },
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

BD.OFF_TARGET_MODES = {
    { id = "show", labelKey = "Show" },
    { id = "dim", labelKey = "Dim" },
    { id = "hide", labelKey = "Hide" },
}

-- Size of a shrunk small hit, relative to a normal one.
BD.SMALL_HIT_SCALE = 0.7

-- Scale pulse when a hit merges into a live number.
BD.COMBINE_PULSE_DURATION = 0.15
BD.COMBINE_PULSE_SCALE = 0.2

BD.COMBINE_MODES = {
    { id = "spell", labelKey = "Same spell" },
    { id = "target", labelKey = "All hits" },
}

BD.SPELL_LABEL_OPTIONS = {
    { id = "icon", labelKey = "Icon" },
    { id = "name", labelKey = "Name" },
    { id = "both", labelKey = "Icon and name" },
}

BD.SPELL_NAME_POSITIONS = {
    { id = "above", labelKey = "Top" },
    { id = "below", labelKey = "Bottom" },
    { id = "left", labelKey = "Left", recommended = true },
    { id = "right", labelKey = "Right" },
}

BD.OUTLINE_OPTIONS = {
    { id = "style", labelKey = "Number style default" },
    { id = "none", labelKey = "None" },
    { id = "thin", labelKey = "Thin" },
    { id = "thick", labelKey = "Thick" },
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
BD.GENERIC_PET_ICON = "Interface\\Icons\\Ability_Hunter_BeastTaming"
BD.POOL_SIZE = 24
BD.METER_PROBE_MAX_SPELLS = 6
BD.PENDING_CAP = 8

-- Personal splash (Modern): how long after a confirmed hit a same-school hit on another enemy
-- counts as yours, how many such hits one cast covers, and how long an early hit waits for its cast.
BD.SPLASH_WINDOW = 0.4
BD.SPLASH_HITS = 8
BD.SPLASH_QUEUE_DELAY = 0.15

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

-- Starting profiles. Applying one resets every setting, then applies these on top.
BD.PROFILES = {
    {
        id = "default",
        labelKey = "Default",
        descriptionKey = "Clean and minimal: numbers on your target in classic yellow. Every option at its default.",
        settings = {},
    },
    {
        id = "extended",
        labelKey = "Extended",
        descriptionKey = "Spell icons and short names, school colors, abbreviated numbers, combined rapid hits, fainter cleave on other enemies, and livelier motion.",
        settings = {
            offTargetMode = "dim",
            offTargetScale = 0.5,
            offTargetAlpha = 0.5,
            personalSplash = true, -- Modern Personal mode needs it to show cleave on other enemies
            showSpellIcon = true,
            spellLabel = "both",
            spellNamePosition = "left",
            spellNameScale = 0.5,
            spellNameMaxLength = 15,
            abbreviate = true,
            combineHits = true,
            useSchoolColors = true,
            animHit = "fountain",
            animMiss = "rainfall",
            -- Offsets are saved per number style; raise all three so the look holds in any style.
            retailOffsetY = 30,
            classicOffsetY = 30,
            impactOffsetY = 30,
        },
    },
}
