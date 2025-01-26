require("shared.init")
require("game.const")
local BackgroundSlice = require("game.backgroundslice")

local NUM_BLANKS <const> = 1
local NUM_SECTIONS <const> = 2

local record Background
    canvas: Canvas.SubCanvas
    slices: {BackgroundSlice}
    slice_count: integer
    y: number
    game_height: number
    mapstack: {integer}
end

local BackgroundMetatable: metatable<Background> = {
    __index = Background
}

function Background:step(dt: number)
    self.y = self.y + BACKGROUND_SPEED*dt

    if self.y > (self.game_height - 2 * config.displayHeight) then
        self.y = 0
    end

    for i, slice in ipairs(self.slices) do
        slice.screenY = slice.screenY + PIPE_SPEED*dt
    end

    -- do we need to unload a slice?
    local i = 1
    while (i <= #self.slices) do
        local slice = self.slices[i]
        if slice.screenY > config.displayHeight then
            -- for each slice we unload we'll add a new one to the top
            local typ = table.remove(self.mapstack)
            table.insert(self.slices, BackgroundSlice.new(config.displayHeight - SLICE_HEIGHT_PX * self.slice_count, typ))
            table.remove(self.slices, i)
        else
            i = i + 1
        end
    end
end

function Background:draw()
    self.canvas.draw(0, math.floor(self.y - (self.game_height - 2 * config.displayHeight)))
    for _, slice in ipairs(self.slices) do
        slice:draw()
    end
end

function Background.new(): Background
    math.randomseed(42)
    local game_height = SLICE_HEIGHT_PX * (NUM_BLANKS + NUM_SECTIONS) + 1024
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
    instance.canvas = Canvas.newCanvas(false, game_height)
    for x=0, (config.displayWidth//TILE_SIZE) do
        for y=0, (game_height//TILE_SIZE) do
            local tileIndex = math.random(0,3)
            instance.canvas.drawImage("dirt.png", tileIndex*TILE_SIZE, 0, TILE_SIZE, TILE_SIZE, x*TILE_SIZE, y*TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end
    end

    -- populate the stack of the map
    local mapstack = {}
    for i = 1,1024 do
        table.insert(mapstack, math.random(1,5))
    end
    instance.mapstack = mapstack
    instance.slice_count = NUM_BLANKS + NUM_SECTIONS
    return instance
end

return Background
