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
