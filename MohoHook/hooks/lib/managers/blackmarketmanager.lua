if HT:getSetting("enable_skin_unlocker") then
    local _ht_injecting = false
    local orig_tradable_update = BlackMarketManager.tradable_update
    function BlackMarketManager:tradable_update(...)
        if orig_tradable_update then
            orig_tradable_update(self, ...)
        end
        if _ht_injecting then return end
        _ht_injecting = true
        pcall(function()
            for skinName, skinData in pairs(tweak_data.blackmarket.weapon_skins) do
                if not self:have_inventory_tradable_item("weapon_skins", skinName) and not skinData.is_a_color_skin then
                    local instanceId = #self._global.inventory_tradable + 1
                    self:tradable_add_item(instanceId, "weapon_skins", skinName, "mint", false, 1)
                end
            end
        end)
        _ht_injecting = false
    end
end

if HT:getSetting("enable_dlc_unlocker") then
    function BlackMarketManager.has_unlocked_breech()
        return true, "bm_menu_locked_breech"
    end

    function BlackMarketManager.has_unlocked_ching()
        return true, "bm_menu_locked_ching"
    end

    function BlackMarketManager.has_unlocked_erma()
        return true, "bm_menu_locked_erma"
    end

    function BlackMarketManager.is_crew_item_unlocked()
        return true
    end
end
