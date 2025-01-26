local Bubble = require("game.bubble")
local Util = require("game.util")
local patterns = require("shared.patterns")

local record ProtoBubble
    x: integer
    y: integer
    tint: integer
end

local record OtherPlayers
    bubbles: {integer:{Bubble}}
end

local OtherPlayersMetatable: metatable<OtherPlayers> = {
    __index = OtherPlayers
}

function OtherPlayers.new(): OtherPlayers
    local instance: OtherPlayers = {
        bubbles = {}
    }
    setmetatable(instance, OtherPlayersMetatable)
    return instance
end

function OtherPlayers:draw()
    for _, v in pairs(self.bubbles) do
        for _, b in ipairs(v) do
            b:draw()
        end
    end
end

function OtherPlayers:newLobbyMessage(lobbyPosX: integer, lobbyPosY: integer, playerIndex: integer, selfIndex: integer)
    if (playerIndex == selfIndex) then return end
    local bubbles = self.bubbles[playerIndex]
    if (bubbles == nil) then
        bubbles = {}
        self.bubbles[playerIndex] = bubbles
    end
    if (#bubbles == 0) then
        local tint = Util.getColourForPlayerIndex(playerIndex)
        table.insert(bubbles, Bubble.new(4, lobbyPosX, nil, lobbyPosY, tint))
    else
        local bubble = bubbles[1]
        if (#bubbles > 1) then
            self.bubbles[playerIndex] = {bubble}
        end
        bubble.draw_x = lobbyPosX
        bubble.draw_y = lobbyPosY
    end
end

function OtherPlayers:newGameMessage(playerIndex: integer, selfIndex: integer, message: string)
    if (playerIndex == selfIndex) then return end
    local bubbles = self.bubbles[playerIndex]
    if (bubbles == nil) then
        bubbles = {}
        self.bubbles[playerIndex] = bubbles
    end
    local tint: string = nil
    local prevBubbleCount = #bubbles
    local bubbleCount = 0
    for x, y, size, invulnerableTime in string.gmatch(message, patterns.gamePosLine) do
        bubbleCount = bubbleCount + 1
        local bubble: Bubble
        if (#bubbles < bubbleCount) then
            if (tint == nil) then
                tint = Util.getColourForPlayerIndex(playerIndex)
            end
            bubble = Bubble.new(math.tointeger(size), math.tointeger(x), nil, math.tointeger(y), tint)
            table.insert(bubbles, bubble)
        else
            bubble = bubbles[bubbleCount]
            bubble.draw_x = math.tointeger(x)
            bubble.draw_y = math.tointeger(y)
            bubble.bubbleIndex = math.tointeger(size)
        end
        bubble.invulnerableTime = math.tointeger(invulnerableTime)
    end
    while (#bubbles > bubbleCount) do
        table.remove(bubbles)
    end
end

function OtherPlayers:websocketMessage(message: string, selfindex: integer)
    local gamePlayerIndex = string.match(message, patterns.gamePos)
    if (gamePlayerIndex) then
        self:newGameMessage(math.tointeger(gamePlayerIndex), selfindex, message)
    end
    local lobbyPosX, lobbyPosY, playerIndex = string.match(message, patterns.lobbyPos)
    if (lobbyPosX and lobbyPosY and playerIndex) then
        self:newLobbyMessage(math.tointeger(lobbyPosX), math.tointeger(lobbyPosY), math.tointeger(playerIndex), selfindex)
        return
    end
end

return OtherPlayers
