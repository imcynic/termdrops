k# TermDrops Installation Script

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
$InstallDir = Join-Path $env:USERPROFILE ".termdrops"
Write-Host "Installing to $InstallDir..."

# Remove existing installation if it exists
if (Test-Path $InstallDir) {
    Remove-Item -Recurse -Force $InstallDir
}

# Create directory and download repository
New-Item -ItemType Directory -Force -Path $InstallDir
Set-Location $InstallDir

# Download and extract repository
Write-Host "Downloading TermDrops..."
$RepoOwner = "imcynic"
$RepoName = "termdrops"
$Branch = "main"
$ZipUrl = "https://github.com/$RepoOwner/$RepoName/archive/refs/heads/$Branch.zip"
$ZipFile = Join-Path $InstallDir "termdrops.zip"
Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipFile

# Extract ZIP
Write-Host "Extracting files..."
Expand-Archive -Path $ZipFile -DestinationPath $InstallDir
Remove-Item $ZipFile
Rename-Item (Join-Path $InstallDir "$RepoName-$Branch") (Join-Path $InstallDir $RepoName)
Set-Location $RepoName

# Install the package globally
Write-Host "Installing TermDrops package..."
python -m pip install --upgrade pip
pip install -e .

# Create PowerShell profile directory if it doesn't exist
$ProfileDir = Split-Path $PROFILE
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Force -Path $ProfileDir
}

# Create the command tracking function
$CommandFunction = @'
function global:Process-TermDropsCommand {
    param($Command)
    python -m termdrops "$Command"
}
'@

# Create the event registration
$EventRegistration = @'
$null = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -Forward -MaxTriggerCount 1
Register-ObjectEvent -InputObject (Get-EventSubscriber -SourceIdentifier PowerShell.OnIdle).Action -EventName OnInvoke -Forward -Action {
    if ($global:LastCommand) {
        Process-TermDropsCommand $global:LastCommand
    }
}
'@

# Combine profile content
$ProfileContent = @"
# TermDrops Command Tracking
$CommandFunction
$EventRegistration
"@

# Add to existing profile or create new one
if (Test-Path $PROFILE) {
    $ExistingProfile = Get-Content $PROFILE -Raw
    if ($ExistingProfile -notlike "*TermDrops Command Tracking*") {
        Add-Content $PROFILE "`n$ProfileContent"
    }
} else {
    Set-Content $PROFILE $ProfileContent
}

# Create wrapper script directory
$WrapperPath = Join-Path $env:USERPROFILE ".local\bin"
New-Item -ItemType Directory -Force -Path $WrapperPath

# Create wrapper script
$WrapperContent = @'
#!pwsh
python -m termdrops @args
'@
Set-Content -Path (Join-Path $WrapperPath "termdrops.ps1") -Value $WrapperContent

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
