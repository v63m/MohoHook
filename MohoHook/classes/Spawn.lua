HT.Spawn = {}

HT.Spawn.index = nil
HT.Spawn.mode = nil
HT.Spawn.available = {}
HT.Spawn.position = "crosshair"

function HT.Spawn:setMode(mode)
    HT.Spawn.index = 1
    HT.Spawn.mode = mode
end

function HT.Spawn:setModeEnemies()
    HT.Spawn:setMode("enemies")
end

function HT.Spawn:setModeAllies()
    HT:enableUnlimitedConversions()
    HT.Spawn:setMode("allies")
end

function HT.Spawn:setModeCivilians()
    HT.Spawn.available.civilians = {}
    for key, value in pairs(HT.Tables.civilians) do
        if HT:isUnitLoaded(Idstring(value)) then
            table.insert(HT.Spawn.available.civilians, value)
        end
    end
    if HT.Utils:isTableEmpty(HT.Spawn.available.civilians) then
        HT:addAlert("ut_alert_no_civilians_available_here", HT.colors.danger)
        return
    end
    HT.Spawn:setMode("civilians")
end

function HT.Spawn:setModeLoots()
    HT.Spawn.available.loots = {}
    for key, value in pairs(HT.Tables.loots) do
        if HT:isUnitLoaded(Idstring(value)) then
            table.insert(HT.Spawn.available.loots, value)
        end
    end
    if HT.Utils:isTableEmpty(HT.Spawn.available.loots) then
        HT:addAlert("ut_alert_no_loots_available_here", HT.colors.danger)
        return
    end
    HT.Spawn:setMode("loots")
end

function HT.Spawn:setModeEquipments()
    HT.Spawn.available.equipments = {}
    for key, value in pairs(HT.Tables.equipments) do
        table.insert(HT.Spawn.available.equipments, value)
    end
    HT.Spawn:setMode("equipments")
end

function HT.Spawn:setModePackages()
    HT.Spawn.available.packages = {}
    for key, value in pairs(HT.Tables.packages) do
        table.insert(HT.Spawn.available.packages, value)
    end
    function tweak_data.gage_assignment:get_num_assignment_units()
        return HT.fakeMaxInteger
    end
    HT.Spawn:setMode("packages")
end

function HT.Spawn:setModeBags()
    HT.Spawn:setMode("bags")
end

function HT.Spawn:setModeExplosives()
    HT.Spawn:setMode("explosives")
end

function HT.Spawn:spawnEnemy(id)
    local position = HT.Spawn:getPosition()
    if not position then
        return
    end
    local rotation = HT:getPlayerCameraRotationFlat()
    local unit = HT:spawnUnit(Idstring(id), position, rotation)
    if not unit then
        return
    end
    HT:setUnitTeam(unit, "combatant")
end

function HT.Spawn:spawnAlly(id)
    local position = HT.Spawn:getPosition()
    if not position then
        return
    end
    local rotation = HT:getPlayerCameraRotationFlat()
    local unit = HT:spawnUnit(Idstring(id), position, rotation)
    if not unit then
        return
    end
    HT:setUnitTeam(unit, "combatant")
    HT.Spawn:convertEnemy(unit)
end

function HT.Spawn:spawnCivilian(id)
    local position = HT.Spawn:getPosition()
    if not position then
        return
    end
    local rotation = HT:getPlayerCameraRotationFlat()
    local unit = HT:spawnUnit(Idstring(id), position, rotation)
    if not unit then
        return
    end
    HT:setUnitTeam(unit, "non_combatant")
    unit:brain():action_request({
        type = "act",
        variant = "cm_sp_stand_idle"
    })
end

function HT.Spawn:spawnLoot(name)
    local position = HT.Spawn:getPosition()
    if not position then
        return
    end
    local rotation = HT:getPlayerCameraRotationFlat()
    HT:spawnUnit(Idstring(name), position, rotation)
end

function HT.Spawn:spawnEquipment(name)
    local position = HT.Spawn:getPosition()
    if not position then
        return
    end
    local rotation = HT:getPlayerCameraRotationFlat()
    if name == "ammo_bag" then
        AmmoBagBase.spawn(position, rotation, 1)
    elseif name == "doctor_bag" then
        DoctorBagBase.spawn(position, rotation, 4)
    elseif name == "first_aid_kit" then
        FirstAidKitBase.spawn(position, rotation, 1)
    elseif name == "body_bags_bag" then
        BodyBagsBagBase.spawn(position, rotation)
    elseif name == "grenade_crate" then
        GrenadeCrateBase.spawn(position, rotation)
    elseif name == "trip_mine" then
        if HT.Spawn.position == "crosshair" then
            local crosshairRay = HT:getCrosshairRay()
            if not crosshairRay then
                return
            end
            rotation = Rotation(crosshairRay.normal, math.UP)
        elseif HT.Spawn.position == "self" then
            rotation = Rotation(HT:getPlayerCameraRotation():yaw(), 90, 0)
        end
        local unit = TripMineBase.spawn(position, rotation, true)
        if not unit then
            return
        end
        local playerUnit = managers.player:player_unit()
        unit:base():set_active(true, playerUnit)
    elseif name == "sentry_gun" then
        HT.Spawn:setEquipment("sentry_gun")
        local playerUnit = managers.player:player_unit()
        local unit = SentryGunBase.spawn(playerUnit, position, rotation)
        if not unit then
            return
        end
        unit:base():post_setup(1)
        managers.network:session():send_to_peers_synched("from_server_sentry_gun_place_result", 1, 0, unit, 2, 2, true,
            2)
    end
end

function HT.Spawn:spawnPackage(id)
    local position = HT.Spawn:getPosition()
    if not position then
        return
    end
    local rotation = HT:getPlayerCameraRotationFlat()
    HT:spawnUnit(Idstring(id), position, rotation)
end

function HT.Spawn:spawnBag(name)
    local position = HT:getPlayerCameraPosition()
    local rotation = HT:getPlayerCameraRotation()
    local forward = HT:getPlayerCameraForward()
    
    if name == "piggy" then
        HT:spawnUnit(Idstring("units/pd2_dlc_pda9/props/pda9_pickup_feed_bag/pda9_pickup_feed_bag"), position, rotation)
        return
    end

    managers.player:server_drop_carry(name, managers.money:get_bag_value(name), true, true, 1, position, rotation, forward, 100, nil, nil)
end

function HT.Spawn:spawnExplosive(id)
    local position = HT.Spawn:getPosition()
    if not position then
        return
    end
    local rotation = HT:getPlayerCameraRotationFlat()
    HT:spawnUnit(Idstring(id), position, rotation)
end

function HT.Spawn:removeNpcs()
    local units = {}
    for key, value in pairs(managers.enemy:all_civilians()) do
        table.insert(units, value.unit)
    end
    for key, value in pairs(managers.enemy:all_enemies()) do
        local brain = value.unit:brain()
        local team_id = brain and brain._attention_handler and brain._attention_handler._team and brain._attention_handler._team.id
        if team_id ~= "neutral1" then
            table.insert(units, value.unit)
        end
    end
    HT:removeUnits(units)
    HT:addAlert("ut_alert_removed_npcs", HT.colors.info)
end

function HT.Spawn:removeLoots()
    local units = {}
    for key, unit in pairs(managers.interaction._interactive_units) do
        if not alive(unit) then
            goto continue
        end
        if not HT.Tables.loots[unit:name():key()] then
            goto continue
        end
        table.insert(units, unit)
        ::continue::
    end
    HT:removeUnits(units)
    HT:addAlert("ut_alert_removed_loots", HT.colors.info)
end

function HT.Spawn:removeEquipments()
    local units = {}
    for key, unit in pairs(World:find_units_quick("all")) do
        if not alive(unit) then
            goto continue
        end
        if not HT.Tables.equipments[unit:name():key()] then
            goto continue
        end
        table.insert(units, unit)
        ::continue::
    end
    HT:removeUnits(units)
    HT:addAlert("ut_alert_removed_equipments", HT.colors.info)
end

function HT.Spawn:removePackages()
    local units = {}
    for key, unit in pairs(managers.interaction._interactive_units) do
        if not alive(unit) then
            goto continue
        end
        if not HT.Tables.packages[unit:name():key()] then
            goto continue
        end
        table.insert(units, unit)
        ::continue::
    end
    HT:removeUnits(units)
    HT:addAlert("ut_alert_removed_packages", HT.colors.info)
end

function HT.Spawn:removeBags()
    local units = {}
    for key, unit in pairs(managers.interaction._interactive_units) do
        if not alive(unit) then
            goto continue
        end
        if not HT.Tables.bagsKeys[unit:name():key()] then
            goto continue
        end
        table.insert(units, unit)
        ::continue::
    end
    HT:removeUnits(units)
    HT:addAlert("ut_alert_removed_bags", HT.colors.info)
end

function HT.Spawn:disposeCorpses()
    managers.enemy:dispose_all_corpses()
    HT:addAlert("ut_alert_corpses_disposed", HT.colors.info)
end

function HT.Spawn:getPosition()
    if HT.Spawn.position == "crosshair" then
        local crosshairRay = HT:getCrosshairRay()
        if not crosshairRay then
            HT:addAlert("ut_alert_cannot_spawn", HT.colors.warning)
            return
        end
        return crosshairRay.position
    elseif HT.Spawn.position == "self" then
        return HT:getPlayerPosition()
    end
end

function HT.Spawn:setPosition(position)
    HT.Spawn.position = position
end

function HT.Spawn:convertEnemy(unit)
    if not alive(unit) then
        return
    end
    managers.groupai:state():convert_hostage_to_criminal(unit)
    managers.groupai:state():sync_converted_enemy(unit)
    unit:contour():add("friendly", true)
end

function HT.Spawn:setEquipment(equipment)
    managers.player:clear_equipment()
    managers.player._equipment.selections = {}
    managers.player:add_equipment({
        equipment = equipment
    })
end

function HT.Spawn:previous()
    if HT.Spawn.mode == "enemies" then
        if HT.Spawn.index == 1 then HT.Spawn.index = HT.Utils:countTable(HT.Tables.enemies)
        else HT.Spawn.index = HT.Spawn.index - 1 end
        HT:showSubtitle(HT.Utils:getPathBaseName(HT.Tables.enemies[HT.Spawn.index]), HT.colors.white)
    elseif HT.Spawn.mode == "allies" then
        if HT.Spawn.index == 1 then HT.Spawn.index = HT.Utils:countTable(HT.Tables.enemies)
        else HT.Spawn.index = HT.Spawn.index - 1 end
        HT:showSubtitle(HT.Utils:getPathBaseName(HT.Tables.enemies[HT.Spawn.index]), HT.colors.white)
    elseif HT.Spawn.mode == "civilians" then
        if HT.Spawn.index == 1 then HT.Spawn.index = HT.Utils:countTable(HT.Spawn.available.civilians)
        else HT.Spawn.index = HT.Spawn.index - 1 end
        HT:showSubtitle(HT.Utils:getPathBaseName(HT.Spawn.available.civilians[HT.Spawn.index]), HT.colors.white)
    elseif HT.Spawn.mode == "loots" then
        if HT.Spawn.index == 1 then HT.Spawn.index = HT.Utils:countTable(HT.Spawn.available.loots)
        else HT.Spawn.index = HT.Spawn.index - 1 end
        HT:showSubtitle(HT.Utils:getPathBaseName(HT.Spawn.available.loots[HT.Spawn.index]), HT.colors.white)
    elseif HT.Spawn.mode == "equipments" then
        if HT.Spawn.index == 1 then HT.Spawn.index = HT.Utils:countTable(HT.Spawn.available.equipments)
        else HT.Spawn.index = HT.Spawn.index - 1 end
        HT:showSubtitle(HT.Spawn.available.equipments[HT.Spawn.index], HT.colors.white)
    elseif HT.Spawn.mode == "packages" then
        if HT.Spawn.index == 1 then HT.Spawn.index = HT.Utils:countTable(HT.Spawn.available.packages)
        else HT.Spawn.index = HT.Spawn.index - 1 end
        HT:showSubtitle(HT.Utils:getPathBaseName(HT.Spawn.available.packages[HT.Spawn.index]), HT.colors.white)
    elseif HT.Spawn.mode == "bags" then
        if HT.Spawn.index == 1 then HT.Spawn.index = HT.Utils:countTable(HT.Tables.bags)
        else HT.Spawn.index = HT.Spawn.index - 1 end
        HT:showSubtitle(HT.Tables.bags[HT.Spawn.index], HT.colors.white)
    elseif HT.Spawn.mode == "explosives" then
        if HT.Spawn.index == 1 then HT.Spawn.index = HT.Utils:countTable(HT.Tables.explosives)
        else HT.Spawn.index = HT.Spawn.index - 1 end
        HT:showSubtitle(HT.Utils:getPathBaseName(HT.Tables.explosives[HT.Spawn.index]), HT.colors.white)
    else
        HT:addAlert("ut_alert_no_mode_selected", HT.colors.warning)
    end
end

function HT.Spawn:next()
    if HT.Spawn.mode == "enemies" then
        if HT.Spawn.index == HT.Utils:countTable(HT.Tables.enemies) then HT.Spawn.index = 1
        else HT.Spawn.index = HT.Spawn.index + 1 end
        HT:showSubtitle(HT.Utils:getPathBaseName(HT.Tables.enemies[HT.Spawn.index]), HT.colors.white)
    elseif HT.Spawn.mode == "allies" then
        if HT.Spawn.index == HT.Utils:countTable(HT.Tables.enemies) then HT.Spawn.index = 1
        else HT.Spawn.index = HT.Spawn.index + 1 end
        HT:showSubtitle(HT.Utils:getPathBaseName(HT.Tables.enemies[HT.Spawn.index]), HT.colors.white)
    elseif HT.Spawn.mode == "civilians" then
        if HT.Spawn.index == HT.Utils:countTable(HT.Spawn.available.civilians) then HT.Spawn.index = 1
        else HT.Spawn.index = HT.Spawn.index + 1 end
        HT:showSubtitle(HT.Utils:getPathBaseName(HT.Spawn.available.civilians[HT.Spawn.index]), HT.colors.white)
    elseif HT.Spawn.mode == "loots" then
        if HT.Spawn.index == HT.Utils:countTable(HT.Spawn.available.loots) then HT.Spawn.index = 1
        else HT.Spawn.index = HT.Spawn.index + 1 end
        HT:showSubtitle(HT.Utils:getPathBaseName(HT.Spawn.available.loots[HT.Spawn.index]), HT.colors.white)
    elseif HT.Spawn.mode == "equipments" then
        if HT.Spawn.index == HT.Utils:countTable(HT.Spawn.available.equipments) then HT.Spawn.index = 1
        else HT.Spawn.index = HT.Spawn.index + 1 end
        HT:showSubtitle(HT.Spawn.available.equipments[HT.Spawn.index], HT.colors.white)
    elseif HT.Spawn.mode == "packages" then
        if HT.Spawn.index == HT.Utils:countTable(HT.Spawn.available.packages) then HT.Spawn.index = 1
        else HT.Spawn.index = HT.Spawn.index + 1 end
        HT:showSubtitle(HT.Utils:getPathBaseName(HT.Spawn.available.packages[HT.Spawn.index]), HT.colors.white)
    elseif HT.Spawn.mode == "bags" then
        if HT.Spawn.index == HT.Utils:countTable(HT.Tables.bags) then HT.Spawn.index = 1
        else HT.Spawn.index = HT.Spawn.index + 1 end
        HT:showSubtitle(HT.Tables.bags[HT.Spawn.index], HT.colors.white)
    elseif HT.Spawn.mode == "explosives" then
        if HT.Spawn.index == HT.Utils:countTable(HT.Tables.explosives) then HT.Spawn.index = 1
        else HT.Spawn.index = HT.Spawn.index + 1 end
        HT:showSubtitle(HT.Utils:getPathBaseName(HT.Tables.explosives[HT.Spawn.index]), HT.colors.white)
    else
        HT:addAlert("ut_alert_no_mode_selected", HT.colors.warning)
    end
end

function HT.Spawn:place()
    if HT.Spawn.mode == "enemies" then
        HT.Spawn:spawnEnemy(HT.Tables.enemies[HT.Spawn.index])
    elseif HT.Spawn.mode == "allies" then
        HT.Spawn:spawnAlly(HT.Tables.enemies[HT.Spawn.index])
    elseif HT.Spawn.mode == "civilians" then
        HT.Spawn:spawnCivilian(HT.Spawn.available.civilians[HT.Spawn.index])
    elseif HT.Spawn.mode == "loots" then
        HT.Spawn:spawnLoot(HT.Spawn.available.loots[HT.Spawn.index])
    elseif HT.Spawn.mode == "equipments" then
        HT.Spawn:spawnEquipment(HT.Spawn.available.equipments[HT.Spawn.index])
    elseif HT.Spawn.mode == "packages" then
        HT.Spawn:spawnPackage(HT.Spawn.available.packages[HT.Spawn.index])
    elseif HT.Spawn.mode == "bags" then
        HT.Spawn:spawnBag(HT.Tables.bags[HT.Spawn.index])
    elseif HT.Spawn.mode == "explosives" then
        HT.Spawn:spawnExplosive(HT.Tables.explosives[HT.Spawn.index])
    else
        HT:addAlert("ut_alert_no_mode_selected", HT.colors.warning)
    end
end
