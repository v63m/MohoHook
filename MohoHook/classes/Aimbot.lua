HT.Aimbot = {}

HT.Aimbot.enabled = false
HT.Aimbot.currentTarget = nil
HT.Aimbot._hooked = false

HT.Aimbot.settings = {
    fov = 30,
    smoothness = 5,
    bone = "head",
    only_when_aiming = true,
    visibility_check = true,
    target_civilians = false,
}

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function shortest_yaw_delta(from, to)
    local d = to - from
    while d > 180  do d = d - 360 end
    while d < -180 do d = d + 360 end
    return d
end

local function is_valid_enemy_target(unit)
    if not alive(unit) then return false end
    local dmg = unit:character_damage()
    if not dmg or dmg:dead() then return false end
    local brain = unit:brain()
    if brain and brain._attention_handler and brain._attention_handler._team then
        local team_id = brain._attention_handler._team.id
        if team_id == "neutral1" or team_id == "criminal1" then
            return false
        end
    end
    return true
end

function HT.Aimbot:findTarget(cam_pos, cam_fwd)
    local fov_cos = math.cos(math.rad(HT.Aimbot.settings.fov))
    local best_unit = nil
    local best_dot = fov_cos

    local function consider(unit)
        if not is_valid_enemy_target(unit) then return end

        local bone_pos
        pcall(function()
            if HT.Aimbot.settings.bone == "head" then
                bone_pos = unit:movement():m_head_pos()
            else
                bone_pos = unit:movement():m_pos()
                if bone_pos then bone_pos = bone_pos + Vector3(0, 0, 100) end
            end
        end)
        if not bone_pos then return end

        local to_tgt = bone_pos - cam_pos
        local len = to_tgt:length()
        if len < 1 then return end
        local dir = to_tgt:normalized()
        local dot = cam_fwd:dot(dir)
        if dot <= best_dot then return end

        if HT.Aimbot.settings.visibility_check then
            local slot_mask = managers.slot:get_mask("bullet_impact_targets")
            local ray = World:raycast("ray", cam_pos, bone_pos, "slot_mask", slot_mask)
            if ray and ray.unit and ray.unit ~= unit then
                return
            end
        end

        best_dot = dot
        best_unit = unit
    end

    if managers.enemy then
        for _, data in pairs(managers.enemy:all_enemies()) do
            consider(data.unit)
        end
        if HT.Aimbot.settings.target_civilians then
            for _, data in pairs(managers.enemy:all_civilians()) do
                consider(data.unit)
            end
        end
    end

    return best_unit
end

-- Registers a per-frame handler on the shared PlayerCamera:update hook so
-- aimbot rotation is applied AFTER natural mouse-look processing. This
-- prevents the game from overwriting our rotation, which was the core reason
-- the previous persist-script approach didn't work.
function HT.Aimbot:installHook()
    if HT.Aimbot._hooked then return end
    HT.Aimbot._hooked = true
    HT.Dexterity:addCameraHook(function(cam, t, dt)
        if not HT.Aimbot.enabled then
            HT.Aimbot.currentTarget = nil
            return
        end
        if not HT:isInGame() or not HT:isInHeist() then return end

        local player = managers.player:player_unit()
        if not alive(player) then return end

        local state = player:movement():current_state()
        if not state then return end

        local state_name = state._name or ""
        if state_name == "bleed_out" or state_name == "fatal"
        or state_name == "arrested" or state_name == "incapacitated"
        or state_name == "tased" or state_name == "carry" then
            HT.Aimbot.currentTarget = nil
            return
        end
        if state._interact_expire_t or state._interacting == true then return end

        if HT.Aimbot.settings.only_when_aiming then
            local in_ads = false
            pcall(function() in_ads = state:in_steelsight() end)
            if not in_ads then
                HT.Aimbot.currentTarget = nil
                return
            end
        end

        local cam_pos = cam:position()
        local cam_fwd = cam:forward()

        local target = HT.Aimbot:findTarget(cam_pos, cam_fwd)
        HT.Aimbot.currentTarget = target
        if not target then return end

        local bone_pos
        pcall(function()
            if HT.Aimbot.settings.bone == "head" then
                bone_pos = target:movement():m_head_pos()
            else
                bone_pos = target:movement():m_pos() + Vector3(0, 0, 100)
            end
        end)
        if not bone_pos then return end

        local look_dir = bone_pos - cam_pos
        if look_dir:length() < 1 then return end

        local desired_rot = Rotation:look_at(look_dir, math.UP)
        local current_rot = cam:rotation()

        local smoothness = clamp(HT.Aimbot.settings.smoothness or 5, 1, 10)
        local lerp_t = clamp(dt * (11 - smoothness) * 4, 0, 1)

        local new_yaw   = current_rot:yaw()   + shortest_yaw_delta(current_rot:yaw(),   desired_rot:yaw())   * lerp_t
        local new_pitch = current_rot:pitch() + (desired_rot:pitch() - current_rot:pitch()) * lerp_t
        new_pitch = clamp(new_pitch, -85, 85)

        pcall(function()
            cam:set_rotation(Rotation(new_yaw, new_pitch, 0))
        end)
    end)
end

function HT.Aimbot:setEnabled(value, --[[optional]]showAlert)
    HT.Aimbot.enabled = value
    HT:setSetting("enable_aimbot", value)
    HT.Aimbot:installHook()
    if showAlert == false then return end
    if value then
        HT:addAlert("Aimbot enabled", HT.colors.success)
    else
        HT:addAlert("Aimbot disabled", HT.colors.success)
    end
end

function HT.Aimbot:toggle()
    HT.Aimbot:setEnabled(not HT.Aimbot.enabled)
end

function HT.Aimbot:setFov(value)
    HT.Aimbot.settings.fov = clamp(tonumber(value) or 30, 1, 180)
    HT:setSetting("aimbot_fov", HT.Aimbot.settings.fov)
end

function HT.Aimbot:setSmoothness(value)
    HT.Aimbot.settings.smoothness = clamp(tonumber(value) or 5, 1, 10)
    HT:setSetting("aimbot_smoothness", HT.Aimbot.settings.smoothness)
end

function HT.Aimbot:setBone(bone)
    if bone ~= "head" and bone ~= "chest" then bone = "head" end
    HT.Aimbot.settings.bone = bone
    HT:setSetting("aimbot_bone", bone)
end

function HT.Aimbot:setOnlyWhenAiming(value)
    HT.Aimbot.settings.only_when_aiming = value and true or false
    HT:setSetting("aimbot_only_when_aiming", HT.Aimbot.settings.only_when_aiming)
end

function HT.Aimbot:setVisibilityCheck(value)
    HT.Aimbot.settings.visibility_check = value and true or false
    HT:setSetting("aimbot_visibility_check", HT.Aimbot.settings.visibility_check)
end

function HT.Aimbot:loadSettings()
    local fov        = HT:getSetting("aimbot_fov")
    local smoothness = HT:getSetting("aimbot_smoothness")
    local bone       = HT:getSetting("aimbot_bone")
    local only_ads   = HT:getSetting("aimbot_only_when_aiming")
    local vis_check  = HT:getSetting("aimbot_visibility_check")

    if fov        then HT.Aimbot.settings.fov        = clamp(tonumber(fov) or 30, 1, 180) end
    if smoothness then HT.Aimbot.settings.smoothness = clamp(tonumber(smoothness) or 5, 1, 10) end
    if bone == "head" or bone == "chest" then HT.Aimbot.settings.bone = bone end
    if only_ads ~= nil then HT.Aimbot.settings.only_when_aiming = only_ads and true or false end
    if vis_check ~= nil then HT.Aimbot.settings.visibility_check = vis_check and true or false end

    if HT:getSetting("enable_aimbot") then
        HT.Aimbot.enabled = true
        HT.Aimbot:installHook()
    end
end
