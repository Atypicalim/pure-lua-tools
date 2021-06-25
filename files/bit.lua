--[[
    bit
]]

local bit = {}
bit.WEIGHTS = {}
bit.DIGIT = 32

for i = 1, bit.DIGIT do
    bit.WEIGHTS[i] = 2 ^ (32 - i)
end

function bit.table2number(tb)
    local negative = tb[1] == 1
    local nr = 0
    for i = 1, bit.DIGIT do
        local v = nil
        if negative then
            v = tb[i] == 1 and 0 or 1
        else
            v = tb[i]
        end
        if v == 1 then
            nr = nr + bit.WEIGHTS[i]
        end
    end
    if negative then
        nr = nr + 1
        nr = -nr
    end
    return nr
end

function bit.number2table(nm)
    nm = nm >= 0 and nm or (0xFFFFFFFF + nm + 1)
    local tb = {}
    for i = 1, bit.DIGIT do
        if nm >= bit.WEIGHTS[i] then
            tb[i] = 1
            nm = nm - bit.WEIGHTS[i]
        else
            tb[i] = 0
        end
    end
    return tb
end

-- logic
function bit.rshift(a, n)
    local tb = bit.number2table(a)
    n = math.max(0, math.min(bit.DIGIT, n))
    for i = bit.DIGIT, 1, -1 do
        tb[i] = tb[i - n] or 0
    end
    return bit.table2number(tb)
end

-- arithmetic
function bit.arshift(a, n)
    local tb = bit.number2table(a)
    n = math.max(0, math.min(bit.DIGIT, n))
    local fill = a < 0 and 1 or 0
    for i = bit.DIGIT, 1, -1 do
        tb[i] = tb[i - n] or fill
    end
    return bit.table2number(tb)
end

function bit.lshift(a, n)
    local tb = bit.number2table(a)
    n = math.max(0, math.min(bit.DIGIT, n))
    for i = 1, bit.DIGIT do
        tb[i] = tb[i + n] or 0
    end
    return bit.table2number(tb)
end

function bit.band(a, b)
    local tb1 = bit.number2table(a)
    local tb2 = bit.number2table(b)
    local r = {}
    for i = 1, bit.DIGIT do
        r[i] = (tb1[i] == 1 and tb2[i] == 1) and 1 or 0
    end
    return bit.table2number(r)
end

function bit.bor(a, b)
    local tb1 = bit.number2table(a)
    local tb2 = bit.number2table(b)
    local r = {}
    for i = 1, bit.DIGIT do
        r[i] = (tb1[i] == 1 or tb2[i] == 1) and 1 or 0
    end
    return bit.table2number(r)
end

function bit.bxor(a, b)
    local tb1 = bit.number2table(a)
    local tb2 = bit.number2table(b)
    local r = {}
    for i = 1, bit.DIGIT do
        r[i] = tb1[i] ~= tb2[i] and 1 or 0
    end
    return bit.table2number(r)
end

function bit.bnot(a)
    local tb = bit.number2table(a)
    local r = {}
    for i = 1, bit.DIGIT do
        r[i] = tb[i] == 1 and 0 or 1
    end
    return bit.table2number(r)
end

return bit
