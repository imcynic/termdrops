#!/bin/bash

# TermDrops Installation Script
set -e

echo "Installing TermDrops CLI..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed."
    exit 1
fi

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    echo "Error: pip3 is required but not installed."
    exit 1
fi

# Create virtual environment
PYTHON_VENV="$HOME/.termdrops"
echo "Creating virtual environment at $PYTHON_VENV..."
python3 -m venv "$PYTHON_VENV"

# Activate virtual environment
source "$PYTHON_VENV/bin/activate"

# Install TermDrops
echo "Installing TermDrops package..."
pip install --upgrade pip
pip install termdrops

# Create wrapper script
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

cat > "$BIN_DIR/termdrops" << 'EOFWRAPPER'
#!/bin/bash
source "$HOME/.termdrops/bin/activate"
python -m termdrops "$@"
EOFWRAPPER

chmod +x "$BIN_DIR/termdrops"

# Add to PATH if needed
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc" 2>/dev/null || true
    export PATH="$HOME/.local/bin:$PATH"
fi

echo ""
echo "TermDrops CLI installed successfully!"
echo "Run 'termdrops login' to connect to your account."
