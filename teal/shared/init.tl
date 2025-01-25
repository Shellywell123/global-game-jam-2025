print("Started initialising...")
global config: Config = {
    imageFilenames = {
        "pipe.png",
        "bubble.png",
        "dirt.png"
    },
    luaFilenames = {
        "game/main.lua",
        "game/background.lua",
        "game/player.lua",
        "game/backgroundslice.lua",
        "shared/subprotocol.lua",
        "shared/init.lua",
        "game/const.lua"
    },
    blankColour = "black",
    pageBackgroundColour = "powderblue",
    displayWidth = 270,
    displayHeight = 480,
    entryPoint = "game/main.lua"
}
print("Completed initialising...")
