return {
    name = "001",
    ordinal = 1,
    width = 400,
    height = 600,
    raysAllowed = 8,
    data = {
        {shape = "RectangularSpawn", x = 100, y = 300, width = 180, height = 100},
        {shape = "TriangularObstacle", x = 200, y = 100, length = 80},
        {shape = "RectangularObstacle", x = 200, y = 300, width = 20, height = 400},
        {shape = "TriangularObstacle", x = 200, y = 500, length = 80},
        {shape = "TriangularObstacle", x = 100, y = 400, length = 60, rotation = math.pi},
        {shape = "TriangularObstacle", x = 100, y = 200, length = 60},
        {shape = "RectangularObstacle", x = 250, y = 150, width = 120, height = 30},
        {shape = "RectangularObstacle", x = 250, y = 450, width = 120, height = 30},
        {shape = "TriangularTrap", x = 370, y = 300, length = 80, rotation = math.pi/2},
        {shape = "RectangularGoal", x = 220, y = 300, width = 20, height = 80}
    }
}
