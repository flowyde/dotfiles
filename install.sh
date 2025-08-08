#!/usr/bin/env bash

set -e

# Cores para saída legível
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Função para exibir texto colorido
print() {
    echo -e "${2:-}$1${NC}"
}

# Variáveis
USER=$(whoami)
DOTFILES_DIR="$HOME/dotfiles"
CONFIGS_DIR="$DOTFILES_DIR/configs"
BACKUP_DIR="$HOME/${USER}_BACKUPS"
DEPS=("stow" "kitty")
DOTCONFIG_DIR="$HOME/.config"  # Onde os symlinks serão criados

print "\nSway Rice Installation Process" "$GREEN"

# Verificar dependências
print "\nVerifying dependencies..." "$YELLOW"
missing=()
for dep in "${DEPS[@]}"; do
    if command -v "$dep" &> /dev/null; then
        print "✓ $dep found" "$GREEN"
    else
        print "✗ $dep not found" "$RED"
        missing+=("$dep")
    fi
done

if [ ${#missing[@]} -gt 0 ]; then
    print "\nPlease install the missing dependencies: ${missing[*]}" "$RED"
    exit 1
fi

# Cria o diretorio de backup se não existir 
mkdir -p "$BACKUP_DIR"

# Para cada diretório dentro de dotfiles/configs
print "\nCopying configurations..." "$YELLOW"

for dir in $CONFIGS_DIR/*; do
    if [ -d "$dir" ]; then
        dirname=$(basename "$dir")
        target_dir="$DOTCONFIG_DIR/$dirname"

        # Se já existir, mover para backup
        if [ -d "$target_dir" ]; then
            backup_target="$BACKUP_DIR/$dirname"
            print "Backing up existing $dirname to $backup_target" "$YELLOW"
            
            # Append timestamp to backup, in case of multiple backups existing.
            if [ -d "$backup_target" ]; then
                timestamp=$(date +"%Y%m%d_%H%M%S")
                backup_target="${backup_target}_${timestamp}"
            fi
            
            mv "$target_dir" "$backup_target"
            print "✓ Backed up $dirname" "$GREEN"
        fi

        # Criar symlinks
        cp -r "$dir" "$target_dir"
        print "✓ Copied $dirname to $target_dir" "$GREEN"
    fi
done

echo
print "All configurations have been installed to ~/.config/" "$GREEN"

if [ "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
    print "Backups of existing files have been created in: $BACKUP_DIR" "$YELLOW"
fi