local subprotocol = require("shared.subprotocol")
local Buttons = require("game.buttons")
local type GameState = require("game.gamestate")
local StartState = require("game.states.start")
local LoadingState = require("game.states.loading")

global record Game
    currentState: GameState
    buttons: Buttons
    keyStates: {string:boolean}
    socketOpen: boolean
    step: function(dt: number)
    draw: function()
    keyUp: function(key: string)
    keyDown: function(key: string)
    keyPress: function(key: string)
    pointerDown: function()
    pointerUp: function()
end

Game.keyStates = {}
Game.socketOpen = false

function Game.init()
    Socket.open(subprotocol)
    Game.currentState = LoadingState
    Game.buttons = Buttons.new()
end

function Game.socketSend(message: string)
    if (Game.socketOpen) then
        Socket.send(message)
    end
end

function Game.changeState(newState: GameState)
    Game.currentState = newState
end

function Game.step(dt: number)
    Game.currentState:step(dt, Game.keyStates, Game.socketSend, Game.changeState)
end

function Game.draw()
    Game.buttons:draw()
    Game.currentState:draw()
end

function Game.keyUp(key: string)
    Game.keyStates[key] = false
end

function Game.keyDown(key: string)
    Game.keyStates[key] = true
end

function Game.keyPress(key: string)
    Game.keyStates[key] = true
    Socket.send("keyPress: "..key)
end

function Game.pointerDown()
    -- noop
end

function Game.pointerUp()
    -- noop: i know the function is empty, its needed, trust me bro
end

function Game.onButton(x: number, y: number)
    print("onTouchStart: x="..x..", y="..y)
    local move = Game.buttons:onClicked(x, y)
    if (move == -1) then
        Game.keyPress("touchLeft")
    elseif (move == 1) then
        Game.keyPress("touchRight")
    end
end

function Game.onButtonRelease()
    print("released")
    -- ben knows this is hacky but just let it slide okay
    Game.keyStates["touchLeft"] = false
    Game.keyStates["touchRight"] = false
end

function Game.websocketOpened()
    Socket.send("Hello World!")
    Game.socketOpen = true
end

function Game.websocketClosed(code: integer, reason: string)
    print("Websocket closed with code "..code..", reason: "..tostring(reason))
    Game.socketOpen = false
end

function Game.websocketMessage(message: string)
    Game.currentState:websocketMessage(message)
end

