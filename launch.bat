@echo off 
REM Tell the user that we are running the mod 
echo Launching SWAT 4 - COOP AI Officers EXP 
echo.
echo This window will close in 5 seconds...
REM Run Swat4.exe from inside <MOD_DIR>\System, so that the 
REM game uses the mod's initialisation files and settings 
cd .\System\
start "" "..\..\ContentExpansion\System\Swat4X.exe"  -nointro
timeout /t 5 /nobreak > NUL
REM Tell the user that the game has exited 
echo mod has exited 