local type GameState = require("game.gamestate")
local protocols = require("shared.protocols")
local StartState = require("game.states.start")

local record LoadingState is GameState
end

function LoadingState.new() : LoadingState
    local instance: LoadingState = {}
    -- setmetatable(instance, LoadingStateMetatable)
    -- instance.background = LoadingState.new()
    return instance -- need scores and players
end

function LoadingState:step(_: number, _: {string:boolean}, _: function(string), _: function(GameState, ?boolean)) end

function LoadingState:draw() end

function LoadingState:keyUp(_: string) end

function LoadingState:keyDown(_: string) end

function LoadingState:keyPress(_: string) end

function LoadingState:pointerDown() end

function LoadingState:pointerUp() end

function LoadingState:websocketMessage(message: string, changeState: function(GameState, ?boolean), playAudio: function(string))
    local match = string.match(message, protocols.registrationSuccess.." (%d+)")
    if (match) then
        changeState(StartState.new(math.tointeger(match)))
        -- playAudio("menu.mp3") -- TODO make a mute/unmute button
    end
end

return LoadingState
