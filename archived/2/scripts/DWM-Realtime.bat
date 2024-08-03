@echo off
start "" "C:\Windows\System32\dwm.exe"
wmic process where name="dwm.exe" CALL setpriority "realtime"

