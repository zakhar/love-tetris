local shapes = require("shapes")
local utils = require("utils")


math.randomseed(os.time())


GRID_SIZE = 16


Figure = {}
function Figure:new(num, x, y)
    local obj = {
        shape = nil,
        x = 0,
        y = 0,
    }
    if num then
        obj.shape = utils.stringToTable(shapes[num])
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end


function Figure:new_random()
    return self:new(math.random(#shapes))
end


function Figure:copy()
    local r = Figure:new()
    r.shape = utils.copy_table(self.shape)
    r.x = self.x
    r.y = self.y
    return r
end


function Figure:getWidth()
    return #self.shape[1]
end


function Figure:getHeight()
    return #self.shape
end


function Figure:moveRight()
    self.x = self.x + 1
end


function Figure:moveLeft()
    self.x = self.x - 1
end


function Figure:moveDown()
    self.y = self.y + 1
end


function Figure:rotateRight()
    self.shape = utils.tableRotateRight(self.shape)
end


function Figure:draw(x, y)
    x = x or 0
    y = y or 0
    for rowIdx, row in ipairs(self.shape) do
        for colIdx, char in ipairs(row) do
            drawBlock(char, x + self.x - 2 + colIdx, y + self.y - 2 + rowIdx)
        end
    end
end

WINDOW_WIDTH = 400
WINDOW_HEIGHT = 500
SCENE_CUP_WIDTH = 15
SCENE_CUP_HEIGHT = 25
SCENE_CUP_X = 3
SCENE_CUP_Y = 3

SCENE_FIGURE_X = 1
SCENE_FIGURE_Y = 1


Scene = {}
function Scene:new()
    local o = {
        currentFigure = Figure:new_random(),
        nextFigure = Figure:new_random(),
        cup = utils.createMat(SCENE_CUP_HEIGHT, SCENE_CUP_WIDTH, "."),
    }

    setmetatable(o, self)
    self.__index = self

    o:generateNextFigure()
    return o
end


function Scene:generateNextFigure()
    self.currentFigure = self.nextFigure
    self.currentFigure.x = SCENE_FIGURE_X
    self.currentFigure.y = SCENE_FIGURE_Y

    self.nextFigure = Figure:new_random()
end


function Scene:isCollision(figure)
    if (figure.x < 1) or (figure.x + figure:getWidth() - 1 > SCENE_CUP_WIDTH) then
        return true
    end
    if (figure.y < 1) or (figure.y + figure:getHeight() - 1 > SCENE_CUP_HEIGHT) then
        return true
    end

    for r = 1, #figure.shape do
        for c = 1, #figure.shape[1] do
            local fig = figure.shape[r][c]
            local cup = self.cup[figure.y - 1 + r][figure.x - 1 + c]
            if fig ~= '.' and cup ~= '.' then
                return true
            end
        end
    end
    return false
end


function Scene:moveFigureLeft()
    local futureFigure = self.currentFigure:copy()
    futureFigure:moveLeft()
    if not self:isCollision(futureFigure) then
        self.currentFigure = futureFigure
    end
end


function Scene:moveFigureRight()
    local futureFigure = self.currentFigure:copy()
    futureFigure:moveRight()
    if not self:isCollision(futureFigure) then
        self.currentFigure = futureFigure
    end
end


function Scene:rotateFigureRight()
    local futureFigure = self.currentFigure:copy()
    futureFigure:rotateRight()
    if not self:isCollision(futureFigure) then
        self.currentFigure = futureFigure
    end
end


function Scene:moveFigureDown()
    local futureFigure = self.currentFigure:copy()
    futureFigure:moveDown()
    if self:isCollision(futureFigure) then
        self:unite(self.currentFigure)
        self:checkFilled()
        self:generateNextFigure()
    else
        self.currentFigure = futureFigure
    end
end


function Scene:unite(figure)
    for r = 1, #figure.shape do
        for c = 1, #figure.shape[1] do
            local char = figure.shape[r][c]
            if char  ~= "." then
                self.cup[figure.y + r - 1][figure.x + c - 1] = char
            end
        end
    end

end


function Scene:checkFilled()
    for r = 1, #self.cup do
        local filled = true
        for c = 1, #self.cup[1] do
            if self.cup[r][c] == "." then
                filled = false
                break
            end
        end
        if filled then
            self:removeLine(r)
        end
    end
end


function Scene:removeLine(row)
    if row > 1 then
        for r = row, 2, -1 do
            for c = 1, #self.cup[r] do
                self.cup[r][c] = self.cup[r-1][c]
            end
        end
    end

    for c = 1, #self.cup[1] do
        self.cup[1][c] = "."
    end
end

function Scene:draw()
    -- draw cup
    for c = 0, SCENE_CUP_WIDTH + 1 do
        drawBlock("x", SCENE_CUP_X + c - 1, SCENE_CUP_Y + SCENE_CUP_HEIGHT)
    end
    for r = 1, SCENE_CUP_HEIGHT do
        drawBlock("x", SCENE_CUP_X - 1, SCENE_CUP_Y + r - 1)
        drawBlock("x", SCENE_CUP_X + SCENE_CUP_WIDTH, SCENE_CUP_Y + r - 1)
    end
    for rowIdx, row in ipairs(self.cup) do
        for colIdx, char in ipairs(row) do
            drawBlock(char, SCENE_CUP_X + colIdx - 1, SCENE_CUP_Y + rowIdx - 1)
        end
    end

    -- draw figure
    if self.currentFigure then
        self.currentFigure:draw(SCENE_CUP_X, SCENE_CUP_Y)
    end
    if self.nextFigure then
        self.nextFigure:draw(SCENE_CUP_X + SCENE_CUP_WIDTH + 3, SCENE_CUP_Y + 1)
    end
end


COLORS = {
    ["x"] = {30, 100, 30},
    ["="] = {250, 255, 0},
    ["1"] = {0, 228, 255},
    ["@"] = {246, 0, 0},
    ["o"] = {105, 182, 37},
    ["n"] = {255, 141, 0},
    ["#"] = {255, 81, 188},
    ["*"] = {255, 81, 188},
}


function getColor(type)
    return COLORS[type]
end


function drawBlock(type, x, y)
    local color = getColor(type)
    if not color then
        return
    end

    love.graphics.setColor(unpack(color))
    love.graphics.rectangle(
        "fill", GRID_SIZE * x, GRID_SIZE * y, GRID_SIZE, GRID_SIZE)
    love.graphics.setColor(unpack(utils.arrMul(color, 0.85)))
    love.graphics.rectangle(
        "line", GRID_SIZE * x, GRID_SIZE * y, GRID_SIZE, GRID_SIZE)
end


function love.load()
    love.keyboard.setKeyRepeat(true)
    scene = Scene:new()
    time = 0
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT,
                        {resizable=false, vsync=true})
    love.window.setTitle("Tetris")
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "left" then
        scene:moveFigureLeft()
    elseif key == "right" then
        scene:moveFigureRight()
    elseif key == "up" then
        scene:rotateFigureRight()
    elseif key == "down" then
        scene:moveFigureDown()
    end
end

MOVE_DOWN_DURATION = 1
function love.update(dt)
    time = time + dt
    if time > MOVE_DOWN_DURATION then
        time = time - MOVE_DOWN_DURATION
        scene:moveFigureDown()
    end
end


function love.draw()
    scene:draw()
end
