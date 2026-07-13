#!/bin/bash

# ================================
# # Base system	                 #
# ================================

sudo dnf config-manager setopt fedora-cisco-openh264.enabled=0
sudo dnf install \
	https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
	https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf group install --allowerasing \
	multimedia \
	sound-and-video
sudo dnf install --allowerasing \
	git \
	ffmpeg \
	mesa-va-drivers-freeworld \
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
	stow \
	chrony

sudo systemctl enable --now \
	bluetooth \
	power-profiles-daemon \
	chronyd

echo 60 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold
echo "w /sys/class/power_supply/BAT0/charge_control_end_threshold - - - - 60" | sudo tee /etc/tmpfiles.d/battery_limit.conf

# ================================
# # Graphics	                 #
# ================================

sudo dnf copr enable yalter/niri
sudo dnf copr enable lionheartp/Hyprland
sudo dnf copr enable lukenukem/asus-linux

sudo dnf install \
	niri \
	noctalia \
	greetd \
	noctalia-greeter \
	asusctl \
	mate-polkit \
	libinput \
	brightnessctl \
	xdg-desktop-portal-gnome \
	xorg-x11-server-Xwayland

sudo systemctl enable --now asusd.service
