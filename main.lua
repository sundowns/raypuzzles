local rays = {}
local obstacles = {}
local newRayX = nil
local newRayY = nil
local tick = 0
local MAP_WIDTH = 0
local MAP_HEIGHT = 0
local mouseObstacle = nil

function love.load()
    math.randomseed(os.time())
    Vector = require "libs.vector"
    Class = require "libs.class"
    HC = require "libs.HC"
    HC.resetHash(20)
    require("src.ray")
    require("src.obstacle")
    paused = false
    gameOver = false
    MAP_WIDTH = love.graphics.getWidth()
    MAP_HEIGHT = love.graphics.getHeight()
    --Walls
    table.insert(obstacles, RectangularObstacle(-50, -50, MAP_WIDTH + 100, 50)) --top wall (starts top left)
    table.insert(obstacles, RectangularObstacle(-50, -50, 50, MAP_HEIGHT + 100)) --left wall (starts top left)
    table.insert(obstacles, RectangularObstacle(-50, MAP_HEIGHT, MAP_WIDTH + 100, 50)) -- bottom wall (starts bottom left)
    table.insert(obstacles, RectangularObstacle(MAP_WIDTH, -50, 50, MAP_HEIGHT + 100)) --right wall (starts top right)
    --Goals
    table.insert(obstacles, CircularGoal(love.math.random(0, MAP_WIDTH), love.math.random(0, MAP_HEIGHT), 10))
    --table.insert(obstacles, RectangularGoal(love.math.random(0, MAP_WIDTH), love.math.random(0, MAP_HEIGHT), 10, 10))
    --Mouse obstacles
    mouseObstacle = CircularObstacle(-100, -100, 20)
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
            mouseObstacle:move(love.mouse.getPosition())
        else
            mouseObstacle:move(-100, -100)
        end
    end
end

function love.draw()
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

    --UI / OVERLAY
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    if gameOver then
        love.graphics.setColor(0,255,0)
        love.graphics.print("You win! Press SPACE to restart", love.graphics.getWidth()/2 - 120, love.graphics.getHeight()/2 - 20)
    end

    if paused and not gameOver then
        love.graphics.setColor(255,0,0)
        love.graphics.print("P A U S E D", love.graphics.getWidth()/2 - 50, love.graphics.getHeight()/2)
        resetColour()
    end
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
    if not paused then
        if button == 1 then
            newRayX = x
            newRayY = y
        elseif button == 2 then
            addRandomObstacle(x, y)
        end
    end
end

function love.mousereleased(x, y, button, isTouch)
    if not paused then
        if newRayX and newRayY then
            if (newRayX ~= x or newRayY ~= y) then
                rays[#rays+1] = Ray(newRayX, newRayY, x, y)
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
