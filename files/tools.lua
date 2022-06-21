--[[
    tools
]]

local tools = {}

local isWindows = nil
function tools.is_windows()
    if is_boolen(isWindows) then return isWindows end
    isWindows = string.find(os.getenv("HOME") or "", '/c/Users') ~= nil or string.find(os.getenv("path") or "", 'C:\\Users') ~= nil
    return isWindows 
end

local isLinux = nil
function tools.is_linux()
    if is_boolen(isLinux) then return isLinux end
    isLinux = not tools.is_windows() and string.find(os.getenv("HOME") or "", '/home/') ~= nil
    return isLinux
end

function tools.execute(cmd)
    local path = './.lua.execute.log'
    files.delete(path)
    local command = string.format('%s >> ./%s 2>&1', cmd, path)
    local result, _ = os.execute(command)
    local isOk = result == true or result == 0
    local output = files.read(path)
    files.delete(path)
    return isOk, output
end

function tools.get_timezone()
    local now = os.time()
    local utc = os.time(os.date("!*t", now))
    local diff = os.difftime(now, utc)
    local zone = math.floor(diff / 60 / 60)
    return zone
end

function tools.get_milliseconds()
    local clock = os.clock()
    local _, milli = math.modf(clock)
    return math.floor(os.time() * 1000 + milli * 1000)
end

return tools
