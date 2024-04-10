--[[
    Path
]]

assert(Path == nil)
Path = class("Path")

function Path:__init__(value)
    self._stack = table.new()
    if value then
        self:set(value)
    end
end

function Path:_parse(value)
    if value:starts("~") then
        value = files.home() .. "/" .. value:sub(2, -1)
    elseif value == "." or value:starts("./") then
        value = files.cwd() .. "/" .. value:sub(2, -1)
    elseif value == ".." or value:starts("../") then
        value = files.cwd() .. "/../" .. value:sub(3, -1)
    elseif value:starts("/") then
        value = files.root() .. "/" .. value:sub(2, -1)
    end
    return value
end

function Path:_explode(value)
    return files.unixify(value):trim("/"):explode("/")
end

function Path:_implode(stack)
    return table.implode(stack, "/")
end

function Path:_validate()
    local size = #self._stack
    local count = 0
    for i=size,1,-1 do
        local item = self._stack[i]
        if i == 1 then
            break
        elseif item == "" then
            table.remove(self._stack, i)
        elseif item == "." then
            table.remove(self._stack, i)
        elseif item == ".." then
            count = count + 1
            table.remove(self._stack, i)
        elseif count > 0 then
            count = count - 1
            table.remove(self._stack, i)
        end
        assert(count >= 0, 'invalid path validate')
    end
end

function Path:cd(value)
    value = files.unixify(value)
    if not string.valid(value) then
        return self
    end
    if #self._stack == 0 or value:starts("~") or value:starts("/") then
        value = self:_parse(value)
        self._stack = self:_explode(value)
    else
        self:push(value)
    end
    self:_validate()
    return self
end

function Path:set(value)
    value = files.unixify(value)
    assert(string.valid(value), 'invalid path value')
    value = self:_parse(value)
    self._stack = self:_explode(value)
    self:_validate()
    return self
end

function Path:get()
    return self:_implode(self._stack)
end

function Path:push(...)
    local values = {...}
    for i,value in ipairs(values) do
        value = files.unixify(value)
        assert(string.valid(value), 'invalid path value')
        local stack = self:_explode(value)
        self._stack:append(stack)
    end
    self:_validate()
    return self
end

function Path:pop(count)
    count = count or 1
    for i=1,count do
        table.remove(self._stack, #self._stack)
    end
    self:_validate()
    return self
end

function Path:equal(other)
    assert(type(other) == "table")
    return self:get() == other:get()
end

function Path:relative(other)
    if self._stack[1] ~= other._stack[1] then
        return
    end
    local max = math.max(#self._stack, #other._stack)
    local diff = "./"
    for i=1,max do
        local v1 = self._stack[i]
        local v2 = other._stack[i]
        if v1 ~= nil and v2 ~= nil then
            if v1 ~= v2 then
                diff = diff .. "../" .. v2
            end
        elseif v1 and not v2 then
            diff = ".." .. "/" .. diff
        elseif not v1 and v2 then
            diff =  diff .. "/" .. v2
        end
    end
    print(diff)
    return Path(diff)
end

function Path:clone()
    local oldPath = self:get()
    local objPath = Path(oldPath)
    local newPath = objPath:get()
    assert(oldPath == newPath, 'buggy path operation')
    return objPath
end

function Path:root()
    return self:pop(#self._stack - 1)
end

function Path:size()
    return #self._stack
end

function Path:isRoot()
    return #self._stack == 1
end

function Path:isFile()
    local last = self._stack[#self._stack]
    return last ~= nil and string.match(last, '%.%w+$') ~= nil
end

function Path:getDir()
    local stack = table.copy(self._stack)
    if self:isFile() then
        table.remove(stack, #stack)
    end
    return self:_implode(stack)
end

function Path:getNameWithExt()
    if self:isFile() then
        local nameWithExe = self._stack[#self._stack]
        local arr = files.unixify(nameWithExe):trim():explode("%.")
        local nam = arr[1]
        local ext = arr[2]
        return nameWithExe, nam, ext
    end
end

