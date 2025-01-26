local Player = require("game.player")
local type GameState = require("game.gamestate")
local StartBackground = require("game.startbackground")
local MainState = require("game.states.main")
local Util = require("game.util")
local protocols = require("shared.protocols")

local record StartScreen is GameState
    player: Player
    background: StartBackground
    selfindex: integer
    sendTimeout: number
end

local StartScreenMetatable: metatable<StartScreen> = {
    __index = StartScreen
}

function StartScreen.new(selfindex: integer) : StartScreen
    local instance: StartScreen = {
        selfindex = selfindex,
        sendTimeout = 0
    }
    setmetatable(instance, StartScreenMetatable)
    instance.player = Player.new(Util.getColourForPlayerIndex(selfindex))
    instance.background = StartBackground.new()
    return instance
end

function StartScreen:step(dt: number, keyStates: {string:boolean}, socketSend: function(string), changeState: function(GameState))
    local newKeystates = {}
    setmetatable(newKeystates, {__index = keyStates})
    -- hacky: make it move up if any keys pressed
    for _,v in pairs(keyStates) do
        if (v) then
            newKeystates["w"] = true
            break
        end
    end
    self.player:step(dt, newKeystates, socketSend)
    if (self.player.bubbles[1].y < 0) then
        if (self.sendTimeout <= 0) then
            socketSend(protocols.requestGameStart)
            self.sendTimeout = 2000
        else
            self.sendTimeout = self.sendTimeout - dt
        end
    end
end

function StartScreen:draw()
    self.background:draw()
    self.player:draw()
end

function StartScreen:websocketMessage(message: string, changeState: function(GameState))
    if (message == protocols.gameStarted) then
        local mainState = MainState.new(self.selfindex)
        changeState(mainState)
    end
end

return StartScreen
