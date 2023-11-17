--[[
    test
]]

local file = debug.getinfo(function() end)['short_src']
local folder = string.gsub(file, "%a+%.%a+", "")
package.path = package.path .. ";" .. folder .. "/?.lua;"

local folder = "./files/"
local orders = {
    "lua",
    "number",
    "math",
    "string",
    "table",
    "json",
    "yaml",
    "plist",
    "class",
    "Path",
    "files",
    "bit",
    "encryption",
    "time",
    "timer",
    "http",
    "package",
    "tools",
    "console",
    "Point",
    "Object",
    "Events",
    "Storage",
    "Log",
    "Graphic",
    "dialog",
    "canvas",
    "bmp",
    "colors",
    --
    "libs/log30",
    "libs/deflate",
    "libs/stream",
    "libs/qrcode",
    "libs/png_decode",
    "libs/png_encode",
    'library',
}

for i,v in ipairs(orders) do
    require(folder .. v)
end

local function build()
    local target = "./tools.lua"
    local content = string.format("\n-- tools:[%s]\n", os.date("%Y-%m-%d_%H:%M:%S", os.time()))
    print('pure-lua-tools:')
    print('building:')

    for i,name in ipairs(orders) do
        local path = string.format("%s%s.lua", folder, name)
        assert(files.is_file(path), 'file not found:' .. name)
        --
        print('including:' .. path)
        content = content .. string.format("\n-- file:[%s]", path) .. "\n\n"
        local code = ""
        local skip = false
        files.read(path):explode("\n"):foreach(function(k, v)
            local text = string.trim(v)
            if #text == 0 then
                return
            elseif string.match(text, "^%s*%-%-%[%[.*") then
                skip = true
                return
            elseif skip and string.match(text, ".*%]%]%s*$") then
                skip = false
                return
            elseif skip then
                return
            elseif string.match(text, "^%s*%-%-.*") then
                return
            end
            code =  code .. v .. "\n"
        end)
        content = content .. code
    end
    print('writing:' .. target)
    files.write(target, content)
    print('finished!')
end
-- build()
