function love.load()
    wf = require "libs/windfield"

    world = wf.newWorld(0, 500)
    player = world:newRectangleCollider(400, 500, 10, 10)
    player:setFixedRotation(true)

    normalPlatforms = {
        {x = 225, y = 550, w = 50, h = 10},
        {x = 100, y = 500, w = 50, h = 10},
        {x = 150, y = 445, w = 50, h = 10},
        {x = 300, y = 430, w = 20, h = 10},
        {x = 335, y = 425, w = 20, h = 10},
        {x = 375, y = 415, w = 20, h = 10},
        {x = 350, y = 355, w = 30, h = 10},
        {x = 550, y = 430, w = 30, h = 10},
        {x = 435, y = 245, w = 30, h = 10},
        {x = 285, y = 215, w = 120, h = 10},
    }

    bouncyPlatforms = {
        {x = 650, y = 430, w = 30, h = 10},
        {x = 700, y = 280, w = 30, h = 10},
        {x = 100, y = 210, w = 10, h = 10},
    }

    jumpThroughPlatforms = {
        {x = 285, y = 165, w = 50, h = 10},
        {x = 285, y = 115, w = 50, h = 10},
        {x = 10, y = 65, w = 100, h = 10},
    }

    -- Set collision classes
    world:addCollisionClass('Player')
    world:addCollisionClass('JumpThrough')

    -- Initialize the collider tables
    normalPlatformsColliders = {}
    bouncyPlatformsColliders = {}
    jumpThroughPlatformsColliders = {}

    for _, platformTable in ipairs({normalPlatforms, bouncyPlatforms, jumpThroughPlatforms}) do
        for _, platform in ipairs(platformTable) do
            local collider = world:newRectangleCollider(platform.x, platform.y, platform.w, platform.h)
            collider:setType("static")

            -- Populate the collider tables
            if platformTable == normalPlatforms then
                table.insert(normalPlatformsColliders, collider)
            elseif platformTable == bouncyPlatforms then
                table.insert(bouncyPlatformsColliders, collider)
            elseif platformTable == jumpThroughPlatforms then
                table.insert(jumpThroughPlatformsColliders, collider)
            end
        end
    end

    -- Set collision callbacks
    player:setCollisionClass('Player')
    for _, jumpThroughPlatformCollider in ipairs(jumpThroughPlatformsColliders) do
        jumpThroughPlatformCollider:setCollisionClass('JumpThrough')
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
    bottomWall = world:newRectangleCollider(0, 590, 800, 10)
    bottomWall:setType("static")

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

    -- Initialize the jump variable
    canJump = false

    -- Check if player is on the ground
    if player:isTouching(bottomWall.body) then
        canJump = true
    end

    -- Check if player is on normal platform
    for i, normalPlatformCollider in ipairs(normalPlatformsColliders) do
        if player:isTouching(normalPlatformCollider.body) then
            canJump = true
            break
        end
    end

    -- Check if player is on the bouncy platform
    for i, bouncyPlatformCollider in ipairs(bouncyPlatformsColliders) do
        if player:isTouching(bouncyPlatformCollider.body) then
            player:applyLinearImpulse(0, -50)
            break
        end
    end

    -- Check if player is on the jump-through platform
    for _, jumpThroughPlatformCollider in ipairs(jumpThroughPlatformsColliders) do
        if player:isTouching(jumpThroughPlatformCollider.body) then
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
