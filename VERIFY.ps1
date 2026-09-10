$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
& .\runtime\node.exe --test tests\adapter.test.cjs tests\data.test.cjs
if ($LASTEXITCODE -ne 0) { throw 'Rule adapter tests failed' }
& .\runtime\godot_console.exe --headless --path game --script res://test_career.gd
if ($LASTEXITCODE -ne 0) { throw 'Career tests failed' }
$smoke = & .\runtime\godot_console.exe --headless --path game --quit-after 1200 -- --smoke 2>&1
$smoke | Write-Host
if ($LASTEXITCODE -ne 0 -or ($smoke -join "`n") -notmatch 'GODOT_SMOKE_PASS:') { throw 'Godot smoke failed or timed out' }
Write-Host 'ALL_CHECKPOINT_TESTS_PASSED (not a Release Candidate gate)'
