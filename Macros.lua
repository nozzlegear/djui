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

-- Gets the Cov_Gen_DJUI macro index. Returns nil if it can't be found.
local function GetGeneralCovenantMacroIndex()
    for i = 1, GetNumMacros() do
        if GetMacroInfo(i) == "Cov_Gen_DJUI" then
            return i
        end
    end

    return nil
end

local GEN_MACRO_INDEX
local PLAYER_COVENANT_ID

function Mod.UpdateGeneralCovenantMacroIcon(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...

        if addonName ~= ADDON_NAME then
            return;
        end

        -- Get the index of the General Covenant macro once and only update it when macros change
        GEN_MACRO_INDEX = GetGeneralCovenantMacroIndex()
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
        GEN_MACRO_INDEX = GetGeneralCovenantMacroIndex()
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

    if GEN_MACRO_INDEX then
        if PLAYER_COVENANT_ID == 1 then
            -- Kyrian, set the macro icon to Phial of Serenity
            SetMacroItem(GEN_MACRO_INDEX, GetItemInfo(PHIAL_ITEM_ID))
        elseif PLAYER_COVENANT_ID == 2 then
            -- Venthyr
            SetMacroSpell(GEN_MACRO_INDEX, GetSpellInfo("Door of Shadows"))
        elseif PLAYER_COVENANT_ID == 3 then
            -- Night Fae
            SetMacroSpell(GEN_MACRO_INDEX, GetSpellInfo("Soulshape"))
        elseif PLAYER_COVENANT_ID == 4 then
            -- Necrolord
            SetMacroSpell(GEN_MACRO_INDEX, GetSpellInfo("Fleshcraft"))
        else
            print("Unhandled Covenant ID:", PLAYER_COVENANT_ID)
        end
    end
end
