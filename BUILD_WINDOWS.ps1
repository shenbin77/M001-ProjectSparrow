$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$target = Join-Path $PSScriptRoot 'builds\Windows-0.2.0-dev'
New-Item -ItemType Directory -Force $target | Out-Null
$log = & .\runtime\godot_console.exe --headless --path game --export-release 'Windows Desktop' "$target\CrimsonSparrow.exe" 2>&1
$code = $LASTEXITCODE
$log | Set-Content work\windows-export.log
if ($code -ne 0 -or ($log -join "`n") -match 'SCRIPT ERROR|Parse Error|Export failed') { throw 'Windows export failed; inspect work/windows-export.log' }
foreach ($directory in @('backend','vendor','data')) {
    if (Test-Path "$target\$directory") { throw "Output $directory already exists: use a fresh version directory or back it up before rebuilding" }
    Copy-Item $directory $target -Recurse
}
New-Item -ItemType Directory -Force "$target\runtime" | Out-Null
Copy-Item runtime\node.exe,runtime\NODE_LICENSE.txt "$target\runtime"
Copy-Item runtime\GODOT_LICENSE.txt,runtime\GODOT_COPYRIGHT.txt $target
Copy-Item runtime\godot_console.exe "$target\CrimsonSparrow_console.exe"
Copy-Item README.md "$target\README.md"
$smoke = & "$target\CrimsonSparrow_console.exe" --headless --quit-after 1200 -- --smoke 2>&1
$code = $LASTEXITCODE
$smoke | Set-Content work\windows-export-smoke.log
if ($code -ne 0 -or ($smoke -join "`n") -notmatch 'GODOT_SMOKE_PASS:') { throw 'Exported runtime smoke failed' }
Get-ChildItem $target -Recurse -File | ForEach-Object { '{0}  {1}' -f (Get-FileHash $_.FullName -Algorithm SHA256).Hash,$_.FullName.Substring($target.Length+1) } | Set-Content "$target\SHA256SUMS.txt"
Write-Host "WINDOWS_EXPORT_VERIFIED $target (development build, not RC)"
