--[[
    Point
]]

assert(Point == nil)
Point = class("Point")

function Point:__init__(x, y)
    self.x = x
    self.y = y
end

-- math.pi / 4 -> {x = 0.7, y = 0.7}
function Point.from_radian(radian)
    return Point(math.cos(radian), math.sin(radian))
end

-- 0° -> {x = 1, y = 0}
function Point.from_angle(angle)
    local radian = angle * (math.pi / 180)
    return Point.from_radian(radian)
end

function Point:clone()
    return Point(self.x, self.y)
end

function Point:add(other)
    return Point(self.x + other.x, self.y + other.y)
end

function Point:sub(other)
    return Point(self.x - other.x, self.y - other.y)
end

function Point:mul(pt, factor)
    return Point(self.x * factor, self.y * factor)
end

function Point:div(pt, factor)
    return Point(self.x / factor, self.y / factor)
end

function Point:middle()
    return Point(self.x / 2, self.y / 2)
end

function Point:length()
    return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

function Point:distance(other)
    return self:sub(other):length()
end

function Point:normalize()
    local length = self:length()
    local x, y = 1, 0
    if length > 0 then
        x, y = self.x / length, self.y / length
    end
    return Point(x, y)
end

function Point:cross(other)
    return self.x * other.y - self.y * other.x
end

function Point:dot(other)
    return self.x * other.x + self.y * other.y
end

function Point:radian()
    return math.atan2(self.x, self.y)
end

function Point:angleWithOther(other)
    local normal1 = other:normalize()
    local normal2 = self:normalize()
    local angle = math.atan2(normal1:cross(normal2), normal1:dot(normal2))
    if math.abs(angle) < 1.192092896e-7 then
        return 0.0
    end
    return angle * 180 / math.pi;
end

function Point:angleOfSelf(base)
    if not base then
        base = Point(0, 0)
    end
    local dx = self.x - base.x
    local dy = self.y - base.y
    local angle = math.atan2(dy, dx) * 180 / math.pi
    return angle
end

function Point:pProject(other)
    local oDot = other:dot(other)
    return Point(other.x * (self:dot(other) / oDot) , pt2.y * (self:dot(other) / oDot))
end

function Point:pRotate(other)
    return Point(self.x * other.x - self.y * other.y, self.x * other.y + self.y * other.x)
end

function Point:rotate(angle, base)
    if not base then
        base = Point(0, 0)
    end
    local vector = self:sub(base):pRotate(Point.from_angle(angle))
    local normal = vector:normalize()
    local length = self:length()
    local temp = Point(normal.x * length, normal.y * length)
    local point = base:add(vector)
    return point
end
