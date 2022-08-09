
-- tools:[2022-08-09_09:51:01]

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
function string.ltrim(this)
    return string.gsub(this, "^[ \t\n\r]+", "")
end
function string.rtrim(this)
    return string.gsub(this, "[ \t\n\r]+$", "")
end
function string.trim(this)
    return this:ltrim():rtrim()
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
            if encodable(i) and encodable(j) then
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

-- file:[./files/files.lua]

files = files or {}
local delimiter = nil
function files.delimiter()
    if delimiter then return delimiter end
    delimiter = string.find(os.tmpname(""), "\\") and "\\" or "/"
    return delimiter
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
function files.modified(path, isDebug)
    local stamp = nil
    xpcall(function()
        local isOk, result = tools.execute("stat -f %m " .. path) -- mac
        if isOk then
            stamp = result
        end
    end, function(err)
        if isDebug then
            print(err)
        end
    end)
    xpcall(function()
        local isOk, result = tools.execute([[forfiles /M ]] .. path .. [[ /C "cmd /c echo @fdate_@ftime"]]) -- windows
        if isOk then
            result = string.trim(result or "")
        end
        local year, month, day, hour, minute, second = string.match(result, "(%d+)%/(%d+)%/(%d+)_(%d+):(%d+):(%d+)")
        if year then
            stamp = os.time({year = year, month = month, day = day, hour = hour, min = minute, sec = second})
        end
    end, function(err)
        if isDebug then
            print(err)
        end
    end)
    if not stamp then
        return -1
    end
    local modified = tonumber(stamp) or -1
    return modified
end
function files.watch(paths, callback, runInit, triggerDelay, checkDelay)
    if is_string(paths) then paths = {paths} end
    assert(#paths >= 1, 'the paths to watch should not be empty')
    assert(is_function(callback), 'the last argument should be a callback func')
    if not is_boolean(runInit) then
        runInit = true
    end
    checkDelay = checkDelay or 1
    triggerDelay = triggerDelay or 1
    local modifiedMap = {}
    local function check(path)
        local modifiedTime = files.modified(path)
        if not modifiedMap[path] then
            if runInit then
                callback(path, modifiedTime)
            end
        elseif modifiedTime - modifiedMap[path] > triggerDelay then
            callback(path, modifiedTime)
        end
        modifiedMap[path] = modifiedTime
    end
    timer.delay(0, function()
        for i,v in ipairs(paths) do
            check(v)
        end
        return checkDelay
    end)
    timer.start()
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
    local isOk, output, code = tools.execute(cmd)
    return isOk, output, code, cmd
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
    local env = os.getenv("HOME") or ""
    isWindows = string.find(env, '/c/Users') ~= nil or string.find(env, 'C:\\Users') ~= nil
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
    local path = string.format('./.lua.execute_%d.log', os.time())
    files.delete(path)
    local command = string.format('%s >> ./%s 2>&1', cmd, path)
    local result, _ = os.execute(command)
    local isOk = result == true or result == 0
    local output = files.read(path)
    files.delete(path)
    return isOk, output
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
    tools.execute("cd")
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
