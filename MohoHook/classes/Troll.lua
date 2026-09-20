HT.Troll = {}

-- Wire protocol: shared with HexTrainer_Mini
HT.Troll.MSG = {
    EFFECT = "HexTrainerMini:troll_effect",
}

-- Catalog of effects, with presets. Each entry has a "kind" (transmitted to
-- mini, which dispatches on it) and optional "payloads" (random pick sent
-- along as data).
HT.Troll.effects = {
    {
        id   = "fake_popup",
        name = "Fake Achievement Popup",
        payloads = {
            "You're doing great!",
            "+1 Big Brain Play",
            "Achievement Unlocked: Being Trash",
            "Welcome back to the heist",
            "Skill check: FAILED",
            "You've been promoted to Bag Boy",
            "Certified Loud",
            "Achievement Unlocked: Walks Into Walls",
        },
    },
    {
        id   = "screen_text",
        name = "Screen Text",
        payloads = {
            "gg",
            "skill issue",
            "WASD to move btw",
            "dont shoot civs",
            "youre cracked",
            "bro missed every shot",
            "press F to pay respects",
            "get the bags",
        },
    },
    {
        id   = "confetti",
        name = "Confetti Blast",
        payloads = { "" },
    },
    {
        id   = "horn",
        name = "Airhorn",
        payloads = { "" },
    },
    {
        id   = "fake_death",
        name = "Fake YOU DIED Overlay",
        payloads = { "" },
    },
    {
        id   = "random_shout",
        name = "Random Shout",
        payloads = { "" },  -- mini picks the voice line locally
    },
    {
        id   = "random_emote",
        name = "Random Emote",
        payloads = { "" },  -- mini picks locally
    },
}

local function pick_random(list)
    if not list or #list == 0 then return "" end
    return list[math.random(1, #list)]
end

-- Send an effect to every Mini-equipped peer. Returns how many recipients.
function HT.Troll:sendEffectToAll(kind)
    if not LuaNetworking then
        HT:addAlert("SuperBLT networking unavailable", HT.colors.danger)
        return 0
    end

    -- Find the effect definition
    local def = nil
    for _, e in ipairs(HT.Troll.effects) do
        if e.id == kind then def = e; break end
    end
    if not def then
        HT:addAlert("Unknown troll effect: " .. tostring(kind), HT.colors.danger)
        return 0
    end

    local payload = pick_random(def.payloads)
    local packet  = kind .. "|" .. payload

    local count = 0
    if HT.Team then
        for _, peer_entry in ipairs(HT.Team:listPeers()) do
            if peer_entry.granted then
                pcall(function()
                    LuaNetworking:SendToPeer(peer_entry.peer_id, HT.Troll.MSG.EFFECT, packet)
                end)
                count = count + 1
            end
        end
    end

    if count == 0 then
        HT:addAlert("No granted peers. Grant Mini Menu first.", HT.colors.warning)
    else
        HT:addAlert(def.name .. " sent to " .. count .. " peers", HT.colors.success)
    end
    return count
end

HT.Troll.serverLines = {
    "$$$ moho hook $$$ $$$ moho hook $$$",
    "$$$ SERVER FUCKED BY MOHO HOOK $$$",
    "$$$ your host is playing with a trainer $$$",
    "$$$ moho hook $$$ was here $$$",
    "$$$ enjoy the bags $$$",
    "#$% moho hook #%# SKILL ISSUE DETECTED #$%",
    "$$$ >>> FREE BAGS <<< no refunds <<< $$$",
    "@@@ moho hook @@@ host privileges revoked @@@",
}

HT.Troll.enableRainbowChat = false

function HT.Troll:setRainbowChat(value)
    HT.Troll.enableRainbowChat = value and true or false
    HT:setSetting("rainbow_chat", HT.Troll.enableRainbowChat)
    HT:updateJsonValue("troll", "ut_item_troll_rainbow_chat", HT.Troll.enableRainbowChat)

    if HT.Troll.enableRainbowChat then
        HT:addAlert("ut_alert_rainbow_chat_enabled", HT.colors.success)
    else
        HT:addAlert("ut_alert_rainbow_chat_disabled", HT.colors.success)
    end
end

function HT.Troll:serverFucker()
    if not HT:isInHeist() then
        HT:addAlert("ut_alert_in_heist_only_feature", HT.colors.warning)
        return
    end
    if not HT:isHost() then
        HT:addAlert("ut_alert_host_only_feature", HT.colors.warning)
        return
    end

    if HT.Mission and HT.Mission.disableCarryVerify then
        HT.Mission:disableCarryVerify()
    end

    pcall(function()
        local chat = managers.chat
        local channel = (ChatManager and ChatManager.GAME) or 1
        if chat then
            for i = 1, 10 do
                chat:send_message(channel, nil, HT.Troll.serverLines[(i % #HT.Troll.serverLines) + 1])
            end
        end
    end)

    pcall(function()
        local session = managers.network:session()
        if not session then
            return
        end

        local pool = {}
        for _, carry_id in ipairs({ "money", "gold", "meth", "cocaine", "jewelry", "weapons", "painting", "salad", "sandwich" }) do
            if tweak_data.carry[carry_id] then
                table.insert(pool, carry_id)
            end
        end

        local throw_level = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)
        if #pool == 0 then
            return
        end
        local centers = {}

        local player = managers.player:player_unit()
        if player and alive(player) then
            table.insert(centers, { pos = player:position(), peer = session:local_peer() })
        end

        for _, peer in pairs(session:peers()) do
            local unit = peer and peer:unit()
            if unit and alive(unit) then
                table.insert(centers, { pos = unit:position(), peer = peer })
            end
        end

        for _, center in ipairs(centers) do
            for i = 1, 8 do
                local carry_id = pool[math.random(#pool)]
                local angle = math.rand(360)
                local radius = math.rand(120, 420)
                local offset = Vector3(math.cos(angle) * radius, math.sin(angle) * radius, math.rand(150, 400))
                local dir = Vector3(math.cos(angle), math.sin(angle), -0.5):normalized()
                managers.player:server_drop_carry(carry_id, 1, true, false, nil,
                    center.pos + offset, Rotation(), dir, throw_level, nil, center.peer)
            end
        end
    end)

    HT:addAlert("Server fucked", HT.colors.danger)
end
