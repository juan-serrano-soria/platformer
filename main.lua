function love.load()
    wf = require "libs/windfield"
    camera = require "libs/camera"

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

    -- Border walls
    walls = {
        {x = 790, y = 0, w = 10, h = 600},
        {x = 0, y = 0, w = 10, h = 600},
        {x = 0, y = 0, w = 800, h = 10},
        {x = 0, y = 590, w = 800, h = 10},
    }

    for _, wall in ipairs(walls) do
        local collider = world:newRectangleCollider(wall.x, wall.y, wall.w, wall.h)
        collider:setType("static")
    end

    bottomWall = world:newRectangleCollider(0, 590, 800, 10)
    bottomWall:setType("static")

    win = {x = 10, y = 55, w = 10, h = 10}
    winCollider = world:newRectangleCollider(win.x, win.y, win.w, win.h)

    -- Set the font and text for win message
    winFont = love.graphics.setNewFont(50)
    winTextContent = ""
    winText = love.graphics.newText(winFont, winTextContent)

    -- Initialize winning variables
    winTime = 0
    hasWon = false

    canJump = true

    -- Set the camera
    cam = camera(player:getX(), player:getY())
    cam:zoom(1.5)
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

    -- Winning
    if player:isTouching(winCollider.body) and not hasWon then
        winText:set("You Win!")  -- Set the win text
        hasWon = true  -- Set the hasWon flag to true
        -- Reset the camera's position and zoom level
        cam:lookAt(800 / 2, 600 / 2)  -- Center the camera on the map
        cam:zoomTo(1)
    end
    if hasWon then
        winTime = winTime + dt  -- Increment the win timer by the elapsed time
        if winTime >= 3 then
            player:setPosition(400, 500)  -- Reset player position
            winTime = 0  -- Reset the win timer
            winText:set("")  -- Remove the win text
            hasWon = false  -- Reset the hasWon flag
            cam:zoomTo(1.5) -- Reset the zoom level
        end
    end

    -- Update the camera
    if not hasWon then
        cam:lookAt(player:getX(), player:getY())
    end

    -- Update the world physics
    world:update(dt)
end

function love.draw()
    -- Set the camera
    if not hasWon then
        cam:attach()
    end

    -- Draw the player
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', player:getX() - 5, player:getY() - 5, 10, 10)

    -- Draw the normal platforms
    love.graphics.setColor(165/255, 42/255, 42/255)
    for i, normalPlatform in ipairs(normalPlatforms) do
        love.graphics.rectangle('fill', normalPlatform.x, normalPlatform.y, normalPlatform.w, normalPlatform.h)
    end

    -- Draw the bouncy platforms
    love.graphics.setColor(0, 1, 0)
    for i, bouncyPlatform in ipairs(bouncyPlatforms) do
        love.graphics.rectangle('fill', bouncyPlatform.x, bouncyPlatform.y, bouncyPlatform.w, bouncyPlatform.h)
    end

    -- Draw the jump-through platforms
    love.graphics.setColor(173/255, 216/255, 230/255)
    for i, jumpThroughPlatform in ipairs(jumpThroughPlatforms) do
        love.graphics.rectangle('fill', jumpThroughPlatform.x, jumpThroughPlatform.y, jumpThroughPlatform.w, jumpThroughPlatform.h)
    end

    -- Draw the border walls
    love.graphics.setColor(153/255, 153/255, 0/255)
    for i, wall in ipairs(walls) do
        love.graphics.rectangle('fill', wall.x, wall.y, wall.w, wall.h)
    end

    -- Draw the win area
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle('fill', win.x, win.y, win.w, win.h)

    -- Set the font and print win message
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(winFont)
    local text_width, text_height = winText:getDimensions()
    local x = (800 - text_width) / 2
    local y = (600 - text_height) / 2
    love.graphics.draw(winText, x, y)

    -- Reset the camera
    if not hasWon then
        cam:detach()
    end
end

function love.keypressed(key)
    -- Player jump
    if key == "up" and canJump then
        player:applyLinearImpulse(0, -50)
        canJump = false
    end
end
