# 1. Install required dependencies (VCLibs and UI Xaml)
$deps = @(
    "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx",
    "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx"
)

foreach ($url in $deps) {
    $file = "$env:TEMP\" + ($url -split "/")[-1]
    Invoke-WebRequest -Uri $url -OutFile $file
    Add-AppxPackage -Path $file
}

# 2. Download and install the latest WinGet bundle from GitHub
$api = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
$url = (Invoke-RestMethod $api).assets | Where-Object { $_.name -like "*msixbundle" } | Select-Object -ExpandProperty browser_download_url
$output = "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

Invoke-WebRequest -Uri $url -OutFile $output
Add-AppxPackage -Path $output

# 3. Verify installation
winget --version

