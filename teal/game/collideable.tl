require("shared.init")

local record Collideable
    x: number
    y: number
    size_x: number
    size_y: number
    sprite: string
    sprite_xoffset: integer
    sprite_yoffset: integer
end

local CollideableMetatable: metatable<Collideable> = {
    __index = Collideable,
 }

function Collideable.new(): Collideable
    local instance: Collideable = {}
    setmetatable(instance, CollideableMetatable)
    instance.x = 0
    instance.y = 0

    instance.size_x = 32
    instance.size_y = 16

    instance.sprite_yoffset = 1
    instance.sprite_xoffset = 0

    instance.sprite = "bubble.png"

    return instance
end

function Collideable:draw(canvas: Canvas.SubCanvas, x: number, y: number)
    canvas.drawImage(
        self.sprite,
        self.sprite_xoffset * config.spriteDimensions,
        self.sprite_yoffset * config.spriteDimensions,
        self.size_x,
        self.size_y,
        self.x + x,
        self.y + y,
        self.size_x,
        self.size_y
    )
end

local record CollideableSlice
    objects: {Collideable}
end

local CollideableSliceMetatable: metatable<CollideableSlice> = {
    __index = CollideableSlice,
 }

function CollideableSlice.new(): CollideableSlice
    local instance: CollideableSlice = {}
    setmetatable(instance, CollideableSliceMetatable)
    instance.objects = {}
    table.insert(instance.objects, Collideable.new())
    return instance
end

function CollideableSlice:draw(canvas: Canvas.SubCanvas, x: number, y: number)
    for _, obj in ipairs(self.objects) do
        obj:draw(canvas, x, y)
    end
end

return CollideableSlice
