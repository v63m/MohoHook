HT.Mission = {}

HT.Mission.enableDisableAi = false
HT.Mission.enableInvisiblePlayer = false
HT.Mission.carryVerifyDisabled = false
HT.Mission.enableFreezeCivilians = false

function HT.Mission:setInvisiblePlayer(value)
    HT.Mission.enableInvisiblePlayer = value
    if value then
        local player = managers.player:player_unit()
        if not alive(player) then
            return
        end
        local playerKey = player:key()
        local AiState = managers.groupai:state()
        for attention_object, data in pairs(AiState._attention_objects.all) do
            if playerKey == attention_object then
                AiState.backuped_attention_object = data
            end
        end
        AiState:unregister_AI_attention_object(player:key())
    else
        local player = managers.player:player_unit()
        if not alive(player) then
            return
        end
        local playerKey = player:key()
        local AiState = managers.groupai:state()
        AiState._attention_objects.all[playerKey] = AiState.backuped_attention_object
        AiState:on_AI_attention_changed(playerKey)
    end
    if value then
        HT:addAlert("ut_alert_invisible_player_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_invisible_player_disabled", HT.colors.success)
    end
end

function HT.Mission:accessCameras()
    game_state_machine:change_state_by_name("ingame_access_camera")
end

function HT.Mission:removeInvisibleWalls()
    local units = World:find_units_quick("all", 1)
    for key, unit in pairs(units) do
        if HT.Utils:inTable(unit:name():key(), HT.Tables.invisibleWalls) then
            HT:removeUnit(unit)
        end
    end
    HT:addAlert("ut_alert_invisible_walls_removed", HT.colors.success)
end

function HT.Mission:convertAllEnemies()
    HT:enableUnlimitedConversions()
    for key, data in pairs(managers.enemy:all_enemies()) do
        if not alive(data.unit) then
            goto continue
        end
        managers.groupai:state():convert_hostage_to_criminal(data.unit)
        managers.groupai:state():sync_converted_enemy(data.unit)
        ::continue::
    end
    HT:addAlert("ut_alert_converted_all_enemies", HT.colors.success)
end

function HT.Mission:nukeEnemies()
    if not HT:isInHeist() then
        HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
        return
    end
    if not HT:isHost() then
        HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
        return
    end

    local attacker = managers.player:player_unit()
    local count = 0

    pcall(function()
        for _, data in pairs(managers.enemy:all_enemies()) do
            if alive(data.unit) and data.unit:character_damage() and not data.unit:character_damage():dead() then
                data.unit:character_damage():damage_mission({
                    variant = "bullet",
                    damage = 1000000,
                    attacker_unit = attacker,
                    headshot = false
                })
                count = count + 1
            end
        end
    end)

    HT:addAlert("Enemies nuked", HT.colors.danger, false, tostring(count), HT.colors.white)
end

function HT.Mission:triggerAlarm()
    managers.groupai:state():on_police_called("empty")
    HT:addAlert("ut_alert_alarm_triggered", HT.colors.success)
end

function HT.Mission:setDisableAi(value)
    HT.Mission.enableDisableAi = value
    if not value then
        for key, value in pairs(managers.enemy:all_civilians()) do
            value.unit:brain():set_active(true)
        end

        for key, value in pairs(managers.enemy:all_enemies()) do
            value.unit:brain():set_active(true)
        end

        if SecurityCamera and SecurityCamera.cameras then
            for key, unit in pairs(SecurityCamera.cameras) do
                unit:base()._detection_interval = 0.1
            end
        end

        if managers.groupai:state():turrets() then
            for key, unit in pairs(managers.groupai:state():turrets()) do
                unit:brain():set_active(true)
            end
        end
    end
    if value then
        HT:addAlert("ut_alert_disable_ai_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_disable_ai_disabled", HT.colors.success)
    end
end

function HT.Mission:disableAi()
    for key, data in pairs(managers.enemy:all_civilians()) do
        if data.unit:brain():is_active() then
            data.unit:brain():set_active(false)
        end
    end

    for key, data in pairs(managers.enemy:all_enemies()) do
        if data.unit:brain():is_active() then
            data.unit:brain():set_active(false)
        end
    end

    if SecurityCamera and SecurityCamera.cameras then
        for key, unit in pairs(SecurityCamera.cameras) do
            if unit:base()._detection_interval ~= HT.fakeMaxInteger then
                unit:base()._detection_interval = HT.fakeMaxInteger
            end
        end
    end

    if managers.groupai:state():turrets() then
        for key, unit in pairs(managers.groupai:state():turrets()) do
            if unit:brain():is_active() then
                unit:brain():set_active(false)
            end
        end
    end
end

function HT.Mission:setInstantDrilling(value)
    _G.CloneClass(TimerGui)
    if value then
        function TimerGui:_set_jamming_values()
        end

        function TimerGui:start()
            local timer = 0.01
            self:_start(timer)
            managers.network:session():send_to_peers_synched("start_timer_gui", self._unit, timer)
        end
    else
        TimerGui._set_jamming_values = TimerGui.orig._set_jamming_values
        TimerGui.start = TimerGui.orig.start
    end
    if value then
        HT:addAlert("ut_alert_instant_drilling_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_instant_drilling_disabled", HT.colors.success)
    end
end

function HT.Mission:setPreventAlarmTriggering(value)
    _G.CloneClass(GroupAIStateBase)
    if value then
        function GroupAIStateBase:on_police_called()
        end
    else
        GroupAIStateBase.on_police_called = GroupAIStateBase.orig.on_police_called
    end
    if value then
        HT:addAlert("ut_alert_prevent_alarm_triggering_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_prevent_alarm_triggering_disabled", HT.colors.success)
    end
end

function HT.Mission:setUnlimitedPagers(value)
    if value then
        tweak_data.player.alarm_pager.bluff_success_chance = { 1, 1, 1, 1, 1 }
    else
        tweak_data.player.alarm_pager.bluff_success_chance = { 1, 1, 1, 1, 0 }
    end
    if value then
        HT:addAlert("ut_alert_unlimited_pagers_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_unlimited_pagers_disabled", HT.colors.success)
    end
end

function HT.Mission:setNoCivilianPenalty(value)
    HT:setSetting("enable_no_civilian_penalty", value)
    HT:updateJsonValue("mission", "ut_item_mission_toggle_no_civilian_penalty", value)

    _G.CloneClass(MoneyManager)
    if value then
        function MoneyManager:civilian_killed() end
    else
        MoneyManager.civilian_killed = MoneyManager.orig.civilian_killed
    end

    if value then
        HT:addAlert("ut_alert_no_civilian_penalty_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_no_civilian_penalty_disabled", HT.colors.success)
    end
end

function HT.Mission:setXray(value)
    if value then
        for key, data in pairs(managers.enemy:all_enemies()) do
            data.unit:contour():add("mark_enemy", false, HT.fakeMaxInteger)
        end
        for key, data in pairs(managers.enemy:all_civilians()) do
            data.unit:contour():add("mark_enemy", false, HT.fakeMaxInteger)
        end
        if SecurityCamera and SecurityCamera.cameras then
            for key, unit in pairs(SecurityCamera.cameras) do
                unit:contour():add("mark_unit", false, HT.fakeMaxInteger)
            end
        end
        _G.CloneClass(EnemyManager)
        function EnemyManager:register_enemy(unit, ...)
            EnemyManager.orig.register_enemy(self, unit, ...)
            unit:contour():add("mark_enemy", false, HT.fakeMaxInteger)
        end

        function EnemyManager:register_civilian(unit, ...)
            EnemyManager.orig.register_civilian(self, unit, ...)
            unit:contour():add("mark_enemy", false, HT.fakeMaxInteger)
        end

        function EnemyManager:on_enemy_died(unit, ...)
            EnemyManager.orig.on_enemy_died(self, unit, ...)
            unit:contour():remove("mark_enemy", false)
        end

        function EnemyManager:on_civilian_died(unit, ...)
            EnemyManager.orig.on_civilian_died(self, unit, ...)
            unit:contour():remove("mark_enemy", false)
        end
    else
        for key, data in pairs(managers.enemy:all_civilians()) do
            data.unit:contour():remove("mark_enemy", false)
        end
        for key, data in pairs(managers.enemy:all_enemies()) do
            data.unit:contour():remove("mark_enemy", false)
        end
        if SecurityCamera and SecurityCamera.cameras then
            for key, unit in pairs(SecurityCamera.cameras) do
                unit:contour():remove("mark_unit", false)
            end
        end
        EnemyManager.register_enemy = EnemyManager.orig.register_enemy
        EnemyManager.register_civilian = EnemyManager.orig.register_civilian
        EnemyManager.on_enemy_died = EnemyManager.orig.on_enemy_died
        EnemyManager.on_civilian_died = EnemyManager.orig.on_civilian_died
    end
    if value then
        HT:addAlert("ut_alert_xray_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_xray_disabled", HT.colors.success)
    end
end

function HT.Mission:disableCarryVerify()
    if HT.Mission.carryVerifyDisabled then return end
    _G.CloneClass(PlayerManager)
    function PlayerManager:verify_carry()
        return true
    end
    HT.Mission.carryVerifyDisabled = true
end

function HT.Mission:throwBag(carryId)
    if not HT:isInHeist() then
        HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
        return false
    end
    if not HT:isHost() then
        HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
        return false
    end

    HT.Mission:disableCarryVerify()

    local carryData = tweak_data.carry[carryId]
    if not carryData then
        HT:addAlert("ut_alert_spawn_unit_failure", HT.colors.danger)
        return false
    end

    local position = HT:getPlayerCameraPosition()
    local rotation = HT:getPlayerCameraRotation()
    local forward = HT:getPlayerCameraForward()
    local throwLevel = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)
    local localPeer = managers.network:session():local_peer()

    managers.player:server_drop_carry(carryId, 1, nil, nil, nil, position, rotation, forward, throwLevel, nil, localPeer)
    return true
end

function HT.Mission:spawnBagOfCurrentType()
    local carryId = "money"

    local carryData = managers.player:get_my_carry_data()
    if carryData and carryData.carry_id then
        carryId = carryData.carry_id
    end

    local ok = HT.Mission:throwBag(carryId)
    if ok then
        HT:addAlert("ut_alert_bag_spawned", HT.colors.success, false, carryId, HT.colors.white)
    end
end

function HT.Mission:spawnMoneyBag()
    local ok = HT.Mission:throwBag("money")
    if ok then HT:addAlert("ut_alert_money_bag_spawned", HT.colors.success) end
end

function HT.Mission:spawnGoldBag()
    local ok = HT.Mission:throwBag("gold")
    if ok then HT:addAlert("ut_alert_gold_bag_spawned", HT.colors.success) end
end

function HT.Mission:giveHeistXp()
    if not HT:isInHeist() then
        HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
        return
    end

    local ok = pcall(function()
        local currentLevel = managers.experience:current_level() or 0
        local levelCap = managers.experience:level_cap() or 100
        local targetLevel = math.min(currentLevel + 5, levelCap)

        if targetLevel > currentLevel then
            managers.experience:_set_current_level(targetLevel)
            if managers.experience._set_next_level_data_from_current then
                managers.experience:_set_next_level_data_from_current()
            end
        end
    end)

    if ok then
        HT:addAlert("ut_alert_heist_xp_given", HT.colors.success)
    else
        HT:addAlert("ut_alert_spawn_unit_failure", HT.colors.danger)
    end
end

function HT.Mission:getOutOfCustody()
    if not HT:isInHeist() then
        HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
        return
    end
    pcall(function()
        IngameWaitingForRespawnState.request_player_spawn()
    end)
    HT:addAlert("Escaping custody...", HT.colors.success, false)
end

HT.Mission.autoCookEnabled = false

local function ht_can_interact() return true end

local function ht_cook_interact(interaction_name)
    local player = managers.player:player_unit()
    if not alive(player) then return end
    for _, unit in pairs(managers.interaction._interactive_units) do
        local interaction = unit and unit:interaction()
        if interaction and interaction.tweak_data == interaction_name then
            interaction.can_interact = ht_can_interact
            interaction:interact(player)
            interaction.can_interact = nil
            break
        end
    end
end

local function ht_drop_bag()
    local carry_data = managers.player:get_my_carry_data()
    if not carry_data then return end
    local player = managers.player:player_unit()
    if not alive(player) then return end
    local pos = player:camera():position()
    local rot = player:camera():rotation()
    local fwd = player:camera():forward()
    if Network:is_server() then
        managers.player:server_drop_carry(carry_data.carry_id, carry_data.multiplier,
            carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier,
            pos, rot, fwd, 1, nil, managers.network:session():local_peer())
    else
        managers.network:session():send_to_host("server_drop_carry",
            carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated,
            carry_data.has_dye_pack, carry_data.dye_value_multiplier, pos, rot, fwd, 1, nil)
    end
    pcall(function() managers.player:set_player_state("standard") end)
end

function HT.Mission:enableAutoCook()
    if HT.Mission.autoCookEnabled then
        HT:addAlert("Auto cook already active", HT.colors.warning, false)
        return
    end
    HT.Mission.autoCookEnabled = true

    if not HT.Mission._dialog_backup then
        HT.Mission._dialog_backup = DialogManager.queue_dialog
    end
    function DialogManager:queue_dialog(id, params)
        HT.Mission._dialog_backup(self, id, params)
        if not HT.Mission.autoCookEnabled then return end
        if id == "pln_rt1_20" or id == "Play_loc_mex_cook_03" then
            ht_cook_interact("muriatic_acid")
            DelayedCalls:Add("ht_cook_step1", 0.3, function()
                ht_cook_interact("methlab_bubbling")
            end)
        elseif id == "pln_rt1_22" or id == "Play_loc_mex_cook_04" then
            ht_cook_interact("caustic_soda")
            DelayedCalls:Add("ht_cook_step2", 0.3, function()
                ht_cook_interact("methlab_caustic_cooler")
            end)
        elseif id == "pln_rt1_24" or id == "Play_loc_mex_cook_05" then
            ht_cook_interact("hydrogen_chloride")
            DelayedCalls:Add("ht_cook_step3", 0.3, function()
                ht_cook_interact("methlab_gas_to_salt")
            end)
        elseif id == "pln_rat_stage1_20" then
            ht_cook_interact("muriatic_acid")
            DelayedCalls:Add("ht_cook_rat1", 0.3, function() ht_cook_interact("methlab_bubbling") end)
        elseif id == "pln_rat_stage1_22" then
            ht_cook_interact("caustic_soda")
            DelayedCalls:Add("ht_cook_rat2", 0.3, function() ht_cook_interact("methlab_caustic_cooler") end)
        elseif id == "pln_rat_stage1_24" then
            ht_cook_interact("hydrogen_chloride")
            DelayedCalls:Add("ht_cook_rat3", 0.3, function() ht_cook_interact("methlab_gas_to_salt") end)
        end
    end

    if not HT.Mission._add_unit_backup then
        HT.Mission._add_unit_backup = ObjectInteractionManager.add_unit
    end
    function ObjectInteractionManager:add_unit(unit, ...)
        HT.Mission._add_unit_backup(self, unit, ...)
        if not HT.Mission.autoCookEnabled then return end
        if not unit then return end
        local interaction = unit and unit.interaction and unit:interaction()
        if not interaction then return end
        if interaction.tweak_data == "taking_meth" or interaction.tweak_data == "taking_meth_huge" then
            local bag_type = interaction.tweak_data == "taking_meth_huge" and "meth_half" or "meth"
            local pos = interaction:interact_position()
            local drop_pos = Vector3(pos.x, pos.y, pos.z + 40)
            DelayedCalls:Add("ht_take_meth", 2.5, function()
                ht_drop_bag()
                ht_cook_interact(interaction.tweak_data)
                DelayedCalls:Add("ht_drop_meth", 0.3, function()
                    if Network:is_server() then
                        local carry = tweak_data.carry[bag_type]
                        if carry then
                            managers.player:server_drop_carry(bag_type, 1,
                                false, false, 1, drop_pos,
                                Vector3(math.random(-180,180), math.random(-180,180), 0),
                                Vector3(0,0,1), 100, nil,
                                managers.network:session():local_peer())
                        end
                    else
                        managers.network:session():send_to_host("server_drop_carry",
                            bag_type, 1, false, false, 1, drop_pos,
                            Vector3(math.random(-180,180), math.random(-180,180), 0),
                            Vector3(0,0,1), 100, nil)
                    end
                    pcall(function() managers.player:clear_carry() end)
                end)
            end)
        end
    end

    HT:addAlert("Auto cook ON", HT.colors.success, false)
end

function HT.Mission:disableAutoCook()
    HT.Mission.autoCookEnabled = false
    if HT.Mission._dialog_backup then
        DialogManager.queue_dialog = HT.Mission._dialog_backup
        HT.Mission._dialog_backup = nil
    end
    if HT.Mission._add_unit_backup then
        ObjectInteractionManager.add_unit = HT.Mission._add_unit_backup
        HT.Mission._add_unit_backup = nil
    end
    HT:addAlert("Auto cook OFF", HT.colors.success, false)
end

function HT.Mission:autoCook()
    if not HT:isInHeist() then
        HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
        return
    end
    if HT.Mission.autoCookEnabled then
        HT.Mission:disableAutoCook()
    else
        HT.Mission:enableAutoCook()
    end
end

function HT.Mission:killAllEnemies()
    local player = managers.player and managers.player:player_unit()
    for _, data in pairs(managers.enemy:all_enemies()) do
        local unit = data.unit
        if alive(unit) then
            pcall(function()
                local dmg = unit:character_damage()
                if dmg and not dmg:dead() then
                    dmg:death({ attacker_unit = player, variant = "bullet" })
                end
            end)
        end
    end
    HT:addAlert("All enemies killed", HT.colors.success, false)
end

function HT.Mission:setFreezeCivilians(value)
    HT:setSetting("enable_freeze_civilians", value)
    HT.Mission.enableFreezeCivilians = value
    if not value then
        for _, data in pairs(managers.enemy:all_civilians()) do
            if alive(data.unit) then
                pcall(function() data.unit:brain():set_active(true) end)
            end
        end
    end
    if value then
        HT:addAlert("Civilians frozen", HT.colors.success, false)
    else
        HT:addAlert("Civilians unfrozen", HT.colors.success, false)
    end
end

function HT.Mission:freezeAllCivs()
    for _, data in pairs(managers.enemy:all_civilians()) do
        if data.unit and alive(data.unit) and data.unit:brain():is_active() then
            data.unit:brain():set_active(false)
        end
    end
end

function HT.Mission:openAllDoors()
    local player = managers.player and managers.player:player_unit()
    if not player then return end
    HT:infiniteEquipmentToggle()
    HT:interactWithAnythingToggle()
    local objects = {}
    for _, v in pairs(managers.interaction._interactive_units) do
        if alive(v) and v.interaction and v:interaction() then
            pcall(function()
                local has_door = false
                local unit = v:interaction()._unit
                if unit and alive(unit) and unit.door and unit:door() then
                    has_door = true
                end
                local td = v:interaction().tweak_data
                if td and (td:find("door") or td:find("lock") or td:find("gate") or td:find("keycard")) then
                    has_door = true
                end
                if has_door then
                    table.insert(objects, v:interaction())
                end
            end)
        end
    end
    for _, v in ipairs(objects) do
        pcall(function() v:interact(player) end)
    end
    HT:infiniteEquipmentToggle()
    HT:interactWithAnythingToggle()
    HT:addAlert("All doors opened", HT.colors.success, false)
end
