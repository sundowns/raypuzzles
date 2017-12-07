local rays = {}
local newRayX = nil
local newRayY = nil
local mouseObstacle = nil
local currentStage = 1
local stageManager = {}

-- GLobal cause trust
world = {}
camera = nil
debug = false
raysRemaining = 0

-- Add to a constants file
PARTICLE_RADIUS = 8
MAP_WIDTH = 0
MAP_HEIGHT = 0

function love.load()
    initPhysics()
    math.randomseed(os.time())
    Vector = require "libs.vector"
    Class = require "libs.class"
    Camera = require "libs.camera"
    Timer = require "libs.timer"
    --HC = require "libs.HC"
    require("src.util")
    require("src.ray")
    require("src.obstacle")
    require("src.stagemanager")
    paused = false
    gameOver = false
    love.graphics.setBackgroundColor(0,0,0,255)
    stageManager = StageManager()
    MAP_WIDTH, MAP_HEIGHT = stageManager:getStageDimensions()
    camera = Camera(MAP_WIDTH/2, MAP_HEIGHT/2, 0.6, 0)
    print("=====[CONTROLS]=====")
    print("MOUSE1: Place a ray (hold and release)")
    print("SPACE: Pause")
    print("WASD/Arrows: Move camera")
    print("F1: Toggle Debug")
    print("F2: Restart level")
    print("==========")
end

function love.update(dt)
    if not paused then
        world:update(dt)
        stageManager:update(dt)
        for i=#rays,1,-1 do --back to front so we can safely remove (https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating)
            local entity = rays[i]
            local kill = entity:update(dt)
            if kill then
                entity.body:destroy()
                table.remove(rays, i)
            end
        end
    end

    if love.keyboard.isDown("left", "a") then camera:move(-1, 0) end
    if love.keyboard.isDown("up", "w") then camera:move(0, -1) end
    if love.keyboard.isDown("right", "d") then camera:move(1, 0) end
    if love.keyboard.isDown("down", "s") then camera:move(0,1) end
end

function love.draw()
    camera:attach()
    --WORLD
    reset_colour()
    stageManager:drawObstacles()
    for i, entity in ipairs(rays) do
        entity:drawParticles()
    end
    for i, entity in ipairs(rays) do
        entity:draw()
    end
    if (newRayX and newRayY) then
        love.graphics.setColor(0, 0, 0,255)
        love.graphics.circle('fill', newRayX, newRayY, 5)
    end

    if debug then
        love.graphics.setColor(255,0,0)
        love.graphics.circle('fill', 0, 0, 3)
    end
    reset_colour()
    camera:detach()

    --UI / OVERLAY
    if raysRemaining == 0 then
        love.graphics.setColor(255,0,0)
    elseif raysRemaining < stageManager.loadedStage.raysAllowed/2 then
        love.graphics.setColor(255,255,0)
    else
        love.graphics.setColor(0,255,0)
    end
    love.graphics.print(raysRemaining.." rays remaining", 10, love.graphics.getHeight()-20)

    if gameOver then
        love.graphics.setColor(0,255,0)
        love.graphics.print("You win! Press SPACE to continue", love.graphics.getWidth()/2 - 120, love.graphics.getHeight()/2 - 20)
    end

    if paused and not gameOver then
        love.graphics.setColor(255,0,0)
        love.graphics.print("P A U S E D", love.graphics.getWidth()/2 - 50, love.graphics.getHeight()/2)
    end

    if debug then
        love.graphics.setColor(255,0,0)
        love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
        love.graphics.print("debug",love.graphics.getWidth()-44,5)
    end
    reset_colour()
end

function love.keypressed(key, scancode, isrepeat)
    if key == "space" then
        if gameOver then
            nextStage()
        end
        paused = not paused
    elseif key == "f1" then
        debug = not debug
    elseif key == "f2" then
        love.event.quit("restart")
    elseif key == "f3" then
        nextStage()
    end
end

function love.mousepressed(x, y, button, isTouch)
    if not paused then
        local camX, camY = camera:worldCoords(x, y)
        if button == 1 then
            if stageManager:testPointForSpawning(camX, camY) and raysRemaining > 0 then
                newRayX = camX
                newRayY = camY
            end
        end
    end
end

function love.mousereleased(x, y, button, isTouch)
    local camX, camY = camera:worldCoords(x, y)
    if not paused then
        if newRayX and newRayY then
            if (newRayX ~= camX or newRayY ~= camY) then
                rays[#rays+1] = Ray(newRayX, newRayY, camX, camY, PARTICLE_RADIUS)
                raysRemaining = raysRemaining - 1
            end
            newRayX = nil
            newRayY = nil
        end
    end
end

--A always seems to be obstacle, B the ray
function beginContact(a, b, coll)
    local data = a:getUserData()
    local data2 = b:getUserData()
    if data then
        if data.isGoal then
            goalHit()
        elseif data.isTrap then
            local ray = data2.ray
            ray:markForDeath()
        end
    elseif data2 then
        data2.ray:emitCollisionParticles()
    end
end

function endContact(a, b, coll)

end

function initPhysics()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0,0,true)
    world:setCallbacks(beginContact, endContact)
end

function nextStage()
    initPhysics()
    rays = {}
    newRayX = nil
    newRayY = nil
    stageManager:nextStage()
    gameOver = false
    MAP_WIDTH, MAP_HEIGHT = stageManager:getStageDimensions()
    camera:lookAt(MAP_WIDTH/2, MAP_HEIGHT/2)
end

function goalHit()
    gameOver = true
    paused = true
end
