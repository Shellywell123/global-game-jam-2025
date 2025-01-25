require("shared.init")

local TILE_SIZE <const> = 16

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
    -- TODO: generate multiple pipes
    instance.canvas.drawImage("pipe.png", 0, 0, 16, 16, 0, 0, 16, 16)
    return instance
end

return BackgroundSlice
