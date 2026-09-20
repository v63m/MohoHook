HT.Instant = {}

function HT.Instant:startHeist()
    managers.network:session():spawn_players()
end

function HT.Instant:restartHeist()
    managers.game_play_central:restart_the_game()
end

function HT.Instant:finishHeist()
    local amountOfAlivePlayers = managers.network:session():amount_of_alive_players()

    pcall(function()
        managers.network:session():send_to_peers("mission_ended", true, amountOfAlivePlayers)
    end)

    game_state_machine:change_state_by_name("victoryscreen", {
        num_winners = amountOfAlivePlayers,
        personal_win = true
    })

    DelayedCalls:Add("ht_fix_victory_screen", 0.5, function()
        local state = game_state_machine:current_state()
        if state and state._completion_bonus_done == false then
            state._completion_bonus_done = true
            pcall(function() state:set_continue_button_text() end)
        end
    end)
end

function HT.Instant:leaveHeist()
    MenuCallbackHandler:_dialog_end_game_yes()
end
