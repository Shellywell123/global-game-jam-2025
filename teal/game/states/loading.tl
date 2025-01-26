local type GameState = require("game.gamestate")
local protocols = require("shared.protocols")
local StartState = require("game.states.start")

local record LoadingState is GameState
end

function LoadingState:step(dt: number, keyStates: {string:boolean}, socketSend: function(string), changeState: function(GameState)) end

function LoadingState:draw() end

function LoadingState:keyUp(key: string) end

function LoadingState:keyDown(key: string) end

function LoadingState:keyPress(key: string) end

function LoadingState:pointerDown() end

function LoadingState:pointerUp() end

function LoadingState:websocketMessage(message: string, changeState: function(GameState))
    local match = string.match(message, protocols.registrationSuccess.." (%d+)")
    if (match) then
        changeState(StartState.new())
    end
end

return LoadingState 
