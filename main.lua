local rays = {}
local newRayX = nil
local newRayY = nil
local MAP_WIDTH = 0
local MAP_HEIGHT = 0
local mouseObstacle = nil
local camera = nil
local currentStage = 1
local stageManager = {}

function love.load()
    math.randomseed(os.time())
    Vector = require "libs.vector"
    Class = require "libs.class"
    Camera = require "libs.camera"
    Timer = require "libs.timer"
    HC = require "libs.HC"
    HC.resetHash(20)
    require("src.util")
    require("src.ray")
    require("src.obstacle")
    require("src.stagemanager")
    paused = false
    gameOver = false
    love.graphics.setBackgroundColor(0,0,0,255)
    stageManager = StageManager("001")
    MAP_WIDTH, MAP_HEIGHT = stageManager:getStageDimensions()
    camera = Camera(MAP_WIDTH/2, MAP_HEIGHT/2, 0.7, 0)
    --Mouse obstacles
    -- mouseObstacle = CircularObstacle(-100000, -100000, 20)
    -- table.insert(obstacles, mouseObstacle)
    --TODO: readd mouse obstacle
    print("=====[CONTROLS]=====")
    print("MOUSE1: Place a ray (hold and release)")
    print("MOUSE2: Place a randomly shaped obstacle")
    print("MOUSE3: Move stuff around")
    print("SPACE: Pause")
    print("WASD/Arrows: Move camera")
    print("F1: Restart\n")
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
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle('line', newRayX, newRayY, 5)
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
            stageManager:nextStage()
            gameOver = false
        end
        print("wtff")
        paused = not paused
    elseif key == "f1" then
        love.event.quit("restart")
    elseif key == "f2" then
        rays = {}
        stageManager:nextStage()
    end
end

function love.mousepressed(x, y, button, isTouch)
    if not paused then
        local camX, camY = camera:worldCoords(x, y)
        if button == 1 then
            local newRayPoint = HC.point(camX, camY)
            local inStartZone = false
            for other, separating_vector in pairs(HC.collisions(newRayPoint)) do
                if other and other.owner.IsSpawn then
                    inStartZone = true
                end
            end
            HC.remove(newRayPoint)
            if inStartZone then
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
                rays[#rays+1] = Ray(newRayX, newRayY, camX, camY)
            end
            newRayX = nil
            newRayY = nil
        end
    end
end

function goalHit()
    gameOver = true
    paused = true
end
