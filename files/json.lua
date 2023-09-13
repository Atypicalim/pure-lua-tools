--[[
    json
]]

json = json or {}

function json.encodable(o)
    local t = type(o)
    return (t == 'string' or t == 'boolean' or t == 'number' or t == 'nil' or t == 'table') or (t == 'function' and o == null)
end

function json._encodeString(s)
    s = string.gsub(s, '\\', '\\\\')
    s = string.gsub(s, '"', '\\"')
    s = string.gsub(s, "'", "\\'")
    s = string.gsub(s, '\n', '\\n')
    s = string.gsub(s, '\t', '\\t')
    return s
end

function json._encode(v)
    if is_nil(v) or v == null then return "null" end
    if is_boolean(v) or is_number(v) then return tostring(v) end
    if is_string(v) then return '"' .. json._encodeString(v) .. '"' end
    local rval = {}
    if table.is_array(v) then
        for i = 1, #v do
            table.insert(rval, json._encode(v[i]))
        end
        return '[' .. table.concat(rval, ',') .. ']'
    end
    if is_table(v) then
        for i, j in pairs(v) do
            if json.encodable(i) and json.encodable(j) then
                table.insert(rval, '"' .. json._encodeString(i) .. '":' .. json._encode(j))
            end
        end
        return '{' .. table.concat(rval, ',') .. '}'
    end
    assert(false, 'type not supported:' .. type(v))
end

function json._decode_scanWhitespace(s, startPos)
    local stringLen = string.len(s)
    while (string.find(" \n\r\t", string.sub(s, startPos, startPos), 1, true) and startPos <= stringLen) do
        startPos = startPos + 1
    end
    return startPos
end

function json._decode_scanObject(s, startPos)
    local object = {}
    local stringLen = string.len(s)
    local key, value
    startPos = startPos + 1
    repeat
        startPos = json._decode_scanWhitespace(s, startPos)
        assert(startPos <= stringLen, 'JSON string ended unexpectedly while scanning object.')
        local curChar = string.sub(s, startPos, startPos)
        if (curChar == '}') then return object, startPos + 1 end
        if (curChar == ',') then startPos = json._decode_scanWhitespace(s, startPos + 1) end
        assert(startPos <= stringLen, 'JSON string ended unexpectedly scanning object.')
        -- Scan the key
        key, startPos = json._decode(s, startPos)
        assert(startPos <= stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
        startPos = json._decode_scanWhitespace(s, startPos)
        assert(startPos <= stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
        assert(string.sub(s, startPos, startPos) == ':', 'JSON string ended unexpectedly searching for assignment at ' .. startPos)
        startPos = json._decode_scanWhitespace(s, startPos + 1)
        assert(startPos <= stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
        value, startPos = json._decode(s, startPos)
        object[key] = value
    until false
end

function json._decode_scanArray(s, startPos)
    local array = {}
    local stringLen = string.len(s)
    startPos = startPos + 1
    repeat
        startPos = json._decode_scanWhitespace(s, startPos)
        assert(startPos <= stringLen, 'JSON String ended unexpectedly scanning array.')
        local curChar = string.sub(s, startPos, startPos)
        if (curChar == ']') then return array, startPos + 1 end
        if (curChar == ',') then startPos = json._decode_scanWhitespace(s, startPos + 1) end
        assert(startPos <= stringLen, 'JSON String ended unexpectedly scanning array.')
        object, startPos = json._decode(s, startPos)
        table.insert(array, object)
    until false
end

function json._decode_scanNumber(s, startPos)
    local endPos = startPos + 1
    local stringLen = string.len(s)
    while (string.find("+-0123456789.e", string.sub(s, endPos, endPos), 1, true) and endPos <= stringLen) do
        endPos = endPos + 1
    end
    local stringValue = string.sub(s, startPos, endPos - 1)
    local numberValue = tonumber(stringValue)
    assert(numberValue ~= nil, 'invalid number [ ' .. stringValue .. '] at:' .. startPos .. ' : ' .. endPos)
    return stringEval(), endPos
end

function json._decode_scanString(s, startPos)
    local startChar = string.sub(s, startPos, startPos)
    local escaped = false
    local endPos = startPos + 1
    local bEnded = false
    local stringLen = string.len(s)
    repeat
        local curChar = string.sub(s, endPos, endPos)
        if not escaped then
            if curChar == [[\]] then
                escaped = true
            else
                bEnded = curChar == startChar
            end
        else
            escaped = false
        end
        endPos = endPos + 1
        assert(endPos <= stringLen + 1, 'JSON string ended unexpectedly scanning string.')
    until bEnded
    local stringValue = 'return ' .. string.sub(s, startPos, endPos - 1)
    local stringEval = loadstring(stringValue)
    assert(stringEval, 'invalid string [ ' .. stringValue .. '] at ' .. startPos .. ' : ' .. endPos)
    return stringEval(), endPos
end

function json._decode_scanComment(s, startPos)
    local endPos = string.find(s, '*/', startPos + 2)
    assert(endPos ~= nil, "invalid comment tag!")
    return json._decode(s, endPos + 2)
end

function json._decode_scanConstants(s, startPos)
    local constValues = {true, false, nil}
    local constNames = {"true", "false", "null"}
    for _, k in pairs(constNames) do
        if string.sub(s, startPos, startPos + string.len(k) - 1) == k then
            return constValues[k], startPos + string.len(k)
        end
    end
    assert(false, 'invalid json value at:' .. startPos)
end

function json._decode(s, startPos)
    startPos = startPos and startPos or 1
    startPos = json._decode_scanWhitespace(s, startPos)
    assert(startPos <= string.len(s), 'Unterminated JSON encoded object found at position in [' .. s .. ']')
    local curChar = string.sub(s, startPos, startPos)
    --
    if string.sub(s, startPos, startPos + 1) == '/*' then return json._decode_scanComment(s, startPos) end
    if curChar == '{' then return json._decode_scanObject(s, startPos) end
    if curChar == '[' then return json._decode_scanArray(s, startPos) end
    if curChar == [["]] or curChar == [[']] then return json._decode_scanString(s, startPos) end
    if string.find("+-0123456789.e", curChar, 1, true) then return json._decode_scanNumber(s, startPos) end
    --
    return json._decode_scanConstants(s, startPos)
end

function json.encode(v)
    local isOk, r = xpcall(function() return json._encode(v) end, function(err) return err end)
    if isOk then return r, nil end
    return nil, r
end

function json.decode(s)
    local isOk, r = xpcall(function() return json._decode(s) end, function(err) return err end)
    if isOk then return r, nil end
    return nil, r
end
