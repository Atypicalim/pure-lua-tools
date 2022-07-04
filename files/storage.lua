--[[
    storage
]]

assert(Storage == nil)
Storage = class("Storage")

local operationg = {}

function Storage:__init__(path, shiftCount)
    assert(is_string(path) and #path > 0, 'invalid storage path!')
    assert(shiftCount == nil or is_number(shiftCount), 'invalid salt type!')
    self._path = path ~= files.get_folder(path) and path or path .. ".db"
    self._shift = shiftCount or 0
    self._data = nil
    if files.is_file(self._path) then
        self:_read()
    end
    if not self._data then
        self._data = {}
        self:_write()
    end
    assert(files.is_file(self._path), 'storage initialize failed!')
    assert(operationg[self._path] == nil, 'storage already in use!')
    operationg[self._path] = true
end

function Storage:close()
    assert(self._path ~= nil, 'storage already closed!')
    operationg[self._path] = nil
    self._path = nil
    self._data = nil
end

function Storage:_read()
    assert(self._path ~= nil, 'storage already closed!')
    local content = files.read(self._path)
    assert(content ~= nil, "invalid storage file:" .. self._path)
    if self._shift > 0 then
        content = encryption.base64_decode(content)
        local list = {}
        for i = 1, #content do
            list[i] = string.char(string.byte(content:sub(i,i)) - self._shift)
        end
        content = table.implode(list)
        content = encryption.base64_decode(content)
    end
    self._data = json.decode(content)
end

function Storage:_write()
    assert(self._path ~= nil, 'storage already closed!')
    local content = json.encode(self._data)
    if self._shift > 0 then
        content = encryption.base64_encode(content)
        local list = {}
        for i = 1, #content do
            list[i] = string.char(string.byte(content:sub(i,i)) + self._shift)
        end
        content = table.implode(list)
        content = encryption.base64_encode(content)
    end
    if not files.is_file(self._path) then
        files.mk_folder(files.get_folder(self._path))
    end
    return files.write(self._path, content)
end

function Storage:get(key, default)
    assert(self._path ~= nil, 'storage already closed!')
    assert(is_string(key), 'invalid storage key!')
    if self._data[key] == nil then return default end
    assert(type(self._data[key]) == type(default) or default == nil, 'invalid data type!')
    return self._data[key]
end

function Storage:set(key, value)
    assert(self._path ~= nil, 'storage already closed!')
    assert(is_string(key), 'invalid storage key!')
    if self._data[key] == nil then
        self._data[key] = value
    else
        assert(type(self._data[key]) == type(value) or value == nil, 'invalid data type!')
        self._data[key] = value
    end
    return self:_write()
end
