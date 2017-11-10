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
    init = function(self, x, y, width, height, isGoal)
        Obstacle:init(x, y)
        self.width = width
        self.height = height
        self.hitbox = HC.rectangle(x, y, width, height)
        self.hitbox.owner = self
        self.IsGoal = isGoal or false
    end;
    move = function(self, newX, newY)
        Obstacle:move(newX, newY)
        self.hitbox:moveTo(newX, newY)
    end;
    draw = function(self, mode)
        self.hitbox:draw(mode)
    end;
    collidedWith = function(self)
        if self.IsGoal then goalHit() end
        Obstacle:collidedWith()
    end;
}

CircularObstacle = Class { _includes = Obstacle,
    init = function(self, x, y, radius, isGoal)
        Obstacle:init(x, y)
        self.radius = radius
        self.hitbox = HC.circle(x, y, radius)
        self.hitbox.owner = self
        self.IsGoal = isGoal or false
    end;
    move = function(self, newX, newY)
        Obstacle:move(newX, newY)
        self.hitbox:moveTo(newX, newY)
    end;
    draw = function(self, mode)
        self.hitbox:draw(mode)
    end;
    collidedWith = function(self)
        if self.IsGoal then goalHit() end
        Obstacle:collidedWith()
    end;
}

RectangularGoal = Class{ _includes = RectangularObstacle,
    init = function(self, x, y, width, height)
        RectangularObstacle:init(x, y, width, height, true)
    end;
    move = function(self, newX, newY)
        RectangularObstacle:move(newX, newY)
    end;
    draw = function(self, mode)
        love.graphics.setColor(0, 255, 0)
        RectangularObstacle:draw(mode)
        resetColour()
    end;
}

CircularGoal = Class{ _includes = CircularObstacle,
    init = function(self, x, y, radius)
        CircularObstacle:init(x, y, radius, true)
    end;
    move = function(self, newX, newY)
        CircularObstacle:move(newX, newY)
    end;
    draw = function(self, mode)
        love.graphics.setColor(0, 255, 0)
        CircularObstacle:draw(mode)
        resetColour()
    end;
}
