@echo off
setlocal
:: gut - Windows wrapper script
:: This script forwards all commands to the gut Bash script.
:: It requires Git for Windows (which provides bash.exe) to be installed.

:: Find the directory where this .cmd file is located
set "GUT_HOME=%~dp0.."

:: Run the gut bash script
bash "%GUT_HOME%\bin\gut" %*
endlocal
