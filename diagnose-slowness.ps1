Write-Host "--- GCP Windows Gaming/Performance Diagnostic ---" -ForegroundColor Cyan

# 1. Check CPU Steal/Wait (Is the host oversold?)
$cpu = Get-Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 3
Write-Host "[1] Average CPU Usage: $([math]::Round(($cpu.CounterSamples.CookedValue | Measure-Object -Average).Average, 2))%"

# 2. Check Disk Latency (The #1 killer of Windows speed on GCP)
$diskRead = Get-Counter "\PhysicalDisk(_Total)\Avg. Disk sec/Read"
$diskWrite = Get-Counter "\PhysicalDisk(_Total)\Avg. Disk sec/Write"
Write-Host "[2] Disk Read Latency: $([math]::Round($diskRead.CounterSamples[0].CookedValue * 1000, 2)) ms"
Write-Host "    Disk Write Latency: $([math]::Round($diskWrite.CounterSamples[0].CookedValue * 1000, 2)) ms"
Write-Host "    (Note: Over 20ms feels slow; over 100ms is a major bottleneck)"

# 3. Check for "Code 43" or GPU Driver Errors
$gpuStatus = Get-PnpDevice -Class Display | Select-Object FriendlyName, Status
Write-Host "[3] GPU Status:"
$gpuStatus | ForEach-Object { Write-Host "    - $($_.FriendlyName): $($_.Status)" }

# 4. Network Auto-Tuning Check
$tcp = Get-NetTCPSetting | Select-Object -First 1 AutoTuningLevelLocal
Write-Host "[4] TCP Auto-Tuning: $($tcp.AutoTuningLevelLocal)"

# 5. Power Plan Check (Should be 'High Performance')
$plan = Get-CimInstance -Namespace root\interop -ClassName Win32_PowerPlan | Where-Object { $_.IsActive }
Write-Host "[5] Active Power Plan: $($plan.ElementName)"

# 6. Check for Thermal/Power Throttling (System Events)
$throttling = Get-WinEvent -FilterHashtable @{LogName='System'; Id=37} -ErrorAction SilentlyContinue | Select-Object -First 1
if ($throttling) { Write-Host "[6] WARNING: CPU Throttling detected in event logs!" -ForegroundColor Red } 
else { Write-Host "[6] No CPU Throttling events found." }

# 7. RDP UDP Check (Crucial for MacBook -> Windows Gaming)
$rdpPort = Get-NetUDPEndpoint -LocalPort 3389 -ErrorAction SilentlyContinue
if ($rdpPort) { Write-Host "[7] RDP UDP is Enabled (Good for speed)" -ForegroundColor Green }
else { Write-Host "[7] RDP UDP is Disabled (RDP will feel laggy)" -ForegroundColor Yellow }

# 8. Available Memory
$mem = Get-CimInstance Win32_OperatingSystem | Select-Object FreePhysicalMemory, TotalVisibleMemorySize
$memPercent = [math]::Round(($mem.FreePhysicalMemory / $mem.TotalVisibleMemorySize) * 100, 2)
Write-Host "[8] Free Memory: $memPercent %"

# 9. Disk Fill Level
$drive = Get-PSDrive C | Select-Object Used, Free
$drivePercent = [math]::Round(($drive.Used / ($drive.Used + $drive.Free)) * 100, 2)
Write-Host "[9] C: Drive Fullness: $drivePercent %"

# 10. Check for Background Updates (The Windows 11/2022 Performance Killer)
$updates = Get-Service -Name wuauserv
Write-Host "[10] Windows Update Service: $($updates.Status)"

Write-Host "`n--- Diagnosis Complete ---" -ForegroundColor Cyan