#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%s)"

mkdir -p "$BACKUP_DIR"

# List of config folders
CONFIGS=("nvim" "tmux" "fastfetch" "ghostty")

echo "Installing dotfiles from $DOTFILES_DIR"
echo "Backing up any existing config to $BACKUP_DIR"
echo

for name in "${CONFIGS[@]}"; do
    SRC="$DOTFILES_DIR/$name"
    DEST="$CONFIG_DIR/$name"

    if [ -e "$DEST" ] || [ -L "$DEST" ]; then
        echo "Backing up $DEST to $BACKUP_DIR"
        mv "$DEST" "$BACKUP_DIR/"
    fi

    echo "Linking $SRC → $DEST"
    ln -s "$SRC" "$DEST"
done

echo
echo "✅ All configs installed!"

