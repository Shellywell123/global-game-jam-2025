require("shared.init")
local BackgroundSlice = require("game.backgroundslice")

local GAME_HEIGHT <const> = 6400
local TILE_SIZE <const> = 32

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
    for x=0,(config.displayWidth//TILE_SIZE) do
        for y=0,(GAME_HEIGHT//TILE_SIZE) do
            local tileIndex = math.random(0,3)
            instance.canvas.drawImage("dirt.png", tileIndex*TILE_SIZE, 0, TILE_SIZE, TILE_SIZE, x*TILE_SIZE, y*TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end
    end
    return instance
end

return Background
