print("Started initialising...")
global config: Config = {
    imageFilenames = {
        "bubble.png",
        "block.png"
    },
    luaFilenames = {
        "game/main.lua",
        "game/background.lua",
        "game/player.lua",
        "shared/subprotocol.lua",
        "shared/init.lua"
    },
    blankColour = "black",
    pageBackgroundColour = "powderblue",
    displayWidth = 270,
    displayHeight = 480,
    entryPoint = "game/main.lua"
}
print("Completed initialising...")
