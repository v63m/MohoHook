if not HT:getSetting("enable_dlc_unlocker") then
    do return end
end

function WinSteamDLCManager:_check_dlc_data(dlc_data)
    return true
end

function WinEpicDLCManager:_check_dlc_data(dlc_data)
    return true
end

function WINDLCManager:_check_dlc_data(dlc_data)
    return true
end

function GenericDLCManager.has_raidww2_clan()
    return true
end

function GenericDLCManager.has_freed_old_hoxton()
    return true
end
