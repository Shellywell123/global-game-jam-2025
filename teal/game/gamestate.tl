local interface GameState
    step: function(dt: number)
    draw: function()
    keyUp: function(key: string)
    keyDown: function(key: string)
    keyPress: function(key: string)
    pointerDown: function()
    pointerUp: function()
end

return GameState
