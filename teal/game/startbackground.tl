require("shared.init")
require("game.const")

local record StartBackground
    canvas: Canvas.SubCanvas
end

local StartBackgroundMetatable: metatable<StartBackground> = {
    __index = StartBackground
}

function StartBackground:step(dt: number)
    -- no-op
end

function StartBackground:draw()
    self.canvas.draw(0,0)
end

function StartBackground.new(): StartBackground
    local instance: StartBackground = {}
    setmetatable(instance, StartBackgroundMetatable)
    instance.canvas = Canvas.newCanvas(false)
    for x=0,(config.displayWidth//TILE_SIZE) do
        for y=0,(config.displayHeight//TILE_SIZE) do
            local tileIndex = math.random(0,3)
            instance.canvas.drawImage("dirt.png", tileIndex*TILE_SIZE, 0, TILE_SIZE, TILE_SIZE, x*TILE_SIZE, y*TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end
    end
    instance.canvas.drawImage("arrow.png", 0, 0, 64, 64, ((config.displayWidth // 2) - 32), 16, 64, 64)
    return instance
end

return StartBackground
