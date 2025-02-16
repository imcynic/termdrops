# TermDrops

A terminal-based game that runs in both PowerShell and Unix terminals.

## Installation

### Windows (PowerShell)
```powershell
iwr -useb https://raw.githubusercontent.com/imcynic/termdrops/main/scripts/install.ps1 | iex
```

### Unix (Linux/macOS)
```bash
curl -fsSL https://raw.githubusercontent.com/imcynic/termdrops/main/scripts/install.sh | bash
```

## Requirements
- Python 3.7 or higher
- pip (Python package installer)

## Development
To set up the development environment:

1. Clone the repository:
   ```bash
   git clone https://github.com/imcynic/termdrops.git
   cd termdrops
   ```

2. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # Unix
   # or
   .\venv\Scripts\Activate.ps1  # Windows
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

## License
[MIT License](LICENSE)
