param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectDir
)

$ErrorActionPreference = "SilentlyContinue"

$LogFile = Join-Path $ProjectDir "launch_log.txt"
Set-Content -Path $LogFile -Value "Starting Death's Decree launcher..." -Encoding UTF8

function Write-Log {
    param([string]$Text)
    Add-Content -Path $LogFile -Value $Text -Encoding UTF8
}

function Find-Godot {
    $localCandidates = @(
        (Join-Path $ProjectDir "Godot.exe"),
        (Join-Path $ProjectDir "Godot_v4.2-stable_win64.exe"),
        (Join-Path $ProjectDir "Godot_v4.3-stable_win64.exe"),
        (Join-Path $ProjectDir "Godot_v4.4-stable_win64.exe"),
        (Join-Path $ProjectDir "Godot_v4.5-stable_win64.exe")
    )

    foreach ($candidate in $localCandidates) {
        if (Test-Path $candidate) {
            Write-Log "Found Godot beside project: $candidate"
            return $candidate
        }
    }

    $command = Get-Command godot -ErrorAction SilentlyContinue
    if ($command) {
        Write-Log "Found Godot from PATH: $($command.Source)"
        return $command.Source
    }

    $programFilesX86 = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)")
    $commonCandidates = @(
        "$env:ProgramFiles\Godot\Godot.exe",
        "$programFilesX86\Godot\Godot.exe",
        "$env:LOCALAPPDATA\Programs\Godot\Godot.exe",
        "$env:USERPROFILE\Desktop\Godot.exe",
        "$env:USERPROFILE\Downloads\Godot.exe"
    )

    foreach ($candidate in $commonCandidates) {
        if ($candidate -and (Test-Path $candidate)) {
            Write-Log "Found Godot in common path: $candidate"
            return $candidate
        }
    }

    Write-Log "Godot was not found in project folder, PATH, or common install paths."
    return $null
}

$projectFile = Join-Path $ProjectDir "project.godot"
if (-not (Test-Path $projectFile)) {
    Write-Log "Missing project.godot at: $projectFile"
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show("Cannot find project.godot in this folder.", "Death's Decree")
    exit 1
}

$godot = Find-Godot
if (-not $godot) {
    $webGame = Join-Path $ProjectDir "play_web.html"
    if (Test-Path $webGame) {
        Write-Log "Godot was not found. Opening browser fallback: $webGame"
        $webUri = ([System.Uri]$webGame).AbsoluteUri
        Start-Process -FilePath $webUri
        exit 0
    }

    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show("Godot was not found, and play_web.html is missing.", "Death's Decree")
    exit 1
}

Write-Log "Launching: $godot --path $ProjectDir"
Start-Process -FilePath $godot -ArgumentList @("--path", $ProjectDir) -WorkingDirectory $ProjectDir
Write-Log "Launch command sent."
