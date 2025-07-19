#!/bin/bash

# ==============================================
# Salbion Group Project Advanced Upgrade Script
# Version: 4.0 (Production-Ready & Compatible)
# ==============================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ----------
# Configuration & Validation
# ----------
readonly SCRIPT_VERSION="4.0"
readonly MIN_PHP_VERSION="8.1"
readonly MIN_NODE_VERSION="16"

# Validate and set project root
if [[ $# -gt 1 ]]; then
    echo "Usage: $0 [project_directory]" >&2
    exit 1
fi

PROJECT_ROOT="${1:-$(pwd)}"
if [[ ! -d "$PROJECT_ROOT" ]]; then
    echo "Error: Project directory '$PROJECT_ROOT' does not exist" >&2
    exit 1
fi

# Convert to absolute path
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"

# Initialize variables
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly LOG_FILE="$PROJECT_ROOT/upgrade_log_$TIMESTAMP.txt"
readonly BACKUP_DIR="$PROJECT_ROOT/.upgrade_backups_$TIMESTAMP"
readonly TEMP_DIR="/tmp/salbion_upgrade_$$"

# Environment Detection
ENVIRONMENT="local"
IS_PRODUCTION="false"
if [[ -f "$PROJECT_ROOT/.env" ]]; then
    ENVIRONMENT=$(grep "^APP_ENV=" "$PROJECT_ROOT/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "local")
    IS_PRODUCTION=$([ "$ENVIRONMENT" = "production" ] && echo "true" || echo "false")
fi

# Color definitions (compatible with all bash versions)
COLOR_RESET='\033[0m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_CYAN='\033[0;36m'
COLOR_BLUE='\033[0;34m'
COLOR_PURPLE='\033[0;35m'
COLOR_WHITE='\033[1;37m'
COLOR_BOLD='\033[1m'

# Package configurations (using functions instead of associative arrays)
get_required_packages() {
    case "$1" in
        "list") echo "spatie/laravel-sluggable spatie/pdf-to-text thiagoalessio/tesseract_ocr pragmarx/google2fa-laravel spatie/laravel-seo spatie/laravel-analytics spatie/laravel-permission" ;;
        "spatie/laravel-sluggable") echo "Enhanced URL slugs" ;;
        "spatie/pdf-to-text") echo "PDF text extraction" ;;
        "thiagoalessio/tesseract_ocr") echo "OCR capabilities" ;;
        "pragmarx/google2fa-laravel") echo "Two-factor authentication" ;;
        "spatie/laravel-seo") echo "SEO optimization" ;;
        "spatie/laravel-analytics") echo "Analytics integration" ;;
        "spatie/laravel-permission") echo "Advanced permissions" ;;
        *) echo "Unknown package" ;;
    esac
}

get_dev_packages() {
    case "$1" in
        "list") echo "barryvdh/laravel-debugbar" ;;
        "barryvdh/laravel-debugbar") echo "Development debugging" ;;
        *) echo "Unknown package" ;;
    esac
}

get_frontend_packages() {
    case "$1" in
        "list") echo "@fontsource/inter alpinejs @tailwindcss/forms" ;;
        "@fontsource/inter") echo "Inter font family" ;;
        "alpinejs") echo "Alpine.js framework" ;;
        "@tailwindcss/forms") echo "Tailwind forms plugin" ;;
        *) echo "Unknown package" ;;
    esac
}

# Global state tracking (using simple variables)
STATUS_PREREQUISITES=""
STATUS_BACKUP=""
STATUS_REDIS=""
STATUS_COMPOSER=""
STATUS_NPM=""
STATUS_ENVIRONMENT=""
STATUS_FILAMENT=""
STATUS_MODELS=""
STATUS_FRONTEND=""
STATUS_OPTIMIZATION=""
STATUS_DOCKER=""
ROLLBACK_REQUIRED="false"

# ----------
# Core Functions
# ----------
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
            echo -e "${COLOR_BOLD}${COLOR_WHITE}\n================================" | tee -a "$LOG_FILE"
            echo -e "$timestamp 🚀 $message" | tee -a "$LOG_FILE"
            echo -e "================================${COLOR_RESET}" | tee -a "$LOG_FILE"
            ;;
        *)
            echo -e "$timestamp $message" | tee -a "$LOG_FILE"
            ;;
    esac
}

execute_command() {
    local command="$1"
    local success_msg="$2"
    local error_msg="$3"
    local silent="${4:-false}"
    local allow_failure="${5:-false}"
    
    log_message "step" "Executing: $command"
    
    if [[ "$silent" == "true" ]]; then
        if eval "$command" >/dev/null 2>>"$LOG_FILE"; then
            log_message "success" "$success_msg"
            return 0
        else
            log_message "error" "$error_msg"
            if [[ "$allow_failure" == "false" ]]; then
                ROLLBACK_REQUIRED="true"
                return 1
            fi
            return 1
        fi
    else
        if eval "$command" 2>&1 | tee -a "$LOG_FILE"; then
            log_message "success" "$success_msg"
            return 0
        else
            log_message "error" "$error_msg"
            if [[ "$allow_failure" == "false" ]]; then
                ROLLBACK_REQUIRED="true"
                return 1
            fi
            return 1
        fi
    fi
}

version_compare() {
    local version1="$1"
    local version2="$2"
    
    # Clean versions (remove any non-version characters)
    version1=$(echo "$version1" | grep -oE '^[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1)
    version2=$(echo "$version2" | grep -oE '^[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1)
    
    # If we can't parse versions, assume they're valid
    if [[ -z "$version1" ]] || [[ -z "$version2" ]]; then
        return 0
    fi
    
    # Simple version comparison using sort -V if available
    if command -v sort >/dev/null 2>&1; then
        if [[ "$(printf '%s\n' "$version1" "$version2" | sort -V | head -n1)" == "$version2" ]]; then
            return 0  # version1 >= version2
        else
            return 1  # version1 < version2
        fi
    else
        # Fallback: basic numeric comparison for major.minor
        local v1_major v1_minor v2_major v2_minor
        v1_major=$(echo "$version1" | cut -d. -f1)
        v1_minor=$(echo "$version1" | cut -d. -f2)
        v2_major=$(echo "$version2" | cut -d. -f1)
        v2_minor=$(echo "$version2" | cut -d. -f2)
        
        if [[ "$v1_major" -gt "$v2_major" ]]; then
            return 0
        elif [[ "$v1_major" -eq "$v2_major" ]] && [[ "$v1_minor" -ge "$v2_minor" ]]; then
            return 0
        else
            return 1
        fi
    fi
}

safe_file_backup() {
    local file_path="$1"
    local backup_name="${2:-$(basename "$file_path")}"
    
    if [[ -f "$file_path" ]]; then
        cp "$file_path" "$BACKUP_DIR/$backup_name"
        log_message "success" "Backed up: $file_path"
        return 0
    else
        log_message "warning" "File not found for backup: $file_path"
        return 1
    fi
}

safe_file_modify() {
    local file_path="$1"
    local description="$2"
    local modification_function="$3"
    
    if [[ ! -f "$file_path" ]]; then
        log_message "warning" "File not found: $file_path"
        return 1
    fi
    
    # Create backup
    safe_file_backup "$file_path" "$(basename "$file_path").pre_$TIMESTAMP"
    
    # Create temp file for modifications
    local temp_file="$TEMP_DIR/$(basename "$file_path")"
    cp "$file_path" "$temp_file"
    
    # Apply modification
    if $modification_function "$temp_file"; then
        # Verify the file is still valid (basic check)
        if [[ -s "$temp_file" ]]; then
            mv "$temp_file" "$file_path"
            log_message "success" "$description"
            return 0
        else
            log_message "error" "File became empty after modification: $file_path"
            return 1
        fi
    else
        log_message "error" "Failed to modify: $file_path"
        return 1
    fi
}

check_prerequisites() {
    log_message "header" "CHECKING PREREQUISITES"
    
    # Check if running as root (security warning)
    if [[ "$EUID" -eq 0 ]]; then
        log_message "error" "This script should not be run as root for security reasons"
        exit 1
    fi
    
    # Check required commands
    local required_commands="php composer npm node"
    for cmd in $required_commands; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_message "error" "$cmd is not installed or not in PATH"
            exit 1
        fi
        log_message "success" "$cmd is available"
    done
    
    # Check PHP version
    local php_version
    php_version=$(php -r "echo PHP_VERSION;" 2>/dev/null | tail -n 1)
    if [[ $? -ne 0 ]] || [[ -z "$php_version" ]]; then
        log_message "error" "Cannot determine PHP version"
        exit 1
    fi
    
    log_message "info" "PHP Version: $php_version"
    if ! version_compare "$php_version" "$MIN_PHP_VERSION"; then
        log_message "error" "PHP version $php_version is below minimum required $MIN_PHP_VERSION"
        exit 1
    fi
    
    # Check Node.js version
    local node_version
    node_version=$(node --version | sed 's/v//' 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        log_message "error" "Cannot determine Node.js version"
        exit 1
    fi
    
    log_message "info" "Node.js Version: $node_version"
    if ! version_compare "$node_version" "$MIN_NODE_VERSION"; then
        log_message "error" "Node.js version $node_version is below minimum required $MIN_NODE_VERSION"
        exit 1
    fi
    
    # Check Laravel installation
    if [[ ! -f "$PROJECT_ROOT/artisan" ]]; then
        log_message "error" "Not a Laravel project (artisan not found)"
        exit 1
    fi
    
    # Check composer.json exists
    if [[ ! -f "$PROJECT_ROOT/composer.json" ]]; then
        log_message "error" "composer.json not found"
        exit 1
    fi
    
    # Check if project directory is writable
    if [[ ! -w "$PROJECT_ROOT" ]]; then
        log_message "error" "Project directory is not writable"
        exit 1
    fi
    
    # Verify we can create temp directory
    if ! mkdir -p "$TEMP_DIR" 2>/dev/null; then
        log_message "error" "Cannot create temporary directory"
        exit 1
    fi
    
    log_message "success" "All prerequisites met"
    STATUS_PREREQUISITES="completed"
}

create_backup() {
    log_message "header" "CREATING BACKUPS"
    
    if ! mkdir -p "$BACKUP_DIR"; then
        log_message "error" "Cannot create backup directory"
        exit 1
    fi
    
    # Critical files to backup
    local files_to_backup=".env composer.json composer.lock package.json package-lock.json config/app.php config/filament.php app/Providers/Filament/AdminPanelProvider.php app/Providers/AppServiceProvider.php app/Providers/FilamentServiceProvider.php app/Models/Product.php app/Models/Page.php app/Models/Category.php app/Models/User.php resources/css/app.css resources/js/app.js tailwind.config.js vite.config.js"
    
    local backup_count=0
    for file in $files_to_backup; do
        if safe_file_backup "$PROJECT_ROOT/$file"; then
            ((backup_count++))
        fi
    done
    
    # Create database backup if possible
    create_database_backup
    
    log_message "info" "Backed up $backup_count files to: $BACKUP_DIR"
    STATUS_BACKUP="completed"
}

create_database_backup() {
    if [[ ! -f "$PROJECT_ROOT/.env" ]]; then
        log_message "warning" "No .env file found - skipping database backup"
        return 1
    fi
    
    # Safely extract database credentials
    local db_connection db_name db_user db_pass db_host db_port
    
    db_connection=$(grep "^DB_CONNECTION=" "$PROJECT_ROOT/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "mysql")
    db_name=$(grep "^DB_DATABASE=" "$PROJECT_ROOT/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "")
    db_user=$(grep "^DB_USERNAME=" "$PROJECT_ROOT/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "")
    db_pass=$(grep "^DB_PASSWORD=" "$PROJECT_ROOT/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "")
    db_host=$(grep "^DB_HOST=" "$PROJECT_ROOT/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "localhost")
    db_port=$(grep "^DB_PORT=" "$PROJECT_ROOT/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "3306")
    
    if [[ -z "$db_name" ]]; then
        log_message "warning" "No database name configured - skipping database backup"
        return 1
    fi
    
    if [[ "$db_connection" == "mysql" ]] && command -v mysqldump >/dev/null 2>&1; then
        # Use more secure approach with defaults file
        local mysql_defaults_file="$TEMP_DIR/mysql_defaults"
        cat > "$mysql_defaults_file" << EOF
[client]
host=$db_host
port=$db_port
user=$db_user
password=$db_pass
EOF
        chmod 600 "$mysql_defaults_file"
        
        if mysqldump --defaults-file="$mysql_defaults_file" \
           --single-transaction \
           --routines \
           --triggers \
           "$db_name" > "$BACKUP_DIR/database_backup.sql" 2>/dev/null; then
            log_message "success" "Database backup created"
        else
            log_message "warning" "Could not create database backup - continuing anyway"
        fi
        
        # Clean up credentials file
        rm -f "$mysql_defaults_file"
    else
        log_message "info" "Database backup not available for connection type: $db_connection"
    fi
}

check_redis_configuration() {
    log_message "header" "CHECKING REDIS CONFIGURATION"
    
    # Check if Redis extension is loaded (suppress warnings)
    if php -m 2>/dev/null | grep -q redis; then
        log_message "success" "Redis extension is loaded"
    else
        log_message "warning" "Redis extension not found"
        log_message "info" "Please ensure Redis extension is installed: sudo apt-get install php-redis (Ubuntu/Debian)"
        log_message "info" "Or: brew install php-redis (macOS with Homebrew)"
    fi
    
    # Check if Redis server is running
    if command -v redis-cli >/dev/null 2>&1; then
        if redis-cli ping >/dev/null 2>&1; then
            log_message "success" "Redis server is running"
        else
            log_message "warning" "Redis server is not running"
        fi
    else
        log_message "info" "Redis CLI not found - install Redis server if needed"
    fi
    
    STATUS_REDIS="completed"
}

install_composer_packages() {
    log_message "header" "INSTALLING COMPOSER PACKAGES"
    
    # Update composer first
    execute_command "cd '$PROJECT_ROOT' && composer self-update" \
        "Composer updated" \
        "Failed to update Composer" \
        true \
        true  # Allow failure
    
    # Validate composer.json before making changes
    if ! execute_command "cd '$PROJECT_ROOT' && composer validate" \
        "composer.json is valid" \
        "composer.json validation failed" \
        true; then
        log_message "error" "Cannot proceed with invalid composer.json"
        return 1
    fi
    
    # Install production packages
    local required_packages
    required_packages=$(get_required_packages "list")
    for package in $required_packages; do
        local description
        description=$(get_required_packages "$package")
        
        if composer show "$package" --working-dir="$PROJECT_ROOT" >/dev/null 2>&1; then
            log_message "success" "$package already installed ($description)"
        else
            log_message "step" "Installing $package - $description"
            execute_command "cd '$PROJECT_ROOT' && composer require '$package' --no-interaction --prefer-stable" \
                "Installed $package" \
                "Failed to install $package"
        fi
    done
    
    # Install development packages only in non-production
    if [[ "$IS_PRODUCTION" != "true" ]]; then
        local dev_packages
        dev_packages=$(get_dev_packages "list")
        for package in $dev_packages; do
            local description
            description=$(get_dev_packages "$package")
            
            if composer show "$package" --dev --working-dir="$PROJECT_ROOT" >/dev/null 2>&1; then
                log_message "success" "$package already installed ($description)"
            else
                log_message "step" "Installing $package - $description"
                execute_command "cd '$PROJECT_ROOT' && composer require '$package' --dev --no-interaction --prefer-stable" \
                    "Installed $package (dev)" \
                    "Failed to install $package"
            fi
        done
    fi
    
    # Optimize autoloader (but don't exclude dev packages if they were just installed)
    local autoload_cmd="composer dump-autoload --optimize"
    if [[ "$IS_PRODUCTION" == "true" ]]; then
        autoload_cmd="$autoload_cmd --no-dev"
    fi
    
    execute_command "cd '$PROJECT_ROOT' && $autoload_cmd" \
        "Composer autoload optimized" \
        "Failed to optimize autoload" \
        true \
        true  # Allow failure
    
    STATUS_COMPOSER="completed"
}

install_npm_packages() {
    log_message "header" "INSTALLING NPM PACKAGES"
    
    # Verify package.json exists
    if [[ ! -f "$PROJECT_ROOT/package.json" ]]; then
        log_message "warning" "package.json not found - creating basic one"
        cat > "$PROJECT_ROOT/package.json" << 'EOF'
{
    "private": true,
    "scripts": {
        "build": "vite build",
        "dev": "vite"
    },
    "devDependencies": {
        "axios": "^1.6.4",
        "laravel-vite-plugin": "^1.0.0",
        "vite": "^5.0.0"
    }
}
EOF
    fi
    
    # Clean install npm packages
    execute_command "cd '$PROJECT_ROOT' && npm ci --silent" \
        "NPM packages installed from lockfile" \
        "Failed to install NPM packages from lockfile" \
        true \
        true
    
    # If ci fails, try regular install
    if [[ $? -ne 0 ]]; then
        execute_command "cd '$PROJECT_ROOT' && npm install --silent" \
            "NPM packages installed" \
            "Failed to install NPM packages"
    fi
    
    # Install additional packages
    local frontend_packages
    frontend_packages=$(get_frontend_packages "list")
    for package in $frontend_packages; do
        local description
        description=$(get_frontend_packages "$package")
        
        # Check if package is already in package.json
        if grep -q "\"$package\"" "$PROJECT_ROOT/package.json"; then
            log_message "success" "$package already in package.json ($description)"
        else
            log_message "step" "Installing $package - $description"
            execute_command "cd '$PROJECT_ROOT' && npm install '$package' --silent" \
                "Installed $package" \
                "Failed to install $package"
        fi
    done
    
    STATUS_NPM="completed"
}

update_environment_config() {
    log_message "header" "UPDATING ENVIRONMENT CONFIGURATION"
    
    if [[ ! -f "$PROJECT_ROOT/.env" ]]; then
        log_message "error" ".env file not found"
        return 1
    fi
    
    modify_env_file() {
        local env_file="$1"
        
        # Create a new .env file with proper modifications
        local temp_env="$TEMP_DIR/.env.new"
        
        # Copy existing file
        cp "$env_file" "$temp_env"
        
        # Update APP_DEBUG based on environment
        if [[ "$IS_PRODUCTION" == "true" ]]; then
            sed -i 's/^APP_DEBUG=.*/APP_DEBUG=false/' "$temp_env"
        fi
        
        # Add missing environment variables if needed
        local env_vars="FILAMENT_DARK_MODE=true CACHE_DRIVER=redis SESSION_DRIVER=redis QUEUE_CONNECTION=redis"
        
        for var in $env_vars; do
            local key="${var%=*}"
            if ! grep -q "^$key=" "$temp_env"; then
                echo "$var" >> "$temp_env"
                log_message "info" "Added environment variable: $key"
            fi
        done
        
        return 0
    }
    
    safe_file_modify "$PROJECT_ROOT/.env" "Environment configuration updated" modify_env_file
    STATUS_ENVIRONMENT="completed"
}

configure_filament() {
    log_message "header" "CONFIGURING FILAMENT"
    
    local provider_path="$PROJECT_ROOT/app/Providers/Filament/AdminPanelProvider.php"
    
    # Check if file exists and has customizations
    if [[ -f "$provider_path" ]]; then
        # Check if file looks like it has been customized
        if grep -q "brandName\|colors\|plugins" "$provider_path" 2>/dev/null; then
            log_message "warning" "AdminPanelProvider appears to be customized - skipping automatic update"
            log_message "info" "Please manually review and update: $provider_path"
            return 0
        fi
    fi
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$provider_path")"
    
    # Create or update provider
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
            ->pages([
                // Custom pages
            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\\Filament\\Widgets')
            ->widgets([
                // Custom widgets
            ])
            ->middleware([
                'web',
                'auth',
            ])
            ->authMiddleware([
                'auth',
            ]);
    }
}
EOF
    
    log_message "success" "AdminPanelProvider configured"
    STATUS_FILAMENT="completed"
}

update_models() {
    log_message "header" "UPDATING MODELS"
    
    # Function to safely update a model with HasSlug trait
    update_model_with_slug() {
        local model_path="$1"
        local slug_field="$2"
        local model_name
        model_name=$(basename "$model_path" .php)
        
        if [[ ! -f "$model_path" ]]; then
            log_message "warning" "$model_name model not found at $model_path"
            return 1
        fi
        
        # Check if already has HasSlug
        if grep -q "use HasSlug;" "$model_path"; then
            log_message "success" "$model_name model already has HasSlug trait"
            return 0
        fi
        
        modify_model() {
            local file="$1"
            
            # Check if this looks like a valid Eloquent model
            if ! grep -q "extends Model" "$file"; then
                log_message "warning" "$model_name does not appear to be an Eloquent model"
                return 1
            fi
            
            # Use a more robust approach with awk instead of sed for complex replacements
            # Create a temporary script
            local awk_script="$TEMP_DIR/model_update.awk"
            
            cat > "$awk_script" << 'EOF'
BEGIN { 
    added_use = 0; 
    added_trait = 0; 
    added_method = 0; 
}

# Add use statements after Eloquent Model import
/use Illuminate\\Database\\Eloquent\\Model;/ {
    print $0
    if (!added_use) {
        print ""
        print "use Spatie\\Sluggable\\HasSlug;"
        print "use Spatie\\Sluggable\\SlugOptions;"
        added_use = 1
    }
    next
}

# Add HasSlug to existing use clause
/use HasFactory;/ {
    gsub(/use HasFactory;/, "use HasFactory, HasSlug;")
    added_trait = 1
}

# Add use clause after class declaration if no existing use clause
/^class.*extends Model/ {
    print $0
    if (!added_trait) {
        print "    use HasSlug;"
        added_trait = 1
    }
    next
}

# Add method before the last closing brace
/^}$/ && !added_method {
    print ""
    print "    /**"
    print "     * Get the options for generating the slug."
    print "     */"
    print "    public function getSlugOptions(): SlugOptions"
    print "    {"
    print "        return SlugOptions::create()"
    print "            ->generateSlugsFrom('" slug_field "')"
    print "            ->saveSlugsTo('slug')"
    print "            ->doNotGenerateSlugsOnUpdate();"
    print "    }"
    added_method = 1
}

{ print }
EOF
            
            # Apply the awk script
            awk -v slug_field="$slug_field" -f "$awk_script" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            
            # Clean up
            rm -f "$awk_script"
            
            return 0
        }
        
        safe_file_modify "$model_path" "Updated $model_name model with HasSlug trait" modify_model
    }
    
    # Update specific models if they exist
    local models_to_update="app/Models/Product.php:name app/Models/Page.php:title app/Models/Category.php:name app/Models/Post.php:title"
    
    for model_info in $models_to_update; do
        local model_path="${model_info%:*}"
        local slug_field="${model_info#*:}"
        update_model_with_slug "$PROJECT_ROOT/$model_path" "$slug_field"
    done
    
    STATUS_MODELS="completed"
}

update_frontend_assets() {
    log_message "header" "UPDATING FRONTEND ASSETS"
    
    # Update CSS
    local css_file="$PROJECT_ROOT/resources/css/app.css"
    
    update_css_file() {
        local file="$1"
        
        # Check if Inter font is already imported
        if grep -q "@import.*@fontsource/inter" "$file"; then
            log_message "success" "Inter font already imported in CSS"
            return 0
        fi
        
        # Create new CSS content
        local temp_css="$TEMP_DIR/app.css"
        
        # Add imports at the beginning
        cat > "$temp_css" << 'EOF'
@import '@fontsource/inter';
@import '@fontsource/inter/400.css';
@import '@fontsource/inter/600.css';
@import '@fontsource/inter/700.css';

EOF
        
        # Append existing content if file exists
        if [[ -f "$file" ]]; then
            cat "$file" >> "$temp_css"
        else
            # Add Tailwind directives if new file
            cat >> "$temp_css" << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Custom styles */
body {
    font-family: 'Inter', system-ui, -apple-system, sans-serif;
}
EOF
        fi
        
        mv "$temp_css" "$file"
        return 0
    }
    
    # Create CSS directory if it doesn't exist
    mkdir -p "$(dirname "$css_file")"
    
    if [[ -f "$css_file" ]]; then
        safe_file_modify "$css_file" "Updated CSS with Inter font" update_css_file
    else
        update_css_file "$css_file"
        log_message "success" "Created new CSS file with Inter font"
    fi
    
    # Create Livewire components if they don't exist
    if [[ ! -f "$PROJECT_ROOT/app/Livewire/ProductGallery.php" ]]; then
        execute_command "cd '$PROJECT_ROOT' && php artisan make:livewire ProductGallery" \
            "Created ProductGallery Livewire component" \
            "Failed to create ProductGallery component" \
            true \
            true
    fi
    
    STATUS_FRONTEND="completed"
}

run_optimizations() {
    log_message "header" "RUNNING OPTIMIZATIONS"
    
    # Clear all caches first
    local cache_commands="config:clear route:clear view:clear cache:clear event:clear"
    
    for cmd in $cache_commands; do
        execute_command "cd '$PROJECT_ROOT' && php artisan $cmd" \
            "Cleared $(echo "$cmd" | cut -d':' -f2) cache" \
            "Failed to clear cache" \
            true \
            true  # Allow failure
    done
    
    # Run optimizations (only in production)
    if [[ "$IS_PRODUCTION" == "true" ]]; then
        local optimization_commands="config:cache route:cache view:cache event:cache"
        
        for cmd in $optimization_commands; do
            execute_command "cd '$PROJECT_ROOT' && php artisan $cmd" \
                "Applied $(echo "$cmd" | cut -d':' -f2) optimization" \
                "Failed to optimize" \
                true \
                true  # Allow failure
        done
    fi
    
    # Run Laravel optimization
    execute_command "cd '$PROJECT_ROOT' && php artisan optimize" \
        "Laravel optimization completed" \
        "Failed to run Laravel optimize" \
        true \
        true
    
    # Build frontend assets
    execute_command "cd '$PROJECT_ROOT' && npm run build" \
        "Built frontend assets" \
        "Failed to build frontend assets"
    
    STATUS_OPTIMIZATION="completed"
}

handle_docker() {
    log_message "header" "HANDLING DOCKER (IF PRESENT)"
    
    local docker_compose_file=""
    if [[ -f "$PROJECT_ROOT/docker-compose.yml" ]]; then
        docker_compose_file="$PROJECT_ROOT/docker-compose.yml"
    elif [[ -f "$PROJECT_ROOT/docker-compose.yaml" ]]; then
        docker_compose_file="$PROJECT_ROOT/docker-compose.yaml"
    fi
    
    if [[ -n "$docker_compose_file" ]]; then
        log_message "info" "Docker compose file detected: $(basename "$docker_compose_file")"
        
        if command -v docker >/dev/null 2>&1 && command -v docker-compose >/dev/null 2>&1; then
            if [[ "$IS_PRODUCTION" != "true" ]]; then
                echo -n "Rebuild Docker containers? (y/N): "
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    execute_command "cd '$PROJECT_ROOT' && docker-compose down" \
                        "Stopped Docker containers" \
                        "Failed to stop containers" \
                        false \
                        true
                    execute_command "cd '$PROJECT_ROOT' && docker-compose up -d --build" \
                        "Rebuilt and started Docker containers" \
                        "Failed to rebuild containers" \
                        false \
                        true
                fi
            else
                log_message "info" "Production environment - skipping Docker rebuild"
            fi
        else
            log_message "warning" "Docker not available but compose file found"
        fi
    else
        log_message "info" "No Docker compose file found - skipping Docker operations"
    fi
    
    STATUS_DOCKER="completed"
}

rollback_changes() {
    log_message "header" "ROLLING BACK CHANGES"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_message "error" "Backup directory not found - cannot rollback"
        return 1
    fi
    
    # Restore backed up files
    for backup_file in "$BACKUP_DIR"/*; do
        if [[ -f "$backup_file" ]]; then
            local original_name
            original_name=$(basename "$backup_file" | sed 's/\.pre_[0-9]*_[0-9]*$//')
            local original_path="$PROJECT_ROOT/$original_name"
            
            if [[ -f "$original_path" ]]; then
                cp "$backup_file" "$original_path"
                log_message "success" "Restored: $original_name"
            fi
        fi
    done
    
    # Run composer install to restore dependencies
    execute_command "cd '$PROJECT_ROOT' && composer install" \
        "Restored composer dependencies" \
        "Failed to restore composer dependencies" \
        true \
        true
    
    log_message "warning" "Rollback completed - please verify your application"
}

get_status() {
    local component="$1"
    case "$component" in
        "prerequisites") echo "$STATUS_PREREQUISITES" ;;
        "backup") echo "$STATUS_BACKUP" ;;
        "redis") echo "$STATUS_REDIS" ;;
        "composer") echo "$STATUS_COMPOSER" ;;
        "npm") echo "$STATUS_NPM" ;;
        "environment") echo "$STATUS_ENVIRONMENT" ;;
        "filament") echo "$STATUS_FILAMENT" ;;
        "models") echo "$STATUS_MODELS" ;;
        "frontend") echo "$STATUS_FRONTEND" ;;
        "optimization") echo "$STATUS_OPTIMIZATION" ;;
        "docker") echo "$STATUS_DOCKER" ;;
        *) echo "" ;;
    esac
}

generate_report() {
    log_message "header" "GENERATING UPGRADE REPORT"
    
    local report_file="$PROJECT_ROOT/upgrade_report_$TIMESTAMP.md"
    
    cat > "$report_file" << EOF
# Salbion Group Project Upgrade Report

**Date:** $(date)  
**Environment:** $ENVIRONMENT  
**Upgrade Script Version:** $SCRIPT_VERSION  
**Project Directory:** $PROJECT_ROOT

## Summary

EOF
    
    # Add status for each component
    local components="prerequisites backup redis composer npm environment filament models frontend optimization docker"
    for component in $components; do
        local status
        status=$(get_status "$component")
        if [[ "$status" == "completed" ]]; then
            echo "- ✅ $(echo "$component" | tr '[:lower:]' '[:upper:]') completed successfully" >> "$report_file"
        else
            echo "- ❌ $(echo "$component" | tr '[:lower:]' '[:upper:]') failed or skipped" >> "$report_file"
        fi
    done
    
    cat >> "$report_file" << EOF

## System Information

- **PHP Version:** $(php -v | head -n1)
- **Composer Version:** $(composer --version 2>/dev/null || echo "Not available")
- **Node.js Version:** $(node --version 2>/dev/null || echo "Not available")
- **NPM Version:** $(npm --version 2>/dev/null || echo "Not available")

## Installed Packages

### Composer Packages
EOF
    
    local required_packages
    required_packages=$(get_required_packages "list")
    for package in $required_packages; do
        local description
        description=$(get_required_packages "$package")
        echo "- **$package**: $description" >> "$report_file"
    done
    
    if [[ "$IS_PRODUCTION" != "true" ]]; then
        echo -e "\n### Development Packages" >> "$report_file"
        local dev_packages
        dev_packages=$(get_dev_packages "list")
        for package in $dev_packages; do
            local description
            description=$(get_dev_packages "$package")
            echo "- **$package**: $description" >> "$report_file"
        done
    fi
    
    cat >> "$report_file" << EOF

### NPM Packages
EOF
    
    local frontend_packages
    frontend_packages=$(get_frontend_packages "list")
    for package in $frontend_packages; do
        local description
        description=$(get_frontend_packages "$package")
        echo "- **$package**: $description" >> "$report_file"
    done
    
    cat >> "$report_file" << EOF

## Backup Information

- **Backup Directory:** \`$BACKUP_DIR\`
- **Database Backup:** $([ -f "$BACKUP_DIR/database_backup.sql" ] && echo "✅ Created" || echo "❌ Not created")

## Next Steps

1. **Test the application:** \`cd $PROJECT_ROOT && php artisan serve\`
2. **Check admin panel:** Visit \`/admin\` and verify functionality
3. **Run tests:** \`php artisan test\` (if tests exist)
4. **Check logs:** Review Laravel logs for any errors
5. **Deploy to staging:** Test in staging environment before production

## Verification Commands

\`\`\`bash
cd $PROJECT_ROOT

# Check Laravel installation
php artisan --version

# Verify database connection
php artisan migrate:status

# Check Filament installation
php artisan filament:install --help

# Test frontend build
npm run build
\`\`\`

## Rollback Instructions

If issues occur, restore from backups:

\`\`\`bash
# Restore configuration files
cp $BACKUP_DIR/.env $PROJECT_ROOT/
cp $BACKUP_DIR/composer.json $PROJECT_ROOT/

# Restore dependencies
cd $PROJECT_ROOT
composer install
npm install

# Clear caches
php artisan config:clear
php artisan cache:clear
\`\`\`

## Support

- **Log File:** \`$LOG_FILE\`
- **Backup Directory:** \`$BACKUP_DIR\`
- **Script Version:** $SCRIPT_VERSION
- **Timestamp:** $TIMESTAMP

EOF
    
    log_message "success" "Upgrade report generated: $report_file"
}

# ----------
# Main Execution Flow
# ----------
main() {
    local start_time
    start_time=$(date +%s)
    
    # Initialize logging
    touch "$LOG_FILE"
    log_message "header" "STARTING SALBION GROUP PROJECT UPGRADE"
    log_message "info" "Script Version: $SCRIPT_VERSION"
    log_message "info" "Project Directory: $PROJECT_ROOT"
    log_message "info" "Environment: $ENVIRONMENT"
    log_message "info" "Log File: $LOG_FILE"
    
    # Change to project directory
    if ! cd "$PROJECT_ROOT"; then
        log_message "error" "Cannot change to project directory: $PROJECT_ROOT"
        exit 1
    fi
    
    # Execute upgrade phases
    local phases="check_prerequisites create_backup check_redis_configuration install_composer_packages install_npm_packages update_environment_config configure_filament update_models update_frontend_assets run_optimizations handle_docker"
    
    for phase in $phases; do
        if ! $phase; then
            log_message "error" "Phase $phase failed"
            if [[ "$ROLLBACK_REQUIRED" == "true" ]]; then
                rollback_changes
            fi
            exit 1
        fi
    done
    
    # Generate report
    generate_report
    
    # Calculate execution time
    local end_time
    end_time=$(date +%s)
    local execution_time=$((end_time - start_time))
    
    log_message "header" "UPGRADE COMPLETED SUCCESSFULLY!"
    log_message "success" "Total execution time: $((execution_time / 60))m $((execution_time % 60))s"
    log_message "info" "Backups stored in: $BACKUP_DIR"
    log_message "info" "Detailed log: $LOG_FILE"
    log_message "info" "Run 'cd $PROJECT_ROOT && php artisan serve' to test your upgraded project"
    
    echo -e "\n${COLOR_GREEN}🎉 Upgrade process completed successfully!${COLOR_RESET}"
    echo -e "${COLOR_CYAN}📋 Check the upgrade report and log files for details${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}⚠️  Remember to test thoroughly before deploying to production${COLOR_RESET}"
}

# ----------
# Error Handling & Cleanup
# ----------
cleanup() {
    local exit_code=$?
    
    # Clean up temporary directory
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    
    if [[ $exit_code -ne 0 ]]; then
        log_message "error" "Script failed with exit code $exit_code"
        log_message "info" "Check the log file for details: $LOG_FILE"
        echo -e "\n${COLOR_RED}❌ Upgrade failed! Check the log file for details.${COLOR_RESET}"
        
        if [[ "$ROLLBACK_REQUIRED" == "true" ]] && [[ -d "$BACKUP_DIR" ]]; then
            echo -e "${COLOR_YELLOW}🔄 Consider running rollback manually if needed${COLOR_RESET}"
        fi
    fi
}

# Set up signal handlers
trap cleanup EXIT
trap 'log_message "warning" "Script interrupted by user"; exit 130' INT TERM

# ----------
# Script Entry Point
# ----------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
