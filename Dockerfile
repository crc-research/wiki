FROM ghcr.io/canastawiki/canasta:3.0.3

RUN apt-get install -y unzip

# Create the user-* folders or Canasta will complain
RUN mkdir -p /var/www/mediawiki/w/user-extensions && \
    mkdir -p /var/www/mediawiki/w/user-skins

# Install extra extensions

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
COPY scripts/*.sh _sources/scripts/maintenance-scripts/

# Copy entrypoint.sh (which will do stuff and then run Canasta's entrypoint /run-all.sh)
COPY entrypoint.sh /
CMD ["/entrypoint.sh"]
