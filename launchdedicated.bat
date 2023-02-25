@echo off
echo Launching Dedicated Server
echo.
echo This window will close in 5 seconds...
cd .\System\
start "" "..\..\ContentExpansion\System\Swat4XDedicatedServer.exe"
timeout /t 5 /nobreak > NUL

