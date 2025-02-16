"""CLI module for termdrops."""
import click
import webbrowser
import requests
import os

# Your Databutton app URL
APP_URL = "https://cynic.databutton.app/termdrops"
API_URL = f"{APP_URL}/api"

@click.group()
def main():
    """TermDrops CLI - Collect pets while using your terminal."""
    pass

@main.command()
def login():
    """Connect to your TermDrops account."""
    click.echo("Opening TermDrops dashboard in your browser...")
    click.echo("Please follow the instructions to connect your terminal.")
    
    try:
        # Try to open the dashboard
        webbrowser.open(f"{APP_URL}/Dashboard")
        
        # Send login command to API
        response = requests.post(
            f"{API_URL}/process-command",
            json={
                "user_id": "cli-login",
                "command": "login"
            }
        )
        
        if response.status_code != 200:
            click.echo(f"Error during login: {response.status_code} {response.reason} for url: {response.url}")
            return
            
    except Exception as e:
        click.echo(f"Error during login: {str(e)}")

if __name__ == '__main__':
    main()
