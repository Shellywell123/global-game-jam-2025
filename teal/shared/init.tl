print("Started initialising...")
global config: Config = {
    imageFilenames = {
        "bubble.png",
        "pipe.png",
        "dirt.png",
        "bubble.png",
        "dirt.png",
        "duck.png",
        "ring.png",
        "sock.png",
        "apple.png"
        "items.png"
    },
    luaFilenames = {
        "game/main.lua",
        "game/background.lua",
        "game/buttons.lua",
        "game/player.lua",
        "game/backgroundslice.lua",
        "game/collideable.lua",
        "shared/subprotocol.lua",
        "shared/init.lua"
    },
    blankColour = "black",
    pageBackgroundColour = "powderblue",
    displayWidth = 270,
    displayHeight = 480,
    spriteDimensions = 32,
    entryPoint = "game/main.lua"
}
print("Completed initialising...")
