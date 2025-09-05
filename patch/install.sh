#!/bin/bash

# Define variables
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
PATCH_DIR="$SCRIPT_DIR/patch_files"
INSTALL_DIR="/usr/local/open-audit"
BACKUP_DIR="$INSTALL_DIR/backup_$(date '+%Y%m%d%H%M%S')"
APACHE_SERVICE="apache2"
FILES_TO_BACKUP=(
    "app/Helpers/discoveries_helper.php"
)

# Function to display messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check if patch directory exists
if [ ! -d "$PATCH_DIR" ]; then
    log "Patch directory $PATCH_DIR does not exist. Exiting."
    exit 1
fi

# Check if install directory exists
if [ ! -d "$INSTALL_DIR" ]; then
    log "Installation directory $INSTALL_DIR does not exist. Exiting."
    exit 1
fi

# Create backup directory
log "Creating backup of original files..."
mkdir -p "$BACKUP_DIR"

# Backup specified files
for FILE in "${FILES_TO_BACKUP[@]}"; do
    if [ -e "$INSTALL_DIR/$FILE" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname "$FILE")"
        cp "$INSTALL_DIR/$FILE" "$BACKUP_DIR/$FILE"
        if [ $? -eq 0 ]; then
            log "Backed up $FILE successfully."
        else
            log "Failed to backup $FILE. Exiting."
            exit 1
        fi
    else
        log "File $FILE does not exist in the installation directory. Skipping."
    fi
done

# Replace PHP files
log "Applying patch..."
cp -R "$PATCH_DIR"/* "$INSTALL_DIR"

if [ $? -eq 0 ]; then
    log "Patch applied successfully."
else
    log "Patch application failed. Exiting."
    exit 1
fi

# Restart Apache service
log "Restarting Apache service..."
systemctl restart "$APACHE_SERVICE"

if [ $? -eq 0 ]; then
    log "Apache service restarted successfully."
else
    log "Failed to restart Apache service. Exiting."
    exit 1
fi

# Verify Apache service status
log "Verifying Apache service status..."
systemctl status "$APACHE_SERVICE" --no-pager

if [ $? -eq 0 ]; then
    log "Apache service is running."
else
    log "Apache service is not running. Please check the service status."
    exit 1
fi

log "Patch installation completed successfully."
