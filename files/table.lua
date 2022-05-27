--[[
    table
]]

function table.new(v)
    assert(v ~= table)
    assert(v == nil or type(v) == 'table')
    return setmetatable(v or {}, {__index = table,})
end

function table.clear(this)
    for k,v in pairs(this) do
        this[k] = nil
    end
    return this
end

function table.keys(this)
    local keys = table.new()
    for key, _ in pairs(this) do
        table.insert(keys, key)
    end
    return keys
end

function table.values(this)
    local values = table.new()
    for _, value in pairs(this) do
        table.insert(values, value)
    end
    return values
end

function table.merge(this, that)
    for k,v in pairs(that) do
        this[k] = v
    end
    return this
end

function table.copy(this)
    local tbs = table.new()
    local function cp(t)
        if type(t) ~= 'table' then return t end
        local ret = tbs[t]
        if ret then return ret end
        ret = table.new()
        tbs[t] = ret
        for k, v in pairs(t) do
            ret[k] = cp(v)
        end
        return ret
    end
    return cp(this)
end

function table.count(this, countKeyType, countValueType)
    local totalCount = 0
    local keyCount = 0
    local valueCount = 0
    local k,v = next(this)
    while k do
        totalCount = totalCount + 1
        if countKeyType and type(k) == countKeyType then
            keyCount = keyCount + 1
        end
        if countValueType and type(v) == countValueType then
            valueCount = valueCount + 1
        end
        k, v = next(this, k)
    end
    return totalCount, keyCount, valueCount
end


function table.is_array(this)
    local totalCount, typedCount, _ = table.count(this, 'number', nil)
    return totalCount == typedCount and typedCount == #this
end

function table.implode(this, separator)
    return table.concat(this, separator)
end


table.read_from_file = function(path)
    assert(is_string(path))
    local c = files.read(path)
    if not c then return end
    return c:table()
end

table.write_to_file = function(this, path)
    assert(is_table(this))
    assert(is_string(path))
    files.write(path, table.string(this))
end

local function to_string(v)
    local t = type(v)
    if t == 'nil' or t == 'number' or t == 'string' then
        return tostring(v)
    end
end

function table.string(this, storey)
    --
    assert(is_table(this))
    storey = storey or 1
    local result = table.new()
    local blank = "    "
    --  
    local function convert_key(key)
        local t = type(key)
        if t == 'number' then
            return "[" .. key .. "]"
        elseif t == 'string' then
            return tostring(key) -- "[\"" .. key .. "\"]"
        end
    end

    local function convert_value(value)
        local t = type(value)
        if t == 'number' then
            return "" .. value .. ""
        elseif t == 'string' then
            return "\"" .. value .. "\""
        end
    end
    --
    local function try_convert(k, v)
        local key = convert_key(k)
        local value = is_table(v) and table.string(v, storey + 1) or convert_value(v)
        if key and value then
            result:insert(blank:rep(storey) .. key .. " = " .. value)
        end
    end
    --
    if table.is_array(this) then
        for i,v in ipairs(this) do try_convert(i, v) end
    else
        for k,v in pairs(this) do try_convert(k, v) end
    end
    return string.new("{\n" .. result:implode(",\n") .. "\n" .. blank:rep(storey - 1) .. "}")
end

function table.encode(this)
    assert(is_table(this))
    return this:string()
end

function table.decode(st)
    assert(is_string(st))
    return st:table()
end

function table.print(this)
    print("[table:" .. lua_get_pointer(this) .. "]")
    print("[[[[[[[")
    print(table.string(this))
    print("]]]]]]]")
end

function table.is_empty(this)
    return next(this) == nil
end

function table.find_value(this, value)
    for k, v in pairs(this) do
        if value == v then
            return k, v
        end
    end
end


function table.find_key(this, key)
    for k, v in pairs(this) do
        if key == k then
            return k, v
        end
    end
end

function table.find_if(this, func)
    for k, v in pairs(this) do
        if func(k, v) then
            return k, v
        end
    end
end

function table.reorder(this, isAsc, ...)
    local conditions = {...} 
    if #conditions == 0 then
        return this
    end
    local condition = nil
    table.sort(this, function(t1, t2)
        for i = 1, #conditions do
            condition = conditions[i]
            if t1[condition] ~= t2[condition] then
                if isAsc then
                    return t1[condition] < t2[condition]
                else
                    return t1[condition] > t2[condition]
                end
            end
        end
    end)
    return this
end

function table.foreach(this, func)
    if table.is_array(this) then
        for i,v in ipairs(this) do
            func(i,v)
        end
    else
        for k,v in pairs(this) do
            func(k,v)
        end
    end
end
