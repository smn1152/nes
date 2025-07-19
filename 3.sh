#!/bin/bash

# ==============================================
# Salbion Group Final Working Script
# Version: 6.0 (Production Ready)
# ==============================================

set -euo pipefail

# Configuration
readonly SCRIPT_VERSION="6.0"
readonly PROJECT_ROOT="${1:-$(pwd)}"
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly LOG_FILE="$PROJECT_ROOT/upgrade_log_$TIMESTAMP.txt"
readonly BACKUP_DIR="$PROJECT_ROOT/.upgrade_backups_$TIMESTAMP"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Environment detection
ENVIRONMENT="local"
if [[ -f "$PROJECT_ROOT/.env" ]]; then
    ENVIRONMENT=$(grep "^APP_ENV=" "$PROJECT_ROOT/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "local")
fi

# Logging function
log_message() {
    local type="$1"
    local message="$2"
    local timestamp="[$(date '+%Y-%m-%d %H:%M:%S')]"
    local output=""
    
    case "$type" in
        "error")   output="${RED}$timestamp ERROR: $message${RESET}" ;;
        "success") output="${GREEN}$timestamp SUCCESS: $message${RESET}" ;;
        "warning") output="${YELLOW}$timestamp WARNING: $message${RESET}" ;;
        "info")    output="${CYAN}$timestamp INFO: $message${RESET}" ;;
        "step")    output="${PURPLE}$timestamp STEP: $message${RESET}" ;;
        *)         output="$timestamp $message" ;;
    esac
    
    echo -e "$output" | tee -a "$LOG_FILE"
}

# Header function
log_header() {
    local message="$1"
    echo -e "\n${WHITE}================================${RESET}" | tee -a "$LOG_FILE"
    echo -e "${WHITE}$message${RESET}" | tee -a "$LOG_FILE"
    echo -e "${WHITE}================================${RESET}" | tee -a "$LOG_FILE"
}

# Execute command with logging
execute_cmd() {
    local cmd="$1"
    local success_msg="$2"
    local error_msg="$3"
    local silent="${4:-false}"
    
    log_message "step" "Executing: $cmd"
    
    if [[ "$silent" == "true" ]]; then
        if eval "$cmd" >/dev/null 2>>"$LOG_FILE"; then
            log_message "success" "$success_msg"
            return 0
        else
            log_message "error" "$error_msg"
            return 1
        fi
    else
        if eval "$cmd" 2>&1 | tee -a "$LOG_FILE"; then
            log_message "success" "$success_msg"
            return 0
        else
            log_message "error" "$error_msg"
            return 1
        fi
    fi
}

# Prerequisites check
check_prerequisites() {
    log_header "CHECKING PREREQUISITES"
    
    # Check if Laravel project
    if [[ ! -f "$PROJECT_ROOT/artisan" ]]; then
        log_message "error" "Not a Laravel project (artisan not found)"
        exit 1
    fi
    
    # Check required commands
    local commands="php composer npm node"
    for cmd in $commands; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_message "error" "$cmd is not installed"
            exit 1
        fi
        log_message "success" "$cmd is available"
    done
    
    # Check PHP version
    local php_version=$(php -r "echo PHP_VERSION;")
    log_message "info" "PHP Version: $php_version"
    
    # Check if directory is writable
    if [[ ! -w "$PROJECT_ROOT" ]]; then
        log_message "error" "Project directory is not writable"
        exit 1
    fi
    
    log_message "success" "All prerequisites met"
}

# Create backup
create_backup() {
    log_header "CREATING BACKUP"
    
    mkdir -p "$BACKUP_DIR"
    
    # Files to backup
    local files=(.env composer.json package.json config/app.php)
    
    # Add model files if they exist
    if [[ -d "$PROJECT_ROOT/app/Models" ]]; then
        while IFS= read -r -d '' file; do
            files+=("${file#$PROJECT_ROOT/}")
        done < <(find "$PROJECT_ROOT/app/Models" -name "*.php" -type f -print0)
    fi
    
    # Backup Filament provider if exists
    local filament_provider="app/Providers/Filament/AdminPanelProvider.php"
    if [[ -f "$PROJECT_ROOT/$filament_provider" ]]; then
        files+=("$filament_provider")
    fi
    
    # Backup CSS file
    if [[ -f "$PROJECT_ROOT/resources/css/app.css" ]]; then
        files+=("resources/css/app.css")
    fi
    
    local backup_count=0
    for file in "${files[@]}"; do
        if [[ -f "$PROJECT_ROOT/$file" ]]; then
            cp "$PROJECT_ROOT/$file" "$BACKUP_DIR/"
            log_message "success" "Backed up: $file"
            ((backup_count++))
        fi
    done
    
    # Database backup
    if command -v mysqldump >/dev/null 2>&1 && [[ -f "$PROJECT_ROOT/.env" ]]; then
        local db_name=$(grep "^DB_DATABASE=" "$PROJECT_ROOT/.env" | cut -d'=' -f2 | tr -d '"' || echo "")
        local db_user=$(grep "^DB_USERNAME=" "$PROJECT_ROOT/.env" | cut -d'=' -f2 | tr -d '"' || echo "")
        local db_pass=$(grep "^DB_PASSWORD=" "$PROJECT_ROOT/.env" | cut -d'=' -f2 | tr -d '"' || echo "")
        
        if [[ -n "$db_name" ]]; then
            if mysqldump -u "$db_user" -p"$db_pass" "$db_name" > "$BACKUP_DIR/database_backup.sql" 2>/dev/null; then
                log_message "success" "Database backup created"
            else
                log_message "warning" "Could not create database backup"
            fi
        fi
    fi
    
    log_message "info" "Backed up $backup_count files to: $BACKUP_DIR"
}

# Install packages
install_packages() {
    log_header "INSTALLING PACKAGES"
    
    # Update composer
    execute_cmd "cd '$PROJECT_ROOT' && composer self-update" \
        "Composer updated" \
        "Failed to update composer" \
        true
    
    # Required packages
    local packages=(
        "spatie/laravel-sluggable"
        "spatie/pdf-to-text"
        "thiagoalessio/tesseract_ocr"
        "pragmarx/google2fa-laravel"
        "spatie/laravel-permission"
        "spatie/laravel-activitylog"
    )
    
    # Filament packages
    local filament_packages=(
        "filament/spatie-laravel-seo-plugin"
        "filament/spatie-laravel-analytics-plugin"
    )
    
    # Install core packages
    for package in "${packages[@]}"; do
        if composer show "$package" --working-dir="$PROJECT_ROOT" >/dev/null 2>&1; then
            log_message "success" "$package already installed"
        else
            execute_cmd "cd '$PROJECT_ROOT' && composer require '$package' --no-interaction" \
                "Installed $package" \
                "Failed to install $package"
        fi
    done
    
    # Install Filament packages
    for package in "${filament_packages[@]}"; do
        if composer show "$package" --working-dir="$PROJECT_ROOT" >/dev/null 2>&1; then
            log_message "success" "$package already installed"
        else
            execute_cmd "cd '$PROJECT_ROOT' && composer require '$package' --no-interaction" \
                "Installed $package" \
                "Failed to install $package"
        fi
    done
    
    # NPM packages
    local npm_packages=(
        "@fontsource/sf-pro-display"
        "alpinejs"
        "@tailwindcss/forms"
    )
    
    for package in "${npm_packages[@]}"; do
        if npm list "$package" --prefix="$PROJECT_ROOT" >/dev/null 2>&1; then
            log_message "success" "$package already installed"
        else
            execute_cmd "cd '$PROJECT_ROOT' && npm install '$package'" \
                "Installed $package" \
                "Failed to install $package"
        fi
    done
    
    # Optimize autoloader
    execute_cmd "cd '$PROJECT_ROOT' && composer dump-autoload -o" \
        "Autoloader optimized" \
        "Failed to optimize autoloader"
}

# Configure environment
configure_environment() {
    log_header "CONFIGURING ENVIRONMENT"
    
    if [[ -f "$PROJECT_ROOT/.env" ]]; then
        # Update debug setting
        sed -i.bak 's/^APP_DEBUG=.*/APP_DEBUG=false/' "$PROJECT_ROOT/.env"
        
        # Add missing settings
        if ! grep -q "^FILAMENT_DARK_MODE=" "$PROJECT_ROOT/.env"; then
            echo "FILAMENT_DARK_MODE=true" >> "$PROJECT_ROOT/.env"
        fi
        
        log_message "success" "Environment configured"
    else
        log_message "error" ".env file not found"
        return 1
    fi
}

# Configure Filament
configure_filament() {
    log_header "CONFIGURING FILAMENT"
    
    local provider_path="$PROJECT_ROOT/app/Providers/Filament/AdminPanelProvider.php"
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$provider_path")"
    
    # Create/update AdminPanelProvider
    cat > "$provider_path" << 'EOF'
<?php

namespace App\Providers\Filament;

use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('admin')
            ->path('/admin')
            ->login()
            ->colors([
                'primary' => Color::Gray,
            ])
            ->darkMode()
            ->sidebarCollapsibleOnDesktop()
            ->maxContentWidth('full')
            ->brandName('Salbion Group')
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\Filament\\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\\Filament\\Pages')
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\\Filament\\Widgets')
            ->middleware([
                'web',
                'auth',
            ])
            ->plugins([
                // Add plugins here
            ]);
    }
}
EOF
    
    log_message "success" "Filament AdminPanelProvider configured"
}

# Update models
update_models() {
    log_header "UPDATING MODELS"
    
    # Function to update model with HasSlug
    update_model_with_slug() {
        local model_path="$1"
        local slug_field="$2"
        local model_name=$(basename "$model_path" .php)
        
        if [[ ! -f "$model_path" ]]; then
            log_message "warning" "$model_name model not found"
            return 1
        fi
        
        # Check if already has HasSlug
        if grep -q "use HasSlug;" "$model_path"; then
            log_message "success" "$model_name already has HasSlug"
            return 0
        fi
        
        # Create backup
        cp "$model_path" "$model_path.backup_$TIMESTAMP"
        
        # Add use statements
        sed -i '/use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;/a\
use Spatie\\Sluggable\\HasSlug;\
use Spatie\\Sluggable\\SlugOptions;' "$model_path"
        
        # Add trait to class
        sed -i 's/use HasFactory;/use HasFactory, HasSlug;/' "$model_path"
        
        # Add getSlugOptions method
        sed -i '$i\
\
    public function getSlugOptions(): SlugOptions\
    {\
        return SlugOptions::create()\
            ->generateSlugsFrom('"'"$slug_field"'"')\
            ->saveSlugsTo('"'"'slug'"'"');\
    }' "$model_path"
        
        log_message "success" "Updated $model_name with HasSlug"
    }
    
    # Update specific models
    local models=(
        "app/Models/Product.php:name"
        "app/Models/Page.php:title"
        "app/Models/Category.php:name"
    )
    
    for model_info in "${models[@]}"; do
        local model_path="$PROJECT_ROOT/${model_info%:*}"
        local slug_field="${model_info#*:}"
        update_model_with_slug "$model_path" "$slug_field"
    done
}

# Update frontend
update_frontend() {
    log_header "UPDATING FRONTEND"
    
    local css_file="$PROJECT_ROOT/resources/css/app.css"
    
    # Create CSS directory if it doesn't exist
    mkdir -p "$(dirname "$css_file")"
    
    # Update CSS file
    if [[ -f "$css_file" ]]; then
        if ! grep -q "@import '@fontsource/sf-pro-display'" "$css_file"; then
            # Create new CSS content
            local temp_css="/tmp/app_css_$TIMESTAMP"
            
            cat > "$temp_css" << 'EOF'
@import '@fontsource/sf-pro-display';
@import '@fontsource/sf-pro-display/400.css';
@import '@fontsource/sf-pro-display/600.css';
@import '@fontsource/sf-pro-display/700.css';

EOF
            
            # Append existing content
            cat "$css_file" >> "$temp_css"
            mv "$temp_css" "$css_file"
            
            log_message "success" "Updated CSS with SF Pro Display"
        else
            log_message "success" "SF Pro Display already in CSS"
        fi
    else
        # Create new CSS file
        cat > "$css_file" << 'EOF'
@import '@fontsource/sf-pro-display';
@import '@fontsource/sf-pro-display/400.css';
@import '@fontsource/sf-pro-display/600.css';
@import '@fontsource/sf-pro-display/700.css';

@tailwind base;
@tailwind components;
@tailwind utilities;

body {
    font-family: 'SF Pro Display', system-ui, -apple-system, sans-serif;
}
EOF
        log_message "success" "Created new CSS file with SF Pro Display"
    fi
    
    # Create Livewire component if needed
    if [[ ! -f "$PROJECT_ROOT/app/Livewire/ProductGallery.php" ]]; then
        execute_cmd "cd '$PROJECT_ROOT' && php artisan make:livewire ProductGallery" \
            "Created ProductGallery component" \
            "Failed to create ProductGallery component" \
            true
    fi
}

# Run optimizations
run_optimizations() {
    log_header "RUNNING OPTIMIZATIONS"
    
    # Clear caches
    local cache_commands=(
        "config:clear"
        "route:clear"
        "view:clear"
        "cache:clear"
    )
    
    for cmd in "${cache_commands[@]}"; do
        execute_cmd "cd '$PROJECT_ROOT' && php artisan $cmd" \
            "Cleared $cmd cache" \
            "Failed to clear $cmd cache" \
            true
    done
    
    # Optimize for production if needed
    if [[ "$ENVIRONMENT" == "production" ]]; then
        local optimization_commands=(
            "config:cache"
            "route:cache"
            "view:cache"
        )
        
        for cmd in "${optimization_commands[@]}"; do
            execute_cmd "cd '$PROJECT_ROOT' && php artisan $cmd" \
                "Applied $cmd optimization" \
                "Failed to apply $cmd optimization" \
                true
        done
    fi
    
    # Run general optimization
    execute_cmd "cd '$PROJECT_ROOT' && php artisan optimize" \
        "Laravel optimization completed" \
        "Failed to run Laravel optimize" \
        true
    
    # Build frontend assets
    execute_cmd "cd '$PROJECT_ROOT' && npm run build" \
        "Frontend assets built" \
        "Failed to build frontend assets"
}

# Handle Docker
handle_docker() {
    log_header "HANDLING DOCKER"
    
    if [[ -f "$PROJECT_ROOT/docker-compose.yml" ]] || [[ -f "$PROJECT_ROOT/docker-compose.yaml" ]]; then
        log_message "info" "Docker compose file detected"
        
        if command -v docker-compose >/dev/null 2>&1; then
            echo -n "Rebuild Docker containers? (y/N): "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                execute_cmd "cd '$PROJECT_ROOT' && docker-compose down" \
                    "Stopped Docker containers" \
                    "Failed to stop containers" \
                    true
                
                execute_cmd "cd '$PROJECT_ROOT' && docker-compose up -d --build" \
                    "Rebuilt Docker containers" \
                    "Failed to rebuild containers"
            fi
        else
            log_message "warning" "Docker compose not available"
        fi
    else
        log_message "info" "No Docker compose file found"
    fi
}

# Generate report
generate_report() {
    log_header "GENERATING REPORT"
    
    local report_file="$PROJECT_ROOT/upgrade_report_$TIMESTAMP.md"
    
    cat > "$report_file" << EOF
# Salbion Group Upgrade Report

**Date:** $(date)
**Script Version:** $SCRIPT_VERSION
**Environment:** $ENVIRONMENT
**Project Directory:** $PROJECT_ROOT

## Summary

- ✅ Prerequisites checked
- ✅ Backup created: \`$BACKUP_DIR\`
- ✅ Packages installed/updated
- ✅ Environment configured
- ✅ Filament configured
- ✅ Models updated with HasSlug
- ✅ Frontend assets updated
- ✅ Optimizations applied

## Installed Packages

### Composer Packages
- spatie/laravel-sluggable
- spatie/pdf-to-text
- thiagoalessio/tesseract_ocr
- pragmarx/google2fa-laravel
- spatie/laravel-permission
- spatie/laravel-activitylog
- filament/spatie-laravel-seo-plugin
- filament/spatie-laravel-analytics-plugin

### NPM Packages
- @fontsource/sf-pro-display
- alpinejs
- @tailwindcss/forms

## Next Steps

1. Test the application: \`php artisan serve\`
2. Check admin panel: Visit \`/admin\`
3. Verify all features work correctly
4. Deploy to staging for testing

## Backup Location

All backups are stored in: \`$BACKUP_DIR\`

## Log File

Detailed log: \`$LOG_FILE\`
EOF
    
    log_message "success" "Report generated: $report_file"
}

# Main function
main() {
    local start_time=$(date +%s)
    
    # Initialize
    touch "$LOG_FILE"
    log_header "STARTING SALBION GROUP UPGRADE v$SCRIPT_VERSION"
    log_message "info" "Project: $PROJECT_ROOT"
    log_message "info" "Environment: $ENVIRONMENT"
    
    # Change to project directory
    cd "$PROJECT_ROOT" || {
        log_message "error" "Cannot change to project directory"
        exit 1
    }
    
    # Execute phases
    check_prerequisites
    create_backup
    install_packages
    configure_environment
    configure_filament
    update_models
    update_frontend
    run_optimizations
    handle_docker
    generate_report
    
    # Calculate execution time
    local end_time=$(date +%s)
    local execution_time=$((end_time - start_time))
    
    # Success message
    log_header "UPGRADE COMPLETED SUCCESSFULLY"
    log_message "success" "Execution time: $((execution_time / 60))m $((execution_time % 60))s"
    log_message "info" "Backups: $BACKUP_DIR"
    log_message "info" "Log: $LOG_FILE"
    log_message "info" "Test with: php artisan serve"
    
    echo -e "\n${GREEN}🎉 Upgrade completed successfully!${RESET}"
    echo -e "${CYAN}📋 Check upgrade_report_$TIMESTAMP.md for details${RESET}"
    echo -e "${YELLOW}⚠️  Test thoroughly before production deployment${RESET}"
}

# Cleanup function
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_message "error" "Script failed with exit code $exit_code"
        echo -e "\n${RED}❌ Upgrade failed! Check $LOG_FILE${RESET}"
    fi
}

# Set trap for cleanup
trap cleanup EXIT

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
