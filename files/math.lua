--[[
    math
]]

function math.radian(angle)
    return angle * math.pi / 180
end

function math.angle(radian)
    return radian * 180 / math.pi
end

function math.round(value)
    return math.floor(value  + 0.5)
end
