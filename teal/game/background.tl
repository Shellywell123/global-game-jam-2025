require("shared.init")
local BackgroundSlice = require("game.backgroundslice")

local record Background
    canvas: Canvas.SubCanvas
    slices: {BackgroundSlice}
end

local BackgroundMetatable: metatable<Background> = {
    __index = Background
}

function Background:draw()
    self.canvas.draw(0,0)
    for _, slice in ipairs(self.slices) do
        slice:draw()
    end
end

function Background.new(): Background
    local size = 64;
    local instance: Background = {}
    setmetatable(instance, BackgroundMetatable)
    instance.slices = {BackgroundSlice.new()}
    instance.canvas = Canvas.newCanvas(false)
    return instance
end

return Background
