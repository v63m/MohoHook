Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_UltimateTrainer", function(localizationManager)
    local locale = BLT.Localization:get_language().language
    locale = HT.Utils:inTable(locale, HT.supportedLocales) and locale or "en"
    localizationManager:load_localization_file(HT.modPath .. "/locales/" .. locale .. ".json")
end)

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_UltimateTrainer", function(menuManager)

    MenuCallbackHandler.ut_player_set_level = function(self, item)
        local level = item:value()
        item:set_value("")
        if HT.Utils:isEmptyString(level) then
            return
        end
        level = HT.Utils:toNumber(level)
        if not HT.Utils:isInteger(level) then
            return
        end
        if level < 0 or level > 100 then
            return
        end
        HT.Player:setLevel(level)
    end

    MenuCallbackHandler.ut_player_set_infamy_rank = function(self, item)
        local infamyRank = item:value()
        item:set_value("")
        if HT.Utils:isEmptyString(infamyRank) then
            return
        end
        infamyRank = HT.Utils:toNumber(infamyRank)
        if not HT.Utils:isInteger(infamyRank) then
            return
        end
        if infamyRank < 0 or infamyRank > 500 then
            return
        end
        HT.Player:setInfamyRank(infamyRank)
    end

    MenuCallbackHandler.ut_player_add_spending_money = function(self, item)
        local amount = item:value()
        item:set_value("")
        if HT.Utils:isEmptyString(amount) then
            return
        end
        amount = HT.Utils:toNumber(amount)
        if not HT.Utils:isInteger(amount) then
            return
        end
        if amount < 0 then
            return
        end
        HT.Player:addSpendingMoney(amount)
    end

    MenuCallbackHandler.ut_player_add_offshore_money = function(self, item)
        local amount = item:value()
        item:set_value("")
        if HT.Utils:isEmptyString(amount) then
            return
        end
        amount = HT.Utils:toNumber(amount)
        if not HT.Utils:isInteger(amount) then
            return
        end
        if amount < 0 then
            return
        end
        HT.Player:addOffshoreMoney(amount)
    end

    MenuCallbackHandler.ut_player_reset_money = function(self, item)
        HT.Player:resetMoney()
    end

    MenuCallbackHandler.ut_player_add_continental_coins = function(self, item)
        local amount = item:value()
        item:set_value("")
        if HT.Utils:isEmptyString(amount) then
            return
        end
        amount = HT.Utils:toNumber(amount)
        if not HT.Utils:isInteger(amount) then
            return
        end
        if amount < 0 then
            return
        end
        HT.Player:addContinentalCoins(amount)
    end

    MenuCallbackHandler.ut_player_reset_continental_coins = function(self, item)
        HT.Player:resetContinentalCoins()
    end

    MenuCallbackHandler.ut_player_toggle_skill_points_hack = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT.Player:setSkillPointsHack(value)
    end

    MenuCallbackHandler.ut_player_set_skill_points_total_amount = function(self, item)
        local amount = item:value()
        if HT.Utils:isEmptyString(amount) then
            return
        end
        amount = HT.Utils:toNumber(amount)
        if not HT.Utils:isInteger(amount) then
            return
        end
        if amount < 0 or amount > 690 then
            HT:addAlert("ut_alert_skill_points_total_amount_out_of_range", HT.colors.warning)
            return
        end
        HT.Player:setSkillPointsTotalAmount(amount)
    end

    MenuCallbackHandler.ut_player_add_perk_experience = function(self, item)
        local amount = item:value()
        item:set_value("")
        if HT.Utils:isEmptyString(amount) then
            return
        end
        amount = HT.Utils:toNumber(amount)
        if not HT.Utils:isInteger(amount) then
            return
        end
        if amount < 0 then
            return
        end
        HT.Player:addPerkPoints(amount)
    end

    MenuCallbackHandler.ut_player_reset_perk_points = function(self, item)
        HT.Player:resetPerkPoints()
    end

    MenuCallbackHandler.ut_player_add_one_of_all_weapon_mods = function(self, item)
        HT.Player:addItemsToInventory("weapon_mods")
    end

    MenuCallbackHandler.ut_player_add_one_of_all_masks = function(self, item)
        HT.Player:addItemsToInventory("masks")
    end

    MenuCallbackHandler.ut_player_add_one_of_all_materials = function(self, item)
        HT.Player:addItemsToInventory("materials")
    end

    MenuCallbackHandler.ut_player_add_one_of_all_patterns = function(self, item)
        HT.Player:addItemsToInventory("textures")
    end

    MenuCallbackHandler.ut_player_add_one_of_all_colors = function(self, item)
        HT.Player:addItemsToInventory("colors")
    end

    MenuCallbackHandler.ut_player_clear_weapon_mods = function(self, item)
        HT.Player:clearInventoryItems("weapon_mods")
    end

    MenuCallbackHandler.ut_player_clear_masks = function(self, item)
        HT.Player:clearInventoryItems("masks")
    end

    MenuCallbackHandler.ut_player_clear_materials = function(self, item)
        HT.Player:clearInventoryItems("materials")
    end

    MenuCallbackHandler.ut_player_clear_patterns = function(self, item)
        HT.Player:clearInventoryItems("textures")
    end

    MenuCallbackHandler.ut_player_clear_colors = function(self, item)
        HT.Player:clearInventoryItems("colors")
    end

    MenuCallbackHandler.ut_player_unlock_all_weapons = function(self, item)
        HT.Player:unlockInventoryCategory("weapon")
    end

    MenuCallbackHandler.ut_player_unlock_all_melee_weapons = function(self, item)
        HT.Player:unlockInventoryCategory("melee_weapon")
    end

    MenuCallbackHandler.ut_player_unlock_all_throwables = function(self, item)
        HT.Player:unlockInventoryCategory("grenade")
    end

    MenuCallbackHandler.ut_player_unlock_all_armors = function(self, item)
        HT.Player:unlockInventoryCategory("armor")
    end

    MenuCallbackHandler.ut_player_unlock_all_slots = function(self, item)
        HT.Player:setAllSlots(true)
    end

    MenuCallbackHandler.ut_player_lock_all_slots = function(self, item)
        HT.Player:setAllSlots(false)
    end

    MenuCallbackHandler.ut_player_remove_exclamation_marks = function(self, item)
        HT.Player:removeExclamationMarks()
    end

    MenuCallbackHandler.ut_player_unlock_all_trophies = function(self, item)
        HT.Player:unlockAllTrophies()
    end

    MenuCallbackHandler.ut_player_lock_all_trophies = function(self, item)
        HT.Player:lockAllTrophies()
    end

    MenuCallbackHandler.ut_player_unlock_all_steam_achievements = function(self, item)
        HT.Player:unlockAllSteamAchievements()
    end

    MenuCallbackHandler.ut_player_lock_all_steam_achievements = function(self, item)
        HT.Player:lockAllSteamAchievements()
    end

    MenuCallbackHandler.ut_unlocker_toggle_dlc_unlocker = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT.Unlocker:setDlcUnlocker(value)
    end

    MenuCallbackHandler.ut_unlocker_toggle_skin_unlocker = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT.Unlocker:setSkinUnlocker(value)
    end

    MenuCallbackHandler.ut_mission_access_cameras = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        managers.menu:close_all_menus()
        HT.Mission:accessCameras()
    end

    MenuCallbackHandler.ut_mission_remove_invisible_walls = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        HT.Mission:removeInvisibleWalls()
    end

    MenuCallbackHandler.ut_mission_convert_all_enemies = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        HT.Mission:convertAllEnemies()
    end

    MenuCallbackHandler.ut_mission_trigger_alarm = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        HT.Mission:triggerAlarm()
    end

    MenuCallbackHandler.ut_mission_toggle_disable_ai = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Mission:setDisableAi(value)
    end

    MenuCallbackHandler.ut_mission_toggle_invisible_player = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Mission:setInvisiblePlayer(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_noclip = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setNoclip(value, true)
    end

    MenuCallbackHandler.ut_dexterity_set_noclip_speed_multiplier = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        HT.Dexterity.noclipSpeedMultiplier = item:value()
    end

    MenuCallbackHandler.ut_mission_toggle_instant_drilling = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Mission:setInstantDrilling(value)
    end

    MenuCallbackHandler.ut_mission_toggle_prevent_alarm_triggering = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Mission:setPreventAlarmTriggering(value)
    end

    MenuCallbackHandler.ut_mission_toggle_unlimited_pagers = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Mission:setUnlimitedPagers(value)
    end

    MenuCallbackHandler.ut_construction_clear = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        HT.Construction:clear()
    end

    MenuCallbackHandler.ut_construction_toggle_crosshair_marker = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Construction:setCrosshairMarker(value)
    end

    MenuCallbackHandler.ut_spawn_remove_npcs = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        HT.Spawn:removeNpcs()
    end

    MenuCallbackHandler.ut_spawn_remove_loots = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        HT.Spawn:removeLoots()
    end

    MenuCallbackHandler.ut_spawn_remove_equipments = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        HT.Spawn:removeEquipments()
    end

    MenuCallbackHandler.ut_spawn_remove_packages = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        HT.Spawn:removePackages()
    end

    MenuCallbackHandler.ut_spawn_remove_bags = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        HT.Spawn:removeBags()
    end

    MenuCallbackHandler.ut_spawn_dispose_corpses = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        HT.Spawn:disposeCorpses()
    end

    MenuCallbackHandler.ut_time_set_environment_early_morning = function(self, item)
        HT.Time:setEnvironmentSetting("environments/pd2_env_hox_02/pd2_env_hox_02")
    end

    MenuCallbackHandler.ut_time_set_environment_morning = function(self, item)
        HT.Time:setEnvironmentSetting("environments/pd2_env_morning_02/pd2_env_morning_02")
    end

    MenuCallbackHandler.ut_time_set_environment_mid_day = function(self, item)
        HT.Time:setEnvironmentSetting("environments/pd2_env_mid_day/pd2_env_mid_day")
    end

    MenuCallbackHandler.ut_time_set_environment_afternoon = function(self, item)
        HT.Time:setEnvironmentSetting("environments/pd2_env_afternoon/pd2_env_afternoon")
    end

    MenuCallbackHandler.ut_time_set_environment_night = function(self, item)
        HT.Time:setEnvironmentSetting("environments/pd2_env_n2/pd2_env_n2")
    end

    MenuCallbackHandler.ut_time_set_environment_misty_night = function(self, item)
        HT.Time:setEnvironmentSetting("environments/pd2_env_arm_hcm_02/pd2_env_arm_hcm_02")
    end

    MenuCallbackHandler.ut_time_set_environment_foggy_night = function(self, item)
        HT.Time:setEnvironmentSetting("environments/pd2_env_foggy_bright/pd2_env_foggy_bright")
    end

    MenuCallbackHandler.ut_time_reset_environment = function(self, item)
        HT.Time:resetEnvironment()
    end

    MenuCallbackHandler.ut_dexterity_toggle_god_mode = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setGodMode(value, true)
    end

    MenuCallbackHandler.ut_dexterity_toggle_infinite_stamina = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setInfiniteStamina(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_run_in_all_directions = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setRunInAllDirections(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_can_run_with_any_bag = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setCanRunWithAnyBag(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_fast_mask = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setFastMask(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_no_carry_cooldown = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setNoCarryCooldown(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_no_flashbangs = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setNoFlashbangs(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_instant_swap = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setInstantSwap(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_instant_reload = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setInstantReload(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_shoot_through_walls = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setShootThroughWalls(value, true)
    end

    MenuCallbackHandler.ut_dexterity_toggle_no_recoil = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setNoRecoil(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_no_spread = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setNoSpread(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_unlimited_ammo = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setUnlimitedAmmo(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_instant_interaction = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setInstantInteraction(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_instant_deployment = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setInstantDeployment(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_unlimited_equipment = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setUnlimitedEquipment(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_move_speed_multiplier = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        HT.Dexterity.enableMoveSpeedMultiplier = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setMoveSpeedMultiplier(
            HT.Dexterity.enableMoveSpeedMultiplier,
            HT.Dexterity.moveSpeedMultiplier
        )
    end

    MenuCallbackHandler.ut_dexterity_set_move_speed_multiplier = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        HT.Dexterity.moveSpeedMultiplier = item:value()
        HT.Dexterity:setMoveSpeedMultiplier(
            HT.Dexterity.enableMoveSpeedMultiplier,
            HT.Dexterity.moveSpeedMultiplier
        )
    end

    MenuCallbackHandler.ut_dexterity_toggle_throw_distance_multiplier = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        HT.Dexterity.enableThrowDistanceMultiplier = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setThrowDistanceMultiplier(
            HT.Dexterity.enableThrowDistanceMultiplier,
            HT.Dexterity.throwDistanceMultiplier
        )
    end

    MenuCallbackHandler.ut_dexterity_set_throw_distance_multiplier = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        HT.Dexterity.throwDistanceMultiplier = item:value()
        HT.Dexterity:setThrowDistanceMultiplier(
            HT.Dexterity.enableThrowDistanceMultiplier,
            HT.Dexterity.throwDistanceMultiplier
        )
    end

    MenuCallbackHandler.ut_dexterity_toggle_fire_rate_multiplier = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        HT.Dexterity.enableFireRateMultiplier = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setFireRateMultiplier(
            HT.Dexterity.enableFireRateMultiplier,
            HT.Dexterity.fireRateMultiplier
        )
    end

    MenuCallbackHandler.ut_dexterity_set_fire_rate_multiplier = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        HT.Dexterity.fireRateMultiplier = item:value()
        HT.Dexterity:setFireRateMultiplier(
            HT.Dexterity.enableFireRateMultiplier,
            HT.Dexterity.fireRateMultiplier
        )
    end

    MenuCallbackHandler.ut_dexterity_toggle_damage_multiplier = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        HT.Dexterity.enableDamageMultiplier = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setDamageMultiplier(
            HT.Dexterity.enableDamageMultiplier,
            HT.Dexterity.damageMultiplier
        )
    end

    MenuCallbackHandler.ut_dexterity_set_damage_multiplier = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        HT.Dexterity.damageMultiplier = item:value()
        HT.Dexterity:setDamageMultiplier(
            HT.Dexterity.enableDamageMultiplier,
            HT.Dexterity.damageMultiplier
        )
    end

    MenuCallbackHandler.ut_configuration_toggle_anti_cheat_checker = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT.AntiCheatChecker:setEnabled(value)
    end

    MenuCallbackHandler.ut_configuration_anti_cheat_checker_show_list = function(self, item)
        HT.AntiCheatChecker:showList()
    end

    MenuCallbackHandler.ut_configuration_toggle_hide_mods_list = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT:setHideModsList(value)
    end

    MenuCallbackHandler.ut_instant_start_heist = function(self, item)
        if not HT:isInGame() then
            HT:addAlert("ut_alert_in_game_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        HT.Instant:startHeist()
    end

    MenuCallbackHandler.ut_menu_extras_item_1_callback = function(self, item)
        if not HT:isInGame() then
            HT:addAlert("ut_alert_in_game_only_feature", HT.colors.warning)
            return
        end
        HT.Extras:collectGagePackages()
    end

    MenuCallbackHandler.ut_menu_extras_item_2_callback = function(self, item)
        if not HT:isInGame() then
            HT:addAlert("ut_alert_in_game_only_feature", HT.colors.warning)
            return
        end
        HT.Extras:boardWindows()
    end

    MenuCallbackHandler.ut_menu_extras_item_3_callback = function(self, item)
        if not HT:isInGame() then
            HT:addAlert("ut_alert_in_game_only_feature", HT.colors.warning)
            return
        end
        HT.Extras:openDepositBoxes()
    end

    MenuCallbackHandler.ut_menu_extras_item_4_callback = function(self, item)
        if not HT:isInGame() then
            HT:addAlert("ut_alert_in_game_only_feature", HT.colors.warning)
            return
        end
        HT.Extras:tieCivilians()
    end

    MenuCallbackHandler.ut_menu_extras_item_5_callback = function(self, item)
        if not HT:isInGame() then
            HT:addAlert("ut_alert_in_game_only_feature", HT.colors.warning)
            return
        end

        local draw_invisible_walls = HT.Utils:getToggleValue(item:value())
        HT.Extras:displayInvisibleWalls(draw_invisible_walls)
    end

    MenuCallbackHandler.ut_menu_extras_item_6_callback = function(self, item)
        if not HT:isInGame() then
            HT:addAlert("ut_alert_in_game_only_feature", HT.colors.warning)
            return
        end
        HT.Extras:lockupAI()
    end

    MenuCallbackHandler.ut_menu_extras_item_7_callback = function(self, item)
        if not HT:isInGame() then
            HT:addAlert("ut_alert_in_game_only_feature", HT.colors.warning)
            return
        end
        HT.Extras:releaseAI()
    end

    MenuCallbackHandler.ut_menu_extras_item_8_callback = function(self, item)
        if not HT:isInGame() then
            HT:addAlert("ut_alert_in_game_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Extras:toggleCashPenalty(value)
    end

    MenuCallbackHandler.ut_menu_extras_item_9_callback = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        HT.Extras:collectSmallLoot()
    end

    MenuCallbackHandler.ut_instant_restart_heist = function(self, item)
        if not HT:isInGame() then
            HT:addAlert("ut_alert_in_game_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        HT.Instant:restartHeist()
    end

    MenuCallbackHandler.ut_instant_finish_heist = function(self, item)
        if not HT:isInGame() then
            HT:addAlert("ut_alert_in_game_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        HT.Instant:finishHeist()
    end

    MenuCallbackHandler.ut_instant_leave_heist = function(self, item)
        if not HT:isInGame() then
            HT:addAlert("ut_alert_in_game_only_feature", HT.colors.warning)
            return
        end
        HT.Instant:leaveHeist()
    end

    MenuCallbackHandler.ut_mission_toggle_xray = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Mission:setXray(value)
    end

    MenuCallbackHandler.ut_mission_spawn_current_bag = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        HT.Mission:spawnBagOfCurrentType()
    end

    MenuCallbackHandler.ut_mission_give_heist_xp = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        HT.Mission:giveHeistXp()
    end

    MenuCallbackHandler.ut_dexterity_toggle_no_fall_damage = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setNoFallDamage(value)
    end

    MenuCallbackHandler.ut_mission_get_out_of_custody = function(self, item)
        HT.Mission:getOutOfCustody()
    end

    MenuCallbackHandler.ut_mission_auto_cook = function(self, item)
        HT.Mission:autoCook()
    end

    MenuCallbackHandler.ut_mission_toggle_auto_cook = function(self, item)
        HT.Mission:autoCook()
    end

    MenuCallbackHandler.ut_mission_kill_all_enemies = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        if not HT:isHost() then
            HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
            return
        end
        HT.Mission:killAllEnemies()
    end

    MenuCallbackHandler.ut_mission_toggle_freeze_civilians = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Mission:setFreezeCivilians(value)
    end

    MenuCallbackHandler.ut_mission_open_all_doors = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        HT.Mission:openAllDoors()
    end

    MenuCallbackHandler.ut_dexterity_toggle_one_shot_kill = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setOneShotKill(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_spinbot = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setSpinbot(value, true)
    end

    MenuCallbackHandler.ut_dexterity_set_spinbot_speed = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        HT.Dexterity:setSpinbotSpeed(item:value())
    end

    MenuCallbackHandler.ut_dexterity_toggle_full_auto = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setFullAuto(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_infinite_bags = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setInfiniteBags(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_slow_motion = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setSlowMotion(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_unlimited_grenades = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setUnlimitedGrenades(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_infinite_armor = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setInfiniteArmor(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_exploding_bullets = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setExplodingBullets(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_tracers = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setTracers(value)
    end

    MenuCallbackHandler.ut_dexterity_toggle_custom_fov = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Dexterity:setCustomFov(value)
    end

    MenuCallbackHandler.ut_dexterity_set_fov = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        HT.Dexterity:setFovValue(item:value())
    end

    MenuCallbackHandler.ut_dexterity_set_jump_multiplier = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        HT.Dexterity:setJumpMultiplier(item:value())
    end

    MenuCallbackHandler.ut_aimbot_toggle_enabled = function(self, item)
        if not HT:isInHeist() then
            HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
            return
        end
        local value = HT.Utils:getToggleValue(item:value())
        HT.Aimbot:setEnabled(value)
        pcall(function() HT:updateJsonValue("aimbot", "ut_item_aimbot_toggle_enabled", value) end)
    end

    MenuCallbackHandler.ut_aimbot_toggle_only_when_aiming = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT.Aimbot:setOnlyWhenAiming(value)
    end

    MenuCallbackHandler.ut_aimbot_toggle_visibility_check = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT.Aimbot:setVisibilityCheck(value)
    end

    MenuCallbackHandler.ut_aimbot_bone = function(self, item)
        local index = tonumber(item:value())
        if index == 2 then
            HT.Aimbot:setBone("chest")
        else
            HT.Aimbot:setBone("head")
        end
    end

    MenuCallbackHandler.ut_aimbot_set_fov = function(self, item)
        HT.Aimbot:setFov(item:value())
    end

    MenuCallbackHandler.ut_aimbot_set_smoothness = function(self, item)
        HT.Aimbot:setSmoothness(item:value())
    end

    MenuCallbackHandler.ut_team_grant_all = function(self, item)
        HT.Team:grantToAll()
    end

    MenuCallbackHandler.ut_team_revoke_all = function(self, item)
        HT.Team:revokeFromAll()
    end

    MenuCallbackHandler.ut_team_refresh = function(self, item)
        HT.Team:registerHooks()
        local peers = HT.Team:listPeers()
        HT:addAlert(tostring(#peers) .. " Mini peer(s) found", HT.colors.info, false)
    end

    MenuCallbackHandler.ut_team_show_status = function(self, item)
        HT:addAlert(HT.Team:statusLine(), HT.colors.info, false)
    end

    MenuCallbackHandler.ut_troll_fake_popup = function(self, item)
        HT.Troll:sendEffectToAll("fake_popup")
    end

    MenuCallbackHandler.ut_troll_screen_text = function(self, item)
        HT.Troll:sendEffectToAll("screen_text")
    end

    MenuCallbackHandler.ut_troll_confetti = function(self, item)
        HT.Troll:sendEffectToAll("confetti")
    end

    MenuCallbackHandler.ut_troll_horn = function(self, item)
        HT.Troll:sendEffectToAll("horn")
    end

    MenuCallbackHandler.ut_troll_fake_death = function(self, item)
        HT.Troll:sendEffectToAll("fake_death")
    end

    MenuCallbackHandler.ut_troll_random_shout = function(self, item)
        HT.Troll:sendEffectToAll("random_shout")
    end

    MenuCallbackHandler.ut_troll_random_emote = function(self, item)
        HT.Troll:sendEffectToAll("random_emote")
    end

    MenuCallbackHandler.ut_troll_server_fucker = function(self, item)
        HT.Troll:serverFucker()
    end

    MenuCallbackHandler.ut_mission_nuke = function(self, item)
        HT.Mission:nukeEnemies()
    end

    MenuCallbackHandler.ut_mission_toggle_no_civilian_penalty = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT.Mission:setNoCivilianPenalty(value)
    end

    MenuCallbackHandler.ut_troll_rainbow_chat = function(self, item)
        local value = HT.Utils:getToggleValue(item:value())
        HT.Troll:setRainbowChat(value)
    end

    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/main.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/player.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/mission.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/dexterity.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/spawn.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/extras.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/time.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/instant.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/unlocker.json", nil, HT.settings)
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/configuration.json", nil, HT.settings)
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/aimbot.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/team.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/troll.json")

    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/level.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/infamy-rank.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/money.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/continental-coins.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/skill-points.json", nil, HT.settings)
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/perk-points.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/inventory.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/trophies.json")
    MenuHelper:LoadFromJsonFile(HT.modPath .. "/menus/steam-achievements.json")
end)

local packageManagerMetaTable = getmetatable(PackageManager)
local _script_data = packageManagerMetaTable.script_data

local ids_menu = Idstring("menu")
local ids_menus = {
    [Idstring("gamedata/menus/start_menu")] = true,
    [Idstring("gamedata/menus/pause_menu")] = true,
}
packageManagerMetaTable.script_data = function(self, typeId, pathId, ...)
    local scriptData = _script_data(self, typeId, pathId, ...)
    if typeId ~= ids_menu and not ids_menus[pathId] then
        return scriptData
    end

    for key, value in ipairs(scriptData[1]) do
        for key2, value2 in ipairs(value) do
            if value2.name == "options" then
                table.insert(scriptData[1][key], key2 + 1, {
                    name = "ut_open_menu_main",
                    text_id = "ut_menu_main_title",
                    help_id = "ut_menu_main_description",
                    next_node = "ut_main_menu",
                    _meta = "item",
                })
                break
            end
        end
    end
    return scriptData
end

if HT:getSetting("enable_hide_mods_list") then
    function MenuCallbackHandler:is_modded_client()
        return false
    end

    function MenuCallbackHandler:is_not_modded_client()
        return true
    end

    function MenuCallbackHandler:build_mods_list()
        return {}
    end
end
