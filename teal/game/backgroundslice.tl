require("shared.init")

local TILE_SIZE <const> = 16
local SLICE_HEIGHT <const> = 16

local record BackgroundSlice
    canvas: Canvas.SubCanvas
    screenX: integer
    screenY: integer
end

local BackgroundSliceMetatable: metatable<BackgroundSlice> = {
    __index = BackgroundSlice
}

function BackgroundSlice:draw()
    self.canvas.draw(0, 0)
end

function BackgroundSlice.new(): BackgroundSlice
    local instance: BackgroundSlice = {}
    setmetatable(instance, BackgroundSliceMetatable)
    instance.canvas = Canvas.newCanvas(true)
    for i=1,SLICE_HEIGHT do
    	instance.canvas.drawImage("pipe.png", 0, 0, TILE_SIZE, TILE_SIZE, 0, (i-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
    	instance.canvas.drawImage("pipe.png", 0, 0, TILE_SIZE, TILE_SIZE, config.displayWidth-TILE_SIZE, (i-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
    end
    return instance
end

return BackgroundSlice
