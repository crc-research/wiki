#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Default values
MW_ADMIN_USER=${MW_ADMIN_USER:-"Admin"}
MW_ADMIN_PASS=${MW_ADMIN_PASS:-"changeme123"}
MW_DB_NAME=${MW_DB_NAME:-"mediawiki"}
MW_DB_USER=${MW_DB_USER:-"root"}
MW_DB_PASS=${MW_DB_PASS:-"mediawiki"}
MW_DB_HOST=${MW_DB_HOST:-"db"}
MW_SITENAME=${MW_SITENAME:-"My Wiki"}
MW_WIKI_LANG=${MW_WIKI_LANG:-"en"}
MW_SCRIPT_PATH=${MW_SCRIPT_PATH:-"/w"}
MW_EMERGENCY_CONTACT=${MW_EMERGENCY_CONTACT:-"admin@example.com"}
MW_PASSWORD_SENDER=${MW_PASSWORD_SENDER:-"admin@example.com"}
MW_AUTO_INSTALL=${MW_AUTO_INSTALL:-"true"}
MW_UPGRADE=${MW_UPGRADE:-"true"}
MW_SITE_SERVER=${MW_SITE_SERVER:-"https://localhost"}

# MediaWiki paths
MW_PATH="/var/www/mediawiki/w"
MW_CONFIG_PATH="/mediawiki/config-generated"
LOCALSETTINGS_PATH="${MW_CONFIG_PATH}/LocalSettings.php"

log "Starting Canasta MediaWiki setup..."

# Wait for database to be ready
log "Waiting for database to be ready..."
while ! mysqladmin ping -h"$MW_DB_HOST" -u"$MW_DB_USER" -p"$MW_DB_PASS" --silent; do
    sleep 2
    log "Still waiting for database..."
done
log "Database is ready!"

# Check if MediaWiki is already installed
if [ -f "$LOCALSETTINGS_PATH" ] && [ "$MW_AUTO_INSTALL" != "force" ]; then
    log "LocalSettings.php exists. Checking if MediaWiki is properly installed..."

    # Check if database has MediaWiki tables
    TABLE_COUNT=$(mysql -h"$MW_DB_HOST" -u"$MW_DB_USER" -p"$MW_DB_PASS" -D"$MW_DB_NAME" -e "SHOW TABLES LIKE 'user';" 2>/dev/null | wc -l)

    if [ "$TABLE_COUNT" -gt 0 ]; then
        log "MediaWiki appears to be already installed."

        # Run upgrade if requested
        if [ "$MW_UPGRADE" = "true" ]; then
            log "Running MediaWiki database upgrade..."
            cd "$MW_PATH"
            php maintenance/update.php --quick --conf="$LOCALSETTINGS_PATH" || warn "Database upgrade failed, but continuing..."
        fi

        log "Starting Canasta services..."
        exec /run-all.sh
    else
        warn "LocalSettings.php exists but database appears empty. Reinstalling..."
        rm -f "$LOCALSETTINGS_PATH"
    fi
fi

# Generate LocalSettings.php if it doesn't exist or if forcing installation
if [ ! -f "$LOCALSETTINGS_PATH" ] || [ "$MW_AUTO_INSTALL" = "force" ]; then
    log "Installing MediaWiki..."

    cd "$MW_PATH"

    # Run MediaWiki installer
    log "Running MediaWiki installation script..."
    php maintenance/install.php \
        --dbtype=mysql \
        --dbserver="$MW_DB_HOST" \
        --dbname="$MW_DB_NAME" \
        --dbuser="$MW_DB_USER" \
        --dbpass="$MW_DB_PASS" \
        --server="$MW_SITE_SERVER" \
        --scriptpath="$MW_SCRIPT_PATH" \
        --lang="$MW_WIKI_LANG" \
        --pass="$MW_ADMIN_PASS" \
        --email="$MW_EMERGENCY_CONTACT" \
        --installdbuser="$MW_DB_USER" \
        --installdbpass="$MW_DB_PASS" \
        "$MW_SITENAME" \
        "$MW_ADMIN_USER"

    if [ $? -eq 0 ]; then
        log "MediaWiki installation completed successfully!"

        # Move LocalSettings.php to the config directory
        if [ -f "$MW_PATH/LocalSettings.php" ]; then
            log "Moving LocalSettings.php to config directory..."
            mv "$MW_PATH/LocalSettings.php" "$LOCALSETTINGS_PATH"

            # Create symlink back to MediaWiki directory
            ln -sf "$LOCALSETTINGS_PATH" "$MW_PATH/LocalSettings.php"
        fi

        # Add additional configuration to LocalSettings.php
        log "Adding additional MediaWiki configuration..."
        cat >> "$LOCALSETTINGS_PATH" << EOF

# Additional Canasta configuration
\$wgEmergencyContact = "$MW_EMERGENCY_CONTACT";
\$wgPasswordSender = "$MW_PASSWORD_SENDER";

# Enable file uploads
\$wgEnableUploads = true;

# Set upload directory
\$wgUploadDirectory = "/mediawiki/images";
\$wgUploadPath = "/images";

# Set cache directory
\$wgCacheDirectory = "/tmp";

# Memory limit
ini_set( 'memory_limit', '512M' );

# Load and enable skins
wfLoadSkin( 'Vector' );
wfLoadSkin( 'MonoBook' );
wfLoadSkin( 'Timeless' );
wfLoadSkin( 'MinervaNeue' );

# Include any custom settings from read-only config
if ( file_exists( '/mediawiki/config/SettingsTemplate.php' ) ) {
    include_once '/mediawiki/config/SettingsTemplate.php';
}
EOF

        # Fix the default skin if it's set to vector-2022
        log "Fixing skin configuration..."
        sed -i 's/\$wgDefaultSkin = "vector-2022";/\$wgDefaultSkin = "vector";/' "$LOCALSETTINGS_PATH"

        # Run database update to ensure everything is current
        log "Running final database update..."
        php maintenance/update.php --quick --conf="$LOCALSETTINGS_PATH"

        log "MediaWiki setup completed successfully!"
    else
        error "MediaWiki installation failed!"
        exit 1
    fi
else
    log "MediaWiki is already configured."
fi

# Start the original Canasta entrypoint
log "Starting Canasta services..."
exec /run-all.sh