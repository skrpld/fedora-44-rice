#!/bin/bash

# ==============================================================================
# Error Handling & Logging Setup
# ==============================================================================

set -e
set -o pipefail

# Log to the same folder as this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/fedora_setup.log"

exec > >(tee -i "$LOG_FILE")
exec 2>&1

failure_handler() {
    local exit_code=$?
    local line_no=$1
    local command="$2"

    echo -e "\n\e[1;31m─────────────────────────────────────────────────────────────────\e[0m"
    echo -e "\e[1;31m✖ ERROR: Setup failed!\e[0m"
    echo -e "\e[1;31mCommand: '$command' on line $line_no exited with status $exit_code.\e[0m"
    echo -e "\e[1;31m─────────────────────────────────────────────────────────────────\e[0m"
    echo -e "📄 You can inspect the full log here: \e[1;33m$LOG_FILE\e[0m\n"
    exit "$exit_code"
}

trap 'failure_handler ${LINENO} "$BASH_COMMAND"' ERR

GREEN='\e[1;32m'
NC='\e[0m'

echo -e "${GREEN}🚀 Starting Fedora setup... Full log will be saved to: $LOG_FILE${NC}"

# ==============================================================================
# Repositories Setup
# ==============================================================================

echo -e "\n${GREEN}📦 Configuring repositories...${NC}"

# Enable required COPR repositories
sudo dnf copr enable -y scottames/ghostty

# ==============================================================================
# Package Installation
# ==============================================================================

echo -e "\n${GREEN}📥 Installing shell, WM, and user applications...${NC}"
sudo dnf install -y --allowerasing \
    zsh \
    zsh-syntax-highlighting \
    zsh-autosuggestions \
    starship \
    fastfetch \
    btop \
    jetbrains-mono-fonts \
    bibata-cursor-themes \
    ghostty \
    firefox \
    helix

# ==============================================================================
# System Services & User Configuration
# ==============================================================================

echo -e "\n${GREEN}⚙️ Configuring services and user settings...${NC}"

# Change default shell to Zsh for the current user
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to Zsh..."
    chsh -s "$(which zsh)"
fi

echo -e "\n${GREEN}🎉 Setup completed successfully!${NC}"
echo -e "Log out or reboot for changes to take effect (group membership, shell change)."
