require("shared.init")
require("game.const")

local record EndBackground
    canvas: Canvas.SubCanvas
end

local EndBackgroundMetatable: metatable<EndBackground> = {
    __index = EndBackground
}

function EndBackground:step()
end

function EndBackground:draw()
    self.canvas.draw(0,0)
end

function EndBackground.new(): EndBackground
    local instance: EndBackground = {}
    setmetatable(instance, EndBackgroundMetatable)
    instance.canvas = Canvas.newCanvas(false)
    for x=0, (config.displayWidth//TILE_SIZE) do
        for y=0, (config.displayHeight//TILE_SIZE) do
            local tileIndex = math.random(0,3) -- ?
            instance.canvas.drawImage("duck.png", tileIndex*TILE_SIZE, 0, TILE_SIZE, TILE_SIZE, x*TILE_SIZE, y*TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end -- or different image
    end
    return instance
end

return EndBackground