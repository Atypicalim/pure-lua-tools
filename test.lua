--[[
    test
]]

local f = debug.getinfo(function() end)['short_src']
local d = string.gsub(f, "%a+%.%a+", "")
package.path = package.path .. ";" .. d .. "/?.lua;"

xpcall(require, function() end, "pure-lua-tools.initialize")
if not class then
    print('[PURE_LUA_TOOLS] downloading ...')
    os.execute('git clone git@github.com:kompasim/pure-lua-tools.git')
    xpcall(require, function() end, "pure-lua-tools.initialize")
    assert(class ~= nil, '[PURE_LUA_TOOLS] download failed!')
    print('[PURE_LUA_TOOLS] download succeed!')
end
