local utils = {}


function utils.toArray(...)
    local arr = {}
    for v in ... do
        arr[#arr + 1] = v
    end
    return arr
end


function utils.stringToTable(str)
    local resTable = {}
    local rowsArray = utils.toArray(str:gmatch("[^\n]+"))

    for _, line in pairs(rowsArray) do
        resTable[#resTable + 1] = utils.toArray(line:gmatch("."))
    end
    return resTable
end

function utils.tableRotateRight(tbl)
    local h = #tbl
    local new = {}
    for r, row in ipairs(tbl) do
        for c, val in ipairs(row) do
            if not new[c] then
                new[c] = {}
            end
            new[c][h - r + 1] = val
        end
    end
    return new
end

function utils.arrMul(arr, coef)
    local new = {}
    for i, val in ipairs(arr) do
        new[i] = val * coef
    end
    return new
end


function utils.createMat(rows, cols, val)
    local t = {}
    for i = 1, rows do
        t[i] = {}
        for j = 1, cols do
            t[i][j] = val
        end
    end
    return t
end


-- https://gist.github.com/tylerneylon/81333721109155b2d244
function utils.copy_table(obj, seen)
    -- Handle non-tables and previously-seen tables.
    if type(obj) ~= 'table' then
        return obj
    end
    if seen and seen[obj] then
        return seen[obj]
    end

    -- New table; mark it as seen an copy recursively.
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do
        res[utils.copy_table(k, s)] = utils.copy_table(v, s)
    end
    return res
end

return utils
