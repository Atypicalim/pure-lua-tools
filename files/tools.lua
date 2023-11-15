--[[
    tools
]]

tools = tools or {}

local isWindows = nil
function tools.is_windows()
    if is_boolean(isWindows) then return isWindows end
    isWindows = package.config:sub(1,1) == "\\"
    return isWindows 
end

local isLinux = nil
function tools.is_linux()
    if is_boolean(isLinux) then return isLinux end
    isLinux = not tools.is_windows() and string.find(os.getenv("HOME") or "", '/home/') ~= nil
    return isLinux
end

local isLinux = nil
function tools.is_mac()
    if is_boolean(isLinux) then return isLinux end
    isLinux = not tools.is_windows() and string.find(os.getenv("HOME") or "", '/Users/') ~= nil
    return isLinux
end

function tools.execute(cmd)
    local flag = "::MY_ERROR_FLAG::"
    local file = io.popen(cmd .. [[ 2>&1 || echo ]] .. flag, "r")
    local out = file:read("*all"):trim()
    local isOk = not out:find(flag)
    if not isOk then
        out = out:sub(1, #out - #flag)
    end
    file:close()
    out = out:trim()
    return isOk, out
end

function tools.get_timezone()
    local now = os.time()
    local utc = os.time(os.date("!*t", now))
    local diff = os.difftime(now, utc)
    local zone = math.floor(diff / 60 / 60)
    return zone
end

function tools.get_milliseconds()
    local clock = os.clock()
    local _, milli = math.modf(clock)
    return math.floor(os.time() * 1000 + milli * 1000)
end

function tools.where_is(program)
    if tools.is_windows() then
        return tools.execute([[where "]] .. program .. [["]])
    else
        return tools.execute([[which "]] .. program .. [["]])
    end
end

local style_flag = nil
local STYLE_MAP = {
    RESET = 0,
    BOLD = 1,
    UNDERLINE = 4,
    INVERSE = 7,
    BLACK = 90,
    RED = 91,
    GREEN = 92,
    YELLOW = 93,
    BLUE = 94,
    MAGENTA = 95,
    CYAN = 96,
    WHITE = 97,
}
function tools.print_styled(name, ...)
    if not style_flag then
        style_flag = true
        os.execute('cd > nul 2>&1')
    end
    name = name and string.upper(name) or "RESET"
    local color = STYLE_MAP[name] or STYLE_MAP.RESET
    io.write(string.format('\27[%dm', color))
    print(...)
    io.write('\27[0m')
end

function tools.print_select(selections)
    selections = selections or {}
    local TEXT_MIN_LENGTH = 16
    local TEXT_MAX_LENGTH = 100
    --
    if #selections <= 1 then
        return selections[1], -1
    end
    --
    local lenText = 0
    for i,v in ipairs(selections) do
        lenText = math.max(TEXT_MIN_LENGTH, math.min(TEXT_MAX_LENGTH, math.max(lenText, #v)))
    end
    --
    local lenLine = 0
    local _texts = {}
    
    for i,text in ipairs(selections) do
        local head = string.center(tostring(i), 3, " ")
        local body = nil
        if #text <= lenText then
            body = string.left(text, lenText, " ")
        else
            body = string.sub(text, 1, lenText - 3) .. "..."
        end
        local line = string.format("| %s. %s |", head, body)
        _texts[i] = line
        lenLine = math.max(lenLine, #line)
    end
    --
    print(string.center("select", lenLine, "-"))
    for i,text in ipairs(_texts) do
        print(text)
    end
    for i=0,#_texts do
    end
    print(string.rep("-", lenLine))
    -- 
    while true do
        io.write("> ")
        local input = io.read()
        local index = tonumber(input)
        if index and selections[index] then
            print('* selected!')
            return selections[index], index
        else
            tools.console_delete(1, nil)
            print('* select:')
        end
    end
end

function tools.print_confirm()
    local TEXT_MIN_LENGTH = 25
    print(string.center("confirm", TEXT_MIN_LENGTH, "-"))
    print("|" .. string.center("Yes or No ?", TEXT_MIN_LENGTH - 2, " ") .. "|")
    print(string.rep("-", TEXT_MIN_LENGTH))
    while true do
        io.write("> ")
        local input = string.upper(io.read())
        if input == "FALSE" or input == "NO" or input == "N" then
            print('* confirmed!')
            return false
        elseif input == "TRUE" or input == "YES" or input == "Y" then
            print('* confirmed!')
            return true
        else
            tools.console_delete(1, nil)
            print('* confirm:')
        end
    end
end

function tools.print_inform()
    local TEXT_MIN_LENGTH = 25
    print(string.center("confirm", TEXT_MIN_LENGTH, "-"))
    print("|" .. string.center("Yes ?", TEXT_MIN_LENGTH - 2, " ") .. "|")
    print(string.rep("-", TEXT_MIN_LENGTH))
    while true do
        io.write("> ")
        local input = string.upper(io.read())
        if input == "TRUE" or input == "YES" or input == "Y" then
            print('* informed!')
            return true
        else
            tools.console_delete(1, nil)
            print('* inform:')
        end
    end
end

function tools.print_enter(isPassword, isNumber, checkFunc)
    local TEXT_MIN_LENGTH = 25
    local tip = "text"
    if isPassword then tip = "pass" end
    if isNumber then tip = "numb" end
    local title = string.format("Enter a %s ?", tip)
    print(string.center("enter", TEXT_MIN_LENGTH, "-"))
    print("|" .. string.center(title, TEXT_MIN_LENGTH - 2, " ") .. "|")
    print(string.rep("-", TEXT_MIN_LENGTH))
    while true do
        io.write("> ")
        local input = io.read()
        local skip = false
        if #input > 0 then
            if isNumber and tonumber(input) == nil then
                print("* invalid number!")
                print('* enter:')
                skip = true
            end
            if checkFunc then
                local isValid, errorMsg = checkFunc(input)
                if not isValid then
                    if isPassword then
                        tools.console_delete(1, "> " .. string.rep("*", #input), false)
                    end
                    print("* " .. (errorMsg or "invalid format!"))
                    print('* enter:')
                    skip = true
                end
            end
            if not skip then
                if isPassword then
                    tools.console_delete(1, "> " .. string.rep("*", #input), false)
                end
                print('* entered!')
                return input
            end
        else
            tools.console_delete(1, "* enter:", false)
        end
    end
end

function tools.print_progress(rate, isReplace, format, size, charLeft, charMiddle, charRight)
    size = size or 63 -- bar length
    format = format or "[ %s %s ]\n" -- bar percent
    local progress = math.max(0, math.min(1, rate))
    local bar = ""
    local isLeft = false
    local isMiddle = false
    local isRight = false
    for i=1,size do
        local v = i / size
        local isSmall = v < progress
        local isBig = v > progress
        if not isLeft and not isMiddle and not isRight then
            isLeft = isSmall
        elseif isLeft and not isMiddle and isBig then
            isLeft = false
            isMiddle = true
        elseif isMiddle and not isRight and isBig then
            isMiddle = false
            isRight = true
        end
        local char = charRight or "-"
        if isLeft then
            char = charLeft or "="
        elseif isMiddle then
            char = charMiddle or ">"
        end
        bar = bar .. char
    end
    local percent = string.center(string.format("%d%%", progress * 100), 4, " ") 
    local text = string.format(format, bar, percent)
    tools.console_delete(isReplace and 1 or 0, text, true)
end

function tools.console_delete(count, replacement, noWrap)
    local line = math.max(0, count or 1)
    local text = replacement or ""
    if noWrap == nil then noWrap = #text == 0 end
    text = text .. (noWrap and "" or "\n")
    text = line <= 0 and text or string.format("\027[%dF\027[0J", line) .. text
    io.write(text)
end

function tools.console_clean(replacement, noWrap)
    local text = replacement or ""
    if noWrap == nil then noWrap = #text == 0 end
    text = text .. (noWrap and "" or "\n")
    text = "\027[2J\027[1;1H" .. text
    io.write(text)
end

function tools.open_url(url)
    return tools.execute([[start "]] .. url .. [["]])
end
