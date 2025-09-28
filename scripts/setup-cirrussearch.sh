#!/bin/bash
set -e

echo "[setup-cirrussearch] Running CirrusSearch setup"
cd /var/www/mediawiki/w/canasta-extensions/CirrusSearch/maintenance

php UpdateSearchIndexConfig.php && \
php ForceSearchIndex.php --skipLinks --indexOnSkip && \
php ForceSearchIndex.php --skipParse
