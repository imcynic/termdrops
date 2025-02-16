"""CLI module for termdrops."""
import click
import webbrowser
import requests
import os
import uuid
import json

# Your Databutton app URL
APP_URL = "https://cynic.databutton.app/termdrops"
API_URL = f"{APP_URL}/api/drops"

# Store terminal ID
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
def login():
    """Connect to your TermDrops account."""
    click.echo("Opening TermDrops login page in your browser...")
    click.echo("Please log in and follow the instructions to connect your terminal.")
    
    try:
        # Get or create terminal ID
        terminal_id = get_or_create_terminal_id()
        
        # Open login page with terminal ID
        login_url = f"{APP_URL}/Login?terminal_id={terminal_id}"
        webbrowser.open(login_url)
        
        # Send login command to API
        response = requests.post(
            f"{API_URL}/process-command",
            json={
                "user_id": terminal_id,
                "command": "login"
            },
            headers={
                "Content-Type": "application/json",
                "Accept": "application/json"
            }
        )
        
        if response.status_code != 200:
            click.echo(f"Error during login: {response.status_code} {response.reason}")
            click.echo(f"Please visit {login_url} manually to connect your terminal.")
            return
            
        data = response.json()
        click.echo(data.get("message", "Please check your browser to complete the login process."))
            
    except Exception as e:
        click.echo(f"Error during login: {str(e)}")
        click.echo(f"Please visit {APP_URL}/Login manually to connect your terminal.")

if __name__ == '__main__':
    main()
