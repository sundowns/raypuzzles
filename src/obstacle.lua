Obstacle = Class{
    init = function(self, x, y)
        self.id = random_string(12)
        self.position = Vector(x, y)
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

-- -- Regular triangle
-- TriangularObstacle = Class{ _includes=Obstacle,
--     --Calculate 3 random points within min and max distance
--     init = function(self, cX, cY, minDistance, maxDistance)
--
--     end;
--     update = function(self, dt)
--         --nothing for now
--     end;
-- }

RectangularObstacle = Class{ _includes = Obstacle,
    init = function(self, x, y, width, height, spawn_rotation, isGoal, isSpawn)
        Obstacle.init(self, x, y)
        self.width = width
        self.height = height
        self.IsGoal = isGoal or false
        self.IsSpawn = isSpawn or false
        self.rotation = spawn_rotation or 0
        self.hitbox = HC.rectangle(x, y, width, height)
        self.hitbox.owner = self
        self.hitbox:rotate(self.rotation)
        self.rotationalTickTime = 0.025
        self.rotationSpeed = 0.075
        self.isRotating = false
        self.rotationaltimer = Timer.new()
        if self.rotation ~= 0 then
            self.rotates = true --add this to parameter/map files, default false
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
        self.rotationaltimer:update(dt) --TODO: make collision good enough for moving shit
    end;
}

CircularObstacle = Class { _includes = Obstacle,
    init = function(self, x, y, radius, isGoal, isSpawn)
        Obstacle.init(self, x, y)
        self.radius = radius
        self.IsGoal = isGoal or false
        self.IsSpawn = isSpawn or false
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

RectangularGoal = Class{ _includes = RectangularObstacle,
    init = function(self, x, y, width, height, rotation)
        RectangularObstacle.init(self, x, y, width, height, rotation or 0, true)
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

CircularGoal = Class{ _includes = CircularObstacle,
    init = function(self, x, y, radius)
        CircularObstacle.init(self, x, y, radius, true)
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

RectangularSpawn = Class { _includes=RectangularObstacle,
    init = function(self, x, y, width, height, rotation)
        RectangularObstacle.init(self, x, y, width, height, rotation or 0, false, true)
    end;
    move = function(self, newX, newY)
        RectangularObstacle.move(self, newX, newY)
    end;
    draw = function(self, mode)
        love.graphics.setColor(255, 200, 0, 230)
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

CircularSpawn = Class { _includes=CircularObstacle,
    init = function(self, x, y, radius)
        CircularObstacle.init(self, x, y, radius, false, true)
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
