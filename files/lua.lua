-- lua extentions

function null()
    return null
end

function is_table(v)
    return type(v) == 'table'
end

function is_array(v)
    return type(v) == 'table' and #v == table.count(v)
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
    return type(v) == 'nil' or v == null
end

function is_empty(v)
    if is_nil(v) then
        return true
    end
    if is_table(v) then
        return next(v) == nil
    end
    return false
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

if not rawget(_G, "lua_print") then
    rawset(_G, "lua_print", print)
end
function print(...)
    local args = {...}
    for i=1,select("#", ...) do
        local v = args[i]
        if v == null then
            v = "null"
        elseif is_table(v) then
            v = table.printable(v, "  ")
        else
            v = tostring(v)
        end
        io.write(v, "  ")
    end
    io.write('\n')
end

local style_flag = nil
local STYLE_MAP = {
    RESET = 0,
    BOLD = 1,
    UNDERLINE = 4,
    INVERSE = 7,
    BLACK = 90,
    RED = 91,
    GREEN = 92,
    YELLOW = 93,
    BLUE = 94,
    MAGENTA = 95,
    CYAN = 96,
    WHITE = 97,
}
function print_styled(name, ...)
    if not style_flag then
        style_flag = true
        os.execute('cd > nul 2>&1')
    end
    name = name and string.upper(name) or "RESET"
    local color = STYLE_MAP[name] or STYLE_MAP.RESET
    io.write(string.format('\27[%dm', color))
    print(...)
    io.write('\27[0m')
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
