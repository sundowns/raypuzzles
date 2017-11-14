return {
    name = "004",
    ordinal = 4,
    width = 300,
    height = 800,
    data = {
        {shape = "RectangularObstacle", x = 10, y = 200, width = 280, height = 20, rotation = math.pi/4, rotates = true},
        {shape = "RectangularObstacle", x = 10, y = 550, width = 280, height = 20, rotation = -math.pi/4, rotates = true},
        {shape = "CircularObstacle", x = 30, y = 400, radius = 30},
        {shape = "CircularObstacle", x = 270, y = 400, radius = 30},
        {shape = "RectangularTrap", x = 100, y = 375, width = 100, height = 30, rotation = math.pi, rotates = true},
        {shape = "RectangularSpawn", x = 0, y = 0, width = 300, height = 30},
        {shape = "RectangularGoal", x = 0, y = 770, width = 300, height = 30}
    }
}
