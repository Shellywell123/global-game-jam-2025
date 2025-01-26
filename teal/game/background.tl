require("shared.init")
require("game.const")
local BackgroundSlice = require("game.backgroundslice")

local NUM_BLANKS <const> = 1
local NUM_SECTIONS <const> = 10

local record Background
    canvas: Canvas.SubCanvas
    slices: {BackgroundSlice}
    y: number
    game_height: number
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
    self.canvas.draw(0, math.floor(self.y - (self.game_height - 2 * config.displayHeight)))
    for _, slice in ipairs(self.slices) do
        slice:draw()
    end
end

function Background.new(): Background
    local game_height = SLICE_HEIGHT_PX * (NUM_BLANKS + NUM_SECTIONS)
    local instance: Background = {
        y = 0,
        game_height = game_height
    }
    setmetatable(instance, BackgroundMetatable)
    instance.slices = {}
    -- then we start randomizing the map
    for i = 1,NUM_BLANKS do
        table.insert(instance.slices, BackgroundSlice.new(config.displayHeight - SLICE_HEIGHT_PX * i, 0))
    end
    for i = 1,NUM_SECTIONS do
        table.insert(instance.slices, BackgroundSlice.new(config.displayHeight - SLICE_HEIGHT_PX * (NUM_BLANKS + i)))
    end
    -- for y=0,num_sections do
    --     table.insert(instance.slices, BackgroundSlice.new((config.displayHeight-GAME_HEIGHT) - SLICE_HEIGHT_PX//2 + (y * SLICE_HEIGHT_PX), nil))
    -- end
    -- -- then we add some blank slices
    -- for y=0, NUM_BLANKS do
    --     table.insert(instance.slices, BackgroundSlice.new((config.displayHeight-GAME_HEIGHT) - SLICE_HEIGHT_PX//2 + ((num_sections + y)*SLICE_HEIGHT_PX), 0))
    -- end
    instance.canvas = Canvas.newCanvas(false, game_height)
    for x=0, (config.displayWidth//TILE_SIZE) do
        for y=0, (game_height//TILE_SIZE) do
            local tileIndex = math.random(0,3)
            instance.canvas.drawImage("dirt.png", tileIndex*TILE_SIZE, 0, TILE_SIZE, TILE_SIZE, x*TILE_SIZE, y*TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end
    end
    return instance
end

return Background
