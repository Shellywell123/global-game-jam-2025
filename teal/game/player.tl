require("shared.init")
require("game.const")

local DEGREES_TO_RADIANS <const> = 3.1415 / 180
local OSCILLATE_AMPLITUDE <const> = 2
local SPRITE_STRIDE <const> = 32
local BUBBLE_DIAMETER <const> = {
    -- maps from bubble "level" to the diameter in pixels
    [0] = 8,
    [1] = 16,
    [2] = 24,
    [3] = 32
}

-- An object that represents a single bubble
local record Bubble
    canvas: Canvas.SubCanvas
    previousBubbleIndex: integer
    bubbleIndex: integer
    x: number
    y: number
    x_vel: number
    y_vel: number
    -- internal incremental ticker
    ticker: number
    ticker_speed: number
    -- must be integral: the pixels into which to draw the bubble
    draw_x: integer
    draw_y: integer
end

local BubbleMetatable: metatable<Bubble> = {
    __index = Bubble,
 }

function Bubble.new(): Bubble
    local instance: Bubble = {}
    setmetatable(instance, BubbleMetatable)
    instance.canvas = Canvas.newCanvas(true)
    instance.previousBubbleIndex = -1
    instance.bubbleIndex = 0
    instance.x = 30
    instance.y = config.displayHeight - 16
    instance.x_vel = 0.2
    instance.y_vel = 0.2
    instance.ticker_speed = 1.1
    instance.ticker = 0
    instance.draw_x = 0
    instance.draw_y = 0
    return instance

end

-- keyStates: input key pressed or not
-- dt: miliseconds
function Bubble:step(dt: number, keyStates: {string:boolean})
    local prevX = self.x
    local prevY = self.y

    if (keyStates["w"] and not keyStates["s"]) then
        self.y = self.y - self.y_vel * dt
    end
    if (keyStates["s"] and not keyStates["w"]) then
        self.y = self.y + self.y_vel * dt
    end
    if (keyStates["a"] and not keyStates["d"]) then
        self.x = self.x - self.x_vel * dt
        if (self.x <= PIPE_SIZE)then
            self.x = PIPE_SIZE
        end
    end
    if (keyStates["d"] and not keyStates["a"]) then
        self.x = self.x + self.x_vel * dt
        local boundary = config.displayWidth - BUBBLE_DIAMETER[self.bubbleIndex] - PIPE_SIZE
        if (self.x >=(boundary))then
            self.x = (boundary)
        end
    end
    -- increment the internal ticker for animations
    self.ticker = math.fmod(self.ticker + (dt * self.ticker_speed), 360)

    -- have to keep these seperate to avoid rounding errors
    self.draw_x = math.floor(self.x + math.sin(self.ticker * DEGREES_TO_RADIANS) * OSCILLATE_AMPLITUDE)
    self.draw_y = math.floor(self.y)
end

function Bubble:draw()
    if (self.bubbleIndex ~= self.previousBubbleIndex) then
        local size = BUBBLE_DIAMETER[self.bubbleIndex]
        self.canvas.clearCanvas()
        self.canvas.drawImage("bubble.png", self.bubbleIndex * SPRITE_STRIDE, 0, size, size, 0, 0, size, size)
        self.previousBubbleIndex = self.bubbleIndex
    end
    self.canvas.draw(self.draw_x, self.draw_y)
end

-- An object that represents everything that a player controls, along with it's
-- canvas
local record Player
    bubbles: {Bubble}
end

local PlayerMetatable: metatable<Player> = {
    __index = Player,
 }

function Player.new(): Player
    local instance: Player = {}
    setmetatable(instance, PlayerMetatable)
    instance.bubbles = {}
    table.insert(instance.bubbles, Bubble.new())
    table.insert(instance.bubbles, Bubble.new())
    table.insert(instance.bubbles, Bubble.new())
    instance.bubbles[2].x = 80
    instance.bubbles[2].x_vel = 0.18
    instance.bubbles[2].bubbleIndex = 1
    instance.bubbles[2].ticker_speed = 1.0
    instance.bubbles[2].y = 50

    instance.bubbles[3].x = 120
    instance.bubbles[3].x_vel = 0.10
    instance.bubbles[3].bubbleIndex = 3
    instance.bubbles[3].ticker_speed = 0.9
    instance.bubbles[3].y = 100
    return instance
end

function Player:step(dt: number, keyStates: {string:boolean}, socketSend: function(string))
    for i, bubble in ipairs(self.bubbles) do
        bubble:step(dt, keyStates)
    end
end

function Player:draw()
    for i, bubble in ipairs(self.bubbles) do
        bubble:draw()
    end
end

function Player:updatePosition(x: number, y: number)
    -- noop
end

return Player
