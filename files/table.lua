--[[
    table
]]

function table.new(t, mode)
    assert(t ~= table)
    assert(t == nil or type(t) == 'table')
    return setmetatable(t or {}, {__index = table, __mode = mode})
end

function table.new_with_weak_key(t)
    return table.new(t, 'k')
end

function table.new_with_weak_value(t)
    return table.new(t, 'v')
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

function table.sub(this, from, to)
    assert(is_array(this))
    local ret = {}
    local len = #this
    from = from or 1
    to = to or #this
    if from < 0 then
        from = from + len + 1
    end
    if to < 0 then
        to = to + len + 1
    end
    from = math.max(0, math.min(from, len))
    to = math.max(0, math.min(to, len))
    for i=from,to do
        table.insert(ret, this[i])
    end
    return ret
end

function table.filter(this, func)
    local ret = {}
    table.foreach(this, function(k, v)
        if func(k, v) then
            if is_array(this) then
                table.insert(ret, v)
            else
                ret[k] = v
            end
        end
    end)
    return ret
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
    return is_array(this)
end

function table.implode(this, separator)
    return table.concat(this, separator)
end

function table.explode(s, separator, maxCount)
    return string.explode(s, separator, maxCount)
end

function table.read_from_file(path)
    assert(is_string(path))
    local c = files.read(path)
    if not c then return end
    return c:table()
end

function table.write_to_file(this, path)
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

local function convert_key(key, isEcho)
    local t = type(key)
    if t == 'number' then
        return isEcho and "(" .. tostring(key) .. ")" or "[" .. key .. "]" 
    elseif t == 'string' then
        return isEcho and "[" .. key .. "]" or tostring(key)
    end
end

local function convert_value(value, isEcho)
    local t = type(value)
    if t == 'boolean' then
        return tostring(value)
    elseif t == 'number' then
        return "" .. value .. ""
    elseif t == 'string' then
        return "\"" .. value .. "\""
    elseif not isEcho then
        return
    elseif t == 'function' then
        return "[" .. tostring(value) .. "]"
    elseif is_class(value) then
        return "[Class:" .. tostring(value) .. "]"
    elseif is_object(value) then
        return "[Object:" .. tostring(value) .. "]"
    else
        return tostring(value)
    end
end

function table.string(this, blank, keys, isEcho, withHidden, arrKeyless, _storey)
    --
    assert(is_table(this))
    _storey = _storey or 1
    local result = table.new()
    blank = blank or "    "
    --
    local function try_convert(k, v, ignoreKey)
        local valid = withHidden or not string.starts(k, "__")
        local key = convert_key(k, isEcho)
        local value = nil
        if is_table(v) then
            value = table.string(v, blank, keys, isEcho, withHidden, arrKeyless, _storey + 1)
        else
            value = convert_value(v, isEcho)
        end
        if valid and key and value then
            if ignoreKey then
                result:insert(blank:rep(_storey) .. value)
            else
                result:insert(blank:rep(_storey) .. key .. " = " .. value)
            end
        end
    end
    --
    if table.is_array(this) then
        for i,v in ipairs(this) do try_convert(i, v, arrKeyless) end
    elseif keys then
        for i,k in ipairs(keys) do
            local v = this[k]
            if v then
                try_convert(k, v)
            end
        end
    else
        for k,v in pairs(this) do try_convert(k, v) end
    end
    local content = ""
    if #result > 0 then
        content = "\n" .. result:implode(",\n") .. ",\n"
        content = content .. blank:rep(_storey - 1)
    end
    return string.new("{" .. content .. "}")
end

function table.printable(this, blank, keys)
    return table.string(this, blank, keys, nil, true)
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
    print("[table:" .. lua_get_pointer(this) .. "](" .. table.printable(this, "| ") .. ")")
end

function table.is_empty(this)
    return next(this) == nil
end

function table.is_equal(this, that)
    assert(is_table(this))
    if not is_table(that) then
        return false
    end
    for k, v in pairs(this) do
        if is_table(v) then
            if not table.is_equal(v, that[k]) then
                return false
            end
        else
            if v ~= that[k] then
                return false
            end
        end
    end
    for k, v in pairs(that) do
        if is_table(v) then
            if not table.is_equal(v, this[k]) then
                return false
            end
        else
            if v ~= this[k] then
                return false
            end
        end
    end
    return true
end

function table.is_same(this, that)
    assert(is_table(this))
    if not is_table(that) then
        return false
    end
    for k, v in pairs(this) do
        if is_table(v) then
            if not table.is_same(v, that[k]) then
                return false
            end
        else
            if type(v) ~= type(that[k]) then
                return false
            end
        end
    end
    for k, v in pairs(that) do
        if is_table(v) then
            if not table.is_same(v, this[k]) then
                return false
            end
        else
            if type(v) ~= type(this[k]) then
                return false
            end
        end
    end
    return true
end

function table.find_value(this, value)
    local rKey, rVal = nil, nil
    table.foreach(this, function(k, v)
        if v == value then
            rKey, rVal = k, v
            return true
        end
    end)
    return rKey, rVal
end

function table.find_key(this, key)
    local rKey, rVal = nil, nil
    table.foreach(this, function(k, v)
        if k == key then
            rKey, rVal = k, v
            return true
        end
    end)
    return rKey, rVal
end

function table.find_if(this, func)
    local rKey, rVal = nil, nil
    table.foreach(this, function(k, v)
        if func(k, v) then
            rKey, rVal = k, v
            return true
        end
    end)
    return rKey, rVal
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
        return nil
    end)
    return this
end

function table.foreach(this, func)
    if table.is_array(this) then
        for i,v in ipairs(this) do
            if func(i,v) then
                return
            end
        end
    else
        for k,v in pairs(this) do 
            if func(k,v) then
                break
            end
        end
    end
end

function table.map(this, func)
    local ret = {}
    table.foreach(this, function(k, v)
        local r = func(k,v)
        if r then
            if is_array(this) then
                table.insert(ret, r)
            else
                ret[k] = r
            end
        end
    end)
    return ret
end

function table.reduce(this, func, accumulator)
    if not is_function(func) and is_function(accumulator) then
        local temp = func
        func = accumulator
        accumulator = temp
    end
    table.foreach(this, function(k, v)
        if not accumulator then
            if is_number(v) then
                accumulator = 0
            elseif is_string(v) then
                accumulator = ""
            elseif is_table(v) then
                accumulator = {}
            end
        end
        accumulator = func(accumulator, v)
    end)
    return accumulator
end

function table.reverse(this)
    local ret = {}
    for i = #this, 1, -1 do
        table.insert(ret, this[i])
    end
    return ret
end

function table.append(this, other)
    for i,v in ipairs(other) do
        table.insert(this, v)
    end
end

function table.remove_value(this, value, count)
    local num = 0
    local key = table.find_value(this, value)
    while key and (not count or num < count) do
        table.remove_key(this, key)
        num = num + 1
        key = table.find_value(this, value)
    end
end

function table.remove_key(this, key)
    if is_array(this) then
        assert(is_number(key))
        table.remove(this, key)
    else
        assert(is_number(key) or is_string(key))
        this[key] = nil
    end
end

function table.remove_if(this, func)
    if is_array(this) then
        for i = #this, 1, -1 do
            if func(i, this[i]) then
                table.remove(this, i)
            end
        end
    else
        for k,v in pairs(this) do
            if func(k, this[k]) then
                this[k] = nil
            end
        end
    end
end
