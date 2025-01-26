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
        "apple.png",
        "items.png",
        "arrow.png",
        "controls.png"
    },
    luaFilenames = {
        "game/main.lua",
        "game/background.lua",
        "game/buttons.lua",
        "game/player.lua",
        "game/otherplayers.lua",
        "game/bubble.lua",
        "game/util.lua",
        "game/backgroundslice.lua",
        "game/collideable.lua",
        "shared/subprotocol.lua",
        "shared/protocols.lua",
        "shared/patterns.lua",
        "shared/init.lua",
        "game/const.lua",
        "game/startbackground.lua",
        "game/states/main.lua",
        "game/states/start.lua",
        "game/states/loading.lua",
        "game/states/end.lua",
        "game/endbackground.lua"
    },
    audioFilenames = {
        ["menu.mp3"] = true
    },
    blankColour = "black",
    pageBackgroundColour = "powderblue",
    displayWidth = 270,
    displayHeight = 480,
    spriteDimensions = 32,
    entryPoint = "game/main.lua"
}
print("Completed initialising...")
