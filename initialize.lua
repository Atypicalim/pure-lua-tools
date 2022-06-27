--[[
    lua tools box
]]

local file = debug.getinfo(function() end)['short_src']
local folder = string.gsub(file, "%a+%.%a+", "")
package.path = package.path .. ";" .. folder .. "/?.lua;"

require("files/lua")
number = require("files/number")
require("files/string")
require("files/table")
class = require("files/class")
Object = require("files/object")
json = require("files/json")
files = require("files/files")
Events = require("files/Events")
timer = require("files/timer")
bit = require("files/bit")
encryption = require("files/encryption")
http = require("files/http")
tools = require("files/tools")
