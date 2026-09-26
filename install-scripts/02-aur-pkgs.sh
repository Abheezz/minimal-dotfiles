#!/bin/bash
# ==============================================================================
# 02-aur-pkgs.sh
# AUR Packages: quickshell, tide-island, hyprshot, cliphist
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
echo -e "${CYAN}  Step 3: Installing AUR Packages                   ${RESET}"
echo -e "${CYAN}====================================================${RESET}\n"

# Resolve AUR helper
AUR_HELPER=""
if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
else
    echo -e "${ERROR} Neither 'yay' nor 'paru' is installed. Please run 00-base-and-aur.sh first."
    exit 1
fi

echo -e "${INFO} Using AUR helper: ${AUR_HELPER}"

# List of AUR packages required for this Hyprland dotfile configuration
AUR_PACKAGES=(
    "quickshell"
    "tide-island"
    "hyprshot"
    "cliphist"
)

PKGS_TO_INSTALL=()
for pkg in "${AUR_PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null && ! pacman -Qi "${pkg}-git" &>/dev/null; then
        PKGS_TO_INSTALL+=("$pkg")
    fi
done

if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
    echo -e "${ACTION} Installing AUR packages: ${PKGS_TO_INSTALL[*]}"
    for pkg in "${PKGS_TO_INSTALL[@]}"; do
        echo -e "\n${ACTION} Installing '$pkg' from AUR..."
        if ! $AUR_HELPER -S --needed --noconfirm "$pkg"; then
            echo -e "${WARN} Direct install of '$pkg' failed. Trying '${pkg}-git'..."
            if ! $AUR_HELPER -S --needed --noconfirm "${pkg}-git"; then
                echo -e "${ERROR} Failed to install '$pkg' or '${pkg}-git' from AUR."
            else
                echo -e "${OK} '${pkg}-git' installed successfully."
            fi
        else
            echo -e "${OK} '$pkg' installed successfully."
        fi
    done
else
    echo -e "${OK} All AUR packages are already installed."
fi

echo -e "\n${OK} AUR packages installation completed."
