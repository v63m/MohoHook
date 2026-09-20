_G.CloneClass(MissionEndState)

local orig_at_enter = MissionEndState.at_enter
function MissionEndState:at_enter(...)
    if orig_at_enter then
        orig_at_enter(self, ...)
    end

    DelayedCalls:Add("ht_mission_end_unstick", 15, function()
        local current = game_state_machine:current_state()
        if not current then
            return
        end
        if current._completion_bonus_done == false then
            current._completion_bonus_done = true
            pcall(function()
                if current.set_continue_button_text then
                    current:set_continue_button_text()
                end
            end)
        end
    end)
end

local orig_at_exit = MissionEndState.at_exit
function MissionEndState:at_exit(...)
    pcall(function()
        if HT and HT.Reset and HT.Reset.all then
            HT.Reset:all(true)
        end
    end)

    if orig_at_exit then
        return orig_at_exit(self, ...)
    end
end

