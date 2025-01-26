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

local enum BlockType
    "Needle"
end

function Collideable.new(x?: number, y?: number, typ?: BlockType): Collideable
    local instance: Collideable = {}
    setmetatable(instance, CollideableMetatable)
    instance.x = x or 0
    instance.y = y or 0
    instance.offset_y = 0

    instance.size_x = 32
    instance.size_y = 16

    instance.sprite_yoffset = 0
    instance.sprite_xoffset = 0
    instance.can_pop = false

    if typ == "Needle" then
        instance.sprite_xoffset = 1
        instance.can_pop = true
    end

    instance.sprite = "items.png"
    instance.collision_geometry = rectangular_geometry

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

local TILE_CONST <const> = 16;

local function layout1(instance: CollideableSlice)
    table.insert(instance.objects, Collideable.new(32, 40))
    table.insert(instance.objects, Collideable.new(64, 40))
    table.insert(instance.objects, Collideable.new(96, 40, "Needle"))

    table.insert(instance.objects, Collideable.new(192))
    table.insert(instance.objects, Collideable.new(224))
end

local function layout2(instance: CollideableSlice)
    table.insert(instance.objects, Collideable.new(64, 100))
    table.insert(instance.objects, Collideable.new(96, 100))
    table.insert(instance.objects, Collideable.new(128, 100))

    table.insert(instance.objects, Collideable.new(96))
    table.insert(instance.objects, Collideable.new(128))
    table.insert(instance.objects, Collideable.new(160))
end

local function layout3(instance: CollideableSlice)
    table.insert(instance.objects, Collideable.new(16, 42, "Needle"))
    table.insert(instance.objects, Collideable.new(224, 42, "Needle"))

    table.insert(instance.objects, Collideable.new(16))
    table.insert(instance.objects, Collideable.new(48))
    table.insert(instance.objects, Collideable.new(80))
    table.insert(instance.objects, Collideable.new(224))
    table.insert(instance.objects, Collideable.new(208))
    table.insert(instance.objects, Collideable.new(176))
end

local function layout4(instance: CollideableSlice)
    table.insert(instance.objects, Collideable.new(224, 42, "Needle"))
    table.insert(instance.objects, Collideable.new(292, 42, "Needle"))

    table.insert(instance.objects, Collideable.new(16))
    table.insert(instance.objects, Collideable.new(48, 0))
    table.insert(instance.objects, Collideable.new(48, 16))
end

local function layout5(instance: CollideableSlice)
    table.insert(instance.objects, Collideable.new(128, 64, "Needle"))
    table.insert(instance.objects, Collideable.new(160, 64, "Needle"))
end

local LAYOUT_FUNCTIONS <const> = {
    layout1, layout2, layout3, layout4, layout5
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
