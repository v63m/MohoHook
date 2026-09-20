HT.Unlocker = {}

function HT.Unlocker:setDlcUnlocker(value)
    HT:setSetting("enable_dlc_unlocker", value)
    if value then
        HT:addAlert("ut_alert_dlc_unlocker_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_dlc_unlocker_disabled", HT.colors.success)
    end
    HT:addAlert("ut_alert_restart_the_game_to_apply_changes", HT.colors.warning)
end

function HT.Unlocker:setSkinUnlocker(value)
    HT:setSetting("enable_skin_unlocker", value)
    if value then
        for skinName, skinData in pairs(tweak_data.blackmarket.weapon_skins) do
            if not managers.blackmarket:have_inventory_tradable_item("weapon_skins", skinName) and not skinData.is_a_color_skin then
                local instanceId = #managers.blackmarket._global.inventory_tradable + 1
                managers.blackmarket:tradable_add_item(instanceId, "weapon_skins", skinName, "mint", false, 1)
            end
        end
    else
        managers.blackmarket._global.inventory_tradable = {}
    end
    HT.Player:refreshAndSave()
    if value then
        HT:addAlert("ut_alert_skin_unlocker_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_skin_unlocker_disabled", HT.colors.success)
    end
    HT:addAlert("ut_alert_restart_the_game_to_apply_changes", HT.colors.warning)
end
