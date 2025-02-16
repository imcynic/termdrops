Cynic
zcynic
Online

Cynic
 — 
2/12/25, 10:04 AM
https://benheater.com/proxmox-running-bliss-os/
0xBEN
Proxmox: Running Bliss OS
In this tutorial, we will look at the process of running Bliss OS in the Proxmox hypervisor, making it convenient to run Android apps from your home lab server.
Proxmox: Running Bliss OS
Cynic
 — 
2/12/25, 10:32 AM
938885
Cynic
 — 
2/12/25, 12:30 PM
Here's what you need to tell the next Claude to help set up netboot.xyz for your custom Clonezilla image:

We've already set up:

Static IP on your server: 192.168.1.248
DHCP server (isc-dhcp-server) configured for PXE boot
Successfully created a Clonezilla backup image stored on external drive


Need to configure:

Add netboot.xyz to your docker-compose stack (we have the service definition ready)
Create custom menu entries in netboot.xyz to point to your Clonezilla image
Configure the paths and locations for the image to be accessible


Key files/info to mention:

existing docker-compose.yaml (which was shared)
The DHCP config we set up in /etc/dhcp/dhcpd.conf
Location of your Clonezilla backup image on the external drive


 end goal:

Boot any computer on your network
Select your custom Windows image from netboot menu
Restore the image quickly over your 10Gb network

version: "3.3"
services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    ports:

Expand
docker-compose.yaml7 KB
Cynic
 — 
2/12/25, 12:43 PM
``` 

Infrastructure ready:

Server with static IP: 192.168.1.248
isc-dhcp-server installed and configured for PXE boot
10Gb network ready for fast image deployment
Custom Clonezilla backup image created and stored on external drive


Docker environment:

Existing docker-compose.yaml (shared above) with netboot.xyz service defined
Various mount points available: /home/bryan/nas, /mnt/qnap, /mnt/cache-pool
netboot.xyz container configured with ports 3000, 69/udp, and 8080 exposed


Next steps needed:

Configure netboot.xyz for custom menu entries
Set up proper paths for the Clonezilla image
Ensure netboot.xyz can access and serve the image
Configure any additional settings needed for 10Gb network optimization


End goal:

PXE boot any computer on the network
Custom menu entry in netboot.xyz to select Windows image
Fast image deployment over 10Gb network

Can you help me with the specific configurations needed for netboot.xyz to serve my custom Clonezilla image?

 
luciderhollows
 — 
2/12/25, 5:06 PM
https://www.tiktok.com/t/ZT2ScmjHT/
TikTok
TikTok · Brad
Image
luciderhollows
 — 
2/12/25, 5:34 PM
https://www.tiktok.com/t/ZT2S3Sq1y/
TikTok
TikTok · Tra Rags
Image
luciderhollows
 — 
2/12/25, 10:05 PM
Sup I'm awake now 🙏🏾
Cynic
 — 
2/12/25, 10:26 PM
Yo
luciderhollows
 — 
2/12/25, 10:27 PM
Sup feeding momo rn
Cynic
 — 
2/13/25, 2:58 AM
6F4z8c74s
Cynic
 — 
2/13/25, 5:16 AM
https://www.panelook.com/LW315AQQ-ESG2_LG_Display_32.0_OLED_overview_67291.html
user login
30K+ LCD panel models, 32K+ LCD panel datasheets, 10M+ pcs panel stocks, 180+ panel sizes, 100+ parametres, 70+ LCD panel brands, 30+ LCD panel applications.
smarthome company
plex sell
terminal pets
rps game
music stuff 
custom touch screen
Cynic
 — 
2/13/25, 12:12 PM
Image
Image
Image
❯ docker exec -it netbootxyz ls -l /var/lib/tftpboot/
total 0

❯ docker exec -it netbootxyz ls -l /var/www/html/ipxe/
total 4380
-rw-r--r--    1 1000     users      1112064 Feb 13 04:34 netboot.xyz.efi
-rw-r--r--    1 1000     users      1112064 Feb 13 04:34 netboot.xyz.efi.1
-rw-r--r--    1 1000     users      1112064 Feb 13 04:34 netboot.xyz.efi.2
-rw-r--r--    1 1000     users       380600 Feb 13 04:34 netboot.xyz.kpxe
-rw-r--r--    1 1000     users       380600 Feb 13 04:34 netboot.xyz.kpxe.1
-rw-r--r--    1 1000     users       380600 Feb 13 04:34 netboot.xyz.kpxe.2
Cynic
 — 
2/13/25, 9:52 PM
luciderhollows
 — 
2/14/25, 5:53 AM
So I found the issue, the laptops aren't thunderbolt 🙂💀💀
Image
Image
Cynic
 — 
2/14/25, 7:49 AM

# Configuring PXE Boot Server for Fast Image Deployment...
Exported on 14/02/2025 at 07:49:25 [from Claude Chat](https://claude.ai/chat/a8f85a9b-62ff-47de-b448-a5aa0534872d) - with [SaveMyChatbot](https://save.hugocollin.com)

## User
Infrastructure ready: - Server with static IP: 192.168.1.248 - isc-dhcp-server installed and configured for PXE boot - 10Gb network ready for fast image deployment - Custom Clonezilla backup image created and stored on external drive at /media/bryan/maxone/W11lukacustom - Clonezilla ISO at /media/bryan/maxone/clonezillaiso/clonezilla-live-3.2.0-5-amd64.iso Steps Completed: 1. Configured DHCP server (/etc/dhcp/dhcpd.conf) for PXE boot 2. Set up network optimization in /etc/sysctl.conf for mixed 2.5Gb/10Gb environment 3. Created Docker setup with netboot.xyz service 4. Set up directory structure for netboot.xyz in Docker 5. Currently working on getting the boot files in place Current Status: - DHCP server is running and responding to requests - netboot.xyz container is running - Working on populating the TFTP and iPXE directories with necessary boot files Our goal is to: 1. Boot any computer on the network via PXE 2. Present a custom menu entry in netboot.xyz to select Windows image 3. Deploy the image over the 10Gb network Current Issue: We're setting up the boot files for netboot.xyz. We've created the directory structure but need to properly populate the TFTP and iPXE directories with the necessary boot files. Would you like to see any particular configuration files or continue with our current task?
... (188 KB left)

Expand
2025-02-14_07-49-25_Claude Chat_Configuring PXE Boot Server for Fast Image Deployment....md238 KB
luciderhollows
 — 
2/14/25, 10:17 AM
Yo carpet people might be coming
Yeah they are!
Kayla and cats, maybe just don't answer the door and let them come another time
Cynic
 — 
2/14/25, 11:43 AM
Image
Cynic
 — 
2/14/25, 2:02 PM
your-super-secret-password: A secure password for PostgreSQL
your-jwt-secret: A secure JWT secret (can be generated with openssl rand -base64 32)
your-anon-key: Your anon key (will be generated)
your-service-key: Your service key (will be generated)
Cynic
 — 
2/14/25, 5:01 PM
your-super-secret-password
Current: SuperSecretPass123

your-jwt-secret
Current: VerySecretJWTKey456

your-anon-key
Current: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiJ9.SuperSecretAnon789

your-service-key
Current: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoic2VydmljZV9yb2xlIn0.SecretService101
__
Did it! got the keys labeled and working. // "Yes! The response you're seeing indicates that everything is working correctly now! Let me break down why this is a success:

The API responded with a Swagger/OpenAPI documentation instead of an error
There's no authentication error, which means your anon key is working
The database roles we created are functioning properly
Kong is correctly routing the requests
PostgREST (rest service) is properly connected to the database

You can now:

Access the Supabase Studio at http://localhost:3001/
Make API calls using your anon key
Use the REST API with proper authentication" -claude.
luciderhollows
 — 
2/14/25, 5:02 PM
^ yes sirrr, got it done. It was being a cunt
Cynic
 — 
2/14/25, 8:59 PM

Here's the SQL you need to run in the Supabase SQL editor to set up the profiles table and security policies:

-- Create profiles table
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,

Expand
message.txt3 KB
Cynic
 — 
Yesterday at 1:15 AM
https://www.reddit.com/r/DataHoarder/comments/1ipte1g/wds_new_hdmr_tech_to_enable_recordbreaking_100tb/
Reddit
From the DataHoarder community on Reddit: WD's new HDMR tech to ena...
Explore this post and more from the DataHoarder community
From the DataHoarder community on Reddit: WD's new HDMR tech to ena...
Cynic
 — 
Yesterday at 2:46 AM
Image
luciderhollows
 — 
Yesterday at 2:47 AM
Think I got it! ^ 🙏🏾
Cynic
 — 
Yesterday at 2:47 AM
oh shiiii
Cynic
 — 
Yesterday at 3:44 AM
im hearing coughs out there
how u still awake
u psycho
luciderhollows
 — 
Yesterday at 3:45 AM
Hahaha yeee I'm smoking to eat rn, I have no idea how I'm doing this lmao. It's crazy cause I still feel wide awake and normal rn for the most part, like 20% tired fs. Weed, food, bath, should put me down 🤣🙏🏾
Cynic
 — 
Yesterday at 3:46 AM
yeahhhh
this man fuckin bipolar
lmfao
But actually tho, you seeing what dopamine from complex projects do tho huh
😂
luciderhollows
 — 
Yesterday at 3:49 AM
PFFT nahhhh idkkkk. Bipolar always sounded so scary and serious to me lol. But I can relate to the mood swings and shit. Who knows, and yeah hahaha. And if it keeps compiling I'm understanding that's how people get to do the real cool shit in life that needs skills like going to a actual race track and or building something from pure scratch
Cynic
 — 
Yesterday at 3:50 AM
compounding is the word u lookin for
unless i didnt read the sentence right
and u sayin sum else
and yeah it does compound
luciderhollows
 — 
Yesterday at 3:50 AM
Ahhh idk I'm high
Yeee hahah
luciderhollows
 — 
Yesterday at 5:47 PM
https://www.tiktok.com/t/ZT2Dg6aV8/
TikTok
TikTok · CFN Cabbage
Image
Cynic
 — 
Yesterday at 10:59 PM
❯ ./termdrops.sh
zsh: ./termdrops.sh: bad interpreter: /bin/bash^M: no such file or directory

 󰮕 󱎦󰫮󱎦󱎦   ~/Downloads 
Cynic
 — 
Yesterday at 11:12 PM
❯ source termdrops.sh
termdrops.sh:4: command not found: ^M
termdrops.sh:8: command not found: ^M
termdrops.sh:67: parse error near `elif'

 󰮕 󱎦󰫮󱎦󱎦   ~/Downloads 
Cynic
 — 
Yesterday at 11:22 PM
❯ source termdrops.sh
Usage: add-zsh-hook hook function
Valid hooks are:
  chpwd precmd preexec periodic zshaddhistory zshexit zsh_directory_name
TermDrops: Command tracking initialized. Use 'termdrops_login <user-id>'
Cynic
 — 
Today at 1:35 AM
Bryansae614!
Cynic
 — 
Today at 1:53 AM
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
https://github.com/imcynic/termdrops
GitHub
GitHub - imcynic/termdrops
Contribute to imcynic/termdrops development by creating an account on GitHub.
GitHub - imcynic/termdrops
Image
luciderhollows
 — 
Today at 2:04 AM
To use this:

Create these files in your repository:
setup.py in the root
termdrops/cli.py for the main code
README.md for documentation
Create an empty termdrops/init.py file
from setuptools import setup, find_packages

setup(
    name="termdrops",
    version="0.1.0",
    package_dir={"": "src"},  # Add this line to specify src directory
    packages=find_packages(where="src"),  # Update this to look in src
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
    author="LT Lives",
    author_email="your.email@example.com",
    description="TermDrops CLI - Collect pets while using your terminal",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/imcynic/termdrops",
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.7",
) 
,,,
,,,
README.md
\

# TermDrops CLI

Collect pets while using your terminal! TermDrops adds MMO-style loot drops to your command-line usage.

## Installation

### Linux/macOS
```bash
curl -s https://raw.githubusercontent.com/imcynic/termdrops/main/scripts/install.sh | bash

Collapse
README.md1 KB
Cynic
 — 
Today at 2:09 AM
https://github.com/imcynic/termdrops/tree/main/src/termdrops
GitHub
termdrops/src/termdrops at main · imcynic/termdrops
Contribute to imcynic/termdrops development by creating an account on GitHub.
termdrops/src/termdrops at main · imcynic/termdrops
luciderhollows
 — 
Today at 2:12 AM
cli.py

import os
import sys
import click
import json
import requests
from pathlib import Path

Expand
message.txt5 KB
Cynic pinned a message to this channel. See all pinned messages.
 — 
Today at 2:21 AM
luciderhollows
 — 
Today at 2:26 AM
,,
install.ps1

# TermDrops Installation Script

$ErrorActionPreference = 'Stop'

Write-Host "Installing TermDrops CLI..."

Expand
install.ps12 KB
Cynic
 — 
Today at 2:34 AM
❯ tree
.
├── LICENSE
├── README.md
├── requirements.txt
├── scripts
│   ├── install.ps1
│   └── install.sh
├── setup.py
├── src
│   └── termdrops
│       ├── cli.py
│       ├── cli.py.txt
│       └── init.py
└── test

4 directories, 10 files
luciderhollows
 — 
Today at 2:35 AM
mv src/termdrops/init.py src/termdrops/init.py
,
rm src/termdrops/cli.py.txt

mv src/termdrops/init.py src/termdrops/__init__.py

Cynic
 — 
Today at 2:39 AM

from setuptools import setup, find_packages

setup(
    name="termdrops",
    version="0.1.0",
    package_dir={"": "src"},  # Add this line to specify src directory

Expand
setup.py1 KB
luciderhollows
 — 
Today at 2:41 AM
install.ps1

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

# Check if git is installed
try {
    git --version
} catch {
    Write-Host "Error: Git is required but not installed."
    Write-Host "Please install Git from https://git-scm.com/downloads"
    exit 1
}

# Create installation directory
$InstallDir = "$env:USERPROFILE\.termdrops"
Write-Host "Creating virtual environment at $InstallDir..."

# Remove existing installation if it exists
if (Test-Path $InstallDir) {
    Remove-Item -Recurse -Force $InstallDir
}

# Create and activate virtual environment
python -m venv $InstallDir
& "$InstallDir\Scripts\Activate.ps1"

# Clone and install TermDrops
Write-Host "Installing TermDrops package..."
Set-Location $InstallDir
git clone https://github.com/imcynic/termdrops.git
Set-Location termdrops
python -m pip install --upgrade pip
pip install -e .

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

Collapse
message.txt3 KB
luciderhollows
 — 
Today at 2:56 AM
,,,,
new
install.ps1

# TermDrops Installation Script

$ErrorActionPreference = 'Stop'

Write-Host "Installing TermDrops CLI..."

Expand
message.txt3 KB
,,,,,
new-new
install.ps1

# TermDrops Installation Script

$ErrorActionPreference = 'Stop'

Write-Host "Installing TermDrops CLI..."

Expand
message.txt4 KB
luciderhollows
 — 
Today at 3:11 AM
new-new-new
install.ps1

# TermDrops Installation Script

$ErrorActionPreference = 'Stop'

Write-Host "Installing TermDrops CLI..."

Expand
message.txt4 KB
"""Main entry point for the termdrops CLI."""
from termdrops.cli import main

if name == 'main':
    main()
Create src/termdrops/main.py
Cynic
 — 
Today at 3:22 AM
....

modified:   install.ps1

no changes added to commit (use "git add" and/or "git commit -a")
                                                                                                                            
❯ cd scripts
cd: no such file or directory: scripts

Expand
message.txt8 KB
the cli.py
Cynic
 — 
Today at 3:34 AM
my smoke vape out there?
luciderhollows
 — 
Today at 3:37 AM
Ye it was on the kitchen counter
Cynic
 — 
Today at 3:39 AM

import os
import sys
import click
import json
import requests
from pathlib import Path

Expand
cli.py5 KB
❯ tree
.
├── LICENSE
├── README.md
├── requirements.txt
├── scripts
│   ├── install.ps1
│   └── install.sh
├── setup.py
├── src
│   └── termdrops
│       ├── cli.py
│       ├── init.py
│       └── main.py
└── test

4 directories, 10 files
luciderhollows
 — 
Today at 3:49 AM

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
$ZipUrl = "https://github.com/imcynic/termdrops/archive/refs/heads/main.zip"
$ZipFile = "$InstallDir\termdrops.zip"
Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipFile

# Extract ZIP
Write-Host "Extracting files..."
Expand-Archive -Path $ZipFile -DestinationPath $InstallDir
Remove-Item $ZipFile
Rename-Item "$InstallDir\termdrops-main" "$InstallDir\termdrops"
Set-Location termdrops

# Install the package globally
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

# Function to process commands through TermDrops
function global:Process-TermDropsCommand {
    param(`$Command)
    python -m termdrops "`$Command"
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
python -m termdrops @args
"@

$WrapperPath = "$env:USERPROFILE\.local\bin"
New-Item -ItemType Directory -Force -Path $WrapperPath
Set-Content -Path "$WrapperPath\termdrops.ps1" -Value $WrapperScript
... (20 lines left)

Collapse
setup.py4 KB
﻿
luciderhollows
luciderhollows

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
$ZipUrl = "https://github.com/imcynic/termdrops/archive/refs/heads/main.zip"
$ZipFile = "$InstallDir\termdrops.zip"
Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipFile

# Extract ZIP
Write-Host "Extracting files..."
Expand-Archive -Path $ZipFile -DestinationPath $InstallDir
Remove-Item $ZipFile
Rename-Item "$InstallDir\termdrops-main" "$InstallDir\termdrops"
Set-Location termdrops

# Install the package globally
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

# Function to process commands through TermDrops
function global:Process-TermDropsCommand {
    param(`$Command)
    python -m termdrops "`$Command"
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
Write-Host "Please restart PowerShell for command tracking to take effect."
Write-Host "Run 'termdrops login' to connect to your account."

# Keep window open to see any errors
Write-Host "`nPress any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

setup.py4 KB
