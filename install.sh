#!/bin/bash

# ==============================================================================
# # Error Handling & Logging Setup
# ==============================================================================

set -e
set -o pipefail

LOG_FILE="$HOME/fedora_setup.log"

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

echo -e "${GREEN}🚀 Starting Fedora 44 setup... Full log will be saved to: $LOG_FILE${NC}"

# ==============================================================================
# # Repositories Setup
# ==============================================================================

echo -e "\n${GREEN}📦 Configuring repositories...${NC}"

# Disable the default Cisco openh264 repo (dnf5 syntax)
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=0

# Install RPM Fusion (Free and Non-free)
sudo dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Refresh metadata after adding new repos (dnf5)
sudo dnf clean metadata
sudo dnf makecache --refresh

# Enable required COPR repositories
sudo dnf copr enable -y yalter/niri
sudo dnf copr enable -y lukenukem/asus-linux
sudo dnf copr enable -y scottames/ghostty
sudo dnf copr enable -y materka/starship

# ==============================================================================
# # Package Installation (Single DNF Transaction)
# ==============================================================================

echo -e "\n${GREEN}📥 Installing system groups and multimedia codecs...${NC}"
sudo dnf group install -y --allowerasing multimedia sound-and-video

echo -e "\n${GREEN}📥 Installing applications, fonts, and drivers...${NC}"
sudo dnf install -y --allowerasing \
    git \
    ffmpeg \
    mesa-va-drivers-freeworld \
    mesa-va-drivers-freeworld.i686 \
    mesa-vulkan-drivers \
    pipewire \
    pipewire-utils \
    pipewire-pulse \
    pipewire-alsa \
    wireplumber \
    bluez \
    libheif-freeworld \
    power-profiles-daemon \
    zram-generator \
    niri \
    noctalia \
    greetd \
    noctalia-greeter \
    asusctl \
    supergfxctl \
    mate-polkit \
    libinput \
    brightnessctl \
    xdg-desktop-portal-gnome \
    xorg-x11-server-Xwayland \
    jetbrains-mono-fonts \
    fish \
    starship \
    fastfetch \
    btop \
    ghostty \
    firefox \
    helix

# ==============================================================================
# # System Services & Hardware Tweaks
# ==============================================================================

echo -e "\n${GREEN}⚙️ Configuring system services and hardware...${NC}"

# Enable core services
sudo systemctl enable --now bluetooth power-profiles-daemon

# Enable ASUS-specific services if they exist
if systemctl list-unit-files | grep -q asusd; then
    sudo systemctl enable --now asusd.service
fi

if systemctl list-unit-files | grep -q supergfxd; then
    sudo systemctl enable --now supergfxd.service
fi

# Apply battery charge limit (only if BAT0 interface is present)
if [ -d "/sys/class/power_supply/BAT0" ]; then
    echo "Configuring BAT0 threshold..."
    echo 60 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold
    echo "w /sys/class/power_supply/BAT0/charge_control_end_threshold - - - - 60" | sudo tee /etc/tmpfiles.d/battery_limit.conf
else
    echo "BAT0 interface not found. Skipping battery limit configuration."
fi

# Add current user to 'video' group to control brightness via brightnessctl without sudo
if ! groups "$USER" | grep -q "\bvideo\b"; then
    echo "Adding $USER to 'video' group for hardware brightness control..."
    sudo usermod -aG video "$USER"
fi

# Change default shell to Fish for the current user
if [ "$SHELL" != "$(which fish)" ]; then
    echo "Changing default shell to Fish..."
    chsh -s "$(which fish)"
fi

echo -e "\n${GREEN}🎉 System setup completed successfully!${NC}"
echo -e "You might need to log out or reboot for some changes to take effect (e.g., group membership, shell change)."
