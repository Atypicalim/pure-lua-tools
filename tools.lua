
-- tools:[2023-06-27_21:50:43]

-- file:[./files/lua.lua]

function is_table(v)
    return type(v) == 'table'
end
function is_string(v)
    return type(v) == 'string'
end
function is_number(v)
    return type(v) == 'number'
end
function is_boolean(v)
    return type(v) == 'boolean'
end
function is_nil(v)
    return type(v) == 'nil'
end
function is_function(v)
    return type(v) == 'function'
end
function is_class(v)
    return is_table(v) and v.__type__ == 'class'
end
function is_object(v)
    return is_table(v) and v.__type__ == 'object'
end
function to_type(v, tp)
    if type(v) == tp then
        return v
    elseif tp == 'string' then
        return tostring(v)
    elseif tp == 'number' then
        return tonumber(v)
    elseif tp == 'boolean' then
        if is_string(v) then
            v = v:lower()
            if v == 'true' then
                return true
            elseif v == 'false' then
                return false
            else
                return nil
            end
        elseif is_number(v) then
            if v == 1 then
                return true
            elseif v == 0 then
                return false
            else
                return nil
            end
        else
            return nil
        end
    else
        return nil
    end
end
function lua_to_string(t)
    local m = getmetatable(t)
    if m and m.__tostring then
        local tmp = m.__tostring
        m.__tostring = nil
        local ret = tostring(t)
        m.__tostring = tmp
        return ret
    else
        return tostring(t)
    end
end
function lua_get_pointer(v)
    local t = type(v)
    if t == "function" or t == "table" then
        local s = lua_to_string(v):explode(": ")
        return s[2]
    else
        return nil
    end
end

-- file:[./files/number.lua]

number = number or {}
function number.is_odd(v)
    return v % 2 ~= 0
end
function number.is_even()
    return not number.is_odd(v)
end
function number.is_int(v)
    return math.floor(v) == v
end
function number.is_float(v)
    return not number.is_int(v)
end

-- file:[./files/math.lua]

function math.radian(angle)
    return angle * math.pi / 180
end
function math.angle(radian)
    return radian * 180 / math.pi
end
function math.round(value)
    return math.floor(value  + 0.5)
end

-- file:[./files/string.lua]

function string.new(v)
    assert(v ~= string)
    assert(v == nil or type(v) == 'string')
    return v or ""
end
function string.append(this, other)
    return this .. other
end
function string.prepend(this, other)
    return other .. this
end
function string.ltrim(this, pattern)
    pattern = pattern or " \t\n\r"
    return string.gsub(this, "^[" .. pattern .. "]+", "")
end
function string.rtrim(this, pattern)
    pattern = pattern or " \t\n\r"
    return string.gsub(this, "[" .. pattern .. "]+$", "")
end
function string.trim(this, pattern)
    return this:ltrim(pattern):rtrim(pattern)
end
function string.slash(this)
    return this:gsub('\\', '/')
end
function string.explode(this, separator, maxCount)
    assert(is_string(this))
    assert(is_string(separator))
    local splitArray = table.new()
    if #this == 0 then
        return splitArray
    end
    if #separator == 0 then
        for i=1,#this do
            if #splitArray >= maxCount then
                splitArray[i] = string.sub(this, i, string.len(this))
                break
            end
            splitArray[i] = string.sub(this, i, i)
        end
        return splitArray
    end
    local startIndex = 1
    local splitIndex = 1
    while true do
        local foundIndex, endIndex = string.find(this, separator, startIndex)
        if not foundIndex or (maxCount and #splitArray >= maxCount) then
            splitArray[splitIndex] = string.sub(this, startIndex, string.len(this))
            break
        end
        splitArray[splitIndex] = string.sub(this, startIndex, foundIndex - 1)
        startIndex = foundIndex + (endIndex - foundIndex + 1)
        splitIndex = splitIndex + 1
    end
    return splitArray
end
function string.valid(v)
    return type(v) == 'string' and #v > 0
end
function string.center(this, len, char)
    len = math.max(len, 0)
    local need = len - #this
    if need <= 0 then
        return this:sub(1, len)
    else
        local l = math.floor(need / 2)
        local r = need - l
        return char:rep(l) .. this .. char:rep(r)
    end
end
function string.left(this, len, char)
    len = math.max(len, 0)
    local need = len - #this
    return need <= 0 and this:sub(1, len) or this .. char:rep(need)
end
function string.right(this, len, char)
    len = math.max(len, 0)
    local need = len - #this
    return need <= 0 and this:sub(#this - len + 1, #this) or char:rep(need) .. this
end
function string.table(this)
    local f = loadstring("return " .. this)
    if not f then return end
    local t = f()
    if not is_table(t) then return end
    return table.new(t)
end
function string.encode(tb)
    assert(is_table(tb))
    return tb:string()
end
function string.decode(this)
    assert(is_string(this))
    return this:table()
end
function string.print(this)
    print(this)
end
function string.execute(this)
    local f = loadstring(this)
    assert(is_function(f), "invalid script string")
    return f()
end
function string.escape(s)
    s = s:gsub('%%', '%%%%')
    :gsub('^%^', '%%^')
    :gsub('%$$', '%%$')
    :gsub('%(', '%%(')
    :gsub('%)', '%%)')
    :gsub('%.', '%%.')
    :gsub('%[', '%%[')
    :gsub('%]', '%%]')
    :gsub('%*', '%%*')
    :gsub('%+', '%%+')
    :gsub('%-', '%%-')
    :gsub('%?', '%%?')
    return s
end
function string.starts(this, s)
    return string.sub(this, 1, #s) == s
end
function string.ends(this, s)
    return string.sub(this, -#s, -1) == s
end

-- file:[./files/table.lua]

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
function table.string(this, blank, keys, _storey)
    assert(is_table(this))
    _storey = _storey or 1
    local result = table.new()
    blank = blank or "    "
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
    local function try_convert(k, v)
        local key = convert_key(k)
        local value = is_table(v) and table.string(v, blank, keys, _storey + 1) or convert_value(v)
        if key and value then
            result:insert(blank:rep(_storey) .. key .. " = " .. value)
        end
    end
    if table.is_array(this) then
        for i,v in ipairs(this) do try_convert(i, v) end
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
    return string.new("{\n" .. result:implode(",\n") .. "\n" .. blank:rep(_storey - 1) .. "}")
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
    return true
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

-- file:[./files/json.lua]

json = json or {}
function json.null()
    return json.null -- so json.null() will also return json.null ; Simply set t = {first = json.null}
end
function json.encodable(o)
    local t = type(o)
    return (t == 'string' or t == 'boolean' or t == 'number' or t == 'nil' or t == 'table') or (t == 'function' and o == json.null)
end
function json._encodeString(s)
    s = string.gsub(s, '\\', '\\\\')
    s = string.gsub(s, '"', '\\"')
    s = string.gsub(s, "'", "\\'")
    s = string.gsub(s, '\n', '\\n')
    s = string.gsub(s, '\t', '\\t')
    return s
end
function json._encode(v)
    if is_nil(v) or v == json.null then return "null" end
    if is_boolean(v) or is_number(v) then return tostring(v) end
    if is_string(v) then return '"' .. json._encodeString(v) .. '"' end
    local rval = {}
    if table.is_array(v) then
        for i = 1, #v do
            table.insert(rval, json._encode(v[i]))
        end
        return '[' .. table.concat(rval, ',') .. ']'
    end
    if is_table(v) then
        for i, j in pairs(v) do
            if json.encodable(i) and json.encodable(j) then
                table.insert(rval, '"' .. json._encodeString(i) .. '":' .. json._encode(j))
            end
        end
        return '{' .. table.concat(rval, ',') .. '}'
    end
    assert(false, 'type not supported:' .. type(v))
end
function json._decode_scanWhitespace(s, startPos)
    local stringLen = string.len(s)
    while (string.find(" \n\r\t", string.sub(s, startPos, startPos), 1, true) and startPos <= stringLen) do
        startPos = startPos + 1
    end
    return startPos
end
function json._decode_scanObject(s, startPos)
    local object = {}
    local stringLen = string.len(s)
    local key, value
    startPos = startPos + 1
    repeat
        startPos = json._decode_scanWhitespace(s, startPos)
        assert(startPos <= stringLen, 'JSON string ended unexpectedly while scanning object.')
        local curChar = string.sub(s, startPos, startPos)
        if (curChar == '}') then return object, startPos + 1 end
        if (curChar == ',') then startPos = json._decode_scanWhitespace(s, startPos + 1) end
        assert(startPos <= stringLen, 'JSON string ended unexpectedly scanning object.')
        key, startPos = json._decode(s, startPos)
        assert(startPos <= stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
        startPos = json._decode_scanWhitespace(s, startPos)
        assert(startPos <= stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
        assert(string.sub(s, startPos, startPos) == ':', 'JSON string ended unexpectedly searching for assignment at ' .. startPos)
        startPos = json._decode_scanWhitespace(s, startPos + 1)
        assert(startPos <= stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
        value, startPos = json._decode(s, startPos)
        object[key] = value
    until false
end
function json._decode_scanArray(s, startPos)
    local array = {}
    local stringLen = string.len(s)
    startPos = startPos + 1
    repeat
        startPos = json._decode_scanWhitespace(s, startPos)
        assert(startPos <= stringLen, 'JSON String ended unexpectedly scanning array.')
        local curChar = string.sub(s, startPos, startPos)
        if (curChar == ']') then return array, startPos + 1 end
        if (curChar == ',') then startPos = json._decode_scanWhitespace(s, startPos + 1) end
        assert(startPos <= stringLen, 'JSON String ended unexpectedly scanning array.')
        object, startPos = json._decode(s, startPos)
        table.insert(array, object)
    until false
end
function json._decode_scanNumber(s, startPos)
    local endPos = startPos + 1
    local stringLen = string.len(s)
    while (string.find("+-0123456789.e", string.sub(s, endPos, endPos), 1, true) and endPos <= stringLen) do
        endPos = endPos + 1
    end
    local stringValue = string.sub(s, startPos, endPos - 1)
    local numberValue = tonumber(stringValue)
    assert(numberValue ~= nil, 'invalid number [ ' .. stringValue .. '] at:' .. startPos .. ' : ' .. endPos)
    return stringEval(), endPos
end
function json._decode_scanString(s, startPos)
    local startChar = string.sub(s, startPos, startPos)
    local escaped = false
    local endPos = startPos + 1
    local bEnded = false
    local stringLen = string.len(s)
    repeat
        local curChar = string.sub(s, endPos, endPos)
        if not escaped then
            if curChar == [[\]] then
                escaped = true
            else
                bEnded = curChar == startChar
            end
        else
            escaped = false
        end
        endPos = endPos + 1
        assert(endPos <= stringLen + 1, 'JSON string ended unexpectedly scanning string.')
    until bEnded
    local stringValue = 'return ' .. string.sub(s, startPos, endPos - 1)
    local stringEval = loadstring(stringValue)
    assert(stringEval, 'invalid string [ ' .. stringValue .. '] at ' .. startPos .. ' : ' .. endPos)
    return stringEval(), endPos
end
function json._decode_scanComment(s, startPos)
    local endPos = string.find(s, '*/', startPos + 2)
    assert(endPos ~= nil, "invalid comment tag!")
    return json._decode(s, endPos + 2)
end
function json._decode_scanConstants(s, startPos)
    local constValues = {true, false, nil}
    local constNames = {"true", "false", "null"}
    for _, k in pairs(constNames) do
        if string.sub(s, startPos, startPos + string.len(k) - 1) == k then
            return constValues[k], startPos + string.len(k)
        end
    end
    assert(false, 'invalid json value at:' .. startPos)
end
function json._decode(s, startPos)
    startPos = startPos and startPos or 1
    startPos = json._decode_scanWhitespace(s, startPos)
    assert(startPos <= string.len(s), 'Unterminated JSON encoded object found at position in [' .. s .. ']')
    local curChar = string.sub(s, startPos, startPos)
    if string.sub(s, startPos, startPos + 1) == '/*' then return json._decode_scanComment(s, startPos) end
    if curChar == '{' then return json._decode_scanObject(s, startPos) end
    if curChar == '[' then return json._decode_scanArray(s, startPos) end
    if curChar == [["]] or curChar == [[']] then return json._decode_scanString(s, startPos) end
    if string.find("+-0123456789.e", curChar, 1, true) then return json._decode_scanNumber(s, startPos) end
    return json._decode_scanConstants(s, startPos)
end
function json.encode(v)
    local isOk, r = xpcall(function() return json._encode(v) end, function(err) return err end)
    if isOk then return r, nil end
    return nil, r
end
function json.decode(s)
    local isOk, r = xpcall(function() return json._decode(s) end, function(err) return err end)
    if isOk then return r, nil end
    return nil, r
end

-- file:[./files/class.lua]

local classMap = {}
local function new(Class, ...)
    assert(is_class(Class), "invalid class table")
    local object = {
        __type__ = "object",
        __name__ = Class.__name__,
        __class__ = Class
    }
    local objectMeta = {
        __index = Class,
        __tostring = function(object)
            return string.format("<object %s>: %s", object.__name__, lua_get_pointer(object))
        end
    }
    local object = setmetatable(object, objectMeta)
    assert(object.__init__, string.format("not constructor for class: %s", object.__class__.__name__))
    object.__init__(object, ...)
    return object
end
assert(class == nil)
function class(name, Base)
    assert(is_string(name), "invalid class name")
    assert(is_nil(Base) or is_class(Base), "invalid class base")
    assert(is_nil(classMap[name]), "multiple class name")
    local Class = {
        __type__ = "class",
        __name__ = name,
        __super__ = Base
    }
    local ClassMeta = {
        __tostring = function(Class)
            return string.format("<Class %s>: %s", Class.__name__, lua_get_pointer(Class))
        end,
        __call = function(Class, ...)
            return new(Class, ...)
        end
    }
    if Class.__super__ then
        ClassMeta.__index = Class.__super__
    end
    setmetatable(Class, ClassMeta)
    return Class, Base
end

-- file:[./files/Path.lua]

assert(Path == nil)
Path = class("Path")
function Path:__init__(value)
    self._stack = {}
    self:set(value)
end
function Path:set(value)
    if value == "~" then
        value = os.getenv('HOME') or os.getenv('USERPROFILE')
    elseif value == "." then
        local cwd = io.popen"cd":read'*l'
        value = Path(cwd):get()
    elseif value == "/" or value == "\\" then
        local cwd = io.popen"cd":read'*l'
        value = Path(cwd)._stack[1]
    end
    value = value or ""
    value = value:gsub("\\+", "/"):gsub("/+", "/")
    value = value:trim():trim("/"):trim()
    self._stack = {}
    local arr = string.explode(value, "/")
    for i,v in ipairs(arr) do
        table.insert(self._stack, v)
    end
    return self
end
function Path:get(isCalculate, delimiter)
    isCalculate = isCalculate == true
    delimiter = delimiter or string.find(os.tmpname(""), "\\") and "\\" or "/"
    local stack = {}
    local value = ""
    for i,v in ipairs(self._stack) do
        if isCalculate and v == ".." then
            table.remove(stack, #stack)
        elseif isCalculate and v == "." then
            if #stack == 0 then
                table.insert(stack, v)
            end
        else
            table.insert(stack, v)
        end
    end
    for i,v in ipairs(stack) do
        value = i == 1 and v or value .. delimiter .. v
    end
    return value
end
function Path:push(...)
    local values = {...}
    local value = ""
    for i,v in ipairs(values) do
        value = value .. "/" .. v
    end
    return self:append(Path(value))
end
function Path:pop(depth)
    depth = depth or 1
    for i=1,depth do
        table.remove(self._stack, #self._stack)
    end
    return self
end
function Path:equal(other)
    assert(type(other) == "table")
    return self:get() == other:get()
end
function Path:append(other)
    assert(type(other) == "table")
    for i,v in ipairs(other._stack) do
        table.insert(self._stack, v)
    end
    return self
end
function Path:relative(other)
    local value1 = self:get(true)
    local value2 = other:get(true)
    local stack1 = Path(value1)._stack
    local stack2 = Path(value2)._stack
    local diff = ""
    for i=1,math.max(#stack1, #stack2) do
        local v1 = stack1[i]
        local v2 = stack2[i]
        if v1 ~= nil and v2 ~= nil then
            if v1 == v2 then
            else
                diff =   diff .. "/../" .. v2
            end
        elseif v1 and not v2 then
            diff = ".." .. "/" .. diff
        elseif not v1 and v2 then
            diff =  diff .. "/" .. v2
        end
    end
    return Path(diff)
end
function Path:root()
    return self:pop(#self._stack - 1)
end

-- file:[./files/files.lua]

files = files or {}
local delimiter = nil
function files.delimiter()
    if delimiter then return delimiter end
    delimiter = string.find(os.tmpname(""), "\\") and "\\" or "/"
    return delimiter
end
function files.home()
    return os.getenv('HOME') or os.getenv('USERPROFILE')
end
local cwd = nil
function files.cwd()
    if cwd then return cwd end
    local isOk, output = nil, nil
    if tools.is_windows() then
        isOk, output = tools.execute("cd")
    else
        isOk, output = tools.execute("pwd")
    end
    assert(isOk and output ~= nil)
    cwd = output:trim():slash() .. '/'
    return cwd
end
function files.csd(thread)
    local info = debug.getinfo(thread or 2)
    if not info then return end
    local path = info.short_src
    assert(path ~= nil)
    path = path:trim():slash()
    return files.cwd() .. files.get_folder(path) .. '/'
end
function files.absolute(this)
    return files.cwd() .. this
end
function files.relative(this)
    return this:gsub(files.cwd(), '')
end
function files.write(path, content, mode)
    local f = io.open(path, mode or "w")
    if not f then return false end
    f:write(content)
    f:close()
    return true
end
function files.read(path, mode)
    local f = io.open(path, mode or "r")
    if not f then return end
    local content = f:read("*a")
    f:close()
    return content
end
function files.size(path)
    f = io.open(path, "rb")
    if not f then return 0 end
    local size = f:seek("end")
    f:close()
    return size
end
function files.delete(path)
    return os.remove(path)
end
function files.is_file(path)
    local f = io.open(path, "rb")
    if f then f:close() end
    return f ~= nil
end
function files.print(path)
    print("[file:" .. path .. "]")
    print("[[[[[[[")
    local lines = files.is_file(path) and io.lines(path) or ipairs({})
    local num = 0
    for line in lines do
        num = num + 1
        print(" " .. tostring(num):right(7, "0") .. " " .. line)
    end
    print("]]]]]]]")
end
function files.copy(from, to)
    local f1 = io.open(from, 'rb')
    local f2 = io.open(to, 'wb')
    if not f1 or not f2 then return end
    f2:write(f1:read('*a'))
    f1:close()
    f2:close()
    return true
end
function files.sync(from, to)
    assert(files.is_folder(from), 'sync from path is invalid')
    files.mk_folder(to)
    local t = files.list(from)
    for i,v in ipairs(t) do
        local fromPath = from .."/" .. v
        local toPath = to .."/" .. v
        if files.is_file(fromPath) then
            files.copy(fromPath, toPath)
        elseif files.is_folder(fromPath) then
            files.sync(fromPath, toPath)
        end
    end
end
function files.is_folder(path)
    if not path then return false end
    local isOk, _ = tools.execute("cd " .. path)
    return isOk == true
end
function files.mk_folder(path)
    if files.is_folder(path) then return end
    local isOk
    if tools.is_windows() then
        isOk = tools.execute(string.format([[mkdir "%s"]], path))
    else
        isOk = tools.execute(string.format([[mkdir -p "%s"]], path))
    end
    return isOk == true
end
function files.list(path)
    local r = table.new()
    if not files.is_folder(path) then return r end
    local isOk, out
    if tools.is_windows() then
        isOk, out = tools.execute(string.format([[dir /b "%s"]], path))
    else
        isOk, out = tools.execute(string.format([[ls "%s"]], path))
    end
    t = out:explode('\n')
    for i,v in ipairs(t) do
        if is_string(v) and #v > 0 then
            table.insert(r, v)
        end
    end
    return r
end
function files.get_folder(filePath)
    return string.gsub(filePath, "[^\\/]+%.[^\\/]+", "")
end
function files.modified(path)
    local stamp = nil
    xpcall(function()
        local isOk, result = tools.execute("stat -f %m " .. path) -- mac
        if isOk then stamp = result end
        local isOk, result = tools.execute("stat -c %Y " .. path) -- linux
        if isOk then stamp = result end
        assert(stamp ~= nil, 'get modified stamp failed')
    end, function(err)
        print(err)
    end)
    if not stamp then
        return -1
    end
    local modified = tonumber(stamp) or -1
    return modified
end
function files.watch(paths, callback, triggerDelay)
    if is_string(paths) then paths = {paths} end
    assert(#paths >= 1, 'the paths to watch should not be empty')
    assert(is_function(callback), 'the last argument should be a callback func')
    for i, path in ipairs(paths) do
        assert(files.is_file(path) or files.is_folder(path), 'path not found in watch:' .. tostring(path))
    end
    triggerDelay = triggerDelay or 1
    local modifiedMap = {}
    local function check(path)
        local modifiedTime = files.modified(path)
        if not modifiedMap[path] then
            callback(path, modifiedTime, true)
            modifiedMap[path] = modifiedTime
        elseif modifiedTime - modifiedMap[path] >= triggerDelay then
            callback(path, modifiedTime, false)
            modifiedMap[path] = modifiedTime
        end
    end
    while true do
        for i,v in ipairs(paths) do check(v) end
    end
end

-- file:[./files/bit.lua]

bit = bit or {}
bit.WEIGHTS = {}
bit.DIGIT = 32
for i = 1, bit.DIGIT do
    bit.WEIGHTS[i] = 2 ^ (32 - i)
end
function bit.table2number(tb)
    local negative = tb[1] == 1
    local nr = 0
    for i = 1, bit.DIGIT do
        local v = nil
        if negative then
            v = tb[i] == 1 and 0 or 1
        else
            v = tb[i]
        end
        if v == 1 then
            nr = nr + bit.WEIGHTS[i]
        end
    end
    if negative then
        nr = nr + 1
        nr = -nr
    end
    return nr
end
function bit.number2table(nm)
    nm = nm >= 0 and nm or (0xFFFFFFFF + nm + 1)
    local tb = {}
    for i = 1, bit.DIGIT do
        if nm >= bit.WEIGHTS[i] then
            tb[i] = 1
            nm = nm - bit.WEIGHTS[i]
        else
            tb[i] = 0
        end
    end
    return tb
end
function bit.rshift(a, n)
    local tb = bit.number2table(a)
    n = math.max(0, math.min(bit.DIGIT, n))
    for i = bit.DIGIT, 1, -1 do
        tb[i] = tb[i - n] or 0
    end
    return bit.table2number(tb)
end
function bit.arshift(a, n)
    local tb = bit.number2table(a)
    n = math.max(0, math.min(bit.DIGIT, n))
    local fill = a < 0 and 1 or 0
    for i = bit.DIGIT, 1, -1 do
        tb[i] = tb[i - n] or fill
    end
    return bit.table2number(tb)
end
function bit.lshift(a, n)
    local tb = bit.number2table(a)
    n = math.max(0, math.min(bit.DIGIT, n))
    for i = 1, bit.DIGIT do
        tb[i] = tb[i + n] or 0
    end
    return bit.table2number(tb)
end
function bit.band(a, b)
    local tb1 = bit.number2table(a)
    local tb2 = bit.number2table(b)
    local r = {}
    for i = 1, bit.DIGIT do
        r[i] = (tb1[i] == 1 and tb2[i] == 1) and 1 or 0
    end
    return bit.table2number(r)
end
function bit.bor(a, b)
    local tb1 = bit.number2table(a)
    local tb2 = bit.number2table(b)
    local r = {}
    for i = 1, bit.DIGIT do
        r[i] = (tb1[i] == 1 or tb2[i] == 1) and 1 or 0
    end
    return bit.table2number(r)
end
function bit.bxor(a, b)
    local tb1 = bit.number2table(a)
    local tb2 = bit.number2table(b)
    local r = {}
    for i = 1, bit.DIGIT do
        r[i] = tb1[i] ~= tb2[i] and 1 or 0
    end
    return bit.table2number(r)
end
function bit.bnot(a)
    local tb = bit.number2table(a)
    local r = {}
    for i = 1, bit.DIGIT do
        r[i] = tb[i] == 1 and 0 or 1
    end
    return bit.table2number(r)
end

-- file:[./files/encryption.lua]

encryption = encryption or {}
local function safeAdd(x, y)
    if x == nil then
        x = 0
    end
    if y == nil then
        y = 0
    end
    local lsw = bit.band(x, 0xffff) + bit.band(y, 0xffff)
    local msw = bit.arshift(x, 16) + bit.arshift(y, 16) + bit.arshift(lsw, 16)
    return bit.bor(bit.lshift(msw, 16), bit.band(lsw, 0xffff))
end
local function bitRotateLeft(num, cnt)
    return bit.bor(bit.lshift(num, cnt), bit.rshift(num, (32 - cnt)))
end
local function md5cmn(q, a, b, x, s, t)
    return safeAdd(bitRotateLeft(safeAdd(safeAdd(a, q), safeAdd(x, t)), s), b)
end
local function md5ff(a, b, c, d, x, s, t)
    return md5cmn(bit.bor(bit.band(b, c), bit.band(bit.bnot(b), d)), a, b, x, s, t)
end
local function md5gg(a, b, c, d, x, s, t)
    return md5cmn(bit.bor(bit.band(b, d), bit.band(c, bit.bnot(d))), a, b, x, s, t)
end
local function md5hh(a, b, c, d, x, s, t)
    return md5cmn(bit.bxor(b, bit.bxor(c, d)), a, b, x, s, t)
end
local function md5ii(a, b, c, d, x, s, t)
    return md5cmn(bit.bxor(c, bit.bor(b, bit.bnot(d))), a, b, x, s, t)
end
local function binlMD5(x, len)
    x[1 + bit.arshift(len, 5)] = bit.bor(x[1 + bit.arshift(len, 5)], bit.lshift(0x80, (len % 32)))
    x[1 + bit.lshift(bit.rshift(len + 64, 9), 4) + 14] = len
    local i
    local olda
    local oldb
    local oldc
    local oldd
    local a = 1732584193
    local b = -271733879
    local c = -1732584194
    local d = 271733878
    for i = 1, #x, 16 do
        olda = a
        oldb = b
        oldc = c
        oldd = d
        a = md5ff(a, b, c, d, x[i], 7, -680876936)
        d = md5ff(d, a, b, c, x[i + 1], 12, -389564586)
        c = md5ff(c, d, a, b, x[i + 2], 17, 606105819)
        b = md5ff(b, c, d, a, x[i + 3], 22, -1044525330)
        a = md5ff(a, b, c, d, x[i + 4], 7, -176418897)
        d = md5ff(d, a, b, c, x[i + 5], 12, 1200080426)
        c = md5ff(c, d, a, b, x[i + 6], 17, -1473231341)
        b = md5ff(b, c, d, a, x[i + 7], 22, -45705983)
        a = md5ff(a, b, c, d, x[i + 8], 7, 1770035416)
        d = md5ff(d, a, b, c, x[i + 9], 12, -1958414417)
        c = md5ff(c, d, a, b, x[i + 10], 17, -42063)
        b = md5ff(b, c, d, a, x[i + 11], 22, -1990404162)
        a = md5ff(a, b, c, d, x[i + 12], 7, 1804603682)
        d = md5ff(d, a, b, c, x[i + 13], 12, -40341101)
        c = md5ff(c, d, a, b, x[i + 14], 17, -1502002290)
        b = md5ff(b, c, d, a, x[i + 15], 22, 1236535329)
        a = md5gg(a, b, c, d, x[i + 1], 5, -165796510)
        d = md5gg(d, a, b, c, x[i + 6], 9, -1069501632)
        c = md5gg(c, d, a, b, x[i + 11], 14, 643717713)
        b = md5gg(b, c, d, a, x[i], 20, -373897302)
        a = md5gg(a, b, c, d, x[i + 5], 5, -701558691)
        d = md5gg(d, a, b, c, x[i + 10], 9, 38016083)
        c = md5gg(c, d, a, b, x[i + 15], 14, -660478335)
        b = md5gg(b, c, d, a, x[i + 4], 20, -405537848)
        a = md5gg(a, b, c, d, x[i + 9], 5, 568446438)
        d = md5gg(d, a, b, c, x[i + 14], 9, -1019803690)
        c = md5gg(c, d, a, b, x[i + 3], 14, -187363961)
        b = md5gg(b, c, d, a, x[i + 8], 20, 1163531501)
        a = md5gg(a, b, c, d, x[i + 13], 5, -1444681467)
        d = md5gg(d, a, b, c, x[i + 2], 9, -51403784)
        c = md5gg(c, d, a, b, x[i + 7], 14, 1735328473)
        b = md5gg(b, c, d, a, x[i + 12], 20, -1926607734)
        a = md5hh(a, b, c, d, x[i + 5], 4, -378558)
        d = md5hh(d, a, b, c, x[i + 8], 11, -2022574463)
        c = md5hh(c, d, a, b, x[i + 11], 16, 1839030562)
        b = md5hh(b, c, d, a, x[i + 14], 23, -35309556)
        a = md5hh(a, b, c, d, x[i + 1], 4, -1530992060)
        d = md5hh(d, a, b, c, x[i + 4], 11, 1272893353)
        c = md5hh(c, d, a, b, x[i + 7], 16, -155497632)
        b = md5hh(b, c, d, a, x[i + 10], 23, -1094730640)
        a = md5hh(a, b, c, d, x[i + 13], 4, 681279174)
        d = md5hh(d, a, b, c, x[i], 11, -358537222)
        c = md5hh(c, d, a, b, x[i + 3], 16, -722521979)
        b = md5hh(b, c, d, a, x[i + 6], 23, 76029189)
        a = md5hh(a, b, c, d, x[i + 9], 4, -640364487)
        d = md5hh(d, a, b, c, x[i + 12], 11, -421815835)
        c = md5hh(c, d, a, b, x[i + 15], 16, 530742520)
        b = md5hh(b, c, d, a, x[i + 2], 23, -995338651)
        a = md5ii(a, b, c, d, x[i], 6, -198630844)
        d = md5ii(d, a, b, c, x[i + 7], 10, 1126891415)
        c = md5ii(c, d, a, b, x[i + 14], 15, -1416354905)
        b = md5ii(b, c, d, a, x[i + 5], 21, -57434055)
        a = md5ii(a, b, c, d, x[i + 12], 6, 1700485571)
        d = md5ii(d, a, b, c, x[i + 3], 10, -1894986606)
        c = md5ii(c, d, a, b, x[i + 10], 15, -1051523)
        b = md5ii(b, c, d, a, x[i + 1], 21, -2054922799)
        a = md5ii(a, b, c, d, x[i + 8], 6, 1873313359)
        d = md5ii(d, a, b, c, x[i + 15], 10, -30611744)
        c = md5ii(c, d, a, b, x[i + 6], 15, -1560198380)
        b = md5ii(b, c, d, a, x[i + 13], 21, 1309151649)
        a = md5ii(a, b, c, d, x[i + 4], 6, -145523070)
        d = md5ii(d, a, b, c, x[i + 11], 10, -1120210379)
        c = md5ii(c, d, a, b, x[i + 2], 15, 718787259)
        b = md5ii(b, c, d, a, x[i + 9], 21, -343485551)
        a = safeAdd(a, olda)
        b = safeAdd(b, oldb)
        c = safeAdd(c, oldc)
        d = safeAdd(d, oldd)
    end
    return {a, b, c, d}
end
local function binl2rstr(input)
    local i
    local output = {}
    local length32 = #input * 32
    for i = 0, length32 - 1, 8 do
        table.insert(output, string.char(bit.band(bit.rshift(input[1 + bit.arshift(i, 5)], i % 32), 0xff)))
    end
    return table.concat(output, '')
end
local function rstr2binl(input)
    local output = {}
    for i = 1, bit.arshift(string.len(input), 2) do
        output[i] = 0
    end
    local length8 = string.len(input) * 8
    for i = 0, length8 - 1, 8 do
        local p = 1 + bit.arshift(i, 5);
        if output[p] == nil then
            output[p] = 0
        end
        output[p] = bit.bor(output[p], bit.lshift(bit.band(input:byte((i / 8) + 1), 0xff), (i % 32)))
    end
    return output
end
local function rstrMD5(s)
    return binl2rstr(binlMD5(rstr2binl(s), string.len(s) * 8))
end
local function charAt(str, n)
    return string.sub(str, n, n)
end
local function rstr2hex(input)
    local hexTab = '0123456789abcdef'
    local output = {}
    for i = 1, string.len(input) do
        local x = input:byte(i)
        table.insert(output, charAt(hexTab, 1 + bit.band(bit.rshift(x, 4), 0x0f)))
        table.insert(output, charAt(hexTab, 1 + bit.band(x, 0x0f)))
    end
    return table.concat(output, '')
end
function encryption.md5(str)
    return rstr2hex(rstrMD5(str))
end
local b ='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function encryption.base64_encode(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
function encryption.base64_decode(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- file:[./files/time.lua]

assert(Time == nil)
Time = class("Time")
local SECONDS_WEEK = 60 * 60 * 24 * 7
local SECONDS_DAY = 60 * 60 * 24
local SECONDS_HOUR = 60 * 60
local SECONDS_MINUTE = 60
local SECONDS_SECOND = 1
function Time:__init__(time, zone)
    self._time = time or os.time()
    self._zone = zone
    if not self._zone then
        local now = os.time()
        local utc = os.time(os.date("!*t", now))
        local diff = os.difftime(now, utc)
        self._zone = math.floor(diff / SECONDS_HOUR)
    end
end
function Time:getValue()
    return self._time
end
function Time:getDate(desc)
    return os.date(desc or "%Y-%m-%d_%H:%M:%S", self._time)
end
function Time:getTime()
    return self._time
end
function Time:setTime(time)
    assert(time ~= nil)
    self._time = time
    return self
end
function Time:getZone()
    return self._zone
end
function Time:setZone(zone)
    assert(zone ~= nil)
    self._time = self._time - self._zone * SECONDS_HOUR
    self._zone = zone
    self._time = self._time + self._zone * SECONDS_HOUR
    return self
end
function Time:getYear()
    return tonumber(os.date("%Y", self._time))
end
function Time:getMonth()
    return tonumber(os.date("%m", self._time))
end
function Time:nameMonth(isFull)
    return os.date(isFull and "%B" or "%b", self._time)
end
function Time:getDay()
    return tonumber(os.date("%d", self._time))
end
function Time:getYMD()
    return self:getYear(), self:getMonth(), self:getDay()
end
function Time:getHour()
    return tonumber(os.date("%H", self._time))
end
function Time:getMinute()
    return tonumber(os.date("%M", self._time))
end
function Time:getSecond()
    return tonumber(os.date("%S", self._time))
end
function Time:getHMS()
    return self:getHour(), self:getMinute(), self:getSecond()
end
function Time:getWeek()
    local w = tonumber(os.date("%w", self._time))
    return w == 0 and 7 or w
end
function Time:nameWeek(isFull)
    return os.date(isFull and "%A" or "%a", self._time)
end
function Time:isAm()
    return self:getHour() < 12
end
function Time:isLeap()
    local year = self:getYear()
    if year % 4 == 0 and year % 100 ~= 0 then
        return true
    end
    if year % 400 == 0 then
        return true
    end
    return false
end
function Time:isSameWeek(time)
    return self:countWeek() == time:countWeek()
end
function Time:isSameDay(time)
    return self:countDay() == time:countDay()
end
function Time:isSameHour(time)
    return self:countHour() == time:countHour()
end
function Time:isSameMinute(time)
    return self:countMinute() == time:countMinute()
end
function Time:getYMDHMS()
    return self:getYear(), self:getMonth(), self:getDay(), self:getHour(), self:getMinute(), self:getSecond()
end
function Time:countWeek()
    local second = self._time % SECONDS_WEEK
    local hour = (self._time - second) / SECONDS_WEEK
    local time = Time(second)
    local result = {time:countDay()}
    table.insert(result, 1, hour)
    return unpack(result)
end
function Time:countDay()
    local second = self._time % SECONDS_DAY
    local hour = (self._time - second) / SECONDS_DAY
    local time = Time(second)
    local result = {time:countHour()}
    table.insert(result, 1, hour)
    return unpack(result)
end
function Time:countHour()
    local second = self._time % SECONDS_HOUR
    local hour = (self._time - second) / SECONDS_HOUR
    local time = Time(second)
    local result = {time:countMinute()}
    table.insert(result, 1, hour)
    return unpack(result)
end
function Time:countMinute()
    local second = self._time % SECONDS_MINUTE
    local minute = (self._time - second) / SECONDS_MINUTE
    return minute, second
end
function Time:addWeek(count)
    assert(count ~= nil)
    self._time = self._time + count * SECONDS_WEEK
    return self
end
function Time:addDay(count)
    assert(count ~= nil)
    self._time = self._time + count * SECONDS_DAY
    return self
end
function Time:addHour(count)
    assert(count ~= nil)
    self._time = self._time + count * SECONDS_HOUR
    return self
end
function Time:addMinute(count)
    assert(count ~= nil)
    self._time = self._time + count * SECONDS_MINUTE
    return self
end
function Time:addSecond(count)
    assert(count ~= nil)
    self._time = self._time + count * SECONDS_SECOND
    return self
end
function Time:diffTime(time)
    assert(time ~= nil)
    local distance = self:getValue() - time:getValue()
    return Time(math.abs(distance)), distance > 0
end
function Time:addTime(time)
    assert(time ~= nil)
    self._time = self._time + time:getValue()
    return self
end

-- file:[./files/timer.lua]

timer = timer or {}
local timers = {}
local function timer_insert(sec, action)
    local deadline = os.clock() + sec
    local pos = 1
    for i, v in ipairs(timers) do
        if v.deadline > deadline then
            break
        end
        pos = i + 1
    end
    local tm = {
        deadline = deadline,
        action = action
    }
    table.insert(timers, pos, tm)
end
local function timer_check()
    local tm = timers[1]
    if tm.deadline <= os.clock() then
        table.remove(timers, 1)
        local isOk, error = xpcall(tm.action, debug.traceback)
        if isOk then return end
        print(error)
    end
end
function timer.flag()
    return {}
end
function timer.finish(flag)
    flag.ok = true
end
function timer.running(flag)
    return flag.ok ~= true
end
function timer.async(func)
    local co = coroutine.create(func)
    coroutine.resume(co)
end
function timer.sleep(seconds)
    local co = coroutine.running()
    timer_insert(seconds, function()
        coroutine.resume(co)
    end)
    coroutine.yield()
end
function timer.wait(flag)
    while timer.running(flag) do
        timer.sleep(0.1)
    end
end
function timer.delay(seconds, func)
    local flag = timer.flag()
    timer_insert(seconds, function()
        if not timer.running(flag) then
            return
        end
        local isOk, s = xpcall(func, debug.traceback)
        if not isOk then
            print(s)
            return
        end
        if not s or s <= 0 then
            timer.finish(flag)
        else
            timer.delay(s, func)
        end
    end)
    return flag
end
function timer.start()
    while #timers > 0 do
        timer_check()
    end
end

-- file:[./files/http.lua]

http = http or {}
function http.download(url, path, tp)
    assert(string.valid(url))
    assert(string.valid(path))
    tp = tp or 'wget'
    local folder = files.get_folder(path)
    files.mk_folder(folder)
    local cmd = nil
    local isOk = false
    if tp == 'curl' then
        cmd = [[curl -L "%s" -o "%s" --max-redirs 3]]
    elseif tp == 'wget' then
        cmd = [[wget "%s" -O "%s"]]
    end
    cmd = string.format(cmd, url, path)
    local isOk, output = tools.execute(cmd)
    return isOk, output, cmd
end
local function curl_request(url, method, params, headers)
    local httpContentFile = "./.lua.http.log"
    files.delete(httpContentFile)
    local h = ""
    for k,v in pairs(headers) do
        assert(is_string(k))
        assert(is_string(v) or is_number(v))
        if h ~= "" then
            h = h .. ";"
        end
        h = h .. "-H '" .. tostring(k) .. ":" .. tostring(v) .. "'"
    end
    local b = ""
    if method == "GET" then
        for k,v in pairs(params) do
            if not string.find(url, "?") then url = url .. "?" end
            assert(is_string(k))
            assert(is_string(v) or is_number(v))
            url = url .. tostring(k) ..  "=" .. tostring(v)
        end
    elseif method == "POST" then
        b = string.format("-d '%s'", json.encode(params))
    end
    local cmd = [[curl "%s" -i  --silent -o "%s" -X %s "%s" -d "%s"]]
    cmd = string.format(cmd, url, httpContentFile, method, h, b)
    local isOk, output = tools.execute(cmd)
    local content = files.read(httpContentFile) or ""
    files.delete(httpContentFile)
    local contents = string.explode(content, "\n%s*\n", 1)
    local head = contents[1] or ""
    local body = contents[2] or ""
    local from, to = string.find(head, 'HTTP.*%s%d%d%d')
    local code = (from and to) and tonumber(string.sub(head, to - 3, to) or "") or -1
    if not isOk or code < 0 then
        return -1, output
    else
        return code, body
    end
end
local function http_request(url, method, params, headers)
    assert(string.valid(url))
    local m = string.upper(method)
    assert(m == "POST" or m == "GET")
    params = params or {}
    headers = headers or {}
    local code, content = curl_request(url, method, params, headers)
    return code == 200, code, content
end
function http.get(url, params, headers)
    return http_request(url, 'GET', params, headers)
end
function http.post(url, params, headers)
    return http_request(url, 'POST', params, headers)
end

-- file:[./files/package.lua]

local recursiveMap = {}
local modulesMap = {}
local function load(path, env)
    local f, err = loadfile(path)
    assert(f ~= nil or err == nil, err)
    if env then setfenv(f, env) end
    local r, msg = pcall(f)
    assert(r == true, msg)
    modulesMap[path] = msg ~= nil and msg or true
    return msg
end
local function search(path)
    if files.is_file(files.csd() .. path) then
        return files.csd() .. path
    elseif files.is_file(files.cwd() .. path) then
        return files.cwd() .. path
    elseif files.is_file(path) then
        return path
    end
end
function package.doload(path, env)
    path = search(tostring(path))
    if path and modulesMap[path] then
        return modulesMap[path] ~= true and modulesMap[path] or nil
    end
    assert(path ~= nil)
    assert(recursiveMap[path] == nil)
    recursiveMap[path] = true
    local r = load(path, env)
    recursiveMap[path] = nil
    return r
end
function package.unload(path)
    path = search(tostring(path))
    if path and modulesMap[path] then modulesMap[path] = nil end
end
function package.isloaded(path)
    path = search(tostring(path))
    return path ~= nil and modulesMap[path] ~= nil
end

-- file:[./files/tools.lua]

tools = tools or {}
local isWindows = nil
function tools.is_windows()
    if is_boolean(isWindows) then return isWindows end
    isWindows = package.config:sub(1,1) == "\\"
    return isWindows 
end
local isLinux = nil
function tools.is_linux()
    if is_boolean(isLinux) then return isLinux end
    isLinux = not tools.is_windows() and string.find(os.getenv("HOME") or "", '/home/') ~= nil
    return isLinux
end
local isLinux = nil
function tools.is_mac()
    if is_boolean(isLinux) then return isLinux end
    isLinux = not tools.is_windows() and string.find(os.getenv("HOME") or "", '/Users/') ~= nil
    return isLinux
end
function tools.execute(cmd)
    local flag = "::MY_ERROR_FLAG::"
    local file = io.popen(cmd .. [[ 2>&1 || echo ]] .. flag, "r")
    local out = file:read("*all"):trim()
    local isOk = not out:find(flag)
    if not isOk then
        out = out:sub(1, #out - #flag)
    end
    file:close()
    out = out:trim()
    return isOk, out
end
function tools.get_timezone()
    local now = os.time()
    local utc = os.time(os.date("!*t", now))
    local diff = os.difftime(now, utc)
    local zone = math.floor(diff / 60 / 60)
    return zone
end
function tools.get_milliseconds()
    local clock = os.clock()
    local _, milli = math.modf(clock)
    return math.floor(os.time() * 1000 + milli * 1000)
end
function tools.rgb_to_hex(r, g, b)
    return bit.lshift(r, 16) + bit.lshift(g, 8) + b
end
function tools.hex_to_rgb(hex)
    local r = bit.band(bit.rshift(hex, 16), 0xFF)
    local g = bit.band(bit.rshift(hex, 8), 0xFF)
    local b = bit.band(hex, 0xFF)
    return r, g, b
end
function tools.rgba_to_hex(r, g, b, a)
    return bit.lshift(r, 24) + bit.lshift(g, 16) + bit.lshift(b, 8) + a
end
function tools.hex_to_rgba(hex)
    local r = bit.band(bit.rshift(hex, 24), 0xFF)
    local g = bit.band(bit.rshift(hex, 16), 0xFF)
    local b = bit.band(bit.rshift(hex, 8), 0xFF)
    local a = bit.band(hex, 0xFF)
    return r, g, b, a
end

-- file:[./files/Object.lua]

assert(Object == nil)
Object = {}
Object.__index = Object
function Object:init()
end
function Object:new(...)
    assert(self.__class == nil, 'can not instantiate object!')
    local obj = setmetatable({}, self)
    obj.__class = self
    obj:init(...)
    return obj
end
function Object:ext()
    assert(self.__class == nil, 'can not extend object!')
    local Cls = {}
    Cls.__index = Cls
    setmetatable(Cls, self)
    return Cls
end
function Object:is(Cls)
    assert(self.__class ~= nil, 'can not check Object!')
    local mt = getmetatable(self)
    while mt do
        if mt == Cls then return true end
        mt = getmetatable(mt)
    end
    return false
end

-- file:[./files/Events.lua]

assert(Events == nil)
Events = class('Events')
function Events:__init__()
    self._eventsMap = {}
end
function Events:triggerEvent(name, ...)
    assert(type(name) == 'string', 'event name should be function')
    self._eventsMap[name] = self._eventsMap[name] or {}
    local args = {...}
    for callback,times in pairs(self._eventsMap[name]) do
        xpcall(function()
            callback(unpack(args))
        end, function(error)
            print('event trigger error:', error)
        end)
        if not self._eventsMap[name][callback] then
        elseif times <= 0 then
        elseif times > 1 then
            self._eventsMap[name][callback] = times - 1
        elseif times == 1 then
            self._eventsMap[name][callback] = nil
        else
            error('not expected')
        end
    end
end
function Events:addListener(name, listener, times)
    assert(type(name) == 'string', 'event name should be function')
    assert(type(listener) == 'function', 'event listener should be function')
    self._eventsMap[name] = self._eventsMap[name] or {}
    if times == nil then
        times = 1
    elseif times == false then
        times = 1
    elseif times == true then
        times = 0
    elseif type(times) == 'number' then
        times = math.max(times, 0)
    else
        error('event times should be number')
    end
    self._eventsMap[name][listener] = times
end
function Events:removeListener(name, listener)
    assert(type(name) == 'string', 'event name should be function')
        assert(type(listener) == 'function', 'event listener should be function')
    self._eventsMap[name] = self._eventsMap[name] or {}
    self._eventsMap[name][listener] = nil
end
function Events:removeListeners(name)
    assert(type(name) == 'string', 'event name should be function')
    self._eventsMap[name] = {}
end
function Events:hasListener(name, listener)
    assert(type(name) == 'string', 'event name should be function')
    assert(type(listener) == 'function', 'event listener should be function')
    return self._eventsMap[name] ~= nil and self._eventsMap[name][listener] ~= nil
end

-- file:[./files/Storage.lua]

assert(Storage == nil)
Storage = class("Storage")
local operationg = {}
function Storage:__init__(path, shiftCount)
    assert(is_string(path) and #path > 0, 'invalid storage path!')
    assert(shiftCount == nil or is_number(shiftCount), 'invalid salt type!')
    self._path = path ~= files.get_folder(path) and path or path .. ".db"
    self._shift = shiftCount or 0
    self._data = nil
    if files.is_file(self._path) then
        self:_read()
    end
    if not self._data then
        self._data = {}
        self:_write()
    end
    assert(files.is_file(self._path), 'storage initialize failed!')
    assert(operationg[self._path] == nil, 'storage already in use!')
    operationg[self._path] = true
end
function Storage:close()
    assert(self._path ~= nil, 'storage already closed!')
    operationg[self._path] = nil
    self._path = nil
    self._data = nil
end
function Storage:_read()
    assert(self._path ~= nil, 'storage already closed!')
    local content = files.read(self._path)
    assert(content ~= nil, "invalid storage file:" .. self._path)
    if self._shift > 0 then
        content = encryption.base64_decode(content)
        local list = {}
        for i = 1, #content do
            list[i] = string.char(string.byte(content:sub(i,i)) - self._shift)
        end
        content = table.implode(list)
        content = encryption.base64_decode(content)
    end
    self._data = json.decode(content)
end
function Storage:_write()
    assert(self._path ~= nil, 'storage already closed!')
    local content = json.encode(self._data)
    if self._shift > 0 then
        content = encryption.base64_encode(content)
        local list = {}
        for i = 1, #content do
            list[i] = string.char(string.byte(content:sub(i,i)) + self._shift)
        end
        content = table.implode(list)
        content = encryption.base64_encode(content)
    end
    if not files.is_file(self._path) then
        files.mk_folder(files.get_folder(self._path))
    end
    return files.write(self._path, content)
end
function Storage:get(key, default)
    assert(self._path ~= nil, 'storage already closed!')
    assert(is_string(key), 'invalid storage key!')
    if self._data[key] == nil then return default end
    assert(type(self._data[key]) == type(default) or default == nil, 'invalid data type!')
    return self._data[key]
end
function Storage:set(key, value)
    assert(self._path ~= nil, 'storage already closed!')
    assert(is_string(key), 'invalid storage key!')
    if self._data[key] == nil then
        self._data[key] = value
    else
        assert(type(self._data[key]) == type(value) or value == nil, 'invalid data type!')
        self._data[key] = value
    end
    return self:_write()
end

-- file:[./files/Log.lua]

assert(Log == nil)
Log = class("Log")
Log.LEVEL = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    USER = 5,
}
Log.COLOR = {
    TAG_BG_CONTENT_FG = {4, 3},
    TAG_FG_CONTENT_BG = {3, 4},
    TAG_BG_CONTENT_BG = {4, 4},
    TAG_FG_CONTENT_FG = {3, 3},
}
local COLORS = {
    [Log.LEVEL.DEBUG] = "\27[%d4m %s \27[0m",
    [Log.LEVEL.INFO]  = "\27[%d2m %s \27[0m",
    [Log.LEVEL.WARN]  = "\27[%d3m %s \27[0m",
    [Log.LEVEL.ERROR] = "\27[%d1m %s \27[0m",
    [Log.LEVEL.USER]  = "\27[%d5m %s \27[0m",
}
local operationg = {}
function Log:__init__(path, name, level, color)
    assert(path == nil or string.valid(path), 'invalid log path!')
    assert(name == nil or string.valid(name), 'invalid log name!')
    assert(level == nil or is_number(level), 'invalid log level!')
    assert(color == nil or table.find_value(Log.COLOR, color), 'invalid log color!')
    self._name = name or "UNKNOWN"
    self._level = level or Log.LEVEL.DEBUG
    self._color = color or Log.COLOR.TAG_BG_CONTENT_FG
    if path ~= nil then
        self._path = path
        assert(operationg[self._path] == nil, 'log already opened!')
        operationg[self._path] = true
        if files.is_file(self._path) then
            files.delete(self._path)
        end
        if not files.is_file(self._path) then
            files.mk_folder(files.get_folder(self._path))
        end
        self._file = io.open(path, "a")
        assert(self._file ~= nil, 'invalid log file!')
    end
    self._valid = true
    self:_write(Log.LEVEL.USER, "START->%s", self._name)
end
function Log:close()
    assert(self._valid == true, 'log already closed!')
    if self._path ~= nil then
        operationg[self._path] = nil
        self._path = nil
    end
    if self._file ~= nil then
        self._file:close()
        self._file = nil
    end
    self._valid = false
end
function Log:_write(level, content, ...)
    assert(self._valid == true, 'log already closed!')
    local levelName = table.find_value(Log.LEVEL, level)
    local logContent = string.format(content, ...)
    assert(levelName ~= nil, 'invalid log level!')
    assert(string.valid(content), 'invalid log content!')
    local date = os.date("%Y-%m-%d_%H:%M:%S", os.time())
    local header = string.format("[%s_%s]", self._name, date)
    local footer = string.format("%s : %s", string.left(levelName, 5, " "), logContent)
    if self._file then
        self._file:write(string.format("%s %s\n", header, footer))
    end
    if table.is_empty(self._color) then
        print(string.format("%s %s", header, footer))
    else
        local left = string.format(COLORS[level], self._color[1], header)
        local right = string.format(COLORS[level], self._color[2], footer)
        print(string.format("%s %s", left, right))
    end
end
function Log:user(content, ...)
    self:_write(Log.LEVEL.USER, content, ...)
end
function Log:error(content, ...)
    self:_write(Log.LEVEL.ERROR, content, ...)
end
function Log:warn(content, ...)
    self:_write(Log.LEVEL.WARN, content, ...)
end
function Log:info(content, ...)
    self:_write(Log.LEVEL.INFO, content, ...)
end
function Log:debug(content, ...)
    self:_write(Log.LEVEL.DEBUG, content, ...)
end

-- file:[./files/Graphic.lua]

assert(Graphic == nil)
Graphic = class("Graphic")
local HIDE_CONSOLE = [[
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0) # hide:0, show:5
]]
local COMMON_HEADER = [[
[reflection.assembly]::LoadWithPartialName( "System.Drawing");
$brush = new-object Drawing.SolidBrush "#22ffcc"
$pen = new-object Drawing.Pen "#22ffcc"
$pen.width = 10
$x = 0
$y = 0
$w = 250
$h = 250
$ax = 0.5
$ay = 0.5
]]
local FORM_CREATE = [[
[reflection.assembly]::LoadWithPartialName( "System.Windows.Forms");
[System.Windows.Forms.Application]::EnableVisualStyles();
$form = New-Object Windows.Forms.Form
$form.ClientSize         = '%d,%d'
$form.StartPosition = 'CenterScreen'
$graphics = $form.createGraphics()
$form.add_paint({
]]
local FORM_SHOW = [[
})
$icon = New-Object system.drawing.icon ("%s")
$form.Icon = $icon
$form.text = "%s"
$form.ShowDialog();
$graphics.Dispose()
]]
local IMAGE_CREATE = [[
$bitmap = new-object System.Drawing.Bitmap 500,500
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
]]
local IMAGE_SAVE = [[
$bitmap.Save("%s")
$graphics.Dispose()
]]
local GRAPHIC_COLOR = [[
$brush.color = "%s"
$pen.color = "%s"
]]
local GRAPHIC_SIZE = [[
$pen.width = %d
]]
local GRAPHIC_POSITION = [[
$x = %d
$y = %d
]]
local GRAPHIC_SIZE = [[
$w = %d
$h = %d
]]
local GRAPHIC_SCREEN = [[
$size = new-object System.Drawing.Size $w, $h
$graphics.CopyFromScreen(%d, %d, $x, $y, $size);
]]
local GRAPHIC_CLIP = [[
$rect = new-object Drawing.Rectangle ($x - $ax * $w), ($y - $ay * $h), $w, $h
$graphics.SetClip($rect)
]]
local DIALOG_TEXT = [[
$font = new-object System.Drawing.Font "%s",%d
$string = '%s'
$size = $graphics.MeasureString($string, $font);
$graphics.DrawString($string, $font, $brush, ($x - $ax * $size.Width), ($y - $ay * $size.Height));
]]
local DIALOG_IMAGE = [[
$file = (get-item '%s')
$img = [System.Drawing.Image]::Fromfile($file);
$units = [System.Drawing.GraphicsUnit]::Pixel
$dest = new-object Drawing.Rectangle ($x - $ax * $w), ($y - $ay * $h), $w, $h
$src = new-object Drawing.Rectangle %d, %d, %d, %d
$graphics.DrawImage($img, $dest, $src, $units);
]]
local DIALOG_ELLIPSE = [[
$rect = new-object Drawing.Rectangle ($x - $ax * $w), ($y - $ay * $h), $w, $h
$graphics.%sEllipse(%s, $rect);
]]
local DIALOG_RECTANGLE = [[
$rect = new-object Drawing.Rectangle ($x - $ax * $w), ($y - $ay * $h), $w, $h
$graphics.%sRectangle(%s, $rect);
]]
local DIALOG_LINE = [[
%s
$points = %s
$graphics.DrawLines($pen, $points);
]]
local DIALOG_CURVE = [[
%s
$points = %s
$graphics.DrawCurve($pen, $points);
]]
local DIALOG_BEZIER = [[
%s
$points = %s
$graphics.DrawBeziers($pen, $points);
]]
local DIALOG_PIE = [[
$graphics.%sPie(%s, ($x - $ax * $w), ($y - $ay * $h), $w, $h, %d, %d);
]]
local DIALOG_ARC = [[
$graphics.DrawArc($pen, ($x - $ax * $w), ($y - $ay * $h), $w, $h, %d, %d);
]]
local DIALOG_POLYGON = [[
%s
$points = %s
$graphics.%sPolygon(%s, $points);
]]
function Graphic:__init__(w, h)
    assert(tools.is_windows(), 'platform not supported!')
    self._w = w or 500
    self._h = h or 500
    self._children = {}
    self._code = ""
end
function Graphic:setColor(color)
    color = color or "#eeeeee"
    self._code = self._code .. string.format(GRAPHIC_COLOR, color, color)
    return self
end
function Graphic:setSize(size)
    size = size or 10
    self._code = self._code .. string.format(GRAPHIC_SIZE, size)
    return self
end
function Graphic:setXY(x, y)
    x = x or 0
    y = y or 0
    self._code = self._code .. string.format(GRAPHIC_POSITION, x, y)
    return self
end
function Graphic:setWH(w, h)
    w = w or 0
    h = h or 0
    self._code = self._code .. string.format(GRAPHIC_SIZE, w, h)
    return self
end
function Graphic:copyScreen(fromX, fromY)
    fromX = fromX or 0
    fromY = fromY or 0
    self._code = self._code .. string.format(GRAPHIC_SCREEN, fromX, fromY)
    return self
end
function Graphic:setClip()
    self._code = self._code .. string.format(GRAPHIC_CLIP)
    return self
end
function Graphic:addText(text, size, font)
    text = text or "Text..."
    size = size or 13
    font = font or "Microsoft Sans Serif"
    self._code = self._code .. string.format(DIALOG_TEXT, font, size, text)
    return self
end
function Graphic:addImage(path, fromX, fromY, fromW, fromH)
    path = path or ""
    fromX = fromX or 0
    fromY = fromY or 0
    fromW = fromW or 250
    fromH = fromH or 250
    self._code = self._code .. string.format(DIALOG_IMAGE, path, fromX, fromY, fromW, fromH)
    return self
end
function Graphic:addEllipse(isFill)
    local mode, tool = self:_formatMode(isFill ~= false)
    self._code = self._code .. string.format(DIALOG_ELLIPSE, mode, tool)
    return self
end
function Graphic:addRectangle(isFill)
    local mode, tool = self:_formatMode(isFill ~= false)
    self._code = self._code .. string.format(DIALOG_RECTANGLE, mode, tool)
    return self
end
function Graphic:addLine(point1, point2, ...)
    local points = {point1, point2, ...}
    points = #points > 0 and points or {}
    local names, bodies = self:_formatPoints(points)
    self._code = self._code .. string.format(DIALOG_LINE, bodies, names)
    return self._children[#self._children]
end
function Graphic:addCurve(point1, point2, ...)
    local points = {point1, point2, ...}
    points = #points > 0 and points or {}
    local names, bodies = self:_formatPoints(points)
    self._code = self._code .. string.format(DIALOG_CURVE, bodies, names)
    return self._children[#self._children]
end
function Graphic:addBezier(start, cPointA1, cPointB1, end1, ...)
    local points = {start, cPointA1, cPointB1, end1, ...}
    points = #points > 0 and points or {}
    local names, bodies = self:_formatPoints(points)
    self._code = self._code .. string.format(DIALOG_BEZIER, bodies, names)
    return self._children[#self._children]
end
function Graphic:addPie(fromR, toR, isFill)
    fromR = fromR or 0
    toR = toR or 270
    local mode, tool = self:_formatMode(isFill ~= false)
    self._code = self._code .. string.format(DIALOG_PIE, mode, tool, fromR, toR)
    return self
end
function Graphic:addArc(fromR, toR)
    fromR = fromR or 0
    toR = toR or 270
    self._code = self._code .. string.format(DIALOG_ARC, fromR, toR)
    return self._children[#self._children]
end
function Graphic:addPolygon(point1, point2, ...)
    local points = {point1, point2, ...}
    points = #points > 0 and points or {}
    local names, bodies = self:_formatPoints(points)
    local mode, tool = self:_formatMode(false)
    self._code = self._code .. string.format(DIALOG_POLYGON, bodies, names, mode, tool)
    return self._children[#self._children]
end
function Graphic:_formatMode(isFill)
    if isFill then
        return "Fill", "$brush"
    else
        return "Draw", "$pen"
    end
end
function Graphic:_formatPoints(points)
    local names, bodies = "", ""
    for index,item in ipairs(points) do
        names = names .. string.format("$p%d", index) .. (index ~= #points and "," or "")
        bodies = bodies .. string.format("$p%s = new-object Drawing.Point %d, %d;", index, item[1], item[2])
    end
    return names, bodies
end
function Graphic:_runScript()
    files.write("running.ps1", self._code)
    local isOk, r = tools.execute([[ powershell.exe -file ./running.ps1]])
    assert(isOk, 'powershell execute failed:' .. r)
    files.delete("running.ps1")
end
function Graphic:show(title, icon)
    title = title or "Title..."
    icon = icon or "./others/test.ico"
    self._code = COMMON_HEADER .. string.format(FORM_CREATE, self._w, self._h) .. self._code -- HIDE_CONSOLE
    self._code = self._code .. string.format(FORM_SHOW, icon, title)
    self:_runScript()
end
function Graphic:save(path)
    path = path or "./graphic.png"
    self._code = COMMON_HEADER .. string.format(IMAGE_CREATE, self._w, self._h) .. self._code
    self._code = self._code .. string.format(IMAGE_SAVE, path)
    self:_runScript()
end

-- file:[./files/dialog.lua]

dialog = dialog or {}
local POWERSHELL = [[
param(
[string]$funcName,
[string]$arg1,
[string]$arg2,
[string]$arg3,
[string]$arg4,
[string]$arg5
)
Function return_result([string]$result) {
    Write-Host "[result[$result]result]"
}
Function select_file($windowTitle, $filterDesc, $startFolder) {
    Add-Type -AssemblyName System.Windows.Forms
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = $windowTitle
    $OpenFileDialog.InitialDirectory = $startFolder
    $OpenFileDialog.filter = $filterDesc
    If ($OpenFileDialog.ShowDialog() -eq "Cancel") {
        return_result ""
    } Else {
        return_result $OpenFileDialog.FileName
    }
}
function select_save($windowTitle, $filterDesc, $startFolder) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $OpenFileDialog.Title = $windowTitle
    $OpenFileDialog.initialDirectory = $startFolder
    $OpenFileDialog.filter = $filterDesc
    $OpenFileDialog.ShowDialog() |  Out-Null
    return_result $OpenFileDialog.filename
}
Function select_folder($windowTitle, $startFolder) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = $windowTitle
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $startFolder
    If ($foldername.ShowDialog() -eq "OK") {
        return_result $foldername.SelectedPath
    } else {
        return_result ""
    }
}
function select_color() {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.AnyColor = $true
    if ($dialog.ShowDialog() -eq "OK") {
        return_result "$($dialog.Color.R),$($dialog.Color.G),$($dialog.Color.B)"
    } Else {
        return_result ""
    }
}
Function show_confirm($title, $message, $flag) {
    Add-Type -AssemblyName Microsoft.VisualBasic
    $result = [Microsoft.VisualBasic.Interaction]::MsgBox($message, $flag, $title)
    return_result $result
}
Function show_input($title, $message, $default) {
    Add-Type -AssemblyName Microsoft.VisualBasic
    $result = [Microsoft.VisualBasic.Interaction]::InputBox($message, $title, $default)
    return_result $result
}
& $funcName $arg1 $arg2 $arg3 $arg4 $arg5
]]
local function dialog_execute_powershell(func, ...)
    assert(tools.is_windows(), 'platform not supported!')
    files.write("./running.ps1", POWERSHELL)
    local cmd = func
    local agrs = {...}
    for i,v in ipairs(agrs) do
        cmd = cmd .. [[ "]] .. tostring(v) .. [["]]
    end
    local isOk, r = tools.execute([[ powershell.exe -file ./running.ps1 ]] .. cmd)
    files.delete("running.ps1")
    assert(isOk, 'powershell execute failed:' .. cmd)
    return r:match(".*%[result%[(.*)%]result%].*")
end
local function dialog_validate_folder(folder)
    folder = folder:gsub('/', '\\')
    if folder:sub(-1, -1) == '\\' then
        folder = folder:sub(1, -2)
    end
    folder = folder:gsub('\\\\', '\\')
    return folder
end
function dialog.select_file(title, filter, folder)
    title = title or "please select a file ..."
    filter = filter or "All files (*.*)|*.*"
    folder = folder or ""
    print(dialog_validate_folder(folder))
    local path = dialog_execute_powershell("select_file", title, filter, dialog_validate_folder(folder))
    if string.valid(path) then
        return path
    end
end
function dialog.select_folder(title, folder)
    title = title or "please select a folder ..."
    folder = folder or ""
    local path = dialog_execute_powershell("select_folder", title, dialog_validate_folder(folder))
    if string.valid(path) then
        return path
    end
end
function dialog.select_save(title, filter, folder)
    title = title or "please save a file ..."
    filter = filter or "All files (*.*)|*.*"
    folder = folder or ""
    local path = dialog_execute_powershell("select_save", title, filter, dialog_validate_folder(folder))
    if string.valid(path) then
        return path
    end
end
function dialog.select_color()
    local color = dialog_execute_powershell("select_color")
    if string.valid(color) then
        local t = string.explode(color, ",")
        local r, g, b = tonumber(t[1]), tonumber(t[2]), tonumber(t[3])
        return r, g, b
    end
end
function dialog.show_confirm(title, message, flag)
    title = title or "title..."
    message = message or "confirm..."
    flag = flag or "YesNoCancel" -- YesNoCancel, YesNo, OkCancel, OKOnly, Critical, Question, Exclamation, Information
    local r = dialog_execute_powershell("show_confirm", title, message, flag)
    if r == "Yes" or r == "Ok" then return true end
    if r == "No" then return false end
    return nil
end
function dialog.show_input(title, message, default)
    title = title or "title..."
    message = message or "input..."
    default = default or ""
    local result = dialog_execute_powershell("show_input", title, message, default)
    if string.valid(result) then
        return result
    end
end

-- file:[./files/canvas.lua]

assert(Canvas == nil)
Canvas = class("Canvas")
function Canvas:__init__(w, h)
    self._width = w
    self._height = h
    self._empty = 0x000000
    self._pixels = {}
end
function Canvas:setPixel(x, y, pixel)
    local xi, xf = math.modf(x)
    local yi, yf = math.modf(y)
    if xf == 0.5 and yf == 0.5 then
        return
    elseif xf == 0.5 then
        self:setPixel(xi, y, pixel)
        self:setPixel(xi + 1, y, pixel)
        return
    elseif yf == 0.5 then
        self:setPixel(x, yi, pixel)
        self:setPixel(x, yi + 1, pixel)
        return
    end
    x = math.round(x)
    y = math.round(y)
    if not self._pixels[x] then
        self._pixels[x] = {}
    end
    self._pixels[x][y] = pixel
    return self
end
function Canvas:getPixel(x, y)
    return self._pixels[y] and self._pixels[y][x] or self._empty
end
function Canvas:getPixels(x, y, w, h)
    x = x or 1
    y = y or 1
    w = w or self._width
    h = h or self._height
    local r = {}
    for i=y,h do
        for j=x,w do
            table.insert(r, self:getPixel(j, i))
        end
    end
    return r
end
function Canvas:drawLine(fromX, fromY, toX, toY, pixel)
    local dx = toX >= fromX and 1 or -1
    local dy = toY >= fromY and 1 or -1
    local kx = (toY - fromY) / (toX - fromX)
    local ky = (toX - fromX) / (toY - fromY)
    local bx = fromY - kx * fromX
    local by = fromX - ky * fromY
    if kx ~= math.huge and kx ~= -math.huge and kx == kx then
        for x=fromX,toX,dx do
            local y = kx * x + bx
            self:setPixel(x, y, pixel)
        end
    end
    if ky ~= math.huge and ky ~= -math.huge and ky == ky then
        for y=fromY,toY,dy do
            local x = ky * y + by
            self:setPixel(x, y, pixel)
        end
    end
    return self
end
function Canvas:drawRect(fromX, fromY, toX, toY, isFill, pixel)
    local d = toX >= fromX and 1 or -1
    for x=fromX,toX,d do
        if isFill or x == fromX or x == toX then
            self:drawLine(x, fromY, x, toY, pixel)
        else
            self:setPixel(x, fromY, pixel)
            self:setPixel(x, toY, pixel)
        end
    end
    return self
end
function Canvas:drawCircle(cx, cy, r, isFill, pixel)
    for x=-r,r do
        y = math.round(math.sqrt(r * r - x * x))
        if isFill then
            self:drawLine(cx + x, cy + y, cx + x, cy - y, pixel)
        else
            self:setPixel(cx + x, cy + y, pixel)
            self:setPixel(cx + x, cy - y, pixel)
        end
    end
    for y=-r,r do
        x = math.round(math.sqrt(r * r - y * y))
        if isFill then
            self:drawLine(cx + x, cy + y, cx - x, cy + y, pixel)
        else
            self:setPixel(cx + x, cy + y, pixel)
            self:setPixel(cx - x, cy + y, pixel)
        end
    end
    return self
end
function Canvas:drawEllipse(cx, cy, w, h, pixel)
    for y=cy-h,cy+h do
        for x=cx-w,cx+w do
            local tx = (x - cx) / (w * 2)
            local ty = (y - cy) / (h * 2)
            if tx * tx + ty * ty <= 0.25 then
                self:setPixel(x, y, pixel)
            end
        end
    end
    return self
end

-- file:[./files/bmp.lua]

bmp = bmp or {}
function bmp.write(filename, width, height, pixels)
    local file = assert(io.open(filename, "wb"))
    assert(width % 4 == 0, "Invalid 4-byte alignment for width")
    assert(height % 4 == 0, "Invalid 4-byte alignment for height")
    assert(file ~= nil, 'open file failed:' .. tostring(filename))
    local fileheader = string.char(0x42, 0x4D) -- 文件类型，BM
    local filesize = 54 + 3 * width * height -- 文件大小
    fileheader = fileheader .. string.char(
        filesize % 256,
        math.floor(filesize / 256) % 256,
        math.floor(filesize / 65536) % 256,
        math.floor(filesize / 16777216) % 256
    ) -- 文件大小
    fileheader = fileheader .. string.rep(string.char(0), 4) -- 保留字段
    fileheader = fileheader .. string.char(54, 0, 0, 0) -- 数据起始位置
    local infoheader = string.char(40, 0, 0, 0) -- 信息头大小
    infoheader = infoheader .. string.char(
        width % 256,
        math.floor(width / 256) % 256,
        math.floor(width / 65536) % 256,
        math.floor(width / 16777216) % 256
    ) -- 图像宽度
    infoheader = infoheader .. string.char(
        height % 256,
        math.floor(height / 256) % 256,
        math.floor(height / 65536) % 256,
        math.floor(height / 16777216) % 256
    ) -- 图像高度
    infoheader = infoheader .. string.char(1, 0) -- 颜色平面数，必须为1
    infoheader = infoheader .. string.char(24, 0) -- 每个像素的位数，24位
    infoheader = infoheader .. string.rep(string.char(0), 4) -- 压缩方式，0表示不压缩
    local imagesize = 3 * width * height
    infoheader = infoheader .. string.char(
        imagesize % 256,
        math.floor(imagesize / 256) % 256,
        math.floor(imagesize / 65536) % 256,
        math.floor(imagesize / 16777216) % 256
    ) -- 图像数据大小
    infoheader = infoheader .. string.rep(string.char(0), 16) -- 其他信息
    file:write(fileheader)
    file:write(infoheader)
    for y = height, 1, -1 do
        for x = 1, width do
            local pixel = pixels[y][x]
            file:write(string.char(pixel[3], pixel[2], pixel[1]))
        end
    end
    file:close()
end
function bmp.read(filename)
    local file = assert(io.open(filename, "rb"))
    assert(file ~= nil, 'open file failed:' .. tostring(filename))
    local fileheader = file:read(14)
    local filetype = fileheader:sub(1,2)
    assert(filetype == "BM", "Not a BMP file")
    local filesize = fileheader:byte(3) +
        fileheader:byte(4) * 256 +
        fileheader:byte(5) * 65536 +
        fileheader:byte(6) * 16777216
    local datastart = fileheader:byte(11) +
        fileheader:byte(12) * 256 +
        fileheader:byte(13) * 65536 +
        fileheader:byte(14) * 16777216
    local infoheader = file:read(40)
    local width = infoheader:byte(5) +
        infoheader:byte(6) * 256 +
        infoheader:byte(7) * 65536 +
        infoheader:byte(8) * 16777216
    local height = infoheader:byte(9) +
        infoheader:byte(10) * 256 +
        infoheader:byte(11) * 65536 +
        infoheader:byte(12) * 16777216
    local bitsperpixel = infoheader:byte(15) +
        infoheader:byte(16) * 256
    assert(width % 4 == 0, "Invalid 4-byte alignment for width")
    assert(height % 4 == 0, "Invalid 4-byte alignment for height")
    assert(bitsperpixel == 24, "Only 24-bit BMP files are supported")
    local compression = infoheader:byte(17) +
        infoheader:byte(18) * 256 +
        infoheader:byte(19) * 65536 +
        infoheader:byte(20) * 16777216
    assert(compression == 0, "Compressed BMP files are not supported")
    local palette = file:read(datastart - 54)
    local pixels = {}
    for y = height, 1, -1 do
        pixels[y] = {}
        for x = 1, width do
            local b = file:read(1):byte()
            local g = file:read(1):byte()
            local r = file:read(1):byte()
            pixels[y][x] = {r, g, b}
        end
        file:read((4 - (width * 3) % 4) % 4)
    end
    file:close()
    return width, height, pixels
end

-- file:[./files/libs/log30.lua]

function log30_wrapper()
local class
local assert, pairs, type, tostring, baseMt, _instances, _classes, class = assert, pairs, type, tostring, {}, {}, {}
local function deep_copy(t, dest, aType)
  local t, r = t or {}, dest or {}
  for k,v in pairs(t) do
    if aType and type(v)==aType then r[k] = v elseif not aType then
      if type(v) == 'table' and k ~= "__index" then r[k] = deep_copy(v) else r[k] = v end
    end
  end; return r
end
local function instantiate(self,...)
  local instance = deep_copy(self) ; _instances[instance] = tostring(instance); setmetatable(instance,self)
  if self.__init then
    if type(self.__init) == 'table' then deep_copy(self.__init, instance) else self.__init(instance, ...) end
  end
  return instance
end
local function extends(self,extra_params)
  local heirClass = deep_copy(self, class(extra_params)); heirClass.__index, heirClass.super = heirClass, self
  return setmetatable(heirClass,self)
end
local baseMt = { __call = function (self,...) return self:new(...) end,
   __tostring = function(self,...)
    if _instances[self] then return ('object (of %s): <%s>'):format((rawget(getmetatable(self),'__name') or 'Unnamed'), _instances[self]) end
    return _classes[self] and ('class (%s): <%s>'):format((rawget(self,'__name') or 'Unnamed'),_classes[self]) or self
  end}
class = function(attr)
  local c = deep_copy(attr) ; _classes[c] = tostring(c);
  c.with = function(self,include) assert(_classes[self], 'Mixins can only be used on classes') return deep_copy(include, self, 'function') end
  c.new, c.extends, c.__index, c.__call, c.__tostring = instantiate, extends, c, baseMt.__call, baseMt.__tostring; return setmetatable(c,baseMt)
end;
return class
end

-- file:[./files/libs/deflate.lua]

function deflate_wrapper()
local M = {_TYPE='module', _NAME='compress.deflatelua', _VERSION='0.3.20111128'}
local assert = assert
local error = error
local ipairs = ipairs
local pairs = pairs
local print = print
local require = require
local tostring = tostring
local type = type
local setmetatable = setmetatable
local io = io
local math = math
local table_sort = table.sort
local math_max = math.max
local string_char = string.char
local function requireany(...)
  local errs = {}
  for i = 1, select('#', ...) do local name = select(i, ...)
    if type(name) ~= 'string' then return name, '' end
    local ok, mod = pcall(require, name)
    if ok then return mod, name end
    errs[#errs+1] = mod
  end
  error(table.concat(errs, '\n'), 2)
end
local bit, name_ = requireany('bit', 'bit32', 'bit.numberlua', nil)
local DEBUG = false
local NATIVE_BITOPS = (bit ~= nil)
local band, lshift, rshift
if NATIVE_BITOPS then
  band = bit.band
  lshift = bit.lshift
  rshift = bit.rshift
end
local function warn(s)
  io.stderr:write(s, '\n')
end
local function debug(...)
  print('DEBUG', ...)
end
local function runtime_error(s, level)
  level = level or 1
  error({s}, level+1)
end
local function make_outstate(outbs)
  local outstate = {}
  outstate.outbs = outbs
  outstate.window = {}
  outstate.window_pos = 1
  return outstate
end
local function output(outstate, byte)
  local window_pos = outstate.window_pos
  outstate.outbs(byte)
  outstate.window[window_pos] = byte
  outstate.window_pos = window_pos % 32768 + 1 -- 32K
end
local function noeof(val)
  return assert(val, 'unexpected end of file')
end
local function hasbit(bits, bit)
  return bits % (bit + bit) >= bit
end
local function memoize(f)
  local mt = {}
  local t = setmetatable({}, mt)
  function mt:__index(k)
    local v = f(k)
    t[k] = v
    return v
  end
  return t
end
local pow2 = memoize(function(n) return 2^n end)
local is_bitstream = setmetatable({}, {__mode='k'})
local function bytestream_from_file(fh)
  local o = {}
  function o:read()
    local sb = fh:read(1)
    if sb then return sb:byte() end
  end
  return o
end
local function bytestream_from_string(s)
  local i = 1
  local o = {}
  function o:read()
    local by
    if i <= #s then
      by = s:byte(i)
      i = i + 1
    end
    return by
  end
  return o
end
local function bytestream_from_function(f)
  local i = 0
  local buffer = ''
  local o = {}
  function o:read()
    i = i + 1
    if i > #buffer then
      buffer = f()
      if not buffer then return end
      i = 1
    end
    return buffer:byte(i,i)
  end
  return o
end
local function bitstream_from_bytestream(bys)
  local buf_byte = 0
  local buf_nbit = 0
  local o = {}
  function o:nbits_left_in_byte()
    return buf_nbit
  end
  if NATIVE_BITOPS then
    function o:read(nbits)
      nbits = nbits or 1
      while buf_nbit < nbits do
        local byte = bys:read()
        if not byte then return end -- note: more calls also return nil
        buf_byte = buf_byte + lshift(byte, buf_nbit)
        buf_nbit = buf_nbit + 8
      end
      local bits
      if nbits == 0 then
        bits = 0
      elseif nbits == 32 then
        bits = buf_byte
        buf_byte = 0
      else
        bits = band(buf_byte, rshift(0xffffffff, 32 - nbits))
        buf_byte = rshift(buf_byte, nbits)
      end
      buf_nbit = buf_nbit - nbits
      return bits
    end
  else
    function o:read(nbits)
      nbits = nbits or 1
      while buf_nbit < nbits do
        local byte = bys:read()
        if not byte then return end -- note: more calls also return nil
        buf_byte = buf_byte + pow2[buf_nbit] * byte
        buf_nbit = buf_nbit + 8
      end
      local m = pow2[nbits]
      local bits = buf_byte % m
      buf_byte = (buf_byte - bits) / m
      buf_nbit = buf_nbit - nbits
      return bits
    end
  end
  is_bitstream[o] = true
  return o
end
local function get_bitstream(o)
  local bs
  if is_bitstream[o] then
    return o
  elseif io.type(o) == 'file' then
    bs = bitstream_from_bytestream(bytestream_from_file(o))
  elseif type(o) == 'string' then
    bs = bitstream_from_bytestream(bytestream_from_string(o))
  elseif type(o) == 'function' then
    bs = bitstream_from_bytestream(bytestream_from_function(o))
  else
    runtime_error 'unrecognized type'
  end
  return bs
end
local function get_obytestream(o)
  local bs
  if io.type(o) == 'file' then
    bs = function(sbyte) o:write(string_char(sbyte)) end
  elseif type(o) == 'function' then
    bs = o
  else
    runtime_error('unrecognized type: ' .. tostring(o))
  end
  return bs
end
local function HuffmanTable(init, is_full)
  local t = {}
  if is_full then
    for val,nbits in pairs(init) do
      if nbits ~= 0 then
        t[#t+1] = {val=val, nbits=nbits}
      end
    end
  else
    for i=1,#init-2,2 do
      local firstval, nbits, nextval = init[i], init[i+1], init[i+2]
      if nbits ~= 0 then
        for val=firstval,nextval-1 do
          t[#t+1] = {val=val, nbits=nbits}
        end
      end
    end
  end
  table_sort(t, function(a,b)
    return a.nbits == b.nbits and a.val < b.val or a.nbits < b.nbits
  end)
  local code = 1 -- leading 1 marker
  local nbits = 0
  for i,s in ipairs(t) do
    if s.nbits ~= nbits then
      code = code * pow2[s.nbits - nbits]
      nbits = s.nbits
    end
    s.code = code
    code = code + 1
  end
  local minbits = math.huge
  local look = {}
  for i,s in ipairs(t) do
    minbits = math.min(minbits, s.nbits)
    look[s.code] = s.val
  end
  local msb = NATIVE_BITOPS and function(bits, nbits)
    local res = 0
    for i=1,nbits do
      res = lshift(res, 1) + band(bits, 1)
      bits = rshift(bits, 1)
    end
    return res
  end or function(bits, nbits)
    local res = 0
    for i=1,nbits do
      local b = bits % 2
      bits = (bits - b) / 2
      res = res * 2 + b
    end
    return res
  end
  local tfirstcode = memoize(
    function(bits) return pow2[minbits] + msb(bits, minbits) end)
  function t:read(bs)
    local code = 1 -- leading 1 marker
    local nbits = 0
    while 1 do
      if nbits == 0 then -- small optimization (optional)
        code = tfirstcode[noeof(bs:read(minbits))]
        nbits = nbits + minbits
      else
        local b = noeof(bs:read())
        nbits = nbits + 1
        code = code * 2 + b -- MSB first
      end
      local val = look[code]
      if val then
        return val
      end
    end
  end
  return t
end
local function parse_gzip_header(bs)
  local FLG_FHCRC = 2^1
  local FLG_FEXTRA = 2^2
  local FLG_FNAME = 2^3
  local FLG_FCOMMENT = 2^4
  local id1 = bs:read(8)
  local id2 = bs:read(8)
  if id1 ~= 31 or id2 ~= 139 then
    runtime_error 'not in gzip format'
  end
  local cm = bs:read(8) -- compression method
  local flg = bs:read(8) -- FLaGs
  local mtime = bs:read(32) -- Modification TIME
  local xfl = bs:read(8) -- eXtra FLags
  local os = bs:read(8) -- Operating System
  if DEBUG then
    debug("CM=", cm)
    debug("FLG=", flg)
    debug("MTIME=", mtime)
    debug("XFL=", xfl)
    debug("OS=", os)
  end
  if not os then runtime_error 'invalid header' end
  if hasbit(flg, FLG_FEXTRA) then
    local xlen = bs:read(16)
    local extra = 0
    for i=1,xlen do
      extra = bs:read(8)
    end
    if not extra then runtime_error 'invalid header' end
  end
  local function parse_zstring(bs)
    repeat
      local by = bs:read(8)
      if not by then runtime_error 'invalid header' end
    until by == 0
  end
  if hasbit(flg, FLG_FNAME) then
    parse_zstring(bs)
  end
  if hasbit(flg, FLG_FCOMMENT) then
    parse_zstring(bs)
  end
  if hasbit(flg, FLG_FHCRC) then
    local crc16 = bs:read(16)
    if not crc16 then runtime_error 'invalid header' end
    if DEBUG then
      debug("CRC16=", crc16)
    end
  end
end
local function parse_zlib_header(bs)
  local cm = bs:read(4) -- Compression Method
  local cinfo = bs:read(4) -- Compression info
  local fcheck = bs:read(5) -- FLaGs: FCHECK (check bits for CMF and FLG)
  local fdict = bs:read(1) -- FLaGs: FDICT (present dictionary)
  local flevel = bs:read(2) -- FLaGs: FLEVEL (compression level)
  local cmf = cinfo * 16 + cm -- CMF (Compresion Method and flags)
  local flg = fcheck + fdict * 32 + flevel * 64 -- FLaGs
  if cm ~= 8 then -- not "deflate"
    runtime_error("unrecognized zlib compression method: " .. cm)
  end
  if cinfo > 7 then
    runtime_error("invalid zlib window size: cinfo=" .. cinfo)
  end
  local window_size = 2^(cinfo + 8)
  if (cmf*256 + flg) % 31 ~= 0 then
    runtime_error("invalid zlib header (bad fcheck sum)")
  end
  if fdict == 1 then
    runtime_error("FIX:TODO - FDICT not currently implemented")
    local dictid_ = bs:read(32)
  end
  return window_size
end
local function parse_huffmantables(bs)
    local hlit = bs:read(5) -- # of literal/length codes - 257
    local hdist = bs:read(5) -- # of distance codes - 1
    local hclen = noeof(bs:read(4)) -- # of code length codes - 4
    local ncodelen_codes = hclen + 4
    local codelen_init = {}
    local codelen_vals = {
      16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15}
    for i=1,ncodelen_codes do
      local nbits = bs:read(3)
      local val = codelen_vals[i]
      codelen_init[val] = nbits
    end
    local codelentable = HuffmanTable(codelen_init, true)
    local function decode(ncodes)
      local init = {}
      local nbits
      local val = 0
      while val < ncodes do
        local codelen = codelentable:read(bs)
        local nrepeat
        if codelen <= 15 then
          nrepeat = 1
          nbits = codelen
        elseif codelen == 16 then
          nrepeat = 3 + noeof(bs:read(2))
        elseif codelen == 17 then
          nrepeat = 3 + noeof(bs:read(3))
          nbits = 0
        elseif codelen == 18 then
          nrepeat = 11 + noeof(bs:read(7))
          nbits = 0
        else
          error 'ASSERT'
        end
        for i=1,nrepeat do
          init[val] = nbits
          val = val + 1
        end
      end
      local huffmantable = HuffmanTable(init, true)
      return huffmantable
    end
    local nlit_codes = hlit + 257
    local ndist_codes = hdist + 1
    local littable = decode(nlit_codes)
    local disttable = decode(ndist_codes)
    return littable, disttable
end
local tdecode_len_base
local tdecode_len_nextrabits
local tdecode_dist_base
local tdecode_dist_nextrabits
local function parse_compressed_item(bs, outstate, littable, disttable)
  local val = littable:read(bs)
  if val < 256 then -- literal
    output(outstate, val)
  elseif val == 256 then -- end of block
    return true
  else
    if not tdecode_len_base then
      local t = {[257]=3}
      local skip = 1
      for i=258,285,4 do
        for j=i,i+3 do t[j] = t[j-1] + skip end
        if i ~= 258 then skip = skip * 2 end
      end
      t[285] = 258
      tdecode_len_base = t
    end
    if not tdecode_len_nextrabits then
      local t = {}
      if NATIVE_BITOPS then
        for i=257,285 do
          local j = math_max(i - 261, 0)
          t[i] = rshift(j, 2)
        end
      else
        for i=257,285 do
          local j = math_max(i - 261, 0)
          t[i] = (j - (j % 4)) / 4
        end
      end
      t[285] = 0
      tdecode_len_nextrabits = t
    end
    local len_base = tdecode_len_base[val]
    local nextrabits = tdecode_len_nextrabits[val]
    local extrabits = bs:read(nextrabits)
    local len = len_base + extrabits
    if not tdecode_dist_base then
      local t = {[0]=1}
      local skip = 1
      for i=1,29,2 do
        for j=i,i+1 do t[j] = t[j-1] + skip end
        if i ~= 1 then skip = skip * 2 end
      end
      tdecode_dist_base = t
    end
    if not tdecode_dist_nextrabits then
      local t = {}
      if NATIVE_BITOPS then
        for i=0,29 do
          local j = math_max(i - 2, 0)
          t[i] = rshift(j, 1)
        end
      else
        for i=0,29 do
          local j = math_max(i - 2, 0)
          t[i] = (j - (j % 2)) / 2
        end
      end
      tdecode_dist_nextrabits = t
    end
    local dist_val = disttable:read(bs)
    local dist_base = tdecode_dist_base[dist_val]
    local dist_nextrabits = tdecode_dist_nextrabits[dist_val]
    local dist_extrabits = bs:read(dist_nextrabits)
    local dist = dist_base + dist_extrabits
    for i=1,len do
      local pos = (outstate.window_pos - 1 - dist) % 32768 + 1 -- 32K
      output(outstate, assert(outstate.window[pos], 'invalid distance'))
    end
  end
  return false
end
local function parse_block(bs, outstate)
  local bfinal = bs:read(1)
  local btype = bs:read(2)
  local BTYPE_NO_COMPRESSION = 0
  local BTYPE_FIXED_HUFFMAN = 1
  local BTYPE_DYNAMIC_HUFFMAN = 2
  local BTYPE_RESERVED_ = 3
  if DEBUG then
    debug('bfinal=', bfinal)
    debug('btype=', btype)
  end
  if btype == BTYPE_NO_COMPRESSION then
    bs:read(bs:nbits_left_in_byte())
    local len = bs:read(16)
    local nlen_ = noeof(bs:read(16))
    for i=1,len do
      local by = noeof(bs:read(8))
      output(outstate, by)
    end
  elseif btype == BTYPE_FIXED_HUFFMAN or btype == BTYPE_DYNAMIC_HUFFMAN then
    local littable, disttable
    if btype == BTYPE_DYNAMIC_HUFFMAN then
      littable, disttable = parse_huffmantables(bs)
    else
      littable = HuffmanTable {0,8, 144,9, 256,7, 280,8, 288,nil}
      disttable = HuffmanTable {0,5, 32,nil}
    end
    repeat
      local is_done = parse_compressed_item(
        bs, outstate, littable, disttable)
    until is_done
  else
    runtime_error 'unrecognized compression type'
  end
  return bfinal ~= 0
end
function M.inflate(t)
  local bs = get_bitstream(t.input)
  local outbs = get_obytestream(t.output)
  local outstate = make_outstate(outbs)
  repeat
    local is_final = parse_block(bs, outstate)
  until is_final
end
local inflate = M.inflate
function M.gunzip(t)
  local bs = get_bitstream(t.input)
  local outbs = get_obytestream(t.output)
  local disable_crc = t.disable_crc
  if disable_crc == nil then disable_crc = false end
  parse_gzip_header(bs)
  local data_crc32 = 0
  inflate{input=bs, output=
    disable_crc and outbs or
      function(byte)
        data_crc32 = crc32(byte, data_crc32)
        outbs(byte)
      end
  }
  bs:read(bs:nbits_left_in_byte())
  local expected_crc32 = bs:read(32)
  local isize = bs:read(32) -- ignored
  if DEBUG then
    debug('crc32=', expected_crc32)
    debug('isize=', isize)
  end
  if not disable_crc and data_crc32 then
    if data_crc32 ~= expected_crc32 then
      runtime_error('invalid compressed data--crc error')
    end
  end
  if bs:read() then
    warn 'trailing garbage ignored'
  end
end
function M.adler32(byte, crc)
  local s1 = crc % 65536
  local s2 = (crc - s1) / 65536
  s1 = (s1 + byte) % 65521
  s2 = (s2 + s1) % 65521
  return s2*65536 + s1
end -- 65521 is the largest prime smaller than 2^16
function M.inflate_zlib(t)
  local bs = get_bitstream(t.input)
  local outbs = get_obytestream(t.output)
  local disable_crc = t.disable_crc
  if disable_crc == nil then disable_crc = false end
  local window_size_ = parse_zlib_header(bs)
  local data_adler32 = 1
  inflate{input=bs, output=
    disable_crc and outbs or
      function(byte)
        data_adler32 = M.adler32(byte, data_adler32)
        outbs(byte)
      end
  }
  bs:read(bs:nbits_left_in_byte())
  local b3 = bs:read(8)
  local b2 = bs:read(8)
  local b1 = bs:read(8)
  local b0 = bs:read(8)
  local expected_adler32 = ((b3*256 + b2)*256 + b1)*256 + b0
  if DEBUG then
    debug('alder32=', expected_adler32)
  end
  if not disable_crc then
    if data_adler32 ~= expected_adler32 then
      runtime_error('invalid compressed data--crc error')
    end
  end
  if bs:read() then
    warn 'trailing garbage ignored'
  end
end
return M
end

-- file:[./files/libs/stream.lua]

function stream_wrapper()
class = library and library.log30 or log30_wrapper()
local Stream = class()
Stream.data = {}
Stream.position = 1
Stream.__name = "Stream"
function Stream:__init(param)
    local str = ""	
    if (param.inputF ~= nil) then
	str = io.open(param.inputF, "rb"):read("*all")
    end
    if (param.input ~= nil) then
	str = param.input
    end
    for i=1,#str do
	self.data[i] = str:byte(i, i)
    end
end
function Stream:bsRight(num, pow)
    return math.floor(num / 2^pow)
end
function Stream:bsLeft(num, pow)
    return math.floor(num * 2^pow)
end
function Stream:bytesToNum(bytes)
	local n = 0
	for k,v in ipairs(bytes) do
		n = self:bsLeft(n, 8) + v
	end
	n = (n > 2147483647) and (n - 4294967296) or n
	return n
end
function Stream:seek(amount)
	self.position = self.position + amount
end
function Stream:readByte()
	if self.position <= 0 then self:seek(1) return nil end
	local byte = self.data[self.position]
	self:seek(1)
	return byte
end
function Stream:readChars(num)
	if self.position <= 0 then self:seek(1) return nil end
	local str = ""
	local i = 1
	while i <= num do
		str = str .. self:readChar()
		i = i + 1
	end
	return str, i-1
end
function Stream:readChar()
	if self.position <= 0 then self:seek(1) return nil end
	return string.char(self:readByte())
end
function Stream:readBytes(num)
	if self.position <= 0 then self:seek(1) return nil end
	local tabl = {}
	local i = 1
	while i <= num do
		local curByte = self:readByte()
		if curByte == nil then break end
		tabl[i] = curByte
		i = i + 1
	end
	return tabl, i-1
end
function Stream:readInt(num)
	if self.position <= 0 then self:seek(1) return nil end
	num = num or 4
	local bytes, count = self:readBytes(num)
	return self:bytesToNum(bytes), count
end
function Stream:writeByte(byte)
	if self.position <= 0 then self:seek(1) return end
	self.data[self.position] = byte
	self:seek(1)
end
function Stream:writeChar(char)
	if self.position <= 0 then self:seek(1) return end
	self:writeByte(string.byte(char))
end
function Stream:writeBytes(buffer)
	if self.position <= 0 then self:seek(1) return end
	local str = ""
	for k,v in pairs(buffer) do
		str = str .. string.char(v)
	end
	writeChars(str)
end
return Stream
end

-- file:[./files/libs/png_decode.lua]

function png_decode_wrapper()
deflate = library and library.deflate or lib_deflate_wrapper()
class = library and library.log30 or log30_wrapper()
Stream = library and library.stream or stream_wrapper()
local Chunk = class()
Chunk.__name = "Chunk"
Chunk.length = 0
Chunk.name = ""
Chunk.data = ""
Chunk.crc = ""
function Chunk:__init(stream)
	if stream.__name == "Chunk" then
		self.length = stream.length
		self.name = stream.name
		self.data = stream.data
		self.crc = stream.crc
	else
		self.length = stream:readInt()
		self.name = stream:readChars(4)
		self.data = stream:readChars(self.length)
		self.crc = stream:readChars(4)
	end
end
function Chunk:getDataStream()
	return Stream({input = self.data})
end
local IHDR = Chunk:extends()
IHDR.__name = "IHDR"
IHDR.width = 0
IHDR.height = 0
IHDR.bitDepth = 0
IHDR.colorType = 0
IHDR.compression = 0
IHDR.filter = 0
IHDR.interlace = 0
function IHDR:__init(chunk)
	self.super.__init(self, chunk)
	local stream = chunk:getDataStream()
	self.width = stream:readInt()
	self.height = stream:readInt()
	self.bitDepth = stream:readByte()
	self.colorType = stream:readByte()
	self.compression = stream:readByte()
	self.filter = stream:readByte()
	self.interlace = stream:readByte()
end
local IDAT = Chunk:extends()
IDAT.__name = "IDAT"
function IDAT:__init(chunk)
	self.super.__init(self, chunk)
end
local PLTE = Chunk:extends()
PLTE.__name = "PLTE"
PLTE.numColors = 0
PLTE.colors = {}
function PLTE:__init(chunk)
	self.super.__init(self, chunk)
	self.numColors = math.floor(chunk.length/3)
	local stream = chunk:getDataStream()
	for i = 1, self.numColors do
		self.colors[i] = {
			R = stream:readByte(),
			G = stream:readByte(),
			B = stream:readByte(),
		}
	end
end
function PLTE:getColor(index)
	return self.colors[index]
end
local Pixel = class()
Pixel.__name = "Pixel"
Pixel.R = 0
Pixel.G = 0
Pixel.B = 0
Pixel.A = 0
function Pixel:__init(stream, depth, colorType, palette)
	local bps = math.floor(depth/8)
	if colorType == 0 then
		local grey = stream:readInt(bps)
		self.R = grey
		self.G = grey
		self.B = grey
		self.A = 255
	end
	if colorType == 2 then
		self.R = stream:readInt(bps)
		self.G = stream:readInt(bps)
		self.B = stream:readInt(bps)
		self.A = 255
	end
	if colorType == 3 then
		local index = stream:readInt(bps)+1
		local color = palette:getColor(index)
		self.R = color.R
		self.G = color.G
		self.B = color.B
		self.A = 255
	end
	if colorType == 4 then
		local grey = stream:readInt(bps)
		self.R = grey
		self.G = grey
		self.B = grey
		self.A = stream:readInt(bps)
	end
	if colorType == 6 then
		self.R = stream:readInt(bps)
		self.G = stream:readInt(bps)
		self.B = stream:readInt(bps)
		self.A = stream:readInt(bps)
	end
end
function Pixel:format()
	return string.format("R: %d, G: %d, B: %d, A: %d", self.R, self.G, self.B, self.A)
end
local ScanLine = class()
ScanLine.__name = "ScanLine"
ScanLine.pixels = {}
ScanLine.filterType = 0
function ScanLine:__init(stream, depth, colorType, palette, length)
	bpp = math.floor(depth/8) * self:bitFromColorType(colorType)
	bpl = bpp*length
	self.filterType = stream:readByte()
	stream:seek(-1)
	stream:writeByte(0)
	local startLoc = stream.position
	if self.filterType == 0 then
		for i = 1, length do
			self.pixels[i] = Pixel(stream, depth, colorType, palette)
		end
	end
	if self.filterType == 1 then
		for i = 1, length do
			for j = 1, bpp do
				local curByte = stream:readByte()
				stream:seek(-(bpp+1))
				local lastByte = 0
				if stream.position >= startLoc then lastByte = stream:readByte() or 0 else stream:readByte() end
				stream:seek(bpp-1)
				stream:writeByte((curByte + lastByte) % 256)
			end
			stream:seek(-bpp)
			self.pixels[i] = Pixel(stream, depth, colorType, palette)
		end
	end
	if self.filterType == 2 then
		for i = 1, length do
			for j = 1, bpp do
				local curByte = stream:readByte()
				stream:seek(-(bpl+2))
				local lastByte = stream:readByte() or 0
				stream:seek(bpl)
				stream:writeByte((curByte + lastByte) % 256)
			end
			stream:seek(-bpp)
			self.pixels[i] = Pixel(stream, depth, colorType, palette)
		end
	end
	if self.filterType == 3 then
		for i = 1, length do
			for j = 1, bpp do
				local curByte = stream:readByte()
				stream:seek(-(bpp+1))
				local lastByte = 0
				if stream.position >= startLoc then lastByte = stream:readByte() or 0 else stream:readByte() end
				stream:seek(-(bpl)+bpp-2)
				local priByte = stream:readByte() or 0
				stream:seek(bpl)
				stream:writeByte((curByte + math.floor((lastByte+priByte)/2)) % 256)
			end
			stream:seek(-bpp)
			self.pixels[i] = Pixel(stream, depth, colorType, palette)
		end
	end
	if self.filterType == 4 then
		for i = 1, length do
			for j = 1, bpp do
				local curByte = stream:readByte()
				stream:seek(-(bpp+1))
				local lastByte = 0
				if stream.position >= startLoc then lastByte = stream:readByte() or 0 else stream:readByte() end
				stream:seek(-(bpl + 2 - bpp))
				local priByte = stream:readByte() or 0
				stream:seek(-(bpp+1))
				local lastPriByte = 0
				if stream.position >= startLoc - (length * bpp + 1) then lastPriByte = stream:readByte() or 0 else stream:readByte() end
				stream:seek(bpl + bpp)
				stream:writeByte((curByte + self:_PaethPredict(lastByte, priByte, lastPriByte)) % 256)
			end
			stream:seek(-bpp)
			self.pixels[i] = Pixel(stream, depth, colorType, palette)
		end
	end
end
function ScanLine:bitFromColorType(colorType)
	if colorType == 0 then return 1 end
	if colorType == 2 then return 3 end
	if colorType == 3 then return 1 end
	if colorType == 4 then return 2 end
	if colorType == 6 then return 4 end
	error 'Invalid colortype'
end
function ScanLine:getPixel(pixel)
	return self.pixels[pixel]
end
function ScanLine:_PaethPredict(a, b, c)
	local p = a + b - c
	local varA = math.abs(p - a)
	local varB = math.abs(p - b)
	local varC = math.abs(p - c)
	if varA <= varB and varA <= varC then return a end
	if varB <= varC then return b end
	return c
end
local pngImage = class()
pngImage.__name = "PNG"
pngImage.width = 0
pngImage.height = 0
pngImage.depth = 0
pngImage.colorType = 0
pngImage.scanLines = {}
function pngImage:__init(data, progCallback)
	local str = Stream({input = data})
	if str:readChars(8) ~= "\137\080\078\071\013\010\026\010" then error 'Not a PNG' end
	local ihdr = {}
	local plte = {}
	local idat = {}
	local num = 1
	while true do
		ch = Chunk(str)
		if ch.name == "IHDR" then ihdr = IHDR(ch) end
		if ch.name == "PLTE" then plte = PLTE(ch) end
		if ch.name == "IDAT" then idat[num] = IDAT(ch) num = num+1 end
		if ch.name == "IEND" then break end
	end
	self.width = ihdr.width
	self.height = ihdr.height
	self.depth = ihdr.bitDepth
	self.colorType = ihdr.colorType
	local dataStr = ""
	for k,v in pairs(idat) do dataStr = dataStr .. v.data end
	local output = {}
	deflate.inflate_zlib {input = dataStr, output = function(byte) output[#output+1] = string.char(byte) end, disable_crc = true}
	imStr = Stream({input = table.concat(output)})
	for i = 1, self.height do
		self.scanLines[i] = ScanLine(imStr, self.depth, self.colorType, plte, self.width)
		if progCallback ~= nil then progCallback(i, self.height) end
	end
end
function pngImage:getPixel(x, y)
	local pixel = self.scanLines[y].pixels[x]
	return pixel
end
return pngImage
end

-- file:[./files/libs/png_encode.lua]

function png_encode_wrapper()
local Png = {}
Png.__index = Png
local DEFLATE_MAX_BLOCK_SIZE = 65535
local function putBigUint32(val, tbl, index)
    for i=0,3 do
        tbl[index + i] = bit.band(bit.rshift(val, (3 - i) * 8), 0xFF)
    end
end
function Png:writeBytes(data, index, len)
    index = index or 1
    len = len or #data
    for i=index,index+len-1 do
        table.insert(self.output, string.char(data[i]))
    end
end
function Png:write(pixels)
    local count = #pixels  -- Byte count
    local pixelPointer = 1
    while count > 0 do
        if self.positionY >= self.height then
            error("All image pixels already written")
        end
        if self.deflateFilled == 0 then -- Start DEFLATE block
            local size = DEFLATE_MAX_BLOCK_SIZE;
            if (self.uncompRemain < size) then
                size = self.uncompRemain
            end
            local header = {  -- 5 bytes long
                bit.band((self.uncompRemain <= DEFLATE_MAX_BLOCK_SIZE and 1 or 0), 0xFF),
                bit.band(bit.rshift(size, 0), 0xFF),
                bit.band(bit.rshift(size, 8), 0xFF),
                bit.band(bit.bxor(bit.rshift(size, 0), 0xFF), 0xFF),
                bit.band(bit.bxor(bit.rshift(size, 8), 0xFF), 0xFF),
            }
            self:writeBytes(header)
            self:crc32(header, 1, #header)
        end
        assert(self.positionX < self.lineSize and self.deflateFilled < DEFLATE_MAX_BLOCK_SIZE);
        if (self.positionX == 0) then  -- Beginning of line - write filter method byte
            local b = {0}
            self:writeBytes(b)
            self:crc32(b, 1, 1)
            self:adler32(b, 1, 1)
            self.positionX = self.positionX + 1
            self.uncompRemain = self.uncompRemain - 1
            self.deflateFilled = self.deflateFilled + 1
        else -- Write some pixel bytes for current line
            local n = DEFLATE_MAX_BLOCK_SIZE - self.deflateFilled;
            if (self.lineSize - self.positionX < n) then
                n = self.lineSize - self.positionX
            end
            if (count < n) then
                n = count;
            end
            assert(n > 0);
            self:writeBytes(pixels, pixelPointer, n)
            self:crc32(pixels, pixelPointer, n);
            self:adler32(pixels, pixelPointer, n);
            count = count - n;
            pixelPointer = pixelPointer + n;
            self.positionX = self.positionX + n;
            self.uncompRemain = self.uncompRemain - n;
            self.deflateFilled = self.deflateFilled + n;
        end
        if (self.deflateFilled >= DEFLATE_MAX_BLOCK_SIZE) then
            self.deflateFilled = 0; -- End current block
        end
        if (self.positionX == self.lineSize) then  -- Increment line
            self.positionX = 0;
            self.positionY = self.positionY + 1;
            if (self.positionY == self.height) then -- Reached end of pixels
                local footer = {  -- 20 bytes long
                    0, 0, 0, 0,  -- DEFLATE Adler-32 placeholder
                    0, 0, 0, 0,  -- IDAT CRC-32 placeholder
                    0x00, 0x00, 0x00, 0x00,
                    0x49, 0x45, 0x4E, 0x44,
                    0xAE, 0x42, 0x60, 0x82,
                }
                putBigUint32(self.adler, footer, 1)
                self:crc32(footer, 1, 4)
                putBigUint32(self.crc, footer, 5)
                self:writeBytes(footer)
                self.done = true
            end
        end
    end
end
function Png:crc32(data, index, len)
    self.crc = bit.bnot(self.crc)
    for i=index,index+len-1 do
        local byte = data[i]
        for j=0,7 do  -- Inefficient bitwise implementation, instead of table-based
            local nbit = bit.band(bit.bxor(self.crc, bit.rshift(byte, j)), 1);
            self.crc = bit.bxor(bit.rshift(self.crc, 1), bit.band((-nbit), 0xEDB88320));
        end
    end
    self.crc = bit.bnot(self.crc)
end
function Png:adler32(data, index, len)
    local s1 = bit.band(self.adler, 0xFFFF)
    local s2 = bit.rshift(self.adler, 16)
    for i=index,index+len-1 do
        s1 = (s1 + data[i]) % 65521
        s2 = (s2 + s1) % 65521
    end
    self.adler = bit.bor(bit.lshift(s2, 16), s1)
end
local function begin(width, height, colorMode)
    colorMode = colorMode or "rgb"
    local bytesPerPixel, colorType
    if colorMode == "rgb" then
        bytesPerPixel, colorType = 3, 2
    elseif colorMode == "rgba" then
        bytesPerPixel, colorType = 4, 6
    else
        error("Invalid colorMode")
    end
    local state = setmetatable({ width = width, height = height, done = false, output = {} }, Png)
    state.lineSize = width * bytesPerPixel + 1
    state.uncompRemain = state.lineSize * height
    local numBlocks = math.ceil(state.uncompRemain / DEFLATE_MAX_BLOCK_SIZE)
    local idatSize = numBlocks * 5 + 6
    idatSize = idatSize + state.uncompRemain;
    local header = {  -- 43 bytes long
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
        0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52,
        0, 0, 0, 0,  -- 'width' placeholder
        0, 0, 0, 0,  -- 'height' placeholder
        0x08, colorType, 0x00, 0x00, 0x00,
        0, 0, 0, 0,  -- IHDR CRC-32 placeholder
        0, 0, 0, 0,  -- 'idatSize' placeholder
        0x49, 0x44, 0x41, 0x54,
        0x08, 0x1D,
    }
    putBigUint32(width, header, 17)
    putBigUint32(height, header, 21)
    putBigUint32(idatSize, header, 34)
    state.crc = 0
    state:crc32(header, 13, 17)
    putBigUint32(state.crc, header, 30)
    state:writeBytes(header)
    state.crc = 0
    state:crc32(header, 38, 6);  -- 0xD7245B6B
    state.adler = 1
    state.positionX = 0
    state.positionY = 0
    state.deflateFilled = 0
    return state
end
return begin
end

-- file:[./files/library.lua]

library = library or {}
library.log30 = log30_wrapper()
library.Stream = stream_wrapper()
library.deflate = deflate_wrapper()
library.pngEncode = png_encode_wrapper()
library.pngDecode = png_decode_wrapper()
