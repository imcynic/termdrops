# TermDrops Installation Script
$ErrorActionPreference = 'Stop'

function Install-TermDrops {
    Write-Host "Installing TermDrops CLI..."

    # Verify Python
    try { 
        $pythonVersion = python --version
        Write-Host $pythonVersion
    } catch {
        Write-Host "Error: Python required. Download from https://www.python.org/downloads/"
        return
    }

    # Setup paths
    $baseDir = Join-Path $env:USERPROFILE ".termdrops"
    $srcDir = Join-Path $baseDir "src"
    $binPath = Join-Path $env:USERPROFILE ".local\bin"

    # Clean and create directories
    Write-Host "Creating directories..."
    Remove-Item -Recurse -Force $baseDir -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force -Path $baseDir | Out-Null
    New-Item -ItemType Directory -Force -Path $srcDir | Out-Null
    New-Item -ItemType Directory -Force -Path $binPath | Out-Null

    # Create virtual environment
    Write-Host "Creating virtual environment..."
    python -m venv $baseDir
    $pythonPath = Join-Path $baseDir "Scripts\python.exe"
    $pipPath = Join-Path $baseDir "Scripts\pip.exe"

    # Upgrade pip
    Write-Host "Upgrading pip..."
    & $pythonPath -m pip install --upgrade pip

    # Create package structure
    Write-Host "Creating package structure..."
    $packageDir = Join-Path $srcDir "termdrops"
    New-Item -ItemType Directory -Force -Path $packageDir | Out-Null

    # Create __init__.py
    Set-Content (Join-Path $packageDir "__init__.py") ""

    # Create __main__.py
    $mainContent = @'
"""Main entry point for termdrops package."""
from termdrops.cli import main

if __name__ == '__main__':
    main()
'@

    Set-Content (Join-Path $packageDir "__main__.py") $mainContent

    # Create cli.py with the updated code
    $cliContent = @'
"""CLI module for termdrops."""
import click
import webbrowser
import os
import uuid
import json
import time
import requests

# Your Databutton app URLs - using direct API URL
APP_URL = "https://cynic.databutton.app/termdrops"  # Frontend URL
API_URL = "https://api.databutton.com/v1/data/cynic/termdrops"  # Direct API URL

# Store terminal ID and session
CONFIG_DIR = os.path.expanduser("~/.termdrops")
CONFIG_FILE = os.path.join(CONFIG_DIR, "config.json")

def get_or_create_terminal_id():
    """Get existing terminal ID or create a new one"""
    if not os.path.exists(CONFIG_DIR):
        os.makedirs(CONFIG_DIR)
    
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, 'r') as f:
                config = json.load(f)
                return config.get('terminal_id')
        except:
            pass
    
    # Create new terminal ID
    terminal_id = str(uuid.uuid4())
    with open(CONFIG_FILE, 'w') as f:
        json.dump({'terminal_id': terminal_id}, f)
    return terminal_id

@click.group()
def main():
    """TermDrops CLI - Collect pets while using your terminal."""
    pass

@main.command()
@click.argument('user_id')
def connect(user_id):
    """Connect to your TermDrops account using your user ID."""
    try:
        # Get or create terminal ID
        terminal_id = get_or_create_terminal_id()
        
        # Connect terminal using our API
        response = requests.post(
            f"{API_URL}/drops/connect-terminal",  # Updated endpoint path
            json={
                "user_id": terminal_id,
                "command": user_id
            },
            headers={
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Origin": APP_URL  # Use frontend URL as origin
            }
        )
        
        # Print response for debugging
        print(f"Response status: {response.status_code}")
        print(f"Response headers: {response.headers}")
        try:
            print(f"Response body: {response.json()}")
        except:
            print(f"Raw response: {response.text}")
        
        if response.status_code == 200:
            data = response.json()
            click.echo(data.get("message", "Terminal connected successfully!"))
            
            # If we got a pet, it will be in the response
            if data.get("dropped"):
                click.echo(f"\nCongratulations! You found a {data['rarity_tier']} pet: {data['pet_name']}!")
            
            # Verify connection
            verify_response = requests.post(
                f"{API_URL}/drops/process-command",  # Updated endpoint path
                json={
                    "user_id": terminal_id,
                    "command": "login"
                },
                headers={
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                    "Origin": APP_URL  # Use frontend URL as origin
                }
            )
            
            if verify_response.status_code == 200:
                verify_data = verify_response.json()
                if verify_data.get("success"):
                    click.echo("\nTerminal ready to collect pets! Start using commands to find more pets.")
                    return
            
            click.echo("\nConnection successful but verification failed. You may need to reconnect.")
            click.echo("Try 'termdrops login' if you have issues.")
        else:
            click.echo(f"Error connecting terminal: {response.status_code} {response.reason}")
            if response.status_code == 403:
                click.echo("Access denied. This might be a CORS issue.")
                click.echo("Try using 'termdrops login' instead to connect through browser.")
            else:
                click.echo("Please try again or use 'termdrops login' to connect through browser.")
            
    except requests.exceptions.ConnectionError:
        click.echo("Error: Could not connect to TermDrops server.")
        click.echo("Please check your internet connection and try again.")
    except Exception as e:
        click.echo(f"Error connecting terminal: {str(e)}")
        click.echo("Please try again or contact support if the issue persists.")

@main.command()
def login():
    """Connect to your TermDrops account through browser login."""
    try:
        # Get or create terminal ID
        terminal_id = get_or_create_terminal_id()
        
        # Open login page with terminal ID
        login_url = f"{APP_URL}/Login?terminal_id={terminal_id}"
        click.echo("Opening TermDrops login page in your browser...")
        click.echo("Please log in and follow the instructions to connect your terminal.")
        webbrowser.open(login_url)
        
        # Wait a bit for the user to log in
        time.sleep(2)
        
        # Try to verify connection
        max_retries = 5
        retry_delay = 2
        
        for i in range(max_retries):
            try:
                response = requests.post(
                    f"{API_URL}/drops/process-command",  # Updated endpoint path
                    json={
                        "user_id": terminal_id,
                        "command": "login"
                    },
                    headers={
                        "Content-Type": "application/json",
                        "Accept": "application/json",
                        "Origin": APP_URL  # Use frontend URL as origin
                    }
                )
                
                if response.status_code == 200:
                    data = response.json()
                    if data.get("success"):
                        click.echo("Terminal connected successfully!")
                        click.echo("\nTerminal ready to collect pets! Start using commands to find more pets.")
                        return
                    elif i < max_retries - 1:
                        click.echo("Waiting for login...")
                        time.sleep(retry_delay)
                    else:
                        click.echo("Login timeout. Please try again or visit the login page manually:")
                        click.echo(login_url)
                else:
                    click.echo(f"Error during login: {response.status_code} {response.reason}")
                    if response.status_code == 403:
                        click.echo("Access denied. This might be a CORS issue.")
                    click.echo(f"Please visit {login_url} manually to connect your terminal.")
                    return
                    
            except requests.exceptions.ConnectionError:
                if i < max_retries - 1:
                    click.echo("Connection failed, retrying...")
                    time.sleep(retry_delay)
                else:
                    click.echo("Could not connect to TermDrops server.")
                    click.echo("Please check your internet connection and try again.")
                    return
            except Exception as e:
                if i < max_retries - 1:
                    click.echo("Retrying connection...")
                    time.sleep(retry_delay)
                else:
                    click.echo(f"Error during login: {str(e)}")
                    click.echo(f"Please visit {login_url} manually to connect your terminal.")
                    return
            
    except Exception as e:
        click.echo(f"Error during login: {str(e)}")
        click.echo("Please try again or contact support if the issue persists.")

if __name__ == '__main__':
    main()
'@

    Set-Content (Join-Path $packageDir "cli.py") $cliContent

    # Create setup.py
    $setupContent = @'
from setuptools import setup, find_packages

setup(
    name="termdrops",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "click>=8.0.0",
        "requests>=2.25.0",
        "rich>=10.0.0",
        "python-dotenv>=0.19.0",
    ],
    entry_points={
        "console_scripts": [
            "termdrops=termdrops.cli:main",
        ],
    },
    author="Bryan Banner",
    author_email="your.email@example.com",
    description="TermDrops CLI - Collect pets while using your terminal",
    long_description="A fun gamification system for terminal users that adds MMO-style loot drops to command-line usage.",
    url="https://github.com/imcynic/termdrops",
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.7",
)
'@

    Set-Content (Join-Path $srcDir "setup.py") $setupContent

    # Install package
    Write-Host "Installing package..."
    Set-Location $srcDir
    & $pipPath install -e .
    
    # Verify the script was created
    $cliScript = Join-Path $baseDir "Scripts\termdrops.exe"
    if (-not (Test-Path $cliScript)) {
        Write-Host "Warning: CLI script not created. Trying alternative installation..."
        & $pipPath install --no-cache-dir -e .
    }

    # Setup command tracking
    $profile_content = @'
# TermDrops Command Tracking
$global:LastCommand = $null
$ExecutionContext.InvokeCommand.PreCommandLookupAction = {
    param($commandName, $commandLookupEventArgs)
    $global:LastCommand = $commandName
}

Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
    if ($global:LastCommand) {
        $terminal_id = Get-Content "$env:USERPROFILE\.termdrops\config.json" | ConvertFrom-Json | Select-Object -ExpandProperty terminal_id
        $body = @{
            user_id = $terminal_id
            command = $global:LastCommand
        } | ConvertTo-Json
        
        try {
            Invoke-RestMethod -Uri "https://api.databutton.com/v1/data/cynic/termdrops/drops/process-command" -Method Post -Body $body -ContentType "application/json" -Headers @{
                "Accept" = "application/json"
                "Origin" = "https://cynic.databutton.app/termdrops"
            }
        } catch {
            # Silently fail for command tracking
        }
        $global:LastCommand = $null
    }
}
'@

    if (Test-Path $PROFILE) {
        if (-not (Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue).Contains("TermDrops")) {
            Add-Content $PROFILE $profile_content
        }
    } else {
        Set-Content $PROFILE $profile_content
    }

    # Create wrapper script that calls the CLI directly
    $wrapperContent = @'
#!/usr/bin/env pwsh
& "$env:USERPROFILE\.termdrops\Scripts\termdrops.exe" $args
'@
    Set-Content (Join-Path $binPath "termdrops.ps1") $wrapperContent

    # Update PATH
    $user_path = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($user_path -notlike "*$binPath*") {
        [Environment]::SetEnvironmentVariable("Path", "$user_path;$binPath", "User")
        $env:Path = "$env:Path;$binPath"
    }

    Write-Host "`nTermDrops CLI installed successfully!"
    Write-Host "Please restart PowerShell and run 'termdrops login'"
}

# Run installation
Install-TermDrops
pause
