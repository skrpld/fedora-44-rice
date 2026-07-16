#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_SUFFIX=".bak.$TIMESTAMP"

GREEN='\e[1;32m'
YELLOW='\e[1;33m'
RED='\e[1;31m'
BLUE='\e[1;34m'
NC='\e[0m'

log()  { echo -e "${GREEN}[INSTALL]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }

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
    ["etc/sddm.conf"]="/etc/sddm.conf"
    ["etc/asusd/asusd.conf"]="/etc/asusd/asusd.conf"
    ["etc/tmpfiles.d/battery_limit.conf"]="/etc/tmpfiles.d/battery_limit.conf"
    ["etc/systemd/zram-generator.conf.d/zram0.conf"]="/etc/systemd/zram-generator.conf.d/zram0.conf"
)

if [[ ! -d "$DOTFILES_DIR" ]]; then
    err "Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
fi

for rel_path in "${!CONFIGS[@]}"; do
    sys_path="${CONFIGS[$rel_path]}"
    dot_path="$DOTFILES_DIR/$rel_path"

    if [[ ! -e "$dot_path" ]]; then
        info "Skipped (not in dotfiles): $rel_path"
        continue
    fi

    if [[ -e "$sys_path" ]] && diff -rq "$dot_path" "$sys_path" >/dev/null 2>&1; then
        info "Skipped (identical): $rel_path"
        continue
    fi

    if [[ "$sys_path" == /etc/* ]]; then
        if [[ -e "$sys_path" ]]; then
            sudo mv "$sys_path" "$sys_path$BACKUP_SUFFIX"
            warn "Backed up system config: $sys_path -> $sys_path$BACKUP_SUFFIX"
        fi
        sudo mkdir -p "$(dirname "$sys_path")"
        if [[ -d "$dot_path" ]]; then
            sudo cp -r "$dot_path" "$sys_path"
        else
            sudo cp -a "$dot_path" "$sys_path"
        fi
    else
        if [[ -e "$sys_path" ]]; then
            mv "$sys_path" "$sys_path$BACKUP_SUFFIX"
            warn "Backed up existing: $sys_path -> $sys_path$BACKUP_SUFFIX"
        fi
        mkdir -p "$(dirname "$sys_path")"
        if [[ -d "$dot_path" ]]; then
            cp -r "$dot_path" "$sys_path"
        else
            cp -a "$dot_path" "$sys_path"
        fi
    fi

    log "Installed: $rel_path -> $sys_path"
done

log "Done. Configs installed from: $DOTFILES_DIR"

