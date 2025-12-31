#!/bin/bash

# Detect OS
OS_TYPE=$(uname)
DOTFILES_DIR=$(pwd)

echo "Setting up dotfiles for $OS_TYPE..."

# 1. Ensure config dir exists
mkdir -p ~/.config

# 2. Stow common configs
# We CD into common so Stow treats subfolders (nvim, etc) as packages
cd "$DOTFILES_DIR/common"
stow . -t ~/.config
stow -t ~ -R zshrc --adopt

# 3. Stow OS-specific configs
cd "$DOTFILES_DIR"
if [[ "$OS_TYPE" == "Darwin" ]]; then
    echo "Applying macOS configs..."
    cd macos && stow . -t ~/.config --adopt
elif [[ "$OS_TYPE" == "Linux" ]]; then
    echo "Applying Linux configs..."
    cd linux && stow . -t ~/.config --adopt
fi

echo "Done!" 
