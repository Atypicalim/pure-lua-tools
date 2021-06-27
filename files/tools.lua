--[[
    tools
]]

local tools = {}

function tools.is_windows()
    return package.config:sub(1,1) == "\\"
end

function tools.is_linux()
    return package.config:sub(1,1) == "/"
end

function tools.execute(cmd)
    local path = 'lua.execute.log'
    files.delete(path)
    local command = string.format('%s >> ./%s 2>&1', cmd, path)
    local isOK = os.execute(command) == true
    local output = files.read(path)
    files.delete(path)
    return isOK, output
end

return tools
