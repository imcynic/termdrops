"""CLI module for termdrops."""
import click
import webbrowser
import os
import uuid
import json
import time
import requests
from supabase import create_client, Client

# Your Databutton app URL
APP_URL = "https://cynic.databutton.app/termdrops"
API_URL = "https://api.databutton.com/api/routes"
SUPABASE_URL = "https://yvroxuwklsjunvymogvp.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl2cm94dXdrbHNqdW52eW1vZ3ZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk1NjQwNzEsImV4cCI6MjA1NTE0MDA3MX0.ph-LQQPpq7GmNDshwwQt3cYwIQTcf3wKvXOQ01KZpeM"

# Initialize Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

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
            f"{API_URL}/connect-terminal",
            json={
                "user_id": terminal_id,
                "command": user_id
            },
            headers={
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Origin": "cli"
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
                f"{API_URL}/process-command",
                json={
                    "user_id": terminal_id,
                    "command": "login"
                },
                headers={
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                    "Origin": "cli"
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
            click.echo("Please try again or use 'termdrops login' to connect through browser.")
            
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
                    f"{API_URL}/process-command",
                    json={
                        "user_id": terminal_id,
                        "command": "login"
                    },
                    headers={
                        "Content-Type": "application/json",
                        "Accept": "application/json",
                        "Origin": "cli"
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
                    click.echo(f"Please visit {login_url} manually to connect your terminal.")
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
