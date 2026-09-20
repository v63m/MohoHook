HT.Construction = {}

HT.Construction.pickedUnit = nil
HT.Construction.spawnedUnits = {}
HT.Construction.crosshairMarker = {}

function HT.Construction:pick()
    local crosshairRay = HT:getCrosshairRay()

    if not crosshairRay or not crosshairRay.unit then
        HT:addAlert("ut_alert_nothing_to_pick", HT.colors.warning)
        return
    end

    HT:playSound("box_tick")
    HT:showHitMarker()

    local unit = crosshairRay.unit

    if unit:base() then
        HT:addAlert("ut_alert_cannot_pick_this_unit", HT.colors.danger)
        return
    end

    HT.Construction.pickedUnit = unit
end

function HT.Construction:spawn()
    if not HT.Construction.pickedUnit then
        HT:addAlert("ut_alert_no_unit_picked", HT.colors.warning)
        return
    end

    local crosshairRay = HT:getCrosshairRay()

    if not crosshairRay then
        HT:addAlert("ut_alert_cannot_spawn_unit", HT.colors.warning)
        return
    end

    local position = crosshairRay.position
    local rotation = HT:getPlayerCameraRotationFlat()

    local unitName = HT.Construction.pickedUnit:name()
    local unit = HT:spawnUnit(unitName, position, rotation)

    if not unit then
        HT:addAlert("ut_alert_spawn_unit_failure", HT.colors.danger)
        return
    end

    HT.Construction.spawnedUnits[HT.Utils:toString(unit)] = unit

    HT:playSound("zoom_in")
    HT:showHitMarker()
end

function HT.Construction:delete()
    local crosshairRay = HT:getCrosshairRay()

    if not crosshairRay or not crosshairRay.unit then
        HT:addAlert("ut_alert_nothing_to_delete", HT.colors.warning)
        return
    end

    local unit = crosshairRay.unit
    local unitTableKey = HT.Utils:toString(unit)

    if not HT.Construction.spawnedUnits[unitTableKey] then
        HT:addAlert("ut_alert_nothing_to_delete", HT.colors.warning)
        return
    end

    HT.Construction.spawnedUnits[unitTableKey] = nil
    HT:removeUnit(unit)

    HT:playSound("zoom_out")
    HT:showHitMarker()
end

function HT.Construction:drawPickedUnit()
    local unit = HT.Construction.pickedUnit

    if not alive(unit) then
        return
    end

    if unit:network_sync() == "spawn" then
        Application:draw(unit, 0, 1, 0)
    else
        Application:draw(unit, 1, 0.5, 0)
    end
end

function HT.Construction:clear()
    for key, unit in pairs(HT.Construction.spawnedUnits) do
        HT:removeUnit(unit)
        HT.Construction.spawnedUnits[key] = nil
    end
    HT:addAlert("ut_alert_construction_cleared", HT.colors.success)
end

function HT.Construction:setCrosshairMarker(value)
    if not HT.Construction.crosshairMarker.workspace then
        local options = {visible = true, color = HT.colors.white:with_alpha(0.5), w = 7, h = 7}
        HT.Construction.crosshairMarker.workspace = Overlay:newgui():create_screen_workspace():panel()
        HT.Construction.crosshairMarker.workspace:bitmap(options):set_center(HT.Construction.crosshairMarker.workspace:center())
    end
    if HT.Construction.crosshairMarker.enabled then
        HT.Construction.crosshairMarker.workspace:hide()
        HT.Construction.crosshairMarker.enabled = false
    else
        HT.Construction.crosshairMarker.workspace:show()
        HT.Construction.crosshairMarker.enabled = true
    end
end
