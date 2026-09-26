#!/bin/bash
# ==============================================================================
# 05-gpu-check.sh
# GPU Hardware Detection and Driver Configuration Guidance
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
echo -e "${CYAN}  Step 6: GPU Detection & Wayland Configuration     ${RESET}"
echo -e "${CYAN}====================================================${RESET}\n"

GPU_INFO=$(lspci -nn | grep -Ei 'vga|3d|display' || true)
echo -e "${INFO} Detected Graphics Hardware:"
echo -e "${GPU_INFO}\n"

IS_NVIDIA=false
IS_AMD=false
IS_INTEL=false

if echo "$GPU_INFO" | grep -iq "nvidia"; then
    IS_NVIDIA=true
fi
if echo "$GPU_INFO" | grep -iq "amd\|radeon\|ati"; then
    IS_AMD=true
fi
if echo "$GPU_INFO" | grep -iq "intel"; then
    IS_INTEL=true
fi

# NVIDIA Specific Handling
if [ "$IS_NVIDIA" = true ]; then
    echo -e "${WARN} NVIDIA Graphics Card detected!"
    echo -e "${NOTE} For Hyprland to run smoothly on NVIDIA hardware, ensure you have:"
    echo -e "  1. 'nvidia-dkms' (or 'nvidia') and 'linux-headers'"
    echo -e "  2. 'nvidia-utils' and 'libva-nvidia-driver'"
    echo -e "  3. Kernel parameter 'nvidia_drm.modeset=1'"
    echo -e "  4. Wayland environment variables set in hyprland.lua"
    
    read -rp "Would you like to automatically configure NVIDIA environment variables in hyprland.lua? [Y/n]: " setup_nvidia
    if [[ ! "$setup_nvidia" =~ ^[Nn]$ ]]; then
        HYPR_LUA="$HOME/.config/hypr/hyprland.lua"
        if [ -f "$HYPR_LUA" ]; then
            if ! grep -q "LIBVA_DRIVER_NAME" "$HYPR_LUA"; then
                echo -e "\n-- NVIDIA Environment Variables" >> "$HYPR_LUA"
                echo -e 'hl.env("LIBVA_DRIVER_NAME", "nvidia")' >> "$HYPR_LUA"
                echo -e 'hl.env("GBM_BACKEND", "nvidia-drm")' >> "$HYPR_LUA"
                echo -e 'hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")' >> "$HYPR_LUA"
                echo -e 'hl.env("NVD_BACKEND", "direct")' >> "$HYPR_LUA"
                echo -e "${OK} NVIDIA environment variables appended to ~/.config/hypr/hyprland.lua"
            else
                echo -e "${OK} NVIDIA environment variables already present in hyprland.lua."
            fi
        fi
        
        # Check if packages installed
        if ! pacman -Qi nvidia-utils &>/dev/null; then
            read -rp "Install nvidia-dkms, linux-headers, and nvidia-utils now? [y/N]: " install_nv
            if [[ "$install_nv" =~ ^[Yy]$ ]]; then
                sudo pacman -S --needed --noconfirm nvidia-dkms linux-headers nvidia-utils libva-nvidia-driver
                echo -e "${OK} NVIDIA driver packages installed."
            fi
        fi
    fi
fi

if [ "$IS_AMD" = true ]; then
    echo -e "${OK} AMD Graphics detected. Wayland works out-of-the-box with 'mesa' and 'vulkan-radeon'."
fi

if [ "$IS_INTEL" = true ]; then
    echo -e "${OK} Intel Graphics detected. Wayland works out-of-the-box with 'mesa' and 'vulkan-intel'."
fi

echo -e "\n${OK} GPU check and configuration completed."
