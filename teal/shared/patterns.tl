local protocols = require("shared.protocols")

return {
    lobbyPos = protocols.lobbyPos .. " (-?%d+) (-?%d+) (%d+)", -- x, y, playerId
    gamePos = protocols.gamePos .. " (%d+)", -- playerId (header row)
    gamePosLine = "|(-?%d+) (-?%d+) (%d+) (-?%d+)" -- x, y, size, invulnerableTime
}
