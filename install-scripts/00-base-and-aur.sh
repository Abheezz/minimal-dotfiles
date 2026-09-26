#!/bin/bash
# ==============================================================================
# 00-base-and-aur.sh
# System Validation, Base Packages, and AUR Helper Setup
# ==============================================================================

set -e

# ANSI Colors
OK="[32m[OK][0m"
ERROR="[31m[ERROR][0m"
NOTE="[33m[NOTE][0m"
INFO="[34m[INFO][0m"
WARN="[31m[WARN][0m"
ACTION="[36m[ACTION][0m"
MAGENTA="[35m"
ORANGE="[38;5;214m"
YELLOW="[33m"
GREEN="[32m"
BLUE="[34m"
CYAN="[36m"
BOLD="[1m"
RESET="[0m"

echo -e "\n${CYAN}====================================================${RESET}"
echo -e "${CYAN}  Step 1: System Checks & AUR Helper Setup          ${RESET}"
echo -e "${CYAN}====================================================${RESET}\n"

# 1. Non-root verification
if [ "$EUID" -eq 0 ]; then
    echo -e "${ERROR} Do not run this script as root! Please run as your regular user with sudo privileges."
    exit 1
fi

# 2. Arch Linux verification
if [ ! -f /etc/arch-release ]; then
    echo -e "${WARN} Non-Arch Linux system detected (/etc/arch-release not found)."
    echo -e "${NOTE} This installer is configured specifically for Arch Linux."
    read -rp "Do you still want to proceed? [y/N]: " proceed
    if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
        echo -e "${ERROR} Aborted by user."
        exit 1
    fi
else
    echo -e "${OK} Arch Linux verified."
fi

# 3. Synchronize package database
echo -e "\n${ACTION} Synchronizing pacman database..."
sudo pacman -Sy

# 4. Check & install base development tools
BASE_PKGS=("base-devel" "git" "curl" "wget" "pciutils" "jq")
PKGS_TO_INSTALL=()

for pkg in "${BASE_PKGS[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        PKGS_TO_INSTALL+=("$pkg")
    fi
done

if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
    echo -e "${ACTION} Installing essential base packages: ${PKGS_TO_INSTALL[*]}"
    sudo pacman -S --needed --noconfirm "${PKGS_TO_INSTALL[@]}"
    echo -e "${OK} Essential base packages installed."
else
    echo -e "${OK} Essential base packages already installed."
fi

# 5. Detect or install AUR helper (yay or paru)
AUR_HELPER=""
if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
    echo -e "${OK} AUR Helper detected: yay ($(yay --version | head -n1))"
elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
    echo -e "${OK} AUR Helper detected: paru ($(paru --version | head -n1))"
else
    echo -e "\n${NOTE} No AUR helper detected. Installing 'yay-bin'..."
    BUILD_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$BUILD_DIR/yay-bin"
    cd "$BUILD_DIR/yay-bin"
    makepkg -si --noconfirm
    cd - >/dev/null
    rm -rf "$BUILD_DIR"
    
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
        echo -e "${OK} yay installed successfully!"
    else
        echo -e "${ERROR} Failed to install yay automatically. Please install an AUR helper manually."
        exit 1
    fi
fi

# Export AUR_HELPER for subsequent scripts
export AUR_HELPER
echo -e "\n${OK} System validation and AUR helper setup completed successfully."
