local subprotocol = require("shared.subprotocol")
local Background = require("game.background")
local Player = require("game.player")

global record Game
    keyStates: {string:boolean}
    background: Background
    player: Player
    socketOpen: boolean
    step: function(dt: number)
    draw: function()
    keyUp: function(key: string)
    keyDown: function(key: string)
    keyPress: function(key: string)
end

Game.keyStates = {}
Game.socketOpen = false

function Game.init()
    Socket.open(subprotocol)
    Game.background = Background.new()
    Game.player = Player.new()
end

function Game.socketSend(message: string)
    if (Game.socketOpen) then
        Socket.send(message)
    end
end

function Game.step(dt: number)
    Game.player:step(dt, Game.keyStates, Game.socketSend)
end

function Game.draw()
    Game.background:draw()
    Game.player:draw()
end

function Game.keyUp(key: string)
    Game.keyStates[key] = false
end

function Game.keyPress(key: string)
    Game.keyStates[key] = true
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
        Game.player:updatePosition(tonumber(x), tonumber(y))
    end
end

function Game.onClick(x: number, y: number)
    -- The -32 accounts for sprite width
    -- Game.player:updatePosition(x - 32, y - 32)
    -- Socket.send("Position updated: x="..tostring(Game.player.x)..", y="..tostring(Game.player.y))
end
