--[[
    number
]]

number = number or {}

function number.is_odd(v)
    return v % 2 ~= 0
end

function number.is_even()
    return not number.is_odd(v)
end

function number.is_int(v)
    return math.floor(v) == v
end

function number.is_float(v)
    return not number.is_int(v)
end
