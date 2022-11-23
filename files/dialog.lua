--[[
    dialog
]]

dialog = dialog or {}

local POWERSHELL = [[

param(
[string]$funcName,
[string]$arg1,
[string]$arg2,
[string]$arg3,
[string]$arg4,
[string]$arg5
)

Function return_result([string]$result) {
    Write-Host "[result[$result]result]"
}

Function select_file($windowTitle, $filterDesc, $startFolder) {
    Add-Type -AssemblyName System.Windows.Forms
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = $windowTitle
    $OpenFileDialog.InitialDirectory = $startFolder
    $OpenFileDialog.filter = $filterDesc
    If ($OpenFileDialog.ShowDialog() -eq "Cancel") {
        return_result ""
    } Else {
        return_result $OpenFileDialog.FileName
    }
}

function select_save($windowTitle, $filterDesc, $startFolder) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $OpenFileDialog.Title = $windowTitle
    $OpenFileDialog.initialDirectory = $startFolder
    $OpenFileDialog.filter = $filterDesc
    $OpenFileDialog.ShowDialog() |  Out-Null
    return_result $OpenFileDialog.filename
}

Function select_folder($windowTitle, $startFolder) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = $windowTitle
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $startFolder
    If ($foldername.ShowDialog() -eq "OK") {
        return_result $foldername.SelectedPath
    } else {
        return_result ""
    }
}

function select_color() {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.AnyColor = $true
    if ($dialog.ShowDialog() -eq "OK") {
        return_result "$($dialog.Color.R),$($dialog.Color.G),$($dialog.Color.B)"
    } Else {
        return_result ""
    }
}
    
Function show_confirm($title, $message, $flag) {
    Add-Type -AssemblyName Microsoft.VisualBasic
    $result = [Microsoft.VisualBasic.Interaction]::MsgBox($message, $flag, $title)
    return_result $result
}

Function show_input($title, $message, $default) {
    Add-Type -AssemblyName Microsoft.VisualBasic
    $result = [Microsoft.VisualBasic.Interaction]::InputBox($message, $title, $default)
    return_result $result
}

& $funcName $arg1 $arg2 $arg3 $arg4 $arg5

]]

local function dialog_execute_powershell(func, ...)
    assert(tools.is_windows(), 'platform not supported!')
    files.write("./running.ps1", POWERSHELL)
    local cmd = func
    local agrs = {...}
    for i,v in ipairs(agrs) do
        cmd = cmd .. [[ "]] .. tostring(v) .. [["]]
    end
    local isOk, r = tools.execute([[ powershell.exe -file ./running.ps1 ]] .. cmd)
    files.delete("running.ps1")
    assert(isOk, 'powershell execute failed:' .. cmd)
    return r:match(".*%[result%[(.*)%]result%].*")
end

local function dialog_validate_folder(folder)
    folder = folder:gsub('/', '\\')
    if folder:sub(-1, -1) == '\\' then
        folder = folder:sub(1, -2)
    end
    folder = folder:gsub('\\\\', '\\')
    return folder
end

function dialog.select_file(title, filter, folder)
    title = title or "please select a file ..."
    filter = filter or "All files (*.*)|*.*"
    folder = folder or ""
    print(dialog_validate_folder(folder))
    local path = dialog_execute_powershell("select_file", title, filter, dialog_validate_folder(folder))
    if string.valid(path) then
        return path
    end
end

function dialog.select_folder(title, folder)
    title = title or "please select a folder ..."
    folder = folder or ""
    local path = dialog_execute_powershell("select_folder", title, dialog_validate_folder(folder))
    if string.valid(path) then
        return path
    end
end

function dialog.select_save(title, filter, folder)
    title = title or "please save a file ..."
    filter = filter or "All files (*.*)|*.*"
    folder = folder or ""
    local path = dialog_execute_powershell("select_save", title, filter, dialog_validate_folder(folder))
    if string.valid(path) then
        return path
    end
end

function dialog.select_color()
    local color = dialog_execute_powershell("select_color")
    if string.valid(color) then
        local t = string.explode(color, ",")
        local r, g, b = tonumber(t[1]), tonumber(t[2]), tonumber(t[3])
        return r, g, b
    end
end

function dialog.show_confirm(title, message, flag)
    title = title or "title..."
    message = message or "confirm..."
    flag = flag or "YesNoCancel" -- YesNoCancel, YesNo, OkCancel, OKOnly, Critical, Question, Exclamation, Information
    local r = dialog_execute_powershell("show_confirm", title, message, flag)
    if r == "Yes" or r == "Ok" then return true end
    if r == "No" then return false end
    return nil
end

function dialog.show_input(title, message, default)
    title = title or "title..."
    message = message or "input..."
    default = default or ""
    local result = dialog_execute_powershell("show_input", title, message, default)
    if string.valid(result) then
        return result
    end
end
