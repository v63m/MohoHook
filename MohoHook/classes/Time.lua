HT.Time = {}

HT.Time.defaultEnvironment = nil

function HT.Time:getEnvironment()
    local ok, result = pcall(function()
        return managers.environment_controller._vp._env_handler._path
    end)
    if ok and result then return result end

    local ok2, result2 = pcall(function()
        return managers.viewport:first_active_viewport():get_environment_path()
    end)
    return (ok2 and result2) or nil
end

function HT.Time:setEnvironment(environment)
    pcall(function()
        managers.viewport:first_active_viewport():set_environment(environment)
    end)
end

function HT.Time:setEnvironmentSetting(environment)
    HT:setSetting("time_environment", environment)
    HT:addAlert("ut_alert_environment_set", HT.colors.success)
end

function HT.Time:setDefaultEnvironment()
    local env = HT.Time:getEnvironment()
    if env then
        HT.Time.defaultEnvironment = env
    end
end

function HT.Time:resetEnvironment()
    HT.Time:setEnvironmentSetting(nil)
    if HT.Time.defaultEnvironment then
        HT.Time:setEnvironment(HT.Time.defaultEnvironment)
    end
end

function HT.Time:checkEnvironment()
    local environment = HT.Time:getEnvironment()
    if not environment then return end

    local target = HT:getSetting("time_environment")
    if not target then return end

    if environment == target then return end

    pcall(function()
        managers.viewport:first_active_viewport():set_environment(target)
    end)
end
