HT.Player = {}

function HT.Player:setLevel(level)
    local rank = 0
    pcall(function() rank = managers.experience:current_rank() end)
    managers.experience:reset()
    local ok = pcall(function() managers.experience:_set_current_level(level) end)
    if not ok then
        pcall(function() managers.experience:set_current_level(level) end)
    end
    pcall(function() managers.experience:set_current_rank(rank) end)
    HT.Player:refreshAndSave()
    HT:addAlert("ut_alert_level_set", HT.colors.success)
end

function HT.Player:setInfamyRank(infamyRank)
    pcall(function() managers.experience:set_current_rank(infamyRank) end)
    HT.Player:refreshAndSave()
    HT:addAlert("ut_alert_infamy_rank_set", HT.colors.success)
end

function HT.Player:addSpendingMoney(amount)
    managers.money:add_to_spending(amount)
    HT.Player:refreshAndSave()
    HT:addAlert("ut_alert_spending_money_added", HT.colors.success)
end

function HT.Player:addOffshoreMoney(amount)
    managers.money:add_to_offshore(amount)
    HT.Player:refreshAndSave()
    HT:addAlert("ut_alert_offshore_money_added", HT.colors.success)
end

function HT.Player:resetMoney()
    managers.money:reset()
    HT.Player:refreshAndSave()
    HT:addAlert("ut_alert_money_reset", HT.colors.success)
end

function HT.Player:addContinentalCoins(amount)
    managers.custom_safehouse:add_coins(amount)
    HT.Player:refreshAndSave()
    HT:addAlert("ut_alert_continental_coins_added", HT.colors.success)
end

function HT.Player:resetContinentalCoins()
    Global.custom_safehouse_manager.total = 0
    Global.custom_safehouse_manager.total_collected = 0
    HT.Player:refreshAndSave()
    HT:addAlert("ut_alert_continental_coins_reset", HT.colors.success)
end

function HT.Player:setSkillPointsHack(value)
    HT:setSetting("enable_skill_points_hack", value)
    if HT:getSetting("enable_skill_points_hack") and HT:getSetting("skill_points_total_amount") then
        local pts = HT:getSetting("skill_points_total_amount") - managers.skilltree:total_points_spent()
        pcall(function() managers.skilltree:_set_points(pts) end)
        HT.Player:refreshAndSave()
    end
    if value then
        HT:addAlert("ut_alert_skill_points_hack_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_skill_points_hack_disabled", HT.colors.success)
    end
    HT:addAlert("ut_alert_restart_the_game_to_apply_changes", HT.colors.warning)
end

function HT.Player:setSkillPointsTotalAmount(amount)
    HT:setSetting("skill_points_total_amount", amount)
    if HT:getSetting("enable_skill_points_hack") then
        local pts = HT:getSetting("skill_points_total_amount") - managers.skilltree:total_points_spent()
        pcall(function() managers.skilltree:_set_points(pts) end)
        HT.Player:refreshAndSave()
    end
    HT:addAlert("ut_alert_skill_points_total_amount_set", HT.colors.success)
    HT:addAlert("ut_alert_restart_the_game_to_apply_changes", HT.colors.warning)
end

function HT.Player:skillPointsHackHook()
    _G.CloneClass(SkillTreeManager)
    function SkillTreeManager:_verify_loaded_data(...)
        SkillTreeManager.orig._verify_loaded_data(self, HT:getSetting("skill_points_total_amount") - managers.experience:current_level())
    end
end

function HT.Player:addPerkPoints(amount)
    local ok = pcall(function() managers.skilltree:give_specialization_points(amount) end)
    if not ok then
        pcall(function() managers.skilltree:give_perk_points(amount) end)
    end
    HT.Player:refreshAndSave()
    HT:addAlert("ut_alert_perk_experience_added", HT.colors.success)
end

function HT.Player:resetPerkPoints()
    pcall(function()
        Global.skilltree_manager.specializations.total_points = 0
        managers.skilltree:reset_specializations()
    end)
    HT.Player:refreshAndSave()
    HT:addAlert("ut_alert_perk_points_reset", HT.colors.success)
end

function HT.Player:addItemsToInventory(category)
    for id, item in pairs(tweak_data.blackmarket[category]) do
        local globalValue = "normal"
        if item.global_value then
            globalValue = item.global_value
        elseif item.infamous then
            globalValue = "infamous"
        elseif item.dlc then
            globalValue = item.dlc
        end
        managers.blackmarket:add_to_inventory(globalValue, category, id, false)
    end
    HT.Player:refreshAndSave()
    if category == "weapon_mods" then
        HT:addAlert("ut_alert_added_one_of_all_weapon_mods", HT.colors.success)
    elseif category == "masks" then
        HT:addAlert("ut_alert_added_one_of_all_masks", HT.colors.success)
    elseif category == "materials" then
        HT:addAlert("ut_alert_added_one_of_all_materials", HT.colors.success)
    elseif category == "textures" then
        HT:addAlert("ut_alert_added_one_of_all_patterns", HT.colors.success)
    elseif category == "colors" then
        HT:addAlert("ut_alert_added_one_of_all_colors", HT.colors.success)
    end
end

function HT.Player:clearInventoryItems(category)
    for globalValue, data in pairs(Global.blackmarket_manager.inventory) do
        if data[category] then
            for key, item in pairs(data[category]) do
                Global.blackmarket_manager.inventory[globalValue][category][key] = nil
            end
        end
    end
    HT.Player:refreshAndSave()
    if category == "weapon_mods" then
        HT:addAlert("ut_alert_weapon_mods_cleared", HT.colors.success)
    elseif category == "masks" then
        HT:addAlert("ut_alert_masks_cleared", HT.colors.success)
    elseif category == "materials" then
        HT:addAlert("ut_alert_materials_cleared", HT.colors.success)
    elseif category == "textures" then
        HT:addAlert("ut_alert_patterns_cleared", HT.colors.success)
    elseif category == "colors" then
        HT:addAlert("ut_alert_colors_cleared", HT.colors.success)
    end
end

function HT.Player:unlockInventoryCategory(category)
    for id, data in pairs(tweak_data.upgrades.definitions) do
        if data.category == category then
            if category == "weapon" then
                if string.find(id, "_primary") or string.find(id, "_secondary") then
                    goto continue
                end
            end
            if not managers.upgrades:aquired(id) then
                managers.upgrades:aquire(id)
            end
        end
        ::continue::
    end
    HT.Player:refreshAndSave()
    if category == "weapon" then
        HT:addAlert("ut_alert_unlocked_all_weapons", HT.colors.success)
    elseif category == "melee_weapon" then
        HT:addAlert("ut_alert_unlocked_all_melee_weapons", HT.colors.success)
    elseif category == "grenade" then
        HT:addAlert("ut_alert_unlocked_all_throwables", HT.colors.success)
    elseif category == "armor" then
        HT:addAlert("ut_alert_unlocked_all_armors", HT.colors.success)
    end
end

function HT.Player:setAllSlots(value)
    for i = 1, 160 do
        Global.blackmarket_manager.unlocked_weapon_slots.primaries[i] = value
        Global.blackmarket_manager.unlocked_weapon_slots.secondaries[i] = value
        Global.blackmarket_manager.unlocked_mask_slots[i] = value
    end
    HT.Player:refreshAndSave()
    if value then
        HT:addAlert("ut_alert_unlocked_all_slots", HT.colors.success)
    else
        HT:addAlert("ut_alert_locked_all_slots", HT.colors.success)
    end
end

function HT.Player:removeExclamationMarks()
    Global.blackmarket_manager.new_drops = {}
    HT.Player:refreshAndSave()
    HT:addAlert("ut_alert_exclamation_marks_removed", HT.colors.success)
end

function HT.Player:unlockAllTrophies()
    local trophies = Global.custom_safehouse_manager.trophies
    for key, trophy in pairs(trophies) do
        trophy.completed = true
    end
    HT.Player:refreshAndSave()
    HT:addAlert("ut_alert_unlocked_all_trophies", HT.colors.success)
end

function HT.Player:lockAllTrophies()
    managers.custom_safehouse:flush_completed_trophies()
    local trophies = Global.custom_safehouse_manager.trophies
    for key, trophy in pairs(trophies) do
        trophy.completed = false
    end
    HT.Player:refreshAndSave()
    HT:addAlert("ut_alert_locked_all_trophies", HT.colors.success)
end

function HT.Player:unlockAllSteamAchievements()
    if not managers.achievment then return end
    local achievements = managers.achievment.achievments or {}
    for id, achievement in pairs(achievements) do
        pcall(function() managers.achievment:award(id) end)
    end
    HT.Player:refreshAndSave()
    HT:addAlert("ut_alert_unlocked_all_steam_achievements", HT.colors.success)
end

function HT.Player:lockAllSteamAchievements()
    if managers.achievment and managers.achievment.clear_all_steam then
        managers.achievment:clear_all_steam()
    end
    HT.Player:refreshAndSave()
    HT:addAlert("ut_alert_locked_all_steam_achievements", HT.colors.success)
end

function HT.Player:refreshAndSave()
    if managers.menu_component and managers.menu_component.refresh_player_profile_gui then
        pcall(function() managers.menu_component:refresh_player_profile_gui() end)
    end
    if managers.savefile and managers.savefile.save_progress then
        pcall(function() managers.savefile:save_progress() end)
    end
end
