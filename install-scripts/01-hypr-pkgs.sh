#!/bin/bash
# ==============================================================================
# 01-hypr-pkgs.sh
# Core Hyprland Desktop, Audio, Fonts, and System Utility Packages
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
echo -e "${CYAN}  Step 2: Installing Official Arch Linux Packages   ${RESET}"
echo -e "${CYAN}====================================================${RESET}\n"

# Check if PulseAudio is installed, as PipeWire replaces it
if pacman -Qq | grep -qw '^pulseaudio$'; then
    echo -e "${WARN} Legacy 'pulseaudio' detected! Pipewire-pulse is required for modern Wayland audio."
    read -rp "Replace pulseaudio with pipewire-pulse? [Y/n]: " replace_pulse
    if [[ ! "$replace_pulse" =~ ^[Nn]$ ]]; then
        sudo pacman -Rdd --noconfirm pulseaudio pulseaudio-bluetooth pulseaudio-alsa 2>/dev/null || true
    fi
fi

# Package groups
HYPR_CORE=(
    "hyprland"
    "xdg-desktop-portal-hyprland"
    "xdg-desktop-portal-gtk"
    "polkit-kde-agent"
    "qt5-wayland"
    "qt6-wayland"
    "qt5ct"
    "qt6ct"
)

AUDIO_STACK=(
    "pipewire"
    "pipewire-pulse"
    "pipewire-alsa"
    "pipewire-jack"
    "wireplumber"
)

APPS_AND_TOOLS=(
    "kitty"
    "rofi-wayland"
    "thunar"
    "thunar-volman"
    "thunar-archive-plugin"
    "tumbler"
    "gvfs"
    "awww"
    "brightnessctl"
    "playerctl"
    "wl-clipboard"
    "libnotify"
    "nano"
    "vim"
)

FONTS=(
    "ttf-jetbrains-mono-nerd"
    "ttf-font-awesome"
    "noto-fonts"
    "noto-fonts-emoji"
    "noto-fonts-cjk"
)

DISPLAY_MANAGER=(
    "sddm"
)

ALL_PACKAGES=("${HYPR_CORE[@]}" "${AUDIO_STACK[@]}" "${APPS_AND_TOOLS[@]}" "${FONTS[@]}" "${DISPLAY_MANAGER[@]}")

# Filter out already installed packages
PKGS_TO_INSTALL=()
for pkg in "${ALL_PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        PKGS_TO_INSTALL+=("$pkg")
    fi
done

if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
    echo -e "${ACTION} Installing (${#PKGS_TO_INSTALL[@]}) packages: ${PKGS_TO_INSTALL[*]}\n"
    sudo pacman -S --needed --noconfirm "${PKGS_TO_INSTALL[@]}"
    echo -e "\n${OK} Official packages successfully installed."
else
    echo -e "${OK} All official packages are already installed."
fi

# Enable PipeWire user services
echo -e "\n${ACTION} Configuring PipeWire sound service for user..."
systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || true

echo -e "${OK} Official packages step completed successfully."
