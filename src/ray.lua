local MIN_SPEED = 20
local MAX_SPEED = 110
local TRAIL_LENGTH = 120
local PROJECTILE_SCATTER_COUNT = 100
local LIFESPAN = 15 -- seconds

local PS_WIDTH, PS_HEIGHT = 100, 80

Ray = Class{
    init = function(self, x, y, atX, atY, radius)
        self.direction = Vector(atX - x, atY - y)
        local aCamX, aCamY = camera:worldCoords(x,y)
        local bCamX, bCamY = camera:worldCoords(atX, atY)
        local distance = distanceFrom(aCamX, aCamY, bCamX, bCamY)

        self.radius = radius
        self.body = love.physics.newBody(world, x, y, "dynamic")
        self.body:setBullet(true)
        self.body:setMass(1)
        self.shape = love.physics.newCircleShape(radius)
        self.fixture = love.physics.newFixture(self.body, self.shape, 1)
        self.fixture:setRestitution(0.95)
        self.fixture:setUserData({ray = self})
        self.body:applyLinearImpulse(self.direction.x/40, self.direction.y/40)


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
        self.markedForDeath = false
    end;
    getColour = function(self)
        return self.red, self.green, self.blue
    end;
    update = function(self, dt)
        self.timer:update(dt)

        if self.isColliding then
            self.collisionParticles:setEmissionRate(700)
        else
            self.collisionParticles:setEmissionRate(0)
        end

        self.trail:moveTo(self.body:getPosition())
        self.trail:update(dt)
        self.collisionParticles:moveTo(self.body:getPosition())
        self.collisionParticles:update(dt)

        self.timetolive = self.timetolive - dt
        if (self.timetolive < 0) then
            return true
        else
            return self.markedForDeath or false --kill if hit a trap, otherwise only if expired
        end
    end;
    draw = function(self)
        love.graphics.setBlendMode("alpha")
        local r,g,b = self:getColour()
        love.graphics.setColor(r,g,b,255)
        love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius())
    end;
    drawParticles = function(self)
        love.graphics.setBlendMode("add")
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
        love.graphics.circle("fill", PS_WIDTH / 2, PS_HEIGHT / 2, 8, 10)
        love.graphics.setCanvas() -- Switch back to drawing on main screen
        self.trail = love.graphics.newParticleSystem(trailCanvas, self.TRAIL_LENGTH)
        self.trail:setParticleLifetime(2.5)
        self.trail:setSizes(1, 0.75, 0.5, 0.15)
        self.trail:setLinearAcceleration(0, 0, 0, 0) -- (minX, minY, maxX, maxY)
        self.trail:setColors(r, g, b, 150, r, g, b, 40)
        self.trail:setEmissionRate(240)
        self.trail:moveTo(self.body:getPosition())

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
        self.collisionParticles:moveTo(self.body:getPosition())
    end;
    emitCollisionParticles = function(self)
        self.isColliding = true
        self.timer:after(0.07, function() self.isColliding = false end)
    end;
    markForDeath = function(self)
        self.markedForDeath = true
    end;
}
