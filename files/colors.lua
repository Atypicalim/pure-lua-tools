--[[
    colors
]]

colors = colors or {}

function colors.rgb_to_hex(rgb)
    return bit.lshift(rgb[1], 16) + bit.lshift(rgb[2], 8) + rgb[3]
end

function colors.hex_to_rgb(hex)
    local r = bit.band(bit.rshift(hex, 16), 0xFF)
    local g = bit.band(bit.rshift(hex, 8), 0xFF)
    local b = bit.band(hex, 0xFF)
    return {r, g, b}
end

function colors.rgb_to_cmyk(rgb)
    local cyan = 255 - rgb[1]
    local magenta = 255 - rgb[2]
    local yellow = 255 - rgb[3]
    local black   = math.min(cyan, magenta, yellow)
    local cyan    = ((cyan - black) / (255 - black))
    local magenta = ((magenta - black) / (255 - black))
    local yellow  = ((yellow  - black) / (255 - black))
  return {cyan, magenta, yellow, black / 255}
end

function colors.cmyk_to_rgb(cmyk)
    local k = cmyk[4]
    local R = cmyk[1] * (1.0 - k) + k
    local G = cmyk[2] * (1.0 - k) + k
    local B = cmyk[3] * (1.0 - k) + k
    R = math.floor((1.0 - R) * 255.0 + 0.5)
    G = math.floor((1.0 - G) * 255.0 + 0.5)
    B = math.floor((1.0 - B) * 255.0 + 0.5)
    return {R, G, B}
end

function colors.rgb_to_str(rgb)
    local r_hex = string.format("%02X", rgb[1])
    local g_hex = string.format("%02X", rgb[2])
    local b_hex = string.format("%02X", rgb[3])
    return "#" .. r_hex .. g_hex .. b_hex
end

function colors.str_to_rgb(str)
    if string.sub(str, 1, 1) == "#" then
        str = string.sub(str, 2, -1)
    end
    local r_hex = string.sub(str, 1, 2)
    local g_hex = string.sub(str, 3, 4)
    local b_hex = string.sub(str, 5, 6)
    return {tonumber(r_hex, 16), tonumber(g_hex, 16), tonumber(b_hex, 16)}
end

function colors.rgb_mix_colors(color, ...)
    local r = color[1]
    local g = color[2]
    local b = color[3]
    local t = {...}
    for i,v in ipairs(t) do
        r = r + v[1]
        g = g + v[2]
        b = b + v[3]
    end
    local c = #t + 1
    r = math.floor(r / c)
    g = math.floor(g / c)
    b = math.floor(b / c)
    return {r, g, b}
end

function colors.rgb_adjust_brightness(rgb, percent)
    local factor = (100 + percent) / 100
    local r = math.min(255, math.max(0, math.floor(rgb[1] * factor)))
    local g = math.min(255, math.max(0, math.floor(rgb[2] * factor)))
    local b = math.min(255, math.max(0, math.floor(rgb[3] * factor)))
    return {r, g, b}
end

function colors.rgb_get_brightness(rgb)
    return (rgb[1] * 299 + rgb[2] * 587 + rgb[3] * 114) / 1000
end

function colors.rgb_get_grayscale(rgb)
    local gray = (rgb[1] + rgb[2] + rgb[3]) / 3
    gray = math.round(gray)
    return {gray, gray, gray}
end

function colors.rgb_get_complementary(rgb)
    local r = 255 - rgb[1]
    local g = 255 - rgb[2]
    local b = 255 - rgb[3]
    return {r, g, b, a}
  end

function colors.get_random_rgb()
    return {math.random(1, 255), math.random(1, 255), math.random(1, 255)}
end
