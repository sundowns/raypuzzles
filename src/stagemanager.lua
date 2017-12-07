local STAGES_DIRECTORY_PATH = "stages/"

StageManager = Class {
    init = function(self)
        self.stageList = love.filesystem.getDirectoryItems(STAGES_DIRECTORY_PATH)
        for k, val in pairs(self.stageList) do
            self.stageList[k] = val:gsub("%.lua", "") --removeS file extensions
        end
        self.currentStageOrdinal = 1
        self.hasLoaded = false
        self:loadStage()
    end;
    loadStage = function(self)
        self.loadedStage = {}
        self.obstacles = {}
        self.spawns = {}
        self.stageName = self.stageList[self.currentStageOrdinal]
        if not love.filesystem.exists(STAGES_DIRECTORY_PATH .. self.stageName .. ".lua") then
            print("Unable to locate stage file " .. STAGES_DIRECTORY_PATH .. self.stageName .. ".lua")
        else
            local stage = require(STAGES_DIRECTORY_PATH .. self.stageName)
            if stage then
                print("Loaded " .. self.stageName)
                self.loadedStage = stage
                self.hasLoaded = true
                table.insert(self.obstacles, RectangularObstacle(self.loadedStage.width/2, 0, self.loadedStage.width, 20)) --top wall
                table.insert(self.obstacles, RectangularObstacle(0, self.loadedStage.height/2, 20, self.loadedStage.height)) --left wall
                table.insert(self.obstacles, RectangularObstacle(self.loadedStage.width/2, self.loadedStage.height, self.loadedStage.width, 20)) --bottom wall
                table.insert(self.obstacles, RectangularObstacle(self.loadedStage.width, self.loadedStage.height/2, 20, self.loadedStage.height)) --right wall
                self:populateStageObstacles()
                raysRemaining = self.loadedStage.raysAllowed
            else
                print("[ERR] Failed to load stagefile " .. self.stageName)
            end
        end
    end;
    nextStage = function(self)
        self.currentStageOrdinal = self.currentStageOrdinal + 1
        if self.currentStageOrdinal > #self.stageList then
            self.currentStageOrdinal = 1
        end
        self.hasLoaded = false
        self:loadStage()
    end;
    populateStageObstacles = function(self)
        if not self.hasLoaded then
            print("[STAGEMANAGER] Attempted to populate obstacles before loading stage")
        else
            for i, item in ipairs(self.loadedStage.data) do
                if item.shape == "CircularObstacle" then
                    table.insert(self.obstacles, CircularObstacle(item.x, item.y, item.radius))
                elseif item.shape == "CircularGoal" then
                    table.insert(self.obstacles, CircularGoal(item.x, item.y, item.radius))
                elseif item.shape == "CircularSpawn" then
                    table.insert(self.spawns, CircularSpawn(item.x, item.y, item.radius))
                elseif item.shape == "CircularTrap" then
                    table.insert(self.obstacles, CircularTrap(item.x, item.y, item.radius))
                elseif item.shape == "RectangularObstacle" then
                    table.insert(self.obstacles, RectangularObstacle(item.x, item.y, item.width, item.height, item.rotation, item.rotates))
                elseif item.shape == "RectangularGoal" then
                    table.insert(self.obstacles, RectangularGoal(item.x, item.y, item.width, item.height, item.rotation, item.rotates))
                elseif item.shape == "RectangularSpawn" then
                    table.insert(self.spawns, RectangularSpawn(item.x, item.y, item.width, item.height, item.rotation, item.rotates))
                elseif item.shape == "RectangularTrap" then
                    table.insert(self.obstacles, RectangularTrap(item.x, item.y, item.width, item.height, item.rotation, item.rotates))
                elseif item.shape == "TriangularObstacle" then
                    table.insert(self.obstacles, TriangularObstacle(item.x, item.y, item.length, item.rotation, item.rotates))
                elseif item.shape == "TriangularGoal" then
                    table.insert(self.obstacles, TriangularGoal(item.x, item.y, item.length, item.rotation, item.rotates))
                elseif item.shape == "TriangularSpawn" then
                    table.insert(self.spawns, TriangularSpawn(item.x, item.y, item.length, item.rotation, item.rotates))
                elseif item.shape == "TriangularTrap" then
                    table.insert(self.obstacles, TriangularTrap(item.x, item.y, item.length, item.rotation, item.rotates))
                end
            end
        end
    end;
    getStageDimensions = function(self)
        if not self.hasLoaded then
            print("[STAGEMANAGER] Attempted to access stage dimensions before loading")
        else
            return self.loadedStage.width, self.loadedStage.height
        end
    end;
    drawObstacles = function(self)
        for i, spawn in ipairs(self.spawns) do
            spawn:draw('fill')
        end
        for i, obstacle in ipairs(self.obstacles) do
            obstacle:draw('fill')
        end
    end;
    addRandomObstacle = function(self, x, y)
        local choice = love.math.random(2)
        if choice == 1 then
            local randomWidth = love.math.random(50, 100)
            local randomHeight = love.math.random(50, 100)
            table.insert(self.obstacles, RectangularObstacle(x-randomWidth/2, y-randomHeight/2, randomWidth, randomHeight))
        elseif choice == 2 then
            table.insert(self.obstacles, CircularObstacle(x, y, love.math.random(8,50)))
        end
    end;
    update = function(self, dt)
        for i=#self.obstacles,1,-1 do --back to front so we can safely remove (https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating)
            local obstacle = self.obstacles[i]
            local kill = obstacle:update(dt)
            if kill then
                table.remove(self.obstacles, i)
            end
        end
    end;
    testPointForSpawning = function(self, x, y)
        local allowSpawn = false
        for i, spawn in ipairs(self.spawns) do
            if spawn.fixture:testPoint(x, y) then
                allowSpawn = true
            end
        end
        return allowSpawn
    end;
}
