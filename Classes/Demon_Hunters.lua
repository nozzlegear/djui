local ADDON_NAME, Mod = ...

-- Macro event listeners
local classFrame = CreateFrame("Frame")
classFrame:RegisterEvent("ADDON_LOADED")
classFrame:SetScript("OnEvent", function (self, event, ...)
    local handler = self[event]

    if handler then 
        handler(self, ...)
    end
end)

local COVENANT_SPELLS = {
    [1] = "Elysian Decree",
    [2] = "Sinful Brand",
    [3] = "The Hunt",
    [4] = "Fodder to the Flame"
}

function classFrame:ADDON_LOADED(addonName)
    if addonName ~= ADDON_NAME then
        return;
    end
    
    -- Only register events in this module if the player is the right class
    if UnitClassBase("player") ~= "DEMONHUNTER" then
        return;
    end

    -- Set the Covenant spells table
    Mod.CLASS_MACRO_NAME = "Cov_DH_DJUI"
    Mod.COVENANT_SPELLS_FOR_CLASS = COVENANT_SPELLS
end
