param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectDir
)

$shortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "Death's Decree.lnk"
$targetPath = Join-Path $ProjectDir "Play_Game.bat"

if (-not (Test-Path $targetPath)) {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show("Cannot find Play_Game.bat.", "Death's Decree")
    exit 1
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.WorkingDirectory = $ProjectDir
$shortcut.IconLocation = "$env:SystemRoot\System32\shell32.dll,167"
$shortcut.Description = "Play Death's Decree"
$shortcut.Hotkey = "CTRL+ALT+D"
$shortcut.Save()

Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show("Desktop shortcut created. Hotkey: Ctrl + Alt + D.", "Death's Decree")
