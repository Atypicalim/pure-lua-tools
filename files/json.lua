--[[
    json
]]

local decode_scanArray
local decode_scanComment
local decode_scanConstant
local decode_scanNumber
local decode_scanObject
local decode_scanString
local decode_scanWhitespace

local function encodeString(s)
    s = string.gsub(s, '\\', '\\\\')
    s = string.gsub(s, '"', '\\"')
    s = string.gsub(s, "'", "\\'")
    s = string.gsub(s, '\n', '\\n')
    s = string.gsub(s, '\t', '\\t')
    return s
end

function null()
    return null -- so json.null() will also return null ; Simply set t = {first = json.null}
end

local function encodable(o)
    local t = type(o)
    return (t == 'string' or t == 'boolean' or t == 'number' or t == 'nil' or t == 'table') or
               (t == 'function' and o == null)
end

local function encode(v)
    --
    if v == nil then
        return "null"
    end
    --
    local vtype = type(v)
    --
    if vtype == 'string' then
        return '"' .. encodeString(v) .. '"' -- Need to handle encoding in string
    end
    -- Handle booleans
    if vtype == 'number' or vtype == 'boolean' then
        return tostring(v)
    end
    -- Handle tables
    if vtype == 'table' then
        local rval = {}
        -- Consider arrays separately
        local isArray = table.is_array(v)
        if isArray then
            for i = 1, #v do
                table.insert(rval, encode(v[i]))
            end
        else -- An object, not an array
            for i, j in pairs(v) do
                if encodable(i) and encodable(j) then
                    table.insert(rval, '"' .. encodeString(i) .. '":' .. encode(j))
                end
            end
        end
        if isArray then
            return '[' .. table.concat(rval, ',') .. ']'
        else
            return '{' .. table.concat(rval, ',') .. '}'
        end
    end
    -- Handle null values
    if vtype == 'function' and v == null then
        return 'null'
    end
    --
    assert(false, 'encode attempt to encode unsupported type ' .. vtype .. ':' .. tostring(v))
end

function decode(s, startPos)
    startPos = startPos and startPos or 1
    startPos = decode_scanWhitespace(s, startPos)
    assert(startPos <= string.len(s), 'Unterminated JSON encoded object found at position in [' .. s .. ']')
    local curChar = string.sub(s, startPos, startPos)
    -- Object
    if curChar == '{' then
        return decode_scanObject(s, startPos)
    end
    -- Array
    if curChar == '[' then
        return decode_scanArray(s, startPos)
    end
    -- Number
    if string.find("+-0123456789.e", curChar, 1, true) then
        return decode_scanNumber(s, startPos)
    end
    -- String
    if curChar == [["]] or curChar == [[']] then
        return decode_scanString(s, startPos)
    end
    if string.sub(s, startPos, startPos + 1) == '/*' then
        return decode(s, decode_scanComment(s, startPos))
    end
    -- Otherwise, it must be a constant
    return decode_scanConstant(s, startPos)
end

-----------------------------------------------------------------------------
-- Internal, PRIVATE functions.
-- Following a Python-like convention, I have prefixed all these 'PRIVATE'
-- functions with an underscore.
-----------------------------------------------------------------------------

--- Scans an array from JSON into a Lua object
-- startPos begins at the start of the array.
-- Returns the array and the next starting position
-- @param s The string being scanned.
-- @param startPos The starting position for the scan.
-- @return table, int The scanned array as a table, and the position of the next character to scan.
function decode_scanArray(s, startPos)
    local array = {} -- The return value
    local stringLen = string.len(s)
    assert(string.sub(s, startPos, startPos) == '[',
        'decode_scanArray called but array does not start at position ' .. startPos .. ' in string:\n' .. s)
    startPos = startPos + 1
    -- Infinite loop for array elements
    repeat
        startPos = decode_scanWhitespace(s, startPos)
        assert(startPos <= stringLen, 'JSON String ended unexpectedly scanning array.')
        local curChar = string.sub(s, startPos, startPos)
        if (curChar == ']') then
            return array, startPos + 1
        end
        if (curChar == ',') then
            startPos = decode_scanWhitespace(s, startPos + 1)
        end
        assert(startPos <= stringLen, 'JSON String ended unexpectedly scanning array.')
        object, startPos = decode(s, startPos)
        table.insert(array, object)
    until false
end

--- Scans a comment and discards the comment.
-- Returns the position of the next character following the comment.
-- @param string s The JSON string to scan.
-- @param int startPos The starting position of the comment
function decode_scanComment(s, startPos)
    assert(string.sub(s, startPos, startPos + 1) == '/*',
        "decode_scanComment called but comment does not start at position " .. startPos)
    local endPos = string.find(s, '*/', startPos + 2)
    assert(endPos ~= nil, "Unterminated comment in string at " .. startPos)
    return endPos + 2
end

--- Scans for given constants: true, false or null
-- Returns the appropriate Lua type, and the position of the next character to read.
-- @param s The string being scanned.
-- @param startPos The position in the string at which to start scanning.
-- @return object, int The object (true, false or nil) and the position at which the next character should be 
-- scanned.
function decode_scanConstant(s, startPos)
    local consts = {
        ["true"] = true,
        ["false"] = false,
        ["null"] = nil
    }
    local constNames = {"true", "false", "null"}

    for i, k in pairs(constNames) do
        -- print ("[" .. string.sub(s,startPos, startPos + string.len(k) -1) .."]", k)
        if string.sub(s, startPos, startPos + string.len(k) - 1) == k then
            return consts[k], startPos + string.len(k)
        end
    end
    assert(nil, 'Failed to scan constant from string ' .. s .. ' at starting position ' .. startPos)
end

--- Scans a number from the JSON encoded string.
-- (in fact, also is able to scan numeric +- eqns, which is not
-- in the JSON spec.)
-- Returns the number, and the position of the next character
-- after the number.
-- @param s The string being scanned.
-- @param startPos The position at which to start scanning.
-- @return number, int The extracted number and the position of the next character to scan.
function decode_scanNumber(s, startPos)
    local endPos = startPos + 1
    local stringLen = string.len(s)
    local acceptableChars = "+-0123456789.e"
    while (string.find(acceptableChars, string.sub(s, endPos, endPos), 1, true) and endPos <= stringLen) do
        endPos = endPos + 1
    end
    local stringValue = 'return ' .. string.sub(s, startPos, endPos - 1)
    local stringEval = loadstring(stringValue)
    assert(stringEval,
        'Failed to scan number [ ' .. stringValue .. '] in JSON string at position ' .. startPos .. ' : ' .. endPos)
    return stringEval(), endPos
end

--- Scans a JSON object into a Lua object.
-- startPos begins at the start of the object.
-- Returns the object and the next starting position.
-- @param s The string being scanned.
-- @param startPos The starting position of the scan.
-- @return table, int The scanned object as a table and the position of the next character to scan.
function decode_scanObject(s, startPos)
    local object = {}
    local stringLen = string.len(s)
    local key, value
    assert(string.sub(s, startPos, startPos) == '{',
        'decode_scanObject called but object does not start at position ' .. startPos .. ' in string:\n' .. s)
    startPos = startPos + 1
    repeat
        startPos = decode_scanWhitespace(s, startPos)
        assert(startPos <= stringLen, 'JSON string ended unexpectedly while scanning object.')
        local curChar = string.sub(s, startPos, startPos)
        if (curChar == '}') then
            return object, startPos + 1
        end
        if (curChar == ',') then
            startPos = decode_scanWhitespace(s, startPos + 1)
        end
        assert(startPos <= stringLen, 'JSON string ended unexpectedly scanning object.')
        -- Scan the key
        key, startPos = decode(s, startPos)
        assert(startPos <= stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
        startPos = decode_scanWhitespace(s, startPos)
        assert(startPos <= stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
        assert(string.sub(s, startPos, startPos) == ':', 'JSON object key-value assignment mal-formed at ' .. startPos)
        startPos = decode_scanWhitespace(s, startPos + 1)
        assert(startPos <= stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
        value, startPos = decode(s, startPos)
        object[key] = value
    until false -- infinite loop while key-value pairs are found
end

--- Scans a JSON string from the opening inverted comma or single quote to the
-- end of the string.
-- Returns the string extracted as a Lua string,
-- and the position of the next non-string character
-- (after the closing inverted comma or single quote).
-- @param s The string being scanned.
-- @param startPos The starting position of the scan.
-- @return string, int The extracted string as a Lua string, and the next character to parse.
function decode_scanString(s, startPos)
    assert(startPos, 'decode_scanString(..) called without start position')
    local startChar = string.sub(s, startPos, startPos)
    assert(startChar == [[']] or startChar == [["]], 'decode_scanString called for a non-string')
    local escaped = false
    local endPos = startPos + 1
    local bEnded = false
    local stringLen = string.len(s)
    repeat
        local curChar = string.sub(s, endPos, endPos)
        -- Character escaping is only used to escape the string delimiters
        if not escaped then
            if curChar == [[\]] then
                escaped = true
            else
                bEnded = curChar == startChar
            end
        else
            -- If we're escaped, we accept the current character come what may
            escaped = false
        end
        endPos = endPos + 1
        assert(endPos <= stringLen + 1, "String decoding failed: unterminated string at position " .. endPos)
    until bEnded
    local stringValue = 'return ' .. string.sub(s, startPos, endPos - 1)
    local stringEval = loadstring(stringValue)
    assert(stringEval,
        'Failed to load string [ ' .. stringValue .. '] in JSON4Lua.decode_scanString at position ' .. startPos .. ' : ' ..
            endPos)
    return stringEval(), endPos
end

--- Scans a JSON string skipping all whitespace from the current start position.
-- Returns the position of the first non-whitespace character, or nil if the whole end of string is reached.
-- @param s The string being scanned
-- @param startPos The starting position where we should begin removing whitespace.
-- @return int The first position where non-whitespace was encountered, or string.len(s)+1 if the end of string
-- was reached.
function decode_scanWhitespace(s, startPos)
    local whitespace = " \n\r\t"
    local stringLen = string.len(s)
    while (string.find(whitespace, string.sub(s, startPos, startPos), 1, true) and startPos <= stringLen) do
        startPos = startPos + 1
    end
    return startPos
end

return {
    encode = encode,
    decode = decode,
    encodable = isEncodable,
    null = null,
}
