#!/bin/bash
# ==============================================================================
# 03-sddm-theme.sh
# Display Manager (SDDM) and Astronaut Theme Configuration
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
echo -e "${CYAN}  Step 4: SDDM Display Manager & Theme Setup        ${RESET}"
echo -e "${CYAN}====================================================${RESET}\n"

# Check if SDDM package is installed
if ! pacman -Qi sddm &>/dev/null; then
    echo -e "${ACTION} Installing SDDM..."
    sudo pacman -S --needed --noconfirm sddm qt5-quickcontrols2 qt5-svg qt5-graphicaleffects
fi

# Disable conflicting display managers
for dm in gdm lightdm lxdm slim; do
    if systemctl is-enabled "${dm}.service" &>/dev/null; then
        echo -e "${WARN} Disabling conflicting display manager: ${dm}"
        sudo systemctl disable "${dm}.service"
    fi
done

# Enable SDDM service
echo -e "${ACTION} Enabling SDDM service..."
sudo systemctl enable sddm.service
echo -e "${OK} sddm.service enabled."

# Prompt or install Astronaut SDDM theme
echo -e "\n${ACTION} Installing SDDM Astronaut Theme..."
if curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh | bash; then
    echo -e "${OK} SDDM Astronaut Theme installed via setup script."
else
    echo -e "${NOTE} Fallback: Cloning SDDM Astronaut Theme directly from GitHub..."
    THEME_DIR="/usr/share/sddm/themes/sddm-astronaut-theme"
    sudo git clone --depth 1 https://github.com/keyitdev/sddm-astronaut-theme.git "$THEME_DIR" 2>/dev/null || true
    
    # Configure SDDM theme
    sudo mkdir -p /etc/sddm.conf.d
    cat << 'CONF' | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null
[Theme]
Current=sddm-astronaut-theme
CONF
    echo -e "${OK} SDDM theme set to sddm-astronaut-theme."
fi

echo -e "\n${OK} SDDM setup completed successfully."
