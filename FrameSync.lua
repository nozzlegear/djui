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
    local fFrame = FocusFrame

    -- Prepare the scaling of each frame
    local pScale = 1.2
    local tScale = pScale
    -- Scale the focus frame to 0.75, which is like unchecking the "Larger Focus Frame" option
    local fScale = 0.75

    -- Widths and heights are the same for all frames. Scaling will make the focus frame smaller than the other frames
    local width = 232
    local height = 100

    -- The player and target frames share the same two anchors
    local pAnchor = "BOTTOM"
    local tAnchor = pAnchor
    -- The focus frame anchors to the center-bottom of the player frame. It should mirror the position of the TargetFrameToT 
    -- (target of target) frame
    local fAnchor1 = "CENTER"
    local fAnchor2 = "BOTTOM"

    -- Prepare the relatives for the frames. The player and target frames must anchor to WorldFrame rather than nil, 
    -- or else Blizzard's frames will throw an error on loading screens
    -- https://www.wowinterface.com/forums/showthread.php?p=332958
    local pRelativeTo = WorldFrame
    local tRelativeTo = pRelativeTo
    local fRelativeTo = pFrame

    -- Prepare the offsets for each frame
    -- TODO: get the following values from an options menu rather than hardcoding them
    local pOffsetX = -268
    local pOffsetY = 187
    local tOffsetX = pOffsetX * -1
    local tOffsetY = pOffsetY
    local fOffsetX = -105
    local fOffsetY = 0

    -- Clear all points for the frames before moving them, or else the movement will behave unexpectedly
    pFrame:ClearAllPoints()
    tFrame:ClearAllPoints()
    fFrame:ClearAllPoints()

    -- Set the points
    pFrame:SetPoint(pAnchor, pRelativeTo, pAnchor, pOffsetX, pOffsetY)
    tFrame:SetPoint(tAnchor, tRelativeTo, tAnchor, tOffsetX, tOffsetY)
    fFrame:SetPoint(fAnchor1, fRelativeTo, fAnchor2, fOffsetX, fOffsetY)

    -- Set the scale and size
    pFrame:SetScale(pScale)
    tFrame:SetScale(tScale)
    fFrame:SetScale(fScale)
    pFrame:SetSize(width, height)
    tFrame:SetSize(width, height)
    fFrame:SetSize(width, height)

    -- Configure the focus frame to use its "small size" which hides buffs and makes it more compact like the TargetFrameToT
    -- Source: https://github.com/tomrus88/BlizzardInterfaceCode/blob/37f825af8905fd317e1c49516c583ba41eac8a2e/Interface/FrameXML/TargetFrame.lua#L1249
    FocusFrame_SetSmallSize(true, false)
end
