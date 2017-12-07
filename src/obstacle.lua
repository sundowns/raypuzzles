--ABSTRACT--
Obstacle = Class{
    init = function(self, x, y)
        self.position = Vector(x, y)
        self.IsObstacle = true
        self.red = 255
        self.green = 255
        self.blue = 255
        self.alpha = 255
    end;
    move = function(self, newX, newY)
        self.position = Vector(newX, newY)
    end;
    update = function(self, dt)
        --nothing for now
    end;
    draw = function(self)
        if debug then
            love.graphics.setColor(255,0,180,255)
            love.graphics.circle('fill',self.position.x, self.position.y, 3)
        end
    end;
}

Trap = Class{
    init = function(self)
        self.IsTrap = true
        self.red = 200
        self.green = 0
        self.blue = 0
        self.alpha = 255
        self.fixture:setSensor(true)
        self.fixture:setUserData({isTrap = true})
    end;
}

Spawn = Class{
    init = function(self)
        self.red = 255
        self.green = 200
        self.blue = 0
        self.alpha = 200
        self.fixture:setSensor(true)
        self.fixture:setUserData({isSpawn = true})
    end;
}

Goal = Class {
    init = function(self)
        self.red = 0
        self.green = 255
        self.blue = 0
        self.alpha = 200
        self.fixture:setSensor(true)
        self.fixture:setUserData({isGoal = true})
    end;
}

--RECTANGLES--
RectangularObstacle = Class{ _includes = Obstacle,
    init = function(self, x, y, width, height, spawn_rotation, rotates)
        Obstacle.init(self, x, y)
        self.width = width
        self.height = height
        self.rotates = rotates
        self.rotation = spawn_rotation or 0
        self.body = love.physics.newBody(world, x, y)
        self.shape = love.physics.newRectangleShape(self.width, self.height)
        self.fixture = love.physics.newFixture(self.body, self.shape, 0.2)

        -- self.rotationalTickTime = 0.025
        -- self.rotationSpeed = 0.075
        -- self.isRotating = false
        -- self.timer = Timer.new()
        -- if self.rotates then
        --     self.isRotating = true
        --     self.timer:every(self.rotationalTickTime, function()
        --         if self.isRotating then
        --             self.rotation = self.rotation + 2*math.pi/self.rotationalTickTime
        --             if self.rotation > 2*math.pi then self.rotation = self.rotation - 2*math.pi end
        --             self.hitbox:rotate(2*math.pi*self.rotationalTickTime*self.rotationSpeed)
        --         end
        --     end)
        -- end
    end;
    move = function(self, newX, newY)
        Obstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        love.graphics.setColor(self.red, self.green, self.blue, self.alpha)
        love.graphics.polygon(mode, self.body:getWorldPoints(self.shape:getPoints()))
        Obstacle.draw(self)
        reset_colour()
    end;
    update = function(self, dt)
        Obstacle.update(self, dt)
        --self.timer:update(dt)
    end;
}

RectangularGoal = Class{ _includes = RectangularObstacle,Goal,
    init = function(self, x, y, width, height, rotation, rotates)
        RectangularObstacle.init(self, x, y, width, height, rotation, rotates)
        Goal.init(self)
    end;
    move = function(self, newX, newY)
        RectangularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        RectangularObstacle.draw(self, mode)
    end;
    update = function(self, dt)
        RectangularObstacle.update(self, dt)
    end;
}

RectangularSpawn = Class { _includes=RectangularObstacle,Spawn,
    init = function(self, x, y, width, height, rotation, rotates)
        RectangularObstacle.init(self, x, y, width, height, rotation, rotates)
        Spawn.init(self)
    end;
    move = function(self, newX, newY)
        RectangularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        RectangularObstacle.draw(self, mode)
    end;
    update = function(self, dt)
        RectangularObstacle.update(self, dt)
    end;
}

RectangularTrap = Class { _includes=RectangularObstacle,Trap,
    init = function(self, x, y, width, height, rotation, rotates)
        RectangularObstacle.init(self, x, y, width, height, rotation, rotates)
        Trap.init(self)
    end;
    move = function(self, newX, newY)
        RectangularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        RectangularObstacle.draw(self, mode)
    end;
    update = function(self, dt)
        RectangularObstacle.update(self, dt)
    end;
}

--CIRCLES--
CircularObstacle = Class { _includes = Obstacle,
    init = function(self, x, y, radius)
        Obstacle.init(self, x, y)
        self.radius = radius
        self.hitbox = HC.circle(x, y, radius)
        self.hitbox.owner = self
    end;
    move = function(self, newX, newY)
        Obstacle.move(self, newX, newY)
        self.hitbox:moveTo(newX, newY)
    end;
    draw = function(self, mode)
        love.graphics.setColor(self.red, self.green, self.blue, self.alpha)
        self.hitbox:draw(mode)
        reset_colour()
    end;
    update = function(self, dt)
        Obstacle.update(self, dt)
    end;
}

CircularGoal = Class{ _includes = CircularObstacle,Goal,
    init = function(self, x, y, radius)
        CircularObstacle.init(self, x, y, radius)
        Goal.init(self)
    end;
    move = function(self, newX, newY)
        CircularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        CircularObstacle.draw(self, mode)
    end;
    update = function(self, dt)
        CircularObstacle.update(self, dt)
    end;
}

CircularSpawn = Class { _includes=CircularObstacle,Spawn,
    init = function(self, x, y, radius)
        CircularObstacle.init(self, x, y, radius)
        Spawn.init(self)
    end;
    move = function(self, newX, newY)
        CircularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        CircularObstacle.draw(self, mode)
    end;
    update = function(self, dt)
        CircularObstacle.update(self, dt)
    end;
}

CircularTrap = Class { _includes=CircularObstacle,Trap,
    init = function(self, x, y, radius)
        CircularObstacle.init(self, x, y, radius)
        Trap.init(self)
    end;
    move = function(self, newX, newY)
        CircularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        CircularObstacle.draw(self, mode)
    end;
    update = function(self, dt)
        CircularObstacle.update(self, dt)
    end;
}

--TRIANGLES--

TriangularObstacle = Class{ _includes=Obstacle,
    --Calculate vertices of equilateral triangle given centre and length of the edges
    ----https://math.stackexchange.com/questions/1344690/is-it-possible-to-find-the-vertices-of-an-equilateral-triangle-given-its-center
    --        A
    --       / \
    --    B /___\ C
    --TODO: another constructor that could use a random distance from cx/cy instead (for non equilaterls)
    init = function(self, centreX, centreY, length, spawn_rotation, rotates)
        Obstacle.init(self, centreX, centreY)
        local aX, aY, bX, bY, cX, cY
        --A = (x, y + (sqrt(3)/3)*length)
        aX = centreX
        aY = centreY + (math.sqrt(3)/3) * length
        --B = (x - length/2, y - (sqrt(3)/6)*length)
        bX = centreX - length / 2
        bY = centreY - (math.sqrt(3)/6) * length
        --C = (x + length/2, y - (sqrt(3)/6)*length)
        cX = centreX + length / 2
        cY = centreY - (math.sqrt(3)/6) * length
        self.sideLength = length
        self.rotation = spawn_rotation or 0
        self.rotates = rotates

        self.body = love.physics.newBody(world, 0, 0)
        --self.body:setAngle(self.rotation)
        self.shape = love.physics.newPolygonShape(aX, aY, bX, bY, cX, cY)
        self.fixture = love.physics.newFixture(self.body, self.shape, 0.2)



        -- self.rotationalTickTime = 0.025
        -- self.rotationSpeed = 0.075
        -- self.timer = Timer.new()
        -- self.isRotating = false
        -- if self.rotates then
        --     self.isRotating = true
        --     self.timer:every(self.rotationalTickTime, function()
        --         if self.isRotating then
        --             self.rotation = self.rotation + 2*math.pi/self.rotationalTickTime
        --             if self.rotation > 2*math.pi then self.rotation = self.rotation - 2*math.pi end
        --             self.hitbox:rotate(2*math.pi*self.rotationalTickTime*self.rotationSpeed)
        --         end
        --     end)
        -- end
    end;
    move = function(self, newX, newY)
        Obstacle.move(self, newX, newY)
        --self.hitbox:moveTo(newX, newY)
    end;
    draw = function(self, mode)
        love.graphics.setColor(self.red, self.green, self.blue, self.alpha)
        love.graphics.polygon(mode, self.body:getWorldPoints(self.shape:getPoints()))
        Obstacle.draw(self)
        reset_colour()
    end;
    update = function(self, dt)
        Obstacle.update(self, dt)
        --self.timer:update(dt)
    end;
}

TriangularGoal = Class{ _includes = TriangularObstacle,Goal,
    init = function(self, x, y, length, spawn_rotation, rotates)
        TriangularObstacle.init(self, x, y, length, spawn_rotation, rotates)
        Goal.init(self)
    end;
    move = function(self, newX, newY)
        TriangularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        TriangularObstacle.draw(self, mode)
    end;
    update = function(self, dt)
        TriangularObstacle.update(self, dt)
    end;
}

TriangularSpawn = Class{ _includes = TriangularObstacle,Spawn,
    init = function(self, x, y, length, spawn_rotation, rotates)
        TriangularObstacle.init(self, x, y, length, spawn_rotation, rotates)
        Spawn.init(self)
    end;
    move = function(self, newX, newY)
        TriangularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        TriangularObstacle.draw(self, mode)
    end;
    update = function(self, dt)
        TriangularObstacle.update(self, dt)
    end;
}

TriangularTrap = Class{ _includes = TriangularObstacle,Trap,
    init = function(self, x, y, length, spawn_rotation, rotates)
        TriangularObstacle.init(self, x, y, length, spawn_rotation, rotates)
        Trap.init(self)
    end;
    move = function(self, newX, newY)
        TriangularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        TriangularObstacle.draw(self, mode)
    end;
    update = function(self, dt)
        TriangularObstacle.update(self, dt)
    end;
}
