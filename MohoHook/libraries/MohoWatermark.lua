MohoWatermark = {}
MohoWatermark._ws = nil

local FONT = "fonts/font_medium_mf"
local SIZE = 19
local X = 14
local Y = 8

local SHINE_SPEED = 260
local SHINE_HALF = 30
local SHINE_GAP = 320
local SHINE_MAX = 0.95

local PARTS = {
    { text = "$$$ moho", r = 0.30, g = 0.55, b = 1.00 },
    { text = " hook $$$", r = 0.62, g = 0.62, b = 0.62 },
}

local function baseColor(part)
    return Color(1, part.r, part.g, part.b)
end

local function shineColor(part, k)
    return Color(1,
        part.r + (1 - part.r) * k,
        part.g + (1 - part.g) * k,
        part.b + (1 - part.b) * k)
end

local function nowTime()
    local ok, t = pcall(function()
        return TimerManager:main():time()
    end)
    if ok and type(t) == "number" then
        return t
    end
    local ok2, t2 = pcall(function()
        return Application:time()
    end)
    if ok2 and type(t2) == "number" then
        return t2
    end
    return 0
end

function MohoWatermark:destroy()
    if self._ws then
        pcall(function()
            managers.gui_data:destroy_workspace(self._ws)
        end)
        self._ws = nil
    end
    self._chars = nil
    self._width = nil
end

function MohoWatermark:build()
    self:destroy()

    local ok = pcall(function()
        self._ws = managers.gui_data:create_fullscreen_workspace()
        local root = self._ws:panel()
        local p = root:panel({ x = 0, y = 0, w = 600, h = 40, layer = 12 })

        local function makeText(txt, x, y, layer, color)
            return p:text({
                text       = txt,
                x          = x,
                y          = y,
                w          = 560,
                h          = SIZE + 4,
                color      = color,
                font       = FONT,
                font_size  = SIZE,
                layer      = layer,
                halign     = "left",
                valign     = "top",
            })
        end

        local shadow = Color(0.85, 0, 0, 0)
        self._chars = {}
        local cursor = X

        for _, part in ipairs(PARTS) do
            for ch in part.text:gmatch(".") do
                makeText(ch, cursor + 1, Y + 1, 0, shadow)
                local t = makeText(ch, cursor, Y, 1, baseColor(part))
                local w = select(3, t:text_rect())
                if not w or w <= 0 then
                    w = SIZE * 0.6
                end
                table.insert(self._chars, {
                    obj = t,
                    part = part,
                    center = cursor + w / 2,
                })
                cursor = cursor + w
            end
        end

        self._width = cursor - X
    end)

    if not ok then
        self:destroy()
    end
end

function MohoWatermark:update()
    if HT and HT:isInGame() and not HT:isInMenu() then
        if not self._ws then
            self:build()
        end
        local chars = self._chars
        if chars and #chars > 0 then
            local w = (self._width and self._width > 0) and self._width or 200
            local span = w + SHINE_HALF * 2 + SHINE_GAP
            local head = ((nowTime() * SHINE_SPEED) % span) - SHINE_HALF
            for _, c in ipairs(chars) do
                local d = math.abs(c.center - head)
                if d < SHINE_HALF then
                    local k = 1 - d / SHINE_HALF
                    k = k * k * SHINE_MAX
                    c.obj:set_color(shineColor(c.part, k))
                else
                    c.obj:set_color(baseColor(c.part))
                end
            end
        end
    else
        self:destroy()
    end
end
