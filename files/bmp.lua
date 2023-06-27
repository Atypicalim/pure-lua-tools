--[[
    bmp
]]

bmp = bmp or {}

function bmp.write(filename, width, height, pixels)
    local file = assert(io.open(filename, "wb"))
    assert(width % 4 == 0, "Invalid 4-byte alignment for width")
    assert(height % 4 == 0, "Invalid 4-byte alignment for height")
    assert(file ~= nil, 'open file failed:' .. tostring(filename))
    -- BMP文件头
    local fileheader = string.char(0x42, 0x4D) -- 文件类型，BM
    local filesize = 54 + 3 * width * height -- 文件大小
    fileheader = fileheader .. string.char(
        filesize % 256,
        math.floor(filesize / 256) % 256,
        math.floor(filesize / 65536) % 256,
        math.floor(filesize / 16777216) % 256
    ) -- 文件大小
    fileheader = fileheader .. string.rep(string.char(0), 4) -- 保留字段
    fileheader = fileheader .. string.char(54, 0, 0, 0) -- 数据起始位置
    -- BMP信息头
    local infoheader = string.char(40, 0, 0, 0) -- 信息头大小
    infoheader = infoheader .. string.char(
        width % 256,
        math.floor(width / 256) % 256,
        math.floor(width / 65536) % 256,
        math.floor(width / 16777216) % 256
    ) -- 图像宽度
    infoheader = infoheader .. string.char(
        height % 256,
        math.floor(height / 256) % 256,
        math.floor(height / 65536) % 256,
        math.floor(height / 16777216) % 256
    ) -- 图像高度
    infoheader = infoheader .. string.char(1, 0) -- 颜色平面数，必须为1
    infoheader = infoheader .. string.char(24, 0) -- 每个像素的位数，24位
    infoheader = infoheader .. string.rep(string.char(0), 4) -- 压缩方式，0表示不压缩
    local imagesize = 3 * width * height
    infoheader = infoheader .. string.char(
        imagesize % 256,
        math.floor(imagesize / 256) % 256,
        math.floor(imagesize / 65536) % 256,
        math.floor(imagesize / 16777216) % 256
    ) -- 图像数据大小
    infoheader = infoheader .. string.rep(string.char(0), 16) -- 其他信息
    -- 写入文件头和信息头
    file:write(fileheader)
    file:write(infoheader)
    -- 写入像素数据
    for y = height, 1, -1 do
        for x = 1, width do
            local pixel = pixels[y][x]
            file:write(string.char(pixel[3], pixel[2], pixel[1]))
        end
    end
    file:close()
end

function bmp.read(filename)
    local file = assert(io.open(filename, "rb"))
    assert(file ~= nil, 'open file failed:' .. tostring(filename))
    -- BMP文件头
    local fileheader = file:read(14)
    local filetype = fileheader:sub(1,2)
    assert(filetype == "BM", "Not a BMP file")
    local filesize = fileheader:byte(3) +
        fileheader:byte(4) * 256 +
        fileheader:byte(5) * 65536 +
        fileheader:byte(6) * 16777216
    local datastart = fileheader:byte(11) +
        fileheader:byte(12) * 256 +
        fileheader:byte(13) * 65536 +
        fileheader:byte(14) * 16777216

    -- BMP信息头
    local infoheader = file:read(40)
    local width = infoheader:byte(5) +
        infoheader:byte(6) * 256 +
        infoheader:byte(7) * 65536 +
        infoheader:byte(8) * 16777216
    local height = infoheader:byte(9) +
        infoheader:byte(10) * 256 +
        infoheader:byte(11) * 65536 +
        infoheader:byte(12) * 16777216
    local bitsperpixel = infoheader:byte(15) +
        infoheader:byte(16) * 256
    assert(width % 4 == 0, "Invalid 4-byte alignment for width")
    assert(height % 4 == 0, "Invalid 4-byte alignment for height")
    assert(bitsperpixel == 24, "Only 24-bit BMP files are supported")
    local compression = infoheader:byte(17) +
        infoheader:byte(18) * 256 +
        infoheader:byte(19) * 65536 +
        infoheader:byte(20) * 16777216
    assert(compression == 0, "Compressed BMP files are not supported")
    -- 跳过可能存在的调色板数据
    local palette = file:read(datastart - 54)
    -- 读取像素数据
    local pixels = {}
    for y = height, 1, -1 do
        pixels[y] = {}
        for x = 1, width do
            local b = file:read(1):byte()
            local g = file:read(1):byte()
            local r = file:read(1):byte()
            pixels[y][x] = {r, g, b}
        end
        -- 跳过每行可能存在的填充字节
        file:read((4 - (width * 3) % 4) % 4)
    end
    file:close()
    return width, height, pixels
end