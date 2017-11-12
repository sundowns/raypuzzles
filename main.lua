local rays = {}
local obstacles = {}
local newRayX = nil
local newRayY = nil
local tick = 0
local MAP_WIDTH = 0
local MAP_HEIGHT = 0
local mouseObstacle = nil
local camera = nil

function love.load()
    math.randomseed(os.time())
    Vector = require "libs.vector"
    Class = require "libs.class"
    Camera = require "libs.camera"
    HC = require "libs.HC"
    HC.resetHash(20)
    require("src.ray")
    require("src.obstacle")
    paused = false
    gameOver = false
    MAP_WIDTH = love.graphics.getWidth()
    MAP_HEIGHT = love.graphics.getHeight()
    camera = Camera(MAP_WIDTH/2, MAP_HEIGHT/2, 0.7, 0)
    --Walls
    table.insert(obstacles, RectangularObstacle(-50, -50, MAP_WIDTH + 100, 50)) --top wall (starts top left)
    table.insert(obstacles, RectangularObstacle(-50, -50, 50, MAP_HEIGHT + 100)) --left wall (starts top left)
    table.insert(obstacles, RectangularObstacle(-50, MAP_HEIGHT, MAP_WIDTH + 100, 50)) -- bottom wall (starts bottom left)
    table.insert(obstacles, RectangularObstacle(MAP_WIDTH, -50, 50, MAP_HEIGHT + 100)) --right wall (starts top right)
    --Goals
    table.insert(obstacles, CircularGoal(love.math.random(0, MAP_WIDTH), love.math.random(0, MAP_HEIGHT), 10))
    --table.insert(obstacles, RectangularGoal(love.math.random(0, MAP_WIDTH), love.math.random(0, MAP_HEIGHT), 10, 10))
    --Mouse obstacles
    mouseObstacle = CircularObstacle(-100000, -100000, 20)
    table.insert(obstacles, mouseObstacle)

    print("MOUSE1: Place a ray (hold and release)")
    print("MOUSE2: Place a randomly shaped obstacle")
    print("MOUSE3: Move stuff around")
    print("SPACE: Pause")
    print("F1: Reset\n")
end

function love.update(dt)
    if not paused then
        tick = tick + 1
        for i=#rays,1,-1 do --back to front so we can safely remove (https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating)
            local entity = rays[i]
            local kill = entity:update(dt, tick)
            if kill then
                table.remove(rays, i)
            end
        end

        if love.mouse.isDown(3) then
            local camX, camY = camera:worldCoords(love.mouse.getPosition())
            mouseObstacle:move(camX, camY)
        else
            mouseObstacle:move(-10000000, -10000000)
        end

        if love.keyboard.isDown("left", "a") then
            camera:move(-1, 0)
        elseif love.keyboard.isDown("up", "w") then
            camera:move(0, -1)
        elseif love.keyboard.isDown("right", "d") then
            camera:move(1, 0)
        elseif love.keyboard.isDown("down", "s") then
            camera:move(0,1)
        end
    end
end

function love.draw()
    camera:attach()
    for i, entity in ipairs(rays) do
        entity:draw()
    end
    resetColour()
    for i, obstacle in ipairs(obstacles) do
        obstacle:draw('fill')
    end
    if (newRayX and newRayY) then
        love.graphics.circle('line', newRayX, newRayY, 4)
    end
    resetColour()
    camera:detach()

    --UI / OVERLAY
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    if gameOver then
        love.graphics.setColor(0,255,0)
        love.graphics.print("You win! Press SPACE to restart", love.graphics.getWidth()/2 - 120, love.graphics.getHeight()/2 - 20)
    end

    if paused and not gameOver then
        love.graphics.setColor(255,0,0)
        love.graphics.print("P A U S E D", love.graphics.getWidth()/2 - 50, love.graphics.getHeight()/2)
    end
    resetColour()

end

function love.keypressed(key, scancode, isrepeat)
    if key == "space" then
        if gameOver then
            love.event.quit("restart")
        end
        paused = not paused
    elseif key == "f1" then
        love.event.quit("restart")
    end
end

function love.mousepressed(x, y, button, isTouch)
    local camX, camY = camera:worldCoords(x, y)
    if not paused then
        if button == 1 then
            newRayX = camX
            newRayY = camY
        elseif button == 2 then
            addRandomObstacle(camX, camY)
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

function addRandomObstacle(x, y)
    local choice = love.math.random(2)
    if choice == 1 then
        local randomWidth = love.math.random(50, 100)
        local randomHeight = love.math.random(50, 100)
        table.insert(obstacles, RectangularObstacle(x-randomWidth/2, y-randomHeight/2, randomWidth, randomHeight))
    elseif choice == 2 then
        table.insert(obstacles, CircularObstacle(x, y, love.math.random(8,50)))
    end
end

function resetColour()
    love.graphics.setColor(255, 255, 255, 255)
end
