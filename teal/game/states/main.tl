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
    instance.player = Player.newTest()
    return instance
end

function Main:step(dt: number, keyStates: {string:boolean}, socketSend: function(string))
    for _, bubble in ipairs(self.player.bubbles) do
        local radius = bubble:radius()
        local squared_radius = radius * radius
        bubble.collision_vector = nil
        for _, bg_slice in ipairs(self.background.slices) do
            local v = bg_slice.collision_slice:collide(bg_slice.screenY, bubble.draw_x + radius, bubble.draw_y + radius, squared_radius)
            if v then
                bubble.collision_vector = v
                break
            end
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
