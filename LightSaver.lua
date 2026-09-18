LightSaverDB = LightSaverDB or {
    x = 0,
    y = 0,
    width = 25,
    title = 15,
    enabled = true
}

local mainFrame = CreateFrame("Frame", "LightSaver", UIParent)
mainFrame:SetSize(LightSaverDB.width, LightSaverDB.width * 2 + LightSaverDB.title)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", LightSaverDB.x, LightSaverDB.y)
mainFrame:SetFrameLevel(100)
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")

local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetText("li-se")
title:SetPoint("TOP", mainFrame, "TOP")
title:SetJustifyH("CENTER")

local topBox = CreateFrame("Frame", nil, mainFrame)
topBox:SetSize(LightSaverDB.width, LightSaverDB.width)
topBox:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -LightSaverDB.title)

local topTexture = topBox:CreateTexture(nil, "BACKGROUND")
topTexture:SetAllPoints()
topTexture:SetColorTexture(0, 0, 1)

local bottomBox = CreateFrame("Frame", nil, mainFrame)
bottomBox:SetSize(LightSaverDB.width, LightSaverDB.width)
bottomBox:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, 0)

local bottomTexture = bottomBox:CreateTexture(nil, "BACKGROUND")
bottomTexture:SetAllPoints()
bottomTexture:SetColorTexture(0, 0, 1)

mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)

mainFrame:RegisterEvent("PLAYER_LOGIN")
mainFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        print("|cff00ff00MyAddon: Light Saver loaded!|r")
    end
end)

patient = {
    name = nil,
    uid = nil,
}

local function FindUnitByGUID()
    if not patient.name then
        return nil
    end

    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local u = "raid" .. i

            print(u, " ", UnitName(u), " ", patient.name)

            if UnitExists(u) then
                if UnitName(u) == patient.name then
                    return u
                end
            end
        end
    end

    if IsInGroup() then
        for i = 1, GetNumGroupMembers() - 1 do
            local u = "party" .. i

            print(u, " ", UnitName(u), " ", patient.name)

            if UnitExists(u) then
                if UnitName(u) == patient.name then
                    return u
                end
            end
        end
    end
end

local function OnSpellCast(unit)
    if unit ~= "player" then
        return
    end

    if UnitExists("target") and UnitName("target") == UnitName("player") then
        patient.name = UnitName("player")
        patient.uid = "player"
    elseif UnitExists("target") and not UnitCanAttack("player", "target") then
        patient.name = UnitName("target")
        patient.uid = FindUnitByGUID()
    else
        patient.name = UnitName("player")
        patient.uid = "player"
    end

    --print("Каст в цель: ", patient.name, " | UID: ", patient.uid)
end

local function UpdateTopBoxColor()
    local maxHP = UnitHealthMax(patient.uid)
    local currentHP = UnitHealth(patient.uid)

    if not maxHP or maxHP <= 0 then
        return
    end

    if currentHP < maxHP - 2000 then
        topTexture:SetColorTexture(1, 0, 0)
    else
        topTexture:SetColorTexture(0, 1, 0)
    end
end

local function OnUnitHealth(unit)
    if patient.uid == nil then
        return
    end

    if unit == patient.uid then
        UpdateTopBoxColor()
    end
end

mainFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
mainFrame:RegisterEvent("UNIT_HEALTH")
mainFrame:SetScript("OnEvent", function(self, event, unit, ...)
    if event == "UNIT_SPELLCAST_SENT" then
        OnSpellCast(unit)
        OnUnitHealth(unit)
    elseif event == "UNIT_HEALTH" then
        OnUnitHealth(unit)
    end
end)

local function updateColor()
    local name, _, _, _, endTime = UnitCastingInfo("player")

    if not name then
        bottomTexture:SetColorTexture(0, 0, 1)
        return
    end

    if (endTime - GetTime() * 1000) < 100 then
        --print(endTime, " ", GetTime(), " ", endTime - GetTime() * 1000)
        bottomTexture:SetColorTexture(1, 0, 0)
    else
        bottomTexture:SetColorTexture(0, 1, 0)
    end
end

mainFrame:SetScript("OnUpdate", updateColor)
