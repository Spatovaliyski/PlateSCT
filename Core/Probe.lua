local _, BD = ...
local L = BD.L

local probeBuffer = {}
local probeDialog

local function ProbeArgToString(value)
    local ok, text = pcall(tostring, value)
    if ok and text ~= nil then
        return text
    end
    return "?"
end

local function ProbePrint(...)
    local count = select("#", ...)
    local parts = {}
    for index = 1, count do
        parts[index] = ProbeArgToString(select(index, ...))
    end
    probeBuffer[#probeBuffer + 1] = table.concat(parts, " ")
end

local function ShowProbeCopyDialog(text)
    if not probeDialog then
        local frame = CreateFrame("Frame", "PlateSCTProbeDialog", UIParent, "BackdropTemplate")
        frame:SetSize(560, 420)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("FULLSCREEN_DIALOG")
        frame:SetToplevel(true)
        frame:EnableMouse(true)
        frame:SetMovable(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            self:SetUserPlaced(false)
        end)
        tinsert(UISpecialFrames, "PlateSCTProbeDialog")
        if not frame.SetBackdrop then
            Mixin(frame, BackdropTemplateMixin)
        end
        frame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        frame:SetBackdropColor(0.07, 0.07, 0.08, 0.97)
        frame:SetBackdropBorderColor(0.38, 0.38, 0.40, 0.95)

        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -14)
        title:SetText(L["Meter probe"])

        local help = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        help:SetPoint("TOP", title, "BOTTOM", 0, -6)
        help:SetWidth(500)
        help:SetJustifyH("CENTER")
        help:SetTextColor(0.75, 0.75, 0.76)
        help:SetText(L["Click the box, Ctrl+A, then Ctrl+C, and paste it in chat."])

        local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 16, -58)
        scroll:SetPoint("BOTTOMRIGHT", -36, 48)

        local edit = CreateFrame("EditBox", nil, scroll)
        edit:SetMultiLine(true)
        edit:SetAutoFocus(false)
        edit:SetFontObject(ChatFontNormal)
        edit:SetWidth(490)
        edit:SetHeight(2000)
        edit:SetMaxLetters(20000)
        edit:SetScript("OnEscapePressed", function()
            frame:Hide()
        end)
        edit:SetScript("OnEditFocusGained", function(self)
            self:HighlightText()
        end)
        edit:SetScript("OnMouseUp", function(self)
            self:HighlightText()
        end)
        edit:SetScript("OnTextChanged", function(self, userInput)
            if userInput and self.lockedText and self:GetText() ~= self.lockedText then
                self:SetText(self.lockedText)
                self:HighlightText()
            end
        end)
        scroll:SetScrollChild(edit)
        frame.edit = edit
        frame.scroll = scroll

        local close = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        close:SetSize(96, 24)
        close:SetPoint("BOTTOM", 0, 14)
        close:SetText(CLOSE)
        close:SetScript("OnClick", function()
            frame:Hide()
        end)

        probeDialog = frame
    end

    probeDialog.edit.lockedText = text or ""
    probeDialog.edit:SetText(probeDialog.edit.lockedText)
    probeDialog:Show()
    probeDialog:Raise()
    probeDialog.edit:SetFocus()
    probeDialog.edit:HighlightText()
end

local function ProbeDescribe(value)
    if not BD.ValuePresent(value) then
        return "nil"
    end
    local secret = BD.IsSecret(value)
    local access = BD.CanAccessValue(value)
    local shown = "?"
    if access then
        local okType, kind = pcall(type, value)
        if okType and kind == "table" then
            local okLen, len = pcall(function()
                return #value
            end)
            shown = okLen and ("table#" .. tostring(len)) or "table"
        else
            local ok, text = pcall(tostring, value)
            shown = ok and text or "?"
        end
    elseif secret then
        shown = "secret"
    else
        local ok, text = pcall(tostring, value)
        shown = ok and text or "?"
    end
    return shown
        .. " secret="
        .. (secret and "yes" or "no")
        .. " access="
        .. (access and "yes" or "no")
end

local function ProbeNameplateMatches(creatureName)
    if not BD.ValuePresent(creatureName) then
        return "nil"
    end
    if not BD.CanAccessValue(creatureName) then
        return "secret-name, cannot compare"
    end
    local hits = {}
    local okPlates, plates = pcall(C_NamePlate.GetNamePlates)
    if okPlates and plates then
        for _, plate in ipairs(plates) do
            local token = plate.namePlateUnitToken
            if token then
                local okName, unitName = pcall(UnitName, token)
                if okName and BD.ValuePresent(unitName) then
                    local okEq, matches = pcall(function()
                        return unitName == creatureName
                    end)
                    if okEq and matches then
                        hits[#hits + 1] = token
                    end
                end
            end
        end
    end
    if #hits == 0 then
        return "no nameplate match"
    end
    return table.concat(hits, ", ")
end

local function ProbeSpellDetails(details)
    if not BD.ValuePresent(details) then
        ProbePrint("      details:", "nil")
        return
    end
    if BD.IsSecret(details) and not BD.CanAccessValue(details) then
        ProbePrint("      details:", ProbeDescribe(details))
        return
    end

    local okUnit, unitName = pcall(function()
        return details.unitName
    end)
    local okAmount, amount = pcall(function()
        return details.amount
    end)
    local okMob, isMob = pcall(function()
        return details.isMob
    end)
    local okPet, isPet = pcall(function()
        return details.isPet
    end)
    ProbePrint(
        "      details unitName=",
        okUnit and ProbeDescribe(unitName) or "err",
        "amount=",
        okAmount and ProbeDescribe(amount) or "err",
        "isMob=",
        okMob and ProbeDescribe(isMob) or "err",
        "isPet=",
        okPet and ProbeDescribe(isPet) or "err"
    )
    if okUnit then
        ProbePrint("      details nameplate:", ProbeNameplateMatches(unitName))
    end
end

local function ProbeCombatSpells(sessionSource)
    local ok, list = pcall(function()
        return sessionSource.combatSpells
    end)
    if not ok then
        ProbePrint("    combatSpells: error reading field")
        return
    end
    ProbePrint("    combatSpells:", ProbeDescribe(list))
    if not BD.ValuePresent(list) then
        return
    end

    local index = 0
    local okIterate = pcall(function()
        for _, damageSpell in ipairs(list) do
            index = index + 1
            if index > BD.METER_PROBE_MAX_SPELLS then
                ProbePrint("    ... truncated after", BD.METER_PROBE_MAX_SPELLS, "spells")
                break
            end
            local okID, spellID = pcall(function()
                return damageSpell.spellID
            end)
            local okTotal, totalAmount = pcall(function()
                return damageSpell.totalAmount
            end)
            local okCreature, creatureName = pcall(function()
                return damageSpell.creatureName
            end)
            local okDetails, details = pcall(function()
                return damageSpell.combatSpellDetails
            end)
            ProbePrint(
                "    [" .. index .. "] spellID=",
                okID and ProbeDescribe(spellID) or "err",
                "total=",
                okTotal and ProbeDescribe(totalAmount) or "err"
            )
            ProbePrint(
                "         creatureName=",
                okCreature and ProbeDescribe(creatureName) or "err",
                "plate=",
                okCreature and ProbeNameplateMatches(creatureName) or "err"
            )
            if okDetails then
                ProbeSpellDetails(details)
            end
        end
    end)
    if not okIterate then
        ProbePrint("    combatSpells: ipairs failed (likely secret table)")
    elseif index == 0 then
        ProbePrint("    combatSpells: empty list")
    end
end

local function ProbeSession(label, sessionType, sourceGUID)
    ProbePrint("  --", label, "sessionType=", sessionType)
    if not C_DamageMeter or not C_DamageMeter.GetCombatSessionSourceFromType then
        ProbePrint("    API missing")
        return
    end
    if not Enum or not Enum.DamageMeterType or Enum.DamageMeterType.DamageDone == nil then
        ProbePrint("    Enum.DamageMeterType.DamageDone missing")
        return
    end
    local ok, sessionSource = pcall(
        C_DamageMeter.GetCombatSessionSourceFromType,
        sessionType,
        Enum.DamageMeterType.DamageDone,
        sourceGUID
    )
    if not ok then
        ProbePrint("    GetCombatSessionSourceFromType error:", tostring(sessionSource))
        return
    end
    ProbePrint("    sessionSource:", ProbeDescribe(sessionSource))
    if not BD.ValuePresent(sessionSource) then
        return
    end
    local okTotal, totalAmount = pcall(function()
        return sessionSource.totalAmount
    end)
    ProbePrint("    source.totalAmount:", okTotal and ProbeDescribe(totalAmount) or "err")
    ProbeCombatSpells(sessionSource)
end

function BD:DumpDamageMeterProbe()
    wipe(probeBuffer)
    local stamp = tostring(time and time() or GetTime())
    if date then
        local ok, formatted = pcall(date, "%Y-%m-%d %H:%M:%S")
        if ok and formatted then
            stamp = formatted
        end
    end
    ProbePrint("----- dump start", stamp, "-----")
    ProbePrint(
        "combat=",
        BD.SafeUnitBoolean(InCombatLockdown) and "yes" or "no",
        "issecretvalue=",
        issecretvalue and "yes" or "no",
        "canaccessvalue=",
        canaccessvalue and "yes" or "no"
    )
    ProbePrint("C_DamageMeter=", C_DamageMeter and "yes" or "no")

    local overall = 0
    local current = 1
    if Enum and Enum.DamageMeterSessionType then
        if Enum.DamageMeterSessionType.Overall ~= nil then
            overall = Enum.DamageMeterSessionType.Overall
        end
        if Enum.DamageMeterSessionType.Current ~= nil then
            current = Enum.DamageMeterSessionType.Current
        end
    end
    ProbePrint("Overall=", overall, "Current=", current)

    local sources = {
        { "player", UnitGUID("player") },
        { "pet", UnitGUID("pet") },
        { "vehicle", UnitGUID("vehicle") },
    }
    local okTarget, targetName = pcall(UnitName, "target")
    ProbePrint("target=", okTarget and ProbeDescribe(targetName) or "err")

    for _, source in ipairs(sources) do
        local label, guid = source[1], source[2]
        if guid then
            ProbePrint(label, "GUID=", guid)
            ProbeSession("Overall", overall, guid)
            ProbeSession("Current", current, guid)
        else
            ProbePrint(label, "GUID=nil")
        end
    end
    ProbePrint("----- dump end -----")
    ShowProbeCopyDialog(table.concat(probeBuffer, "\n"))
end
