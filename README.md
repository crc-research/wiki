# MediaWiki with Varnish Cache

A containerized MediaWiki setup with Varnish caching and clean HTTP-only configuration.

## Quick Start

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Start the services:
   ```bash
   docker compose up -d
   ```

3. Access your wiki at: `http://localhost`

## Configuration

- **LocalSettings.php**: Located in `config/LocalSettings.php` and version controlled
- **Environment variables**: Configure in `.env` file
- **Extensions**: Place in `./extensions/` directory
- **Skins**: Place in `./skins/` directory

## Cache Management

### Purging Varnish Cache

When you make configuration changes (like updating the logo), you may need to purge the Varnish cache:

**Method 1: Purge everything (recommended)**
```bash
docker compose exec varnish varnishadm ban req.url '~' '.'
```

**Method 2: HTTP PURGE requests**
```bash
# Purge homepage
curl -X PURGE http://localhost/

# Purge specific pages
curl -X PURGE http://localhost/Main_Page
```

**Method 3: Restart Varnish**
```bash
docker compose restart varnish
```

## Data Persistence

All persistent data uses named Docker volumes:
- `mediawiki-images`: Uploaded files
- `mysql-data-volume`: Database data
- `elasticsearch`: Search index

Your local directories stay clean - no generated files are written to them.

## Security Keys

For production, generate secure keys:

```bash
# Generate secret key (64 characters)
openssl rand -hex 32

# Generate upgrade key (32 characters)
openssl rand -hex 16
```

Add them to your `.env` file:
```bash
MW_SECRET_KEY=your-64-character-hex-secret-key-here
MW_UPGRADE_KEY=your-32-character-hex-upgrade-key-here
```

## URL Configuration

This setup uses clean URLs without `/wiki/` prefix:
- ✅ `http://localhost/Main_Page`
- ✅ `http://localhost/Special:RecentChanges`

URLs are rewritten by Varnish to the MediaWiki backend.

## Updating MediaWiki

1. Update the image version in `docker-compose.yml`
2. Restart containers: `docker compose up -d`
4. Your `LocalSettings.php` stays the same (manually managed)

## Troubleshooting

### Logo not showing after changes
- Purge Varnish cache (see Cache Management above)
- Check browser cache (hard refresh with Ctrl+F5)
- Restart containers if needed

### Configuration changes not taking effect
- Restart the web container: `docker compose restart web`
- Purge Varnish cache
- Check that LocalSettings.php syntax is correct
