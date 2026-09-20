HT.Dexterity = {}

HT.Dexterity.enableUnlimitedEquipment = false

HT.Dexterity.enableMoveSpeedMultiplier = false
HT.Dexterity.enableThrowDistanceMultiplier = false
HT.Dexterity.enableFireRateMultiplier = false
HT.Dexterity.enableDamageMultiplier = false

HT.Dexterity.moveSpeedMultiplier = 1
HT.Dexterity.throwDistanceMultiplier = 1
HT.Dexterity.fireRateMultiplier = 1
HT.Dexterity.damageMultiplier = 1

HT.Dexterity.tweakDataCarryTypes = nil
HT.Dexterity.godModeReset = false

HT.Dexterity.enableNoclip = false
HT.Dexterity.noclipSpeedMultiplier = 2
HT.Dexterity.noclipAxisMove = { x = 0, y = 0, z = 0 }

HT.Dexterity.enableSpinbot = false
HT.Dexterity.spinbotSpeed = 720
HT.Dexterity.spinbotHooked = false

HT.Dexterity.enableFullAuto = false

HT.Dexterity.enableInfiniteBags = false
HT.Dexterity.carryStack = {}
HT.Dexterity.infiniteBagsHooked = false

HT.Dexterity.enableSlowMotion = false

HT.Dexterity.enableUnlimitedGrenades = false

HT.Dexterity.enableInfiniteArmor = false

HT.Dexterity.enableExplodingBullets = false
HT.Dexterity.explodingBulletsNextT = 0

HT.Dexterity.enableTracers = false

HT.Dexterity.enableCustomFov = false
HT.Dexterity.customFov = 75
HT.Dexterity.fovHooked = false

HT.Dexterity.jumpMultiplier = 1
HT.Dexterity.tweakJumpVelocityBackup = nil

-- Centralized PlayerCamera:update post-hook registry. Multiple features need
-- to run after the camera updates each frame; wrapping PlayerCamera:update
-- more than once breaks earlier wrappers (each wrapper replaces the last),
-- so every feature registers a handler here instead.
HT.Dexterity.cameraHooks = {}
HT.Dexterity.cameraHooked = false
HT.Dexterity.cameraHookPending = false

function HT.Dexterity:isVectorLike(v)
    if type(v) ~= "userdata" then return false end
    local ok, x = pcall(function() return v.x end)
    if not ok or type(x) ~= "number" then return false end
    local okY, y = pcall(function() return v.y end)
    local okZ, z = pcall(function() return v.z end)
    return okY and okZ and type(y) == "number" and type(z) == "number"
end

local function deepCopyTree(v)
    if HT.Dexterity:isVectorLike(v) then
        return Vector3(v.x, v.y, v.z)
    end
    if type(v) ~= "table" then return v end
    local out = {}
    for k, val in pairs(v) do out[k] = deepCopyTree(val) end
    return out
end

local function scaleTree(dst, base, mult)
    if HT.Dexterity:isVectorLike(base) then
        dst.x = base.x * mult
        dst.y = base.y * mult
        dst.z = base.z * mult
        return
    end
    if type(base) ~= "table" then return end
    for k, v in pairs(base) do
        if type(v) == "number" then
            dst[k] = v * mult
        elseif type(v) == "table" or HT.Dexterity:isVectorLike(v) then
            if dst[k] == nil then
                dst[k] = deepCopyTree(v)
            end
            scaleTree(dst[k], v, mult)
        end
    end
end

local function inHeistAndAlive()
    if not HT:isInGame() or not HT:isInHeist() then return false end
    local player = managers.player:player_unit()
    return alive(player), player
end

-- Installs the shared PlayerCamera:update wrapper. Game classes are not
-- loaded yet during early startup, so if PlayerCamera doesn't exist yet we
-- mark it pending and retry later (see bootupstate hook).
function HT.Dexterity:_ensureCameraHook()
    if HT.Dexterity.cameraHooked then return true end
    if type(PlayerCamera) ~= "table" then
        HT.Dexterity.cameraHookPending = true
        return false
    end
    local ok = pcall(function()
        _G.CloneClass(PlayerCamera)
        local orig_update = PlayerCamera.orig.update
        function PlayerCamera:update(t, dt)
            orig_update(self, t, dt)
            for _, handler in ipairs(HT.Dexterity.cameraHooks) do
                pcall(handler, self, t, dt)
            end
        end
    end)
    if ok then
        HT.Dexterity.cameraHooked = true
        HT.Dexterity.cameraHookPending = false
    end
    return ok
end

function HT.Dexterity:addCameraHook(fn)
    table.insert(HT.Dexterity.cameraHooks, fn)
    return self:_ensureCameraHook()
end

function HT.Dexterity:setGodMode(value, --[[optional]]showAlert)
    if value == nil then
        return
    end

    HT:setSetting("enable_god_mode", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_god_mode", value)
    
    if managers.player
    and managers.player.player_unit
    and managers.player:player_unit().character_damage
    and managers.player:player_unit():character_damage().set_god_mode then
        managers.player:player_unit():character_damage():set_god_mode(value)
    end

    if showAlert == false then
        return
    end

    if value then
        HT:addAlert("ut_alert_god_mode_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_god_mode_disabled", HT.colors.success)
    end
end

function HT.Dexterity:resetGodMode()
    local player = managers.player and managers.player:player_unit()
    if player and alive(player) and player.character_damage and player:character_damage().set_god_mode then
        player:character_damage():set_god_mode(false)
    end
end

function HT.Dexterity:setInfiniteStamina(value)
    HT:setSetting("enable_infinite_stamina", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_infinite_stamina", value)
    
    _G.CloneClass(PlayerMovement)
    if value then
        function PlayerMovement:_change_stamina() end

        function PlayerMovement:is_stamina_drained() return false end
    else
        PlayerMovement._change_stamina = PlayerMovement.orig._change_stamina
        PlayerMovement.is_stamina_drained = PlayerMovement.orig.is_stamina_drained
    end
end

function HT.Dexterity:setNoclip(value, isUpdate, --[[optional]]showAlert)
    HT.Dexterity.enableNoclip = value

    local player = managers.player and managers.player:player_unit()
    if not player or not alive(player) then
        HT.Dexterity.noclipAxisMove = { x = 0, y = 0, z = 0 }
        if showAlert == false then return end
        return
    end

    local keyboard = Input:keyboard()
    local keyboardDown = keyboard.down
    local camera = player:camera()
    if not camera then
        HT.Dexterity.noclipAxisMove = { x = 0, y = 0, z = 0 }
        if showAlert == false then return end
        return
    end
    local cameraRotation = camera:rotation()
    local speed = HT.Dexterity.noclipSpeedMultiplier or 2
    if value then
        HT.Dexterity.noclipAxisMove.x = keyboardDown(keyboard, Idstring("w")) and speed or keyboardDown(keyboard, Idstring("s")) and -speed or 0
        HT.Dexterity.noclipAxisMove.y = keyboardDown(keyboard, Idstring("d")) and speed or keyboardDown(keyboard, Idstring("a")) and -speed or 0
        HT.Dexterity.noclipAxisMove.z = keyboardDown(keyboard, Idstring("space")) and speed or keyboardDown(keyboard, Idstring("left ctrl")) and -speed or 0
        local moveDir = cameraRotation:x() * HT.Dexterity.noclipAxisMove.y + cameraRotation:y() * HT.Dexterity.noclipAxisMove.x + cameraRotation:z() * HT.Dexterity.noclipAxisMove.z
        local moveDelta = moveDir * 10
        local newPos = player:position() + moveDelta
        managers.player:warp_to(newPos, cameraRotation, 1, Rotation(0, 0, 0))
    else
        HT.Dexterity.noclipAxisMove = { x = 0, y = 0, z = 0 }
    end

    local isNotUpdate = isUpdate == nil or isUpdate == false

    if showAlert == false then
        return
    end

    if value and isNotUpdate then
        HT:addAlert("ut_alert_noclip_enabled", HT.colors.success)
    elseif isNotUpdate then
        HT:addAlert("ut_alert_noclip_disabled", HT.colors.success)
    end
end

function HT.Dexterity:setRunInAllDirections(value)
    HT:setSetting("enable_run_in_all_directions", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_run_in_all_directions", value)
    
    _G.CloneClass(PlayerStandard)
    if value then
        function PlayerStandard:_can_run_directional() return true end
    else
        PlayerStandard._can_run_directional = PlayerStandard.orig._can_run_directional
    end
end

function HT.Dexterity:setCanRunWithAnyBag(value)
    HT:setSetting("enable_can_run_with_any_bag", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_can_run_with_any_bag", value)

    HT.Dexterity.tweakDataCarryTypes = HT.Dexterity.tweakDataCarryTypes or deep_clone(tweak_data.carry.types)
    if value then
        for carry_type, data in pairs(tweak_data.carry.types) do
            if type(data) == "table" then
                tweak_data.carry.types[carry_type].can_run = true
            end
        end
    else
        for carry_type, data in pairs(HT.Dexterity.tweakDataCarryTypes) do
            if tweak_data.carry.types[carry_type] and type(data) == "table" then
                tweak_data.carry.types[carry_type].can_run = data.can_run
            end
        end
    end
end

function HT.Dexterity:setFastMask(value)
    HT:setSetting("enable_fast_mask", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_fast_mask", value)

    HT.Dexterity.tweakDataPlayerPutOnMaskTime = HT.Dexterity.tweakDataPlayerPutOnMaskTime or tweak_data.player.put_on_mask_time
    if value then
        tweak_data.player.put_on_mask_time = 0.25
    else
        tweak_data.player.put_on_mask_time = HT.Dexterity.tweakDataPlayerPutOnMaskTime
    end
end

function HT.Dexterity:setNoCarryCooldown(value)
    HT:setSetting("enable_no_carry_cooldown", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_no_carry_cooldown", value)
    
    _G.CloneClass(PlayerManager)
    if value then
        function PlayerManager:carry_blocked_by_cooldown() return false end
    else
        PlayerManager.carry_blocked_by_cooldown = PlayerManager.orig.carry_blocked_by_cooldown
    end
end

function HT.Dexterity:setNoFlashbangs(value)
    HT:setSetting("enable_no_flashbangs", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_no_flashbangs", value)

    _G.CloneClass(CoreEnvironmentControllerManager)
    if value then
        function CoreEnvironmentControllerManager:set_flashbang() end
    else
        CoreEnvironmentControllerManager.set_flashbang = CoreEnvironmentControllerManager.orig.set_flashbang
    end
end

function HT.Dexterity:setInstantSwap(value)
    HT:setSetting("enable_instant_swap", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_instant_swap", value)

    _G.CloneClass(PlayerStandard)
    if value then
        function PlayerStandard:_get_swap_speed_multiplier() return HT.fakeMaxInteger end
    else
        PlayerStandard._get_swap_speed_multiplier = PlayerStandard.orig._get_swap_speed_multiplier
    end
end

function HT.Dexterity:setInstantReload(value)
    HT:setSetting("enable_instant_reload", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_instant_reload", value)

    _G.CloneClass(RaycastWeaponBase)
    if value then
        function RaycastWeaponBase:can_reload()
            pcall(function()
                self._ammo_remaining_in_clip = self:get_ammo_max_per_clip()
                managers.hud:set_ammo_amount(self:selection_index(), self:ammo_info())
            end)
            return false
        end
    else
        RaycastWeaponBase.can_reload = RaycastWeaponBase.orig.can_reload
    end
end

function HT.Dexterity:setShootThroughWalls(value, --[[optional]]showAlert)
    HT:setSetting("enable_shoot_through_walls", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_shoot_through_walls", value)

    _G.CloneClass(RaycastWeaponBase)
    _G.CloneClass(NewRaycastWeaponBase)

    if value then
        RaycastWeaponBase._can_shoot_through_shield = true
        RaycastWeaponBase._can_shoot_through_wall = true
        NewRaycastWeaponBase._can_shoot_through_shield = true
        NewRaycastWeaponBase._can_shoot_through_wall = true
    else
        RaycastWeaponBase._can_shoot_through_shield = RaycastWeaponBase.orig._can_shoot_through_shield
        RaycastWeaponBase._can_shoot_through_wall = RaycastWeaponBase.orig._can_shoot_through_wall
        NewRaycastWeaponBase._can_shoot_through_shield = NewRaycastWeaponBase.orig._can_shoot_through_shield
        NewRaycastWeaponBase._can_shoot_through_wall = NewRaycastWeaponBase.orig._can_shoot_through_wall
    end

    local player = managers.player and managers.player:player_unit()
    if player and alive(player) and player.inventory and player:inventory() and player:inventory()._available_selections then
        for _, selection in pairs(player:inventory()._available_selections) do
            if selection and selection.unit and alive(selection.unit) then
                local unitBase = selection.unit:base()
                if unitBase then
                    if value then
                        unitBase._bullet_slotmask_old = unitBase._bullet_slotmask
                        unitBase._bullet_slotmask = World:make_slot_mask(7, 11, 12, 14, 16, 17, 18, 21, 22, 25, 26, 33, 34, 35)
                    else
                        if unitBase._bullet_slotmask_old then
                            unitBase._bullet_slotmask = unitBase._bullet_slotmask_old
                            unitBase._bullet_slotmask_old = nil
                        end
                    end
                end
            end
        end
    end

    if showAlert == false then
        return
    end

    if value then
        HT:addAlert("ut_alert_shoot_through_walls_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_shoot_through_walls_disabled", HT.colors.success)
    end
end

function HT.Dexterity:setNoRecoil(value)
    HT:setSetting("enable_no_recoil", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_no_recoil", value)

    _G.CloneClass(NewRaycastWeaponBase)
    if value then
        function NewRaycastWeaponBase:recoil_multiplier() return 0 end
    else
        NewRaycastWeaponBase.recoil_multiplier = NewRaycastWeaponBase.orig.recoil_multiplier
    end
end

function HT.Dexterity:setNoSpread(value)
    HT:setSetting("enable_no_spread", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_no_spread", value)

    _G.CloneClass(NewRaycastWeaponBase)
    if value then
        function NewRaycastWeaponBase:spread_multiplier() return 0 end
    else
        NewRaycastWeaponBase.spread_multiplier = NewRaycastWeaponBase.orig.spread_multiplier
    end
end

function HT.Dexterity:setUnlimitedAmmo(value)
    HT:setSetting("enable_unlimited_ammo", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_unlimited_ammo", value)

    _G.CloneClass(RaycastWeaponBase)
    _G.CloneClass(SawWeaponBase)
    if value then
        function RaycastWeaponBase:clip_empty()
            self:set_ammo_total(self:get_ammo_max())
            return self:get_ammo_remaining_in_clip() == 0
        end

        function SawWeaponBase:clip_empty()
            self:set_ammo_total(self:get_ammo_max())
            return self:get_ammo_remaining_in_clip() == 0
        end
    else
        RaycastWeaponBase.clip_empty = RaycastWeaponBase.orig.clip_empty
        SawWeaponBase.clip_empty = SawWeaponBase.orig.clip_empty
    end
end

function HT.Dexterity:setInstantInteraction(value)
    HT:setSetting("enable_instant_interaction", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_instant_interaction", value)
    
    _G.CloneClass(BaseInteractionExt)
    if value then
        function BaseInteractionExt:_get_timer() return 0.001 end
    else
        BaseInteractionExt._get_timer = BaseInteractionExt.orig._get_timer
    end
end

function HT.Dexterity:setInstantDeployment(value)
    HT:setSetting("enable_instant_deployment", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_instant_deployment", value)

    _G.CloneClass(PlayerManager)
    if value then
        function PlayerManager:selected_equipment_deploy_timer() return 0.001 end
    else
        PlayerManager.selected_equipment_deploy_timer = PlayerManager.orig.selected_equipment_deploy_timer
    end
end

function HT.Dexterity:setUnlimitedEquipment(value)
    HT:setSetting("enable_unlimited_equipment", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_unlimited_equipment", value)
    
    HT.Dexterity.enableUnlimitedEquipment = value
    _G.CloneClass(BaseInteractionExt)
    _G.CloneClass(PlayerManager)
    if value then
        function BaseInteractionExt:_has_required_upgrade() return true end

        function BaseInteractionExt:_has_required_deployable() return true end

        function BaseInteractionExt:can_interact() return true end

        function PlayerManager:on_used_body_bag() end

        function PlayerManager:remove_equipment() end

        function PlayerManager:remove_special() end
    else
        BaseInteractionExt._has_required_upgrade = BaseInteractionExt.orig._has_required_upgrade
        BaseInteractionExt._has_required_deployable = BaseInteractionExt.orig._has_required_deployable
        BaseInteractionExt.can_interact = BaseInteractionExt.orig.can_interact
        PlayerManager.on_used_body_bag = PlayerManager.orig.on_used_body_bag
        PlayerManager.remove_equipment = PlayerManager.orig.remove_equipment
        PlayerManager.remove_special = PlayerManager.orig.remove_special
    end
end

function HT.Dexterity:setMoveSpeedMultiplier(value, multiplier)
    if value and type(multiplier) ~= "number" then
        return
    end

    HT:setSetting("enable_move_speed_multiplier", value)
    HT:setSetting("move_speed_multiplier", multiplier)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_set_move_speed_multiplier", value)
    
    _G.CloneClass(PlayerManager)
    if value then
        function PlayerManager:movement_speed_multiplier() return multiplier end
    else
        PlayerManager.movement_speed_multiplier = PlayerManager.orig.movement_speed_multiplier
    end
end

function HT.Dexterity:setThrowDistanceMultiplier(value, multiplier)
    if value and type(multiplier) ~= "number" then
        return
    end

    HT:setSetting("enable_throw_distance_multiplier", value)
    HT:setSetting("throw_distance_multiplier", multiplier)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_set_throw_distance_multiplier", value)
    
    HT.Dexterity.tweakDataCarryTypes = HT.Dexterity.tweakDataCarryTypes or deep_clone(tweak_data.carry.types)
    if value then
        for carry_type, data in pairs(tweak_data.carry.types) do
            if type(data) == "table" then
                tweak_data.carry.types[carry_type].throw_distance_multiplier = multiplier
            end
        end
    else
        for carry_type, data in pairs(HT.Dexterity.tweakDataCarryTypes) do
            if tweak_data.carry.types[carry_type] and type(data) == "table" then
                tweak_data.carry.types[carry_type].throw_distance_multiplier = data.throw_distance_multiplier
            end
        end
    end
end

function HT.Dexterity:setFireRateMultiplier(value, multiplier)
    if value and type(multiplier) ~= "number" then
        return
    end

    HT:setSetting("enable_fire_rate_multiplier", value)
    HT:setSetting("fire_rate_multiplier", multiplier)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_set_fire_rate_multiplier", value)

    _G.CloneClass(NewRaycastWeaponBase)
    if value then
        function NewRaycastWeaponBase:fire_rate_multiplier() return multiplier end
    else
        NewRaycastWeaponBase.fire_rate_multiplier = NewRaycastWeaponBase.orig.fire_rate_multiplier
    end
end

function HT.Dexterity:setDamageMultiplier(value, multiplier)
    if value and type(multiplier) ~= "number" then
        return
    end

    HT:setSetting("enable_damage_multiplier", value)
    HT:setSetting("damage_multiplier", multiplier)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_set_damage_multiplier", value)

    _G.CloneClass(CopDamage)
    if value then
        function CopDamage:damage_bullet(attack_data)
            if attack_data.attacker_unit == managers.player:player_unit() then
                attack_data.damage = multiplier * 10
            end
            return self.orig.damage_bullet(self, attack_data)
        end

        function CopDamage:damage_melee(attack_data)
            if attack_data.attacker_unit == managers.player:player_unit() then
                attack_data.damage = multiplier * 10
            end
            return self.orig.damage_melee(self, attack_data)
        end
    else
        CopDamage.damage_bullet = CopDamage.orig.damage_bullet
        CopDamage.damage_melee = CopDamage.orig.damage_melee
    end
end

function HT.Dexterity:setNoFallDamage(value)
    HT:setSetting("enable_no_fall_damage", value)
    _G.CloneClass(PlayerDamage)
    if value then
        function PlayerDamage:damage_fall() end
    else
        PlayerDamage.damage_fall = PlayerDamage.orig.damage_fall
    end
    if value then
        HT:addAlert("No fall damage enabled", HT.colors.success, false)
    else
        HT:addAlert("No fall damage disabled", HT.colors.success, false)
    end
end

function HT.Dexterity:installSpinbotHook()
    if HT.Dexterity.spinbotHooked then
        return
    end
    HT.Dexterity.spinbotHooked = true
    HT.Dexterity:addCameraHook(function(cam, t, dt)
        if not HT.Dexterity.enableSpinbot then
            return
        end
        local alive_ok = inHeistAndAlive()
        if not alive_ok then
            return
        end

        local player = managers.player:player_unit()

        local state = player:movement():current_state()
        if not state then
            return
        end

        local state_name = state._name or ""
        if state_name == "bleed_out" or state_name == "fatal"
        or state_name == "arrested" or state_name == "incapacitated"
        or state_name == "tased" then
            return
        end

        local rot = cam:rotation()
        local speed = HT.Dexterity.spinbotSpeed or 720
        local new_yaw = rot:yaw() + speed * dt
        while new_yaw > 180 do new_yaw = new_yaw - 360 end
        while new_yaw < -180 do new_yaw = new_yaw + 360 end

        pcall(function()
            cam:set_rotation(Rotation(new_yaw, rot:pitch(), 0))
        end)
    end)
end

function HT.Dexterity:setSpinbot(value, --[[optional]]showAlert)
    HT.Dexterity.enableSpinbot = value and true or false
    HT:setSetting("enable_spinbot", HT.Dexterity.enableSpinbot)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_spinbot", HT.Dexterity.enableSpinbot)
    HT.Dexterity:installSpinbotHook()

    if showAlert == false then
        return
    end

    if HT.Dexterity.enableSpinbot then
        HT:addAlert("ut_alert_spinbot_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_spinbot_disabled", HT.colors.success)
    end
end

function HT.Dexterity:setSpinbotSpeed(speed)
    if type(speed) ~= "number" then
        return
    end
    HT.Dexterity.spinbotSpeed = speed
    HT:setSetting("spinbot_speed", speed)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_set_spinbot_speed", speed)
end

function HT.Dexterity:setFullAuto(value)
    HT.Dexterity.enableFullAuto = value and true or false
    HT:setSetting("enable_full_auto", HT.Dexterity.enableFullAuto)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_full_auto", HT.Dexterity.enableFullAuto)

    if type(RaycastWeaponBase) ~= "table" or type(NewRaycastWeaponBase) ~= "table" then
        -- Weapon classes aren't loaded yet during early startup; retry later.
        HT.Dexterity.fullAutoApplyPending = true
        return
    end
    HT.Dexterity.fullAutoApplyPending = false

    _G.CloneClass(RaycastWeaponBase)
    _G.CloneClass(NewRaycastWeaponBase)
    if value then
        function RaycastWeaponBase:fire_mode() return "auto" end
        function NewRaycastWeaponBase:fire_mode() return "auto" end
    else
        RaycastWeaponBase.fire_mode = RaycastWeaponBase.orig.fire_mode
        NewRaycastWeaponBase.fire_mode = NewRaycastWeaponBase.orig.fire_mode
    end
end

function HT.Dexterity:clearCarryStack()
    HT.Dexterity.carryStack = {}
end

function HT.Dexterity:pushCarryStack()
    local ok, data = pcall(function()
        if not managers.player or not managers.player:is_carrying() then
            return nil
        end
        return managers.player:get_my_carry_data()
    end)
    if not ok or type(data) ~= "table" or not data.carry_id then
        return
    end
    table.insert(HT.Dexterity.carryStack, {
        carry_id             = data.carry_id,
        multiplier           = data.multiplier,
        dye_initiated        = true,
        has_dye_pack         = data.has_dye_pack,
        dye_value_multiplier = data.dye_value_multiplier,
    })
end

function HT.Dexterity:popCarryStack()
    if not HT.Dexterity.enableInfiniteBags then
        return
    end
    local data = table.remove(HT.Dexterity.carryStack)
    if not data then
        return
    end
    pcall(function()
        local pman = managers.player
        local player = pman and pman:player_unit()
        if pman and player and alive(player) then
            pman:set_carry(data.carry_id, data.multiplier or 1, data.dye_initiated, data.has_dye_pack, data.dye_value_multiplier)
        end
    end)
end

function HT.Dexterity:installInfiniteBagsHooks()
    if HT.Dexterity.infiniteBagsHooked then
        return
    end
    if type(CarryInteractionExt) ~= "table" or type(PlayerManager) ~= "table" then
        return
    end
    if not Hooks or not Hooks.PreHook or not Hooks.PostHook then
        return
    end
    HT.Dexterity.infiniteBagsHooked = true

    Hooks:PreHook(CarryInteractionExt, "interact", "HT_CarryInteractionExt_interact_stack", function(self, player)
        if HT.Dexterity.enableInfiniteBags then
            HT.Dexterity:pushCarryStack()
        end
    end)

    Hooks:PostHook(PlayerManager, "drop_carry", "HT_PlayerManager_drop_carry_pop", function(...)
        HT.Dexterity:popCarryStack()
    end)

    Hooks:PostHook(PlayerManager, "bank_carry", "HT_PlayerManager_bank_carry_pop", function(...)
        HT.Dexterity:popCarryStack()
    end)
end

function HT.Dexterity:setInfiniteBags(value)
    HT.Dexterity.enableInfiniteBags = value and true or false
    HT:setSetting("enable_infinite_bags", HT.Dexterity.enableInfiniteBags)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_infinite_bags", HT.Dexterity.enableInfiniteBags)

    if type(CarryInteractionExt) ~= "table" then
        return
    end

    HT.Dexterity:installInfiniteBagsHooks()

    _G.CloneClass(CarryInteractionExt)
    if value then
        function CarryInteractionExt:_interact_blocked(player)
            if self._unit and alive(self._unit) and self._unit:carry_data() and self._unit:carry_data():is_attached_to_zipline_unit() then
                return true
            end
            return false
        end

        function CarryInteractionExt:can_select(player)
            if self._unit and alive(self._unit) and self._unit:carry_data() and self._unit:carry_data():is_attached_to_zipline_unit() then
                return false
            end
            return CarryInteractionExt.super.can_select(self, player)
        end

        if HT.Mission and HT.Mission.disableCarryVerify then
            HT.Mission:disableCarryVerify()
        end
        HT:addAlert("ut_alert_infinite_bags_enabled", HT.colors.success)
    else
        CarryInteractionExt._interact_blocked = CarryInteractionExt.orig._interact_blocked
        CarryInteractionExt.can_select        = CarryInteractionExt.orig.can_select
        HT.Dexterity:clearCarryStack()
        HT:addAlert("ut_alert_infinite_bags_disabled", HT.colors.success)
    end
end

function HT.Dexterity:setSlowMotion(value)
    HT.Dexterity.enableSlowMotion = value and true or false
    HT:setSetting("enable_slow_motion", HT.Dexterity.enableSlowMotion)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_slow_motion", HT.Dexterity.enableSlowMotion)

    pcall(function()
        local tsm = managers.timespeed
        if not tsm then
            return
        end
        local id = Idstring("HT_slow_motion")
        if value then
            tsm:play_effect(id, {
                timer = "game",
                affect_timer = "game",
                speed = 0.35,
                fade_in = 0.1,
                fade_out = 0.5,
                sync = false
            })
        else
            tsm:stop_effect(id, 0.5)
        end
    end)

    if HT.Dexterity.enableSlowMotion then
        HT:addAlert("ut_alert_slow_motion_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_slow_motion_disabled", HT.colors.success)
    end
end

function HT.Dexterity:setUnlimitedGrenades(value)
    HT.Dexterity.enableUnlimitedGrenades = value and true or false
    HT:setSetting("enable_unlimited_grenades", HT.Dexterity.enableUnlimitedGrenades)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_unlimited_grenades", HT.Dexterity.enableUnlimitedGrenades)

    if type(PlayerManager) ~= "table" then
        return
    end
    _G.CloneClass(PlayerManager)

    if value then
        function PlayerManager:add_grenade_amount(amount, sync)
            if amount < 0 then
                amount = 0
                sync = false
            end
            return PlayerManager.orig.add_grenade_amount(self, amount, sync)
        end
    else
        PlayerManager.add_grenade_amount = PlayerManager.orig.add_grenade_amount
    end
end

function HT.Dexterity:setInfiniteArmor(value)
    HT.Dexterity.enableInfiniteArmor = value and true or false
    HT:setSetting("enable_infinite_armor", HT.Dexterity.enableInfiniteArmor)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_infinite_armor", HT.Dexterity.enableInfiniteArmor)

    _G.CloneClass(PlayerDamage)
    if value then
        function PlayerDamage:set_regenerate_timer_to_max()
            PlayerDamage.orig.set_regenerate_timer_to_max(self)
            self._regenerate_timer = 0
        end
    else
        PlayerDamage.set_regenerate_timer_to_max = PlayerDamage.orig.set_regenerate_timer_to_max
    end

    if HT.Dexterity.enableInfiniteArmor then
        HT:addAlert("ut_alert_infinite_armor_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_infinite_armor_disabled", HT.colors.success)
    end
end

function HT.Dexterity:setExplodingBullets(value)
    HT.Dexterity.enableExplodingBullets = value and true or false
    HT:setSetting("enable_exploding_bullets", HT.Dexterity.enableExplodingBullets)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_exploding_bullets", HT.Dexterity.enableExplodingBullets)

    _G.CloneClass(InstantBulletBase)
    if value then
        function InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound)
            local result = InstantBulletBase.orig.on_collision(self, col_ray, weapon_unit, user_unit, damage, blank, no_sound)

            pcall(function()
                if not HT.Dexterity.enableExplodingBullets then
                    return
                end
                if not (user_unit and alive(user_unit) and user_unit == managers.player:player_unit()) then
                    return
                end
                if type(col_ray) ~= "table" or not col_ray.position or not col_ray.normal then
                    return
                end

                local now = TimerManager:main():time()
                if now < HT.Dexterity.explodingBulletsNextT then
                    return
                end
                HT.Dexterity.explodingBulletsNextT = now + 0.05

                local range = 250
                local params = {
                    camera_shake_mul = 4,
                    sound_event = "grenade_explode"
                }

                managers.explosion:explode_on_client(col_ray.position, col_ray.normal, user_unit, 40, range, 0.5, params)

                if Network:is_server() then
                    managers.explosion:detect_and_give_dmg({
                        player_damage = 0,
                        hit_pos = col_ray.position,
                        range = range,
                        collision_slotmask = managers.slot:get_mask("explosion_targets"),
                        curve_pow = 1,
                        damage = 500,
                        ignore_unit = user_unit,
                        alert_radius = 1200,
                        user = user_unit,
                        owner = weapon_unit
                    })
                end
            end)

            return result
        end
    else
        InstantBulletBase.on_collision = InstantBulletBase.orig.on_collision
    end

    if HT.Dexterity.enableExplodingBullets then
        HT:addAlert("ut_alert_exploding_bullets_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_exploding_bullets_disabled", HT.colors.success)
    end
end

function HT.Dexterity:setTracers(value)
    if value == nil then
        return
    end

    HT.Dexterity.enableTracers = value and true or false
    HT:setSetting("enable_tracers", HT.Dexterity.enableTracers)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_tracers", HT.Dexterity.enableTracers)

    local effect = Idstring(HT.Dexterity.enableTracers and "effects/particles/weapons/sniper_trail" or "effects/particles/weapons/weapon_trail")

    -- Update already-spawned weapons; newly created weapons are handled by
    -- the raycastweaponbase post-hook.
    pcall(function()
        local player = managers.player and managers.player:local_player()
        if not (player and alive(player)) then
            return
        end
        local inventory = player:inventory()
        if not inventory then
            return
        end
        for _, selection_data in pairs(inventory:available_selections() or {}) do
            local base = alive(selection_data.unit) and selection_data.unit:base() or nil
            if base and base._trail_effect_table then
                base._trail_effect_table.effect = effect
            end
        end
    end)

    if HT.Dexterity.enableTracers then
        HT:addAlert("Tracers enabled", HT.colors.success, false)
    else
        HT:addAlert("Tracers disabled", HT.colors.success, false)
    end
end

local function customFovHandler(cam, t, dt)
    if not HT.Dexterity.enableCustomFov then return end
    local alive_ok = inHeistAndAlive()
    if not alive_ok then return end

    local player = managers.player:player_unit()

    local state = player:movement():current_state()
    if state and state.in_steelsight and state:in_steelsight() then return end

    local fov = tonumber(HT.Dexterity.customFov) or 75
    pcall(function()
        if cam._camera_unit and cam._camera_unit:base() and cam._camera_unit:base().set_fov then
            cam._camera_unit:base():set_fov(fov)
        elseif cam.set_fov then
            cam:set_fov(fov)
        end
    end)
end

function HT.Dexterity:setCustomFov(value, --[[optional]]showAlert)
    HT.Dexterity.enableCustomFov = value and true or false
    HT:setSetting("enable_custom_fov", HT.Dexterity.enableCustomFov)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_custom_fov", HT.Dexterity.enableCustomFov)
    if not HT.Dexterity.fovHooked then
        HT.Dexterity.fovHooked = true
        HT.Dexterity:addCameraHook(customFovHandler)
    end

    if showAlert == false then return end

    if HT.Dexterity.enableCustomFov then
        HT:addAlert("ut_alert_custom_fov_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_custom_fov_disabled", HT.colors.success)
    end
end

function HT.Dexterity:setFovValue(value)
    local fov = tonumber(value)
    if not fov then return end
    if fov < 50 then fov = 50 end
    if fov > 130 then fov = 130 end
    HT.Dexterity.customFov = fov
    HT:setSetting("custom_fov", fov)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_set_fov", fov)
end

function HT.Dexterity:setJumpMultiplier(value)
    local mult = tonumber(value)
    if not mult then return end
    if mult < 1 then mult = 1 end
    if mult > 10 then mult = 10 end

    HT.Dexterity.jumpMultiplier = mult
    HT:setSetting("jump_multiplier", mult)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_set_jump_multiplier", mult)

    pcall(function()
        if type(tweak_data) ~= "table" or not tweak_data.player or not tweak_data.player.movement then
            return
        end
        local jumpVelocity = tweak_data.player.movement.jump_velocity
        if not jumpVelocity then return end
        if not HT.Dexterity.tweakJumpVelocityBackup then
            HT.Dexterity.tweakJumpVelocityBackup = deepCopyTree(jumpVelocity)
        end
        scaleTree(jumpVelocity, HT.Dexterity.tweakJumpVelocityBackup, mult)
    end)
end

function HT.Dexterity:resetJumpMultiplier()
    HT.Dexterity.jumpMultiplier = 1
    pcall(function()
        if type(tweak_data) ~= "table" or not tweak_data.player or not tweak_data.player.movement then
            return
        end
        local jumpVelocity = tweak_data.player.movement.jump_velocity
        if jumpVelocity and HT.Dexterity.tweakJumpVelocityBackup then
            scaleTree(jumpVelocity, HT.Dexterity.tweakJumpVelocityBackup, 1)
        end
    end)
end

function HT.Dexterity:setOneShotKill(value)
    HT:setSetting("enable_one_shot_kill", value)
    HT:updateJsonValue("dexterity", "ut_item_dexterity_toggle_one_shot_kill", value)
    _G.CloneClass(CopDamage)
    if value then
        function CopDamage:damage_bullet(attack_data)
            if attack_data and attack_data.attacker_unit == managers.player:player_unit() then
                attack_data.damage = 1000000
            end
            return CopDamage.orig.damage_bullet(self, attack_data)
        end
        function CopDamage:damage_melee(attack_data)
            if attack_data and attack_data.attacker_unit == managers.player:player_unit() then
                attack_data.damage = 1000000
            end
            return CopDamage.orig.damage_melee(self, attack_data)
        end
    else
        CopDamage.damage_bullet = CopDamage.orig.damage_bullet
        CopDamage.damage_melee = CopDamage.orig.damage_melee
    end
    if value then
        HT:addAlert("One Shot Kill enabled", HT.colors.success, false)
    else
        HT:addAlert("One Shot Kill disabled", HT.colors.success, false)
    end
end
