require("shared.init")
require("game.const")
local Bubble = require("game.bubble")
local protocols = require("shared.protocols")
local Util = require("game.util")

local BIG_POP_BUBBLES <const> = {
    [0] = 15,
    [1] = 11,
    [2] = 7,
    [3] = 4
}
local MAX_EPHEMERAL_VELOCITY <const> = 0.2

-- An object that represents everything that a player controls, along with it's
-- canvas
local record Player
    bubbles: {Bubble}
    tint: string
    selfindex: integer
end

local PlayerMetatable: metatable<Player> = {
    __index = Player,
}

function Player.new(selfindex: integer, bubbles?: {Bubble}): Player
    local instance: Player = {
        selfindex = selfindex
    }
    local tint = Util.getColourForPlayerIndex(selfindex)
    setmetatable(instance, PlayerMetatable)
    instance.bubbles = bubbles or {
        Bubble.new(4, 80, 0.18, nil, tint)
    }
    return instance
end

function Player:wouldPop(i: integer) : boolean
    -- are we invulnerable still? return true if we would pop
    return self.bubbles[i].invulnerableTime <= 0
end

local function randomX() : number
    return (math.random() - 0.5) * MAX_EPHEMERAL_VELOCITY
end

local function randomY() : number
    return math.random() * MAX_EPHEMERAL_VELOCITY
end

function Player:pop(i: integer)
    local big_pop = self.bubbles[i].bubbleIndex == 4
    -- todo: offset new bubbles to the center of the old bubble
    self.bubbles[i].bubbleIndex = self.bubbles[i].bubbleIndex - 1

    if self.bubbles[i].bubbleIndex < 0 then
        Audio.playAudio("pop.mp3")
        return
    end

    self.bubbles[i].y = self.bubbles[i].y + 10
    self.bubbles[i].ephemeral_y_vel = randomY()
    self.bubbles[i].ephemeral_x_vel = randomX()
    self.bubbles[i].invulnerableTime = self.bubbles[i].invulnerableTime + INVULNERABLE_TIME

    local bubble_copy = Bubble.copy(self.bubbles[i])
    bubble_copy.ephemeral_y_vel = randomY()
    bubble_copy.ephemeral_x_vel = randomX()
    table.insert(self.bubbles, bubble_copy)

    if big_pop then
        for size, num in ipairs(BIG_POP_BUBBLES) do
            for _ = 1, num do
                local b = Bubble.new(size, math.floor(bubble_copy.x), nil, math.floor(bubble_copy.y), bubble_copy.tint)
                b.ephemeral_y_vel = randomY()
                b.ephemeral_x_vel = randomX() * 8
                b.invulnerableTime = bubble_copy.invulnerableTime
                table.insert(self.bubbles, b)
            end
        end
    end

    Audio.playAudio("pop.mp3")
end

function Player:step(dt: number, keyStates: {string:boolean}, socketSend: function(string))
    local i = 1
    while (i <= #self.bubbles) do
        if (self.bubbles[i].y >= config.displayHeight) then
            table.remove(self.bubbles, i)
        else
            self.bubbles[i]:step(dt, keyStates)
            i = i + 1
        end
    end
    local sendMessage = protocols.gamePos .. " " .. self.selfindex
    for _, bubble in ipairs(self.bubbles) do
        sendMessage = sendMessage .. "|"..bubble.draw_x.." "..bubble.draw_y.." "..bubble.bubbleIndex.." "..math.max(bubble.invulnerableTime, 0)
    end
    socketSend(sendMessage)
end

function Player:draw()
    for _, bubble in ipairs(self.bubbles) do
        bubble:draw()
    end
end

function Player:updatePosition(_: number, _: number)
    -- noop
end

return Player
