"""CLI module for termdrops."""
import click
import webbrowser
import requests
import os

# Your Databutton app URL
APP_URL = "https://cynic.databutton.app/termdrops"
API_URL = f"{APP_URL}/api/drops"  # Updated to include the 'drops' part

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
        dashboard_url = f"{APP_URL}/Dashboard"
        webbrowser.open(dashboard_url)
        
        # Send login command to API
        response = requests.post(
            f"{API_URL}/process-command",  # This now becomes /api/drops/process-command
            json={
                "user_id": "cli-login",
                "command": "login"
            },
            headers={
                "Content-Type": "application/json",
                "Accept": "application/json"
            }
        )
        
        if response.status_code != 200:
            click.echo(f"Error during login: {response.status_code} {response.reason}")
            click.echo(f"Please visit {dashboard_url} manually to connect your terminal.")
            return
            
        data = response.json()
        click.echo(data.get("message", "Please check your browser to complete the login process."))
            
    except Exception as e:
        click.echo(f"Error during login: {str(e)}")
        click.echo(f"Please visit {dashboard_url} manually to connect your terminal.")

if __name__ == '__main__':
    main()
