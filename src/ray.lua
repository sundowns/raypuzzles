local MIN_SPEED = 20
local MAX_SPEED = 110
local TRAIL_LENGTH = 120
local PROJECTILE_SCATTER_COUNT = 100
local LIFESPAN = 12 -- seconds

local PS_WIDTH, PS_HEIGHT = 100, 80

Ray = Class{
    init = function(self, x, y, atX, atY, radius)
        self.pos = Vector(x, y)
        self.direction = Vector(atX - x, atY - y)
        local aCamX, aCamY = camera:worldCoords(x,y)
        local bCamX, bCamY = camera:worldCoords(atX, atY)
        local distance = distanceFrom(aCamX, aCamY, bCamX, bCamY)
        self.power = BASE_POWER*distance/love.graphics.getWidth()/2 --TODO: figure out power scale
        local attempted = self.power
        self.radius = radius
        self.hitbox = HC.circle(x, y, self.radius)
        self.hitbox.owner = self
        self.power = math.clamp(self.power, MIN_SPEED, MAX_SPEED)
        print("attempt: " .. attempted.. " actual: " ..self.power)

        self.red = love.math.random(50,255)
        self.green = love.math.random(50,255)
        self.blue = love.math.random(50,255)
        self.timetolive = LIFESPAN
        self.trail = {}
        self.timer = Timer.new()
        self.collisionParticles = {}
        self:prepareParticleSystems()
        self.isColliding = false
        self.IsRay = true
    end;
    getColour = function(self)
        return self.red, self.green, self.blue
    end;
    update = function(self, dt)
        self.timer:update(dt)

        if self.isColliding then
            self.collisionParticles:setEmissionRate(500)
        else
            self.collisionParticles:setEmissionRate(0)
        end

        local kill = self:moveIncrementally(dt, 30)

        self.collisionParticles:update(dt)
        self.trail:update(dt)

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
                if collides then
                    if other.owner.IsObstacle and not other.owner.IsSpawn then
                        kill = self:collideWithObstacle(other.owner, dx, dy, dt)
                        colliding = true
                    elseif other.owner.IsRay then
                        kill = self:collideWithRay(other.owner, dx, dy, dt)
                        colliding = true
                    end
                end
            end
            self:moveWithDirection(timeIncrement)
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
    prepareParticleSystems = function(self)
        local r,g,b = self:getColour()
        -- Trail
        local trailCanvas = love.graphics.newCanvas(PS_WIDTH, PS_HEIGHT)
        love.graphics.setCanvas(trailCanvas) -- Switch to drawing on canvas
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.circle("fill", PS_WIDTH / 2, PS_HEIGHT / 2, 6, 10)
        love.graphics.setCanvas() -- Switch back to drawing on main screen
        self.trail = love.graphics.newParticleSystem(trailCanvas, self.TRAIL_LENGTH)
        self.trail:moveTo(self.pos.x, self.pos.y)
        self.trail:setParticleLifetime(2.5)
        self.trail:setSizes(1, 0.75, 0.5, 0.15)
        self.trail:setLinearAcceleration(0, 0, 0, 0) -- (minX, minY, maxX, maxY)
        self.trail:setColors(r, g, b, 150, r, g, b, 40)
        self.trail:setEmissionRate(240)

        -- Collision effects
        local collisionCanvas = love.graphics.newCanvas(PS_WIDTH, PS_HEIGHT)
        love.graphics.setCanvas(collisionCanvas)
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.circle("fill", PS_WIDTH / 2, PS_HEIGHT / 2, 5, 3)
        love.graphics.setCanvas()
        self.collisionParticles = love.graphics.newParticleSystem(collisionCanvas, PROJECTILE_SCATTER_COUNT)
        self.collisionParticles:setParticleLifetime(0.5, 2)
        self.collisionParticles:setSizeVariation(0.7)
        self.collisionParticles:setSpin(-4*math.pi, 4*math.pi)
        self.collisionParticles:setSpinVariation(1)
        self.collisionParticles:setLinearAcceleration(-100, -100, 100, 100) -- (minX, minY, maxX, maxY)
        self.collisionParticles:setSpread(math.pi/4)
        self.collisionParticles:setColors(r, g, b, 255, r, g, b, 150)
        self.collisionParticles:moveTo(self.pos.x, self.pos.y)
    end;
    emitCollisionParticles = function(self)
        self.isColliding = true
        self.timer:after(0.07, function() self.isColliding = false end)
    end;
    --displacement x & y + velocity to combine with
    collidedWith = function(self, dx, dy, velocity)
        self.direction = (self.direction + velocity):normalized() * self.power
        self:move(dx, dy)
        self:emitCollisionParticles()
    end;
    collideWithObstacle = function(self, obstacle, dx, dy, dt)
        --TODO: Is this fine? seems ok for non-circles
        --TODO: replace this with bouncing off different walls that makes sense! (this makes no sense!)
        --dx,dy is the separating vector needed to stop overlap, NOT the normal vector (which we mirror/flip over for a proper bounce)
        --self.direction = self.direction + Vector(dx, dy)
        local speed = self.direction:len()
        local collisionDirection =  self.direction:normalized() + Vector(dx,dy):normalized()
        self.direction = collisionDirection:normalized() * speed
        self:move(dx*dt, dy*dt) --this however is legit, the separating vector SHOULD be used to prevent clipping
        obstacle:collidedWith(-dx*dt, -dy*dt)
        self:emitCollisionParticles()
        if obstacle.IsTrap then return true else return false end
    end;
    collideWithRay = function(self, ray, dx, dy, dt)
        --Elastic collisions
        --https://stackoverflow.com/questions/345838/ball-to-ball-collision-detection-and-handling
        local collision = self.pos - ray.pos
        collision = collision:normalized()

        -- Get the components of the velocity vectors which are parallel to the collision.
        local aci = self.direction * collision
        local bci = ray.direction * collision
        -- Solve for the new velocities using the 1-dimensional elastic collision equations.
        local acf = bci
        local bcf = aci

        self.direction = self.direction + (acf-aci) * collision
        ray.direction = ray.direction + (bcf-bci) * collision
        --Old method:
        -- local originalVelocity = self.direction:clone()
        -- self.direction = (self.direction + ray.direction):normalized() * self.power
        self:move(dx*dt/2, dy*dt/2)
        ray:move(-dx*dt/2, -dy*dt/2)
        -- ray:collidedWith(-dx*dt/2, -dy*dt/2, originalVelocity)
        self:emitCollisionParticles()
        ray:emitCollisionParticles()
    end;
}
