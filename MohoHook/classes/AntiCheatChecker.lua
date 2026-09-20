HT.AntiCheatChecker = {}

HT.AntiCheatChecker.detectedText = nil

function HT.AntiCheatChecker:setEnabled(value)
    HT:setSetting("enable_anti_cheat_checker", value)
    if not value then
        if HT.AntiCheatChecker.detectedText then
            HT.AntiCheatChecker.detectedText:set_visible(false)
        end
    end
    if value then
        HT:addAlert("ut_alert_anti_cheat_checker_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_anti_cheat_checker_disabled", HT.colors.success)
    end
end

function HT.AntiCheatChecker:useAntiCheatDetectedFeatures()
    return HT:getSetting("enable_dlc_unlocker")
        or HT:getSetting("enable_skill_points_hack")
        or HT.Dexterity.enableUnlimitedEquipment
        or HT.Spawn.mode == "equipments"
        or HT.Spawn.mode == "bags"
end

function HT.AntiCheatChecker:check()
    if not HT.AntiCheatChecker.detectedText then
        local workspace = managers.gui_data:create_saferect_workspace()
        local config = {
            align = "center",
            font_size = 15,
            font = tweak_data.menu.pd2_medium_font,
            text = HT:getLocalizedText("ut_anti_cheat_detected"),
            color = HT.colors.warning,
            alpha = 0.8
        }
        HT.AntiCheatChecker.detectedText = workspace:panel():text(config)
    end

    local useAntiCheatDetectedFeatures = HT.AntiCheatChecker:useAntiCheatDetectedFeatures()
    HT.AntiCheatChecker.detectedText:set_visible(useAntiCheatDetectedFeatures)
end

function HT.AntiCheatChecker:showList()
    local title = HT:getLocalizedText("ut_popup_configuration_anti_cheat_checker_show_list_title")
    local message = ""
    if HT.AntiCheatChecker:useAntiCheatDetectedFeatures() then
        if HT:getSetting("enable_dlc_unlocker") then
            message = message .. "- DLC Unlocker\n"
        end
        if HT:getSetting("enable_skill_points_hack") then
            message = message .. "- Skill point hack\n"
        end
        if HT.Dexterity.enableUnlimitedEquipment then
            message = message .. "- Unlimited equipment\n"
        end
        if HT.Spawn.mode == "equipments" then
            message = message .. "- Spawn mode equipments\n"
        end
        if HT.Spawn.mode == "bags" then
            message = message .. "- Spawn mode bags\n"
        end
    else
        message = HT:getLocalizedText("ut_popup_configuration_anti_cheat_checker_show_list_no_detected_feature_message")
    end
    QuickMenu:new("$$$ moho hook $$$ - " .. title, message, {}):Show()
end
