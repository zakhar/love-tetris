
local utils = require("utils")
local shapes = require("shapes")

math.randomseed(os.time())

FloatYPositionSpeed = 1
GridSize = 16

local Figure = {
    text = "xx",
    shape = utils.stringToTable(shapes[math.random(#shapes)]),
    floatYPosition = 1,
    x = 10,
    y = 1,
}

function Figure:draw()
    for rowIdx, row in ipairs(self.shape) do
        for colIdx, char in ipairs(row) do
            drawBlock(char, self.x + colIdx, self.y + rowIdx)
        end
    end
end

function Figure:rotateRight()
    self.shape = utils.tableRotateRight(self.shape)
end


function Figure:moveRight()
    self.x = self.x + 1
end


function Figure:moveLeft()
    self.x = self.x - 1
end


local Cup = {
    x = 1,
    y = 1,
    w = 20,
    h = 35,
    field = nil
}

function Cup:init()
    self.field = utils.createMat(self.h, self.w, ".")
end

function Cup:draw()
    for c = 1, self.w + 1 do
        drawBlock("x", self.x + c - 1, self.h)
    end
    for r = 1, self.h - 1 do
        drawBlock("x", 1, self.y + r - 1)
        drawBlock("x", self.w + 1, self.y + r - 1)
    end
    for rowIdx, row in ipairs(self.field) do
        for colIdx, char in ipairs(row) do
            drawBlock(char, self.x + colIdx - 1, self.y + rowIdx - 1)
        end
    end

end

function Cup:collision(figure)
    for r = 1, #figure.shape do
        for c = 1, #figure.shape[0] do
            local fig = figure.shape[r][c]
            local cup = self.field[1]
        end
    end
end

function drawBlock(type, x, y)
    local color
    if type == "*" then
        color = {120, 30, 30}
    elseif type == "x" then
        color = {30, 120, 30}
    else
        return
    end

    love.graphics.setColor(unpack(color))
    love.graphics.rectangle(
        "fill", GridSize * x, GridSize * y, GridSize, GridSize)
    love.graphics.setColor(unpack(utils.arrMul(color, 0.85)))
    love.graphics.rectangle(
        "line", GridSize * x, GridSize * y, GridSize, GridSize)
end

function love.load()
    love.keyboard.setKeyRepeat(false)
    Cup:init()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "left" then
        Figure:moveLeft()
    elseif key == "right" then
        Figure:moveRight()
    elseif key == "up" then
        Figure:rotateRight()
    end
end


function love.update(dt)
    Figure.floatYPosition = Figure.floatYPosition + FloatYPositionSpeed * dt
    Figure.y = math.floor(Figure.floatYPosition)
end


function love.draw()
    Cup:draw()
    Figure:draw()
end
