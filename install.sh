#!/bin/bash
# ==============================================================================
# Arch Linux + Hyprland (Lua) Dotfiles & Environment Installer
# Inspired by JaKooLit/Arch-Hyprland
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Ensure install logs directory exists
mkdir -p Install-Logs
LOG="Install-Logs/install-$(date +%Y%m%d-%H%M%S).log"

# Log redirect helper
log_msg() {
    echo -e "$1" | tee -a "$LOG"
}

# Banner
print_banner() {
    clear
    echo -e "${MAGENTA}${BOLD}"
    cat << "BANNER"
  █████╗ ██████╗  ██████╗██╗  ██╗    ██╗  ██╗██╗   ██╗██████╗ ██████╗ 
 ██╔══██╗██╔══██╗██╔════╝██║  ██║    ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗
 ███████║██████╔╝██║     ███████║    ███████║ ╚████╔╝ ██████╔╝██████╔╝
 ██╔══██║██╔══██╗██║     ██╔══██║    ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗
 ██║  ██║██║  ██║╚██████╗██║  ██║    ██║  ██║   ██║   ██║     ██║  ██║
 ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝
BANNER
    echo -e "${CYAN}           Arch Linux + Hyprland (Lua) Dotfiles Installer${RESET}"
    echo -e "${YELLOW}           Hyprland • Tide-Island • Kitty • SDDM • Awww${RESET}\n"
}

# Help menu
show_help() {
    cat << HELP
Usage: ./install.sh [OPTIONS]

Options:
  -h, --help        Show this help message and exit
  -y, --noconfirm   Run unattended without confirmation prompts
  --only-dots       Deploy dotfiles and wallpapers only (skip package installations)
  --skip-sddm       Skip SDDM display manager and Astronaut theme installation
  --skip-gpu        Skip GPU detection and driver configuration
HELP
    exit 0
}

# Default flag options
NOCONFIRM=false
ONLY_DOTS=false
SKIP_SDDM=false
SKIP_GPU=false

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help) show_help ;;
        -y|--noconfirm) NOCONFIRM=true; shift ;;
        --only-dots) ONLY_DOTS=true; shift ;;
        --skip-sddm) SKIP_SDDM=true; shift ;;
        --skip-gpu) SKIP_GPU=true; shift ;;
        *) echo "Unknown option: $1"; show_help ;;
    esac
done

print_banner

# Check EUID
if [ "$EUID" -eq 0 ]; then
    log_msg "${ERROR} This script must ${YELLOW}NOT${RESET} be run as root!"
    log_msg "${NOTE} Please execute as your standard user with sudo permissions."
    exit 1
fi

log_msg "${INFO} Installation log initialized at: ${BOLD}${LOG}${RESET}"

# Confirm installation unless unattended
if [ "$NOCONFIRM" = false ]; then
    echo -e "${YELLOW}This script will configure Arch Linux with:${RESET}"
    echo -e "  • Hyprland with Lua configuration (~/.config/hypr/hyprland.lua)"
    echo -e "  • Tide-Island dynamic island desktop bar & quickshell"
    echo -e "  • Kitty terminal with JetBrainsMono Nerd Font"
    echo -e "  • Awww Wayland wallpaper daemon & custom wallpapers (~/Wallpapers)"
    echo -e "  • Rofi launcher, Thunar file manager, Cliphist, Hyprshot"
    echo -e "  • PipeWire & WirePlumber modern audio stack"
    echo -e "  • SDDM display manager with Astronaut Theme"
    echo -e "  • Automated safety backup of any existing configs to ~/.config/dotfiles_backup_*\n"
    
    read -rp "Ready to proceed with installation? [Y/n]: " proceed
    if [[ "$proceed" =~ ^[Nn]$ ]]; then
        log_msg "\n${WARN} Installation aborted by user."
        exit 0
    fi
fi

# Execute script helper with logging
run_step() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/install-scripts/$script_name"
    
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        log_msg "\n${ACTION} Executing: ${script_name}..."
        if bash "$script_path" 2>&1 | tee -a "$LOG"; then
            log_msg "${OK} Step '${script_name}' finished successfully."
        else
            log_msg "${ERROR} Step '${script_name}' encountered an error!"
            read -rp "Do you wish to continue despite errors? [y/N]: " cont
            if [[ ! "$cont" =~ ^[Yy]$ ]]; then
                log_msg "${ERROR} Installation halted."
                exit 1
            fi
        fi
    else
        log_msg "${ERROR} Script not found: $script_path"
        exit 1
    fi
}

# Main Execution Flow
if [ "$ONLY_DOTS" = true ]; then
    log_msg "${INFO} Fast-track: Only deploying dotfiles and wallpapers..."
    run_step "04-dotfiles.sh"
else
    # Step 1: Base and AUR helper
    run_step "00-base-and-aur.sh"

    # Step 2: Official pacman packages
    run_step "01-hypr-pkgs.sh"

    # Step 3: AUR packages
    run_step "02-aur-pkgs.sh"

    # Step 4: SDDM and Theme
    if [ "$SKIP_SDDM" = false ]; then
        run_step "03-sddm-theme.sh"
    else
        log_msg "${INFO} Skipping SDDM installation (--skip-sddm)."
    fi

    # Step 5: Dotfiles deployment
    run_step "04-dotfiles.sh"

    # Step 6: GPU Check
    if [ "$SKIP_GPU" = false ]; then
        run_step "05-gpu-check.sh"
    else
        log_msg "${INFO} Skipping GPU check (--skip-gpu)."
    fi
fi

# Final Summary
echo -e "\n${GREEN}================================================================${RESET}"
echo -e "${GREEN}${BOLD}     Installation & Dotfiles Setup Completed Successfully!     ${RESET}"
echo -e "${GREEN}================================================================${RESET}\n"

cat << "SUMMARY"
✨ What was configured:
  1. Hyprland (Lua)       : ~/.config/hypr/hyprland.lua
  2. Tide-Island Bar      : ~/.config/tide-island/userconfig.json (linked to ~/Wallpapers)
  3. Kitty Terminal       : ~/.config/kitty/kitty.conf (with Catppuccin color scheme)
  4. File Manager         : ~/.config/Thunar & ~/.config/xfce4 (custom actions)
  5. Wallpapers           : ~/Wallpapers/ (managed via awww-daemon)
  6. SDDM Login Manager   : Enabled with Astronaut Theme

⌨️  Key Keybindings Cheat Sheet:
  • ALT + RETURN          : Open Kitty Terminal
  • ALT + SPACE           : Open Application Launcher (Rofi)
  • ALT + E               : Open Thunar File Manager
  • ALT + Q               : Close Active Window
  • ALT + F               : Toggle Floating Window
  • ALT + SHIFT + S       : Region Screenshot (Hyprshot to clipboard)
  • ALT + Tab             : Toggle Tide-Island Workspace Overview
  • ALT + C               : Toggle Tide-Island Control Center
  • ALT + P               : Toggle Tide-Island Power Menu
  • ALT + N               : Toggle Tide-Island Notification Center
  • ALT + W               : Toggle Tide-Island Wallpaper Picker
  • ALT + V               : Toggle Clipboard History
  • ALT + [1-9]           : Switch to Workspace [1-9]
  • ALT + SHIFT + [1-9]   : Move Window to Workspace [1-9]

SUMMARY

log_msg "${NOTE} It is recommended to reboot your system to start SDDM and Hyprland cleanly."
if [ "$NOCONFIRM" = false ]; then
    read -rp "Would you like to reboot now? [y/N]: " reboot_now
    if [[ "$reboot_now" =~ ^[Yy]$ ]]; then
        log_msg "${ACTION} Rebooting system..."
        sudo reboot
    fi
fi

echo -e "\n${OK} Enjoy your new Hyprland setup!\n"
