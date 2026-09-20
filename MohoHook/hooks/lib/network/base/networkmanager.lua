if NetworkManager and not NetworkManager.orig then
    pcall(function() _G.CloneClass(NetworkManager) end)
end
