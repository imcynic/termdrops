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
API_URL = "https://api.databutton.com/_projects/f9e24496-ea7b-4714-b109-1aaf70a5bfee/dbtn/prodx/app/routes"  # Direct API URL

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
