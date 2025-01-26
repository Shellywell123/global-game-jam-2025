local type GameState = require("game.gamestate")
local EndBackground = require("game.endbackground") -- create end background
-- local MainState = require("game.states.main")


local record EndScreen is GameState
    background: EndBackground
end

local EndScreenMetatable: metatable<EndScreen> = {
    __index = EndScreen
}


function EndScreen.new() : EndScreen
    local instance: EndScreen = {}
    setmetatable(instance, EndScreenMetatable)
    return instance -- need scores and players
end


function EndScreen:step(numberOfPlayers: number, keyStates: {string:boolean}, socketSend: function(string), changeState:function(GameState)) 
    -- option to restart game and load new game?
    local newKeyStates = {} -- boolean required
    setmetatable(newKeyStates, {__index = keyStates})
    -- show score
end


function EndScreen:draw()
    self.background:draw() -- console.error
end

return EndScreen

