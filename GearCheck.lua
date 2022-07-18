local ADDON_NAME, Mod = ...

local PREPARATION_SPELL_IDS = {
    [44521] = "Preparation",
    [32727] = "Arena Preparation",
    [32728] = "Arena Preparation",
    [136116] = "Battleground Insight"
}

-- Event listeners
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function (self, event, ...)
    local handler = self[event]

    if handler then 
        handler(self, ...)
    end
end)

local gearTextFrame;

local function SetupFrame(self)
    if gearTextFrame ~= nil then
        return;
    end

    gearTextFrame = CreateFrame("Frame", "GearCheckFrame", UIParent)

    gearTextFrame:SetSize(64,64)
    gearTextFrame:SetPoint("CENTER")
    gearTextFrame:SetMovable(true)
    gearTextFrame:EnableMouse(true)
    gearTextFrame:RegisterForDrag("LeftButton")
    gearTextFrame:SetScript("OnDragStart", gearTextFrame.StartMoving)
    gearTextFrame:SetScript("OnDragStop", gearTextFrame.StopMovingOrSizing)

    -- Set the frame text
    gearTextFrame.font = gearTextFrame:CreateFontString()
    gearTextFrame.font:SetFont("Fonts/FRIZQT__.TTF", 18)
    gearTextFrame.font:SetText("Gear check frame")
    gearTextFrame.font:SetPoint("Center", gearTextFrame, "Bottom", 0, -10)
    gearTextFrame.font:SetJustifyH("RIGHT")

    Mod:HideGearList()
end

function Mod:ListAndShowGear()
    local gearList = ""

    for i = 1, 18 do
        local item = ItemLocation:CreateFromEquipmentSlot(i)
        local isValid = item:IsValid()
        
        -- Show the item name if it's a legendary or a trinket
        if isValid and C_LegendaryCrafting.IsRuneforgeLegendary(item) then
            local lego = C_LegendaryCrafting.GetRuneforgeLegendaryComponentInfo(item)
            local legoPower = C_LegendaryCrafting.GetRuneforgePowerInfo(lego.powerID)
            local matchesSpec = legoPower.matchesSpec
            local iconFileID = legoPower.iconFileID
        
            gearList = gearList .. "\n" .. legoPower.name
         elseif isValid and (i == 13 or i == 14) then
            local itemName = C_Item.GetItemName(item)
            gearList = gearList .. "\n" .. itemName
        end
    end

    if gearList ~= "" then
        gearTextFrame.font:SetText(gearList)
        gearTextFrame:Show()
    end
end

function Mod:HideGearList()
    gearTextFrame:Hide()
end

local function IsPreparationAura(auraInfo)
    local auraId

    if type(auraInfo) == "number" then
        auraId = auraInfo
    else
        auraId = auraInfo.spellId
    end

    -- Aura is one of the preparation auras if it can be found in the table of spell ids
    return PREPARATION_SPELL_IDS[auraId] ~= nil
end

local function PlayerIsInPreparation()
    -- This function can receive up to three arbitrary args passed to AuraUtil.FindAura, but we don't need that here.
    -- We just need to check that the aura id is a preparation aura id.
    local function isMatch(_, _, _, auraName, auraId)
        return IsPreparationAura(auraId)
    end

    return AuraUtil.FindAura(isMatch, "player", "HELPFUL") ~= nil
end

function Mod:CheckInPreparation()
    print("Player is in preparation? " .. (PlayerIsInPreparation() and "true" or "false"))
end

function eventFrame:UNIT_AURA(unitTarget, isFullUpdate, updatedAuras)
    if unitTarget ~= "player" or AuraUtil.ShouldSkipAuraUpdate(isFullUpdate, updatedAuras, IsPreparationAura) then
        return
    end

    if PlayerIsInPreparation() then
        Mod:ListAndShowGear()
    else
        Mod:HideGearList();
    end
end

function eventFrame:PLAYER_EQUIPMENT_CHANGED(...)
    Mod:ListAndShowGear()
end

function eventFrame:ADDON_LOADED(addonName)
    if addonName ~= ADDON_NAME then
        return;
    end

    -- Set up the text frame so its previous position will be restored
    SetupFrame()

    -- Text frame should only show during preparation in arenas, battlegrounds and solo shuffle
    eventFrame:RegisterEvent("PVP_MATCH_ACTIVE")
    eventFrame:RegisterEvent("PVP_MATCH_INACTIVE")
    eventFrame:RegisterEvent("UNIT_AURA")
    eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
end
