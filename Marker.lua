local ADDON_NAME, Mod = ...

local MAX_ICON_INDEX = 8
local CLASS_MARKS = {
    -- Stars
    ["ROGUE"] = 1,
    ["WARRIOR"] = 1,
    -- Circles
    ["DRUID"] = 2,
    -- Diamonds
    ["WARLOCK"] = 3,
    ["DEMONHUNTER"] = 3,
    ["PALADIN"] = 3,
    -- Triangles
    ["MONK"] = 4,
    ["HUNTER"] = 4,
    -- Moons
    ["PRIEST"] = 5,
    -- Squares
    ["SHAMAN"] = 6,
    ["MAGE"] = 6,
    -- CROSSES
    ["DEATHKNIGHT"] = 7
    -- Skulls
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PVP_MATCH_ACTIVE")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:SetScript("OnEvent", function (self, event, ...)
    local handler = self[event]
    handler(self, ...)
end)

function frame:ADDON_LOADED(addonName)
    if addonName ~= ADDON_NAME then
        return;
    end

    -- Register additional events here as needed
end

function frame:PVP_MATCH_ACTIVE(...)
    Mod:MarkPlayers()
end

function frame:GROUP_ROSTER_UPDATE(...)
    Mod:MarkPlayers()
end

local function GetClassMark(unitId)
    local className, classId = UnitClassBase(unitId)
    local mark = CLASS_MARKS[className]

    if mark == nil then
        print("WARNING: Could not find a class mark for class ", className, unitId)
        -- Return a skull which is not used by any class
        return 8
    end

    return mark
end

function Mod:MarkPlayers(force)
    -- Check which kind of instance the user is in
    local instanceName, instanceType = GetInstanceInfo()

    -- Only mark players if we're in an arena match or rbg
    if not force and instanceType ~= "arena" and instanceType ~= "ratedbg" then
        return;
    end

    -- Keep track of which marks have been used
    local usedMarks = { }
    -- Keep track of units that don't get assigned a mark on first pass because of duplicate mark usage
    local skippedUnits = { }

    local function TryMarkUnit(unit, markOverride)
        if not UnitExists(unit) then
            return;
        end

        -- Check if the unit is already using a mark
        local existingMark = GetRaidTargetIndex(unit)

        if existingMark then
            usedMarks[existingMark] = unit
            return;
        end

        -- Get the desired mark for this unit and apply it if it hasn't been used
        local mark = markOverride or GetClassMark(unit)

        if usedMarks[mark] == nil then
            print("Marking unit with icon", unit, mark)
            SetRaidTarget(unit, mark)
            usedMarks[mark] = unit
        else
            table.insert(skippedUnits, unit)
        end
    end

    if instanceType == "ratedbg" then 
        -- Only 10 players in RBGs
        for i = 1, 10 do
            local unit = "raid" .. i
            local role = UnitGroupRolesAssigned(unit)

            -- Only mark healers and tanks in RBGs
            if role == "HEALER" or role == "TANK" then
                TryMarkUnit("raid" .. i)
            end
        end
    else
        -- We mark all players in the party
        local units = {
            "player",
            "party1",
            "party2",
            "party3",
            "party4"
        }

        for i = 1, #units do
            TryMarkUnit(units[i])
        end
    end
    
    -- Iterate over any players who weren't assigned a mark because of duplicate classes
    -- (e.g. if two shamans, one was assigned a square and the other was skipped because it can't also be assigned a square)
    for key, unit in pairs(skippedUnits) do
        local unit = skippedUnits[i]
        -- Find a mark that hasn't been used yet
        for i = 1, MAX_ICON_INDEX do
            if not usedMarks[i] then
                TryMarkUnit(unit, i)
                break;
            end
        end
    end
end
