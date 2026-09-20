if not HTCloneClassWrapped and type(_G.CloneClass) == "function" then
    HTCloneClassWrapped = true
    _G.CloneClass = function(class)
        if type(class) ~= "table" or rawget(class, "orig") then
            return
        end
        local orig = {}
        for k, v in pairs(class) do
            orig[k] = v
        end
        class.orig = orig
    end
end

local modPath = ModPath

local function stringReplace(string, search, replace)
    return string:gsub(search, replace)
end

modPath = stringReplace(modPath, "\\", "/")

if modPath:sub(-1, -1) == "/" then
    modPath = modPath:sub(1, -2)
end

dofile(modPath .. "/libraries/DebugLogClass.lua")
dofile(modPath .. "/libraries/HexStatus.lua")
dofile(modPath .. "/libraries/MohoWatermark.lua")

dofile(modPath .. "/classes/HT.lua")
dofile(modPath .. "/classes/Utils.lua")

HT.modPath = modPath
HT:loadSettings()

dofile(modPath .. "/classes/Tables.lua")
dofile(modPath .. "/classes/Aimbot.lua")
dofile(modPath .. "/classes/AntiCheatChecker.lua")
dofile(modPath .. "/classes/Construction.lua")
dofile(modPath .. "/classes/Dexterity.lua")
dofile(modPath .. "/classes/Instant.lua")
dofile(modPath .. "/classes/Keybinds.lua")
dofile(modPath .. "/classes/Mission.lua")
dofile(modPath .. "/classes/Player.lua")
dofile(modPath .. "/classes/Spawn.lua")
dofile(modPath .. "/classes/Team.lua")
dofile(modPath .. "/classes/Time.lua")
dofile(modPath .. "/classes/Troll.lua")
dofile(modPath .. "/classes/Unlocker.lua")
dofile(modPath .. "/classes/Updater.lua")
dofile(modPath .. "/classes/Extras.lua")
dofile(modPath .. "/classes/Reset.lua")

local function bootApply(fn)
    local ok, err = pcall(fn)
    if not ok and HT and HT.debugLogClass then
        pcall(function() HT.debugLogClass:log("Boot apply failed: " .. tostring(err)) end)
    end
end

bootApply(function() HT.Aimbot:loadSettings() end)
bootApply(function() HT.Team:registerHooks() end)

bootApply(function()
    HT.Dexterity.spinbotSpeed = HT:getSetting("spinbot_speed") or 720
    if HT:getSetting("enable_spinbot") then
        HT.Dexterity.enableSpinbot = true
    end
    HT.Dexterity:installSpinbotHook()
end)

bootApply(function() HT.Dexterity:setFullAuto(HT:getSetting("enable_full_auto") == true) end)

bootApply(function()
    HT.Dexterity.customFov = HT:getSetting("custom_fov") or 75
    HT.Dexterity:setCustomFov(HT:getSetting("enable_custom_fov"), false)
end)

bootApply(function() HT.Dexterity:setJumpMultiplier(HT:getSetting("jump_multiplier") or 1) end)
