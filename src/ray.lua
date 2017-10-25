local MIN_SPEED = 20
local TRAIL_LENGTH = 100

Ray = Class{
    init = function(self, x, y, atX, atY)
        self.pos = Vector(x, y)
        self.direction = Vector(atX - x, atY - y)
        if (self.direction:len() < MIN_SPEED) then
            local unitVector = self.direction:normalized()
            self.direction = unitVector * MIN_SPEED
        end

        self.red = love.math.random(255)
        self.green = love.math.random(255)
        self.blue = love.math.random(255)
        self.trail = {}
    end;
    getColour = function(self)
        return self.red, self.green, self.blue
    end;
    updatePosition = function(self, dt, tick)
        if (tick % 2 == 0) then
            table.insert(self.trail, self.pos)
        end

        self.pos = self.pos + self.direction * dt
        if (#self.trail > TRAIL_LENGTH) then
            table.remove(self.trail, 1)
        end
    end;
    draw = function(self)
        local r,g,b = self:getColour()
        love.graphics.setColor(r,g,b,255)
        love.graphics.circle('fill', self.pos.x, self.pos.y, 3)

        for i = 1, #self.trail do
            love.graphics.setColor(r, g, b, (80/#self.trail)*i)
            love.graphics.circle("fill", self.trail[i].x, self.trail[i].y, 3)
        end
    end;
}
