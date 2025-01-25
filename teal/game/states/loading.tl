local type GameState = require("game.gamestate")

local record LoadingState is GameState
end

function LoadingState:step(dt: number, keyStates: {string:boolean}, socketSend: function(string), changeState: function(GameState)) end

function LoadingState:draw() end

function LoadingState:keyUp(key: string) end

function LoadingState:keyDown(key: string) end

function LoadingState:keyPress(key: string) end

function LoadingState:pointerDown() end

function LoadingState:pointerUp() end

return LoadingState 
