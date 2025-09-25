# Task: Automate Canasta Wiki Deployment

The primary goal is to automate the deployment and initial setup of a Canasta wiki stack, making it fully operational with a single command.

## Core Requirement

The entire deployment and setup process must be triggered by a single `docker compose up` command. The system must be able to initialize itself from a fresh state without any manual intervention or preliminary script execution.

## Key Constraints and Clarifications

1.  **Single-Command Deployment**: The deployment platform is strictly limited to executing `docker compose up`. No other commands or preparatory steps (e.g., `bash setup.sh prepare`) are permissible. The entire setup logic must be self-contained within the Docker Compose lifecycle.

2.  **No Local Docker Builds**: The solution must use the official, pre-built Docker images for Canasta and its dependencies (e.g., from `ghcr.io` or Docker Hub). No `build:` directives should be present in the `docker-compose.yml` file.

3.  **Environment Variable for Secrets and Configuration**: All secrets (like the admin and root database passwords) and instance-specific configurations (like the domain name and wiki ID) must be supplied via environment variables. The system should read these variables to configure itself. The required variables should be clearly documented.

4.  **Specific Software Version**: The stack must use Canasta version `3.0.3`.

## Desired Outcome

A `docker-compose.yml` file and any necessary supporting scripts (e.g., `setup.sh`) that, when run with `docker compose up` and the appropriate environment variables set, will:
-   Generate all necessary configuration files on the fly.
-   Wait for the database to be ready.
-   Run the MediaWiki installer to set up the wiki if it's not already installed.
-   Start all services in the correct order, resulting in a fully functional wiki.

## Validation Steps

To verify that the automated deployment works as intended:

1. **Set Environment Variables**: Ensure all required environment variables are set. For example, create or edit a `.env` file with:
   - `MYSQL_PASSWORD=your_db_password`
   - `MW_SITE_SERVER=https://yourdomain.com`
   - `MW_SITE_FQDN=yourdomain.com`
   - `MW_ADMIN_PASSWORD=your_admin_password` (assuming this is how admin password is set)
   - `MW_WIKI_ID=your_wiki_id`
   - Any other necessary variables as per the setup.

2. **Start the Stack**: Run the command:
   ```
   docker compose up -d
   ```

3. **Monitor Logs**: Check the logs for successful setup:
   ```
   docker compose logs -f web
   ```
   Look for messages indicating that the database is ready, MediaWiki installer ran successfully, and no errors occurred.

4. **Access the Wiki**: Open a browser and navigate to the URL specified in `MW_SITE_SERVER` (e.g., https://localhost). Verify that the wiki's main page loads correctly.

5. **Login as Admin**: Attempt to log in using the admin credentials (username: likely 'Admin' or as configured, password: from `MW_ADMIN_PASSWORD`). Ensure you can access admin features.

6. **Check Database**: Verify the database setup by executing:
   ```
   docker compose exec db mysql -u root -p"$MYSQL_PASSWORD" -e "SHOW TABLES FROM mediawiki;"
   ```
   This should list the MediaWiki tables if installation was successful.

7. **Test Functionality**: Create a test page or upload an image to ensure the wiki is fully operational.

8. **Teardown (Optional)**: To test from fresh state, stop and remove volumes:
   ```
   docker compose down -v
   ```
   Then repeat steps 2-7 to confirm it sets up automatically from scratch.

If all steps complete without manual intervention and the wiki functions as expected, the task is validated.
