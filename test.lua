--[[
    test
]]

local f = debug.getinfo(function() end)['short_src']
local d = string.gsub(f, "%a+%.%a+", "")
package.path = package.path .. ";" .. d .. "/?.lua;"

local MY_WORK_DIR = "./" -- os.getenv("HOME")
assert(MY_WORK_DIR ~= nil, "[PURE_LUA_TOOLS] please set [HOMVE] env variable !")
package.path = package.path .. ";" .. MY_WORK_DIR .. "/.pure-lua-tools/?.lua"
xpcall(require, function() end,"initialize")
if not class then
    print('[PURE_LUA_TOOLS] downloading ...')
    os.execute("git clone git@github.com:kompasim/pure-lua-tools.git " .. MY_WORK_DIR .. "/.pure-lua-tools")
    xpcall(require, function() end, "initialize")
    assert(class ~= nil, "[PURE_LUA_TOOLS] download failed!")
    print('[PURE_LUA_TOOLS] download succeed!')
end
