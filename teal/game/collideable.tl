require("shared.init")

local DEGREES_TO_RADIANS <const> = 3.1415 / 180

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
    -- assumes the object that is being considered is a circle
    collision_geometry: function(self: self, x: number, y: number, squared_radius: number) : {number}
end

local function squared_distance(x: number, y: number, other_x: number, other_y: number) : number
end

local function signum(x : number) : number
   if x > 0 then
      return 1
   elseif x < 0 then
      return -1
   else
      return 0
   end
end

local function rectangular_geometry(self: Collideable, x: number, y: number, squared_radius: number) : {number}
    -- calculate the closet point
    local X = math.max(self.x, math.min(x, self.x + self.size_x))
    local Y = math.max(self.y, math.min(y - 1, self.y + self.size_y))

    local dx = X - x
    local dy = Y - y

    local d =  dx*dx + dy*dy

    if d < squared_radius then
        if math.abs(dx) > math.abs(dy) then
            return {[0] = signum(dx), [1] = 0 }
        else
            return {[0] = 0, [1] = signum(dy) }
        end
    end

    return nil
end

local CollideableMetatable: metatable<Collideable> = {
    __index = Collideable,
 }

function Collideable.new(): Collideable
    local instance: Collideable = {}
    setmetatable(instance, CollideableMetatable)
    instance.x = 50
    instance.y = 200

    instance.size_x = 32
    instance.size_y = 16

    instance.sprite_yoffset = 0
    instance.sprite_xoffset = 0

    instance.sprite = "items.png"
    instance.collision_geometry = rectangular_geometry

    return instance
end

function Collideable:collide(x: number, y: number, squared_radius: number) : {number}
    return self:collision_geometry(x, y, squared_radius)
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
function CollideableSlice:collide(x: number, y: number, squared_radius: number) : {number}
    for _, obj in ipairs(self.objects) do
        local col = obj:collide(x, y, squared_radius)
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
