local rays = {}
local obstacles = {}
local newRayX = nil
local newRayY = nil
local tick = 0
local MAP_WIDTH = 0
local MAP_HEIGHT = 0

function love.load()
    Vector = require "libs.vector"
    Class = require "libs.class"
    HC = require "libs.HC"
    HC.resetHash(20)
    require("src.ray")
    paused = false;
    MAP_WIDTH = love.graphics.getWidth()
    MAP_HEIGHT = love.graphics.getHeight()
    table.insert(obstacles, HC.rectangle(-50, -50, MAP_WIDTH + 100, 50)) --top wall (starts top left)
    table.insert(obstacles, HC.rectangle(-50, -50, 50, MAP_HEIGHT + 100)) --left wall (starts top left)
    table.insert(obstacles, HC.rectangle(-50, MAP_HEIGHT, MAP_WIDTH + 100, 50)) -- bottom wall (starts bottom left)
    table.insert(obstacles, HC.rectangle(MAP_WIDTH, -50, 50, MAP_HEIGHT + 100)) --right wall (starts top right)
    print("MOUSE1: Place a ray (hold and release for direction/power)")
    print("MOUSE2: Place a randomly obstacle")
    print("SPACE: Pause")
    print("F1: Reset")
end

function love.update(dt)
    if not paused then
        tick = tick + 1
        for i=#rays,1,-1 do --back to front so we can safely remove (https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating)
            local entity = rays[i]
            local kill = entity:update(dt, tick)
            if kill then
                table.remove(rays, i)
            else
                entity:handleCollisions(dt)
            end
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
end

function love.keypressed(key, scancode, isrepeat)
    if key == "space" then
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

function addRandomObstacle(x, y)
    local choice = love.math.random(2)
    if choice == 1 then
        table.insert(obstacles, HC.rectangle(x, y, love.math.random(50, 100), love.math.random(50, 100)))
    elseif choice == 2 then
        table.insert(obstacles, HC.circle(x, y, love.math.random(8,50)))
    end
end

function resetColour()
    love.graphics.setColor(255, 255, 255, 255)
end
