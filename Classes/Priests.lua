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

local PRIEST_COVENANT_SPELLS = {
    [1] = "Boon of the Ascended",
    [2] = "Mindgames",
    [3] = "Fae Guardians",
    [4] = "Unholy Nova"
}

local function UpdatePriestMacros(covenantId, classMacroIndex)
    local spellInfo = GetSpellInfo(PRIEST_COVENANT_SPELLS[covenantId])

    if spellInfo then 
        SetMacroSpell(classMacroIndex, spellInfo)
    end
end

function priestFrame:ADDON_LOADED(addonName)
    if addonName ~= ADDON_NAME then
        return;
    end
    
    -- Only register events in this module if the player is the right class
    if UnitClassBase("player") ~= "PRIEST" then
        return;
    end

    -- Set the UpdateClassMacros function
    function Mod:UpdateClassMacros(...)
        UpdatePriestMacros(...)
    end
    Mod.CLASS_MACRO_NAME = "Cov_Priest_DJUI"

    priestFrame:RegisterEvent("PVP_MATCH_ACTIVE")
    priestFrame:RegisterEvent("PVP_MATCH_INACTIVE")
end
