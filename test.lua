--[[
    test
]]

local f = debug.getinfo(function() end)['short_src']
local d = string.gsub(f, "%a+%.%a+", "")
package.path = package.path .. ";" .. d .. "/?.lua;"

require("initialize")
