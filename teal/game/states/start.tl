local Player = require("game.player")
local type GameState = require("game.gamestate")
local StartBackground = require("game.startbackground")

local record StartScreen is GameState
    player: Player
    background: StartBackground
end

local StartScreenMetatable: metatable<StartScreen> = {
    __index = StartScreen
}

function StartScreen.new() : StartScreen
    local instance: StartScreen = {}
    setmetatable(instance, StartScreenMetatable)
    instance.player = Player.new()
    instance.background = StartBackground.new()
    return instance
end

function StartScreen:step(dt: number, keyStates: {string:boolean}, socketSend: function(string))
    self.player:step(dt, keyStates, socketSend)
end

function StartScreen:draw()
    self.background:draw()
    self.player:draw()
end

return StartScreen
