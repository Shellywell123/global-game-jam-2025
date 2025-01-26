require("game.const")

local record Util
end

function Util.getColourForPlayerIndex(index: integer): string
    return PLAYER_COLOURS[((index-1) % #PLAYER_COLOURS + 1)]
end

return Util
