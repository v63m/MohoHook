HT = {}

HT.version = "1.2.4"
HT.threadUrl = ""

HT.supportedLocales = {
    "chs",
    "en",
    "es",
    "fr",
    "ru"
}

HT.modPath = nil
HT.settings = {}
HT.saveFilesNames = {}
HT.saveFilesNames.settings = "ut-settings.json"
HT.saveFilesNames.bltData = "blt_data.txt"

HT.colors = {
    white = Color("ffffff"),
    info = Color("0000ff"),
    success = Color("00ff00"),
    warning = Color("ffff00"),
    danger = Color("ff0000")
}

HT.keybinds = {
    {id = "UTKeybindOpenMenu", pc = "f1"},
    {id = "UTKeybindGodMode", pc = "f2"},
    {id = "UTKeybindSpawnBag", pc = "f3"},
    {id = "UTKeybindNoclip", pc = "f4"},
    {id = "UTKeybindResetAll", pc = "f5"},
    {id = "UTKeybindToggleStatus", pc = "f6"},
    {id = "UTKeybindToggleSpinbot", pc = "f7"},
    {id = "UTKeybindToggleAimbot", pc = ""},
    {id = "UTKeybindTeleport", pc = "h"},
    {id = "UTKeybindReplenish", pc = "right alt"},
    {id = "UTKeybindTest", pc = ""},
}

HT.fakeMaxInteger = 1000000000000000000000000000000

function HT:init()
    HT:setSetting("initialized_version", HT.version)
    if HT:getSetting("enable_anti_cheat_checker") == nil then
        HT:setSetting("enable_anti_cheat_checker", true)
    end

    local bltData = HT:getBltData()
    bltData.keybinds = {}
    for key, value in pairs(HT.keybinds) do
        table.insert(bltData.keybinds, value)
    end
    HT:setBltData(bltData)

    local title = HT:getLocalizedText("ut_popup_first_launch_title")
    local message = HT:getLocalizedText("ut_popup_first_launch_message")
    local options = {
        {
            text = "Continue",
            is_cancel_button = true
        },
        {
            text = HT:getLocalizedText("ut_exit"),
            callback = HT.exitGame
        }
    }
    QuickMenu:new("$$$ moho hook $$$ - " .. title, message, options):Show()
end

function HT:loadSettings()
    HT.settings = HT.Utils:getSaveTable(HT.saveFilesNames.settings)
    return true
end

function HT:saveSettings()
    return HT.Utils:setSaveTable(HT.saveFilesNames.settings, HT.settings)
end

function HT:getSetting(name)
    return HT.settings[name]
end

function HT:infiniteEquipmentToggle()
    if not HT:isInGame() then return end
    _G.CloneClass(PlayerManager)
    local is_infinite = HT:getSetting("infinite_equipment")
    if is_infinite then
        PlayerManager.remove_equipment = PlayerManager.orig.remove_equipment
        HT:setSetting("infinite_equipment", false)
    else
        function PlayerManager:remove_equipment() end
        HT:setSetting("infinite_equipment", true)
    end
    HT:saveSettings()
end

function HT.interactWithAnythingToggle()
    if not HT:isInGame() then return end
    _G.CloneClass(BaseInteractionExt)
    local is_interact = HT:getSetting("interact_with_anything")
    if is_interact then
        BaseInteractionExt.can_interact = BaseInteractionExt.orig.can_interact
        BaseInteractionExt.interact_start = BaseInteractionExt.orig.interact_start
        HT:setSetting("interact_with_anything", false)
    else
        function BaseInteractionExt:can_interact() return true end
        local orig_interact_start = BaseInteractionExt.orig.interact_start
        function BaseInteractionExt:interact_start(...)
            local ok, err = pcall(orig_interact_start, self, ...)
            if not ok then
            end
        end
        HT:setSetting("interact_with_anything", true)
    end
    HT:saveSettings()
end

function HT.bypassUpgradesToggle()
    if not HT:isInGame() then return end
    _G.CloneClass(BaseInteractionExt)
    local is_bypass = HT:getSetting("bypass_upgrades")
    if is_bypass then
        BaseInteractionExt._has_required_upgrade = BaseInteractionExt.orig._has_required_upgrade
        HT:setSetting("bypass_upgrades", false)
    else
        function BaseInteractionExt:_has_required_upgrade() return true end
        HT:setSetting("bypass_upgrades", true)
    end
    HT:saveSettings()
end

function HT:setSetting(name, value, save)
    HT.settings[name] = value
    if save or save == nil then
        HT:saveSettings()
    end
end

function HT:updateJsonValue(_json, key, value)
    local content = HT.Utils:readFile(HT.modPath .. "/menus/" .. _json .. ".json")
    if not content then return end
    local data = json.decode(content)
    if not data then return end

    for index, item in pairs(data.items) do
        if item.id == key then
            item.default_value = value
            break
        end
    end

    local file = io.open(HT.modPath .. "/menus/" .. _json .. ".json", "w")
    if file then
        file:write(json.encode(data))
        file:close()
    end
end

function HT:getBltData()
    return HT.Utils:getSaveTable(HT.saveFilesNames.bltData)
end

function HT:setBltData(data)
    return HT.Utils:setSaveTable(HT.saveFilesNames.bltData, data)
end

function HT:log(data)
    log(HT.Utils:toString(data))
end

function HT:getLocalizedText(stringId)
    return managers.localization:text(stringId)
end

function HT:setMenuToggle(item_id, value)
    pcall(function()
        local active_menu = managers.menu:active_menu()
        if not active_menu then return end
        local node = active_menu.logic:selected_node()
        if not node then return end
        for _, item in ipairs(node:items()) do
            local params = item:parameters()
            if params and (params.name == item_id or params.id == item_id) then
                item:set_value(value and "on" or "off")
                pcall(function()
                    local gui = active_menu.renderer
                    if gui and gui.reload_item then
                        gui:reload_item(item)
                    end
                end)
                return
            end
        end
    end)
end

function HT:addAlert(message, color, localized, highLightText, highLightColor)
    if localized or localized == nil then
        message = HT:getLocalizedText(message)
    end
    local parameters = {
        message = message,
        color = color or HT.colors.white,
        time = 5
    }
    if not localized then
        if highLightText then
            parameters.highlight_msg = highLightText
            parameters.highlight_color = highLightColor or HT.colors.white
        end
    end
    HT.debugLogClass:addNewLog(parameters)
end

function HT:showSubtitle(message, color)
    if not managers.mission then return end
    if type(message) ~= "string" then return end
    pcall(function()
        managers.mission:_show_debug_subtitle(message, color)
    end)
end

function HT:isUnitLoaded(name)
    return PackageManager:has(Idstring("unit"), name)
end

function HT:spawnUnit(name, position, rotation)
    if not HT:isUnitLoaded(name) then
        return false
    end
    return World:spawn_unit(name, position, rotation)
end

function HT:InteractType(interactTypes, --[[optional]]cheatEquipmentBoolean)
    local objects = {}
    local cheatEquipment = cheatEquipmentBoolean or false

    if cheatEquipment then
        HT:infiniteEquipmentToggle()
        HT:interactWithAnythingToggle()
    end

    for _,v in pairs(managers.interaction._interactive_units) do
        if table.contains(interactTypes, v:interaction().tweak_data) then
            table.insert(objects, v:interaction())
        end
    end

    for _,v in ipairs(objects) do
        v:interact(managers.player:player_unit())
    end

    if cheatEquipment then
        HT:infiniteEquipmentToggle()
        HT:interactWithAnythingToggle()
    end
end

function HT:removeUnit(unit)
    if not alive(unit) then return end
    World:delete_unit(unit)
    managers.network:session():send_to_peers_synched("remove_unit", unit)
end

function HT:removeUnits(units)
    for key, unit in pairs(units) do
        HT:removeUnit(unit)
    end
end

function HT:setUnitTeam(unit, team)
    if not alive(unit) then return end
    local teamId = tweak_data.levels:get_default_team_ID(team)
    local teamData = managers.groupai:state():team_data(teamId)
    unit:movement():set_team(teamData)
end

function HT:enableUnlimitedConversions()
    _G.CloneClass(PlayerManager)
    function PlayerManager:upgrade_value(category, upgrade, default)
        if category == "player" and upgrade == "convert_enemies" then
            return true
        elseif category == "player" and upgrade == "convert_enemies_max_minions" then
            return HT.fakeMaxInteger
        else
            return PlayerManager.orig.upgrade_value(self, category, upgrade, default)
        end
    end
end

function HT:isHost()
    return Network:is_server()
end

function HT:isInGame()
    return Utils:IsInGameState()
end

function HT:isInHeist()
    if not HT:isInGame() then return false end
    return Utils:IsInHeist()
end

function HT:isDriving()
    return game_state_machine:current_state_name() == "ingame_driving"
end

function HT:isInMenu()
    return managers.menu:is_active()
end

function HT:isInStartMenu()
    return game_state_machine:current_state_name() == "menu_main"
end

function HT:isInMultiPlayer()
    return Network:multiplayer()
end

function HT:getCrosshairRay()
    return Utils:GetCrosshairRay()
end

function HT:getPlayerPosition()
    return managers.player:player_unit():position()
end

function HT:getPlayerCameraPosition()
    return managers.player:player_unit():camera():position()
end

function HT:getPlayerCameraRotation()
    return managers.player:player_unit():camera():rotation()
end

function HT:getPlayerCameraRotationFlat()
    return Rotation(HT:getPlayerCameraRotation():yaw(), 0, 0)
end

function HT:getPlayerCameraForward()
    return managers.player:player_unit():camera():forward()
end

function HT:showHitMarker()
    if managers.hud and managers.hud.on_crit_confirmed then
        managers.hud:on_crit_confirmed()
    end
end

function HT:playSound(name)
    managers.menu_component:post_event(name)
end

function HT:teleportPlayer(position, rotation)
    managers.player:warp_to(position, rotation)
end

function HT:openSteamBrowser(url)
    Steam:overlay_activate("url", url)
end

function HT:openThread()
    HT:openSteamBrowser(HT.threadUrl)
end

function HT:exitGame()
    os.exit()
end

function HT:openMenu()
    managers.menu:open_menu("menu_pause")
    managers.menu:open_node("ut_main_menu")
end

function HT:reloadStartMenu()
    if HT:isInMultiPlayer() then
        MenuCallbackHandler:_dialog_leave_lobby_yes()
    end
    setup:load_start_menu()
end

function HT:setHideModsList(value)
    HT:setSetting("enable_hide_mods_list", value)
    if value then
        HT:addAlert("ut_alert_hide_mods_list_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_hide_mods_list_disabled", HT.colors.success)
    end
    HT:addAlert("ut_alert_restart_the_game_to_apply_changes", HT.colors.warning)
end
