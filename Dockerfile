FROM ghcr.io/canastawiki/canasta:3.0.3

# Update the package index
RUN apt-get update && apt-get install -y ca-certificates curl gnupg \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://packages.sury.org/php/apt.gpg -o /etc/apt/keyrings/sury.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/sury.gpg] https://packages.sury.org/php/ bookworm main" > /etc/apt/sources.list.d/sury.list

# Install php-luasandbox for the Scribunto extension.
# Debian repos don't have it for php 8.1, so we have to install it using pecl
RUN apt-get install -y php8.1-cli php8.1-dev php8.1-common lua5.1 liblua5.1-0-dev git build-essential pkg-config autoconf && \
    pecl install luasandbox && \
    echo "extension=luasandbox.so" > /etc/php/8.1/mods-available/luasandbox.ini && \
    phpenmod -v 8.1 luasandbox

# Create the user-* folders or Canasta will complain
RUN mkdir -p /var/www/mediawiki/w/user-extensions && \
    mkdir -p /var/www/mediawiki/w/user-skins

# Install extra extensions
RUN apt-get install -y unzip

RUN cd /tmp && \
    wget -q https://github.com/wikimedia/mediawiki-extensions-CreatePageUw/archive/refs/heads/master.zip -O createpageuw.zip && \
    unzip -q createpageuw.zip && \
    mv mediawiki-extensions-CreatePageUw-master /var/www/mediawiki/w/user-extensions/CreatePageUw && \
    rm createpageuw.zip

RUN cd /tmp && \
    wget -q https://github.com/ProfessionalWiki/SlashCommands/archive/d62aaa95b9461e2757a9a5d2e9ca16e093f95fea.zip -O slashcommands.zip && \
    unzip -q slashcommands.zip && \
    mv SlashCommands-d62aaa95b9461e2757a9a5d2e9ca16e093f95fea /var/www/mediawiki/w/user-extensions/SlashCommands && \
    rm slashcommands.zip

# Copy custom maintenance scripts so Canasta runs them automatically
COPY scripts/*.sh /maintenance-scripts/
RUN chmod +x /maintenance-scripts/*.sh
# Canasta has a few scripts as well but they are broken, e.g. https://github.com/CanastaWiki/Canasta/blob/master/smw-maintenance.sh
# isn't even valid bash ("sac"). We only need the cirrus search setup and we can do it by ourselves.

# Copy entrypoint.sh (which will do stuff and then run Canasta's entrypoint /run-all.sh)
COPY entrypoint.sh /
CMD ["/entrypoint.sh"]
