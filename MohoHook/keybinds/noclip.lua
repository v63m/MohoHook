if not HT:isInHeist() then return end
local val = not HT.Dexterity.enableNoclip
HT.Dexterity:setNoclip(val, false, true)
HT:setMenuToggle("ut_item_dexterity_toggle_noclip", val)
