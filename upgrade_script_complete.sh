#!/bin/bash

# ==============================================
# Salbion Group Laravel Upgrade Script
# Version: 5.0 (Simplified for your setup)
# ==============================================

set -euo pipefail

# Configuration
readonly SCRIPT_VERSION="5.0"
readonly MIN_PHP_VERSION="8.1"
readonly MIN_NODE_VERSION="16"

# Colors - using simple variables instead of associative array
COLOR_RESET='\033[0m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_CYAN='\033[0;36m'
COLOR_PURPLE='\033[0;35m'
COLOR_BOLD='\033[1m'

# Parse arguments
DRY_RUN="false"
PROJECT_ROOT="$(pwd)"

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        --help)
            echo "Usage: $0 [--dry-run] [--help]"
            echo "  --dry-run  Show what would be done without making changes"
            echo "  --help     Show this help message"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# Initialize
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly LOG_FILE="$PROJECT_ROOT/upgrade_log_$TIMESTAMP.txt"
readonly BACKUP_DIR="$PROJECT_ROOT/.upgrade_backups_$TIMESTAMP"
readonly TEMP_DIR="/tmp/salbion_upgrade_$$"

# Logging
log_message() {
    local type="$1"
    local message="$2"
    local timestamp="[$(date '+%Y-%m-%d %H:%M:%S')]"
    
    case "$type" in
        "error")
            echo -e "${COLOR_RED}$timestamp ❌ ERROR: $message${COLOR_RESET}" | tee -a "$LOG_FILE"
            ;;
        "warning")
            echo -e "${COLOR_YELLOW}$timestamp ⚠️  WARNING: $message${COLOR_RESET}" | tee -a "$LOG_FILE"
            ;;
        "success")
            echo -e "${COLOR_GREEN}$timestamp ✅ SUCCESS: $message${COLOR_RESET}" | tee -a "$LOG_FILE"
            ;;
        "info")
            echo -e "${COLOR_CYAN}$timestamp ℹ️  INFO: $message${COLOR_RESET}" | tee -a "$LOG_FILE"
            ;;
        "step")
            echo -e "${COLOR_PURPLE}$timestamp 🔄 STEP: $message${COLOR_RESET}" | tee -a "$LOG_FILE"
            ;;
        "header")
            echo -e "${COLOR_BOLD}\n================================" | tee -a "$LOG_FILE"
            echo -e "$timestamp 🚀 $message" | tee -a "$LOG_FILE"
            echo -e "================================${COLOR_RESET}" | tee -a "$LOG_FILE"
            ;;
    esac
}

execute_command() {
    local command="$1"
    local success_msg="$2"
    local error_msg="$3"
    local allow_failure="${4:-false}"
    
    log_message "step" "Executing: $command"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_message "info" "[DRY RUN] Would execute: $command"
        return 0
    fi
    
    if eval "$command" 2>&1 | tee -a "$LOG_FILE"; then
        log_message "success" "$success_msg"
        return 0
    else
        log_message "error" "$error_msg"
        if [[ "$allow_failure" == "false" ]]; then
            exit 1
        fi
        return 1
    fi
}

# Create backup
create_backup() {
    log_message "header" "CREATING BACKUP"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_message "info" "[DRY RUN] Would create backup in: $BACKUP_DIR"
        return 0
    fi
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup important files
    for file in .env composer.json composer.lock package.json package-lock.json; do
        if [[ -f "$file" ]]; then
            cp "$file" "$BACKUP_DIR/"
            log_message "success" "Backed up: $file"
        fi
    done
}

# Install NPM packages
install_npm_packages() {
    log_message "header" "INSTALLING NPM PACKAGES"
    
    # Packages to install
    local packages=(
        "@fontsource/inter"
        "alpinejs"
        "@tailwindcss/forms"
        "@tailwindcss/typography"
    )
    
    for package in "${packages[@]}"; do
        if grep -q "\"$package\"" package.json 2>/dev/null; then
            log_message "info" "$package already installed"
        else
            execute_command "npm install $package --save-dev" \
                "Installed $package" \
                "Failed to install $package" \
                true
        fi
    done
}

# Update environment configuration
update_environment() {
    log_message "header" "UPDATING ENVIRONMENT CONFIGURATION"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_message "info" "[DRY RUN] Would add environment variables for Redis and Filament"
        return 0
    fi
    
    # Add environment variables if missing
    local vars=(
        "FILAMENT_DARK_MODE=true"
        "CACHE_DRIVER=file"
        "SESSION_DRIVER=file"
        "QUEUE_CONNECTION=sync"
    )
    
    for var in "${vars[@]}"; do
        local key="${var%%=*}"
        if ! grep -q "^$key=" .env; then
            echo "$var" >> .env
            log_message "success" "Added: $var"
        fi
    done
}

# Update frontend assets
update_frontend() {
    log_message "header" "UPDATING FRONTEND ASSETS"
    
    # Create temp directory
    mkdir -p "$TEMP_DIR"
    
    # Update CSS with Inter font
    local css_file="resources/css/app.css"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_message "info" "[DRY RUN] Would update $css_file with Inter font"
        return 0
    fi
    
    if [[ -f "$css_file" ]] && ! grep -q "@fontsource/inter" "$css_file"; then
        # Create temp file with font imports
        cat > "$TEMP_DIR/font_imports.css" << 'CSS'
@import '@fontsource/inter/400.css';
@import '@fontsource/inter/500.css';
@import '@fontsource/inter/600.css';
@import '@fontsource/inter/700.css';

CSS
        # Prepend to existing CSS
        cat "$css_file" >> "$TEMP_DIR/font_imports.css"
        mv "$TEMP_DIR/font_imports.css" "$css_file"
        log_message "success" "Added Inter font to CSS"
    fi
    
    # Build assets
    execute_command "npm run build" \
        "Built frontend assets" \
        "Failed to build assets" \
        true
}

# Run optimizations
run_optimizations() {
    log_message "header" "RUNNING OPTIMIZATIONS"
    
    local commands=(
        "php artisan optimize:clear"
        "php artisan config:cache"
        "php artisan route:cache"
        "php artisan view:cache"
        "php artisan icons:cache"
        "php artisan filament:upgrade"
    )
    
    for cmd in "${commands[@]}"; do
        execute_command "$cmd" \
            "Executed: $cmd" \
            "Failed: $cmd" \
            true
    done
}

# Create deployment scripts
create_deployment_scripts() {
    log_message "header" "CREATING DEPLOYMENT SCRIPTS"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_message "info" "[DRY RUN] Would create deployment scripts in scripts/"
        return 0
    fi
    
    mkdir -p scripts
    
    # Create deploy script
    cat > scripts/deploy.sh << 'DEPLOY'
#!/bin/bash
set -e

echo "🚀 Starting deployment..."

# Pull latest code
git pull origin main

# Install dependencies
composer install --no-dev --optimize-autoloader
npm ci --production

# Run migrations
php artisan migrate --force

# Clear and rebuild caches
php artisan optimize:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan filament:upgrade

# Build assets
npm run build

echo "✅ Deployment complete!"
DEPLOY
    
    chmod +x scripts/deploy.sh
    log_message "success" "Created deployment script"
}

# Main execution
main() {
    log_message "header" "SALBION GROUP UPGRADE SCRIPT v$SCRIPT_VERSION"
    log_message "info" "Mode: $([ "$DRY_RUN" == "true" ] && echo "DRY RUN" || echo "LIVE")"
    
    # Create temp directory
    mkdir -p "$TEMP_DIR"
    
    # Run upgrade steps
    create_backup
    install_npm_packages
    update_environment
    update_frontend
    run_optimizations
    create_deployment_scripts
    
    # Cleanup
    rm -rf "$TEMP_DIR"
    
    log_message "header" "UPGRADE COMPLETED!"
    log_message "info" "Log file: $LOG_FILE"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        log_message "info" "Backup location: $BACKUP_DIR"
        echo -e "\n${COLOR_GREEN}✅ Next steps:${COLOR_RESET}"
        echo "1. Run: php artisan serve"
        echo "2. Visit: http://localhost:8000/admin"
        echo "3. Create admin user: php artisan make:filament-user"
    fi
}

# Run main
main
