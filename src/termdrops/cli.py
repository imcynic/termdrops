import os
import sys
import click
import json
import requests
from pathlib import Path
from rich.console import Console
from rich.panel import Panel
from rich.text import Text

console = Console()

# Configuration
CONFIG_DIR = Path.home() / ".config" / "termdrops"
CONFIG_FILE = CONFIG_DIR / "config.json"
API_URL = "https://app.databutton.com/lgxqxcurrently/TermDrops"

def load_config():
    """Load configuration from file."""
    if not CONFIG_FILE.exists():
        return {}
    
    try:
        with open(CONFIG_FILE) as f:
            return json.load(f)
    except Exception as e:
        console.print(f"[red]Error loading config: {e}[/red]")
        return {}

def save_config(config):
    """Save configuration to file."""
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    
    try:
        with open(CONFIG_FILE, 'w') as f:
            json.dump(config, f)
    except Exception as e:
        console.print(f"[red]Error saving config: {e}[/red]")

def process_command(command):
    """Send command to API and process response."""
    config = load_config()
    user_id = config.get('user_id')
    
    if not user_id:
        console.print("[yellow]Not logged in. Run 'termdrops login' first.[/yellow]")
        return
    
    try:
        response = requests.post(
            f"{API_URL}/api/process-command",
            json={
                "user_id": user_id,
                "command": command
            }
        )
        response.raise_for_status()
        data = response.json()
        
        if data.get("dropped"):
            # Show drop notification
            pet_name = data.get("pet_name")
            rarity = data.get("rarity_tier")
            message = Text()
            message.append("\n🎉 ", style="bold green")
            message.append(f"Found a {rarity} pet: ", style=f"bold {get_rarity_color(rarity)}")
            message.append(f"{pet_name}!\n", style="bold")
            
            console.print(Panel(
                message,
                title="TermDrops",
                border_style="green"
            ))
    except Exception as e:
        console.print(f"[red]Error processing command: {e}[/red]")

def get_rarity_color(rarity):
    """Get color for rarity tier."""
    colors = {
        "common": "white",
        "uncommon": "green",
        "rare": "blue",
        "epic": "magenta",
        "legendary": "yellow"
    }
    return colors.get(rarity, "white")

@click.group()
def cli():
    """TermDrops CLI - Collect pets while using your terminal!"""
    pass

@cli.command()
def login():
    """Login to TermDrops."""
    console.print("\n[bold green]Opening TermDrops dashboard in your browser...[/bold green]")
    console.print("Please follow the instructions to connect your terminal.\n")
    
    # Send login command to get URL
    try:
        response = requests.post(
            f"{API_URL}/api/process-command",
            json={
                "user_id": "cli-login",
                "command": "login"
            }
        )
        response.raise_for_status()
        data = response.json()
        
        if data.get("message"):
            console.print(data["message"])
    except Exception as e:
        console.print(f"[red]Error during login: {e}[/red]")

@cli.command()
def status():
    """Check TermDrops connection status."""
    config = load_config()
    user_id = config.get('user_id')
    
    if user_id:
        console.print("[green]Connected to TermDrops![/green]")
        console.print(f"User ID: {user_id}")
    else:
        console.print("[yellow]Not connected to TermDrops.[/yellow]")
        console.print("Run 'termdrops login' to connect.")

@cli.command()
def configure():
    """Configure TermDrops CLI."""
    user_id = click.prompt("Enter your user ID", type=str)
    
    config = load_config()
    config['user_id'] = user_id
    save_config(config)
    
    console.print("[green]Configuration saved successfully![/green]")

def main():
    """Main entry point for the CLI."""
    if len(sys.argv) > 1 and sys.argv[1] not in ['login', 'status', 'configure']:
        # If not a known command, process it as a terminal command
        process_command(' '.join(sys.argv[1:]))
    else:
        cli()

if __name__ == "__main__":
    main()
