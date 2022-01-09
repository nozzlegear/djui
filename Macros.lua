local ADDON_NAME, Mod = ...

-- Gets the Cov_Gen_DJUI macro index. Returns nil if it can't be found.
local function GetGeneralCovenantMacroIndex()
    for i = 1, GetNumMacros() do
        if GetMacroInfo(i) == "Cov_Gen_DJUI" then
            return i
        end
    end

    return nil
end

-- Get the index of the General Covenant macro once and only update it when macros change
local macroIndex = GetGeneralCovenantMacroIndex()
local covId = C_Covenants.GetActiveCovenantID()

function Mod.UpdateGeneralCovenantMacroIcon(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...

        if addonName ~= ADDON_NAME then
            return;
        end

        -- Unregister the ADDON_LOADED event
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "UPDATE_MACROS" then
        -- The player's macros have changed, update the macro index
        macroIndex = GetGeneralCovenantMacroIndex()
    elseif event == "COVENANT_CHOSEN" then
        -- The player has changed covenants, update the covenant id
        covId = ...
        -- This event fires before the player's spellbook has been updated with the new covenant spells, so we can't update the macro yet
        return
    elseif event == "SPELLS_CHANGED" then
        -- This event is extremely spammy in places like Torghast. Only update the macro if the player isn't in an instance where they for sure aren't changing covenants.
        if IsInInstance() then
            return
        end
    elseif event == "BAG_UPDATE_DELAYED" and covId ~= 1 then
        -- Bag was updated but the player is not Kyrian so it's not relevant
        return
    end

    print(event)

    if macroIndex then
        if covId == 1 then
            -- Kyrian, set the macro icon to Phial of Serenity
            local phialId = 177278
            SetMacroItem(macroIndex, GetItemInfo(phialId))
        elseif covId == 2 then
            -- Venthyr
            SetMacroSpell(macroIndex, GetSpellInfo("Door of Shadows"))
        elseif covId == 3 then
            -- Night Fae
            SetMacroSpell(macroIndex, GetSpellInfo("Soulshape"))
        elseif covId == 4 then
            -- Necrolord
            SetMacroSpell(macroIndex, GetSpellInfo("Fleshcraft"))
        end
    end
end

-- Macro event listeners
local macroFrame = CreateFrame("Frame")
macroFrame:RegisterEvent("ADDON_LOADED")
macroFrame:RegisterEvent("COVENANT_CHOSEN")
macroFrame:RegisterEvent("SPELLS_CHANGED")
macroFrame:RegisterEvent("BAG_UPDATE_DELAYED")
macroFrame:RegisterEvent("UPDATE_MACROS")
macroFrame:SetScript("OnEvent", Mod.UpdateGeneralCovenantMacroIcon)
