--[[
    plist
]]

plist = plist or {}

local plist_indent = 2
local plist_prefix = string.rep(" ", plist_indent)
local function plist_encode(value, indent)
    local prefix1 = string.rep(plist_prefix, indent + 1)
    local prefix2 = string.rep(plist_prefix, indent)
    if is_string(value) then
        return prefix2 .. "<string>" .. value .. "</string>"
    elseif is_number(value) then
        return prefix2 .. "<real>" .. tostring(value) .. "</real>"
    elseif is_boolean(value) then
        return prefix2 .. (value and "<true/>" or "<false/>")
    elseif is_array(value) then
        local arr = {}
        for i, v in ipairs(value) do
            table.insert(arr, plist_encode(v, indent + 1))
        end
        local itm = table.concat(arr, '\n')
        if string.valid(itm) then
            itm = "\n" .. itm .. "\n" .. prefix2
        end
        return prefix2 .. "<array>" .. itm .. "</array>"
    elseif is_table(value) then
        local dic = {}
        for k, v in pairs(value) do
            table.insert(dic, prefix1 .. "<key>" .. tostring(k) .. "</key>")
            table.insert(dic, plist_encode(v, indent + 1))
        end
        return prefix2 .. "<dict>\n" .. table.concat(dic, '\n') .. "\n" .. prefix2 .. "</dict>"
    else
        error("unsupported value for plist: " .. tostring(value))
    end
end

function plist.encode(t)
    assert(is_table(t))
    local d = {}
    table.insert(d, '<?xml version="1.0" encoding="UTF-8"?>')
    table.insert(d, '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">')
    table.insert(d, '<plist version="1.0">')
    table.insert(d, plist_encode(t, 0))
    table.insert(d, '</plist>')
    return table.concat(d, '\n')
end

function plist.decode(text)
    local stack = {}
    local root = {}
    local curr = nil
    local key = nil
    for tag, value in string.gmatch(text, "<(/?%w+/?)>([^<]*)") do
        if tag == "dict" then
            if not curr then
                assert(key == nil)
                curr = root
            else
                local k = key or #curr + 1
                curr[k] = {}
                curr = curr[k]
            end
            table.insert(stack, curr)
        elseif tag == "/dict" then
            table.remove(stack)
            curr = stack[#stack]
            key = nil
        elseif tag == "array" then
            local k = key or #curr + 1
            curr[k] = {}
            curr = curr[k]
            table.insert(stack, curr)
            key = nil
        elseif tag == "/array" then
            table.remove(stack)
            curr = stack[#stack]
            key = nil
        elseif tag == "key" then
            key = value
        elseif tag == "string" then
            local k = key or #curr + 1
            curr[k] = value
        elseif tag == "real" then
            local k = key or #curr + 1
            curr[k] = tonumber(value)
        elseif tag == "true/" then
            local k = key or #curr + 1
            curr[k] = true
        elseif tag == "false/" then
            local k = key or #curr + 1
            curr[k] = false
        end
    end
  
    return root
end
