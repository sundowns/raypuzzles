local MIN_SPEED = 5
local MAX_SPEED = 60
local BASE_POWER = 30
local TRAIL_LENGTH = 100
local PARTICLE_RADIUS = 6
local LIFESPAN = 20 -- seconds


Ray = Class{
    init = function(self, x, y, atX, atY)
        self.pos = Vector(x, y)
        self.direction = Vector(atX - x, atY - y)
        local distance = distanceFrom(x, y, atX, atY)
        self.power = BASE_POWER*(distance/love.graphics.getHeight())^2
        local attempted = self.power
        self.radius = PARTICLE_RADIUS
        self.hitbox = HC.circle(x, y, self.radius)
        self.hitbox.owner = self
        if (self.power < MIN_SPEED) then
            self.power = MIN_SPEED
        elseif (self.power > MAX_SPEED) then
            self.power = MAX_SPEED
        end
         print("attempt: " .. attempted.. " actual: " ..self.power)

        self.red = love.math.random(50,255)
        self.green = love.math.random(50,255)
        self.blue = love.math.random(50,255)
        self.trail = {} --TODO: replace with particle system
        self.timetolive = LIFESPAN
        self.trailTimer = Timer.new()
        self.collisionTimer = Timer.new()
        self.canCollide = true

        self.trailTimer:every(0.005, function()
            table.insert(self.trail, self.pos)
            if (#self.trail > TRAIL_LENGTH) then
                table.remove(self.trail, 1)
            end
        end)
    end;
    getColour = function(self)
        return self.red, self.green, self.blue
    end;
    update = function(self, dt)
        self.trailTimer:update(dt)
        self.collisionTimer:update(dt)

        self:moveIncrementally(dt, 12)

        self.timetolive = self.timetolive - dt
        if (self.timetolive < 0) then
            return true
        else
            return false
        end
    end;
    moveWithDirection = function(self, dt, speed_coefficient)
        if not speed_coefficient then speed_coefficient = 1 end
        self.pos = self.pos + self.direction * dt
        self.hitbox:moveTo(self.pos.x, self.pos.y)
    end;
    move = function(self, dx, dy)
        self.pos = Vector(self.pos.x + dx, self.pos.y + dy)
        self.hitbox:moveTo(self.pos.x, self.pos.y)
    end;
    moveIncrementally = function(self, dt, increments)
        local timeIncrement = dt/increments
        local colliding = false
        for i = 1, increments do
            self:moveWithDirection(timeIncrement)
            if self.canCollide then
                for other in pairs(HC.neighbors(self.hitbox)) do
                    local collides, dx, dy = self.hitbox:collidesWith(other)
                    if collides and not other.owner.IsSpawn then
                        self.direction = self.direction + Vector(dx, dy)
                        self:move(dx*dt, dy*dt)
                        colliding = true
                        other.owner:collidedWith()
                        self.canCollide = false
                        self.collisionTimer:after(0.001, function() self.canCollide = true end)
                    end
                end
                self.direction = self.direction:normalized() * self.power
                self:moveWithDirection(timeIncrement*(increments-1))
                if (colliding) then
                    break
                end
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
