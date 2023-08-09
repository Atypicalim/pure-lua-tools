--[[
    Point
]]

assert(Point == nil)
Point = class("Point")

function Point:__init__(x, y)
    self.x = x
    self.y = y
end

function Point.from_radian(radian)
    return {x = math.cos(radian), y = math.sin(radian)}
end

function Point.from_angle(angle)
    local radian = angle * (math.pi / 180)
    return Point.from_radian(radian)
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
    return math.sqrt(self.x * self.x + self.y * self.y)
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

function Point:angle()
    return self:radian() * 180 / math.pi
end

function Point:angle_by(base)
    if base:length() == 0 then
        return self:to_angle()
    end
    local normalSelf = self:normalize()
    local normalBase = base:normalize()
    local cross = normalSelf:cross(normalBase)
    local dot = normalSelf:dot(normalBase)
    local atan = math.atan2(cross, dot)
    if math.abs(atan) < 1.192092896e-7 then
        return 0.0
    end
    return atan * 180 / math.pi
end

function Point:pProject(other)
    local oDot = other:dot(other)
    return Point(other.x * (self:dot(other) / oDot) , pt2.y * (self:dot(other) / oDot))
end

function Point:pRotate(other)
    return Point(self.x * other.x - self.y * other.y, self.x * other.y + self.y * other.x)
end

function Point:rotate_by(anchorPoint, angle)
    local sub = self:sub(anchorPoint)
    local base = Point.from_angle(angle)
    local vector = sub:pRotate(base)
    local point = anchorPoint:add(vector)
    return point
end
