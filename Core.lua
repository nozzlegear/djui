local function PrintHelp()
    print("Usage:")
    print("`/djui` to open the addon's configuration interface.")
    print("`/djui help` to show this help message.")
end

-- Feature: copy position of player/target/focus frames from one character to another
-- Feature: mark arena members when zoning into an arena
-- Feature: mark healers and tank when zoning into an rbg
-- Feature: display the name of the current covenant/soulbind/legendary when zoning into any instance (pve and pvp)
-- Feature: display warning when wearing pve trinkets in pvp and vice versa
-- Feature: hide the bagbar
-- Feature: add dark shadows to frames (lortui/sui)
-- Feature: update the Cov_Gen_DJUI macro icon when zoning in, using phial of serenity (to update quantity), and when changing covenants
--     Subfeature: Create the Cov_Gen_DJUI macro

-- Gets the Cov_Gen_DJUI macro index. Returns nil if it can't be found.
function GetGeneralCovenantMacroIndex()
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

function UpdateGeneralCovenantMacroIcon(self, event, ...)

    print(event)

    if event == "UPDATE_MACROS" then
        -- The player's macros have changed, update the macro index
        macroIndex = GetGeneralCovenantMacroIndex()
    elseif event == "COVENANT_CHOSEN" then
        -- The player has changed covenants, update the covenant id
        covId = ...
        -- This event fires before the player's spellbook has been updated with the new covenant spells, so we can't update the macro yet
        return
    elseif event == "UNIT_INVENTORY_CHANGED" then
        local unitTarget = ...

        if unitTarget ~= "player" then
            -- This event fires for party/raid members as well. We only care about the player.
            return
        end
    end

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
macroFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
macroFrame:RegisterEvent("COVENANT_CHOSEN")
macroFrame:RegisterEvent("SPELLS_CHANGED")
macroFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
macroFrame:RegisterEvent("UPDATE_MACROS")
macroFrame:SetScript("OnEvent", UpdateGeneralCovenantMacroIcon)

-- Slash commands
SLASH_DJUI1 = "/djui"
function SlashCmdList.DJUI(msg, editBox)
    -- Trim the string and convert it to lowercase
    msg = string.gsub(msg, "^%s*(.-)%s*$", "%1"):lower()

    if msg == "test" then
        print("No test function set.")
    else
        PrintHelp()
    end
end
