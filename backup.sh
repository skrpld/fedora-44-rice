#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_SUFFIX=".bak.$TIMESTAMP"

GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
NC='\e[0m'

log()  { echo -e "${GREEN}[BACKUP]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }

# dotfiles_relative_path -> system_absolute_path
declare -A CONFIGS=(
    [".config/fish/config.fish"]="$HOME/.config/fish/config.fish"
    [".config/starship.toml"]="$HOME/.config/starship.toml"
    [".config/niri/config.kdl"]="$HOME/.config/niri/config.kdl"
    [".config/ghostty/config"]="$HOME/.config/ghostty/config"
    [".config/helix/config.toml"]="$HOME/.config/helix/config.toml"
    [".config/helix/languages.toml"]="$HOME/.config/helix/languages.toml"
    [".config/fastfetch/config.jsonc"]="$HOME/.config/fastfetch/config.jsonc"
    [".config/btop/btop.conf"]="$HOME/.config/btop/btop.conf"
    [".config/btop/themes"]="$HOME/.config/btop/themes"
    ["etc/greetd/config.toml"]="/etc/greetd/config.toml"
    ["etc/asusd/asusd.conf"]="/etc/asusd/asusd.conf"
    ["etc/tmpfiles.d/battery_limit.conf"]="/etc/tmpfiles.d/battery_limit.conf"
    ["etc/systemd/zram-generator.conf.d/zram0.conf"]="/etc/systemd/zram-generator.conf.d/zram0.conf"
)

mkdir -p "$DOTFILES_DIR"

for rel_path in "${!CONFIGS[@]}"; do
    sys_path="${CONFIGS[$rel_path]}"
    dot_path="$DOTFILES_DIR/$rel_path"

    if [[ ! -e "$sys_path" ]]; then
        info "Skipped (not found): $sys_path"
        continue
    fi

    mkdir -p "$(dirname "$dot_path")"

    if [[ -e "$dot_path" ]]; then
        mv "$dot_path" "$dot_path$BACKUP_SUFFIX"
        warn "Renamed existing in dotfiles: $rel_path -> ${rel_path}${BACKUP_SUFFIX}"
    fi

    if [[ "$sys_path" == /etc/* ]]; then
        if [[ -d "$sys_path" ]]; then
            sudo cp -r "$sys_path" "$dot_path"
        else
            sudo cp -a "$sys_path" "$dot_path"
        fi
        sudo chown -R "$(id -u):$(id -g)" "$dot_path" 2>/dev/null || true
    else
        if [[ -d "$sys_path" ]]; then
            cp -r "$sys_path" "$dot_path"
        else
            cp -a "$sys_path" "$dot_path"
        fi
    fi

    log "Backed up: $sys_path  ->  $rel_path"
done

log "Done. Dotfiles saved to: $DOTFILES_DIR"
