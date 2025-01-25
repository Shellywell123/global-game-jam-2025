require("shared.init")
require("game.const")
local type Vector2D = require("game.vector2d")

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
    invulnerableTime: number
    -- must be integral: the pixels into which to draw the bubble
    draw_x: integer
    draw_y: integer
    collision_vector: Vector2D
end

local BubbleMetatable: metatable<Bubble> = {
    __index = Bubble,
 }

function Bubble:radius(): number
    return BUBBLE_DIAMETER[self.bubbleIndex] / 2
end

function Bubble.copy(b: Bubble): Bubble
    local instance: Bubble = {}
    setmetatable(instance, BubbleMetatable)
    instance.canvas = Canvas.newCanvas(true, nil, b.tint)
    instance.previousBubbleIndex = b.previousBubbleIndex
    instance.bubbleIndex = b.bubbleIndex
    instance.x = b.x
    instance.y = b.y
    instance.x_vel = b.x_vel
    instance.y_vel = b.y_vel
    instance.ticker_speed = b.ticker_speed
    instance.ticker = b.ticker
    instance.draw_x = b.draw_x
    instance.draw_y = b.draw_x
    instance.invulnerableTime = b.invulnerableTime
    instance.collision_vector = b.collision_vector
    instance.tint = b.tint

    return instance
end

function Bubble.new(index: integer, x?: integer, x_vel?: number, y?: integer, tint?: string): Bubble
    local instance: Bubble = {}
    setmetatable(instance, BubbleMetatable)
    instance.canvas = Canvas.newCanvas(true, nil, tint)
    instance.previousBubbleIndex = -1
    instance.bubbleIndex = index
    instance.x = x or 30
    instance.y = y or config.displayHeight - 64
    instance.x_vel = x_vel or 0.2
    instance.y_vel = 0.2
    instance.ticker_speed = 1.1
    instance.ticker = 0
    instance.draw_x = 0
    instance.draw_y = 0
    instance.invulnerableTime = 0
    instance.collision_vector = nil
    instance.tint = tint
    return instance
end

-- keyStates: input key pressed or not
-- dt: miliseconds
function Bubble:step(dt: number, keyStates: {string:boolean})

    local cv: Vector2D = {x = 0, y = 0}
    if self.collision_vector then
        cv = self.collision_vector
    end

    if cv.y ~= 0 then
        self.y = self.y + 2 * BACKGROUND_SPEED * dt
    end

    local left = false
    local right = false

    if (keyStates["a"] or keyStates["ArrowLeft"] or keyStates["touchLeft"]) then
        if cv.x == 0 then
            left = true
        end
    end
    if (keyStates["d"] or keyStates["ArrowRight"] or keyStates["touchRight"]) then
        if cv.x == 0 then
            right = true
        end
    end

    if (left and not right) then
        self.x = self.x - self.x_vel * dt
        if (self.x <= PIPE_SIZE)then
            self.x = PIPE_SIZE
        end
    end
    if (right and not left) then
        self.x = self.x + self.x_vel * dt
        local boundary = config.displayWidth - BUBBLE_DIAMETER[self.bubbleIndex] - PIPE_SIZE
        if (self.x >=(boundary))then
            self.x = (boundary)
        end
    end

    if (keyStates["w"] and not keyStates["s"]) then
        if cv.y == 0 then
            self.y = self.y - self.y_vel * dt
        end
    end
    if (keyStates["s"] and not keyStates["w"]) then
        if cv.y == 0 then
            self.y = self.y + self.y_vel * dt
        end
    end

    -- increment the internal ticker for animations
    self.ticker = math.fmod(self.ticker + (dt * self.ticker_speed), 360)

    if self.invulnerableTime > 0 then
        self.invulnerableTime = self.invulnerableTime - dt
    end

    -- have to keep these seperate to avoid rounding errors
    self.draw_x = math.floor(self.x + math.sin(self.ticker * DEGREES_TO_RADIANS) * OSCILLATE_AMPLITUDE)
    self.draw_y = math.floor(self.y)
end

function Bubble:draw()
    -- have to keep these seperate to avoid rounding errors
    self.draw_x = self.draw_x
    self.draw_y = self.draw_y

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

function Player.new(bubbles?: {Bubble}): Player
    local instance: Player = {}
    setmetatable(instance, PlayerMetatable)
    instance.bubbles = bubbles or {
        Bubble.new(1, 80, 0.18)
    }
    return instance
end

-- For testing 3 bubbles at once
function Player.newTest(): Player
    local instance = Player.new {
        Bubble.new(0),
        Bubble.new(1, 80, 0.18),
        Bubble.new(2, 120, 0.10)
    }
    instance.bubbles[2].bubbleIndex = 1
    instance.bubbles[2].ticker_speed = 1.0

    instance.bubbles[3].bubbleIndex = 3
    instance.bubbles[3].ticker_speed = 0.9
    return instance
end

function Player:pop(i: integer)
    -- are we invulnerable still?
    if self.bubbles[i].invulnerableTime > 0 then
        return
    end

    self.bubbles[i].bubbleIndex = self.bubbles[i].bubbleIndex - 1

    if self.bubbles[i].bubbleIndex < 0 then
        return
    end

    self.bubbles[i].x = self.bubbles[i].x - 5
    self.bubbles[i].y = self.bubbles[i].y + 10

    self.bubbles[i].invulnerableTime = self.bubbles[i].invulnerableTime + INVULNERABLE_TIME

    -- todo: slightly randomise the velocities
    local bubble_copy = Bubble.copy(self.bubbles[i])
    bubble_copy.x = bubble_copy.x + 10

    table.insert(self.bubbles, bubble_copy)
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
