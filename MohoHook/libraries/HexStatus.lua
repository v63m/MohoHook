HexStatus = {}
HexStatus._ws = nil
HexStatus._visible = true
HexStatus._lastState = ""

local STATUS_W = 200
local STATUS_X = 16
local STATUS_Y = 120

local tracked = {
    {label = "God Mode",         setting = "enable_god_mode"},
    {label = "Inf Stamina",      setting = "enable_infinite_stamina"},
    {label = "Unlimited Ammo",   setting = "enable_unlimited_ammo"},
    {label = "No Recoil",        setting = "enable_no_recoil"},
    {label = "No Spread",        setting = "enable_no_spread"},
    {label = "Shoot Walls",      setting = "enable_shoot_through_walls"},
    {label = "Instant Reload",   setting = "enable_instant_reload"},
    {label = "Unltd Equipment",  setting = "enable_unlimited_equipment"},
    {label = "No Fall Damage",   setting = "enable_no_fall_damage"},
    {label = "Noclip",           setting = nil, custom = function() return HT.Dexterity.enableNoclip end},
    {label = "Disable AI",       setting = nil, custom = function() return HT.Mission.enableDisableAi end},
    {label = "Invisible",        setting = nil, custom = function() return HT.Mission.enableInvisiblePlayer end},
    {label = "Prevent Alarm",    setting = "enable_prevent_alarm_triggering"},
    {label = "Unltd Pagers",     setting = "enable_unlimited_pagers"},
    {label = "X-Ray",            setting = "enable_xray"},
    {label = "Move Speed",       setting = "enable_move_speed_multiplier"},
    {label = "Fire Rate",        setting = "enable_fire_rate_multiplier"},
    {label = "Damage",           setting = "enable_damage_multiplier"},
    {label = "Run Any Bag",      setting = "enable_can_run_with_any_bag"},
    {label = "Inf Bags",         setting = "enable_infinite_bags"},
    {label = "Slow-Mo",          setting = "enable_slow_motion"},
    {label = "Inf Nades",        setting = "enable_unlimited_grenades"},
    {label = "Inf Armor",        setting = "enable_infinite_armor"},
    {label = "Boom",             setting = "enable_exploding_bullets"},
    {label = "No Civ $",         setting = "enable_no_civilian_penalty"},
    {label = "Rainbow",          setting = "rainbow_chat"},
    {label = "Full Auto",        setting = "enable_full_auto"},
    {label = "Tracers",          setting = "enable_tracers"},
    {label = "Custom FOV",       setting = "enable_custom_fov"},
    {label = "Aimbot",           setting = "enable_aimbot"},
    {label = "Spinbot",          custom = function() return HT.Dexterity.enableSpinbot end},
    {labelFn = function() return "Jump x" .. tostring(HT.Dexterity.jumpMultiplier or 1) end, custom = function() return (HT.Dexterity.jumpMultiplier or 1) > 1 end},
}

function HexStatus:toggleVisibility()
    self._visible = not self._visible
    if not self._visible then
        self:_destroy()
        self._lastState = ""
    end
    if self._visible then
        HT:addAlert("Status overlay: ON", HT.colors.success, false)
    else
        HT:addAlert("Status overlay: OFF", HT.colors.warning, false)
    end
end

function HexStatus:_getActiveList()
    local active = {}
    for _, t in ipairs(tracked) do
        local on = false
        if t.custom then
            local ok
            ok, on = pcall(t.custom)
            if not ok then on = false end
        elseif t.setting then
            on = HT:getSetting(t.setting) == true
        end
        if on then
            local okLabel, label = pcall(function()
                return t.labelFn and t.labelFn() or t.label
            end)
            table.insert(active, okLabel and label or "?")
        end
    end
    return active
end

function HexStatus:_stateString(list)
    return table.concat(list, ",")
end

function HexStatus:_destroy()
    if self._ws then
        managers.gui_data:destroy_workspace(self._ws)
        self._ws = nil
    end
end

function HexStatus:update()
    if not HT:isInHeist() or not self._visible then
        if self._ws then self:_destroy() end
        self._lastState = ""
        return
    end

    local active = self:_getActiveList()
    local state = self:_stateString(active)

    if state == self._lastState and self._ws then return end
    self._lastState = state

    self:_destroy()

    if #active == 0 then return end

    local line_h = 14
    local pad = 6
    local total_h = pad * 2 + #active * line_h + 16

    self._ws = managers.gui_data:create_fullscreen_workspace()
    local root = self._ws:panel()
    local p = root:panel({x=STATUS_X, y=STATUS_Y, w=STATUS_W, h=total_h, layer=10})

    p:rect({x=0, y=0, w=STATUS_W, h=total_h,
        color=Color(0.75, 0.04, 0.04, 0.10), layer=0,
        halign="left", valign="top"})

    p:text({text="ACTIVE CHEATS", x=pad, y=pad, w=STATUS_W - pad*2, h=14,
        color=Color(1, 0.40, 0.42, 0.95), font="fonts/font_medium_mf",
        font_size=11, layer=1, halign="left", valign="top"})

    for i, label in ipairs(active) do
        local ty = pad + 14 + (i-1) * line_h
        p:text({text="+ " .. label, x=pad, y=ty, w=STATUS_W - pad*2, h=line_h,
            color=Color(1, 0.75, 0.95, 0.65), font="fonts/font_medium_mf",
            font_size=10, layer=1, halign="left", valign="top"})
    end
end
