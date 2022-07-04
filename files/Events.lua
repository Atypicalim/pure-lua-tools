--[[
    Events
]]

assert(Events == nil)
Events = class('Events')

function Events:__init__()
    self._eventsMap = {}
end

function Events:triggerEvent(name, ...)
    assert(type(name) == 'string', 'event name should be function')
    self._eventsMap[name] = self._eventsMap[name] or {}
    local args = {...}
    for callback,times in pairs(self._eventsMap[name]) do
        xpcall(function()
            callback(unpack(args))
        end, function(error)
            print('event trigger error:', error)
        end)
        if not self._eventsMap[name][callback] then
            -- listener was removed in callback
        elseif times <= 0 then
            -- continue listening until removed
        elseif times > 1 then
            self._eventsMap[name][callback] = times - 1
        elseif times == 1 then
            self._eventsMap[name][callback] = nil
        else
            error('not expected')
        end
    end
end

function Events:addListener(name, listener, times)
    assert(type(name) == 'string', 'event name should be function')
    assert(type(listener) == 'function', 'event listener should be function')
    self._eventsMap[name] = self._eventsMap[name] or {}
    if times == nil then
        times = 1
    elseif times == false then
        times = 1
    elseif times == true then
        times = 0
    elseif type(times) == 'number' then
        times = math.max(times, 0)
    else
        error('event times should be number')
    end
    self._eventsMap[name][listener] = times
end

function Events:removeListener(name, listener)
    assert(type(name) == 'string', 'event name should be function')
        assert(type(listener) == 'function', 'event listener should be function')
    self._eventsMap[name] = self._eventsMap[name] or {}
    self._eventsMap[name][listener] = nil
end

function Events:removeListeners(name)
    assert(type(name) == 'string', 'event name should be function')
    self._eventsMap[name] = {}
end

function Events:hasListener(name, listener)
    assert(type(name) == 'string', 'event name should be function')
    assert(type(listener) == 'function', 'event listener should be function')
    return self._eventsMap[name] ~= nil and self._eventsMap[name][listener] ~= nil
end
