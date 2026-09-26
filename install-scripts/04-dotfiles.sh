#!/bin/bash
# ==============================================================================
# 04-dotfiles.sh
# Deploy Dotfiles, Wallpapers, and Configuration with Automated Backups
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
WALLPAPERS_DIR="$SCRIPT_DIR/Wallpapers"

echo -e "\n${CYAN}====================================================${RESET}"
echo -e "${CYAN}  Step 5: Deploying Dotfiles & Wallpapers           ${RESET}"
echo -e "${CYAN}====================================================${RESET}\n"

# 1. Create timestamped backup directory
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/.config/dotfiles_backup_$TIMESTAMP"
BACKUP_NEEDED=false

CONFIGS_TO_CHECK=("hypr" "kitty" "tide-island" "Thunar" "xfce4")
for cfg in "${CONFIGS_TO_CHECK[@]}"; do
    if [ -d "$HOME/.config/$cfg" ] || [ -f "$HOME/.config/$cfg" ]; then
        BACKUP_NEEDED=true
        break
    fi
done

for sh_file in ".bashrc" ".bash_profile" ".bash_logout"; do
    if [ -f "$HOME/$sh_file" ]; then
        BACKUP_NEEDED=true
        break
    fi
done

if [ "$BACKUP_NEEDED" = true ]; then
    echo -e "${ACTION} Existing dotfiles detected. Creating backup at: ${BACKUP_DIR}"
    mkdir -p "$BACKUP_DIR/.config"
    for cfg in "${CONFIGS_TO_CHECK[@]}"; do
        if [ -e "$HOME/.config/$cfg" ]; then
            cp -r "$HOME/.config/$cfg" "$BACKUP_DIR/.config/"
            echo -e "  ${NOTE} Backed up ~/.config/$cfg"
        fi
    done
    for sh_file in ".bashrc" ".bash_profile" ".bash_logout"; do
        if [ -f "$HOME/$sh_file" ]; then
            cp "$HOME/$sh_file" "$BACKUP_DIR/"
            echo -e "  ${NOTE} Backed up ~/$sh_file"
        fi
    done
    echo -e "${OK} Backup created successfully."
else
    echo -e "${INFO} No conflicting dotfiles detected. Proceeding cleanly."
fi

# 2. Deploy Wallpapers
echo -e "\n${ACTION} Deploying Wallpapers to '$HOME/Wallpapers'..."
mkdir -p "$HOME/Wallpapers"
if [ -d "$WALLPAPERS_DIR" ]; then
    cp -r "$WALLPAPERS_DIR/"* "$HOME/Wallpapers/"
    echo -e "${OK} Wallpapers copied to $HOME/Wallpapers"
fi

# 3. Deploy .config files
echo -e "\n${ACTION} Deploying configurations to '$HOME/.config'..."
mkdir -p "$HOME/.config/hypr"
mkdir -p "$HOME/.config/kitty/colors"
mkdir -p "$HOME/.config/tide-island"
mkdir -p "$HOME/.config/Thunar"
mkdir -p "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"

# Copy Hyprland Lua config
cp -r "$DOTFILES_DIR/.config/hypr/"* "$HOME/.config/hypr/"
echo -e "  ${OK} Installed Hyprland Lua config (~/.config/hypr/hyprland.lua)"

# Copy Kitty config & colors
cp -r "$DOTFILES_DIR/.config/kitty/"* "$HOME/.config/kitty/"
echo -e "  ${OK} Installed Kitty config (~/.config/kitty/kitty.conf)"

# Copy and patch Tide-Island config
sed "s|/home/abhiz/Wallpapers|$HOME/Wallpapers|g" "$DOTFILES_DIR/.config/tide-island/userconfig.json" > "$HOME/.config/tide-island/userconfig.json"
echo -e "  ${OK} Installed & dynamically configured Tide-Island (~/.config/tide-island/userconfig.json)"

# Copy Thunar and XFCE configs
cp -r "$DOTFILES_DIR/.config/Thunar/"* "$HOME/.config/Thunar/"
cp -r "$DOTFILES_DIR/.config/xfce4/xfconf/xfce-perchannel-xml/"* "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/"
echo -e "  ${OK} Installed Thunar & XFCE custom actions and preferences"

# Copy mimeapps.list
if [ -f "$DOTFILES_DIR/.config/mimeapps.list" ]; then
    cp "$DOTFILES_DIR/.config/mimeapps.list" "$HOME/.config/mimeapps.list"
    echo -e "  ${OK} Installed default application associations (~/.config/mimeapps.list)"
fi

# 4. Deploy Bash configs
echo -e "\n${ACTION} Deploying Shell configurations..."
for sh_file in ".bashrc" ".bash_profile" ".bash_logout"; do
    if [ -f "$DOTFILES_DIR/$sh_file" ]; then
        cp "$DOTFILES_DIR/$sh_file" "$HOME/$sh_file"
        echo -e "  ${OK} Installed ~/$sh_file"
    fi
done

# 5. Fix permissions
chmod -R u+rw "$HOME/.config/hypr" "$HOME/.config/kitty" "$HOME/.config/tide-island" "$HOME/.config/Thunar" "$HOME/Wallpapers"

echo -e "\n${OK} All dotfiles and wallpapers deployed successfully."
