--[[
    graphic
]]

assert(Graphic == nil)
Graphic = class("Graphic")

local HIDE_CONSOLE = [[
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0) # hide:0, show:5
]]

local COMMON_HEADER = [[
[reflection.assembly]::LoadWithPartialName( "System.Drawing");
$brush = new-object Drawing.SolidBrush "#22ffcc"
$pen = new-object Drawing.Pen "#22ffcc"
$pen.width = 10
$x = 0
$y = 0
$w = 250
$h = 250
$ax = 0.5
$ay = 0.5
]]

local FORM_CREATE = [[
[reflection.assembly]::LoadWithPartialName( "System.Windows.Forms");
[System.Windows.Forms.Application]::EnableVisualStyles();
$form = New-Object Windows.Forms.Form
$form.ClientSize         = '%d,%d'
$form.StartPosition = 'CenterScreen'
$graphics = $form.createGraphics()
$form.add_paint({
]]

local FORM_SHOW = [[
})
$icon = New-Object system.drawing.icon ("%s")
$form.Icon = $icon
$form.text = "%s"
$form.ShowDialog();
$graphics.Dispose()
]]

local IMAGE_CREATE = [[
$bitmap = new-object System.Drawing.Bitmap 500,500
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
]]

local IMAGE_SAVE = [[
$bitmap.Save("%s")
$graphics.Dispose()
]]

local GRAPHIC_COLOR = [[
$brush.color = "%s"
$pen.color = "%s"
]]

local GRAPHIC_SIZE = [[
$pen.width = %d
]]

local GRAPHIC_POSITION = [[
$x = %d
$y = %d
]]

local GRAPHIC_SIZE = [[
$w = %d
$h = %d
]]

local GRAPHIC_SCREEN = [[
$size = new-object System.Drawing.Size $w, $h
$graphics.CopyFromScreen(%d, %d, $x, $y, $size);
]]

local GRAPHIC_CLIP = [[
$rect = new-object Drawing.Rectangle ($x - $ax * $w), ($y - $ay * $h), $w, $h
$graphics.SetClip($rect)
]]

local DIALOG_TEXT = [[
$font = new-object System.Drawing.Font "%s",%d
$string = '%s'
$size = $graphics.MeasureString($string, $font);
$graphics.DrawString($string, $font, $brush, ($x - $ax * $size.Width), ($y - $ay * $size.Height));
]]

local DIALOG_IMAGE = [[
$file = (get-item '%s')
$img = [System.Drawing.Image]::Fromfile($file);
$units = [System.Drawing.GraphicsUnit]::Pixel
$dest = new-object Drawing.Rectangle ($x - $ax * $w), ($y - $ay * $h), $w, $h
$src = new-object Drawing.Rectangle %d, %d, %d, %d
$graphics.DrawImage($img, $dest, $src, $units);
]]

local DIALOG_ELLIPSE = [[
$rect = new-object Drawing.Rectangle ($x - $ax * $w), ($y - $ay * $h), $w, $h
$graphics.%sEllipse(%s, $rect);
]]

local DIALOG_RECTANGLE = [[
$rect = new-object Drawing.Rectangle ($x - $ax * $w), ($y - $ay * $h), $w, $h
$graphics.%sRectangle(%s, $rect);
]]

local DIALOG_LINE = [[
%s
$points = %s
$graphics.DrawLines($pen, $points);
]]

local DIALOG_CURVE = [[
%s
$points = %s
$graphics.DrawCurve($pen, $points);
]]

local DIALOG_BEZIER = [[
%s
$points = %s
$graphics.DrawBeziers($pen, $points);
]]

local DIALOG_PIE = [[
$graphics.%sPie(%s, ($x - $ax * $w), ($y - $ay * $h), $w, $h, %d, %d);
]]

local DIALOG_ARC = [[
$graphics.DrawArc($pen, ($x - $ax * $w), ($y - $ay * $h), $w, $h, %d, %d);
]]

local DIALOG_POLYGON = [[
%s
$points = %s
$graphics.%sPolygon(%s, $points);
]]

function Graphic:__init__(w, h)
    assert(tools.is_windows(), 'platform not supported!')
    self._w = w or 500
    self._h = h or 500
    self._children = {}
    self._code = ""
end

function Graphic:setColor(color)
    color = color or "#eeeeee"
    self._code = self._code .. string.format(GRAPHIC_COLOR, color, color)
    return self
end

function Graphic:setSize(size)
    size = size or 10
    self._code = self._code .. string.format(GRAPHIC_SIZE, size)
    return self
end

function Graphic:setXY(x, y)
    x = x or 0
    y = y or 0
    self._code = self._code .. string.format(GRAPHIC_POSITION, x, y)
    return self
end

function Graphic:setWH(w, h)
    w = w or 0
    h = h or 0
    self._code = self._code .. string.format(GRAPHIC_SIZE, w, h)
    return self
end

function Graphic:copyScreen(fromX, fromY)
    fromX = fromX or 0
    fromY = fromY or 0
    self._code = self._code .. string.format(GRAPHIC_SCREEN, fromX, fromY)
    return self
end

function Graphic:setClip()
    self._code = self._code .. string.format(GRAPHIC_CLIP)
    return self
end

function Graphic:addText(text, size, font)
    text = text or "Text..."
    size = size or 13
    font = font or "Microsoft Sans Serif"
    self._code = self._code .. string.format(DIALOG_TEXT, font, size, text)
    return self
end

function Graphic:addImage(path, fromX, fromY, fromW, fromH)
    path = path or ""
    fromX = fromX or 0
    fromY = fromY or 0
    fromW = fromW or 250
    fromH = fromH or 250
    self._code = self._code .. string.format(DIALOG_IMAGE, path, fromX, fromY, fromW, fromH)
    return self
end

function Graphic:addEllipse(isFill)
    local mode, tool = self:_formatMode(isFill ~= false)
    self._code = self._code .. string.format(DIALOG_ELLIPSE, mode, tool)
    return self
end

function Graphic:addRectangle(isFill)
    local mode, tool = self:_formatMode(isFill ~= false)
    self._code = self._code .. string.format(DIALOG_RECTANGLE, mode, tool)
    return self
end

function Graphic:addLine(point1, point2, ...)
    local points = {point1, point2, ...}
    points = #points > 0 and points or {}
    local names, bodies = self:_formatPoints(points)
    self._code = self._code .. string.format(DIALOG_LINE, bodies, names)
    return self._children[#self._children]
end

function Graphic:addCurve(point1, point2, ...)
    local points = {point1, point2, ...}
    points = #points > 0 and points or {}
    local names, bodies = self:_formatPoints(points)
    self._code = self._code .. string.format(DIALOG_CURVE, bodies, names)
    return self._children[#self._children]
end

function Graphic:addBezier(start, cPointA1, cPointB1, end1, ...)
    local points = {start, cPointA1, cPointB1, end1, ...}
    points = #points > 0 and points or {}
    local names, bodies = self:_formatPoints(points)
    self._code = self._code .. string.format(DIALOG_BEZIER, bodies, names)
    return self._children[#self._children]
end

function Graphic:addPie(fromR, toR, isFill)
    fromR = fromR or 0
    toR = toR or 270
    local mode, tool = self:_formatMode(isFill ~= false)
    self._code = self._code .. string.format(DIALOG_PIE, mode, tool, fromR, toR)
    return self
end

function Graphic:addArc(fromR, toR)
    fromR = fromR or 0
    toR = toR or 270
    self._code = self._code .. string.format(DIALOG_ARC, fromR, toR)
    return self._children[#self._children]
end

function Graphic:addPolygon(point1, point2, ...)
    local points = {point1, point2, ...}
    points = #points > 0 and points or {}
    local names, bodies = self:_formatPoints(points)
    local mode, tool = self:_formatMode(false)
    self._code = self._code .. string.format(DIALOG_POLYGON, bodies, names, mode, tool)

    return self._children[#self._children]
end

function Graphic:_formatMode(isFill)
    if isFill then
        return "Fill", "$brush"
    else
        return "Draw", "$pen"
    end
end

function Graphic:_formatPoints(points)
    local names, bodies = "", ""
    for index,item in ipairs(points) do
        names = names .. string.format("$p%d", index) .. (index ~= #points and "," or "")
        bodies = bodies .. string.format("$p%s = new-object Drawing.Point %d, %d;", index, item[1], item[2])
    end
    return names, bodies
end

function Graphic:_runScript()
    files.write("running.ps1", self._code)
    local isOk, r = tools.execute([[ powershell.exe -file ./running.ps1]])
    assert(isOk, 'powershell execute failed:' .. r)
    files.delete("running.ps1")
end

function Graphic:show(title, icon)
    title = title or "Title..."
    icon = icon or "./others/test.ico"
    self._code = COMMON_HEADER .. string.format(FORM_CREATE, self._w, self._h) .. self._code -- HIDE_CONSOLE
    self._code = self._code .. string.format(FORM_SHOW, icon, title)
    self:_runScript()
end

function Graphic:save(path)
    path = path or "./graphic.png"
    self._code = COMMON_HEADER .. string.format(IMAGE_CREATE, self._w, self._h) .. self._code
    self._code = self._code .. string.format(IMAGE_SAVE, path)
    self:_runScript()
end
