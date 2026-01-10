#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle GPU Switch
# @raycast.mode silent

# Optional parameters:
# @raycast.argument1 { "type": "password", "placeholder": "password" }
# @raycast.icon 🤖
# @raycast.packageName System

# Documentation:
# @raycast.author Claudiu Ivan
# @raycast.authorURL https://raycast.com/kioku

# Check if running with sudo
# if [ "$EUID" -ne 0 ]; then 
#     echo "Please run as root (using sudo)"
#     exit 1
# fi

# Get the current graphics switch setting
# Get the current graphics switch setting and extract just the numeric value
current_setting=$(pmset -g | grep gpuswitch | sed 's/.*gpuswitch[[:space:]]*\([0-2]\).*/\1/' || echo "")

if [ -z "$current_setting" ]; then
    echo "Error: Could not detect GPU switching settings"
    exit 1
fi

echo "Current setting: $current_setting"

# Check the current setting and toggle it
if [ "$current_setting" = "2" ]; then
    echo "Disabling automatic graphics switching..."
    echo -e "\n$1" | sudo -S pmset -a gpuswitch 0
    # ... rest of the script remains the same
    if [ $? -eq 0 ]; then
        echo "Successfully disabled automatic graphics switching"
    else
        echo "Error: Failed to disable automatic graphics switching"
        exit 1
    fi
else
    echo "Enabling automatic graphics switching..."
    echo -e "\n$1" | sudo -S pmset -a gpuswitch 2
    if [ $? -eq 0 ]; then
        echo "Successfully enabled automatic graphics switching"
    else
        echo "Error: Failed to enable automatic graphics switching"
        exit 1
    fi
fi
