--[[
    tools
]]

local tools = {}

local isWindows = nil
function tools.is_windows()
    if is_boolen(isWindows) then return isWindows end
    isWindows = string.find(os.getenv("HOME") or "", '/c/Users') ~= nil or string.find(os.getenv("path") or "", 'C:\\Users')
    return isWindows
end

local isLinux = nil
function tools.is_linux()
    if is_boolen(isLinux) then return isLinux end
    isLinux = not tools.is_windows() and string.find(os.getenv("HOME") or "", '/home/') ~= nil
    return isLinux
end

function tools.execute(cmd)
    local path = 'lua.execute.log'
    files.delete(path)
    local command = string.format('%s >> ./%s 2>&1', cmd, path)
    local result, _, code = os.execute(command)
    local isOk = result == true
    local output = files.read(path)
    files.delete(path)
    return isOk, output, code
end

function tools.get_current_script_absolute_folder()
    local cwd = files.cwd()
    local info = debug.getinfo(2)
    local name = info.short_src
    local absolutePath = files.cwd() .. info.short_src
    local absoluteFolder = files.get_folder(absolutePath)
    return absoluteFolder
end

function tools.get_current_script_relative_folder()
    local cwd = files.cwd()
    local info = debug.getinfo(2)
    local name = info.short_src
    local relativePath = "./" .. info.short_src
    local relativeFolder = files.get_folder(relativePath)
    return relativeFolder
end

return tools
