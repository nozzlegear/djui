local ADDON_NAME, Mod = ...

local EARTH_ELEMENTAL_SPELL_ID = 198103
local EARTH_ELEMENTAL_FILE_ID

-- Macro event listeners
local shamanFrame = CreateFrame("Frame")
shamanFrame:RegisterEvent("ADDON_LOADED")
shamanFrame:SetScript("OnEvent", function (self, event, ...)
    local handler = self[event]

    if handler then 
        handler(self, ...)
    end
end)

local COVENANT_SPELLS = {
    [1] = "Vesper Totem",
    [2] = "Chain Harvest",
    [3] = "Fae Transfusion",
    [4] = "Primordial Wave"
}

local promptFrame
local isInPreparation

local function SetupPromptFrame(self)
    if promptFrame ~= nil then
        return;
    end

    promptFrame = CreateFrame("Frame", "TheRockPrompt", UIParent)

    promptFrame:SetSize(64,64)
    promptFrame:SetPoint("CENTER")
    promptFrame:SetMovable(true)
    promptFrame:EnableMouse(true)
    promptFrame:RegisterForDrag("LeftButton")
    promptFrame:SetScript("OnDragStart", promptFrame.StartMoving)
    promptFrame:SetScript("OnDragStop", promptFrame.StopMovingOrSizing)

    -- Use the earth elemental icon as the prompt texture
    promptFrame.texture = promptFrame:CreateTexture()
    promptFrame.texture:SetAllPoints(promptFrame)
    promptFrame.texture:SetTexture(EARTH_ELEMENTAL_FILE_ID)

    -- Set the prompt text
    promptFrame.font = promptFrame:CreateFontString()
    promptFrame.font:SetFont("Fonts/FRIZQT__.TTF", 18)
    promptFrame.font:SetText("ROCK FIRST GLOBAL")
    promptFrame.font:SetPoint("Center", promptFrame, "Bottom", 0, -10)

    -- Make the button glow
    ActionButton_ShowOverlayGlow(promptFrame)
end

function shamanFrame:ADDON_LOADED(addonName)
    if addonName ~= ADDON_NAME then
        return;
    end

    -- Get the file id for the Earth Elemental icon
    _, _, EARTH_ELEMENTAL_FILE_ID = GetSpellInfo(EARTH_ELEMENTAL_SPELL_ID)
    
    -- Only register events in this module if the player is a shaman
    if UnitClassBase("player") ~= "SHAMAN" then
        return;
    end
    -- Set the Covenant spells table
    Mod.CLASS_MACRO_NAME = "Cov_Shaman_DJUI"
    Mod.COVENANT_SPELLS_FOR_CLASS = COVENANT_SPELLS

    shamanFrame:RegisterEvent("PVP_MATCH_ACTIVE")
    shamanFrame:RegisterEvent("PVP_MATCH_INACTIVE")
end

function Mod:ShowShamanRockIcon()
    if promptFrame == nil then
        SetupPromptFrame(self)
    end

    promptFrame:Show()
    -- Play a sound to draw the player's attention
    PlaySoundFile("Interface/AddOns/djui/Resources/Sounds/the-rock.mp3", "Master")
end

function Mod:HideShamanRockIcon()
    if promptFrame ~= nil then
        promptFrame:Hide()
    end
end

function shamanFrame:PVP_MATCH_ACTIVE(...)
    -- Check if the player is in an arena
    local instanceName, instanceType = GetInstanceInfo()

    -- Register an event listener for the Earth Elemental cooldown
    if not shamanFrame:IsEventRegistered("SPELL_UPDATE_COOLDOWN") then
        shamanFrame:RegisterUnitEvent("SPELL_UPDATE_COOLDOWN")
    end

    if instanceType == "arena" then
        -- TODO: check if player is using the Deeptremor Stone legendary
        -- TODO: check if the player has the preparation buff and set isInPreparation = true

        -- Register an event listener for when the Preparation buff falls off
        if not shamanFrame:IsEventRegistered("UNIT_AURA") then
            shamanFrame:RegisterUnitEvent("UNIT_AURA")
        end
    
        C_Timer.After(60, function ()
            Mod:ShowShamanRockIcon()
            -- Start a 7 second timer to hide the icon
            C_Timer.After(7, function () 
                Mod:HideShamanRockIcon()
            end)
        end)
    else
        -- Register an event listener for when the player enters combat
        -- Note: there is a PLAYER_ENTER_COMBAT event but it only counts melee combat
        -- https://wowpedia.fandom.com/wiki/PLAYER_ENTER_COMBAT
        if not shamanFrame:IsEventRegistered("PLAYER_REGEN_DISABLED") then
            shamanFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        end
    end
end

function shamanFrame:PVP_MATCH_INACTIVE(...)
    -- Remove buff/cooldown event watchers until next match
    shamanFrame:UnregisterEvent("UNIT_AURA")
    shamanFrame:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
end

function shamanFrame:UNIT_AURA(unit, ...)
    -- TODO: check if the Preparation buff fell off
    if isInPreparation and preparationBuffExists then
        isInPreparation = false
        Mod:ShowShamanRockIcon()
    end
end

function shamanFrame:SPELL_UPDATE_COOLDOWN(unit, ...)
    -- TODO: check if earth ele is off cooldown
end

function shamanFrame:PLAYER_REGEN_DISABLED(...)

end
