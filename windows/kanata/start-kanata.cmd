@echo off
cd /d "%~dp0"
taskkill /f /im kanata_windows_gui_winIOv2_x64.exe >nul 2>&1
start "" kanata_windows_gui_winIOv2_x64.exe -c "%~dp0kanata.kbd"
