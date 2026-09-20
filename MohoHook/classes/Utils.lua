HT.Utils = {}

function HT.Utils:getType(value)
    return type(value)
end

function HT.Utils:toString(value)
    return tostring(value)
end

function HT.Utils:isString(value)
    return HT.Utils:getType(value) == "string"
end

function HT.Utils:isEmptyString(value)
    return HT.Utils:isString(value) and value == ""
end

function HT.Utils:toNumber(value)
    return tonumber(value)
end

function HT.Utils:isNumber(value)
    return HT.Utils:getType(value) == "number"
end

function HT.Utils:toInteger(value)
    return math.floor(value)
end

function HT.Utils:isInteger(value)
    return HT.Utils:isNumber(value) and HT.Utils:toString(value % 1) == "0"
end

function HT.Utils:getRandomNumber(min, max, float)
    if float then
        return math.random(min, max - 1) + math.random()
    else
        return math.random(min, max)
    end
end

function HT.Utils:jsonEncode(value)
    return json.encode(value)
end

function HT.Utils:jsonDecode(value)
    return json.decode(value)
end

function HT.Utils:readFile(filePath)
    if not io.file_is_readable(filePath) then
        return false
    end
    local file = io.open(filePath, "r")
    if not file then
        return false
    end
    local content = file:read("*all")
    file:close()
    return content
end

function HT.Utils:writeFile(filePath, content, mode)
    local file = io.open(filePath, mode or "w+")
    if not file then
        return false
    end
    file:write(content)
    file:close()
    return true
end

function HT.Utils:getSaveTable(fileName)
    local content = HT.Utils:readFile(SavePath .. fileName)
    if not content then
        return {}
    end
    return HT.Utils:jsonDecode(content)
end

function HT.Utils:setSaveTable(fileName, table)
    local content = HT.Utils:jsonEncode(table)
    return HT.Utils:writeFile(SavePath .. fileName, content)
end

function HT.Utils:getToggleValue(value)
    return value == "on"
end

function HT.Utils:inTable(element, table)
    for key, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function HT.Utils:isTableEmpty(table)
    return next(table) == nil
end

function HT.Utils:countTable(table)
    local count = 0
    for key, value in pairs(table) do
        count = count + 1
    end
    return count
end

function HT.Utils:getRandomElementFromTable(table)
    local count = HT.Utils:countTable(table)
    if count == 0 then
        return nil
    end
    return table[HT.Utils:getRandomNumber(1, count)]
end

function HT.Utils:getPathBaseName(path)
    return path:match("[^/]+$")
end
