Obstacle = Class{
    init = function(self, x, y)
        self.position = Vector(x, y)
    end;
    move = function(self, newX, newY)
        self.position = Vector(newX, newY)
    end;
    collidedWith = function(self)
        --nothing for now, maybe some fancy effects/tweening?
    end;
}

RectangularObstacle = Class{ _includes = Obstacle,
    init = function(self, x, y, width, height, rotation, isGoal, isSpawn)
        Obstacle.init(self, x, y)
        self.width = width
        self.height = height
        self.IsGoal = isGoal or false
        self.IsSpawn = isSpawn or false
        self.rotation = rotation or 0
        self.hitbox = HC.rectangle(x, y, width, height)
        self.hitbox.owner = self
        self.hitbox:rotate(self.rotation)
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
}
