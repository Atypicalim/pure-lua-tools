--[[
    Canvas
]]

assert(Canvas == nil)
Canvas = class("Canvas")

function Canvas:__init__(w, h)
    self._width = w
    self._height = h
    self._pixels = {}
    for y=1,self._height do
        for x=1,self._width do
            self:setPixel(x, y, {10, 10, 10, 255})
        end
    end
end

function Canvas:setPixel(x, y, pixel)
    local xi, xf = math.modf(x)
    local yi, yf = math.modf(y)
    if xf == 0.5 and yf == 0.5 then
        return
    elseif xf == 0.5 then
        self:setPixel(xi, y, pixel)
        self:setPixel(xi + 1, y, pixel)
        return
    elseif yf == 0.5 then
        self:setPixel(x, yi, pixel)
        self:setPixel(x, yi + 1, pixel)
        return
    end
    x = math.round(x)
    y = math.round(y)
    assert(#pixel == 4)
    if not self._pixels[x] then
        self._pixels[x] = {}
    end
    self._pixels[x][y] = pixel
    return self
end

function Canvas:getPixel(x, y)
    return self._pixels[x][y]
end

function Canvas:getPixels(x, y, w, h)
    x = x or 1
    y = y or 1
    w = w or self._width
    h = h or self._height
    local r = {}
    for i=y,h do
        for j=x,w do
            table.insert(r, self:getPixel(j, i))
        end
    end
    return r
end

function Canvas:drawLine(fromX, fromY, toX, toY, pixel)
    local dx = toX >= fromX and 1 or -1
    local dy = toY >= fromY and 1 or -1
    local kx = (toY - fromY) / (toX - fromX)
    local ky = (toX - fromX) / (toY - fromY)
    local bx = fromY - kx * fromX
    local by = fromX - ky * fromY
    if kx ~= math.huge and kx ~= -math.huge and kx == kx then
        for x=fromX,toX,dx do
            local y = kx * x + bx
            self:setPixel(x, y, pixel)
        end
    end
    if ky ~= math.huge and ky ~= -math.huge and ky == ky then
        for y=fromY,toY,dy do
            local x = ky * y + by
            self:setPixel(x, y, pixel)
        end
    end
    return self
end

function Canvas:drawRect(fromX, fromY, toX, toY, isFill, pixel)
    local d = toX >= fromX and 1 or -1
    for x=fromX,toX,d do
        if isFill or x == fromX or x == toX then
            self:drawLine(x, fromY, x, toY, pixel)
        else
            self:setPixel(x, fromY, pixel)
            self:setPixel(x, toY, pixel)
        end
    end
    return self
end

function Canvas:drawCircle(cx, cy, r, isFill, pixel)
    for x=-r,r do
        y = math.round(math.sqrt(r * r - x * x))
        if isFill then
            self:drawLine(cx + x, cy + y, cx + x, cy - y, pixel)
        else
            self:setPixel(cx + x, cy + y, pixel)
            self:setPixel(cx + x, cy - y, pixel)
        end
    end
    for y=-r,r do
        x = math.round(math.sqrt(r * r - y * y))
        if isFill then
            self:drawLine(cx + x, cy + y, cx - x, cy + y, pixel)
        else
            self:setPixel(cx + x, cy + y, pixel)
            self:setPixel(cx - x, cy + y, pixel)
        end
    end
    return self
end

function Canvas:drawEllipse(cx, cy, w, h, pixel)
    for y=cy-h,cy+h do
        for x=cx-w,cx+w do
            local tx = (x - cx) / (w * 2)
            local ty = (y - cy) / (h * 2)
            if tx * tx + ty * ty <= 0.25 then
                self:setPixel(x, y, pixel)
            end
        end
    end
    return self
end
