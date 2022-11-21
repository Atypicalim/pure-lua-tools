--[[
    dialog
]]

assert(Dialog == nil)
Dialog = class("Log")

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
$form.StartPosition = '%s'
$icon = New-Object system.drawing.icon ("%s")
$form.Icon = $icon
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
$listBox.Size = New-Object System.Drawing.Size(%d,%d)
$listBox.Height = %d
%s
$form.Controls.Add($listBox)
]]


local DIALOG_IMAGE = [[
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

local DIALOG_FOOTER = [[
$form.ShowDialog()
]]

function Dialog:__init__(width, height, title, background, position, icon)
    self._code = DIALOG_HEADER;
    width = width or 500
    height = height or 500
    title = title or 'Unknown'
    background = background or "#ffffff"
    position = position or "CenterScreen"
    icon = icon or "E:/OTHERS/Lua/pure-lua-tools/others/test.ico"
    self._code = self._code .. string.format(DIALOG_CREATE, width, height, title, background, position, icon);

end

function Dialog:addText(text, x, y, size, font)
    text = text or "Text..."
    x = x or 0
    y = y or 0
    size = size or 13
    font = font or "Microsoft Sans Serif"
    self._code = self._code .. string.format(DIALOG_TEXT, text, x, y, font, size);
end

function Dialog:addInput(text, x, y, length, size, font)
    text = text or "Input..."
    x = x or 0
    y = y or 50
    length = length or 150
    size = size or 26
    font = font or "Microsoft Sans Serif"
    self._code = self._code .. string.format(DIALOG_INPUT, text, x, y, font, size, length);
end

function Dialog:addButton(text, x, y, w, h, flag)
    local ext = ""
    local txt = "Button"
    if flag == 1 then
        ext = DIALOG_BUTTON_EXT_OK
        txt= "Ok"
    elseif flag == -1 then
        ext = DIALOG_BUTTON_EXT_NO
        txt= "No"
    end
    text = text or txt
    x = x or 0
    y = y or 125
    w = w or 75
    h = h or 25
    self._code = self._code .. string.format(DIALOG_BUTTON, text, x, y, w, h, ext);
end

function Dialog:addList(x, y, w, h, height, items)
    x = x or 0
    y = y or 175
    w = w or 75
    h = h or 25
    height = height or 100
    items = items or {1, 2, 3, 4, 5, 6, 7, 8, 9, 0}
    local list = ""
    for i,v in ipairs(items) do
        list = list .. string.format([[$listBox.Items.Add('%s');]], v)
    end
    self._code = self._code .. string.format(DIALOG_LIST, x, y, w, h, height, list);
end

function Dialog:addImage(path, x, y, w, h, mode, background)
    path = path or "E:/OTHERS/Lua/pure-lua-tools/others/test.png"
    x = x or 0
    y = y or 300
    w = w or 1
    h = h or 1
    local with = w > 1 and tostring(w) or "$img.Size.Width * " .. tostring(w)
    local height = h > 1 and tostring(h) or "$img.Size.Height * " .. tostring(h)
    mode = mode or "Normal" -- AutoSize, CenterImage, StretchImage, Zoom
    background = background or "#333333"
    self._code = self._code .. string.format(DIALOG_IMAGE, path, x, y, with, height, mode, background);
end

function Dialog:show()
    self._code = self._code .. string.format(DIALOG_FOOTER)
    files.write("running.ps1", self._code)
    print(self._code)
    local isOk, r = tools.execute([[ powershell.exe -file ./running.ps1]])
    assert(isOk, 'powershell execute failed:' .. r)
end

-- dialog = Dialog()
-- dialog:addText()
-- dialog:addInput()
-- dialog:addButton()
-- dialog:addList()
-- dialog:addImage()
-- dialog:show()

-- # .Net methods for hiding/showing the console in the background
-- Add-Type -Name Window -Namespace Console -MemberDefinition '
-- [DllImport("Kernel32.dll")]
-- public static extern IntPtr GetConsoleWindow();
-- [DllImport("user32.dll")]
-- public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
-- '
-- $consolePtr = [Console.Window]::GetConsoleWindow()
-- [Console.Window]::ShowWindow($consolePtr, 0) # hide:0, show:5


-- [reflection.assembly]::LoadWithPartialName( "System.Windows.Forms")
-- [reflection.assembly]::LoadWithPartialName( "System.Drawing")
-- $myBrush = new-object Drawing.SolidBrush green
-- $mypen = new-object Drawing.Pen black
-- $mypen.color = "red" # Set the pen color
-- $mypen.width = 5     # ste the pen line width
-- $rect = new-object Drawing.Rectangle 10, 10, 180, 180

-- $form = New-Object Windows.Forms.Form
-- $formGraphics = $form.createGraphics()
-- $form.add_paint({
--     $formGraphics.FillEllipse($myBrush, $rect) # draw an ellipse using rectangle object
--     $formGraphics.DrawLine($mypen, 10, 10, 190, 190) # draw a line
--     $formGraphics.DrawLine($mypen, 190, 10, 10, 190) # draw a line
-- })
-- $form.ShowDialog()
