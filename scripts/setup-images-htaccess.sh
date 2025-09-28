#!/bin/bash
set -e

MW_IMAGES_DIR="/var/www/mediawiki/w/images"

echo "[setup-images-htaccess] Ensuring .htaccess in ${MW_IMAGES_DIR}"
mkdir -p "${MW_IMAGES_DIR}"

cat > "${MW_IMAGES_DIR}/.htaccess" << 'EOF'
# Allow access to image files
Require all granted

<IfModule headers_module>
Header set X-Content-Type-Options nosniff
</IfModule>
<IfModule php7_module>
php_flag engine off
</IfModule>
# In php8, php dropped the version number.
<IfModule php_module>
php_flag engine off
</IfModule>
EOF
