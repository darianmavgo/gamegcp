<#
.SYNOPSIS
    Troubleshoots and attempts fixes for Xbox Controller streaming on Windows Server 2022 (GCP).
    Run this script as Administrator.

.DESCRIPTION
    This script attempts 10 specific fixes/checks to get the ViGEmBus and Parsec controller streaming working.
    It logs all output to C:\Temp\ControllerFix.log.
#>

$ErrorActionPreference = "Stop"
$LogPath = "C:\Temp\ControllerFix.log"

if (!(Test-Path "C:\Temp")) { New-Item -ItemType Directory -Path "C:\Temp" | Out-Null }
Start-Transcript -Path $LogPath -Append

Write-Host "=================================================================="
Write-Host "  Starting Controller Troubleshooting - $(Get-Date)"
Write-Host "=================================================================="

function Check-And-Fix-Service {
    param ( [string]$ServiceName )
    Write-Host "[-] Checking Service: $ServiceName"
    try {
        $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($svc) {
            if ($svc.Status -ne 'Running') {
                Write-Host "    ! Service is stopped. Attempting to start..."
                Start-Service -Name $ServiceName
                Write-Host "    + Service started."
            } else {
                Write-Host "    * Service is running."
            }
            # Ensure automatic startup
            Set-Service -Name $ServiceName -StartupType Automatic
        } else {
            Write-Host "    ! Service $ServiceName not found (might be normal for this OS version)."
        }
    } catch {
        Write-Host "    ! Error checking service: $_"
    }
}

# FIX 1: Install/Update ViGEmBus
Write-Host "`n[1] Checking ViGEmBus..."
$ViGEmInstalled = Get-WmiObject Win32_InstalledWin32Program | Where-Object { $_.Name -like "*ViGEmBus*" }
if (!$ViGEmInstalled) {
    Write-Host "    ! ViGEmBus not detected. Installing..."
    try {
        # Using winget is often flaky on Server, trying direct download if possible, else falling back to winget
        # Assuming winget is installed per previous instructions.
        winget install ViGEm.ViGEmBus --accept-package-agreements --accept-source-agreements
        Write-Host "    + ViGEmBus install command executed."
    } catch {
        Write-Host "    ! Failed to install ViGEmBus via winget. Please install manually from https://github.com/nefarius/ViGEmBus/releases"
    }
} else {
    Write-Host "    * ViGEmBus is installed."
}

# FIX 2: Ensure Device Association Service is running
# This service is critical for PnP device recognition
Write-Host "`n[2] Checking Device Association Service..."
Check-And-Fix-Service "DeviceAssociationService"

# FIX 3: Ensure Windows Audio Service is running
# Parsec and some controller APIs have dependencies on the Audio subsystem
Write-Host "`n[3] Checking Windows Audio Service..."
Check-And-Fix-Service "Audiosrv"
Check-And-Fix-Service "AudioEndpointBuilder"

# FIX 4: Install/Update Xbox 360 Controller Drivers
# Windows Server often lacks the built-in driver mapping.
Write-Host "`n[4] Checking Xbox 360 Controller Drivers..."
# This is hard to script perfectly without the device present, but we can try to stage the driver.
# A common fix is to ensure the "Xbox 360 Peripherals" driver class is available.
# We will check if the file xusb22.sys exists.
if (Test-Path "C:\Windows\System32\drivers\xusb22.sys") {
    Write-Host "    * xusb22.sys driver file found."
} else {
    Write-Host "    ! xusb22.sys missing. This is common on Server 2022."
    Write-Host "    ! ACTION: You may need to manually install 'Xbox 360 Controller for Windows' driver via Device Manager."
}

# FIX 5: Check Parsec Service
Write-Host "`n[5] Checking Parsec Service..."
Check-And-Fix-Service "Parsec"

# FIX 6: Registry: Enable GameInput Service (if exists)
Write-Host "`n[6] Checking GameInput Service..."
Check-And-Fix-Service "GameInputSvc"

# FIX 7: Disable USB Selective Suspend (Power Settings)
Write-Host "`n[7] Disabling USB Selective Suspend..."
powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2beb146625c 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2beb146625c 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /A
Write-Host "    + Power settings updated."

# FIX 8: Check for 'Unknown Devices' in PnP
Write-Host "`n[8] Checking for Unknown Devices (Potential Controller)..."
$UnknownDevices = Get-PnpDevice | Where-Object { $_.Status -eq 'Error' -or $_.Class -eq 'Unknown' }
if ($UnknownDevices) {
    Write-Host "    ! Found potentially problematic devices:"
    $UnknownDevices | Select-Object FriendlyName, InstanceId, Status | Format-Table
    Write-Host "    ! If you see a device here, right-click it in Device Manager -> Update Driver -> Browse -> Let me pick -> Xbox 360 Peripherals."
} else {
    Write-Host "    * No obvious errored devices found (Note: Controller might not be connected yet)."
}

# FIX 9: Check XboxGipSvc
Write-Host "`n[9] Checking XboxGipSvc..."
Check-And-Fix-Service "XboxGipSvc"

# FIX 10: Verify DirectX (Simple check)
Write-Host "`n[10] Checking DirectX presence..."
if (Test-Path "C:\Windows\System32\xinput1_3.dll") {
    Write-Host "    * XInput1_3.dll found (DirectX likely installed)."
} else {
    Write-Host "    ! XInput1_3.dll missing. Games/Controllers may fail."
    Write-Host "    ! ACTION: Install DirectX End-User Runtimes (June 2010)."
}

Write-Host "`n=================================================================="
Write-Host "  Troubleshooting Complete."
Write-Host "  Please review C:\Temp\ControllerFix.log"
Write-Host "=================================================================="

Stop-Transcript
