local Player = require("game.player")
local OtherPlayers = require("game.otherplayers")
local type GameState = require("game.gamestate")
local StartBackground = require("game.startbackground")
local MainState = require("game.states.main")
-- local Util = require("game.util")
local protocols = require("shared.protocols")

local record StartScreen is GameState
    player: Player
    otherplayers: OtherPlayers
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
    instance.player = Player.new(selfindex)
    instance.otherplayers = OtherPlayers.new()
    instance.background = StartBackground.new()
    return instance
end

function StartScreen:step(dt: number, keyStates: {string:boolean}, socketSend: function(string), _: function(GameState, ?boolean))
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
    local bubble = self.player.bubbles[1]
    if (bubble.y < -64) then
        if (self.sendTimeout <= 0) then
            socketSend(protocols.requestGameStart)
            self.sendTimeout = 2000
        else
            self.sendTimeout = self.sendTimeout - dt
        end
    else
        socketSend(protocols.lobbyPos.." "..bubble.draw_x.." "..bubble.draw_y.." "..self.selfindex)
    end
end

function StartScreen:draw()
    self.background:draw()
    self.otherplayers:draw()
    self.player:draw()
end

function StartScreen:websocketMessage(message: string, changeState: function(GameState, ?boolean), _: function(string))
    if (message == protocols.gameStarted) then
        local mainState = MainState.new(self.selfindex, self.otherplayers)
        changeState(mainState, true)
    else
        self.otherplayers:websocketMessage(message, self.selfindex)
    end
end

return StartScreen
