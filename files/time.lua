--[[
    Time
]]

assert(Time == nil)
Time = class("Time")

local SECONDS_WEEK = 60 * 60 * 24 * 7
local SECONDS_DAY = 60 * 60 * 24
local SECONDS_HOUR = 60 * 60
local SECONDS_MINUTE = 60
local SECONDS_SECOND = 1

function Time.getZone()
    local now = os.time()
    local utc = os.time(os.date("!*t", now))
    local diff = os.difftime(now, utc)
    local zone = math.floor(diff / 60 / 60)
    return zone
end

function Time:getMillis()
    local _, milli = math.modf(os.clock())
    return math.floor(Time.getSeconds() * 1000 + milli * 1000)
end

function Time:__init__(time)
    self._time = time or os.time()
end

function Time:value()
    return self._time
end

function Time:format(desc)
    return os.date(desc, self._time)
end

function Time:getTime()
    return os.date("%H%M%S", self._time)
end

function Time:getDate()
    return os.date("%Y%m%d", self._time)
end

function Time:getYear()
    return tonumber(os.date("%Y", self._time))
end

function Time:getMonth()
    return tonumber(os.date("%m", self._time))
end

function Time:nameMonth(isFull)
    return os.date(isFull and "%B" or "%b", self._time)
end

function Time:getDay()
    return tonumber(os.date("%d", self._time))
end

function Time:getHour()
    return tonumber(os.date("%H", self._time))
end

function Time:getMinute()
    return tonumber(os.date("%M", self._time))
end

function Time:getSecond()
    return tonumber(os.date("%S", self._time))
end

function Time:getWeek()
    local w = tonumber(os.date("%w", self._time))
    return w == 0 and 7 or w
end

function Time:nameWeek(isFull)
    return os.date(isFull and "%A" or "%a", self._time)
end

function Time:isAm()
    return self:getHour() < 12
end

function Time:isPm()
    return not self:isAm()
end

function Time:countWeek()
    local second = self._time % SECONDS_WEEK
    local hour = (self._time - second) / SECONDS_WEEK
    local time = Time(second)
    local result = {time:countDay()}
    table.insert(result, 1, hour)
    return unpack(result)
end

function Time:countDay()
    local second = self._time % SECONDS_DAY
    local hour = (self._time - second) / SECONDS_DAY
    local time = Time(second)
    local result = {time:countHour()}
    table.insert(result, 1, hour)
    return unpack(result)
end

function Time:countHour()
    local second = self._time % SECONDS_HOUR
    local hour = (self._time - second) / SECONDS_HOUR
    local time = Time(second)
    local result = {time:countMinute()}
    table.insert(result, 1, hour)
    return unpack(result)
end

function Time:countMinute()
    local second = self._time % SECONDS_MINUTE
    local minute = (self._time - second) / SECONDS_MINUTE
    return minute, second
end

function Time:addWeek(cound)
    self._time = self._time + cound * SECONDS_WEEK
    return self
end

function Time:addDay(cound)
    self._time = self._time + cound * SECONDS_DAY
    return self
end

function Time:addHour(cound)
    self._time = self._time + cound * SECONDS_HOUR
    return self
end

function Time:addMinute(cound)
    self._time = self._time + cound * SECONDS_MINUTE
    return self
end

function Time:addSecond(cound)
    self._time = self._time + cound * SECONDS_SECOND
    return self
end

function Time:diffTime(time)
    assert(type(time) == "table", 'invalid  time value')
    local distance = self:value() - time:value()
    return Time(math.abs(distance)), distance > 0
end

function Time:addTime(time)
    self._time = self._time + time:value()
    return self
end
