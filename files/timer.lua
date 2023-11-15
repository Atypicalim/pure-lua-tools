--[[
    timer
]]

timer = timer or {}
local timers = {}

local function timer_insert(sec, action)
    local deadline = os.clock() + sec
    local pos = 1
    for i, v in ipairs(timers) do
        if v.deadline > deadline then
            break
        end
        pos = i + 1
    end
    local tm = {
        deadline = deadline,
        action = action
    }
    table.insert(timers, pos, tm)
end

local function timer_check()
    local tm = timers[1]
    if tm.deadline <= os.clock() then
        table.remove(timers, 1)
        local isOk, error = xpcall(tm.action, debug.traceback)
        if isOk then return end
        print(error)
    end
end

function timer.flag()
    return {}
end

function timer.finish(flag)
    flag.ok = true
end

function timer.running(flag)
    return flag.ok ~= true
end

function timer.async(func)
    local co = coroutine.create(func)
    coroutine.resume(co)
end

function timer.sleep(seconds)
    local co = coroutine.running()
    timer_insert(seconds, function()
        coroutine.resume(co)
    end)
    coroutine.yield()
end

function timer.wait(flag)
    while timer.running(flag) do
        timer.sleep(0.1)
    end
end

local function timer_delay(seconds, func, _flag)
    _flag = _flag or timer.flag()
    timer_insert(seconds, function()
        if not timer.running(_flag) then
            return
        end
        local isOk, s = xpcall(func, debug.traceback)
        if not isOk then
            print(s)
            return
        end
        if not s or s <= 0 then
            timer.finish(_flag)
        else
            timer_delay(s, func, _flag)
        end
    end)
    return _flag
end

function timer.delay(seconds, func)
    return timer_delay(seconds, func)
end

function timer.start()
    while #timers > 0 do
        timer_check()
    end
end
