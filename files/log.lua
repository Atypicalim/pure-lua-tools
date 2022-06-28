--[[
    log
]]

local Log = class("Log")

Log.LEVEL = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    USER = 5,
}

Log.COLOR = {
    TAG_BG_CONTENT_FG = {4, 3},
    TAG_FG_CONTENT_BG = {3, 4},
    TAG_BG_CONTENT_BG = {4, 4},
    TAG_FG_CONTENT_FG = {3, 3},
}

local COLORS = {
    [Log.LEVEL.DEBUG] = "\27[%d4m %s \27[0m",
    [Log.LEVEL.INFO]  = "\27[%d2m %s \27[0m",
    [Log.LEVEL.WARN]  = "\27[%d3m %s \27[0m",
    [Log.LEVEL.ERROR] = "\27[%d1m %s \27[0m",
    [Log.LEVEL.USER]  = "\27[%d5m %s \27[0m",
}

local operationg = {}

function Log:__init__(path, name, level, color)
    assert(path == nil or string.valid(path), 'invalid log path!')
    assert(name == nil or string.valid(name), 'invalid log name!')
    assert(level == nil or is_number(level), 'invalid log level!')
    assert(color == nil or table.find_value(Log.COLOR, color), 'invalid log color!')
    self._name = name or "UNKNOWN"
    self._level = level or Log.LEVEL.DEBUG
    self._color = color or Log.COLOR.TAG_BG_CONTENT_FG
    if path ~= nil then
        self._path = path
        assert(operationg[self._path] == nil, 'log already opened!')
        operationg[self._path] = true
        if files.is_file(self._path) then
            files.delete(self._path)
        end
        if not files.is_file(self._path) then
            files.mk_folder(files.get_folder(self._path))
        end
        self._file = io.open(path, "a")
        assert(self._file ~= nil, 'invalid log file!')
    end
    self._valid = true
    self:write(string.format("START->%s", self._name))
end

function Log:close()
    assert(self._valid == true, 'log already closed!')
    if self._path ~= nil then
        operationg[self._path] = nil
        self._path = nil
    end
    if self._file ~= nil then
        self._file:close()
        self._file = nil
    end
    self._valid = false
end

function Log:_write(level, content, ...)
    assert(self._valid == true, 'log already closed!')
    local levelName = table.find_value(Log.LEVEL, level)
    local logContent = string.format(content, ...)
    assert(levelName ~= nil, 'invalid log level!')
    assert(string.valid(content), 'invalid log content!')
    local date = os.date("%Y-%m-%d_%H:%M:%S", os.time())
    local header = string.format("[%s_%s]", self._name, date)
    local footer = string.format("%s : %s", string.left(levelName, 5, " "), logContent)
    if self._file then
        self._file:write(string.format("%s %s\n", header, footer))
    end
    if table.is_empty(self._color) then
        print(string.format("%s %s", header, footer))
    else
        local left = string.format(COLORS[level], self._color[1], header)
        local right = string.format(COLORS[level], self._color[2], footer)
        print(string.format("%s %s", left, right))
    end
end

function Log:write(content, ...)
    self:_write(Log.LEVEL.USER, content, ...)
end

function Log:error(content, ...)
    self:_write(Log.LEVEL.ERROR, content, ...)
end

function Log:warn(content, ...)
    self:_write(Log.LEVEL.WARN, content, ...)
end

function Log:info(content, ...)
    self:_write(Log.LEVEL.INFO, content, ...)
end

function Log:debug(content, ...)
    self:_write(Log.LEVEL.DEBUG, content, ...)
end

return Log
