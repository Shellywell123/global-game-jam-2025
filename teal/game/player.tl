require("shared.init")
require("game.const")
local type Vector2D = require("game.vector2d")

local BIG_POP_BUBBLES <const> = {
    [0] = 15,
    [1] = 11,
    [2] = 7,
    [3] = 4
}

local DEGREES_TO_RADIANS <const> = 3.1415 / 180
local OSCILLATE_AMPLITUDE <const> = 2
local EPHEMERAL_ACCELERATION <const> = 0.0002
local MAX_EPHEMERAL_VELOCITY <const> = 0.2
local BUBBLE_DIAMETER <const> = {
    -- maps from bubble "level" to the diameter in pixels
    [0] = 8,
    [1] = 16,
    [2] = 24,
    [3] = 32,
    [4] = 64
}
local BUBBLE_SPEEDS <const> = {
    -- maps from bubble "level" to the diameter in pixels
    [0] = 0.2,
    [1] = 0.18,
    [2] = 0.1,
    [3] = 0.08,
    [4] = 0.06
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
    ephemeral_x_vel: number
    ephemeral_y_vel: number
    -- internal incremental ticker
    ticker: number
    ticker_speed: number
    invulnerableTime: number
    -- must be integral: the pixels into which to draw the bubble
    draw_x: integer
    draw_y: integer
    collision_vector: Vector2D
    tint: string
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
    instance.ephemeral_x_vel = b.ephemeral_x_vel
    instance.ephemeral_y_vel = b.ephemeral_y_vel
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
    instance.x_vel = x_vel or BUBBLE_SPEEDS[index]
    instance.y_vel = 0.2
    instance.ephemeral_x_vel = 0
    instance.ephemeral_y_vel = 0
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

    -- if we are not colliding, there is a small restoration speed that gets added
    if (cv.y == 0) and self.y + self:radius() > BUBBLE_TARGET_Y then
        self.y = self.y - BUBBLE_RESTORATION_SPEED * dt
    end

    -- increment the internal ticker for animations
    self.ticker = math.fmod(self.ticker + (dt * self.ticker_speed), 360)

    if self.invulnerableTime > 0 then
        self.invulnerableTime = self.invulnerableTime - dt
    end

    -- add temporary velocities
    if (self.ephemeral_y_vel > 0) or (self.ephemeral_x_vel > 0) then
        self.y = self.y + self.ephemeral_y_vel * dt
        self.x = self.x + self.ephemeral_x_vel * dt
        -- reduce temporary velocities
        self.ephemeral_x_vel = math.max(0, self.ephemeral_x_vel - dt * EPHEMERAL_ACCELERATION)
        self.ephemeral_y_vel = math.max(0, self.ephemeral_y_vel - dt * EPHEMERAL_ACCELERATION)
    end

    -- check boundary collision
    local boundary = config.displayWidth - BUBBLE_DIAMETER[self.bubbleIndex] - PIPE_SIZE
    if (self.x >=(boundary))then
        self.x = (boundary)
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
        if self.bubbleIndex ~= 4 then
            self.canvas.drawImage("bubble.png", self.bubbleIndex * SPRITE_STRIDE, 0, size, size, 0, 0, size, size)
        else
            self.canvas.drawImage("bubble.png", 0, SPRITE_STRIDE * 2, size, size, 0, 0, size, size)
        end
        self.previousBubbleIndex = self.bubbleIndex
    end

    -- blink the bubbles
    if (self.invulnerableTime <= 0) or (math.fmod(self.invulnerableTime, 100) < 50) then
        self.canvas.draw(self.draw_x, self.draw_y)
    end
end

-- An object that represents everything that a player controls, along with it's
-- canvas
local record Player
    bubbles: {Bubble}
    tint: string
end

local PlayerMetatable: metatable<Player> = {
    __index = Player,
}

function Player.new(tint: string, bubbles?: {Bubble}): Player
    local instance: Player = {}
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
            for i = 1, num do
                local b = Bubble.new(size, math.floor(bubble_copy.x), nil, math.floor(bubble_copy.y), bubble_copy.tint)
                b.ephemeral_y_vel = randomY()
                b.ephemeral_x_vel = randomX() * 8
                b.invulnerableTime = bubble_copy.invulnerableTime
                table.insert(self.bubbles, b)
            end
        end
    end
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
