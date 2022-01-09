local ADDON_NAME, Mod = ...
local PANDA_FOOD_ID = 120168
local IS_PANDA = false

local promptFrame;

local function SetupPromptFrame(self)
    if promptFrame ~= nil then
        return;
    end

    promptFrame = CreateFrame("Frame", "PandaFoodPrompt", UIParent)

    promptFrame:SetSize(64,64)
    promptFrame:SetPoint("CENTER")
    promptFrame:SetMovable(true)
    promptFrame:EnableMouse(true)
    promptFrame:RegisterForDrag("LeftButton")
    promptFrame:SetScript("OnDragStart", promptFrame.StartMoving)
    promptFrame:SetScript("OnDragStop", promptFrame.StopMovingOrSizing)

    -- Use the panda food icon as the prompt texture
    promptFrame.texture = promptFrame:CreateTexture()
    promptFrame.texture:SetAllPoints(promptFrame)
    promptFrame.texture:SetTexture(GetItemIcon(PANDA_FOOD_ID))

    -- Set the prompt text
    promptFrame.font = promptFrame:CreateFontString()
    promptFrame.font:SetFont("Fonts/FRIZQT__.TTF", 18)
    promptFrame.font:SetText("Restock panda food")
    promptFrame.font:SetPoint("Center", promptFrame, "Bottom", 0, -10)

    -- Make the button glow
    ActionButton_ShowOverlayGlow(promptFrame)
end

function Mod.CheckPandaFood(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...

        if addonName ~= ADDON_NAME then
            return;
        end

        -- Get the player's race and check if they're a panda
        local playerRaceId = select(3, UnitRace("player"))
        -- Race ID reference: https://wowpedia.fandom.com/wiki/API_UnitRace
        IS_PANDA = playerRaceId == 25 or playerRaceId == 26

        -- Unregister the ADDON_LOADED event
        self:UnregisterEvent("ADDON_LOADED")
    end

    if not IS_PANDA then
        return;
    end

    -- Only check food if the player is resting (e.g. in a city or inn)
    if not IsResting() then
        -- Hide the prompt if the player has left a rest area
        if promptFrame ~= nil then
            promptFrame:Hide()
        end

        return;
    end

    if promptFrame == nil then
        SetupPromptFrame(self)
    end

    -- Get the number of panda foods in the player's inventory
    local foodCount = GetItemCount(PANDA_FOOD_ID)

    if foodCount == 0 then
        promptFrame:Show()
    else
        promptFrame:Hide()
    end
end

-- Panda food event listeners
local foodFrame = CreateFrame("Frame")
foodFrame:RegisterEvent("ADDON_LOADED")
foodFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
foodFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
foodFrame:RegisterEvent("BAG_UPDATE_DELAYED")
foodFrame:SetScript("OnEvent", Mod.CheckPandaFood)
