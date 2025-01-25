print("Started initialising...")
global config: Config = {
    imageFilenames = {
        "left-arrow.png",
        "right-arrow.png",
        "bubble.png",
        "pipe.png",
        "bubble.png"
    },
    luaFilenames = {
        "game/main.lua",
        "game/background.lua",
        "game/buttons.lua",
        "game/player.lua",
        "game/backgroundslice.lua",
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
