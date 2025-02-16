# TermDrops Installation Script

$ErrorActionPreference = 'Stop'

Write-Host "Installing TermDrops CLI..."

# Check if Python is installed
try {
    python --version
} catch {
    Write-Host "Error: Python is required but not installed."
    Write-Host "Please install Python from https://www.python.org/downloads/"
    exit 1
}

# Check if pip is installed
try {
    pip --version
} catch {
    Write-Host "Error: pip is required but not installed."
    Write-Host "Please install pip by running: python -m ensurepip --upgrade"
    exit 1
}

# Create base directory
$BaseDir = "$env:USERPROFILE\.termdrops"
Write-Host "Installing to $BaseDir..."

# Remove existing installation if it exists
if (Test-Path $BaseDir) {
    Remove-Item -Recurse -Force $BaseDir
}

# Create directory and download repository
New-Item -ItemType Directory -Force -Path $BaseDir
Set-Location $BaseDir

# Download and extract repository
Write-Host "Downloading TermDrops..."
$ZipUrl = "https://github.com/imcynic/termdrops/archive/refs/heads/main.zip"
$ZipFile = "$BaseDir\termdrops.zip"
Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipFile

# Extract ZIP
Write-Host "Extracting files..."
Expand-Archive -Path $ZipFile -DestinationPath $BaseDir
Remove-Item $ZipFile
Rename-Item "$BaseDir\termdrops-main" "$BaseDir\termdrops"
Set-Location termdrops

# Create and activate virtual environment inside the repository
Write-Host "Creating virtual environment..."
python -m venv venv
& ".\venv\Scripts\Activate.ps1"

# Install the package
Write-Host "Installing TermDrops package..."
python -m pip install --upgrade pip
pip install -e .

# Create PowerShell profile directory if it doesn't exist
$ProfileDir = Split-Path $PROFILE
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Force -Path $ProfileDir
}

# Add command tracking to PowerShell profile
$ProfileContent = @"
# TermDrops Command Tracking
`$env:TERMDROPS_VENV = "$BaseDir\termdrops\venv"

# Function to process commands through TermDrops
function global:Process-TermDropsCommand {
    param(`$Command)
    & "$BaseDir\termdrops\venv\Scripts\python.exe" -m termdrops "`$Command"
}

# Register the command processor
`$null = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -Forward -MaxTriggerCount 1
Register-ObjectEvent -InputObject (Get-EventSubscriber -SourceIdentifier PowerShell.OnIdle).Action -EventName OnInvoke -Forward -Action {
    if (`$global:LastCommand) {
        Process-TermDropsCommand `$global:LastCommand
    }
}
"@

# Add to existing profile or create new one
if (Test-Path $PROFILE) {
    # Check if TermDrops is already in profile
    $ExistingProfile = Get-Content $PROFILE -Raw
    if ($ExistingProfile -notlike "*TermDrops Command Tracking*") {
        Add-Content $PROFILE "`n$ProfileContent"
    }
} else {
    Set-Content $PROFILE $ProfileContent
}

# Create wrapper script for termdrops CLI commands
$WrapperScript = @"
#!pwsh
& "$BaseDir\termdrops\venv\Scripts\python.exe" -m termdrops @args
"@

$WrapperPath = "$env:USERPROFILE\.local\bin"
New-Item -ItemType Directory -Force -Path $WrapperPath
Set-Content -Path "$WrapperPath\termdrops.ps1" -Value $WrapperScript

# Add to PATH if needed
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$WrapperPath*") {
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$UserPath;$WrapperPath",
        "User"
    )
    $env:Path = "$env:Path;$WrapperPath"
}

Write-Host ""
Write-Host "TermDrops CLI installed successfully!"
Write-Host "Please restart PowerShell for command tracking to take effect."
Write-Host "Run 'termdrops login' to connect to your account."

# Keep window open to see any errors
Write-Host "`nPress any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
