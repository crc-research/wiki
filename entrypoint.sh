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
MW_SITE_SERVER=${MW_SITE_SERVER:-"https://localhost"}

# Run auto-update by default
export MW_AUTOUPDATE=true

# MediaWiki paths
MW_PATH="/var/www/mediawiki/w"

log "Starting Canasta MediaWiki setup..."

# # Wait for database to be ready
# log "Waiting for database to be ready..."
# while ! mysqladmin ping -h"$MW_DB_HOST" -u"$MW_DB_USER" -p"$MW_DB_PASS" --silent; do
#     sleep 2
#     log "Still waiting for database..."
# done
# log "Database is ready!"

log "Checking database..."

# Check if database has MediaWiki tables
TABLE_COUNT=$(mysql -h"$MW_DB_HOST" -u"$MW_DB_USER" -p"$MW_DB_PASS" -D"$MW_DB_NAME" -e "SHOW TABLES LIKE 'user';" 2>/dev/null | wc -l)

if [ "$TABLE_COUNT" -eq 0 ]; then
    log "Database appears empty. Running MediaWiki installation..."
    cd "$MW_PATH"

    # Run a subset of Canasta's run-all.sh that will let us run the install script
    /create-symlinks.sh

    # Hide LocalSettings.php from Canasta or else it will refuse to run the install script
    mv "$MW_PATH/LocalSettings.php" "$MW_PATH/LocalSettings.php.bak"

    # Run MediaWiki installer (this will create the database tables)
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

    # Restore LocalSettings.php
    mv "$MW_PATH/LocalSettings.php.bak" "$MW_PATH/LocalSettings.php"

    log "Database setup completed!"
else
    log "Database already initialized."
fi

# Start the original Canasta entrypoint
log "Starting Canasta services..."
exec /run-all.sh
