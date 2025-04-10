local Pegasus = require('pegasus')
local FilesPlugin = require('pegasus.plugins.files')
local WebsocketHandshakePlugin = require('server.websockets.websocketHandshakePlugin')
local mimetypes = require('mimetypes')
local Handler = require('pegasus.handler')
local Frame = require('server.websockets.frame')
local FrameHandler = require('server.websockets.frameHandler')
local ConnectionHandler = require('server.websockets.connectionHandler')
local ServerClientRegister = require('server.websockets.serverClientRegister')
local socket = require("socket")
local subprotocol = require("shared.subprotocol")
local protocols = require("shared.protocols")
local patterns = require("shared.patterns")

-- Patch the mimetypes.guess function to handle wasm
local super = mimetypes.guess
mimetypes.guess = function(filename: string): string
    if (string.find(filename, ".+%.wasm")) then
        return "application/wasm"
    end
    return super(filename)
end

-- This plugin allows the client to perform a websocket handshake
local websocketHandshakePlugin = WebsocketHandshakePlugin:new("/websocket", subprotocol)

-- Basic server setup
local pegasus = Pegasus:new({
    port = "26000",
    location = "dist/",
    plugins = {
        websocketHandshakePlugin:getPlugin(),
        FilesPlugin:new({
            location = "./",
            default = "index.html"
        })
    },
    timeout = 5
})

local nextClientIndex = 1
local clientIndexes: {socket.Client:integer} = {}

local enum GameStates
    "lobby"
    "started"
end

local record ClientData
    startRequested: boolean
end

local clientData: {integer:ClientData} = {}
local gameState: GameStates = "lobby"

-- A FrameHandler which broadcasts any updates to position
local frameHandler = FrameHandler:new({
    onTextFrameParsed = function(_: FrameHandler, client: socket.Client, frame: Frame, register: ServerClientRegister)

        -- print(frame.stringContent)
        local lengthNum = 0
        for k, v in pairs(clientIndexes) do -- for every key in the table with a corresponding non-nil value 
            lengthNum = lengthNum + 1
        end
        print("gamestate: "..gameState, "clients: "..tostring(lengthNum))

        local gPlayerIndex = string.match(frame.stringContent, patterns.gamePos)
        if (gPlayerIndex) then
            -- if (gameState ~= "started") then return end
            local clientIndex = clientIndexes[client]
            if (clientIndex ~= math.tointeger(gPlayerIndex)) then return end
            local broadcast = Frame:newTextFrame(frame.stringContent)
            register:registerBroadcastToSend(broadcast)
            return
        end

        local lobbyPosX, lobbyPosY, playerIndex = string.match(frame.stringContent, patterns.lobbyPos) 

        if (lobbyPosX and lobbyPosY and playerIndex) then
            if (gameState ~= "lobby") then return end
            local clientIndex = clientIndexes[client]
            if (clientIndex ~= math.tointeger(playerIndex)) then return end
            local broadcast = Frame:newTextFrame(frame.stringContent)
            register:registerBroadcastToSend(broadcast)
            return
        end

        if (frame.stringContent == protocols.registerClient) then 
            if (gameState ~= "lobby") then
                return -- TODO: maybe a holding screen here?
            end
            print("Registering client "..nextClientIndex)
            clientIndexes[client] = nextClientIndex
            nextClientIndex = nextClientIndex + 1
            clientData[clientIndexes[client]] = {
                startRequested = false
            }
            local response = Frame:newTextFrame(protocols.registrationSuccess.." "..clientIndexes[client])
            register:registerMessageToSend(client, response)
            return
        end
        
        if (frame.stringContent == protocols.requestGameStart) then
            if (gameState ~= "lobby") then return end
            local clientIndex = clientIndexes[client]
            if (clientIndex) then
                clientData[clientIndex].startRequested = true
                local startGame = true
                
                -- this is the logic to wait for everybody to start the game
                for _,v in pairs(clientData) do
                    if (not v.startRequested) then
                        startGame = false
                        break
                    end
                end
                if (startGame) then
                    print("Starting game...")
                    local broadcast = Frame:newTextFrame(protocols.gameStarted)
                    register:registerBroadcastToSend(broadcast)
                    -- gameState = "started"
                end
            end
            return
        end
    end
})

-- A FrameHandler which pings a client after it is connected
local connectionHandler: ConnectionHandler = ConnectionHandler:new({
    onNewWebsocket = function(_: ConnectionHandler, client: socket.Client, register: ServerClientRegister)
        local pingFrame = Frame:newPingFrame()
        register:registerMessageToSend(client, pingFrame)
    end
})

pegasus.start = function(self: Pegasus)
    local handler = Handler:new(nil, self.location, self.plugins, self.log)
    local server = assert(socket.bind(self.host, self.port))
    -- Keeps track of connected websocket clients
    local register = ServerClientRegister:new(server)
    -- Makes sure that any successful websocket handshake stores the client in the register
    websocketHandshakePlugin:setRegister(register)
    local ip, port = server:getsockname()

    print('Pegasus is up on ' .. ip .. ":".. port)

    while 1 do
        connectionHandler:handleNext(self, handler, register, frameHandler)
    end
end

pegasus:start()
