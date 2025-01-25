local Background = require("game.background")
local Player = require("game.player")
local type GameState = require("game.gamestate")

local record Main is GameState
    background: Background
    player: Player
end

local MainMetatable: metatable<Main> = {
    __index = Main
}

function Main.new() : Main
    local instance: Main = {}
    setmetatable(instance, MainMetatable)
    instance.background = Background.new()
    instance.player = Player.new()
    return instance
end

function Main:step(dt: number, keyStates: {string:boolean}, socketSend: function(string))
    local to_pop = {}
    for i, bubble in ipairs(self.player.bubbles) do
        local radius = bubble:radius()
        local squared_radius = radius * radius
        bubble.collision_vector = nil
        for _, bg_slice in ipairs(self.background.slices) do
            local v = bg_slice.collision_slice:collide(bg_slice.screenY, bubble.draw_x + radius, bubble.draw_y + radius, squared_radius)
            if v then
                bubble.collision_vector = v[1]
                if v[2] then
                    table.insert(to_pop, i)
                end
                break
            end
        end
    end

    for _, i in ipairs(to_pop) do
        self.player:pop(i)
    end

    local i = 1
    while (i <= #self.player.bubbles) do
        if self.player.bubbles[i].bubbleIndex >= 0 then
            i = i + 1
        else
            table.remove(self.player.bubbles, i)
        end
    end

    self.player:step(dt, keyStates, socketSend)
    self.background:step(dt)
end

function Main:draw()
    self.background:draw()
    self.player:draw()
end

return Main
