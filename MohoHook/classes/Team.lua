HT.Team = {}

-- Peers who have HexTrainer_Mini installed. Populated by "hello" broadcasts
-- that the companion mod sends when it loads. Map: peer_id -> { name = "...",
-- granted = bool, last_seen = timestamp }.
HT.Team.peers = {}

-- Net message IDs. Shared protocol with HexTrainer_Mini.
HT.Team.MSG = {
    HELLO        = "HexTrainerMini:hello",    -- mini -> host, "I'm here"
    HELLO_ACK    = "HexTrainerMini:hello_ack",-- host -> mini, acknowledge
    GRANT        = "HexTrainerMini:grant",    -- host -> mini, enable mini menu
    REVOKE       = "HexTrainerMini:revoke",   -- host -> mini, disable mini menu
    GRANTED_ACK  = "HexTrainerMini:granted_ack", -- mini -> host, confirm
}

-- Lazy: register receive hooks only when LuaNetworking is available.
function HT.Team:registerHooks()
    if HT.Team._hooksRegistered then return end
    if not LuaNetworking then return end

    LuaNetworking:AddReceiveHook(HT.Team.MSG.HELLO, function(data, sender)
        local sid = tostring(sender)
        HT.Team.peers[sid] = HT.Team.peers[sid] or { granted = false }
        HT.Team.peers[sid].last_seen = os.time()
        pcall(function()
            local peer = managers.network:session():peer(sender)
            if peer then HT.Team.peers[sid].name = peer:name() end
        end)
        -- Acknowledge so the mini mod knows the host has the full mod
        pcall(function()
            LuaNetworking:SendToPeer(sender, HT.Team.MSG.HELLO_ACK, "1")
        end)
    end)

    LuaNetworking:AddReceiveHook(HT.Team.MSG.GRANTED_ACK, function(data, sender)
        local sid = tostring(sender)
        if HT.Team.peers[sid] then
            HT.Team.peers[sid].granted = (data == "1")
        end
    end)

    HT.Team._hooksRegistered = true
end

-- List peers (for menu population). Returns array of { peer_id, name, granted }.
function HT.Team:listPeers()
    local out = {}
    if not managers.network or not managers.network:session() then
        return out
    end
    for pid, info in pairs(HT.Team.peers) do
        local peer_id = tonumber(pid)
        local peer = nil
        pcall(function() peer = managers.network:session():peer(peer_id) end)
        if peer then
            table.insert(out, {
                peer_id = peer_id,
                name    = info.name or peer:name() or "Peer " .. tostring(peer_id),
                granted = info.granted == true,
            })
        end
    end
    table.sort(out, function(a, b) return (a.name or "") < (b.name or "") end)
    return out
end

function HT.Team:grantTo(peer_id)
    if not LuaNetworking then
        HT:addAlert("SuperBLT networking unavailable", HT.colors.danger)
        return
    end
    pcall(function()
        LuaNetworking:SendToPeer(peer_id, HT.Team.MSG.GRANT, "1")
    end)
    local sid = tostring(peer_id)
    if HT.Team.peers[sid] then
        HT.Team.peers[sid].granted = true
    end
    HT:addAlert("Granted Mini Menu to peer " .. tostring(peer_id), HT.colors.success)
end

function HT.Team:revokeFrom(peer_id)
    if not LuaNetworking then return end
    pcall(function()
        LuaNetworking:SendToPeer(peer_id, HT.Team.MSG.REVOKE, "1")
    end)
    local sid = tostring(peer_id)
    if HT.Team.peers[sid] then
        HT.Team.peers[sid].granted = false
    end
    HT:addAlert("Revoked Mini Menu from peer " .. tostring(peer_id), HT.colors.warning)
end

function HT.Team:grantToAll()
    local count = 0
    for _, entry in ipairs(HT.Team:listPeers()) do
        HT.Team:grantTo(entry.peer_id)
        count = count + 1
    end
    if count == 0 then
        HT:addAlert("No peers with Mini Menu installed", HT.colors.warning)
    else
        HT:addAlert("Granted to " .. count .. " teammates", HT.colors.success)
    end
end

function HT.Team:revokeFromAll()
    for _, entry in ipairs(HT.Team:listPeers()) do
        HT.Team:revokeFrom(entry.peer_id)
    end
    HT:addAlert("Revoked from all teammates", HT.colors.warning)
end

-- Produce a readable status line for the menu, e.g. "Wolf ✓" or "Wolf —"
function HT.Team:statusLine()
    local peers = HT.Team:listPeers()
    if #peers == 0 then
        return "No teammates with Mini installed"
    end
    local parts = {}
    for _, p in ipairs(peers) do
        local mark = p.granted and "[GRANTED]" or "[AVAILABLE]"
        table.insert(parts, p.name .. " " .. mark)
    end
    return table.concat(parts, ", ")
end
