Write-Host "`n--- HARDWARE STATS ---" -ForegroundColor Cyan
$cpuInfo = Get-CimInstance Win32_Processor
$memInfo = Get-CimInstance Win32_OperatingSystem
$cores = $cpuInfo.NumberOfLogicalProcessors

Write-Host "CPU Model: $($cpuInfo.Name)"
Write-Host "Logical Cores: $cores"
Write-Host "Total RAM: $([math]::Round($memInfo.TotalVisibleMemorySize / 1MB, 2)) GB"

Write-Host "`n--- SYSTEM LOAD ---" -ForegroundColor Cyan
$totalCpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
Write-Host "Overall CPU Usage: $([math]::Round($totalCpu, 2))%" -ForegroundColor $(if($totalCpu -gt 85){"Red"}else{"Green"})

Write-Host "`n--- TOP 5 PROCESSES HOGGING CPU ---" -ForegroundColor Yellow
# We sample for 1 second to get 'real-time' percentage rather than lifetime average
Get-Counter "\Process(*)\% Processor Time" -ErrorAction SilentlyContinue | 
    Select-Object -ExpandProperty CounterSamples | 
    Where-Object { $_.InstanceName -notmatch "^(_total|idle|system)$" } | 
    Sort-Object CookedValue -Descending | 
    Select-Object -First 5 | 
    Format-Table @{Name="ProcessName"; Expression={$_.InstanceName}}, 
                 @{Name="CPU % (per core)"; Expression={[math]::Round($_.CookedValue, 2)}},
                 @{Name="Total System %"; Expression={[math]::Round($_.CookedValue / $cores, 2)}}
                 