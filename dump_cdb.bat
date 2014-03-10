set version=%1
REM set _NT_SYMBOL_PATH=srv*e:\document\symcache
set _NT_SYMBOL_PATH=srv*e:\document\symcache*\\192.168.1.90\pdbarchive
for /r ../%version% %%i in (*.zip) do if not exist "%%i.txt" del crash_dump.dmp && unzip -o "%%i" -d ../%version%/ && cdb -z ../%version%/crash_dump.dmp -logo "%%i.txt" -lines -c "!analyze -v;q" 
REM for /r ../%version% %%i in (*.zip) do if not exist "%%i.txt" del crash_dump.dmp && unzip -o "%%i" -d ../%version%/