--[[
    dialog
]]

assert(Dialog == nil)
Dialog = class("Log")
local Node = class("Node")

local DIALOG_HEADER = [[
[reflection.assembly]::LoadWithPartialName( "System.Windows.Forms");
[reflection.assembly]::LoadWithPartialName( "System.Drawing");
[System.Windows.Forms.Application]::EnableVisualStyles();
]]

local DIALOG_CREATE = [[
$form = New-Object Windows.Forms.Form
$form.ClientSize         = '%d,%d'
$form.text               = "%s"
$form.BackColor          = "%s"
$form.StartPosition = 'CenterScreen'
$icon = New-Object system.drawing.icon ("%s")
$form.Icon = $icon
$graphics = $form.createGraphics()
$brush = new-object Drawing.SolidBrush "#ffff00"
$pen = new-object Drawing.Pen "#ffff00"
]]

local DIALOG_TEXT = [[
$label = New-Object system.Windows.Forms.Label
$label.text             = "%s"
$label.AutoSize         = $true
$label.width            = 0
$label.height           = 0
$label.location         = New-Object System.Drawing.Point(%d,%d)
$label.Font             = '%s,%d'
$form.controls.add($label)
]]

local DIALOG_INPUT = [[
$input = New-Object Windows.Forms.TextBox
$input.Text = "%s"
$input.Location = New-Object Drawing.Point %d,%d
$input.Font = '%s,%d'
$input.Size = New-Object Drawing.Point %d,0
$form.controls.add($input)
]]

local DIALOG_BUTTON = [[
$button = New-Object System.Windows.Forms.Button
$button.Text = '%s'
$button.Location = New-Object System.Drawing.Point(%d,%d)
$button.Size = New-Object System.Drawing.Size(%d,%d)
%s
$form.Controls.Add($button)
]]

local DIALOG_BUTTON_EXT_OK = [[
$button.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $button
]]
local DIALOG_BUTTON_EXT_NO = [[
$button.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton  = $button
]]

local DIALOG_LIST = [[
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(%d,%d)
$listBox.Width = %d
$listBox.Height = %d
%s
$form.Controls.Add($listBox)
]]


local DIALOG_PICTURE = [[
$file = (get-item '%s')
$img = [System.Drawing.Image]::Fromfile($file);
$picture = new-object Windows.Forms.PictureBox
$picture.Location = New-Object System.Drawing.Size(%d,%d)
$with = [System.Math]::Floor(%s)
$heigth = [System.Math]::Floor(%s)
$picture.Size = New-Object System.Drawing.Size($with, $heigth)
$picture.Image = $img
$picture.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::%s
$picture.BackColor = "%s"
$form.controls.add($picture)
]]

local DIALOG_IMAGE = [[
$form.add_paint({
    $file = (get-item '%s')
    $img = [System.Drawing.Image]::Fromfile($file);
    $units = [System.Drawing.GraphicsUnit]::Pixel
    $dest = new-object Drawing.Rectangle %d, %d, %d, %d
    $src = new-object Drawing.Rectangle %d, %d, %d, %d
    $graphics.DrawImage($img, $dest, $src, $units);
})
]]

local DIALOG_ELLIPSE = [[
$form.add_paint({
    $brush.color = "%s"
    $rect = new-object Drawing.Rectangle %d, %d, %d, %d
    $graphics.FillEllipse($brush, $rect)
})
]]

local DIALOG_RECTANGLE = [[
$form.add_paint({
    $brush.color = "%s"
    $rect = new-object Drawing.Rectangle %d, %d, %d, %d
    $graphics.FillRectangle($brush, $rect)
})
]]

local DIALOG_BEZIER = [[
$form.add_paint({
    $pen.color = "%s"
    $pen.width = %d
    $p = new-object Drawing.Point %d, %d;
    %s
    $points = $p, %s
    $graphics.DrawBeziers($pen, $points)
})
]]

local DIALOG_LINE = [[
$form.add_paint({
    $pen.color = "%s"
    $pen.width = %d
    %s
    $points = %s
    $graphics.DrawLines($pen, $points)
})
]]

local DIALOG_CURVE = [[
$form.add_paint({
    $pen.color = "%s"
    $pen.width = %d
    %s
    $points = %s
    $graphics.DrawCurve($pen, $points)
})
]]

local DIALOG_PIE = [[
$form.add_paint({
    $pen.color = "%s"
    $pen.width = %d
    $graphics.DrawPie($pen, %d, %d, %d, %d, %d, %d)
})
]]

local DIALOG_ARC = [[
$form.add_paint({
    $pen.color = "%s"
    $pen.width = %d
    $graphics.DrawArc($pen, %d, %d, %d, %d, %d, %d)
})
]]

local DIALOG_POLYGON = [[
$form.add_paint({
    $pen.color = "%s"
    $pen.width = %d
    %s
    $points = %s
    $graphics.DrawPolygon($pen, $points)
})
]]

local DIALOG_FOOTER = [[
$form.ShowDialog()
]]

local TYPES = {
    DIALOG = "DIALOG",
    TEXT = "TEXT",
    INPUT = "INPUT",
    BUTTON = "BUTTON",
    LIST = "LIST",
    PICTURE = "PICTURE",
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
    self.w = 100
    self.h = 25
    self.length = 100
    self.background = "#222222"
    self.color = "#cccccc"
    self.text = "Unknown..."
    self.font = "Microsoft Sans Serif"
    self.size = 13
    self.ext = nil
    for k,v in pairs(map or {}) do
        self[k] = v
    end
end

function Node:setXY(x, y)
    self.x = x or self.x
    self.y = y or self.y
    return self
end

function Node:setWH(w, h)
    self.w = w or self.w
    self.h = h or self.h
    return self
end

function Node:setLength(length)
    self.length = lengthh
    return self
end

function Node:setBackground(background)
    self.background = background
    return self
end

function Node:setColor(color)
    self.color = color
    return self
end

function Node:setText(text)
    self.text = text
    return self
end

function Node:setFont(font)
    self.font = font
    return self
end

function Node:setSize(size)
    self.size = size
    return self
end

function Node:setExt(ext)
    self.ext = ext
    return self
end

function Dialog:__init__(title, icon)
    self._children = {}
    self._code = ""
    table.insert(self._children, Node(TYPES.DIALOG):setWH(500, 500):setText("Dialog..."):setExt("./others/test.ico"))
end

function Dialog:addText()
    table.insert(self._children, Node(TYPES.TEXT):setXY(0, 0):setText(text or "Text..."))
    return self._children[#self._children]
end

function Dialog:addInput()
    table.insert(self._children, Node(TYPES.INPUT):setXY(nil, 35):setText(text or "Input..."))
    return self._children[#self._children]
end

function Dialog:addButton(flag)
    local ext = ""
    if flag == 1 then
        ext = DIALOG_BUTTON_EXT_OK
    elseif flag == -1 then
        ext = DIALOG_BUTTON_EXT_NO
    end
    table.insert(self._children, Node(TYPES.BUTTON):setXY(nil, 75):setText("Button..."):setExt(ext))
    return self._children[#self._children]
end

function Dialog:addList(items)
    items = items or {1, 2, 3, 4, 5, 6, 7, 8, 9, 0}
    table.insert(self._children, Node(TYPES.LIST):setXY(nil, 115):setWH(150, 100):setExt(items))
    return self._children[#self._children]
end

function Dialog:addPicture(path, mode)
    path = path or "./others/test.png"
    mode = mode or "Normal" -- AutoSize, CenterImage, StretchImage, Zoom
    table.insert(self._children, Node(TYPES.PICTURE):setXY(nil, 235):setWH(150, 150):setExt({path, mode}))
    return self._children[#self._children]
end

function Dialog:addImage(path, fromX, fromY, fromW, fromH)
    path = path or "./others/yellow.png"
    fromX = fromX or 75
    fromY = fromY or 75
    fromW = fromW or 350
    fromH = fromH or 350
    table.insert(self._children, Node(TYPES.IMAGE):setXY(250, 10):setWH(200, 200):setExt({path, fromX, fromY, fromW, fromH}))
    return self._children[#self._children]
end

function Dialog:addEllipse()
    table.insert(self._children, Node(TYPES.ELLIPSE):setXY(0, 0):setWH(100, 100))
    return self._children[#self._children]
end

function Dialog:addRectangle()
    table.insert(self._children, Node(TYPES.RECTANGLE):setXY(0, 0):setWH(100, 100))
    return self._children[#self._children]
end

function Dialog:addBezier(cPointA1, cPointB1, end1, ...)
    local points = {cPointA1, cPointB1, end1, ...}
    points = #points > 0 and points or {{100, 100}, {200, 10}, {200, 200}}
    table.insert(self._children, Node(TYPES.BEZIER):setXY(0, 0):setExt(points))
    return self._children[#self._children]
end

function Dialog:addLine(point1, point2, ...)
    local points = {point1, point2, ...}
    points = #points > 0 and points or {{100, 100}, {100, 200}, {200, 200}}
    table.insert(self._children, Node(TYPES.LINE):setExt(points))
    return self._children[#self._children]
end

function Dialog:addCurve(point1, point2, ...)
    local points = {point1, point2, ...}
    points = #points > 0 and points or {{100, 100}, {100, 200}, {200, 200}}
    table.insert(self._children, Node(TYPES.CURVE):setExt(points))
    return self._children[#self._children]
end

function Dialog:addPie(fromR, toR)
    table.insert(self._children, Node(TYPES.PIE):setXY(100, 100):setWH(200, 200):setExt({fromR or 0, toR or 270}))
    return self._children[#self._children]
end

function Dialog:addArc(fromR, toR)
    table.insert(self._children, Node(TYPES.ARC):setXY(100, 100):setWH(200, 200):setExt({fromR or 0, toR or 270}))
    return self._children[#self._children]
end

function Dialog:addPolygon(point1, point2, ...)
    local points = {point1, point2, ...}
    points = #points > 0 and points or {{100, 100}, {100, 200}, {200, 200}}
    table.insert(self._children, Node(TYPES.POLYGON):setExt(points))
    return self._children[#self._children]
end

function Dialog:_formatPoints(points)
    local names, bodies = "", ""
    for index,item in ipairs(points) do
        names = names .. string.format("$p%d", index) .. (index ~= #points and "," or "")
        bodies = bodies .. string.format("$p%s = new-object Drawing.Point %d, %d;", index, item[1], item[2])
    end
    return names, bodies
end

function Dialog:_processChild(i, v)
    if v.tp == TYPES.DIALOG then
        self._code = self._code .. string.format(DIALOG_CREATE, v.w, v.h, v.text, v.background, v.ext)
    elseif v.tp == TYPES.TEXT then
        self._code = self._code .. string.format(DIALOG_TEXT, v.text, v.x, v.y, v.font, v.size)
    elseif v.tp == TYPES.INPUT then
        self._code = self._code .. string.format(DIALOG_INPUT, v.text, v.x, v.y, v.font, v.size, v.length)
    elseif v.tp == TYPES.BUTTON then
        self._code = self._code .. string.format(DIALOG_BUTTON, v.text, v.x, v.y, v.w, v.h, v.ext)
    elseif v.tp == TYPES.LIST then
        local items = ""
        for _,item in ipairs(v.ext) do
            items = items .. string.format([[$listBox.Items.Add('%s');]], item)
        end
        self._code = self._code .. string.format(DIALOG_LIST, v.x, v.y, v.w, v.h, items)
    elseif v.tp == TYPES.PICTURE then
        local with = v.w > 1 and tostring(v.w) or "$img.Size.Width * " .. tostring(v.w)
        local height = v.h > 1 and tostring(v.h) or "$img.Size.Height * " .. tostring(v.h)
        self._code = self._code .. string.format(DIALOG_PICTURE, v.ext[1], v.x, v.y, with, height, v.ext[2], v.background)
    elseif v.tp == TYPES.IMAGE then
        self._code = self._code .. string.format(DIALOG_IMAGE, v.ext[1], v.x, v.y, v.w, v.h, v.ext[2], v.ext[3], v.ext[4], v.ext[5])
    elseif v.tp == TYPES.ELLIPSE then
        self._code = self._code .. string.format(DIALOG_ELLIPSE, v.color, v.x, v.y, v.w, v.h)
    elseif v.tp == TYPES.RECTANGLE then
        self._code = self._code .. string.format(DIALOG_RECTANGLE, v.color, v.x, v.y, v.w, v.h)
    elseif v.tp == TYPES.BEZIER then
        local names, bodies = self:_formatPoints(v.ext)
        self._code = self._code .. string.format(DIALOG_BEZIER, v.color, v.size, v.x, v.y, bodies, names)
    elseif v.tp == TYPES.LINE then
        local names, bodies = self:_formatPoints(v.ext)
        self._code = self._code .. string.format(DIALOG_LINE, v.color, v.size, bodies, names)
    elseif v.tp == TYPES.CURVE then
        local names, bodies = self:_formatPoints(v.ext)
        self._code = self._code .. string.format(DIALOG_CURVE, v.color, v.size, bodies, names)
    elseif v.tp == TYPES.PIE then
        self._code = self._code .. string.format(DIALOG_PIE, v.color, v.size, v.x, v.y, v.w, v.h, v.ext[1], v.ext[2])
    elseif v.tp == TYPES.ARC then
        self._code = self._code .. string.format(DIALOG_ARC, v.color, v.size, v.x, v.y, v.w, v.h, v.ext[1], v.ext[2])
    elseif v.tp == TYPES.POLYGON then
        local names, bodies = self:_formatPoints(v.ext)
        self._code = self._code .. string.format(DIALOG_POLYGON, v.color, v.size, bodies, names)
    end
end

function Dialog:show()
    self._code = DIALOG_HEADER;
    for i,v in ipairs(self._children) do
        self:_processChild(i, v)
    end
    self._code = self._code .. string.format(DIALOG_FOOTER)
    files.write("running.ps1", self._code)
    local isOk, r = tools.execute([[ powershell.exe -file ./running.ps1]])
    assert(isOk, 'powershell execute failed:' .. r)
    files.delete("running.ps1")
end

function Dialog:save()
    -- $bmp=new-object System.Drawing.Bitmap 500,500
    -- $graphics=[System.Drawing.Graphics]::FromImage($bmp)
    -- $graphics.Dispose()
    -- $bmp.Save("./screenshot.png")
end

dialog = Dialog()
-- dialog:addText()
-- dialog:addInput()
-- dialog:addButton()
-- dialog:addList()
dialog:addPicture()
dialog:addImage()
-- dialog:addEllipse()
-- dialog:addRectangle():setXY(100, 175)
-- dialog:addBezier()
-- dialog:addLine()
-- dialog:addCurve()
-- dialog:addPie()
-- dialog:addArc()
-- dialog:addPolygon()
dialog:show()

-- # .Net methods for hiding/showing the console in the background
-- Add-Type -Name Window -Namespace Console -MemberDefinition '
-- [DllImport("Kernel32.dll")]
-- public static extern IntPtr GetConsoleWindow();
-- [DllImport("user32.dll")]
-- public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
-- '
-- $consolePtr = [Console.Window]::GetConsoleWindow()
-- [Console.Window]::ShowWindow($consolePtr, 0) # hide:0, show:5

