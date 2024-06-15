function love.load()
    wf = require "libs/windfield"

    world = wf.newWorld(0, 500)

    player = world:newRectangleCollider(350, 100, 80, 80)
    
end

function love.update(dt)
    -- Update the world physics
    world:update(dt)
end

function love.draw()
    -- Draw the colliders
    world:draw()
end
