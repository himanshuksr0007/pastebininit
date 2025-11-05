#!/bin/bash
# PastebinInit Installation Script
# Installs dependencies and sets up the tool

set -e  # Exit on error

echo "================================"
echo "PastebinInit - Installation"
echo "================================"
echo ""

# Check Python is installed
echo "ℹ Checking Python 3..."
if ! command -v python3 &> /dev/null; then
    echo "✗ Python 3 is not installed"
    echo ""
    echo "Install Python 3:"
    echo "  Ubuntu/Debian: sudo apt install python3"
    echo "  macOS: brew install python3"
    echo "  Windows: Download from python.org"
    exit 1
fi

PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "✓ Python $PYTHON_VERSION found"
echo ""

# Check pip is installed
echo "ℹ Checking pip3..."
if ! command -v pip3 &> /dev/null; then
    echo "✗ pip3 is not installed"
    echo ""
    echo "Install pip3:"
    echo "  Ubuntu/Debian: sudo apt install python3-pip"
    echo "  macOS: pip3 comes with Python"
    echo "  Windows: pip comes with Python"
    exit 1
fi

PIP_VERSION=$(pip3 --version 2>&1 | awk '{print $2}')
echo "✓ pip3 found"
echo ""

# Install requests library
echo "ℹ Installing Python dependencies..."
pip3 install --user requests
echo "✓ Dependencies installed"
echo ""

# Make script executable
if [ -f "pastebininit" ]; then
    echo "ℹ Making pastebininit executable..."
    chmod +x pastebininit
    echo "✓ pastebininit is now executable"
    echo ""
fi

# Create symbolic link for easier access (optional)
if [ -f "pastebininit" ]; then
    echo "ℹ Setup complete!"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Get your API key from: https://pastebin.com/doc_api"
    echo ""
    echo "2. Try your first upload:"
    echo "   python3 pastebininit --api-key YOUR_KEY --content 'Hello World'"
    echo ""
    echo "3. For more examples, see EXAMPLES.md"
    echo ""
fi

echo "================================"
echo "✓ Installation Successful!"
echo "================================"
