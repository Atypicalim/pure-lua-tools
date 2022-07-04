--[[
    package
]]

local recursiveMap = {}
local modulesMap = {}

local function load(path, env)
    local f, err = loadfile(path)
    assert(f ~= nil or err == nil, err)
    if env then setfenv(f, env) end
    local r, msg = pcall(f)
    assert(r == true, msg)
    modulesMap[path] = msg ~= nil and msg or true
    return msg
end

local function search(path)
    if files.is_file(files.csd() .. path) then
        return files.csd() .. path
    elseif files.is_file(files.cwd() .. path) then
        return files.cwd() .. path
    elseif files.is_file(path) then
        return path
    end
end

function package.doload(path, env)
    path = search(tostring(path))
    if path and modulesMap[path] then
        return modulesMap[path] ~= true and modulesMap[path] or nil
    end
    assert(path ~= nil)
    assert(recursiveMap[path] == nil)
    recursiveMap[path] = true
    local r = load(path, env)
    recursiveMap[path] = nil
    return r
end

function package.unload(path)
    path = search(tostring(path))
    if path and modulesMap[path] then modulesMap[path] = nil end
end

function package.isloaded(path)
    path = search(tostring(path))
    return path ~= nil and modulesMap[path] ~= nil
end
