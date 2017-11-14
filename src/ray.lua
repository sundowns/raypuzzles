local MIN_SPEED = 3
local MAX_SPEED = 60
local BASE_POWER = 30
local TRAIL_LENGTH = 120
local PARTICLE_RADIUS = 6
local LIFESPAN = 13 -- seconds

local PS_WIDTH, PS_HEIGHT = 100, 80

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
        self.power = math.clamp(self.power, MIN_SPEED, MAX_SPEED)
        print("attempt: " .. attempted.. " actual: " ..self.power)

        self.red = love.math.random(50,255)
        self.green = love.math.random(50,255)
        self.blue = love.math.random(50,255)
        self.timetolive = LIFESPAN
        self.trail = {}
        self.collisionParticles = {}
        self:prepareParticleSystems()
        self.collisionTimer = Timer.new()
        self.isColliding = false
    end;
    getColour = function(self)
        return self.red, self.green, self.blue
    end;
    update = function(self, dt)
        self.collisionTimer:update(dt)
        self.trail:update(dt)
        self.collisionParticles:update(dt)

        if self.isColliding then
            self.collisionParticles:setEmissionRate(100)
        else
            self.collisionParticles:setEmissionRate(0)
        end

        local kill = self:moveIncrementally(dt, 12)

        self.timetolive = self.timetolive - dt
        if (self.timetolive < 0) then
            return true
        else
            return kill or false --kill if hit a trap, otherwise only if expired
        end
    end;
    moveWithDirection = function(self, dt, speed_coefficient)
        if not speed_coefficient then speed_coefficient = 1 end
        self.pos = self.pos + self.direction * dt
        self:updatePositions();
    end;
    move = function(self, dx, dy)
        self.pos = Vector(self.pos.x + dx, self.pos.y + dy)
        self:updatePositions();
    end;
    updatePositions = function(self) --private, only used internally by move functions!
        self.hitbox:moveTo(self.pos.x, self.pos.y)
        self.trail:moveTo(self.pos.x, self.pos.y)
        self.collisionParticles:moveTo(self.pos.x, self.pos.y)
    end;
    moveIncrementally = function(self, dt, increments)
        local timeIncrement = dt/increments
        local colliding = false
        local kill = false
        for i = 1, increments do
            self:moveWithDirection(timeIncrement)
            for other in pairs(HC.neighbors(self.hitbox)) do
                local collides, dx, dy = self.hitbox:collidesWith(other)
                if collides and not other.owner.IsSpawn then
                    if other.owner.IsTrap then kill = true end
                    self.direction = self.direction + Vector(dx, dy)
                    self:move(dx*dt, dy*dt)
                    colliding = true
                    other.owner:collidedWith()
                end
            end
            self.direction = self.direction:normalized() * self.power
            self:moveWithDirection(timeIncrement*(increments-1))
            if (colliding) then
                self.isColliding = true
                self.collisionTimer:after(0.2, function() self.isColliding = false end)
                break
            end
        end
        return kill
    end;
    draw = function(self)
        love.graphics.setBlendMode("add")
        local r,g,b = self:getColour()
        love.graphics.setColor(r,g,b,255)
        love.graphics.circle('fill', self.pos.x, self.pos.y, self.radius)


        love.graphics.draw(self.collisionParticles)
        love.graphics.setBlendMode("alpha")
        love.graphics.draw(self.trail)
    end;
    collidedWith = function(self)
        --nothing for now, maybe cute effects/tweening
    end;
    prepareParticleSystems = function(self)
        local r,g,b = self:getColour()
        -- Trail
        local trailCanvas = love.graphics.newCanvas(PS_WIDTH, PS_HEIGHT)
        love.graphics.setCanvas(trailCanvas) -- Switch to drawing on canvas 'trail'
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.circle("fill", PS_WIDTH / 2, PS_HEIGHT / 2, 6, 10)
        love.graphics.setCanvas() -- Switch back to drawing on main screen
        self.trail = love.graphics.newParticleSystem(trailCanvas, self.TRAIL_LENGTH)
        self.trail:setParticleLifetime(2.5) -- (min, max)
        self.trail:setSizes(1, 0.75, 0.5, 0.15)
        self.trail:setLinearAcceleration(0, 0, 0, 0) -- (minX, minY, maxX, maxY)

        self.trail:setColors(r, g, b, 150, r, g, b, 40) -- (r1, g1, b1, a1, r2, g2, b2, a2 ...)
        self.trail:setEmissionRate(100)
        self.trail:moveTo(self.pos.x, self.pos.y)
        -- Collision effects
        local collisionCanvas = love.graphics.newCanvas(PS_WIDTH, PS_HEIGHT)
        love.graphics.setCanvas(collisionCanvas) -- Switch to drawing on canvas 'trail'
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.circle("fill", PS_WIDTH / 2, PS_HEIGHT / 2, 5, 3)
        love.graphics.setCanvas() -- Switch back to drawing on main screen
        self.collisionParticles = love.graphics.newParticleSystem(collisionCanvas, 50)
        self.collisionParticles:setParticleLifetime(0.5, 2) -- (min, max)
        self.collisionParticles:setSizeVariation(0.7)
        self.collisionParticles:setSpin(0, 2*math.pi)
        self.collisionParticles:setSpinVariation(1)
        self.collisionParticles:setLinearAcceleration(-90, -90, 90, 90) -- (minX, minY, maxX, maxY)
        self.collisionParticles:setSpread(math.pi/4)
        self.collisionParticles:setColors(r, g, b, 255, r, g, b, 150) -- (r1, g1, b1, a1, r2, g2, b2, a2 ...)
        self.collisionParticles:moveTo(self.pos.x, self.pos.y)
    end;
}
