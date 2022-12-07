--[[
    Path
]]

assert(Log == nil)
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
                --
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
