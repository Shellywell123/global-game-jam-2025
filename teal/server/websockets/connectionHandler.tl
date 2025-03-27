local type Pegasus = require('pegasus')
local type Handler = require('pegasus.handler')
local type FrameHandler = require('server.websockets.frameHandler')
local type ServerClientRegister = require('server.websockets.serverClientRegister')
local type ContainedError = require("server.containederror")
local socket = require("socket")
local Frame = require("server.websockets.frame")

local record ConnectionHandler
end

local ConnectionHandlerMetatable: metatable<ConnectionHandler> = {
    __index = ConnectionHandler
}

function ConnectionHandler:onNewWebsocket(_: socket.Client, _: ServerClientRegister)
    -- OVERRIDE
end

function ConnectionHandler:handleNext(pegasus: Pegasus, handler: Handler, register: ServerClientRegister, frameHandler: FrameHandler)
    local register_senders = {}

    for client, frames in pairs(register.messageQueue) do
        if (#frames ~= 0) then
            table.insert(register_senders, client)
        end
    end

    local receivers, senders, err = socket.select(register.receivers, register_senders, nil)

    if err then
        print("Error: ", err)
        return
    end

    if receivers then
        for _, receiver in ipairs(receivers) do
            if (receiver == register.server) then
                local client, errmsg = register.server:accept()

                if client then
                    client:settimeout(pegasus.timeout, 'b')
                    handler:processRequest(pegasus.port, client, register.server)
                elseif errmsg ~= "timeout" then
                    print("Failed to accept connection "..register.nextIndex..": "..errmsg)
                end

                if (register:containsClient(client)) then
                    print("Connection "..register.nextIndex.." converted to a websocket")
                    client:setoption("keepalive", true)
                    self:onNewWebsocket(client, register)
                else
                    -- print("Connection "..register.nextIndex.." completed and closed")
                end
            else
                local client = receiver as socket.Client
                local index = register.indexMap[client]
                local status, result = pcall(function(): Frame
                    local frame = Frame:readNext(client)
                    return frame
                end)
                if (status) then
                    pcall(function() frameHandler:handleFrame(client, result, register) end)
                else
                    local containedError = result as ContainedError
                    print(containedError)
                    if (containedError.message == "closed") then
                        print("Connection "..index.." forcibly closed.")
                        register:removeClient(client)
                    else
                        local ermsg = "?"
                        if containedError.message ~= nil then
                            ermsg = containedError.message
                        end
                        print("Error parsing frame from connection "..index..": "..ermsg)
                    end
                end

                -- Send immediate responses, e.g ping or pong
                local immediate = register.immediateMessageQueue[client]
                if (immediate ~= nil) then
                    for _, frame in ipairs(immediate) do
                        client:send(frame)
                    end
                    register.immediateMessageQueue[client] = {}
                end
            end
        end
    end
    if senders then
        for _, client in ipairs(senders) do
            local index = register.indexMap[client]
            -- Send non-immediate responses, e.g broadcasts
            if (index ~= nil) then
                for _, frame in ipairs(register.messageQueue[client]) do
                    client:send(frame)
                end
                register.messageQueue[client] = {}
            end
        end
    end

end

function ConnectionHandler:new(instance: ConnectionHandler): ConnectionHandler
    local newInstance = instance or {}
    setmetatable(newInstance, ConnectionHandlerMetatable)
    return newInstance
end

return ConnectionHandler
