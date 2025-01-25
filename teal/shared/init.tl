print("Started initialising...")
global config: Config = {
    imageFilenames = {
        "guy.png",
        "block.png"
    },
    luaFilenames = {
        "game/main.lua",
        "game/background.lua",
        "game/character.lua",
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
