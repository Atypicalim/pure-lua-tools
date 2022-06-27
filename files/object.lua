--[[
    Object
]]

local Object = {}
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

return Object
