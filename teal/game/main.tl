local subprotocol = require("shared.subprotocol")
local Background = require("game.background")
local Buttons = require("game.buttons")
local Player = require("game.player")

global record Game
    keyStates: {string:boolean}
    background: Background
    buttons: Buttons
    player: Player
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
    Game.buttons = Buttons.new()
    Game.player = Player.new()
end

function Game.socketSend(message: string)
    if (Game.socketOpen) then
        Socket.send(message)
    end
end

function Game.step(dt: number)
    for _, bubble in ipairs(Game.player.bubbles) do
        local radius = bubble:radius()
        local squared_radius = radius * radius
        bubble.collision_vector = nil
        for _, bg_slice in ipairs(Game.background.slices) do
            local v = bg_slice.collision_slice:collide(bubble.draw_x + radius, bubble.draw_y + radius, squared_radius)
            if v then
                bubble.collision_vector = v
                break
            end
        end

    end

    Game.player:step(dt, Game.keyStates, Game.socketSend)
    Game.background:step(dt)
end

function Game.draw()
    Game.background:draw()
    Game.buttons:draw()
    Game.player:draw()
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
    print(message)
    local _, _, x, y = string.find(message, "Position updated: x=(%d+%.?%d*), y=(%d+%.?%d*)")
    if (x and y) then
        print("From Lua: "..message)
        Game.player:updatePosition(tonumber(x), tonumber(y))
    end
end

