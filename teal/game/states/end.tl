local type GameState = require("game.gamestate")
-- local StartState = require("game.states.start")
local EndBackground = require("game.endbackground")

local record EndScreen is GameState
    background: EndBackground
end

local EndScreenMetatable: metatable<EndScreen> = {
    __index = EndScreen
}


function EndScreen.new() : EndScreen
    local instance: EndScreen = {}
    setmetatable(instance, EndScreenMetatable)
    instance.background = EndBackground.new()
    return instance -- need scores and players
end


function EndScreen:step(numberOfPlayers: number, keyStates: {string:boolean}, socketSend: function(string), changeState:function(GameState, ?boolean))
    -- option to restart game and load new game?
    local newKeyStates = {} -- boolean required
    setmetatable(newKeyStates, {__index = keyStates})

    -- show score
    -- TODO change state to start state if restart pressed
    -- if (keyStates["touchRestart"]) then
    --     startState = StartState.new(self.otherplayers)
    --     changeState(StartState, false)
    -- end
end


function EndScreen:draw()
    self.background:draw()
end

return EndScreen

