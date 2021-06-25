--[[
    encrypt
]] local bit = require "bit"

--[[
    Add integers, wrapping at 2^32. This uses 16-bit operations internally
    to work around bugs in some JS interpreters.
--]]
local function safeAdd(x, y)
    if x == nil then
        x = 0
    end
    if y == nil then
        y = 0
    end
    local lsw = bit.band(x, 0xffff) + bit.band(y, 0xffff)
    local msw = bit.arshift(x, 16) + bit.arshift(y, 16) + bit.arshift(lsw, 16)
    return bit.bor(bit.lshift(msw, 16), bit.band(lsw, 0xffff))
end

--[[
    Bitwise rotate a 32-bit number to the left.
--]]
local function bitRotateLeft(num, cnt)
    return bit.bor(bit.lshift(num, cnt), bit.rshift(num, (32 - cnt)))
end

--[[
    These local functions implement the four basic operations the algorithm uses.
--]]
local function md5cmn(q, a, b, x, s, t)
    return safeAdd(bitRotateLeft(safeAdd(safeAdd(a, q), safeAdd(x, t)), s), b)
end
local function md5ff(a, b, c, d, x, s, t)
    return md5cmn(bit.bor(bit.band(b, c), bit.band(bit.bnot(b), d)), a, b, x, s, t)
end
local function md5gg(a, b, c, d, x, s, t)
    return md5cmn(bit.bor(bit.band(b, d), bit.band(c, bit.bnot(d))), a, b, x, s, t)
end
local function md5hh(a, b, c, d, x, s, t)
    return md5cmn(bit.bxor(b, c, d), a, b, x, s, t)
end
local function md5ii(a, b, c, d, x, s, t)
    return md5cmn(bit.bxor(c, bit.bor(b, bit.bnot(d))), a, b, x, s, t)
end

--[[
    Calculate the MD5 of an array of little-endian words, and a bit length.
--]]
local function binlMD5(x, len)
    -- append padding
    x[1 + bit.arshift(len, 5)] = bit.bor(x[1 + bit.arshift(len, 5)], bit.lshift(0x80, (len % 32)))
    x[1 + bit.lshift(bit.rshift(len + 64, 9), 4) + 14] = len

    local i
    local olda
    local oldb
    local oldc
    local oldd
    local a = 1732584193
    local b = -271733879
    local c = -1732584194
    local d = 271733878

    for i = 1, #x, 16 do
        olda = a
        oldb = b
        oldc = c
        oldd = d

        a = md5ff(a, b, c, d, x[i], 7, -680876936)
        d = md5ff(d, a, b, c, x[i + 1], 12, -389564586)
        c = md5ff(c, d, a, b, x[i + 2], 17, 606105819)
        b = md5ff(b, c, d, a, x[i + 3], 22, -1044525330)
        a = md5ff(a, b, c, d, x[i + 4], 7, -176418897)
        d = md5ff(d, a, b, c, x[i + 5], 12, 1200080426)
        c = md5ff(c, d, a, b, x[i + 6], 17, -1473231341)
        b = md5ff(b, c, d, a, x[i + 7], 22, -45705983)
        a = md5ff(a, b, c, d, x[i + 8], 7, 1770035416)
        d = md5ff(d, a, b, c, x[i + 9], 12, -1958414417)
        c = md5ff(c, d, a, b, x[i + 10], 17, -42063)
        b = md5ff(b, c, d, a, x[i + 11], 22, -1990404162)
        a = md5ff(a, b, c, d, x[i + 12], 7, 1804603682)
        d = md5ff(d, a, b, c, x[i + 13], 12, -40341101)
        c = md5ff(c, d, a, b, x[i + 14], 17, -1502002290)
        b = md5ff(b, c, d, a, x[i + 15], 22, 1236535329)

        a = md5gg(a, b, c, d, x[i + 1], 5, -165796510)
        d = md5gg(d, a, b, c, x[i + 6], 9, -1069501632)
        c = md5gg(c, d, a, b, x[i + 11], 14, 643717713)
        b = md5gg(b, c, d, a, x[i], 20, -373897302)
        a = md5gg(a, b, c, d, x[i + 5], 5, -701558691)
        d = md5gg(d, a, b, c, x[i + 10], 9, 38016083)
        c = md5gg(c, d, a, b, x[i + 15], 14, -660478335)
        b = md5gg(b, c, d, a, x[i + 4], 20, -405537848)
        a = md5gg(a, b, c, d, x[i + 9], 5, 568446438)
        d = md5gg(d, a, b, c, x[i + 14], 9, -1019803690)
        c = md5gg(c, d, a, b, x[i + 3], 14, -187363961)
        b = md5gg(b, c, d, a, x[i + 8], 20, 1163531501)
        a = md5gg(a, b, c, d, x[i + 13], 5, -1444681467)
        d = md5gg(d, a, b, c, x[i + 2], 9, -51403784)
        c = md5gg(c, d, a, b, x[i + 7], 14, 1735328473)
        b = md5gg(b, c, d, a, x[i + 12], 20, -1926607734)

        a = md5hh(a, b, c, d, x[i + 5], 4, -378558)
        d = md5hh(d, a, b, c, x[i + 8], 11, -2022574463)
        c = md5hh(c, d, a, b, x[i + 11], 16, 1839030562)
        b = md5hh(b, c, d, a, x[i + 14], 23, -35309556)
        a = md5hh(a, b, c, d, x[i + 1], 4, -1530992060)
        d = md5hh(d, a, b, c, x[i + 4], 11, 1272893353)
        c = md5hh(c, d, a, b, x[i + 7], 16, -155497632)
        b = md5hh(b, c, d, a, x[i + 10], 23, -1094730640)
        a = md5hh(a, b, c, d, x[i + 13], 4, 681279174)
        d = md5hh(d, a, b, c, x[i], 11, -358537222)
        c = md5hh(c, d, a, b, x[i + 3], 16, -722521979)
        b = md5hh(b, c, d, a, x[i + 6], 23, 76029189)
        a = md5hh(a, b, c, d, x[i + 9], 4, -640364487)
        d = md5hh(d, a, b, c, x[i + 12], 11, -421815835)
        c = md5hh(c, d, a, b, x[i + 15], 16, 530742520)
        b = md5hh(b, c, d, a, x[i + 2], 23, -995338651)

        a = md5ii(a, b, c, d, x[i], 6, -198630844)
        d = md5ii(d, a, b, c, x[i + 7], 10, 1126891415)
        c = md5ii(c, d, a, b, x[i + 14], 15, -1416354905)
        b = md5ii(b, c, d, a, x[i + 5], 21, -57434055)
        a = md5ii(a, b, c, d, x[i + 12], 6, 1700485571)
        d = md5ii(d, a, b, c, x[i + 3], 10, -1894986606)
        c = md5ii(c, d, a, b, x[i + 10], 15, -1051523)
        b = md5ii(b, c, d, a, x[i + 1], 21, -2054922799)
        a = md5ii(a, b, c, d, x[i + 8], 6, 1873313359)
        d = md5ii(d, a, b, c, x[i + 15], 10, -30611744)
        c = md5ii(c, d, a, b, x[i + 6], 15, -1560198380)
        b = md5ii(b, c, d, a, x[i + 13], 21, 1309151649)
        a = md5ii(a, b, c, d, x[i + 4], 6, -145523070)
        d = md5ii(d, a, b, c, x[i + 11], 10, -1120210379)
        c = md5ii(c, d, a, b, x[i + 2], 15, 718787259)
        b = md5ii(b, c, d, a, x[i + 9], 21, -343485551)

        a = safeAdd(a, olda)
        b = safeAdd(b, oldb)
        c = safeAdd(c, oldc)
        d = safeAdd(d, oldd)
    end
    return {a, b, c, d}
end

--[[
     Convert an array of little-endian words to a string
--]]
local function binl2rstr(input)
    local i
    local output = {}
    local length32 = #input * 32
    for i = 0, length32 - 1, 8 do
        table.insert(output, string.char(bit.band(bit.rshift(input[1 + bit.arshift(i, 5)], i % 32), 0xff)))
    end
    return table.concat(output, '')
end

--[[
     Convert a raw string to an array of little-endian words
--]]
local function rstr2binl(input)
    local output = {}
    for i = 1, bit.arshift(string.len(input), 2) do
        output[i] = 0
    end
    local length8 = string.len(input) * 8
    for i = 0, length8 - 1, 8 do
        local p = 1 + bit.arshift(i, 5);
        if output[p] == nil then
            output[p] = 0
        end
        output[p] = bit.bor(output[p], bit.lshift(bit.band(input:byte((i / 8) + 1), 0xff), (i % 32)))
    end
    return output
end

local function rstrMD5(s)
    return binl2rstr(binlMD5(rstr2binl(s), string.len(s) * 8))
end

local function charAt(str, n)
    return string.sub(str, n, n)
end

local function rstr2hex(input)
    local hexTab = '0123456789abcdef'
    local output = {}
    for i = 1, string.len(input) do
        local x = input:byte(i)
        table.insert(output, charAt(hexTab, 1 + bit.band(bit.rshift(x, 4), 0x0f)))
        table.insert(output, charAt(hexTab, 1 + bit.band(x, 0x0f)))
    end
    return table.concat(output, '')
end

local function md5(str)
    return rstr2hex(rstrMD5(str))
end

return {
    md5 = md5
}
