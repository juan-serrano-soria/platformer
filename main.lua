function love.load()
    wf = require "libs/windfield"

    world = wf.newWorld(0, 500)
    player = world:newRectangleCollider(400, 550, 10, 10)

    grounds = {
        world:newRectangleCollider(0, 590, 800, 10), -- bottom ground
        world:newRectangleCollider(225, 550, 50, 10),
        world:newRectangleCollider(100, 500, 50, 10),
        world:newRectangleCollider(150, 445, 50, 10),
        world:newRectangleCollider(300, 430, 20, 10),
        world:newRectangleCollider(335, 425, 20, 10),
        world:newRectangleCollider(375, 415, 20, 10),
        world:newRectangleCollider(350, 355, 30, 10),
    }

    for i, ground in ipairs(grounds) do
        ground:setType("static")
    end

    rightWall = world:newRectangleCollider(790, 0, 10, 600)
    rightWall:setType("static")
    leftWall = world:newRectangleCollider(0, 0, 10, 600)
    leftWall:setType("static")

    canJump = true
end

function love.update(dt)
    -- Player movement constrained by a max velocity
    local px, py = player:getLinearVelocity()
    if love.keyboard.isDown('left') and px > -150 then
        player:applyForce(-50, 0)
    elseif love.keyboard.isDown('right') and px < 150 then
        player:applyForce(50, 0)
    end

    -- Check if player is on the ground
    canJump = false
    for i, ground in ipairs(grounds) do
        if player:isTouching(ground.body) then
            canJump = true
            break
        end
    end

    -- Update the world physics
    world:update(dt)
end

function love.draw()
    -- Draw the colliders
    world:draw()
end

function love.keypressed(key)
    -- Player jump
    if key == "up" and canJump then
        player:applyLinearImpulse(0, -50)
        canJump = false
    end
end
