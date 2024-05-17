Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class UserInput
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

# Configuration
$idleDuration = New-TimeSpan -Seconds 5 # -Minutes 1
$shutdownDuration = New-TimeSpan -Hours 1 -Minutes 1 -Seconds 1
$appName = "Trackabi Timer"
$appPath = "C:\Users\Electro Ragragui\AppData\Local\Programs\trackabi.timer\Trackabi Timer.exe"  # Update this to the actual path of the application
$emailTo = "rimahyassine.pro@gmail.com"  # Update this to the actual recipient email address
$emailFrom = "rimahyassine2002@gmail.com"  # Update this to your Gmail address
$emailPassword = "..."  # Update this to your Gmail password or App Password
$smtpServer = "smtp.gmail.com"
$smtpPort = "587"

# Function to send email
function Send-Email($subject, $body) {
    $securePassword = ConvertTo-SecureString $emailPassword -AsPlainText -Force

    $message = New-Object System.Net.Mail.MailMessage
    $message.From = $emailFrom
    $message.To.Add($emailTo)
    $message.Subject = $subject
    $message.Body = $body

    $smtp = New-Object Net.Mail.SmtpClient($smtpServer, $smtpPort)
    $smtp.EnableSsl = $true
    $smtp.Credentials = New-Object System.Net.NetworkCredential($emailFrom, $securePassword)
    $smtp.Send($message)
}

# Function to start the application with retry logic
function Start-AppWithRetry($retries) {
    for ($i = 1; $i -le $retries; $i++) {
        try {
            Start-Process -FilePath $appPath
            return $true
        } catch {
            Start-Sleep -Seconds 2
        }
    }
    Send-Email -subject "Application Start Failure" -body "The application $appName failed to start after $retries retries."
    return $false
}

# Function to stop the application and ensure it is completely closed
function Stop-App($appName) {
    $processes = Get-Process -Name $appName -ErrorAction SilentlyContinue
    if ($processes) {
        foreach ($process in $processes) {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        }
    }
}

function Lock-Workstation {
    rundll32.exe user32.dll,LockWorkStation
}

# Main loop
$initialIdle = [UserInput]::GetIdleTime()
$lastActive = [DateTime]::Now

while ($true) {
    $idleTime = [UserInput]::GetIdleTime()
    
    Write-Host "Idle time $idleTime"

    if ($idleTime -ge $idleDuration) {
        # User inactive for 1 minute
        Stop-App -appName $appName
        Lock-Workstation

        # Check for long inactivity for shutdown
        if ([DateTime]::Now - $lastActive -ge $shutdownDuration) {
            # Stop-Computer -Force
            break
        }
    } else {
        # User is active
        $lastActive = [DateTime]::Now

        # Check if the application is running, if not, start it
        if (-not (Get-Process -Name $appName -ErrorAction SilentlyContinue)) {
            Start-AppWithRetry -retries 3
        }
    }
    
    Start-Sleep -Seconds 1
}
