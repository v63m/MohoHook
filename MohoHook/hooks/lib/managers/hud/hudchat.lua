local RAINBOW_COLORS = {
    Color(1, 0.24, 0.24),
    Color(1, 0.6, 0),
    Color(1, 0.9, 0),
    Color(0.3, 1, 0.35),
    Color(0.25, 0.65, 1),
    Color(0.7, 0.35, 1)
}

_G.CloneClass(HUDChat)

function HUDChat:receive_message(name, message, color, icon)
    HUDChat.orig.receive_message(self, name, message, color, icon)

    local ok, err = pcall(function()
        if not (HT and HT.Troll and HT.Troll.enableRainbowChat) then
            return
        end

        local lines = self._lines
        if type(lines) ~= "table" or #lines == 0 then
            return
        end

        local entry = lines[#lines]
        local line = entry and entry[1]
        if not line or not line.text then
            return
        end

        local total = utf8.len(line:text())
        if not total or total <= 0 then
            return
        end

        for i = 0, total - 1 do
            line:set_range_color(i, i + 1, RAINBOW_COLORS[(i % #RAINBOW_COLORS) + 1])
        end
    end)

    if not ok and HT and HT.debugLogClass then
        HT.debugLogClass:log("Rainbow chat failed: " .. tostring(err))
    end
end
