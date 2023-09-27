--[[
    class
]]

local classMap = {}

-- create object
local function new(Class, ...)
    -- asset values
    assert(is_class(Class), "invalid class table")
    -- object table
    local object = {
        __type__ = "object",
        __name__ = Class.__name__,
        __class__ = Class
    }
    -- object meta
    local objectMeta = {
        __index = Class,
        __tostring = function(object)
            return string.format("<object:%s %s in:%s>", object.__name__, lua_get_pointer(object), object.__path__)
        end
    }
    local object = setmetatable(object, objectMeta)
    -- init object
    assert(object.__init__, string.format("not constructor for class: %s", object.__class__.__name__))
    object.__init__(object, ...)
    -- return object
    return object
end

-- create class
assert(class == nil)
function class(name, Base)
    -- assert values
    assert(is_string(name), "invalid class name")
    assert(is_nil(Base) or is_class(Base), "invalid class base")
    assert(is_nil(classMap[name]), "multiple class name")
    -- class table
    local Class = {
        __type__ = "class",
        __name__ = name,
        __super__ = Base,
        __path__ = lua_script_path(1),
    }
    -- class meta
    local ClassMeta = {
        __tostring = function(Class)
            return string.format("<Class:%s %s in:%s>", Class.__name__, lua_get_pointer(Class), Class.__path__)
        end,
        __call = function(Class, ...)
            return new(Class, ...)
        end
    }
    if Class.__super__ then
        ClassMeta.__index = Class.__super__
    end
    setmetatable(Class, ClassMeta)
    -- return class
    return Class, Base
end
