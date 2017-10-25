local world = {}
local newRayX = nil
local newRayY = nil
local tick = 0

function love.load()
    Vector = require "libs.vector"
    Class = require "libs.class"
    require("src.ray")
    paused = false;
end

function love.update(dt)
    if not paused then
        tick = tick + 1
        --update each ray!
        for i, entity in ipairs(world) do
            entity:updatePosition(dt, tick)
        end
    end
end

function love.draw()
    for i, entity in ipairs(world) do
        entity:draw()
    end
    resetColour()
    if (newRayX and newRayY) then
        love.graphics.circle('line', newRayX, newRayY, 3)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "space" then
        paused = not paused
    end
end

function love.mousepressed(x, y, button, isTouch)
    if button == 1 then
        newRayX = x
        newRayY = y
    end
end

function love.mousereleased(x, y, button, isTouch)
    if newRayX and newRayY then
        if (newRayX ~= x or newRayY ~= y) then
            world[#world+1] = Ray(newRayX, newRayY, x, y)
        end
        newRayX = nil
        newRayY = nil
    end
end

function resetColour()
    love.graphics.setColor(255, 255, 255, 255)
end
