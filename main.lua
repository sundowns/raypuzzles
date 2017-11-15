local rays = {}
local newRayX = nil
local newRayY = nil
local mouseObstacle = nil
local currentStage = 1
local stageManager = {}

-- GLobal cause trust
camera = nil

-- Add to a constants file
BASE_POWER = 160
PARTICLE_RADIUS = 6
MAP_WIDTH = 0
MAP_HEIGHT = 0

function love.load()
    math.randomseed(os.time())
    Vector = require "libs.vector"
    Class = require "libs.class"
    Camera = require "libs.camera"
    Timer = require "libs.timer"
    HC = require "libs.HC"
    --HC.resetHash(20)
    require("src.util")
    require("src.ray")
    require("src.obstacle")
    require("src.stagemanager")
    paused = false
    gameOver = false
    love.graphics.setBackgroundColor(0,0,0,255)
    stageManager = StageManager("001")
    MAP_WIDTH, MAP_HEIGHT = stageManager:getStageDimensions()
    camera = Camera(MAP_WIDTH/2, MAP_HEIGHT/2, 0.6, 0)
    --Mouse obstacles
    -- mouseObstacle = CircularObstacle(-100000, -100000, 20)
    -- table.insert(obstacles, mouseObstacle)
    --TODO: readd mouse obstacle
    print("=====[CONTROLS]=====")
    print("MOUSE1: Place a ray (hold and release)")
    print("SPACE: Pause")
    print("WASD/Arrows: Move camera")
    print("F1: Restart")
    print("F2: Next level")
    print("==========")
end

function love.update(dt)
    if not paused then
        stageManager:update(dt)
        for i=#rays,1,-1 do --back to front so we can safely remove (https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating)
            local entity = rays[i]
            local kill = entity:update(dt)
            if kill then
                table.remove(rays, i)
            end
        end

        -- if love.mouse.isDown(3) then
        --     local camX, camY = camera:worldCoords(love.mouse.getPosition())
        --     mouseObstacle:move(camX, camY)
        -- else
        --     mouseObstacle:move(-10000000, -10000000)
        -- end
    end

    if love.keyboard.isDown("left", "a") then camera:move(-1, 0) end
    if love.keyboard.isDown("up", "w") then camera:move(0, -1) end
    if love.keyboard.isDown("right", "d") then camera:move(1, 0) end
    if love.keyboard.isDown("down", "s") then camera:move(0,1) end
end

function love.draw()
    camera:attach()

    reset_colour()
    stageManager:drawObstacles()
    for i, entity in ipairs(rays) do
        entity:draw()
    end
    if (newRayX and newRayY) then
        love.graphics.setColor(0, 0, 0,255)
        love.graphics.circle('fill', newRayX, newRayY, 5)
    end
    reset_colour()
    camera:detach()

    --UI / OVERLAY
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    if gameOver then
        love.graphics.setColor(0,255,0)
        love.graphics.print("You win! Press SPACE to continue", love.graphics.getWidth()/2 - 120, love.graphics.getHeight()/2 - 20)
    end

    if paused and not gameOver then
        love.graphics.setColor(255,0,0)
        love.graphics.print("P A U S E D", love.graphics.getWidth()/2 - 50, love.graphics.getHeight()/2)
    end
    reset_colour()

end

function love.keypressed(key, scancode, isrepeat)
    if key == "space" then
        if gameOver then
            rays = {}
            newRayX = nil
            newRayY = nil
            stageManager:nextStage()
            gameOver = false
            camera:lookAt(MAP_WIDTH/2, MAP_HEIGHT/2)
        end
        paused = not paused
    elseif key == "f1" then
        love.event.quit("restart")
    elseif key == "f2" then
        rays = {}
        newRayX = nil
        newRayY = nil
        stageManager:nextStage()
        gameOver = false
        camera:lookAt(MAP_WIDTH/2, MAP_HEIGHT/2)
    end
end

function love.mousepressed(x, y, button, isTouch)
    if not paused then
        local camX, camY = camera:worldCoords(x, y)
        if button == 1 then
            local newRayPoint = HC.circle(camX, camY, PARTICLE_RADIUS)
            local inStartZone = false
            --local inObstacle = false
            for other, separating_vector in pairs(HC.collisions(newRayPoint)) do
                if other then
                    if other.owner.IsSpawn then
                        inStartZone = true
                    -- else
                    --     inObstacle = true
                    end

                end
            end
            HC.remove(newRayPoint)
            if inStartZone  then --and not inObstacle
                newRayX = camX
                newRayY = camY
            end
        elseif button == 2 then
            --stageManager:addRandomObstacle(camX, camY) --TODO: make use of elsewhere?
        end
    end
end

function love.mousereleased(x, y, button, isTouch)
    local camX, camY = camera:worldCoords(x, y)
    if not paused then
        if newRayX and newRayY then
            if (newRayX ~= camX or newRayY ~= camY) then
                rays[#rays+1] = Ray(newRayX, newRayY, camX, camY, PARTICLE_RADIUS)
            end
            newRayX = nil
            newRayY = nil
        end
    end
end

function love.wheelmoved(x, y)
    -- if y > 0 then -- fucks with power scale
    --     camera:zoom(1.05)
    -- elseif y < 0 then
    --     camera:zoom(0.95)
    -- end
end

function goalHit()
    gameOver = true
    paused = true
end
