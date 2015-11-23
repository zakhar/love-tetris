
local utils = require("utils")
local shapes = require("shapes")

math.randomseed(os.time())

FloatYPositionSpeed = 0.5
GridSize = 16

local Figure = {
    text = "xx",
    shape = utils.stringToTable(shapes[math.random(#shapes)]),
    floatYPosition = 0,
    x = 10,
    y = 10,
}

function Figure:draw()
    for rowIdx, row in ipairs(self.shape) do
        for colIdx, char in ipairs(row) do
            drawBlock(char, self.x + colIdx, self.y + rowIdx)
        end
    end
end

function Figure:rotateRight()
    local h = #self.shape
    local new = {}
    for r, row in ipairs(self.shape) do
        for c, val in ipairs(row) do
            if not new[c] then
                new[c] = {}
            end
            new[c][h - r + 1] = val
        end
    end
    self.shape = new
end

function drawBlock(type, x, y)
    if type == "*" then
        love.graphics.setColor(128, 33, 33)
        love.graphics.rectangle(
            "fill", GridSize * x, GridSize * y, GridSize, GridSize)
        love.graphics.setColor(208, 33, 33)
        love.graphics.rectangle(
            "line", GridSize * x, GridSize * y, GridSize, GridSize)
    end
end

function love.load()
    love.keyboard.setKeyRepeat(false)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "left" then
        Figure.x = Figure.x - 1
    elseif key == "right" then
        Figure.x = Figure.x + 1
    elseif key == "up" then
        Figure:rotateRight()
    end
end


function love.update(dt)
    Figure.floatYPosition = Figure.floatYPosition + FloatYPositionSpeed * dt
    Figure.y = math.floor(Figure.floatYPosition)
end


function love.draw()
    Figure:draw()
end
