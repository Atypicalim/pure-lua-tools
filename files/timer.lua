--[[
    string
]]
local timer = {}
local timers = {}
local pool = setmetatable({}, {
    __mode = "kv"
})

local function timer_insert(sec, fn)
    local expiretime = os.clock() + sec
    local pos = 1
    for i, v in ipairs(timers) do
        if v.expiretime > expiretime then
            break
        end
        pos = i + 1
    end
    local context = {
        expiretime = expiretime,
        fn = fn
    }
    table.insert(timers, pos, context)
    return context
end

local function timer_resume(co, ...)
    local ok, err = coroutine.resume(co, ...)
    if not ok then
        error(debug.traceback(co, err))
    end
    return ok, err
end

local function timer_body(fn)
    local co = coroutine.running()
    while true do
        fn()
        pool[#pool + 1] = co
        fn = coroutine.yield()
    end
end

local function timer_start()
    while #timers > 0 do
        local tm = timers[1]
        if tm.expiretime <= os.clock() then
            table.remove(timers, 1)
            if not tm.remove then
                local ok, err = xpcall(tm.fn, debug.traceback)
                if not ok then
                    print("timer error:", err)
                end
            end
        else
            break
        end
    end
end

function timer.async(fn)
    local co = table.remove(pool)
    if not co then
        co = coroutine.create(timer_body)
    end
    local _, res = timer_resume(co, fn)
    if res then
        return res
    end
    return co
end

function timer.delay(seconds, fn)
    return timer_insert(seconds, fn)
end

function timer.sleep(seconds)
    local co = coroutine.running()
    timer_insert(seconds, function()
        coroutine.resume(co)
    end)
    return coroutine.yield()
end

function timer.cancel(ctx)
    assert(type(ctx) == 'table' and ctx.fn ~= nil)
    ctx.remove = true
end

function timer.start()
    while #timers > 0 do
        timer_start()
    end
end

return timer
