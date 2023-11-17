--[[
    console
]]

console = console or {}

local LINE_LENGTH = 50

local style_flag = nil
local STYLE_MAP = {
    RESET = 0,
    BOLD = 1,
    UNDERLINE = 4,
    INVERSE = 7,
}
local COLOR_MAP = {
    BLACK = {90, 40},
    RED = {91, 41},
    GREEN = {92, 42},
    YELLOW = {93, 43},
    BLUE = {94, 44},
    MAGENTA = {95, 45},
    CYAN = {96, 46},
    WHITE = {97, 47},
}

local function _console_print_format(format, ...)
    local args = {...}
    if not style_flag then
        style_flag = true
        os.execute('cd > nul 2>&1')
    end
    io.write(format)
    for i,v in ipairs(args) do
        io.write(i == 1 and "" or "  ", v)
    end
    io.write('\27[0m')
end

function console.print_colorful_no_wrap(fgName, bgName, ...)
    local fgInfo = COLOR_MAP[fgName] or COLOR_MAP.WHITE
    local bgInfo = COLOR_MAP[bgName] or COLOR_MAP.BLACK
    local fgColor = fgInfo[1]
    local bgColor = bgInfo[2]
    local format = string.format('\27[%d;%dm', bgColor, fgColor)
    _console_print_format(format, ...)
end

function console.print_colorful_with_wrap(fgName, bgName, ...)
    console.print_colorful_no_wrap(fgName, bgName, ...)
    io.write('\n')
end

function console.print_colorful(fgName, bgName, ...)
    print_colorful_with_wrap(fgName, bgName, ...)
end

function console.print_styled_no_wrap(name, ...)
    name = name and string.upper(name) or "RESET"
    local style = STYLE_MAP[name] or STYLE_MAP.RESETd
    local format = string.format('\27[%dm', style)
    _console_print_format(format, ...)
end

function console.print_styled_with_wrap(name, ...)
    console.print_styled_no_wrap(name, ...)
    io.write('\n')
end

function console.print_styled(name, ...)
    print_styled_with_wrap(name, ...)
end

function console.print_inform()
    print(string.center("inform", LINE_LENGTH, "-"))
    print("|" .. string.center("Yes ?", LINE_LENGTH - 2, " ") .. "|")
    print(string.rep("-", LINE_LENGTH))
    while true do
        io.write("> ")
        local input = string.upper(io.read())
        if input == "TRUE" or input == "YES" or input == "Y" then
            print('* informed!')
            return true
        else
            console.delete_line(1)
            print('* inform:')
        end
    end
end

function console.print_confirm()
    print(string.center("confirm", LINE_LENGTH, "-"))
    print("|" .. string.center("Yes or No ?", LINE_LENGTH - 2, " ") .. "|")
    print(string.rep("-", LINE_LENGTH))
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
            console.delete_line(1)
            print('* confirm:')
        end
    end
end

function console.print_progress(rate, isReplace, charLeft, charMiddle, charRight)
    charLeft = charLeft ~= nil and charLeft:sub(1, 1) or "="
    charMiddle = charMiddle ~= nil and charMiddle:sub(1, 1) or ">"
    charRight = charRight ~= nil and charRight:sub(1, 1) or "-"
    local size = LINE_LENGTH - 9
    local format = "[ %s %s ]\n"
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
        local char = charRight
        if isLeft then
            char = charLeft
        elseif isMiddle then
            char = charMiddle
        end
        bar = bar .. char
    end
    local percent = string.center(string.format("%d%%", progress * 100), 4, " ") 
    local text = string.format(format, bar, percent)
    console.delete_line(isReplace and 1 or 0, text, true)
end

function console.print_qrcode(content)
    print(string.center("qrcode", LINE_LENGTH, "-"))
    print("|")
    local isOk, datas = library.qrcode(content)
    assert(isOk == true, 'qrcode generate failed!')
    for i,column in ipairs(datas) do
        if i ~= 1 then
            io.write('\n')
        end
        for j,row in ipairs(column) do
            if j == 1 then
                io.write('|  ')
            end
            io.write(row > 0 and "\27[47m  \27[0m" or "  ")
            if j == #column then
                io.write('  |')
            end
        end
    end
    io.write('\n')
    print("|")
    print(string.rep("-", LINE_LENGTH))
end

function console.print_select(selections)
    selections = selections or {}
    local TEXT_LENGTH = LINE_LENGTH - 9
    --
    if #selections <= 0 then
        return nil, -1
    end
    --
    local lenLine = 0
    local _texts = {}
    
    for i,text in ipairs(selections) do
        local head = string.center(tostring(i), 3, " ")
        local body = nil
        if #text <= TEXT_LENGTH then
            body = string.left(text, TEXT_LENGTH, " ")
        else
            body = string.sub(text, 1, TEXT_LENGTH - 3) .. "..."
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
            console.delete_line(1)
            print('* select:')
        end
    end
end

function console.print_enter(isPassword, isNumber, checkFunc)
    local tip = "text"
    if isPassword then tip = "password" end
    if isNumber then tip = "number" end
    local title = string.format("Enter a %s ?", tip)
    print(string.center("enter", LINE_LENGTH, "-"))
    print("|" .. string.center(title, LINE_LENGTH - 2, " ") .. "|")
    print(string.rep("-", LINE_LENGTH))
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
                        console.delete_line(1, "> " .. string.rep("*", #input), false)
                    end
                    print("* " .. (errorMsg or "invalid format!"))
                    print('* enter:')
                    skip = true
                end
            end
            if not skip then
                if isPassword then
                    console.delete_line(1, "> " .. string.rep("*", #input), false)
                end
                print('* entered!')
                return input
            end
        else
            console.delete_line(1, "* enter:", false)
        end
    end
end

function console.print_edit(_content)
    _content = _content or ""
    local content = _content
    print(string.center("edit", LINE_LENGTH, "-"))
    print("|" .. string.center("e:Edit s:Save p:Print r:Revert q:Quit", LINE_LENGTH - 2, " ") .. "|")
    print(string.rep("-", LINE_LENGTH))
    while true do
        io.write("> ")
        local input = string.upper(io.read())
        if input == "E" or input == "EDIT" then
            console.delete_line(1)
            print('* editing:')
            local path = files.temp()
            files.write(path, content)
            tools.edit_file(path)
            content = files.read(path) or content
            files.delete(path)
            print('* edited!')
        elseif input == "P" or input == "PRINT" then
            console.delete_line(1)
            local lines = {}
            for line in content:gmatch("[^\r\n]+") do
                table.insert(lines, line)
            end
            for i,v in ipairs(lines) do
                print("|" .. string.right(tostring(i), 3, " "), v)
            end
            print('* printed!')
        elseif input == "S" or input == "SAVE" then
            local path = dialog.select_save(title, filter, folder)
            console.delete_line(1)
            if path then
                files.write(path, content)
                print('* saved!')
            end
        elseif input == "R" or input == "RESET" then
            content = _content
            console.delete_line(1)
            print('* reverted!')
        elseif input == "Q" or input == "QUIT" then
            console.delete_line(1)
            print('* quitted!')
            break
        else
            console.delete_line(1)
            print('* edit:')
        end
    end
    return content
end

function console.delete_line(count, replacement, noWrap)
    local line = math.max(0, count or 1)
    local text = replacement or ""
    if noWrap == nil then noWrap = #text == 0 end
    text = text .. (noWrap and "" or "\n")
    text = line <= 0 and text or string.format("\027[%dF\027[0J", line) .. text
    io.write(text)
end

function console.clean_screen(replacement, noWrap)
    local text = replacement or ""
    if noWrap == nil then noWrap = #text == 0 end
    text = text .. (noWrap and "" or "\n")
    text = "\027[2J\027[1;1H" .. text
    io.write(text)
end
