#!/bin/bash

# Backup folder path
USER=$(whoami)
BACKUP_DIR="$HOME/${USER}_BACKUPS"

# Check if backup directory exists
if [ -d "$BACKUP_DIR" ]; then
    # Calculate total size before deletion (in MB)
    size_before=$(du -sm "$BACKUP_DIR" | cut -f1)

    # Confirm with the user
    read -p "Are you sure you want to delete all files in $BACKUP_DIR? [y/N] " confirm
    if [[ "$confirm" =~ ^[yY]$ ]]; then
        rm -rf "$BACKUP_DIR"/*
        echo "✓ Backup folder cleaned."
        echo "Freed approximately ${size_before}MB of space."
    else
        echo "Operation cancelled."
    fi
else
    echo "Backup folder does not exist: $BACKUP_DIR"
fi
