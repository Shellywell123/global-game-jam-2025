require("shared.init")

local record Buttons
    canvas: Canvas.SubCanvas
end

local size <const> = 64;

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
    instance.canvas.drawImage("left-arrow.png", 0, 0, 512, 512, 0, config.displayHeight - size, size, size)
    instance.canvas.drawImage("right-arrow.png", 0, 0, 512, 512, config.displayWidth - size, config.displayHeight - size, size, size)
    return instance
end


-- function Buttons:onClicked(x: number, y: number): number

--     if (y > config.displayHeight - size) then
        
--         if (x < size ) then -- left button pressed
--             print("Left button clicked")
--             -- character.spriteIndex = 0
--             return -1
        
--         elseif (x > config.displayWidth - size ) then -- right button pressed
--             print("Right button clicked")
--             return 1
--         end
--     end
--     return 0
-- end


return Buttons
