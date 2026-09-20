if not HT:isInHeist() then return end
local val = not (HT:getSetting("enable_god_mode") == true)
HT.Dexterity:setGodMode(val, true)
HT:setSetting("enable_god_mode", val)
HT:setMenuToggle("ut_item_dexterity_toggle_god_mode", val)
