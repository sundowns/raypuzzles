local MIN_SPEED = 50
local MAX_SPEED = 700 --350
local TRAIL_LENGTH = 80
local PARTICLE_RADIUS = 6
local LIFESPAN = 20 -- seconds

Ray = Class{
    init = function(self, x, y, atX, atY)
        self.pos = Vector(x, y)
        self.direction = Vector(atX - x, atY - y)
        self.radius = PARTICLE_RADIUS
        self.hitbox = HC.circle(x, y, self.radius)
        self.hitbox.owner = self
        if (self.direction:len() < MIN_SPEED) then
            self.direction = self.direction:normalized() * MIN_SPEED
        elseif (self.direction:len() > MAX_SPEED) then
            self.direction = self.direction:normalized() * MAX_SPEED
        end

        self.red = love.math.random(255)
        self.green = love.math.random(255)
        self.blue = love.math.random(255)
        self.trail = {}
        self.timetolive = LIFESPAN
    end;
    getColour = function(self)
        return self.red, self.green, self.blue
    end;
    update = function(self, dt, tick)
        if (tick % 3 == 0) then
            table.insert(self.trail, self.pos)
            if (#self.trail > TRAIL_LENGTH) then
                table.remove(self.trail, 1)
            end
        end

        self:moveIncrementally(dt, 1, 8)

        self.timetolive = self.timetolive - dt
        if (self.timetolive < 0) then
            return true
        else
            return false
        end
    end;
    move = function(self, dt, speed_coefficient)
        self.pos = self.pos + self.direction * speed_coefficient * dt
        self.hitbox:moveTo(self.pos.x, self.pos.y)
    end;
    moveIncrementally = function(self, dt, speed_coefficient, increments)
        local timeIncrement = dt/increments
        local colliding = false
        for i = 1, increments do
            self:move(timeIncrement, speed_coefficient)
            for other in pairs(HC.neighbors(self.hitbox)) do
                local collides, dx, dy = self.hitbox:collidesWith(other)
                if collides then
                    local speed = self.direction:len()
                    self.direction = (self.direction + Vector(dx*increments, dy*increments)):normalized() * speed
                    colliding = true
                    self:move(timeIncrement, speed_coefficient)
                    other.owner:collidedWith()
                end
            end
            if (colliding) then
                break
            end
        end
    end;
    draw = function(self)
        local r,g,b = self:getColour()
        love.graphics.setColor(r,g,b,255)
        love.graphics.circle('fill', self.pos.x, self.pos.y, self.radius)

        for i = 1, #self.trail do
            love.graphics.setColor(r, g, b, (80/#self.trail)*i)
            love.graphics.circle("fill", self.trail[i].x, self.trail[i].y, (self.radius/#self.trail)*i) --reduce the size further along!!?
        end
    end;
    collidedWith = function(self)
        --nothing for now, maybe cute effects/tweening
    end;
}
