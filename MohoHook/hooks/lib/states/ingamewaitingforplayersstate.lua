_G.CloneClass(IngameWaitingForPlayersState)
function IngameWaitingForPlayersState:at_exit(...)
    IngameWaitingForPlayersState.orig.at_exit(self, ...)

    HT.debugLogClass.allow_new_entries = false

    local function apply(fn)
        local ok, err = pcall(fn)
        if not ok then
            pcall(function() HT.debugLogClass:log("Re-apply failed: " .. tostring(err)) end)
        end
    end

    apply(function() HT.Dexterity:setGodMode(HT:getSetting("enable_god_mode"), false) end)
    apply(function() HT.Dexterity:setInfiniteStamina(HT:getSetting("enable_infinite_stamina")) end)
    apply(function() HT.Dexterity:setRunInAllDirections(HT:getSetting("enable_run_in_all_directions")) end)
    apply(function() HT.Dexterity:setCanRunWithAnyBag(HT:getSetting("enable_can_run_with_any_bag")) end)
    apply(function() HT.Dexterity:setFastMask(HT:getSetting("enable_fast_mask")) end)
    apply(function() HT.Dexterity:setNoCarryCooldown(HT:getSetting("enable_no_carry_cooldown")) end)
    apply(function() HT.Dexterity:setNoFlashbangs(HT:getSetting("enable_no_flashbangs")) end)
    apply(function() HT.Dexterity:setInstantSwap(HT:getSetting("enable_instant_swap")) end)
    apply(function() HT.Dexterity:setInstantReload(HT:getSetting("enable_instant_reload")) end)
    apply(function() HT.Dexterity:setShootThroughWalls(HT:getSetting("enable_shoot_through_walls"), false) end)
    apply(function() HT.Dexterity:setNoRecoil(HT:getSetting("enable_no_recoil")) end)
    apply(function() HT.Dexterity:setNoSpread(HT:getSetting("enable_no_spread")) end)
    apply(function() HT.Dexterity:setUnlimitedAmmo(HT:getSetting("enable_unlimited_ammo")) end)
    apply(function() HT.Dexterity:setInstantInteraction(HT:getSetting("enable_instant_interaction")) end)
    apply(function() HT.Dexterity:setInstantDeployment(HT:getSetting("enable_instant_deployment")) end)
    apply(function() HT.Dexterity:setUnlimitedEquipment(HT:getSetting("enable_unlimited_equipment")) end)
    apply(function() HT.Dexterity:setMoveSpeedMultiplier(HT:getSetting("enable_move_speed_multiplier"), HT:getSetting("move_speed_multiplier")) end)
    apply(function() HT.Dexterity:setThrowDistanceMultiplier(HT:getSetting("enable_throw_distance_multiplier"), HT:getSetting("throw_distance_multiplier")) end)
    apply(function() HT.Dexterity:setFireRateMultiplier(HT:getSetting("enable_fire_rate_multiplier"), HT:getSetting("fire_rate_multiplier")) end)
    apply(function() HT.Dexterity:setDamageMultiplier(HT:getSetting("enable_damage_multiplier"), HT:getSetting("damage_multiplier")) end)
    apply(function() HT.Dexterity:setNoFallDamage(HT:getSetting("enable_no_fall_damage")) end)
    apply(function()
        HT.Dexterity.spinbotSpeed = HT:getSetting("spinbot_speed") or 720
        HT.Dexterity:setSpinbot(HT:getSetting("enable_spinbot"), false)
    end)
    apply(function() HT.Dexterity:setFullAuto(HT:getSetting("enable_full_auto")) end)
    apply(function() HT.Dexterity:clearCarryStack() end)
    apply(function() HT.Dexterity:setInfiniteBags(HT:getSetting("enable_infinite_bags")) end)
    apply(function() HT.Dexterity:setSlowMotion(HT:getSetting("enable_slow_motion")) end)
    apply(function() HT.Dexterity:setUnlimitedGrenades(HT:getSetting("enable_unlimited_grenades")) end)
    apply(function() HT.Dexterity:setInfiniteArmor(HT:getSetting("enable_infinite_armor")) end)
    apply(function() HT.Dexterity:setExplodingBullets(HT:getSetting("enable_exploding_bullets")) end)
    apply(function() HT.Mission:setNoCivilianPenalty(HT:getSetting("enable_no_civilian_penalty")) end)
    apply(function() HT.Troll:setRainbowChat(HT:getSetting("rainbow_chat")) end)
    apply(function()
        HT.Dexterity.customFov = HT:getSetting("custom_fov") or 75
        HT.Dexterity:setCustomFov(HT:getSetting("enable_custom_fov"), false)
    end)
    apply(function() HT.Dexterity:setJumpMultiplier(HT:getSetting("jump_multiplier") or 1) end)
    apply(function() HT.Aimbot:loadSettings() end)
    apply(function() HT.Team:registerHooks() end)

    HT.debugLogClass.allow_new_entries = true
end
