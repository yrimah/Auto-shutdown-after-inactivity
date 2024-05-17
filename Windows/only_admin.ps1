# Configuration
$adminPassword = "mypass"  # Specify the password for the admin
$batchFile = "C:\Users\Public\prompt.bat"

# Create a batch file with the password check logic
$batchContent = @"
@echo off
echo The application failed to start and email notification failed. Contact the admin immediately.

:retry
set /p pw=Enter password to close: 
if "%pw%"=="$adminPassword" (
    exit
) else (
    echo Incorrect password. Please try again.
    goto retry
)
"@

# Write the batch content to a file
Set-Content -Path $batchFile -Value $batchContent

# Function to set a window always on top and maximize it
function Set-WindowAlwaysOnTop {
    param (
        [Parameter(Mandatory = $true)]
        [System.Diagnostics.Process] $process
    )

    Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        public class User32 {
            [DllImport("user32.dll")]
            [return: MarshalAs(UnmanagedType.Bool)]
            public static extern bool SetForegroundWindow(IntPtr hWnd);

            [DllImport("user32.dll")]
            public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);

            [DllImport("user32.dll")]
            public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

            [DllImport("user32.dll")]
            public static extern bool IsWindowVisible(IntPtr hWnd);

            public static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
            public static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
            public const uint SWP_NOSIZE = 0x0001;
            public const uint SWP_NOMOVE = 0x0002;
            public const int SW_SHOWMAXIMIZED = 3;
            public const int SW_RESTORE = 9;
        }
"@

    $handle = $process.MainWindowHandle
    while (-not [User32]::IsWindowVisible($handle)) {
        Start-Sleep -Milliseconds 100
    }
    [User32]::SetForegroundWindow($handle)
    [User32]::ShowWindowAsync($handle, [User32]::SW_SHOWMAXIMIZED)
    [User32]::SetWindowPos($handle, [User32]::HWND_TOPMOST, 0, 0, 0, 0, [User32]::SWP_NOSIZE -bor [User32]::SWP_NOMOVE)
}

# Function to ensure the window remains on top and maximized
function Ensure-WindowOnTop {
    param (
        [Parameter(Mandatory = $true)]
        [System.Diagnostics.Process] $process
    )

    Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        public class User32 {
            [DllImport("user32.dll")]
            [return: MarshalAs(UnmanagedType.Bool)]
            public static extern bool SetForegroundWindow(IntPtr hWnd);

            [DllImport("user32.dll")]
            public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);

            [DllImport("user32.dll")]
            public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

            [DllImport("user32.dll")]
            public static extern bool IsIconic(IntPtr hWnd);

            [DllImport("user32.dll")]
            public static extern bool IsZoomed(IntPtr hWnd);

            public static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
            public static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
            public const uint SWP_NOSIZE = 0x0001;
            public const uint SWP_NOMOVE = 0x0002;
            public const int SW_SHOWMAXIMIZED = 3;
            public const int SW_RESTORE = 9;
        }
"@

    $handle = $process.MainWindowHandle
    while ($true) {
        Start-Sleep -Milliseconds 100
        if ([User32]::IsIconic($handle)) {
            [User32]::ShowWindowAsync($handle, [User32]::SW_RESTORE)
        }
        if (-not [User32]::IsZoomed($handle)) {
            [User32]::ShowWindowAsync($handle, [User32]::SW_SHOWMAXIMIZED)
        }
        [User32]::SetForegroundWindow($handle)
        [User32]::SetWindowPos($handle, [User32]::HWND_TOPMOST, 0, 0, 0, 0, [User32]::SWP_NOSIZE -bor [User32]::SWP_NOMOVE)
    }
}

# Function to notify the user to contact the admin
function Notify-Admin {
    while ($true) {
        $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/k", $batchFile -PassThru
        Start-Sleep -Seconds 1  # Give the process some time to start
        Set-WindowAlwaysOnTop -process $process
        Start-Job -ScriptBlock { param($p) Ensure-WindowOnTop -process $p } -ArgumentList $process
        $process.WaitForExit()

        # Check if the process was terminated improperly (e.g., by Ctrl+C or exit command)
        if ($process.ExitCode -ne 0) {
            Write-Host "The Command Prompt was closed improperly. Restarting..."
        } else {
            break  # Exit the loop if the process exited correctly with the password
        }
    }
}

# Trigger the Notify-Admin function for testing
Notify-Admin
