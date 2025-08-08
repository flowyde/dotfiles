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
DEPS=("quickshell" "kitty")
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

# Cria o diretório de backup se não existir 
mkdir -p "$BACKUP_DIR"

# Verifica o tamanho total do diretório de backup
MAX_SIZE=$((10 * 1024)) # 10MB em KB

get_backup_size() {
    du -s "$BACKUP_DIR" | awk '{print $1}'
}

current_size=$(get_backup_size)

if [ "$current_size" -gt "$MAX_SIZE" ]; then
    print "\nBackup folder exceeds 10MB. Cleaning up old backups..." "$RED"

    # Lista os itens mais antigos primeiro
    while [ "$current_size" -gt "$MAX_SIZE" ]; do
        oldest_item=$(find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -printf '%T+ %p\n' | sort | head -n 1 | awk '{print $2}')
        
        if [ -z "$oldest_item" ]; then
            break
        fi

        rm -rf "$oldest_item"
        print "Deleted: $oldest_item" "$YELLOW"

        current_size=$(get_backup_size)
    done

    print "✓ Old backups deleted. Backup folder is now under 10MB." "$GREEN"
fi


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
            
            # Append timestamp to backup, in caso de múltiplos backups
            if [ -d "$backup_target" ]; then
                timestamp=$(date +"%Y%m%d_%H%M%S")
                backup_target="${backup_target}_${timestamp}"
            fi
            
            mv "$target_dir" "$backup_target"
            print "✓ Backed up $dirname" "$GREEN"
        fi

        # Copiar configurações para ~/.config
        cp -r "$dir" "$target_dir"
        print "✓ Copied $dirname to $target_dir" "$GREEN"
    fi
done

echo
print "All configurations have been installed to ~/.config/" "$GREEN"

if [ "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
    print "Backups of existing files have been created in: $BACKUP_DIR" "$YELLOW"
fi
