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

function OtherPlayers:websocketMessage(message: string, selfindex: integer)
    local lobbyPosX, lobbyPosY, playerIndex = string.match(message, patterns.lobbyPos)
    if (lobbyPosX and lobbyPosY and playerIndex) then
        local playerIndexInt = math.tointeger(playerIndex)
        if (playerIndexInt == selfindex) then return end
        local bubbles = self.bubbles[playerIndexInt]
        if (bubbles == nil) then
            bubbles = {}
            self.bubbles[playerIndexInt] = bubbles
        end
        if (#bubbles == 0) then
            local tint = Util.getColourForPlayerIndex(playerIndexInt)
            table.insert(bubbles, Bubble.new(4, math.tointeger(lobbyPosX), nil, math.tointeger(lobbyPosY), tint))
        else
            local bubble = bubbles[1]
            if (#bubbles > 1) then
                self.bubbles[playerIndexInt] = bubbles
            end
            bubble.draw_x = math.tointeger(lobbyPosX)
            bubble.draw_y = math.tointeger(lobbyPosY)
        end
    end
end

return OtherPlayers
