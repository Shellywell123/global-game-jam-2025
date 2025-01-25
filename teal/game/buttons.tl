local record Buttons
    canvas: Canvas.SubCanvas
end

local ButtonsMetatable: metatable<Buttons> = {
    __index = Buttons
}

function Buttons:draw()
    self.canvas.draw(0, 0)
end

function Buttons.new(): Buttons
    local instance: Buttons = {}
    setmetatable(instance, ButtonsMetatable)
    instance.canvas = Canvas.newCanvas(true)
    --  (path: string, sx: number, sy: number, /sw: number, sh: number, // sources
    -- dx: number, dy: number, dw: number, dh: number) //targets
    instance.canvas.drawImage("left-arrow.png", 0, 0, 512, 512, 0, 1728, 128, 128)
    instance.canvas.drawImage("right-arrow.png", 0, 0, 512, 512, 0, 1792, 128, 128)
    return instance
end

return Buttons
