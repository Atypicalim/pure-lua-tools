--[[
    yaml
]]

yaml = yaml or {}

function yaml.null()
    return yaml.null
end

function yaml.convert(val)
    val = string.trim(val)
    -- 
    local low = string.lower(val)
    if low == "null" or low == "~" then
        return yaml.null
    elseif low == "true" or low == "yes" or low == "on" then
        return true
    elseif low == "false" or low == "no" or low == "off" then
        return false
    end
    --
    if (val:starts("'") and val:ends("'")) or (val:starts('"') and val:ends('"')) then
        return string.sub(val, 2, -2)
    end
    --
    local num = tonumber(val)
    if num then
        return num
    end
    --
    local time = {string.match(val, "^(%d%d%d%d)%-(%d%d)%-(%d%d)[Tt_ ](%d%d):(%d%d):(%d%d)([%+%-]%d%d?)$")}
    if table.is_empty(time) then
        time = {string.match(val, "^(%d%d%d%d)%-(%d%d)%-(%d%d)[Tt_ ](%d%d):(%d%d):(%d%d)([%+%-]%d%d?)$")}
    end
    if table.is_empty(time) then
        time = {string.match(val, "^(%d%d%d%d)%-(%d%d)%-(%d%d)[Tt_ ](%d%d):(%d%d):(%d%d)$")}
    end
    if table.is_empty(time) then
        time = {string.match(val, "^(%d%d%d%d)%-(%d%d)%-(%d%d)$")}
    end
    if not table.is_empty(time) then
        local y = tonumber(time[1])
        local m = tonumber(time[2])
        local d = tonumber(time[3])
        assert(d ~= nil)
        local hou = tonumber(time[4]) or 0
        local min = tonumber(time[5]) or 0
        local sec = tonumber(time[6]) or 0
        local zone = tonumber(time[7]) or 0
        local t = os.time({year = y, month = m, day = d, hour = hou, min = min, sec = sec})
        t = t - zone * 60 * 60
        return t
    end
    -- 
    return val
end

function yaml.decode(text)
    local spacing = 2
    local ready = false
    local indenting = 1
    local result = {}
    local stack = { result }
    local current = result
    local anchors = {}
    local index = 0
    local lines = {}
    for line in text:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    --
    local function assertExt(bool, msg)
        assert(bool, msg .. " at line:" .. index .. ", content:[[" .. lines[index] .. "]]")
    end
    local function pushStack()
        current = {}
        table.insert(stack, current)
        indenting = indenting + 1
        return current
    end
    local function popStack()
        table.remove(stack)
        current = stack[#stack]
        indenting = indenting - 1
        return current
    end
    local function writeAnchor(name, content)
        assertExt(anchors[name] == nil, 'multiple yaml anchor')
        anchors[name] = content
    end
    local function readAnchor(name, tp)
        local content = anchors[name]
        assertExt(content ~= nil, 'invalid yaml anchor!')
        if tp then
            assertExt(type(content) == tp, 'invalid anchor type!')
        end
        return content
    end
    --
    local function consume(index, line, t)
        line = string.trim(line)
        -- line comment
        if line:starts("#") then
            return
        end
        -- 
        if line:match("^-%s*%&%a%w+%s+[^%s]+$") then
            -- array anchor define
            local name, val = line:match("^-%s*%&(%a%w+)%s+([^%s]+)$")
            local key = #t + 1
            t[key] = yaml.convert(val)
            writeAnchor(name, t[key])
        elseif line:match("^-%s*%*%s*[^%s]+$") then
            -- array anchor use
            local name, val = line:match("^-%s*%*%s*([^%s]+)$")
            local key = #t + 1
            t[key] = readAnchor(name, nil)
        elseif line:match("^-%s*") then
            -- array normal process
            local val = line:sub(2)
            local key = #t + 1
            t[key] = yaml.convert(val)
        elseif line:match("^%w+%s*:%s*%&%a%w+$") then
            -- map anchor define
            local key, name = line:match("^(%a%w*)%s*:%s*%&(%a%w*)$")
            t[key] = pushStack()
            writeAnchor(name, t[key])
        elseif line:match("^<<:%s*%*%a%w*$") then
            -- map anchor use
            local name = line:match("*(%a%w*)$")
            for k,v in pairs(readAnchor(name, 'table')) do
                t[k] = v
            end
        elseif line:match("%w+%s*:") then
            -- map normal process
            local key, val = line:match("^%s*(%w+)%s*:%s*(.*)$")
            assertExt(string.valid(key), 'invalid yaml key')
            if not string.valid(val) then
                t[key] = pushStack()
            else
                t[key] = yaml.convert(val)
            end
        else
            assertExt(false, 'invalid yaml line!')
        end
    end
    --
    for _,line in ipairs(lines) do
        index = index + 1
        local spaces = line:match("^(%s*)")
        local count = #spaces
        -- spacing
        if count > 0 and not ready then
            spacing = count
            ready = true
        end
        -- lines
        local indent = #spaces / spacing + 1
        if indent == indenting then
            consume(index, line, current)
        elseif indent < indenting then
            local num = indenting - indent
            assertExt(num < #stack, 'invalid yaml stack!')
            for i=1,num do popStack() end
            assertExt(current ~= nil, 'invalid yaml stack!')
            consume(index, line, current)
        else
            error('invalid yaml indent!')
        end
    end
    return result
end
