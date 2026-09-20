_G.CloneClass(BootupState)
function BootupState:at_enter()
    BootupState.orig.at_enter(self)

    -- Retry installs that were deferred during early startup because game
    -- classes (PlayerCamera, RaycastWeaponBase, ...) weren't loaded yet.
    if HT and HT.Dexterity then
        if HT.Dexterity.cameraHookPending then
            pcall(function() HT.Dexterity:_ensureCameraHook() end)
        end
        if HT.Dexterity.fullAutoApplyPending then
            pcall(function() HT.Dexterity:setFullAuto(HT:getSetting("enable_full_auto") == true) end)
        end
    end

    local bltData = HT:getBltData()
    bltData.keybinds = {}
    for _, value in pairs(HT.keybinds) do
        table.insert(bltData.keybinds, value)
    end
    HT:setBltData(bltData)

    if HT:getSetting("initialized_version") ~= HT.version then
        HT:init()
    else
        HT.Updater:checkForUpdate()
    end
end
