local ADDON_NAME, Mod = ...

local function PrintHelp()
    print("Usage:")
    print("`/djui` to open the addon's configuration interface.")
    print("`/djui help` to show this help message.")
end

-- Feature: detect enemy Xan'shi Holy Priest rez lego in arenas
-- Feature: hide the raid unit frames when entering a big bg
-- Feature: provide a link to look up an enemy arena player on check-pvp.fr at the end of a match.
-- Feature: play a sound when an enemy/friendly dies in an arena match
-- Feature: mark arena members when zoning into an arena
-- Feature: mark healers and tank when zoning into an rbg
-- Feature: copy position of player/target/focus frames from one character to another
-- Feature: track rating delta across pvp queue session
-- Feature: display the name of the current covenant/soulbind/legendary when zoning into any instance (pve and pvp)
-- Feature: display warning when wearing pve trinkets in pvp and vice versa
-- Feature: hide the bagbar
-- Feature: add dark shadows to frames (lortui/sui)
-- Feature: update the Cov_Gen_DJUI macro icon when zoning in, using phial of serenity (to update quantity), and when changing covenants
--     Subfeature: Create the Cov_Gen_DJUI macro

-- Slash commands
SLASH_DJUI1 = "/djui"
function SlashCmdList.DJUI(msg, editBox)
    -- Trim the string and convert it to lowercase
    msg = string.gsub(msg, "^%s*(.-)%s*$", "%1"):lower()

    if msg == "mark" then
        local force = true
        Mod:MarkPlayers(force)
    elseif msg == "sync" then
        Mod:SyncFrames()
    elseif msg == "shaman rock show" then
        Mod:ShowShamanRockIcon()
    elseif msg == "shaman rock hide" then
        Mod:HideShamanRockIcon()
    elseif (msg == "sb" or msg == "soulbind" or msg == "conduits") then
        Mod:CheckSoulbind(true)
    elseif (msg == "focus") then
        Mod:CheckFocus()
    elseif msg == "gear" or msg == "gear show" or msg == "show gear" then
        Mod:ListAndShowGear()
    elseif msg == "gear hide" or msg == "hide gear" then
        Mod:HideGearList()
    elseif msg == "gear test" then
        Mod:CheckInPreparation()
    else
        PrintHelp()
    end
end
