Obstacle = Class{
    init = function(self, x, y)
        self.position = Vector(x, y)
        self.IsObstacle = true
    end;
    move = function(self, newX, newY)
        self.position = Vector(newX, newY)
    end;
    collidedWith = function(self)
        --nothing for now, maybe some fancy effects/tweening?
    end;
    update = function(self, dt)
        --nothing for now
    end;
}

--https://math.stackexchange.com/questions/1344690/is-it-possible-to-find-the-vertices-of-an-equilateral-triangle-given-its-center
-- Regular triangle
TriangularObstacle = Class{ _includes=Obstacle,
    --TODO: another constructor that could use a random distance from cx/cy instead (for non equilaterls)
    --Calculate vertices of equilateral triangle given centre and length of the edges
    --        A
    --       / \
    --    B /___\ C
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
        self.hitbox = HC.polygon(aX, aY, bX, bY, cX, cY)
        self.hitbox.owner = self
        self.hitbox:rotate(self.rotation)
        self.rotationalTickTime = 0.025
        self.rotationSpeed = 0.075
        self.rotationaltimer = Timer.new()
        self.isRotating = false
        if self.rotates then
            self.isRotating = true
            self.rotationaltimer:every(self.rotationalTickTime, function()
                if self.isRotating then
                    self.rotation = self.rotation + 2*math.pi/self.rotationalTickTime
                    if self.rotation > 2*math.pi then self.rotation = self.rotation - 2*math.pi end
                    self.hitbox:rotate(2*math.pi*self.rotationalTickTime*self.rotationSpeed)
                end
            end)
        end
    end;
    move = function(self, newX, newY)
        Obstacle.move(self, newX, newY)
        self.hitbox:moveTo(newX, newY)
    end;
    draw = function(self, mode)
        self.hitbox:draw(mode)
    end;
    collidedWith = function(self)
        Obstacle.collidedWith(self)
        self.isRotating = false
        self.rotationaltimer:after(0.15, function()
            self.isRotating = true
        end)
    end;
    update = function(self, dt)
        Obstacle.update(self, dt)
        self.rotationaltimer:update(dt)
    end;
}

RectangularObstacle = Class{ _includes = Obstacle,
    init = function(self, x, y, width, height, spawn_rotation, rotates)
        Obstacle.init(self, x, y)
        self.width = width
        self.height = height
        self.rotates = rotates
        self.rotation = spawn_rotation or 0
        self.hitbox = HC.rectangle(x, y, width, height)
        self.hitbox.owner = self
        self.hitbox:rotate(self.rotation)
        self.rotationalTickTime = 0.025
        self.rotationSpeed = 0.075
        self.isRotating = false
        self.rotationaltimer = Timer.new()
        if self.rotates then
            self.isRotating = true
            self.rotationaltimer:every(self.rotationalTickTime, function()
                if self.isRotating then
                    self.rotation = self.rotation + 2*math.pi/self.rotationalTickTime
                    if self.rotation > 2*math.pi then self.rotation = self.rotation - 2*math.pi end
                    self.hitbox:rotate(2*math.pi*self.rotationalTickTime*self.rotationSpeed)
                end
            end)
        end
    end;
    move = function(self, newX, newY)
        Obstacle.move(self, newX, newY)
        self.hitbox:moveTo(newX, newY)
    end;
    draw = function(self, mode)
        self.hitbox:draw(mode)
    end;
    collidedWith = function(self)
        Obstacle.collidedWith(self)
        self.isRotating = false
        self.rotationaltimer:after(0.15, function()
            self.isRotating = true
        end)
    end;
    update = function(self, dt)
        Obstacle.update(self, dt)
        self.rotationaltimer:update(dt)
    end;
}

RectangularGoal = Class{ _includes = RectangularObstacle,
    init = function(self, x, y, width, height, rotation, rotates)
        RectangularObstacle.init(self, x, y, width, height, rotation, rotates)
        self.IsGoal = true
    end;
    move = function(self, newX, newY)
        RectangularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        love.graphics.setColor(0, 255, 0, 200)
        RectangularObstacle.draw(self, mode)
        reset_colour()
    end;
    collidedWith = function(self)
        goalHit()
    end;
    update = function(self, dt)
        RectangularObstacle.update(self, dt)
    end;
}

RectangularSpawn = Class { _includes=RectangularObstacle,
    init = function(self, x, y, width, height, rotation)
        RectangularObstacle.init(self, x, y, width, height, rotation, rotates)
        self.IsSpawn = true
    end;
    move = function(self, newX, newY)
        RectangularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        love.graphics.setColor(255, 200, 0, 200)
        RectangularObstacle.draw(self, mode)
        reset_colour()
    end;
    collidedWith = function(self)
        --nothing
    end;
    update = function(self, dt)
        RectangularObstacle.update(self, dt)
    end;
}

RectangularTrap = Class { _includes=RectangularObstacle,
    init = function(self, x, y, width, height, rotation, rotates)
        RectangularObstacle.init(self, x, y, width, height, rotation, rotates)
        self.IsTrap = true
    end;
    move = function(self, newX, newY)
        RectangularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        love.graphics.setColor(255, 0, 0, 255)
        RectangularObstacle.draw(self, mode)
        reset_colour()
    end;
    collidedWith = function(self)
        --nothing
    end;
    update = function(self, dt)
        RectangularObstacle.update(self, dt)
    end;
}

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
        self.hitbox:draw(mode)
    end;
    collidedWith = function(self)
        Obstacle.collidedWith(self)
    end;
    update = function(self, dt)
        Obstacle.update(self, dt)
    end;
}

CircularGoal = Class{ _includes = CircularObstacle,
    init = function(self, x, y, radius)
        CircularObstacle.init(self, x, y, radius)
        self.IsGoal = true
    end;
    move = function(self, newX, newY)
        CircularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        love.graphics.setColor(0, 255, 0, 200)
        CircularObstacle.draw(self, mode)
        reset_colour()
    end;
    collidedWith = function(self)
        goalHit()
    end;
    update = function(self, dt)
        CircularObstacle.update(self, dt)
    end;
}

CircularSpawn = Class { _includes=CircularObstacle,
    init = function(self, x, y, radius)
        CircularObstacle.init(self, x, y, radius)
        self.IsSpawn = true
    end;
    move = function(self, newX, newY)
        CircularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        love.graphics.setColor(255, 200, 0, 230)
        CircularObstacle.draw(self, mode)
        reset_colour()
    end;
    collidedWith = function(self)
        --nothing
    end;
    update = function(self, dt)
        CircularObstacle.update(self, dt)
    end;
}

CircularTrap = Class { _includes=CircularObstacle,
    init = function(self, x, y, radius)
        CircularObstacle.init(self, x, y, radius)
        self.IsTrap = true
    end;
    move = function(self, newX, newY)
        CircularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        love.graphics.setColor(255, 0, 0, 255)
        CircularObstacle.draw(self, mode)
        reset_colour()
    end;
    collidedWith = function(self)
        --nothing
    end;
    update = function(self, dt)
        CircularObstacle.update(self, dt)
    end;
}
