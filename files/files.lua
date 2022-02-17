--[[
    file
]]

local files = {}

local delimiter = nil
function files.delimiter()
    if delimiter then return delimiter end
    delimiter = string.find(os.tmpname(""), "\\") and "\\" or "/"
    return delimiter
end

-- current working directory
local cwd = nil
function files.cwd()
    if cwd then return cwd end
    local isOk, output, code = tools.execute("pwd")
    local s = output:trim() .. '/'
    cwd = s:slash()
    return cwd
end

-- current script directory
function files.csd()
    return files.get_folder(debug.getinfo(2).short_src)
end

function files.absolute(this)
    return files.cwd() .. this
end

function files.relative(this)
    return this:gsub(files.cwd(), '')
end

function files.write(path, content, mode)
    local f = io.open(path, mode or "w")
    if not f then return false end
    f:write(content)
    f:close()
    return true
end

function files.read(path, mode)
    local f = io.open(path, mode or "r")
    if not f then return end
    local content = f:read("*a")
    f:close()
    return content
end

function files.size(path)
    f = io.open(path, "rb")
    if not f then return 0 end
    local size = f:seek("end")
    f:close()
    return size
end

function files.delete(path)
    os.remove(path)
end

function files.is_file(path)
    local f = io.open(path, "rb")
    if f then f:close() end
    return f ~= nil
end

function files.print(path)
    print("[file:" .. path .. "]")
    print("[[[[[[[")
    local lines = files.is_file(path) and io.lines(path) or ipairs({})
    local num = 0
    for line in lines do
        num = num + 1
        print(" " .. tostring(num):right(7, "0") .. " " .. line)
    end
    print("]]]]]]]")
end

function files.files(from, to)
    local f1 = io.open(from, 'rb')
    local f2 = io.open(to, 'wb')
    if not f1 or not f2 then return end
    f2:write(f1:read('*a'))
    f1:close()
    f2:close()
    return true
end

function files.is_folder(path)
    local a, b, code = tools.execute("cd " .. path)
    return code == 0
end

function files.mk_folder(path)
    if files.is_folder(path) then return end
    local _, _, code = tools.execute(string.format([[mkdir -p "%s"]], path))
    return code == 0
end

function files.list(path)
    local r = table.new()
    if not files.is_folder(path) then return r end
    local t = io.popen('ls ' .. path):read("*all"):explode('\n')
    for i,v in ipairs(t) do
        if is_string(v) and #v > 0 then
            table.insert(r, v)
        end
    end
    return r
end

function files.get_folder(filePath)
    return string.gsub(filePath, "%a+%.%a+", "")
end

return files
