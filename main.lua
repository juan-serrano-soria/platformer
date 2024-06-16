function love.load()
    wf = require "libs/windfield"

    world = wf.newWorld(0, 500)

    player = world:newRectangleCollider(350, 100, 80, 80)
    ground = world:newRectangleCollider(100, 400, 600, 100)
    ground:setType("static")

    canJump = true
end

function love.update(dt)
    -- Player movement constrained by a max velocity
    local px, py = player:getLinearVelocity()
    if love.keyboard.isDown('left') and px > -300 then
        player:applyForce(-5000, 0)
    elseif love.keyboard.isDown('right') and px < 300 then
        player:applyForce(5000, 0)
    end
    -- Check if player is on the ground
    canJump = false
    if player:isTouching(ground.body) then
        canJump = true
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
        player:applyLinearImpulse(0, -5000)
        canJump = false
    end
end
