require("shared.init")
local CollideableSlice = require("game.collideable")

local PIPE_TILE_SIZE <const> = 16
local SLICE_HEIGHT <const> = 16
global SLICE_HEIGHT_PX <const> = PIPE_TILE_SIZE * SLICE_HEIGHT

local record BackgroundSlice
    canvas: Canvas.SubCanvas
    screenX: integer
    screenY: number
    collision_slice: CollideableSlice
end

local BackgroundSliceMetatable: metatable<BackgroundSlice> = {
    __index = BackgroundSlice
}

function BackgroundSlice:draw()
    self.canvas.draw(0, math.floor(self.screenY))
    self.collision_slice:draw(self.canvas)
end

function BackgroundSlice.new(y: integer, layout?: integer): BackgroundSlice
    local instance: BackgroundSlice = {
        screenY = y
    }
    setmetatable(instance, BackgroundSliceMetatable)
    instance.canvas = Canvas.newCanvas(true)

    instance.collision_slice = CollideableSlice.new(layout or math.random(1,5))
    for i=1,SLICE_HEIGHT do
        local leftTile = math.random(0, 3)
        local rightTile = math.random(0, 3)
        instance.canvas.drawImage("pipe.png", leftTile*PIPE_TILE_SIZE, 0, PIPE_TILE_SIZE, PIPE_TILE_SIZE, 0, (i-1)*PIPE_TILE_SIZE, PIPE_TILE_SIZE, PIPE_TILE_SIZE)
        instance.canvas.drawImage("pipe.png", rightTile*PIPE_TILE_SIZE, 0, PIPE_TILE_SIZE, PIPE_TILE_SIZE, config.displayWidth-PIPE_TILE_SIZE, (i-1)*PIPE_TILE_SIZE, PIPE_TILE_SIZE, PIPE_TILE_SIZE)
    end
    return instance
end

return BackgroundSlice
