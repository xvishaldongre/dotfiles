#!/usr/bin/env bash
# Install Chaotic AUR repository
# Part of arch-config declarative package management
# https://aur.chaotic.cx/

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PACMAN_CONF="/etc/pacman.conf"
CHAOTIC_REPO="chaotic-aur"

echo -e "${BLUE}Setting up Chaotic AUR repository...${NC}"

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run with sudo${NC}" >&2
    echo "Usage: sudo $0" >&2
    exit 1
fi

# Check if Chaotic AUR is already configured
if grep -q "^\[${CHAOTIC_REPO}\]" "$PACMAN_CONF"; then
    echo -e "${YELLOW}Chaotic AUR is already configured in pacman.conf${NC}"
    echo -e "${GREEN}✓ Nothing to do${NC}"
    exit 0
fi

echo -e "${BLUE}Importing Chaotic AUR keys...${NC}"

# Retrieve and sign the primary key
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB

# Install the keyring and mirrorlist packages
echo -e "${BLUE}Installing Chaotic AUR keyring and mirrorlist...${NC}"
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Add repository to pacman.conf
echo -e "${BLUE}Adding Chaotic AUR repository to pacman.conf...${NC}"

# Check if the repo section already exists (in case of partial install)
if ! grep -q "^\[${CHAOTIC_REPO}\]" "$PACMAN_CONF"; then
    cat >> "$PACMAN_CONF" << 'EOF'

# Chaotic AUR - Pre-built AUR packages
# https://aur.chaotic.cx/
# Managed by arch-config chaotic-aur module
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
fi

# Refresh package databases
echo -e "${BLUE}Refreshing package databases...${NC}"
pacman -Sy

echo ""
echo -e "${GREEN}✓ Chaotic AUR repository installed successfully!${NC}"
echo ""
echo -e "${BLUE}You can now install packages from Chaotic AUR using pacman.${NC}"
echo "Example: sudo pacman -S <package-name>"
echo ""
echo -e "${BLUE}Popular packages available from Chaotic AUR:${NC}"
echo "  - yay, paru (AUR helpers)"
echo "  - many -git packages pre-built"
echo "  - gaming tools, development packages, and more"
echo ""
