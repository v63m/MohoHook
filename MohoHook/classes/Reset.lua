HT.Reset = {}

HT.Reset.dex_toggles = {
    {setting="enable_god_mode",                   id="ut_item_dexterity_toggle_god_mode"},
    {setting="enable_infinite_stamina",            id="ut_item_dexterity_toggle_infinite_stamina"},
    {setting="enable_run_in_all_directions",       id="ut_item_dexterity_toggle_run_in_all_directions"},
    {setting="enable_can_run_with_any_bag",        id="ut_item_dexterity_toggle_can_run_with_any_bag"},
    {setting="enable_no_carry_cooldown",           id="ut_item_dexterity_toggle_no_carry_cooldown"},
    {setting="enable_no_flashbangs",               id="ut_item_dexterity_toggle_no_flashbangs"},
    {setting="enable_fast_mask",                   id="ut_item_dexterity_toggle_fast_mask"},
    {setting="enable_no_fall_damage",              id="ut_item_dexterity_toggle_no_fall_damage"},
    {setting="enable_instant_swap",                id="ut_item_dexterity_toggle_instant_swap"},
    {setting="enable_instant_reload",              id="ut_item_dexterity_toggle_instant_reload"},
    {setting="enable_no_recoil",                   id="ut_item_dexterity_toggle_no_recoil"},
    {setting="enable_no_spread",                   id="ut_item_dexterity_toggle_no_spread"},
    {setting="enable_unlimited_ammo",              id="ut_item_dexterity_toggle_unlimited_ammo"},
    {setting="enable_shoot_through_walls",         id="ut_item_dexterity_toggle_shoot_through_walls"},
    {setting="enable_spinbot",                     id="ut_item_dexterity_toggle_spinbot"},
    {setting="enable_full_auto",                   id="ut_item_dexterity_toggle_full_auto"},
    {setting="enable_tracers",                     id="ut_item_dexterity_toggle_tracers"},
    {setting="enable_custom_fov",                  id="ut_item_dexterity_toggle_custom_fov"},
    {setting="enable_instant_interaction",         id="ut_item_dexterity_toggle_instant_interaction"},
    {setting="enable_instant_deployment",          id="ut_item_dexterity_toggle_instant_deployment"},
    {setting="enable_unlimited_equipment",         id="ut_item_dexterity_toggle_unlimited_equipment"},
    {setting="enable_noclip",                      id="ut_item_dexterity_toggle_noclip"},
    {setting="enable_move_speed_multiplier",       id="ut_item_dexterity_toggle_move_speed_multiplier"},
    {setting="enable_fire_rate_multiplier",        id="ut_item_dexterity_toggle_fire_rate_multiplier"},
    {setting="enable_damage_multiplier",           id="ut_item_dexterity_toggle_damage_multiplier"},
    {setting="enable_throw_distance_multiplier",   id="ut_item_dexterity_toggle_throw_distance_multiplier"},
    {setting="enable_infinite_bags",               id="ut_item_dexterity_toggle_infinite_bags"},
    {setting="enable_slow_motion",                 id="ut_item_dexterity_toggle_slow_motion"},
    {setting="enable_unlimited_grenades",          id="ut_item_dexterity_toggle_unlimited_grenades"},
    {setting="enable_infinite_armor",              id="ut_item_dexterity_toggle_infinite_armor"},
    {setting="enable_exploding_bullets",           id="ut_item_dexterity_toggle_exploding_bullets"},
}

HT.Reset.mission_toggles = {
    {setting="enable_disable_ai",                  id="ut_item_mission_toggle_disable_ai"},
    {setting="enable_invisible_player",            id="ut_item_mission_toggle_invisible_player"},
    {setting="enable_instant_drilling",            id="ut_item_mission_toggle_instant_drilling"},
    {setting="enable_prevent_alarm_triggering",    id="ut_item_mission_toggle_prevent_alarm_triggering"},
    {setting="enable_unlimited_pagers",            id="ut_item_mission_toggle_unlimited_pagers"},
    {setting="enable_xray",                        id="ut_item_mission_toggle_xray"},
    {setting="enable_no_civilian_penalty",         id="ut_item_mission_toggle_no_civilian_penalty"},
}

function HT.Reset:all(silent)
    silent = silent == true

    for _, t in ipairs(HT.Reset.dex_toggles) do
        HT:setSetting(t.setting, false)
        pcall(function() HT:setMenuToggle(t.id, false) end)
        pcall(function() HT:updateJsonValue("dexterity", t.id, false) end)
    end
    for _, t in ipairs(HT.Reset.mission_toggles) do
        HT:setSetting(t.setting, false)
        pcall(function() HT:setMenuToggle(t.id, false) end)
        pcall(function() HT:updateJsonValue("mission", t.id, false) end)
    end

    if HT.Aimbot then
        HT.Aimbot.enabled = false
        HT.Aimbot.currentTarget = nil
        HT:setSetting("enable_aimbot", false)
        pcall(function() HT:setMenuToggle("ut_item_aimbot_toggle_enabled", false) end)
        pcall(function() HT:updateJsonValue("aimbot", "ut_item_aimbot_toggle_enabled", false) end)
    end

    pcall(function()
        local p = managers.player:player_unit()
        if alive(p) then p:character_damage():set_god_mode(false) end
    end)

    pcall(function()
        _G.CloneClass(PlayerMovement)
        PlayerMovement._change_stamina    = PlayerMovement.orig._change_stamina
        PlayerMovement.is_stamina_drained = PlayerMovement.orig.is_stamina_drained
    end)

    pcall(function()
        _G.CloneClass(PlayerStandard)
        PlayerStandard._can_run_directional = PlayerStandard.orig._can_run_directional
    end)

    pcall(function()
        if HT.Dexterity.tweakDataCarryTypes then
            for carry_type, data in pairs(HT.Dexterity.tweakDataCarryTypes) do
                if tweak_data.carry.types[carry_type] and type(data) == "table" then
                    tweak_data.carry.types[carry_type].can_run = data.can_run
                    tweak_data.carry.types[carry_type].throw_distance_multiplier = data.throw_distance_multiplier
                end
            end
        end
    end)

    pcall(function()
        _G.CloneClass(PlayerManager)
        PlayerManager.carry_blocked_by_cooldown = PlayerManager.orig.carry_blocked_by_cooldown
    end)

    pcall(function()
        _G.CloneClass(CoreEnvironmentControllerManager)
        CoreEnvironmentControllerManager.set_flashbang = CoreEnvironmentControllerManager.orig.set_flashbang
    end)

    pcall(function()
        if HT.Dexterity.tweakDataPlayerPutOnMaskTime then
            tweak_data.player.put_on_mask_time = HT.Dexterity.tweakDataPlayerPutOnMaskTime
        end
    end)

    pcall(function()
        _G.CloneClass(PlayerDamage)
        PlayerDamage.damage_fall = PlayerDamage.orig.damage_fall
    end)

    pcall(function()
        _G.CloneClass(PlayerStandard)
        PlayerStandard._get_swap_speed_multiplier = PlayerStandard.orig._get_swap_speed_multiplier
    end)

    pcall(function()
        _G.CloneClass(RaycastWeaponBase)
        RaycastWeaponBase.can_reload = RaycastWeaponBase.orig.can_reload
    end)

    pcall(function()
        _G.CloneClass(RaycastWeaponBase)
        _G.CloneClass(NewRaycastWeaponBase)
        RaycastWeaponBase.fire_mode      = RaycastWeaponBase.orig.fire_mode
        NewRaycastWeaponBase.fire_mode   = NewRaycastWeaponBase.orig.fire_mode
    end)

    HT.Dexterity.enableFullAuto = false
    HT.Dexterity.enableCustomFov = false
    HT.Dexterity:resetJumpMultiplier()

    HT.Dexterity.enableInfiniteBags = false
    HT.Dexterity:clearCarryStack()
    pcall(function()
        if CarryInteractionExt and CarryInteractionExt.orig then
            CarryInteractionExt._interact_blocked = CarryInteractionExt.orig._interact_blocked
            CarryInteractionExt.can_select        = CarryInteractionExt.orig.can_select
        end
    end)

    HT.Dexterity.enableSlowMotion = false
    HT.Dexterity.enableUnlimitedGrenades = false
    pcall(function()
        if managers.timespeed then
            managers.timespeed:stop_effect(Idstring("HT_slow_motion"), 0.5)
        end
    end)
    pcall(function()
        if PlayerManager and PlayerManager.orig then
            PlayerManager.add_grenade_amount = PlayerManager.orig.add_grenade_amount
        end
    end)

    HT.Dexterity.enableInfiniteArmor = false
    pcall(function()
        _G.CloneClass(PlayerDamage)
        PlayerDamage.set_regenerate_timer_to_max = PlayerDamage.orig.set_regenerate_timer_to_max
    end)

    HT.Dexterity.enableExplodingBullets = false
    pcall(function()
        _G.CloneClass(InstantBulletBase)
        InstantBulletBase.on_collision = InstantBulletBase.orig.on_collision
    end)

    HT.Troll.enableRainbowChat = false
    HT:setSetting("rainbow_chat", false)
    pcall(function() HT:setMenuToggle("ut_item_troll_rainbow_chat", false) end)
    pcall(function() HT:updateJsonValue("troll", "ut_item_troll_rainbow_chat", false) end)

    pcall(function()
        _G.CloneClass(MoneyManager)
        MoneyManager.civilian_killed = MoneyManager.orig.civilian_killed
    end)

    pcall(function()
        _G.CloneClass(NewRaycastWeaponBase)
        NewRaycastWeaponBase.recoil_multiplier    = NewRaycastWeaponBase.orig.recoil_multiplier
        NewRaycastWeaponBase.spread_multiplier    = NewRaycastWeaponBase.orig.spread_multiplier
        NewRaycastWeaponBase.fire_rate_multiplier = NewRaycastWeaponBase.orig.fire_rate_multiplier
    end)

    pcall(function()
        _G.CloneClass(RaycastWeaponBase)
        RaycastWeaponBase.clip_empty = RaycastWeaponBase.orig.clip_empty
        pcall(function()
            _G.CloneClass(SawWeaponBase)
            SawWeaponBase.clip_empty = SawWeaponBase.orig.clip_empty
        end)
    end)

    pcall(function()
        _G.CloneClass(RaycastWeaponBase)
        _G.CloneClass(NewRaycastWeaponBase)
        RaycastWeaponBase._can_shoot_through_shield    = RaycastWeaponBase.orig._can_shoot_through_shield
        RaycastWeaponBase._can_shoot_through_wall      = RaycastWeaponBase.orig._can_shoot_through_wall
        NewRaycastWeaponBase._can_shoot_through_shield = NewRaycastWeaponBase.orig._can_shoot_through_shield
        NewRaycastWeaponBase._can_shoot_through_wall   = NewRaycastWeaponBase.orig._can_shoot_through_wall
    end)

    pcall(function()
        _G.CloneClass(BaseInteractionExt)
        BaseInteractionExt._get_timer = BaseInteractionExt.orig._get_timer
    end)

    pcall(function()
        _G.CloneClass(PlayerManager)
        PlayerManager.selected_equipment_deploy_timer = PlayerManager.orig.selected_equipment_deploy_timer
    end)

    pcall(function()
        _G.CloneClass(BaseInteractionExt)
        _G.CloneClass(PlayerManager)
        BaseInteractionExt._has_required_upgrade    = BaseInteractionExt.orig._has_required_upgrade
        BaseInteractionExt._has_required_deployable = BaseInteractionExt.orig._has_required_deployable
        BaseInteractionExt.can_interact             = BaseInteractionExt.orig.can_interact
        PlayerManager.on_used_body_bag              = PlayerManager.orig.on_used_body_bag
        PlayerManager.remove_equipment              = PlayerManager.orig.remove_equipment
        PlayerManager.remove_special                = PlayerManager.orig.remove_special
    end)

    HT.Dexterity.enableNoclip = false
    HT.Dexterity.noclipAxisMove = {x=0, y=0, z=0}
    HT.Dexterity.enableSpinbot = false

    pcall(function()
        _G.CloneClass(PlayerManager)
        PlayerManager.movement_speed_multiplier = PlayerManager.orig.movement_speed_multiplier
    end)

    pcall(function()
        _G.CloneClass(CopDamage)
        CopDamage.damage_bullet = CopDamage.orig.damage_bullet
        CopDamage.damage_melee  = CopDamage.orig.damage_melee
    end)

    if HT:isInHeist() then
        HT.Mission.enableDisableAi = false
        pcall(function()
            for _, v in pairs(managers.enemy:all_civilians()) do
                pcall(function() v.unit:brain():set_active(true) end)
            end
            for _, v in pairs(managers.enemy:all_enemies()) do
                pcall(function() v.unit:brain():set_active(true) end)
            end
            if SecurityCamera and SecurityCamera.cameras then
                for _, u in pairs(SecurityCamera.cameras) do
                    pcall(function() u:base()._detection_interval = 0.1 end)
                end
            end
        end)

        HT.Mission.enableInvisiblePlayer = false
        pcall(function() HT.Mission:setInvisiblePlayer(false) end)

        pcall(function()
            _G.CloneClass(TimerGui)
            TimerGui._set_jamming_values = TimerGui.orig._set_jamming_values
            TimerGui.start               = TimerGui.orig.start
        end)

        pcall(function()
            _G.CloneClass(GroupAIStateBase)
            GroupAIStateBase.on_police_called = GroupAIStateBase.orig.on_police_called
        end)

        pcall(function()
            tweak_data.player.alarm_pager.bluff_success_chance = {1, 1, 1, 1, 0}
        end)

        pcall(function()
            if managers.enemy then
                for _, d in pairs(managers.enemy:all_enemies())   do pcall(function() d.unit:contour():remove("mark_enemy", false) end) end
                for _, d in pairs(managers.enemy:all_civilians()) do pcall(function() d.unit:contour():remove("mark_enemy", false) end) end
            end
            if EnemyManager and EnemyManager.orig then
                _G.CloneClass(EnemyManager)
                EnemyManager.register_enemy    = EnemyManager.orig.register_enemy
                EnemyManager.register_civilian = EnemyManager.orig.register_civilian
                EnemyManager.on_enemy_died     = EnemyManager.orig.on_enemy_died
                EnemyManager.on_civilian_died  = EnemyManager.orig.on_civilian_died
            end
        end)

        pcall(function() HT.Mission:disableAutoCook() end)
    end

    HT:saveSettings()
    HT.Dexterity.godModeReset = false

    if not silent then
        HT:addAlert("All cheats reset", HT.colors.warning, false)
    end
end
