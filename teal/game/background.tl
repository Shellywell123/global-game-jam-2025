require("shared.init")
require("game.const")
local BackgroundSlice = require("game.backgroundslice")

local GAME_HEIGHT <const> = 1024

local record Background
    canvas: Canvas.SubCanvas
    slices: {BackgroundSlice}
    y: number
end

local BackgroundMetatable: metatable<Background> = {
    __index = Background
}

function Background:step(dt: number)
    self.y = self.y + BACKGROUND_SPEED*dt
    for _,slice in ipairs(self.slices) do
        slice.screenY = slice.screenY + PIPE_SPEED*dt
    end
end

function Background:draw()
    self.canvas.draw(0,math.floor(self.y))
    for _, slice in ipairs(self.slices) do
        slice:draw()
    end
end

function Background.new(): Background
    local size = 64;
    local instance: Background = {
        y = config.displayHeight - GAME_HEIGHT
    }
    setmetatable(instance, BackgroundMetatable)
    instance.slices = {}
    for y=0,((PIPE_SPEED_RATIO*GAME_HEIGHT)//SLICE_HEIGHT_PX) do
        table.insert(instance.slices, BackgroundSlice.new((config.displayHeight-GAME_HEIGHT) - SLICE_HEIGHT_PX//2 + (y*SLICE_HEIGHT_PX)))
    end
    instance.canvas = Canvas.newCanvas(false, GAME_HEIGHT)
    for x=0,(config.displayWidth//TILE_SIZE) do
        for y=0,(GAME_HEIGHT//TILE_SIZE) do
            local tileIndex = math.random(0,3)
            instance.canvas.drawImage("dirt.png", tileIndex*TILE_SIZE, 0, TILE_SIZE, TILE_SIZE, x*TILE_SIZE, y*TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end
    end
    return instance
end

return Background
