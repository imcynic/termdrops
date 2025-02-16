# TermDrops Installation Script
$ErrorActionPreference = 'Stop'

function Install-TermDrops {
    Write-Host "Installing TermDrops CLI..."

    # Verify Python
    try { python --version } 
    catch {
        Write-Host "Error: Python required. Download from https://www.python.org/downloads/"
        return
    }

    # Setup paths
    $baseDir = Join-Path $env:USERPROFILE ".termdrops"
    $binPath = Join-Path $env:USERPROFILE ".local/bin"

    # Clean and create directories
    Remove-Item -Recurse -Force $baseDir -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force -Path $baseDir | Out-Null
    New-Item -ItemType Directory -Force -Path $binPath | Out-Null

    # Download and extract
    $zipUrl = "https://github.com/imcynic/termdrops/archive/refs/heads/main.zip"
    $zipFile = Join-Path $baseDir "termdrops.zip"
    
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile
    Expand-Archive -Path $zipFile -DestinationPath $baseDir
    Remove-Item $zipFile
    Rename-Item (Join-Path $baseDir "termdrops-main") (Join-Path $baseDir "termdrops")

    # Install package
    Set-Location (Join-Path $baseDir "termdrops")
    python -m pip install -e .

    # Setup command tracking
    $profile_content = @'
# TermDrops Command Tracking
function Process-Command { param($cmd) python -m termdrops $cmd }
Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -Forward -Action {
    if ($global:LastCommand) { Process-Command $global:LastCommand }
}
'@

    if (Test-Path $PROFILE) {
        if (-not (Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue).Contains("TermDrops")) {
            Add-Content $PROFILE $profile_content
        }
    } else {
        Set-Content $PROFILE $profile_content
    }

    # Create wrapper
    Set-Content (Join-Path $binPath "termdrops.ps1") 'python -m termdrops $args'

    # Update PATH
    $user_path = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($user_path -notlike "*$binPath*") {
        [Environment]::SetEnvironmentVariable("Path", "$user_path;$binPath", "User")
        $env:Path = "$env:Path;$binPath"
    }

    Write-Host "`nTermDrops installed successfully!"
    Write-Host "Please restart PowerShell and run 'termdrops login'"
}

# Run installation
Install-TermDrops
pause
