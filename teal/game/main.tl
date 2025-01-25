local subprotocol = require("shared.subprotocol")
local Background = require("game.background")
local Character = require("game.character")
local Buttons = require("game.buttons")

global record Game
    keyStates: {string:boolean}
    background: Background
    character: Character
    buttons: Buttons
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
    Game.background = Background.new()
    Game.character = Character.new()
    Game.buttons = Buttons.new()
end

function Game.socketSend(message: string)
    if (Game.socketOpen) then
        Socket.send(message)
    end
end

function Game.step(dt: number)
    Game.character:step(dt, Game.keyStates, Game.socketSend)
end

function Game.draw()
    Game.background:draw()
    Game.character:draw()
    Game.buttons:draw()
end

function Game.keyUp(key: string)
    Game.keyStates[key] = false
end

function Game.keyDown(key: string)
    Game.keyStates[key] = true
    print("keyDown: "..key)
end

function Game.keyPress(key: string)
    Game.keyStates[key] = true
    Socket.send("keyPress: "..key)
    print("keyPress: "..key)
end

function Game.pointerDown()
    print("pressed")
end

-- i know the function it empty, its needed, trust me bro
function Game.pointerUp()
end

function Game.onButton(x: number, y: number)
    print("onTouchStart: x="..x..", y="..y)
    local move = Game.buttons:onClicked(x, y)
    if (move == 0) then
        return
    elseif (move == -1) then
        Game.keyPress("touchLeft")
    elseif (move == 1) then
        Game.keyPress("touchRight")
    end

    Socket.send("Position updated: x="..tostring(Game.character.x)..", y="..tostring(Game.character.y))
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
    print(message)
    local _, _, x, y = string.find(message, "Position updated: x=(%d+%.?%d*), y=(%d+%.?%d*)")
    if (x and y) then
        print("From Lua: "..message)
        Game.character:updatePosition(tonumber(x), tonumber(y))
    end
end
