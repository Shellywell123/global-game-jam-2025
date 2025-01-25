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
        "shared/subprotocol.lua"
    },
    blankColour = "black",
    pageBackgroundColour = "powderblue",
    displayWidth = 1080,
    displayHeight = 1920,
    entryPoint = "game/main.lua"
}
print("Completed initialising...")
