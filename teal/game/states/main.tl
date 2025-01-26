local Background = require("game.background")
local Player = require("game.player")
local type GameState = require("game.gamestate")

local record SpriteAnimation
    canvas: Canvas.SubCanvas
    timeToLive: number
    x: integer
    y: integer
    size: integer
    previousSpriteIndex: integer
    spriteIndex: integer
end

local SpriteAnimationMetatable: metatable<SpriteAnimation> = {
    __index = SpriteAnimation,
}

function SpriteAnimation.new(x: number, y: number, index: integer, size: number) : SpriteAnimation
    local instance: SpriteAnimation = {}
    setmetatable(instance, SpriteAnimationMetatable)
    instance.canvas = Canvas.newCanvas(true)
    instance.spriteIndex = index
    instance.spriteIndex = index
    instance.x = math.floor(x)
    instance.y = math.floor(y)
    instance.size = math.floor(size)
    instance.timeToLive = 100
    return instance
end

function SpriteAnimation:step(dt: number)
    self.timeToLive = self.timeToLive - dt
    self.y = math.floor(self.y + dt * BACKGROUND_SPEED)
end

function SpriteAnimation:draw()
    if (self.spriteIndex ~= self.previousSpriteIndex) then
        self.canvas.clearCanvas()
        self.canvas.drawImage("bubble.png", self.spriteIndex * SPRITE_STRIDE, SPRITE_STRIDE, self.size, self.size, 0, 0, self.size, self.size)
        self.previousSpriteIndex = self.spriteIndex
    end
    self.canvas.draw(self.x, self.y)
end

local record Main is GameState
    background: Background
    player: Player
    animations: {SpriteAnimation}
end

local MainMetatable: metatable<Main> = {
    __index = Main
}

function Main.new() : Main
    local instance: Main = {}
    setmetatable(instance, MainMetatable)
    instance.background = Background.new()
    instance.player = Player.new()
    instance.animations = {}
    return instance
end

function Main:step(dt: number, keyStates: {string:boolean}, socketSend: function(string), changeState: function(GameState))
    -- update all the active animations
    for _, anim in ipairs(self.animations) do
        anim:step(dt)
    end

    local to_pop = {}
    for i, bubble in ipairs(self.player.bubbles) do
        local radius = bubble:radius()
        local squared_radius = radius * radius
        bubble.collision_vector = nil
        for _, bg_slice in ipairs(self.background.slices) do
            local v = bg_slice.collision_slice:collide(bg_slice.screenY, bubble.draw_x + radius, bubble.draw_y + radius, squared_radius)
            if v then
                bubble.collision_vector = v[1]
                if v[2] then
                    table.insert(to_pop, i)
                end
                break
            end
        end
    end

    for _, i in ipairs(to_pop) do
        if self.player:wouldPop(i) then
            local bub = self.player.bubbles[i]
            table.insert(self.animations, SpriteAnimation.new(
                bub.x,
                bub.y,
                bub.bubbleIndex,
                bub:radius() * 2
            ))
            self.player:pop(i)
        end
    end

    local i = 1
    while (i <= #self.player.bubbles) do
        if self.player.bubbles[i].bubbleIndex >= 0 then
            i = i + 1
        else
            table.remove(self.player.bubbles, i)
        end
    end

    -- cleanup the animations
    local i = 1
    while (i <= #self.animations) do
        if self.animations[i].timeToLive > 0 then
            i = i + 1
        else
            table.remove(self.animations, i)
        end
    end

    self.player:step(dt, keyStates, socketSend)
    self.background:step(dt)
end

function Main:draw()
    self.background:draw()
    self.player:draw()
    -- draw all the animations
    for _, anim in ipairs(self.animations) do
        anim:draw()
    end
end

return Main
