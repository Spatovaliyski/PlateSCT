-- Run from the addon root: lua tests/SettingsTransfer.lua (Lua 5.1).
-- No WoW installation or third-party Lua modules are required.
local passed = 0
local function eq(actual, expected, label)
    assert(actual == expected, (label or "value") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local function copy(source)
    local result = {}
    for key, value in pairs(source) do result[key] = value end
    return result
end
local function same(actual, expected)
    for key, value in pairs(expected) do eq(actual[key], value, key) end
    for key in pairs(actual) do eq(actual[key], expected[key], key) end
end
local function test(name, run)
    run()
    passed = passed + 1
    print("PASS " .. name)
end
local function load(path, BD) assert(loadfile(path))("PlateSCT", BD) end

bit = {}
function bit.band(a, b)
    local result, place = 0, 1
    while a > 0 and b > 0 do
        if a % 2 == 1 and b % 2 == 1 then result = result + place end
        a, b, place = math.floor(a / 2), math.floor(b / 2), place * 2
    end
    return result
end
function bit.bor(a, b, ...)
    local result = a + b - bit.band(a, b)
    if select("#", ...) > 0 then return bit.bor(result, ...) end
    return result
end
local frames, cvars, class = {}, {}, "MAGE"
function CreateFrame()
    local frame = { scripts = {} }
    function frame:SetScript(event, fn) self.scripts[event] = fn end
    function frame:RegisterEvent() end
    function frame:RegisterUnitEvent() end
    frames[#frames + 1] = frame
    return frame
end
function GetLocale() return "enUS" end
function GetAddOnMetadata() return "1.2.2" end
function UnitClass() return class, class end
function SetCVar(key, value) cvars[key] = value end
function CreateColor(...) return { ... } end
STANDARD_TEXT_FONT = "Fonts\\FRIZQT__.TTF"
StaticPopupDialogs = {}
Enum = { LuaCurveType = { Step = 1 } }
C_Timer = { After = function(_, callback) callback() end }
local function new(flavor)
    frames, cvars, class = {}, {}, "MAGE"
    C_CurveUtil = flavor == "modern" and {
        CreateColorCurve = function()
            return { points = {}, SetType = function() end,
                AddPoint = function(self, value, color) self.points[#self.points + 1] = { value, color } end }
        end,
    } or nil
    local BD = { API = {
        IsModern = function() return flavor == "modern" end,
        IsClassic = function() return flavor == "classic" end,
        ApplyFlavorDefaults = function(defaults)
            if flavor == "classic" then defaults.numberStyle, defaults.fontSize = "classic", 18 end
        end,
    } }
    load("Locales/Locale.lua", BD)
    load("Locales/enUS.lua", BD)
    load("Locales/frFR.lua", BD)
    load("Core/Constants.lua", BD)
    load("Core/Util.lua", BD)
    load("Core/Events.lua", BD)
    load("Core/SettingsTransfer.lua", BD)
    BD.db = copy(BD.DEFAULTS)
    PlateSCTDB = BD.db
    BD.effects = { scenario = 0, attribution = 0, panel = 0, minimap = 0 }
    function BD:RefreshScenario() self.effects.scenario = self.effects.scenario + 1 end
    function BD:ClearAttributionState() self.effects.attribution = self.effects.attribution + 1 end
    function BD:RebuildOptionsPanel() self.effects.panel = self.effects.panel + 1 end
    function BD:RefreshMinimapButton() self.effects.minimap = self.effects.minimap + 1 end
    return BD
end
local function modernKey(key)
    return key == "onlyMyDamage" or key == "allNameplates" or key:match("^attribution") or key:match("^schoolFilter")
end
local function localPreference(key)
    return key == "locale" or key == "settingsAnimations" or key == "showOptionsPreview"
end
local function configured(BD)
    local numbers = {
        combineWindow = 0.35,
        minDamage = 54321, fontSize = 25, incomingFontSize = 32, duration = 1.7, floatDistance = 85, scrollSpeed = 2.3,
        minimapAngle = -137.12345678901234, critSoundThreshold = 1234.56789, hugeCritSoundThreshold = 987654321,
    }
    local strings = {
        combineMode = "target",
        thousandSeparator = "dot", iconPosition = "bottom", fontFace = "lsm:字体 Français;%=!~ +",
        incomingFontFace = "lsm:Incoming font",
        numberStyle = "impact", impactPosition = "top", animHit = "rainfall", animCrit = "classicSlap",
        animMiss = "fountain", locale = "frFR", critSoundChannel = "Music", hugeCritSoundChannel = "SFX",
    }
    for key, value in pairs(BD.DEFAULTS) do
        if key ~= "layoutRevision" then
            if type(value) == "boolean" then BD.db[key] = not value
            elseif type(value) == "number" then BD.db[key] = numbers[key] or -37.5
            elseif type(value) == "string" then BD.db[key] = strings[key] or "strict" end
        end
    end
    -- A valid engaged-mode configuration and explicit manual school preferences.
    BD.db.onlyMyDamage, BD.db.allNameplates = false, true
    BD.db.schoolFilterRecommended = false
end

-- Golden fixtures have independently calculated checksums (Python zlib.adler32).
local CLASSIC_V1 = "!PlateSCT:1!addon=s:1.0.0;shared.enabled=b:0;shared.fontSize=n:22;source=s:classic!621b1c32"
local MODERN_V1 = "!PlateSCT:1!addon=s:1.0.0;modern.attributionManual=s:strict;shared.fontSize=n:24;source=s:modern!55b922a7"
-- Independently encoded using Python int.to_bytes / zlib.adler32, not the addon codec.
local CLASSIC_V2 = "PSCT2001QWE0shgQ5001vTW3LG22cd02cf"
local MODERN_V2 = "PSCT2019p2U0shgQj2OjoaR28DKwl27jnpS3LI55df061c"
-- Test writer deliberately builds arbitrary wire records to exercise the trust boundary.
local function wire(body, version)
    local payload = "!PlateSCT:" .. (version or "1") .. "!" .. body
    local a, b = 1, 0
    for index = 1, #payload do a = (a + payload:byte(index)) % 65521; b = (b + a) % 65521 end
    return payload .. "!" .. string.format("%08x", b * 65536 + a)
end
local function records(body, source)
    return wire("source=s:" .. (source or "modern") .. ";addon=s:1.0.0;" .. body)
end
local function reject(BD, text)
    local before, effects = copy(BD.db), copy(BD.effects)
    local identity = BD.db
    local preview, previewError = BD:PreviewSettingsImport(text)
    eq(preview, nil, "rejected preview"); eq(type(previewError), "string", "preview error")
    local result, err = BD:ImportSettings(text)
    eq(result, nil, "rejected import"); eq(type(err), "string", "import error")
    same(BD.db, before); same(BD.effects, effects); eq(BD.db, identity, "database identity")
end

for _, source in ipairs({ "classic", "modern" }) do
    for _, destination in ipairs({ "classic", "modern" }) do
        test(source .. " -> " .. destination .. " all settings", function()
            local sender = new(source)
            configured(sender)
            sender.db.obsoleteSetting = "not a preference"
            local original = copy(sender.db)
            local text = assert(sender:ExportSettings())
            assert(text:match("^PSCT2[A-Za-z0-9]+$"), "exports contain only letters and numbers")
            eq(text, assert(sender:ExportSettings()), "deterministic export")
            same(sender.db, original)
            local receiver = new(destination)
            local before, effects = copy(receiver.db), copy(receiver.effects)
            local identity = receiver.db
            local preview = assert(receiver:PreviewSettingsImport(text))
            eq(preview.values.layoutRevision, nil); eq(preview.values.obsoleteSetting, nil)
            if source == "classic" then
                for key in pairs(preview.values) do assert(not modernKey(key), "Classic export leaked " .. key) end
            end
            same(receiver.db, before); same(receiver.effects, effects)
            local result = assert(receiver:ImportSettings(text))
            eq(#result.ignored, source == "modern" and destination == "classic" and 18 or 0, "ignored count")
            eq(receiver.db, identity, "database identity"); eq(PlateSCTDB, identity, "saved database identity")
            for key in pairs(receiver.DEFAULTS) do
                local applicable = key ~= "layoutRevision" and not localPreference(key)
                    and (not modernKey(key) or (source == "modern" and destination == "modern"))
                local expected = before[key]
                if applicable then expected = original[key] end
                eq(receiver.db[key], expected, key)
                if applicable then eq(preview.values[key], original[key], "coverage " .. key) end
            end
            eq(receiver.effects.panel, 1); eq(receiver.effects.minimap, 1)
            eq(receiver.effects.scenario, destination == "modern" and 1 or 0)
            eq(receiver.effects.attribution, destination == "modern" and 1 or 0)
            eq(receiver:ResolveLocaleCode(), "enUS")
            eq(receiver.ResolveFontPath(), STANDARD_TEXT_FONT, "unavailable SharedMedia fallback")
            for _, cvar in ipairs(receiver.BLIZZ_FCT_CVARS) do eq(cvars[cvar], "1", "restore Blizzard text") end
            if destination == "modern" then eq(receiver:GetThresholdCurve().points[2][1], original.minDamage) end
            local priorEffects = copy(receiver.effects)
            eq(#assert(receiver:ImportSettings(text)).changes, 0, "idempotent import")
            same(receiver.effects, priorEffects)
        end)
    end
end

test("settings window preferences stay on this character", function()
    local sender = new("modern")
    sender.db.locale, sender.db.settingsAnimations, sender.db.showOptionsPreview = "frFR", false, false
    sender.db.fontSize = 31
    local text = assert(sender:ExportSettings())
    local preview = assert(sender:PreviewSettingsImport(text))
    eq(preview.values.locale, nil)
    eq(preview.values.settingsAnimations, nil)
    eq(preview.values.showOptionsPreview, nil)
    eq(preview.values.fontSize, 31)
    local receiver = new("classic")
    receiver.db.locale, receiver.db.settingsAnimations, receiver.db.showOptionsPreview = "deDE", true, true
    local old = records("shared.locale=s:frFR;shared.settingsAnimations=b:0;shared.showOptionsPreview=b:0;shared.fontSize=n:28")
    local result = assert(receiver:ImportSettings(old))
    eq(receiver.db.locale, "deDE")
    eq(receiver.db.settingsAnimations, true)
    eq(receiver.db.showOptionsPreview, true)
    eq(receiver.db.fontSize, 28)
    eq(#result.ignored, 3)
    local mixed = assert(receiver:ImportSettings(records("shared.locale=s:unknown;shared.fontSize=n:26")))
    eq(receiver.db.locale, "deDE")
    eq(receiver.db.fontSize, 26)
    eq(#mixed.ignored, 1)
end)

test("golden v1 fixtures preserve absent fields and migration revision", function()
    local BD = new("modern")
    BD.db.duration, BD.db.attributionManual, BD.db.layoutRevision = 3.1, "veryStrict", 42
    assert(BD:ImportSettings("\r\n " .. CLASSIC_V1 .. " \n"))
    eq(BD.db.enabled, false); eq(BD.db.fontSize, 22); eq(BD.db.duration, 3.1)
    eq(BD.db.attributionManual, "veryStrict"); eq(BD.db.layoutRevision, 42)
    assert(BD:ImportSettings(MODERN_V1))
    eq(BD.db.fontSize, 24); eq(BD.db.attributionManual, "strict"); eq(BD.db.layoutRevision, 42)
end)

test("unknown fields and incompatible Modern values are ignored", function()
    local BD = new("classic")
    local text = records("shared.fontSize=n:30;modern.attributionManual=s:futureMode;shared.futureFlag=b:0;future.newField=s:hello")
    local result = assert(BD:ImportSettings(text))
    eq(BD.db.fontSize, 30); eq(#result.ignored, 3)
    eq(BD.db.futureFlag, nil); eq(BD.db.attributionManual, BD.DEFAULTS.attributionManual)
    local modern = new("modern")
    reject(modern, text)
    local known = assert(modern:ImportSettings(records("shared.fontSize=n:30;shared.futureFlag=b:0")))
    eq(#known.ignored, 1)
end)

test("compact golden fixtures preserve stable IDs and skip future IDs", function()
    for _, flavor in ipairs({ "classic", "modern" }) do
        local BD = new(flavor)
        local priorMode, priorDuration = BD.db.onlyMyDamage, BD.db.duration
        assert(BD:ImportSettings("\n " .. CLASSIC_V2:sub(1, 12) .. "\n" .. CLASSIC_V2:sub(13) .. " \r\n"))
        eq(BD.db.enabled, false); eq(BD.db.fontSize, 22)
        eq(BD.db.onlyMyDamage, priorMode); eq(BD.db.duration, priorDuration)
        local result = assert(BD:ImportSettings(MODERN_V2))
        eq(BD.db.fontSize, 24)
        eq(BD.db.attributionManual, flavor == "modern" and "strict" or "balanced")
        eq(#result.ignored, flavor == "classic" and 1 or 0)
        result = assert(BD:ImportSettings("PSCT2001QWE0shgTI03PBzC29MIMs1qhs1a3LI5816063c"))
        eq(#result.ignored, 1); eq(BD.db.unknown200, nil); eq(BD.db.fontSize, 24)
    end
end)

test("compact corruption and malformed binary records are rejected atomically", function()
    local BD = new("modern")
    -- All binary-record fixtures below have valid, independently calculated checksums.
    for _, text in ipairs({
        "PSCT2001QWE0shgQ5000491ae90262", -- duplicate ID
        "PSCT2001QWE0shgQH00163e026c", -- wrong scope
        "PSCT2001QWE0shgQH2416be02ec", -- wrong source
        "PSCT2001QWE0shgQB0116330267", -- wrong value type
        "PSCT2001QWE0shgQB02IDZd0Fjb728a103ae", -- nonfinite number
        "PSCT2001QWE0shgQB02HwSm3HA250e0379", -- invalid number
        "PSCT2001QWE0shgQF00pPd1b200272", -- oversized string
        "PSCT2001QWE0shgQF03PBz76YF24c00399", -- incomplete string
        "PSCT2001QWE0shgQF03PBvA273W1g2cf903f8", -- control byte
        "PSCT2001QWE0shgQ52316a502df", -- invalid tag
        "PSCT2001QWE0shgQB13cc0266", -- incomplete record
        "PSCT2001QWE0shgQ40116250260", -- reserved ID
        "PSCT2001QWE0shgQB08G189c0268", -- empty number
        "PSCT2001QWE0shgQF03163d026d", -- empty string length
        "PSCT2001QWE0shgQF0CO18aa026d", -- empty long length
        "PSCT202IDYk0DFQG11740261", -- invalid source
        "PSCT2013079f01ae", -- invalid version length
        "PSCT20005f1016d", -- missing header
        "PSCT2zzzzzz00000000", -- Base62 block overflow
        "PSCT2A00000000", -- invalid Base62 block width
        "PSCT2!!!!!!!!00000000", -- invalid alphabet
        "PSCT3" .. CLASSIC_V2:sub(6), -- future format
        "PSCT2" .. string.rep("A", 32768), -- oversized input
    }) do reject(BD, text) end
    local text = assert(BD:ExportSettings())
    for _, length in ipairs({ 1, 4, 5, 6, #text - 8, #text - 1 }) do reject(BD, text:sub(1, length)) end
    local replacement = text:sub(6, 6) == "0" and "1" or "0"
    reject(BD, text:sub(1, 5) .. replacement .. text:sub(7))
    reject(BD, text .. "0")
end)

test("compact variable lengths and maximum font names round-trip losslessly", function()
    local BD = new("modern")
    for _, length in ipairs({ 1, 2, 3, 4, 5, 6, 7, 8, 1020 }) do
        local font = "lsm:" .. string.rep("x", length)
        BD.db.fontFace = font
        local text = assert(BD:ExportSettings())
        assert(text:match("^PSCT2[A-Za-z0-9]+$"))
        BD.db.fontFace = "game"
        assert(BD:ImportSettings(text))
        eq(BD.db.fontFace, font)
    end
    BD.db.fontFace = "lsm:" .. string.rep("x", 1021)
    eq(BD:ExportSettings(), nil)
end)

test("recommended schools preview without mutation and follow receiving class", function()
    local sender = new("modern")
    sender.db.schoolFilterEnabled, sender.db.schoolFilterRecommended = true, true
    class = "MAGE"; sender:ApplySchoolFilterRecommended()
    local text = assert(sender:ExportSettings())
    local receiver = new("modern")
    class = "WARRIOR"
    local before = copy(receiver.db)
    local preview = assert(receiver:PreviewSettingsImport(text))
    same(receiver.db, before); eq(preview.recommendedSchools, true)
    assert(receiver:ImportSettings(text))
    eq(receiver:SchoolFilterMatchesClass(), true)
    local expected = copy(receiver.db)
    local classic = new("classic")
    local classicText = assert(classic:ExportSettings())
    -- Restore target global class/runtime environment before applying the Classic export.
    class = "MAGE"
    assert(receiver:ImportSettings(classicText))
    for key in pairs(expected) do if modernKey(key) then eq(receiver.db[key], expected[key], key) end end
end)

test("both booleans, numeric boundaries, and Unicode strings", function()
    for _, flavor in ipairs({ "classic", "modern" }) do
        local BD = new(flavor)
        for _, value in ipairs({ false, true }) do
            BD.db.enabled, BD.db.showIncoming, BD.db.debug = value, value, value
            local text = assert(BD:ExportSettings())
            BD.db.enabled, BD.db.showIncoming, BD.db.debug = not value, not value, not value
            assert(BD:ImportSettings(text))
            eq(BD.db.enabled, value); eq(BD.db.showIncoming, value); eq(BD.db.debug, value)
        end
        assert(BD:ImportSettings(records("shared.fontSize=n:10;shared.duration=n:0.5;shared.retailOffsetX=n:-200;shared.minDamage=n:0")))
        assert(BD:ImportSettings(records("shared.fontSize=n:48;shared.duration=n:4;shared.retailOffsetX=n:200;shared.minDamage=n:1e+20")))
        eq(BD.db.minDamage, 1e20)
    end
end)

test("malformed and hostile strings never mutate settings or effects", function()
    local BD = new("modern")
    for _, text in ipairs({
        "", "return { enabled = true }", CLASSIC_V1:sub(1, -2), CLASSIC_V1 .. "!junk",
        CLASSIC_V1:gsub("fontSize=n:22", "fontSize=n:23"),
        records("shared.fontSize=n:25") .. string.rep(" ", 32769),
        records("shared.fontSize=n:25", "invalid"),
        wire("source=s:classic;shared.enabled=b:1"),
        wire("source=s:classic;addon=s:bad%7Cversion;shared.enabled=b:1"),
        records("shared.enabled=b:0;shared.enabled=b:1"),
        records("shared.fontSize=n:25;modern.fontSize=n:25"),
        records("shared.onlyMyDamage=b:0"), records("modern.onlyMyDamage=b:0", "classic"),
        records("shared.layoutRevision=n:999"), records("shared.fontSize=n:9"),
        records("shared.fontSize=n:49"), records("shared.enabled=n:1"),
        records("shared.duration=n:0"), records("shared.minDamage=n:-1"),
        records("shared.fontSize=n:1e999"), records("shared.fontSize=n:nan"),
        records("shared.fontSize=n:0x14"), records("shared.fontSize=n:1+1"),
        records("shared.animHit=s:classicSlap"),
        records("shared.fontFace=s:lsm%3A%ZZ"), records("shared.fontFace=s:lsm%3A%"),
        records("shared.fontFace=s:lsm%3A%00"), records("shared.fontFace=s:lsm%3Aunescaped space"),
        records("shared.fontFace=s:" .. string.rep("x", 1025)),
        records("shared.enabled=b:0;"), records("shared.enabled=b:2"),
        records("shared.enabled=f:function"),
        records("modern.onlyMyDamage=b:1;modern.allNameplates=b:1"),
    }) do
        reject(BD, text)
    end
    reject(BD, wire("source=s:modern;addon=s:1.0.0;shared.enabled=b:0", "2"))
    local fields = {}
    for index = 1, 255 do fields[#fields + 1] = "shared.future" .. index .. "=b:0" end
    reject(BD, records(table.concat(fields, ";")))
    reject(BD, nil)
    reject(BD, {})
end)

test("schema completeness and invalid local preferences fail safely", function()
    local BD = new("classic")
    BD.DEFAULTS.newPreference = true
    local text, err = BD:ExportSettings()
    eq(text, nil); eq(type(err), "string"); reject(BD, CLASSIC_V1)
    BD.DEFAULTS.newPreference = nil
    BD.db.duration = math.huge
    eq(BD:ExportSettings(), nil)
    BD.db.duration = 1
    BD.db.enabled = nil
    assert(BD:ExportSettings())
    eq(BD.db.enabled, nil, "export does not fill defaults into live state")
    local modern = new("modern")
    modern.db.onlyMyDamage, modern.db.allNameplates = true, true
    eq(modern:ExportSettings(), nil, "inconsistent damage mode")
end)

test("refresh failure rolls back data and retries runtime restoration", function()
    local BD = new("modern")
    local before, identity = copy(BD.db), BD.db
    local attempts = 0
    function BD:RebuildOptionsPanel()
        attempts = attempts + 1
        if attempts == 1 then error("simulated UI failure") end
    end
    local result, err, diagnostic = BD:ImportSettings(records("shared.fontSize=n:30;shared.hideBlizzardFCT=b:0;shared.minDamage=n:10"))
    eq(result, nil); eq(type(err), "string"); assert(diagnostic:find("simulated UI failure", 1, true))
    same(BD.db, before); eq(BD.db, identity); eq(attempts, 2)
    eq(BD:GetThresholdCurve(), nil)
    for _, cvar in ipairs(BD.BLIZZ_FCT_CVARS) do eq(cvars[cvar], "0", "rollback Blizzard text") end
end)

test("reset reuses refresh and imports persist through the login path", function()
    for _, flavor in ipairs({ "classic", "modern" }) do
        local BD = new(flavor)
        configured(BD)
        local original = copy(BD.db)
        local text = assert(BD:ExportSettings())
        BD:ResetToDefaults()
        same(BD.db, BD.DEFAULTS)
        assert(BD:ImportSettings(text))
        for _, frame in ipairs(frames) do
            if frame.scripts.OnEvent then frame.scripts.OnEvent(frame, "PLAYER_LOGIN") end
        end
        for key in pairs(BD.DEFAULTS) do
            if not modernKey(key) or flavor == "modern" then eq(BD.db[key], original[key], key) end
        end
    end
end)

test("all shipped Lua compiles and every new string is translated", function()
    local BD = new("classic")
    for line in io.lines("PlateSCT.toc") do
        line = line:gsub("\r$", "")
        if line:match("%.lua$") then assert(loadfile(line), line) end
    end
    for _, code in ipairs({ "frFR", "deDE", "esES", "ruRU", "itIT", "ptBR", "zhCN", "zhTW", "koKR" }) do
        load("Locales/" .. code .. ".lua", BD)
    end
    local strings, start = {}, false
    for line in io.lines("Locales/enUS.lua") do
        if line:find("-- Settings import / export", 1, true) then start = true end
        local key = start and line:match('^L%["(.-)"%]')
        if key then strings[#strings + 1] = key end
    end
    eq(#strings, 24, "translated key count")
    for code, translations in pairs(BD.LocaleTables) do
        for _, key in ipairs(strings) do
            local value = translations[key]
            assert(type(value) == "string" and value ~= "", code .. ": " .. key)
            local expected, actual = {}, {}
            for spec in key:gmatch("%%[ds]") do expected[#expected + 1] = spec end
            for spec in value:gmatch("%%[ds]") do actual[#actual + 1] = spec end
            eq(table.concat(actual), table.concat(expected), code .. " placeholders")
        end
    end
end)

test("dialog export, validation, editing, cancellation, and apply", function()
    local BD = new("classic")
    local original = copy(BD.db)
    local originalCreateFrame = CreateFrame
    local buttons, input, labels = {}, nil, {}
    local function noop() end
    local function frame(kind)
        local f = { scripts = {}, shown = true, enabled = true, text = "", height = 180, offset = 0 }
        for _, method in ipairs({ "SetAllPoints", "EnableMouse", "SetFrameLevel", "SetPoint", "SetColorTexture",
            "SetMultiLine", "SetTextInsets", "SetSpacing", "SetMaxLetters", "RegisterEvent", "SetTextColor",
            "UpdateScrollChildRect" }) do f[method] = noop end
        function f:SetSize(_, height) self.height = height end
        function f:SetHeight(height) self.height = height end
        function f:GetHeight() return self.height end
        function f:GetFrameLevel() return 1 end
        function f:CreateTexture() return frame("Texture") end
        function f:SetScript(event, fn) self.scripts[event] = fn end
        function f:Hide()
            local shown = self.shown
            self.shown = false
            if shown and self.scripts.OnHide then self.scripts.OnHide(self) end
        end
        function f:Show() self.shown = true end
        function f:IsShown() return self.shown end
        function f:SetShown(shown) if shown then self:Show() else self:Hide() end end
        function f:SetText(text)
            self.text = text
            if self.scripts.OnTextChanged then self.scripts.OnTextChanged(self, true) end
        end
        function f:GetText() return self.text end
        function f:SetFocus() self.focus = true end
        function f:ClearFocus() self.focus = false end
        function f:HighlightText() self.selected = true end
        function f:Disable() self.enabled = false end
        function f:SetEnabled(value) self.enabled = value end
        function f:IsEnabled() return self.enabled end
        function f:SetScrollChild(child) self.child = child end
        function f:SetVerticalScroll(value) self.offset = value end
        function f:GetVerticalScroll() return self.offset end
        return f
    end
    CreateFrame = frame
    BD.OptionsWidgets = {
        Backdrop = noop,
        Text = function(_, text)
            local f = frame("FontString"); f:SetText(text); labels[#labels + 1] = f; return f
        end,
        EditBox = function() input = frame("EditBox"); return input end,
        Button = function(_, label, _, _, click)
            local f = frame("Button"); f:SetText(label)
            function f:Click() if self.enabled then click() end end
            buttons[label] = f
            return f
        end,
        CloseButton = function() return frame("Button") end,
    }
    CANCEL, YES, NO = "Cancel", "Yes", "No"
    SlashCmdList, UISpecialFrames = {}, {}
    load("Options/Options.lua", BD)
    -- Reach the real dialog factory without constructing unrelated settings pages.
    local function upvalue(fn, name)
        for index = 1, 100 do
            local key, value = debug.getupvalue(fn, index)
            if key == name then return value end
            if not key then break end
        end
        error("Missing upvalue: " .. name)
    end
    local build = upvalue(BD.RegisterOptionsPanel, "BuildConfigFrame")
    local factory = upvalue(build, "CreateSettingsTransferDialog")
    local root = frame("Frame")
    root.searchBox = frame("EditBox")
    function root:DismissTransient() if self.transientMenu then self.transientMenu:Hide() end end
    -- Import should use the actual refresh path with only the settings panel stubbed.
    function BD:RebuildOptionsPanel() self.effects.panel = self.effects.panel + 1; root:DismissTransient() end
    local dialog = factory(root)
    local apply, validate, cancel = buttons["Apply settings"], buttons["Validate string"], buttons.Cancel
    dialog:Open(false)
    eq(input:GetText(), assert(BD:ExportSettings()), "copyable export")
    eq(input.selected, true); eq(input.focus, true); eq(apply:IsShown(), false)
    cancel:Click(); eq(dialog:IsShown(), false); same(BD.db, original)
    dialog:Open(true); eq(apply:IsEnabled(), false); eq(root.pageScrollLocked, true)
    input:SetText(CLASSIC_V1); validate:Click()
    eq(apply:IsEnabled(), true); eq(dialog.validatedText, CLASSIC_V1); same(BD.db, original)
    input:SetText("bad"); eq(apply:IsEnabled(), false); eq(dialog.validatedText, nil)
    validate:Click(); eq(apply:IsEnabled(), false); same(BD.db, original)
    input:SetText(CLASSIC_V1); validate:Click(); cancel:Click()
    same(BD.db, original); eq(root.pageScrollLocked, false); eq(input:GetText(), "")
    dialog:Open(true); input:SetText(CLASSIC_V1); validate:Click(); apply:Click()
    eq(BD.db.fontSize, 22); eq(BD.db.enabled, false); eq(dialog:IsShown(), false)
    eq(BD.effects.panel, 1); eq(root.pageScrollLocked, false)
    dialog:Open(true); input:SetText(CLASSIC_V1); validate:Click(); eq(apply:IsEnabled(), true, "no changes still clickable")
    input.scripts.OnEscapePressed(); eq(dialog:IsShown(), false); eq(input.focus, false)
    CreateFrame = originalCreateFrame
end)

print(string.format("%d settings transfer tests passed (%s).", passed, _VERSION))
