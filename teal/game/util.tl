require("game.const")

local record Util
end

function Util.getColourForPlayerIndex(index: integer): string
    return PLAYER_COLOURS[(index % #PLAYER_COLOURS) + 1]
end

return Util
