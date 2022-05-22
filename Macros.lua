local ADDON_NAME, Mod = ...

local PHIAL_ITEM_ID = 177278

-- Macro event listeners
local macroFrame = CreateFrame("Frame")
macroFrame:RegisterEvent("ADDON_LOADED")
macroFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
macroFrame:RegisterEvent("COVENANT_CHOSEN")
macroFrame:RegisterEvent("SPELLS_CHANGED")
macroFrame:RegisterEvent("BAG_UPDATE_DELAYED")
macroFrame:RegisterEvent("UPDATE_MACROS")
macroFrame:SetScript("OnEvent", function (self, event, ...)
    local handler = self[event]

    Mod.UpdateGeneralCovenantMacroIcon(self, event, ...)
end)

-- Gets the Cov_Gen_DJUI and Cov_{CLASSNAME}_DJUI macro index. Returns a tuple containing both indexes, either of which may be nil if they can't be found.
local function GetMacroIndexes()
    local classMacroName = Mod.CLASS_MACRO_NAME or nil
    local genMacroIndex
    local classMacroIndex

    for i = 1, GetNumMacros() do
        local macroName = GetMacroInfo(i)

        if macroName == "Cov_Gen_DJUI" then
            genMacroIndex = i
        elseif macroName == classMacroName then
            classMacroIndex = i
        end
    end

    return genMacroIndex or nil, classMacroIndex or nil
end

local GENERAL_MACRO_SPELLS = {
    [1] = function () 
        local isItem = true
        local itemInfo = GetItemInfo(PHIAL_ITEM_ID)
        return isItem, itemInfo
    end,
    [2] = "Door of Shadows",
    [3] = "Soulshape",
    [4] = "Fleshcraft"
}
local GEN_MACRO_INDEX
local CLASS_MACRO_INDEX
local PLAYER_COVENANT_ID

function Mod.UpdateGeneralCovenantMacroIcon(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...

        if addonName ~= ADDON_NAME then
            return;
        end

        -- Get the macro indexes once and only update them when macros change
        GEN_MACRO_INDEX, CLASS_MACRO_INDEX = GetMacroIndexes()
        -- We get the covenant id here as well because it can be 0 (none) when the module loads
        PLAYER_COVENANT_ID = C_Covenants.GetActiveCovenantID()

        -- Unregister the ADDON_LOADED event
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Sometimes the covenant id still isn't set after ADDON_LOADED. Ensure it is set here.
        if PLAYER_COVENANT_ID == 0 or PLAYER_COVENANT_ID == nil then
            print("Attempting to get player covenant id for a second time")
            PLAYER_COVENANT_ID = C_Covenants.GetActiveCovenantID()
        end

        -- Unregister this event, we don't need to check this each time the player enters a loading screen
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    elseif event == "UPDATE_MACROS" then
        -- The player's macros have changed, update the macro index
        GEN_MACRO_INDEX, CLASS_MACRO_INDEX = GetMacroIndexes()
    elseif event == "COVENANT_CHOSEN" then
        -- The player has changed covenants, update the covenant id
        PLAYER_COVENANT_ID = ...
        -- This event fires before the player's spellbook has been updated with the new covenant spells, so we can't update the macro yet
        return
    elseif event == "SPELLS_CHANGED" then
        -- This event is extremely spammy in places like Torghast. Only update the macro if the player isn't in an instance where they for sure aren't changing covenants.
        if IsInInstance() then
            return
        end
    elseif event == "BAG_UPDATE_DELAYED" and PLAYER_COVENANT_ID ~= 1 then
        -- Bag was updated but the player is not Kyrian so it's not relevant
        return
    end

    -- Update the general macro
    if PLAYER_COVENANT_ID and GEN_MACRO_INDEX then
        local spell = GENERAL_MACRO_SPELLS[PLAYER_COVENANT_ID]
        local isItem = false
        local spellInfo

        if type(spell) == "function" then 
            isItem, spellInfo = spell() 
        else 
            spellInfo = GetSpellInfo(spell) 
        end

        if spellInfo and isItem then 
            SetMacroItem(GEN_MACRO_INDEX, spellInfo)
        elseif spellInfo then
            SetMacroSpell(GEN_MACRO_INDEX, spellInfo)
        end
    end

    -- Update the class-specific macro
    if PLAYER_COVENANT_ID and CLASS_MACRO_INDEX and Mod["COVENANT_SPELLS_FOR_CLASS"] then
        local covenantSpell = Mod.COVENANT_SPELLS_FOR_CLASS[PLAYER_COVENANT_ID]
        local spellInfo = GetSpellInfo(covenantSpell)

        if spellInfo then 
            SetMacroSpell(CLASS_MACRO_INDEX, spellInfo)
        end
    end
end
