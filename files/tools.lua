--[[
    tools
]]

local tools = {}

function tools.is_windows()
    return string.find(os.getenv("HOME") or "", '/c/Users') ~= nil or string.find(os.getenv("path") or "", 'C:\\Users')
end

function tools.is_linux()
    return not tools.is_windows() and string.find(os.getenv("HOME") or "", '/home/') ~= nil
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
