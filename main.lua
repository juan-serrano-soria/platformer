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
        world:newRectangleCollider(550, 430, 30, 10),
        world:newRectangleCollider(435, 245, 30, 10),
        world:newRectangleCollider(285, 215, 120, 10),
    }

    bouncyGrounds = {
        world:newRectangleCollider(650, 430, 30, 10),
        world:newRectangleCollider(700, 280, 30, 10),
        world:newRectangleCollider(100, 210, 10, 10),
    }

    jumpThroughGrounds = {
        world:newRectangleCollider(285, 165, 50, 10),
        world:newRectangleCollider(285, 115, 50, 10),
        world:newRectangleCollider(10, 65, 100, 10),
    }

    -- Set collision classes
    world:addCollisionClass('Player')
    world:addCollisionClass('JumpThrough')

    for _, groundTable in ipairs({grounds, bouncyGrounds, jumpThroughGrounds}) do
        for _, ground in ipairs(groundTable) do
            ground:setType("static")
        end
    end

    -- Set collision callbacks
    player:setCollisionClass('Player')
    for _, ground in ipairs(jumpThroughGrounds) do
        ground:setCollisionClass('JumpThrough')
    end

    -- Set pre-solve callback for jump-through platforms
    player:setPreSolve(function(collider_1, collider_2, contact)
        if collider_1.collision_class == 'Player' and collider_2.collision_class == 'JumpThrough' then
            local _, vy = collider_1:getLinearVelocity()
            if vy < 0 then
                contact:setEnabled(false) -- If player is moving down, disable the collision
            else
                contact:setEnabled(true) -- If player is moving up, enable the collision
            end
        end
    end)

    rightWall = world:newRectangleCollider(790, 0, 10, 600)
    rightWall:setType("static")
    leftWall = world:newRectangleCollider(0, 0, 10, 600)
    leftWall:setType("static")
    topWall = world:newRectangleCollider(0, 0, 800, 10)
    topWall:setType("static")

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

    -- Check if player is on the bouncy ground
    for i, ground in ipairs(bouncyGrounds) do
        if player:isTouching(ground.body) then
            player:applyLinearImpulse(0, -50)
            break
        end
    end

    -- Check if player is on the jump-through ground
    for _, ground in ipairs(jumpThroughGrounds) do
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
