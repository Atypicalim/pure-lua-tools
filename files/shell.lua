--[[
    shell
]]

shell = shell or {}

local smt = {}
setmetatable(shell, smt)

local function shell_execute(cmd, ...)
    for _, v in ipairs({...}) do
        cmd = cmd .. ' ' .. v
    end
    local isOk, out = tools.execute(cmd)
    return isOk, out
end

smt.__index = function(t, cmd)
	return function(...)
        return shell_execute(cmd, ...)
	end
end
