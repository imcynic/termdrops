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

# Create installation directory
$InstallDir = "$env:USERPROFILE\.termdrops"
Write-Host "Creating virtual environment at $InstallDir..."

# Create and activate virtual environment
python -m venv $InstallDir
& "$InstallDir\Scripts\Activate.ps1"

# Install TermDrops
Write-Host "Installing TermDrops package..."
python -m pip install --upgrade pip
pip install termdrops

# Create wrapper script
$WrapperScript = @"
#!pwsh
& "$InstallDir\Scripts\Activate.ps1"
python -m termdrops @args
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
Write-Host "Run 'termdrops login' to connect to your account."
