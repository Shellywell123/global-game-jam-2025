require("shared.init")
local BackgroundSlice = require("game.backgroundslice")

local GAME_HEIGHT <const> = 25600
local TILE_SIZE <const> = 32
local SPEED = 0.03

local record Background
    canvas: Canvas.SubCanvas
    slices: {BackgroundSlice}
    y: number
end

local BackgroundMetatable: metatable<Background> = {
    __index = Background
}

function Background:step(dt: number)
    self.y = self.y + SPEED*dt
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
    instance.slices = {BackgroundSlice.new()}
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
