require("shared.init")

local record Collideable
    x: number
    y: number
    size_x: number
    size_y: number
    sprite: string
    sprite_xoffset: integer
    sprite_yoffset: integer

    -- by default will just use a box with the size and shape
    -- returns a 2D unit vector that points from the middle of the collideable
    -- to the object
    collision_geometry: function(self: self, x: number, y: number) : {number}
end

local function rectangular_geometry(self: Collideable, x: number, y: number) : {number}
    if (x >= self.x and x <= self.x + self.size_x) then
        if x > self.x + self.size_x / 2 then
            return {[0] = 1, [1] = 0}
        else
            return {[0] = -1, [1] = 0}
        end
    end
    if (y >= self.y and y <= self.y + self.size_y) then
        return {[0] = 0, [1] = 1}
    end
    return nil
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
    instance.collision_geometry = rectangular_geometry

    return instance
end

function Collideable:collide(x: number, y: number) : {number}
    return self:collision_geometry(x, y)
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

-- takes the objects position and then calculates if there is a collision,
-- returning the unit vector direction from the collideable to the object, else
-- nil
function CollideableSlice:collide(x: number, y: number) : {number}
    for _, obj in ipairs(self.objects) do
        local col = obj:collide(x, y)
        if col then
            return col
        end
    end
    return nil
end

function CollideableSlice:draw(canvas: Canvas.SubCanvas, x: number, y: number)
    for _, obj in ipairs(self.objects) do
        obj:draw(canvas, x, y)
    end
end

return CollideableSlice
