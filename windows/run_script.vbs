Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File C:\scripted_trackabi\script.ps1", 0
Set objShell = Nothing

' start time of test : 11:38
' expected end time of test 13:38
' with timer stoped after 5min at 30:16 