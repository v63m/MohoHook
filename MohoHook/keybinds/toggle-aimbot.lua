HT.Aimbot:toggle()
pcall(function() HT:setMenuToggle("ut_item_aimbot_toggle_enabled", HT.Aimbot.enabled) end)
pcall(function() HT:updateJsonValue("aimbot", "ut_item_aimbot_toggle_enabled", HT.Aimbot.enabled) end)
