require("shared.init")
local type Vector2D = require("game.vector2d")

local DEGREES_TO_RADIANS <const> = 3.1415 / 180

local record Collideable
    x: number
    y: number
    size_x: number
    size_y: number
    offset_y: number
    sprite: string
    sprite_xoffset: integer
    sprite_yoffset: integer
    can_pop: boolean

    -- by default will just use a box with the size and shape
    -- returns a 2D unit vector that points from the middle of the collideable
    -- to the object
    -- assumes the object that is being considered is a circle
    collision_geometry: function(self: self, x: number, y: number, squared_radius: number) : Vector2D
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

local function line_circle_at_origin_determinant(x1: number, x2: number, y1: number, y2: number, squared_radius: number) : Vector2D

    local dx = x2 - x1
    local dy = y2 - y1
    local dr2 = (dx * dx) + (dy * dy)
    local determinant = x1 * y2 - y1 * x2

    local discriminant =  squared_radius * dr2 - (determinant * determinant)

    if discriminant <= 0 then
        return nil
    end

    local X = (determinant * dy + signum(dy) * dx * math.sqrt(discriminant)) / dr2
    local Y = (-determinant * dx + math.abs(dy) * math.sqrt(discriminant)) / dr2

    if (X >= x1 - 1) and (X <= x2 + 1) and (Y >= y1 - 1) and (Y <= y2 + 1) then
        return {x = X, y = Y}
    end
    return nil
end

local function line_circle_intersection(line_p1: Vector2D, line_p2: Vector2D, x_circ: number, y_circ: number, squared_radius: number) : Vector2D
    return line_circle_at_origin_determinant(
        line_p1.x - x_circ,
        line_p2.x - x_circ,
        line_p1.y - y_circ,
        line_p2.y - y_circ,
        squared_radius
    )
end

local function to_basis_vector(v: Vector2D) : Vector2D
    if math.abs(v.x) > math.abs(v.y) then
        return {x = signum(v.x), y = 0 }
    else
        return {x = 0, y = signum(v.y) }
    end
end


local function rectangular_geometry(self: Collideable, x: number, y: number, squared_radius: number) : Vector2D
    local d = line_circle_intersection(
        {
            x = self.x,
            y = self.y + self.size_y
        },{
            x = self.x + self.size_x,
            y = self.y + self.size_y
        },
        x,
        y - self.offset_y,
        squared_radius
    )

    if d then
        return to_basis_vector(d)
    end

    d = line_circle_intersection(
        {x = self.x, y = self.y},
        {x = self.x, y = self.y + self.size_y},
        x,
        y - self.offset_y,
        squared_radius
    )

    if d then
        return to_basis_vector(d)
    end

    d = line_circle_intersection(
        {x = self.x + self.size_x, y = self.y},
        {x = self.x + self.size_x, y = self.y + self.size_y},
        x,
        y - self.offset_y,
        squared_radius
    )

    if d then
        return to_basis_vector(d)
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
    instance.offset_y = 0

    instance.size_x = 32
    instance.size_y = 16

    instance.sprite_yoffset = 0
    instance.sprite_xoffset = 0

    instance.sprite = "items.png"
    instance.collision_geometry = rectangular_geometry
    instance.can_pop = false

    return instance
end

function Collideable:collide(x: number, y: number, squared_radius: number) : Vector2D
    return self:collision_geometry(x, y, squared_radius)
end

function Collideable:draw(canvas: Canvas.SubCanvas)
    canvas.drawImage(
        self.sprite,
        self.sprite_xoffset * config.spriteDimensions,
        self.sprite_yoffset * config.spriteDimensions,
        self.size_x,
        self.size_y,
        self.x,
        self.y,
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

local function layout1(instance: CollideableSlice)
    table.insert(instance.objects, Collideable.new())
    table.insert(instance.objects, Collideable.new())
    instance.objects[2].x = 32
    table.insert(instance.objects, Collideable.new())
    instance.objects[3].x = 64
    table.insert(instance.objects, Collideable.new())
    instance.objects[4].x = 96

    table.insert(instance.objects, Collideable.new())
    instance.objects[4].x = 224
    instance.objects[4].sprite_xoffset = 1
    instance.objects[4].can_pop = true
end

local LAYOUT_FUNCTIONS <const> = {
    layout1, layout1
}


function CollideableSlice.new(layout: integer): CollideableSlice
    local instance: CollideableSlice = {}
    setmetatable(instance, CollideableSliceMetatable)
    instance.objects = {}

    if layout ~= 0 then
        LAYOUT_FUNCTIONS[layout](instance)
    end

    return instance
end

-- takes the objects position and then calculates if there is a collision,
-- returning the unit vector direction from the collideable to the object, else
-- nil
function CollideableSlice:collide(offset_y: number, x: number, y: number, squared_radius: number) : {Vector2D, boolean}
    for _, obj in ipairs(self.objects) do
        obj.offset_y = offset_y
        local col = obj:collide(x, y, squared_radius)
        if col then
            return {col, obj.can_pop}
        end
    end
    return nil
end

function CollideableSlice:draw(canvas: Canvas.SubCanvas)
    for _, obj in ipairs(self.objects) do
        obj:draw(canvas)
    end
end

return CollideableSlice
