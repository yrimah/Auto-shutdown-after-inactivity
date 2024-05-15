Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File C:\scripted_trackabi\script.ps1", 0
Set objShell = Nothing