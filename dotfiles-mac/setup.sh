#!/usr/bin/env bash

# # Install homebrew
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# # Install bundle and all packages
# brew bundle --file=homebrew/Brewfile

# Symlink all the files
[[ ! -d ~/.config ]] && mkdir ~/.config
stow .
stow -t ~ zshrc --adopt