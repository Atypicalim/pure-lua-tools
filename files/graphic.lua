--[[
    graphic
]]

assert(Graphic == nil)
Graphic = class("Graphic")
local Node = class("Node")

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
$x = 0
$y = 0
$w = 250
$h = 250
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
$graphics.Dispose()
$bitmap.Save("%s")
$graphics.Dispose()
]]

local GRAPHIC_STYLE = [[
$brush.color = "%s"
$pen.color = "%s"
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

local DIALOG_TEXT = [[
$font = new-object System.Drawing.Font "%s",%d
$graphics.DrawString('%s', $font, $brush, $x, $y);
]]

local DIALOG_IMAGE = [[
$file = (get-item '%s')
$img = [System.Drawing.Image]::Fromfile($file);
$units = [System.Drawing.GraphicsUnit]::Pixel
$dest = new-object Drawing.Rectangle $x, $y, 200, 200
$src = new-object Drawing.Rectangle %d, %d, %d, %d
$graphics.DrawImage($img, $dest, $src, $units);
]]

local DIALOG_ELLIPSE = [[
$rect = new-object Drawing.Rectangle $x, $y, $w, $h
$graphics.FillEllipse($brush, $rect);
]]

local DIALOG_RECTANGLE = [[
$rect = new-object Drawing.Rectangle $x, $y, $w, $h
$graphics.FillRectangle($brush, $rect);
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
$graphics.DrawPie($pen, $x, $y, $w, $h, %d, %d);
]]

local DIALOG_ARC = [[
$graphics.DrawArc($pen, $x, $y, $w, $h, %d, %d);
]]

local DIALOG_POLYGON = [[
%s
$points = %s
$graphics.DrawPolygon($pen, $points);
]]

local TYPES = {
    STYLE = "STYLE",
    POSITION = "POSITION",
    SIZE = "SIZE",
    TEXT = "TEXT",
    ELLIPSE = "ELLIPSE",
    RECTANGLE = "RECTANGLE",
    BEZIER = "BEZIER",
    LINE = "LINE",
    CURVE = "CURVE",
    PIE = "PIE",
    ARC = "ARC",
    POLYGON = "POLYGON",
}

function Node:__init__(tp, map)
    self.tp = tp
    self.x = 0
    self.y = 0
    self.w = 250
    self.h = 250
    self.ext = nil
    for k,v in pairs(map or {}) do
        self[k] = v
    end
end

function Node:setExt(ext)
    self.ext = ext
    return self
end

function Graphic:__init__(w, h)
    self._w = w or 500
    self._h = h or 500
    self._children = {}
    self._code = ""
end

function Graphic:setStyle(color, size)
    color = color or "#eeeeee"
    size = size or 10
    table.insert(self._children, Node(TYPES.STYLE):setExt({color, size}))
    return self
end

function Graphic:setXY(x, y)
    x = x or 0
    y = y or 0
    table.insert(self._children, Node(TYPES.POSITION):setExt({x, y}))
    return self
end

function Graphic:setWH(w, h)
    w = w or 0
    h = h or 0
    table.insert(self._children, Node(TYPES.SIZE):setExt({w, h}))
    return self
end

function Graphic:addText(text, size, font)
    text = text or "Text..."
    size = size or 13
    font = font or "Microsoft Sans Serif"
    table.insert(self._children, Node(TYPES.TEXT):setExt({text, size, font}))
    return self._children[#self._children]
end

function Graphic:addImage(path, fromX, fromY, fromW, fromH)
    path = path or ""
    fromX = fromX or 0
    fromY = fromY or 0
    fromW = fromW or 250
    fromH = fromH or 250
    table.insert(self._children, Node(TYPES.IMAGE):setExt({path, fromX, fromY, fromW, fromH}))
    return self._children[#self._children]
end

function Graphic:addEllipse()
    table.insert(self._children, Node(TYPES.ELLIPSE))
    return self._children[#self._children]
end

function Graphic:addRectangle()
    table.insert(self._children, Node(TYPES.RECTANGLE))
    return self._children[#self._children]
end

function Graphic:addLine(point1, point2, ...)
    local points = {point1, point2, ...}
    points = #points > 0 and points or {{100, 100}, {100, 200}, {200, 200}}
    table.insert(self._children, Node(TYPES.LINE):setExt(points))
    return self._children[#self._children]
end

function Graphic:addCurve(point1, point2, ...)
    local points = {point1, point2, ...}
    points = #points > 0 and points or {{100, 100}, {100, 200}, {200, 200}}
    table.insert(self._children, Node(TYPES.CURVE):setExt(points))
    return self._children[#self._children]
end

function Graphic:addBezier(start, cPointA1, cPointB1, end1, ...)
    local points = {start, cPointA1, cPointB1, end1, ...}
    points = #points > 0 and points or {{10, 10}, {100, 100}, {200, 10}, {200, 200}}
    table.insert(self._children, Node(TYPES.BEZIER):setExt(points))
    return self._children[#self._children]
end

function Graphic:addPie(fromR, toR)
    table.insert(self._children, Node(TYPES.PIE):setExt({fromR or 0, toR or 270}))
    return self._children[#self._children]
end

function Graphic:addArc(fromR, toR)
    table.insert(self._children, Node(TYPES.ARC):setExt({fromR or 0, toR or 270}))
    return self._children[#self._children]
end

function Graphic:addPolygon(point1, point2, ...)
    local points = {point1, point2, ...}
    points = #points > 0 and points or {{50, 50}, {50, 100}, {100, 100}}
    table.insert(self._children, Node(TYPES.POLYGON):setExt(points))
    return self._children[#self._children]
end

function Graphic:_formatPoints(points)
    local names, bodies = "", ""
    for index,item in ipairs(points) do
        names = names .. string.format("$p%d", index) .. (index ~= #points and "," or "")
        bodies = bodies .. string.format("$p%s = new-object Drawing.Point %d, %d;", index, item[1], item[2])
    end
    return names, bodies
end

function Graphic:_processChild(i, v)
    if v.tp == TYPES.STYLE then
        self._code = self._code .. string.format(GRAPHIC_STYLE, v.ext[1], v.ext[1], v.ext[2])
    elseif v.tp == TYPES.POSITION then
        self._code = self._code .. string.format(GRAPHIC_POSITION, v.ext[1], v.ext[2])
    elseif v.tp == TYPES.SIZE then
        self._code = self._code .. string.format(GRAPHIC_SIZE, v.ext[1], v.ext[2])
    elseif v.tp == TYPES.TEXT then
        self._code = self._code .. string.format(DIALOG_TEXT, v.ext[3], v.ext[2], v.ext[1])
    elseif v.tp == TYPES.IMAGE then
        self._code = self._code .. string.format(DIALOG_IMAGE, v.ext[1], v.ext[2], v.ext[3], v.ext[4], v.ext[5])
    elseif v.tp == TYPES.ELLIPSE then
        self._code = self._code .. string.format(DIALOG_ELLIPSE)
    elseif v.tp == TYPES.RECTANGLE then
        self._code = self._code .. string.format(DIALOG_RECTANGLE)
    elseif v.tp == TYPES.LINE then
        local names, bodies = self:_formatPoints(v.ext)
        self._code = self._code .. string.format(DIALOG_LINE, bodies, names)
    elseif v.tp == TYPES.CURVE then
        local names, bodies = self:_formatPoints(v.ext)
        self._code = self._code .. string.format(DIALOG_CURVE, bodies, names)
    elseif v.tp == TYPES.BEZIER then
        local names, bodies = self:_formatPoints(v.ext)
        self._code = self._code .. string.format(DIALOG_BEZIER, bodies, names)
    elseif v.tp == TYPES.PIE then
        self._code = self._code .. string.format(DIALOG_PIE, v.ext[1], v.ext[2])
    elseif v.tp == TYPES.ARC then
        self._code = self._code .. string.format(DIALOG_ARC, v.ext[1], v.ext[2])
    elseif v.tp == TYPES.POLYGON then
        local names, bodies = self:_formatPoints(v.ext)
        self._code = self._code .. string.format(DIALOG_POLYGON, bodies, names)
    end
end

function Graphic:_processStart()
    for i,v in ipairs(self._children) do
        self:_processChild(i, v)
    end
end

function Graphic:_processEnd()
    files.write("running.ps1", self._code)
    local isOk, r = tools.execute([[ powershell.exe -file ./running.ps1]])
    assert(isOk, 'powershell execute failed:' .. r)
    files.delete("running.ps1")
end

function Graphic:show(title, icon)
    title = title or "Title..."
    icon = icon or "./others/test.ico"
    self._code = self._code .. HIDE_CONSOLE
    self._code = self._code .. COMMON_HEADER
    self._code = self._code .. string.format(FORM_CREATE, self._w, self._h)
    self:_processStart()
    self._code = self._code .. string.format(FORM_SHOW, icon, title)
    self:_processEnd()
end

function Graphic:save(path)
    path = path or "./screenshot.png"
    self._code = self._code .. COMMON_HEADER
    self._code = self._code .. string.format(IMAGE_CREATE, self._w, self._h)
    self:_processStart()
    self._code = self._code .. string.format(IMAGE_SAVE, path)
    self:_processEnd()
end

local graphic = Graphic()
graphic:setXY(0, 0):setWH(500, 500):setStyle("#222222"):addRectangle()
graphic:setXY(250, 50):setWH(200, 200):addImage("./others/yellow.png", 75, 75, 350, 350)
graphic:setXY(25, 275):setWH(350, 350):addImage("./others/test.png", nil, nil, nil, nil)
graphic:setXY(25, 150):setStyle("#ff0000"):addText("Text...", 48, nil)
-- graphic:setStyle("#2255ff"):addLine()
-- graphic:setStyle("#2255ff"):addCurve()
-- graphic:setStyle("#2255ff"):addBezier()
-- graphic:addEllipse()
-- graphic:addPie()
-- graphic:addArc()
graphic:setStyle("#00ff00"):addPolygon()
-- graphic:show()
graphic:save()
