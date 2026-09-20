if HT:isInMenu() then
    do return end
end

if not HT:isInGame() then
    do return end
end

if not HT:isInHeist() then
    do return end
end

HT.Keybinds:teleport()
