#!/bin/bash

# Clipboard logger script
LOG_FILE=~/my-logs.txt
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Print header
echo "=====================$TIMESTAMP ====================================================================" >>"$LOG_FILE"

# Append clipboard content
pbpaste >>"$LOG_FILE"

# Optional: Add a newline after each entry
echo -e "\n====================================================================================================" >>"$LOG_FILE"
