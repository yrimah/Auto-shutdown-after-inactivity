## Check Execution Policy before running the script
#  run : Set-ExecutionPolicy RemoteSigned : to run powershell scripts created just locally
#  run : Set-ExecutionPolicy Unrestricted : to run also the scripts downloaded from the internet

Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class UserInput1
    {
        [DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
        public static extern short GetAsyncKeyState(int virtualKeyCode);

        [DllImport("user32.dll", SetLastError=true)]
        public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        [StructLayout(LayoutKind.Sequential)]
        public struct LASTINPUTINFO
        {
            public uint cbSize;
            public uint dwTime;
        }

        public static TimeSpan GetIdleTime()
        {
            LASTINPUTINFO lastInputInfo = new LASTINPUTINFO();
            lastInputInfo.cbSize = (uint)Marshal.SizeOf(lastInputInfo);
            if (!GetLastInputInfo(ref lastInputInfo))
            {
                throw new Exception("GetLastInputInfo failed");
            }
            return TimeSpan.FromMilliseconds(Environment.TickCount - lastInputInfo.dwTime);
        }
    }
"@

$idleDuration = New-TimeSpan -Minutes 7200

$appName = "Trackabi Timer"

while($true)
{
    $idleTime = [UserInput1]::GetIdleTime()

    if ($idleTime -ge $idleDuration)
    {
        Stop-Process -Name $appName
        Stop-Computer -Force
        break
    }
    Start-Sleep -Seconds 60
}

## test ##

# trackabi timer before 5min #
# 3h32
# trackabi timer second day #
# 3h32 and reset timer for today #