@echo off
setlocal
cd /d "%~dp0"
start "Crimson Sparrow" "%~dp0runtime\godot.exe" --path "%~dp0game"
