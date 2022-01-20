local ADDON_NAME, Mod = ...

local syncFrame = CreateFrame("Frame")
syncFrame:RegisterEvent("ADDON_LOADED")
syncFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
syncFrame:SetScript("OnEvent", function (self, event, ...)
    local handler = self[event]

    handler(self, ...)
end)

function syncFrame:ADDON_LOADED(addonName, ...)
    if addonName ~= ADDON_NAME then
        return;
    end

    -- Register additional events here as needed
end

function syncFrame:PLAYER_ENTERING_WORLD(isInitialLogin)
    -- Moving the frames does not seem to be saved consistently. Sometimes they'll save their new position, sometimes they won't. 
    -- Sync the position manually when the player enters world. Must be done here, because if it's done during ADDON_LOADED it will break EasyFrames class colors (for some reason)
    Mod:SyncFrames()
end

function Mod:SyncFrames()
    local pFrame = PlayerFrame
    local tFrame = TargetFrame
    local scale = 1.2
    local width = 232
    local height = 100
    local anchor = "BOTTOM"
    -- Must anchor to WorldFrame rather than nil, or else Blizzard's frames will throw an error on loading screens
    -- https://www.wowinterface.com/forums/showthread.php?p=332958
    local relativeTo = WorldFrame
    -- TODO: get the following values from an options menu rather than hardcoding them
    local offsetY = 187
    local pFrameOffsetX = -268
    local tFrameOffsetX = 268

    -- Clear all points for the frames before moving them, or else the movement will behave unexpectedly
    pFrame:ClearAllPoints()
    tFrame:ClearAllPoints()

    -- Set the points
    pFrame:SetPoint(anchor, relativeTo, anchor, pFrameOffsetX, offsetY)
    tFrame:SetPoint(anchor, relativeTo, anchor, tFrameOffsetX, offsetY)

    -- Set the scale and size
    pFrame:SetScale(scale)
    tFrame:SetScale(scale)
    pFrame:SetSize(width, height)
    tFrame:SetSize(width, height)
end
