HT.Extras = {}

function HT.Extras:collectGagePackages()
    HT:addAlert("ut_menu_extras_item_1_alert", HT.colors.white)
    HT:InteractType({'gage_assignment'}, true)
end

function HT.Extras:boardWindows()
    HT:addAlert("ut_menu_extras_item_2_alert", HT.colors.white)
    HT:InteractType({'need_boards', 'stash_planks'}, true)
end

function HT.Extras:openDepositBoxes()
    HT:addAlert("ut_menu_extras_item_3_alert", HT.colors.white)
    local player = managers.player:player_unit()
    local depositboxes = {}
	for _,v in pairs(managers.interaction._interactive_units) do
		if v.interaction then
			local id = string.sub(v:interaction()._unit:name():t(), 1, 10)
			if id == "@ID7999172" -- Harvest Bank
			or id == "@IDe4bc870" or id == "@ID51da6d6" or id == "@ID8d8c766" or id == "@ID50aac55" or id == "@ID5dcd177" --Armoured Transport
			or id == "@IDa95e021" -- The Big Bank
			or id == "@IDe93c9b2" then -- GO Bank
				table.insert(depositboxes, v:interaction())
			end	
		end 
	end 	
	for _,v in pairs(depositboxes) do
		v:interact(player)
	end
end

function HT.Extras:tieCivilians()
    HT:addAlert("ut_menu_extras_item_4_alert", HT.colors.white)
	HT:InteractType({"requires_cable_ties", 'intimidate'}, true)
end

function HT.Extras:displayInvisibleWalls(value)
    HT:addAlert("ut_menu_extras_item_5_alert", HT.colors.white)
    for _, unit in pairs(World:find_units("all", 1)) do
        if HT.Tables.collisionData[unit:name():key()] then
            unit:set_visible(value and true or false)
        end
    end
end

function HT.Extras:lockupAI()
    HT:addAlert("ut_menu_extras_item_6_alert", HT.colors.white)
    for id, data in pairs(managers.criminals._characters) do
        local bot = data.data.ai
        local name = data.name
        local unit = data.unit
        if bot and alive(unit) then
            local crim_data = managers.criminals:character_data_by_name(name)
            if crim_data then
                managers.hud:set_mugshot_custody(crim_data.mugshot_id)
            end
            unit:set_slot(name, 0)
        end
    end
end

function HT.Extras:releaseAI()
    HT:addAlert("ut_menu_extras_item_7_alert", HT.colors.white)
    local spawn_on_unit = managers.player:player_unit()
    for id, data in pairs(managers.criminals._characters) do
        local bot = data.data.ai
        local name = data.name
        local unit = data.unit
        if bot and not alive(unit) then
            managers.trade:remove_from_trade(name)
            managers.groupai:state():spawn_one_teamAI(false, name, spawn_on_unit)
        end
    end
end

function HT.Extras:collectSmallLoot()
    HT:addAlert("ut_menu_extras_item_9_alert", HT.colors.white)
    -- Small loose loot interaction types. Unknown ids simply match nothing.
    HT:InteractType({
        "gold_pickup",
        "money_pickup",
        "cash_pickup",
        "diamond_pickup",
        "jewelry_pickup",
        "museum_coin_pickup",
        "coin_pickup",
        "necklace_pickup",
        "watch_pickup",
        "small_gem_pickup",
        "small_loot_pickup",
    }, true)
end

function HT.Extras:toggleCashPenalty(value)
    HT:addAlert("ut_menu_extras_item_8_alert", HT.colors.white)

    _G.CloneClass(MoneyManager)
    _G.CloneClass(UnitNetworkHandler)
    _G.CloneClass(StatisticsManager)

    if value then
	    function MoneyManager.civilian_killed() return false end
        function MoneyManager.get_civilian_deduction() return 0 end
	    function UnitNetworkHandler:sync_hostage_killed_warning(warning) return 0 end

        local old_killed = StatisticsManager.killed
        function StatisticsManager:killed(data) return (data.name == "civilian" or old_killed(self, data)) end
    else
        MoneyManager.get_civilian_deduction = MoneyManager.orig.get_civilian_deduction
        MoneyManager.civilian_killed = MoneyManager.orig.civilian_killed
        UnitNetworkHandler.sync_hostage_killed_warning = UnitNetworkHandler.orig.sync_hostage_killed_warning
        StatisticsManager.killed = StatisticsManager.orig.killed
    end
end
