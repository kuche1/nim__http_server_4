@echo off
:inf
cls
nim c -r --threads:on example.nim
echo.
pause
goto inf