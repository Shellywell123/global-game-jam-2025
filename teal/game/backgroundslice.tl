require("shared.init")
local CollideableSlice = require("game.collideable")

local TILE_SIZE <const> = 16
local SLICE_HEIGHT <const> = 16
global SLICE_HEIGHT_PX <const> = TILE_SIZE * SLICE_HEIGHT

local record BackgroundSlice
    canvas: Canvas.SubCanvas
    screenX: integer
    screenY: integer
    collision_slice: CollideableSlice
end

local BackgroundSliceMetatable: metatable<BackgroundSlice> = {
    __index = BackgroundSlice
}

function BackgroundSlice:draw()
    self.canvas.draw(0, math.floor(self.screenY))
    self.collision_slice:draw(self.canvas, 0, self.screenY)
end

function BackgroundSlice.new(y: integer): BackgroundSlice
    local instance: BackgroundSlice = {
        screenY = y
    }
    setmetatable(instance, BackgroundSliceMetatable)
    instance.canvas = Canvas.newCanvas(true)
    instance.collision_slice = CollideableSlice.new()
    for i=1,SLICE_HEIGHT do
        local leftTile = math.random(0, 3)
        local rightTile = math.random(0, 3)
    	instance.canvas.drawImage("pipe.png", leftTile*TILE_SIZE, 0, TILE_SIZE, TILE_SIZE, 0, (i-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
    	instance.canvas.drawImage("pipe.png", rightTile*TILE_SIZE, 0, TILE_SIZE, TILE_SIZE, config.displayWidth-TILE_SIZE, (i-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
    end
    return instance
end

return BackgroundSlice
