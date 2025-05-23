-- lua extentions

function null()
    return null
end

function is_userdata(v)
    return type(v) == 'userdata'
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
        elseif is_class(v) or is_object(v) then
            v = tostring(v)
        elseif is_table(v) then
            v = table.printable(v, "  ")
        else
            v = tostring(v)
        end
        io.write(v, "  ")
    end
    io.write('\n')
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

function lua_set_debug(enable)
    rawset(_G, 'lua-is-debug', enable == true)
end

function lua_is_debug()
    return rawget(_G, 'lua-is-debug') == true
end

function lua_set_user(user)
    assert(#user >= 3, 'invalid user format')
    assert(string.match(user, '%w+'), 'invalid user format')
    rawset(_G, 'lua-user-name', user)
end

function lua_get_user()
    return rawget(_G, 'lua-user-name') or 'unknown'
end

function lua_script_path(level)
    level = level or 0
    local info = debug.getinfo(2 + level, "S")
    if info and info.source and info.source:sub(1, 1) == "@" then
        return info.source:sub(2)
    end
    return nil
end

function lua_new_decorator(func)
    assert(func == nil or is_function(func))
    local function _call(self, ...)
        local args = {...}
        if self._bFunc then
            local _results = {self._bFunc(unpack(args))}
            if #_results > 0 then
                args = _results
            end
        end
        assert(self._fFunc, 'decorator func not found')
        local results = nil
        if not self._eFunc then
            results = {self._fFunc(unpack(args))}
        else
            xpcall(function()
                results = {self._fFunc(unpack(args))}
            end, function(e)
                results = {self._eFunc(e)}
            end)
        end
        assert(results ~= nil, 'decorator logic eror found')
        if self._aFunc then
            local _results = {self._aFunc(unpack(results))}
            if #_results > 0 then
                results = _results
            end
        end
        return unpack(results)
    end
    local decorator = {
        _bFunc = nil,
        _fFunc = func,
        _eFunc = nil,
        _aFunc = nil,
    }
    function decorator:before(func)
        assert(func == nil or is_function(func))
        self._bFunc = func
        return self
    end
    function decorator:after(func)
        assert(func == nil or is_function(func))
        self._aFunc = func
        return self
    end
    function decorator:error(func)
        assert(func == nil or is_function(func))
        self._eFunc = func
        return self
    end
    function decorator:func(func)
        assert(func == nil or is_function(func))
        self._fFunc = func
        return self
    end
    function decorator:call(...)
        return _call(self, ...)
    end
    setmetatable(decorator, {__call = _call})
    return decorator
end

local function __lua_delegate_func(t, k)
    local v = rawget(t, k)
    if v ~= nil then
        return
    end
    local _meta = rawget(t, "__delegated")
    local _dlgt = rawget(t, "__delegation")
    if _meta ~= nil and _meta.__index ~= nil and _meta.__index ~= __lua_delegate_func then
        v = _meta.__index[k]
    end
    if v ~= nil then
        return v
    end
    -- 
    if is_function(_dlgt) then
        v = function(...) return _dlgt(k, ...) end
    elseif is_userdata(_dlgt) then
        if is_function(_dlgt[k]) then
            v = function(_t, ...) return _dlgt[k](_dlgt, ...) end
        else
            v = _dlgt[k]
        end
    end
    return v
end

function lua_set_delegate(obj, delegation)
    rawset(obj, '__delegation', delegation)
    if rawget(obj, '__delegated') ~= nil or delegation == nil then return end
    local _meta = getmetatable(obj)
    rawset(obj, '__delegated', _meta)
    setmetatable(obj, {__index = __lua_delegate_func})
end

