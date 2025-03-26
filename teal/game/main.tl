local subprotocol = require("shared.subprotocol")
local Buttons = require("game.buttons")
local type GameState = require("game.gamestate")
-- local StartState = require("game.states.start")
local LoadingState = require("game.states.loading")
-- local MainState = require("game.states.main")
local protocols = require("shared.protocols")

local function drawScore(canvas: Canvas.SubCanvas, timeElapsed: number)
    local timeElapsedString = string.format("%.2fs", timeElapsed)
    canvas.clearCanvas()
    canvas.drawText(0, 0, timeElapsedString)
end

global record Game
    currentState: GameState
    canvas: Canvas.SubCanvas
    timeElapsed: number
    enable_timer: boolean
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
    userInteracted: boolean
    queuedAudio: {string}
end

Game.keyStates = {}
Game.socketOpen = false
Game.userInteracted = false
Game.queuedAudio = {}

function Game.playAudio(path: string)
    if (Game.userInteracted) then Audio.playAudio(path)
    else table.insert(Game.queuedAudio, path) end
end

function Game.init()
    Socket.open(subprotocol)
    Game.currentState = LoadingState
    Game.buttons = Buttons.new()
    Game.canvas = Canvas.newCanvas(true)
end

function Game.socketSend(message: string)
    if (Game.socketOpen) then
        Socket.send(message)
    end
end

function Game.changeState(newState: GameState, timer?: boolean)
    Game.enable_timer = timer or false
    if Game.enable_timer then
        Game.timeElapsed = 0
    end
    Game.currentState = newState
end

function Game.step(dt: number)
    if (Game.enable_timer) then
        Game.timeElapsed = Game.timeElapsed + (dt/1000) -- fergus isnt as fast as ai, but hes more accurate
    end

    Game.currentState:step(dt, Game.keyStates, Game.socketSend, Game.changeState)
end

function Game.draw()
    Game.buttons:draw()
    Game.currentState:draw()
    Game.canvas.clearCanvas()
    if (Game.enable_timer) then
        drawScore(Game.canvas, Game.timeElapsed)
    end
    Game.canvas.draw(0, 0)
end

function Game.keyUp(key: string)
    Game.keyStates[key] = false
end

function Game.setUserInteracted()
    Game.userInteracted = true
    for _,v in ipairs(Game.queuedAudio) do
        Audio.playAudio(v)
    end
    Game.queuedAudio = {}
end

function Game.keyDown(key: string)
    if key == "w" or key == "s" then
        return
    end
    Game.keyStates[key] = true
    Game.setUserInteracted()
end

function Game.keyPress(key: string)
    if key == "w" or key == "s" then
        return
    end
    Game.keyStates[key] = true
    -- Socket.send("keyPress: "..key)
    Game.setUserInteracted()
end

function Game.pointerDown()
    -- noop
end

function Game.pointerUp()
    -- noop: i know the function is empty, its needed, trust me bro
end

function Game.onButton(x: number, y: number)
    Game.setUserInteracted()
    local move = Game.buttons:onClicked(x, y)
    if (move == -1) then
        Game.keyPress("touchLeft")
    elseif (move == 1) then
        Game.keyPress("touchRight")
    elseif (move == 1) then
        Game.keyPress("touchRestart")    -- TODO else if =2 then restart button clicked
    end
    print("clicked")

end

function Game.onButtonRelease()
    print("released")
    -- ben knows this is hacky but just let it slide okay
    Game.keyStates["touchLeft"] = false
    Game.keyStates["touchRight"] = false
    Game.keyStates["touchRestart"] = false
end

function Game.websocketOpened()
    Game.socketOpen = true
    Socket.send(protocols.registerClient)
end

function Game.websocketClosed(code: integer, reason: string)
    print("Websocket closed with code "..code..", reason: "..tostring(reason))
    Game.socketOpen = false
end

function Game.websocketMessage(message: string)
    Game.currentState:websocketMessage(message, Game.changeState, Game.playAudio)
end

