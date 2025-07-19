#!/bin/bash

# 🚀 Salbion Group Project Health Check Script
# این اسکریپت تمام جنبه‌های پروژه را بررسی می‌کند

echo "🔍 Starting Salbion Group Project Health Check..."
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC}: $2"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}: $2"
        ((FAILED++))
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARN${NC}: $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ️  INFO${NC}: $1"
}

echo ""
echo "🏗️  1. PROJECT STRUCTURE CHECK"
echo "================================"

# Check Laravel installation
if [ -f "artisan" ]; then
    print_status 0 "Laravel installation found"
else
    print_status 1 "Laravel artisan file not found"
fi

# Check composer.json
if [ -f "composer.json" ]; then
    print_status 0 "Composer configuration found"
    
    # Check if Laravel 11 is installed
    if grep -q "laravel/framework" composer.json; then
        LARAVEL_VERSION=$(grep -o '"laravel/framework": "[^"]*"' composer.json | cut -d'"' -f4)
        print_info "Laravel version: $LARAVEL_VERSION"
    fi
else
    print_status 1 "composer.json not found"
fi

# Check package.json
if [ -f "package.json" ]; then
    print_status 0 "NPM configuration found"
else
    print_status 1 "package.json not found"
fi

echo ""
echo "📦 2. DEPENDENCIES CHECK"
echo "========================="

# Check FilamentPHP
if grep -q "filament/filament" composer.json; then
    print_status 0 "FilamentPHP installed"
else
    print_status 1 "FilamentPHP not installed"
fi

# Check Spatie packages
SPATIE_PACKAGES=("spatie/laravel-permission" "spatie/laravel-medialibrary" "spatie/laravel-sluggable" "spatie/laravel-activitylog")
for package in "${SPATIE_PACKAGES[@]}"; do
    if grep -q "$package" composer.json; then
        print_status 0 "$package installed"
    else
        print_status 1 "$package not installed"
    fi
done

# Check other required packages
OTHER_PACKAGES=("intervention/image" "laravel/sanctum" "league/flysystem-aws-s3-v3")
for package in "${OTHER_PACKAGES[@]}"; do
    if grep -q "$package" composer.json; then
        print_status 0 "$package installed"
    else
        print_warning "$package not installed (optional)"
    fi
done

echo ""
echo "🗄️  3. DATABASE & MIGRATIONS CHECK"
echo "===================================="

# Check .env file
if [ -f ".env" ]; then
    print_status 0 ".env file exists"
    
    # Check database configuration
    if grep -q "DB_DATABASE=salbion_group" .env; then
        print_status 0 "Database name configured"
    else
        print_warning "Database name not set to salbion_group"
    fi
    
    if grep -q "DB_CONNECTION=mysql" .env; then
        print_status 0 "MySQL connection configured"
    else
        print_warning "Database connection not set to MySQL"
    fi
else
    print_status 1 ".env file not found"
fi

# Check migration files
REQUIRED_MIGRATIONS=("create_categories_table" "create_products_table" "create_pages_table")
for migration in "${REQUIRED_MIGRATIONS[@]}"; do
    if ls database/migrations/*${migration}.php 1> /dev/null 2>&1; then
        print_status 0 "Migration: $migration"
    else
        print_status 1 "Migration: $migration"
    fi
done

# Check vendor migrations
VENDOR_MIGRATIONS=("create_permission_tables" "create_activity_log_table" "create_media_table")
for migration in "${VENDOR_MIGRATIONS[@]}"; do
    if ls database/migrations/*${migration}.php 1> /dev/null 2>&1; then
        print_status 0 "Vendor migration: $migration"
    else
        print_status 1 "Vendor migration: $migration"
    fi
done

echo ""
echo "🏛️  4. MODELS CHECK"
echo "==================="

# Check model files
REQUIRED_MODELS=("Category" "Product" "Page" "User")
for model in "${REQUIRED_MODELS[@]}"; do
    if [ -f "app/Models/${model}.php" ]; then
        print_status 0 "Model: ${model}.php"
        
        # Check if model has proper traits
        case $model in
            "Category"|"Product"|"Page")
                if grep -q "use HasSlug" "app/Models/${model}.php"; then
                    print_status 0 "Model $model has HasSlug trait"
                else
                    print_warning "Model $model missing HasSlug trait"
                fi
                ;;
        esac
    else
        print_status 1 "Model: ${model}.php"
    fi
done

echo ""
echo "🎛️  5. FILAMENT RESOURCES CHECK"
echo "==============================="

# Check FilamentPHP admin panel
if [ -d "app/Providers/Filament" ]; then
    print_status 0 "Filament admin panel provider found"
else
    print_status 1 "Filament admin panel provider not found"
fi

# Check Filament resources
FILAMENT_RESOURCES=("CategoryResource" "ProductResource")
for resource in "${FILAMENT_RESOURCES[@]}"; do
    if [ -f "app/Filament/Resources/${resource}.php" ]; then
        print_status 0 "Filament resource: ${resource}.php"
    else
        print_status 1 "Filament resource: ${resource}.php"
    fi
done

echo ""
echo "🎨 6. FRONTEND ASSETS CHECK"
echo "==========================="

# Check public directories
PUBLIC_DIRS=("css" "js" "images")
for dir in "${PUBLIC_DIRS[@]}"; do
    if [ -d "public/$dir" ]; then
        print_status 0 "Public directory: $dir"
    else
        print_status 1 "Public directory: $dir"
    fi
done

# Check storage link
if [ -L "public/storage" ]; then
    print_status 0 "Storage link exists"
else
    print_warning "Storage link not created (run: php artisan storage:link)"
fi

# Check Vite build
if [ -d "public/build" ]; then
    print_status 0 "Vite build assets found"
else
    print_warning "Vite build assets not found (run: npm run build)"
fi

echo ""
echo "⚙️  7. CONFIGURATION CHECK"
echo "=========================="

# Check config files
CONFIG_FILES=("permission.php")
for config in "${CONFIG_FILES[@]}"; do
    if [ -f "config/$config" ]; then
        print_status 0 "Config file: $config"
    else
        print_warning "Config file: $config not published"
    fi
done

echo ""
echo "🧪 8. FUNCTIONALITY TEST"
echo "========================"

# Test Laravel
if php artisan --version &>/dev/null; then
    print_status 0 "Laravel artisan working"
    LARAVEL_VERSION=$(php artisan --version | cut -d' ' -f3)
    print_info "Laravel version: $LARAVEL_VERSION"
else
    print_status 1 "Laravel artisan not working"
fi

# Test database connection
if php artisan migrate:status &>/dev/null; then
    print_status 0 "Database connection working"
    
    # Check if migrations are run
    MIGRATION_STATUS=$(php artisan migrate:status 2>/dev/null | grep "Ran" | wc -l)
    if [ $MIGRATION_STATUS -gt 0 ]; then
        print_status 0 "Migrations executed ($MIGRATION_STATUS migrations ran)"
    else
        print_warning "No migrations have been run"
    fi
else
    print_status 1 "Database connection failed"
fi

# Test Filament
if [ -f "app/Providers/Filament/AdminPanelProvider.php" ]; then
    print_status 0 "Filament admin panel configured"
else
    print_status 1 "Filament admin panel not configured"
fi

echo ""
echo "🔒 9. SECURITY CHECK"
echo "==================="

# Check APP_KEY
if grep -q "APP_KEY=base64:" .env 2>/dev/null; then
    print_status 0 "Application key generated"
else
    print_warning "Application key not generated (run: php artisan key:generate)"
fi

# Check APP_DEBUG
if grep -q "APP_DEBUG=false" .env 2>/dev/null; then
    print_info "Debug mode: Production (false)"
elif grep -q "APP_DEBUG=true" .env 2>/dev/null; then
    print_warning "Debug mode: Development (true) - Set to false for production"
fi

echo ""
echo "📊 10. PERFORMANCE CHECK"
echo "========================"

# Check cache directories
CACHE_DIRS=("bootstrap/cache" "storage/framework/cache" "storage/framework/sessions" "storage/framework/views")
for dir in "${CACHE_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        print_status 0 "Cache directory: $dir"
    else
        print_status 1 "Cache directory: $dir"
    fi
done

# Check if caches are optimized
if [ -f "bootstrap/cache/config.php" ]; then
    print_info "Configuration cached (good for production)"
else
    print_warning "Configuration not cached (run: php artisan config:cache for production)"
fi

echo ""
echo "🔧 11. RECOMMENDED ACTIONS"
echo "=========================="

# Generate action list based on failures
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}🚨 Critical Issues Found:${NC}"
    
    # Check specific failures and suggest fixes
    if ! grep -q "filament/filament" composer.json 2>/dev/null; then
        echo "   • Install FilamentPHP: composer require filament/filament"
    fi
    
    if [ ! -f ".env" ]; then
        echo "   • Create .env file: cp .env.example .env"
    fi
    
    if ! ls database/migrations/*create_categories_table.php 1> /dev/null 2>&1; then
        echo "   • Create Category migration: php artisan make:migration create_categories_table"
    fi
    
    if [ ! -f "app/Models/Category.php" ]; then
        echo "   • Create Category model with proper traits and relationships"
    fi
fi

if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Optimization Suggestions:${NC}"
    echo "   • Run: php artisan storage:link"
    echo "   • Run: npm run build"
    echo "   • Run: php artisan migrate (if not done)"
    echo "   • Run: php artisan config:cache (for production)"
    echo "   • Set APP_DEBUG=false (for production)"
fi

echo ""
echo "📈 FINAL SCORE"
echo "=============="

TOTAL=$((PASSED + FAILED))
if [ $TOTAL -gt 0 ]; then
    PERCENTAGE=$((PASSED * 100 / TOTAL))
    echo -e "Passed: ${GREEN}$PASSED${NC}"
    echo -e "Failed: ${RED}$FAILED${NC}"
    echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
    echo -e "Success Rate: ${BLUE}$PERCENTAGE%${NC}"
    
    if [ $PERCENTAGE -ge 90 ]; then
        echo -e "${GREEN}🎉 Excellent! Your project is in great shape!${NC}"
    elif [ $PERCENTAGE -ge 70 ]; then
        echo -e "${YELLOW}👍 Good! A few improvements needed.${NC}"
    elif [ $PERCENTAGE -ge 50 ]; then
        echo -e "${YELLOW}⚠️  Moderate. Several issues need attention.${NC}"
    else
        echo -e "${RED}🚨 Critical. Major issues need immediate attention.${NC}"
    fi
else
    echo -e "${RED}No tests could be performed.${NC}"
fi

echo ""
echo "🏁 Health check completed!"
echo "=========================="

# Generate detailed report
echo ""
echo "📋 DETAILED RECOMMENDATIONS"
echo "============================"

echo "1. 🔄 Next Steps for Development:"
echo "   • Create FilamentPHP resources for better admin experience"
echo "   • Implement Apple-style frontend design"
echo "   • Add sample data with seeders"
echo "   • Set up proper error handling"

echo ""
echo "2. 🚀 Production Readiness:"
echo "   • Configure proper database credentials"
echo "   • Set up SSL certificate"
echo "   • Configure backup strategy"
echo "   • Set up monitoring and logging"

echo ""
echo "3. 🎨 Frontend Enhancement:"
echo "   • Implement the Apple-style design system"
echo "   • Add responsive navigation"
echo "   • Create product showcase pages"
echo "   • Optimize images and assets"

echo ""
echo "4. 🔒 Security Hardening:"
echo "   • Enable CSRF protection"
echo "   • Set up rate limiting"
echo "   • Configure HTTPS redirects"
echo "   • Implement proper user roles"

exit 0
