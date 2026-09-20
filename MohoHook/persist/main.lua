if HexStatus then
    HexStatus:update()
end
HT.debugLogClass:update()

if MohoWatermark then
    MohoWatermark:update()
end

if HT:isInGame() then
    if HT:isInHeist() then
        local isGodModeEnabled = HT:getSetting("enable_god_mode")
        if not HT.Dexterity.godModeReset and not isGodModeEnabled then
            if Global.god_mode then
                HT.Dexterity:resetGodMode()
            end
            HT.Dexterity.godModeReset = true
        end

        if HT.Mission.enableDisableAi then
            HT.Mission:disableAi()
        end

        if HT.Mission.enableFreezeCivilians then
            HT.Mission:freezeAllCivs()
        end

        if HT.Dexterity.enableNoclip then
            HT.Dexterity:setNoclip(HT.Dexterity.enableNoclip, true, false)
        end

        if not HT.Time.defaultEnvironment then
            HT.Time:setDefaultEnvironment()
        end

        if HT:getSetting("time_environment") then
            HT.Time:checkEnvironment()
        end

        if HT:isHost() then
            if HT.Construction.pickedUnit then
                HT.Construction:drawPickedUnit()
            end
        end
    end
end

if HT:getSetting("enable_anti_cheat_checker") then
    HT.AntiCheatChecker:check()
end

