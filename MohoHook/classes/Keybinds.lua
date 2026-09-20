HT.Keybinds = {}

function HT.Keybinds:teleport()
    local crosshairRay = HT:getCrosshairRay()

    if not crosshairRay then
        return
    end

    local offset = Vector3()
    mvector3.set(offset, HT:getPlayerCameraForward())
    mvector3.multiply(offset, 100)
    mvector3.add(crosshairRay.hit_position, offset)
    HT:teleportPlayer(crosshairRay.hit_position, HT:getPlayerCameraRotation())
end

function HT.Keybinds:replenish()
    local playerUnit = managers.player:player_unit()

    if not alive(playerUnit) then
        return
    end

    managers.player:add_body_bags_amount(99)
    managers.player:add_special({ name = "cable_tie", amount = 99 })
    managers.player:set_player_state("standard")
    playerUnit:base():replenish()
end
