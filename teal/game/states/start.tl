local Player = require("game.player")
local type GameState = require("game.gamestate")
local StartBackground = require("game.startbackground")
local MainState = require("game.states.main")

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
        local mainState = MainState.new()
        changeState(mainState)
        mainState:step(dt, {}, socketSend, changeState)
    end
end

function StartScreen:draw()
    self.background:draw()
    self.player:draw()
end

function StartScreen:websocketMessage(message: string)
    -- no-op
end

return StartScreen
