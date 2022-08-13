local ADDON_NAME, Mod = ...

-- Macro event listeners
local priestFrame = CreateFrame("Frame")
priestFrame:RegisterEvent("ADDON_LOADED")
priestFrame:SetScript("OnEvent", function (self, event, ...)
    local handler = self[event]

    if handler then 
        handler(self, ...)
    end
end)

local COVENANT_SPELLS = {
    [1] = "Boon of the Ascended",
    [2] = "Mindgames",
    [3] = "Fae Guardians",
    [4] = "Unholy Nova"
}

local COVENANT_ICON_IDS = {
    [1] = 3257748,
    [2] = 3586270,
    [3] = 3586268,
    [4] = 3257749
}

local POWER_INFUSION_ICON_ID = 135939

-- Legendary power ID source: https://wow.tools/dbc/?dbc=runeforgelegendaryability&build=9.2.5.43022
local POWER_INFUSION_LEGENDARY_ID = 147

local SPEC_IDS = {
    DISCIPLINE = 1,
    HOLY = 2,
    SHADOW = 3
}

local SPEC_SET_IDS = {
    [SPEC_IDS.DISCIPLINE] = 31,
    [SPEC_IDS.HOLY] = 32,
    [SPEC_IDS.SHADOW] = 33,
    ALL = 166
}

local ACTIVE_CONDUIT_STATE = 3

local POTENCY_CONDUIT_TYPE = 1

local CONDUIT_PROMPT_FRAME

local FOCUS_PROMPT_FRAME

local function SetupConduitPromptFrame(self)
    if CONDUIT_PROMPT_FRAME == nil then
        CONDUIT_PROMPT_FRAME = CreateFrame("Frame", "IncorrectConduitsPrompt", UIParent)

        -- Set size/position
        CONDUIT_PROMPT_FRAME:SetSize(64,64)
        CONDUIT_PROMPT_FRAME:SetPoint("CENTER")
        CONDUIT_PROMPT_FRAME:SetMovable(true)
        CONDUIT_PROMPT_FRAME:EnableMouse(true)
        CONDUIT_PROMPT_FRAME:RegisterForDrag("LeftButton")
        CONDUIT_PROMPT_FRAME:SetScript("OnDragStart", CONDUIT_PROMPT_FRAME.StartMoving)
        CONDUIT_PROMPT_FRAME:SetScript("OnDragStop", CONDUIT_PROMPT_FRAME.StopMovingOrSizing)

        -- Set the prompt text
        CONDUIT_PROMPT_FRAME.font = CONDUIT_PROMPT_FRAME:CreateFontString()
        CONDUIT_PROMPT_FRAME.font:SetPoint("Center", CONDUIT_PROMPT_FRAME, "Bottom", 0, -10)
        CONDUIT_PROMPT_FRAME.font:SetFont("Fonts/FRIZQT__.TTF", 18)
        CONDUIT_PROMPT_FRAME.font:SetText("Incorrect conduits!")

        -- Set the prompt texture
        CONDUIT_PROMPT_FRAME.texture = CONDUIT_PROMPT_FRAME:CreateTexture()
        CONDUIT_PROMPT_FRAME.texture:SetAllPoints(CONDUIT_PROMPT_FRAME)

        -- Make the button glow
        ActionButton_ShowOverlayGlow(CONDUIT_PROMPT_FRAME)
    end

    -- Determine the player's covenant ID so we can use the covenant icon in the texture
    local playerCovenantID = C_Covenants.GetActiveCovenantID()

    CONDUIT_PROMPT_FRAME.texture:SetTexture(COVENANT_ICON_IDS[playerCovenantID])
end

local function SetupFocusPromptFrame(self)
    if FOCUS_PROMPT_FRAME ~= nil then
        return;
    end

    FOCUS_PROMPT_FRAME = CreateFrame("Frame", "SetFocusPromptFrame", UIParent)

    -- Set size/position
    FOCUS_PROMPT_FRAME:SetSize(64,64)
    FOCUS_PROMPT_FRAME:SetPoint("CENTER")
    FOCUS_PROMPT_FRAME:SetMovable(true)
    FOCUS_PROMPT_FRAME:EnableMouse(true)
    FOCUS_PROMPT_FRAME:RegisterForDrag("LeftButton")
    FOCUS_PROMPT_FRAME:SetScript("OnDragStart", FOCUS_PROMPT_FRAME.StartMoving)
    FOCUS_PROMPT_FRAME:SetScript("OnDragStop", FOCUS_PROMPT_FRAME.StopMovingOrSizing)

    -- Set the prompt text
    FOCUS_PROMPT_FRAME.font = FOCUS_PROMPT_FRAME:CreateFontString()
    FOCUS_PROMPT_FRAME.font:SetPoint("Center", FOCUS_PROMPT_FRAME, "Bottom", 0, -10)
    FOCUS_PROMPT_FRAME.font:SetFont("Fonts/FRIZQT__.TTF", 18)
    FOCUS_PROMPT_FRAME.font:SetText("Set focus for PI!")

    -- Set the prompt texture
    FOCUS_PROMPT_FRAME.texture = FOCUS_PROMPT_FRAME:CreateTexture()
    FOCUS_PROMPT_FRAME.texture:SetAllPoints(FOCUS_PROMPT_FRAME)
    FOCUS_PROMPT_FRAME.texture:SetTexture(POWER_INFUSION_ICON_ID)

    -- Make the button glow
    ActionButton_ShowOverlayGlow(FOCUS_PROMPT_FRAME)
end

local function GetConduitName(conduitID)
    local conduitData = C_Soulbinds.GetConduitCollectionData(conduitID)

    if conduitData then
        return C_Item.GetItemNameByID(conduitData.conduitItemID)
    else
        return nil
    end
end

local function ShowIncorrectConduitsPrompt()
    if CONDUIT_PROMPT_FRAME == nil then
        SetupConduitPromptFrame()
    end

    CONDUIT_PROMPT_FRAME:Show();
end

local function HideIncorrectConduitsPrompt()
    if CONDUIT_PROMPT_FRAME ~= nil then
        CONDUIT_PROMPT_FRAME:Hide()
    end
end

local function CheckSoulbind(debug)
    local playerSpecId = GetSpecialization()
    local playerSpecSetID = SPEC_SET_IDS[playerSpecId]
    local soulbindData = C_Soulbinds.GetSoulbindData(C_Soulbinds.GetActiveSoulbindID())
    local hasIncorrectConduit = false

    for i, conduit in pairs(soulbindData.tree.nodes) do
        if conduit.state == ACTIVE_CONDUIT_STATE and conduit.conduitType == POTENCY_CONDUIT_TYPE then
            local conduitData = C_Soulbinds.GetConduitCollectionData(conduit.conduitID)
            local conduitSpecSetID = conduitData.conduitSpecSetID
            local isCorrect = conduitSpecSetID == playerSpecSetID or conduitSpecSetID == SPEC_SET_IDS.ALL
            local conduitName = GetConduitName(conduit.conduitID)

            if not isCorrect then
                hasIncorrectConduit = true

                if debug then
                    print("INCORRECT CONDUIT:", conduitName)
                    DevTools_Dump({
                        [1] = {
                            isCorrect = isCorrect,
                            conduitName = conduitName,
                            conduitSpecSetID = conduitSpecSetID or "nil",
                            playerSpecSetID = playerSpecSetID,
                            allSpecsSetId = SPEC_SET_IDS.ALL,
                            specSetIdsTable = SPEC_SET_IDS,
                            conduit = conduit
                        }
                    })
                end
            end
        end
    end

    if hasIncorrectConduit then
        ShowIncorrectConduitsPrompt()
    else
        HideIncorrectConduitsPrompt()
    end
end

local function PlayerIsWearingPowerInfusionLegendary()
    -- Twins can be equipped in Head, Neck and Shoulder slots
    local slots = {
        INVSLOT_HEAD,
        INVSLOT_NECK,
        INVSLOT_SHOULDER
    }

    for i = 1, #slots do
        local item = ItemLocation:CreateFromEquipmentSlot(slots[i])

        if item:IsValid() and C_LegendaryCrafting.IsRuneforgeLegendary(item) then
            local lego = C_LegendaryCrafting.GetRuneforgeLegendaryComponentInfo(item)

            if lego.powerID == POWER_INFUSION_LEGENDARY_ID then
                return true
            end
        end
    end

    return false
end

local function ShowFocusPrompt()
    if FOCUS_PROMPT_FRAME == nil then
        SetupFocusPromptFrame()
    end

    FOCUS_PROMPT_FRAME:Show();
end

local function HideFocusPrompt()
    if FOCUS_PROMPT_FRAME ~= nil then
        FOCUS_PROMPT_FRAME:Hide()
    end
end

local function CheckFocusFrame()
    HideFocusPrompt();

    -- Only show the frame in instances
    if not IsInInstance() then
        return;
    end

    -- If the player has a focus that isn't the player themselves, return early
    if UnitExists("focus") and not UnitIsUnit("focus", "player") then
        return;
    end

    local playerSpecId = GetSpecialization()
    -- The player should have a focus if they're healing or if they're wearing the PI legendary
    local shouldHaveFocus = 
        playerSpecId == SPEC_IDS.HOLY
        or playerSpecId == SPEC_IDS.DISCIPLINE
        or PlayerIsWearingPowerInfusionLegendary()
        -- and partySize > 1

    if shouldHaveFocus then
        -- Note: setting focus is a secure function, addons cannot set it automatically. We can only show a prompt.
        ShowFocusPrompt()
    end
end

function priestFrame:PVP_MATCH_ACTIVE(...)
    CheckFocusFrame()
    HideIncorrectConduitsPrompt()
end

function priestFrame:PLAYER_SPECIALIZATION_CHANGED(...)
    CheckSoulbind()
end

function priestFrame:SOULBIND_ACTIVATED(...)
    CheckSoulbind()
end

function priestFrame:COVENANT_CHOSEN(...)
    CheckSoulbind()
end

function priestFrame:PLAYER_FOCUS_CHANGED(...)
    CheckFocusFrame()
end

function priestFrame:PLAYER_ENTERING_WORLD(isInitialLogin, isReloading)
    if isInitialLogin or isReloading then
        CheckSoulbind()
    end

    CheckFocusFrame()
end

function priestFrame:ADDON_LOADED(addonName)
    if addonName ~= ADDON_NAME then
        return;
    end
    
    -- Only register events in this module if the player is the right class
    if UnitClassBase("player") ~= "PRIEST" then
        return;
    end

    -- Set up the prompt frames here so their previous position will be restored
    SetupConduitPromptFrame()
    SetupFocusPromptFrame()

    -- Set the Covenant spells table
    Mod.CLASS_MACRO_NAME = "Cov_Priest_DJUI"
    Mod.COVENANT_SPELLS_FOR_CLASS = COVENANT_SPELLS

    priestFrame:RegisterEvent("PVP_MATCH_ACTIVE")
    priestFrame:RegisterEvent("PVP_MATCH_INACTIVE")
    priestFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    priestFrame:RegisterEvent("SOULBIND_ACTIVATED")
    priestFrame:RegisterEvent("COVENANT_CHOSEN")
    priestFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    priestFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
end

function Mod:CheckSoulbind(debug)
    CheckSoulbind(debug)
end

function Mod:CheckFocus()
    CheckFocusFrame()
end
