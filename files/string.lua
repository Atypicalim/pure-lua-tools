--[[
    string
]]

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

function string.implode(t, separator)
    return table.concat(t, separator)
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

function string.limit(this, length, suffix)
    assert(length > 0, 'invalid limit length')
    suffix = suffix or "..."
    assert(length > #suffix, 'invalid limit length')
    if #this <= length then
        return this
    else
        return stirng.sub(this, 1, length - #suffix) .. suffix
    end
end

function string.render(this, ...)
    local args = {...}
    if is_table(args[1]) then
        args = args[1]
    end
    local rgxp = is_array(args) and "{(%d+)}" or "{(%w+)}"
    local result = this:gsub(rgxp, function(val)
        local key = is_array(args) and tonumber(val) or val
        return args[key] and tostring(args[key]) or "{" .. key .. "}"
    end)
    return result
end

function string.utf8_encode(code)
    assert(is_number(code) and code % 1 == 0, 'invalid unicode code point')
    assert(code >= 0 and code <= 0x10FFFF, 'invalid unicode code point')
    assert(code < 0xD800 or code > 0xDFFF, 'invalid unicode surrogate')
    if code <= 0x7F then
        return string.char(code)
    elseif code <= 0x7FF then
        return string.char(0xC0 + math.floor(code / 0x40), 0x80 + code % 0x40)
    elseif code <= 0xFFFF then
        return string.char(0xE0 + math.floor(code / 0x1000),
            0x80 + math.floor(code / 0x40) % 0x40, 0x80 + code % 0x40)
    end
    return string.char(0xF0 + math.floor(code / 0x40000),
        0x80 + math.floor(code / 0x1000) % 0x40,
        0x80 + math.floor(code / 0x40) % 0x40, 0x80 + code % 0x40)
end

function string.utf8_read(this, index)
    local b = string.byte(this, index)
    local code, size
    if b < 0x80 then
        code, size = b, 1
    elseif b >= 0xC2 and b <= 0xDF then
        code, size = b % 0x20, 2
    elseif b >= 0xE0 and b <= 0xEF then
        code, size = b % 0x10, 3
    elseif b >= 0xF0 and b <= 0xF4 then
        code, size = b % 0x08, 4
    else
        error('invalid utf8 leading byte at ' .. index)
    end
    assert(index + size - 1 <= #this, 'truncated utf8 sequence at ' .. index)
    for i = index + 1, index + size - 1 do
        local nextByte = string.byte(this, i)
        assert(nextByte >= 0x80 and nextByte <= 0xBF, 'invalid utf8 continuation byte at ' .. i)
        code = code * 0x40 + nextByte % 0x40
    end
    if size == 2 then
        assert(code >= 0x80, 'overlong utf8 sequence at ' .. index)
    elseif size == 3 then
        assert(code >= 0x800, 'overlong utf8 sequence at ' .. index)
    elseif size == 4 then
        assert(code >= 0x10000, 'overlong utf8 sequence at ' .. index)
    end
    assert(code < 0xD800 or code > 0xDFFF, 'invalid unicode surrogate at ' .. index)
    assert(code <= 0x10FFFF, 'invalid unicode code point at ' .. index)
    return code, size
end

function string.utf8_decode(this)
    assert(is_string(this))
    local codes = table.new()
    local index = 1
    while index <= #this do
        local code, size = string.utf8_read(this, index)
        table.insert(codes, code)
        index = index + size
    end
    return codes
end

function string.utf8_len(this)
    assert(is_string(this))
    local count = 0
    for i = 1, #this do
        local b = string.byte(this, i)
        if b < 0x80 or b >= 0xC0 then
            count = count + 1
        end
    end
    return count
end

function string.utf8_find(this, charIndex)
    assert(is_string(this))
    assert(is_number(charIndex) and charIndex % 1 == 0 and charIndex ~= 0, 'invalid character index')
    if charIndex < 0 then
        charIndex = string.utf8_len(this) + charIndex + 1
    end
    if charIndex < 1 then return nil end
    local current = 0
    local index = 1
    while index <= #this do
        local b = string.byte(this, index)
        local size = 1
        if b >= 0xC2 and b <= 0xDF then
            size = 2
        elseif b >= 0xE0 and b <= 0xEF then
            size = 3
        elseif b >= 0xF0 and b <= 0xF4 then
            size = 4
        end
        current = current + 1
        if current == charIndex then
            return index, math.min(index + size - 1, #this)
        end
        index = index + size
    end
end

function string.utf8_sub(this, first, last)
    assert(is_string(this))
    first = first or 1
    last = last or -1
    local length = string.utf8_len(this)
    if first < 0 then first = length + first + 1 end
    if last < 0 then last = length + last + 1 end
    if first < 1 then first = 1 end
    if last > length then last = length end
    if first > last or first > length or last < 1 then
        return ""
    end
    local from = string.utf8_find(this, first)
    local _, to = string.utf8_find(this, last)
    return string.sub(this, from, to)
end

function string.utf8_codepoint(this, charIndex)
    assert(is_string(this))
    charIndex = charIndex or 1
    assert(is_number(charIndex) and charIndex % 1 == 0 and charIndex ~= 0, 'invalid character index')
    local index = string.utf8_find(this, charIndex)
    assert(index ~= nil, 'invalid character index')
    local code = string.utf8_read(this, index)
    return code
end

function string.utf8_codes(this)
    assert(is_string(this))
    local index = 1
    return function()
        if index > #this then return nil end
        local position = index
        local code, size = string.utf8_read(this, index)
        index = index + size
        return position, code
    end
end

function string.utf8_valid(this)
    assert(is_string(this))
    local isOk = pcall(string.utf8_decode, this)
    return isOk
end

function string.utf8_reverse(this)
    assert(is_string(this))
    local chars = table.new()
    local index = 1
    while index <= #this do
        local code, size = string.utf8_read(this, index)
        table.insert(chars, string.utf8_encode(code))
        index = index + size
    end
    local result = table.new()
    for i = #chars, 1, -1 do
        table.insert(result, chars[i])
    end
    return table.concat(result)
end
