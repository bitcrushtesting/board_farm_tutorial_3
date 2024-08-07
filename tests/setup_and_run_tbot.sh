#!/bin/bash

# Copyright © 2024 Bitcrush Testing

# Define variables
VENV_DIR="tbot_venv"
TBOT_TEST_SCRIPT="tbot_test.py"

# Step 1: Create a Python virtual environment
echo "Creating Python virtual environment"
python3 -m venv "$VENV_DIR"

# Step 2: Activate the virtual environment
echo "Activating virtual environment"
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

# Step 3: Upgrade pip to the latest version
echo "Upgrading pip"
pip install --upgrade pip

# Step 4: Install tbot
echo "Installing tbot"
pip install tbot

# Step 5: Run the tbot test script
if [ -f "$TBOT_TEST_SCRIPT" ]; then
    echo "Running tbot test script"
    python "$TBOT_TEST_SCRIPT"
else
    echo "Test script $TBOT_TEST_SCRIPT not found!"
fi

# Step 6: Deactivate the virtual environment
echo "Deactivating virtual environment..."
deactivate

echo "----- DONE -----"
