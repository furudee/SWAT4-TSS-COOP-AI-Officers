@echo off 
REM Tell the user that we are compiling the mod 
echo Compiling source code for mod 
REM Run UCC.exe from inside <MOD_DIR>\System, so that the 
REM compiler uses the mod's initialisation files and settings 
REM and stores the compiled output in the <MOD_DIR>\System 
REM directory 
cd .\System\ 
..\..\ContentExpansion\System\UCC.exe make -nobind -all
REM Tell the user that the game has exited, and wait for a keypress 
cd ..
echo Finished compiling mod 
PAUSE 