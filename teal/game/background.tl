require("shared.init")

local record Background
    canvas: Canvas.SubCanvas
end

local BackgroundMetatable: metatable<Background> = {
    __index = Background
}

function Background:draw()
    self.canvas.draw(0, 0)
end

function Background.new(): Background
    local size = 64;
    local instance: Background = {}
    setmetatable(instance, BackgroundMetatable)
    instance.canvas = Canvas.newCanvas(false)
    instance.canvas.drawImage("block.png", 0, 0, size, size, size, config.displayHeight - size, size, size)
    return instance
end

return Background
