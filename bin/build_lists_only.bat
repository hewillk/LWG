@echo off
bin\lists
if errorlevel 1 goto error
mailing\sg3-active.html
goto done

:error
echo ***********************************
echo ********** build failure **********
echo ***********************************

:done

