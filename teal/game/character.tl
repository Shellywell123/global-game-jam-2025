local record Character
    canvas: Canvas.SubCanvas
    spriteIndex: integer
    prevSpriteIndex: integer
    x: number
    y: number
    speed: number
end

local CharacterMetatable: metatable<Character> = {
    __index = Character,
}

function Character.new(): Character
    local instance: Character = {}
    setmetatable(instance, CharacterMetatable)
    instance.speed = 0.5
    instance.spriteIndex = 0
    instance.x = 30
    instance.y = 40
    instance.canvas = Canvas.newCanvas(true)
    return instance
end

function Character:step(dt: number, keyStates: {string:boolean}, socketSend: function(string))
    local prevX = self.x
    local prevY = self.y

    local left = false
    local right = false

    if (keyStates["a"] or keyStates["ArrowLeft"] or keyStates["touchLeft"]) then
        left = true
    end
    if (keyStates["d"] or keyStates["ArrowRight"] or keyStates["touchRight"]) then
        right = true
    end

    if (left and not right) then
        self.spriteIndex = 0
        self.x = self.x - self.speed * dt
    end
    if (right and not left) then
        self.spriteIndex = 1
        self.x = self.x + self.speed * dt
    end
    self.x = math.floor(self.x)
    self.y = math.floor(self.y)
end

function Character:draw()
    if (self.spriteIndex ~= self.prevSpriteIndex) then
        self.canvas.clearCanvas()
        self.canvas.drawImage("bubble.png", 0, 0, 64, 64, 0, 0, 64, 64)
        self.prevSpriteIndex = self.spriteIndex
    end
    self.canvas.draw(self.x, self.y)
end

function Character:GetPosition(): number, number
    return self.x, self.y
end

function Character:updatePosition(x: number, y: number)
    self.x = x
    self.y = y
end

return Character
