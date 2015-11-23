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

return utils
