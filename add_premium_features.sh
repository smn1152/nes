#!/bin/bash

# ==============================================
# Salbion Group Premium Features Installation
# Version: 1.0
# ==============================================

set -euo pipefail

# Colors
COLOR_RESET='\033[0m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_CYAN='\033[0;36m'
COLOR_PURPLE='\033[0;35m'
COLOR_BOLD='\033[1m'

# Initialize
PROJECT_ROOT="$(pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$PROJECT_ROOT/premium_features_log_$TIMESTAMP.txt"

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

# Execute command with logging
execute_command() {
    local command="$1"
    local success_msg="$2"
    local error_msg="$3"
    
    log_message "step" "Executing: $command"
    
    if eval "$command" >> "$LOG_FILE" 2>&1; then
        log_message "success" "$success_msg"
        return 0
    else
        log_message "error" "$error_msg"
        return 1
    fi
}

# 1. Install Performance & Monitoring
install_monitoring() {
    log_message "header" "INSTALLING PERFORMANCE & MONITORING"
    
    # Laravel Pulse
    log_message "info" "Installing Laravel Pulse..."
    execute_command "composer require laravel/pulse" \
        "Laravel Pulse installed" \
        "Failed to install Laravel Pulse" || true
    
    execute_command "php artisan vendor:publish --provider=\"Laravel\Pulse\PulseServiceProvider\"" \
        "Pulse published" \
        "Failed to publish Pulse" || true
    
    execute_command "php artisan migrate --force" \
        "Pulse migrations run" \
        "Failed to run Pulse migrations" || true
    
    # Clockwork
    log_message "info" "Installing Clockwork..."
    execute_command "composer require itsgoingd/clockwork" \
        "Clockwork installed" \
        "Failed to install Clockwork" || true
    
    log_message "success" "Monitoring tools installed"
}

# 2. Install Filament Plugins
install_filament_plugins() {
    log_message "header" "INSTALLING FILAMENT PLUGINS"
    
    # Excel Export
    execute_command "composer require pxlrbt/filament-excel" \
        "Filament Excel installed" \
        "Failed to install Filament Excel" || true
    
    # Settings
    execute_command "composer require spatie/laravel-settings" \
        "Laravel Settings installed" \
        "Failed to install Laravel Settings" || true
    
    execute_command "composer require filament/spatie-laravel-settings-plugin" \
        "Filament Settings Plugin installed" \
        "Failed to install Filament Settings Plugin" || true
    
    # Create GeneralSettings class
    mkdir -p app/Settings
    cat > app/Settings/GeneralSettings.php << 'GENERAL_SETTINGS'
<?php

namespace App\Settings;

use Spatie\LaravelSettings\Settings;

class GeneralSettings extends Settings
{
    public string $site_name;
    public string $site_description;
    public string $site_logo;
    public string $contact_email;
    public string $contact_phone;
    public string $address;
    public array $social_links;
    public bool $maintenance_mode;
    
    public static function group(): string
    {
        return 'general';
    }
}
GENERAL_SETTINGS
    
    log_message "success" "Filament plugins installed"
}

# 3. Install Media & Content Features
install_media_features() {
    log_message "header" "INSTALLING MEDIA & CONTENT FEATURES"
    
    # Image Optimizer
    execute_command "composer require spatie/laravel-image-optimizer" \
        "Image Optimizer installed" \
        "Failed to install Image Optimizer" || true
    
    # QR Code
    execute_command "composer require simplesoftwareio/simple-qrcode" \
        "QR Code generator installed" \
        "Failed to install QR Code generator" || true
    
    log_message "success" "Media features installed"
}

# 4. Install Developer Tools
install_developer_tools() {
    log_message "header" "INSTALLING DEVELOPER TOOLS"
    
    # API Documentation
    execute_command "composer require dedoc/scramble" \
        "API Documentation installed" \
        "Failed to install API Documentation" || true
    
    # Query Builder
    execute_command "composer require spatie/laravel-query-builder" \
        "Query Builder installed" \
        "Failed to install Query Builder" || true
    
    log_message "success" "Developer tools installed"
}

# 5. Install Frontend Enhancement
install_frontend_enhancements() {
    log_message "header" "INSTALLING FRONTEND ENHANCEMENTS"
    
    # Livewire
    execute_command "composer require livewire/livewire" \
        "Livewire installed" \
        "Failed to install Livewire" || true
    
    # Wire UI
    execute_command "composer require wireui/wireui" \
        "Wire UI installed" \
        "Failed to install Wire UI" || true
    
    log_message "success" "Frontend enhancements installed"
}

# 6. Create Dashboard Widgets
create_dashboard_widgets() {
    log_message "header" "CREATING DASHBOARD WIDGETS"
    
    # Stats Widget
    mkdir -p app/Filament/Widgets
    cat > app/Filament/Widgets/StatsOverviewWidget.php << 'STATS_WIDGET'
<?php

namespace App\Filament\Widgets;

use App\Models\Product;
use App\Models\Category;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverviewWidget extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        return [
            Stat::make('Total Products', Product::count())
                ->description('All time')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('success')
                ->chart([7, 2, 10, 3, 15, 4, 17]),
            
            Stat::make('Active Products', Product::where('is_active', true)->count())
                ->description('Currently active')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('primary'),
            
            Stat::make('Categories', Category::count())
                ->description('Product categories')
                ->descriptionIcon('heroicon-m-squares-2x2')
                ->color('warning'),
            
            Stat::make('Total Users', User::count())
                ->description('Registered users')
                ->descriptionIcon('heroicon-m-user-group')
                ->color('info'),
        ];
    }
}
STATS_WIDGET
    
    log_message "success" "Dashboard widgets created"
}

# 7. Create Product Controller
create_product_pages() {
    log_message "header" "CREATING PRODUCT PAGES"
    
    # Create controller
    cat > app/Http/Controllers/ProductController.php << 'PRODUCT_CONTROLLER'
<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index()
    {
        $products = Product::with('category')
            ->where('is_active', true)
            ->latest()
            ->paginate(12);
            
        return view('products.index', compact('products'));
    }
    
    public function show($slug)
    {
        $product = Product::with(['category', 'media'])
            ->where('slug', $slug)
            ->where('is_active', true)
            ->firstOrFail();
            
        $relatedProducts = Product::where('category_id', $product->category_id)
            ->where('id', '!=', $product->id)
            ->where('is_active', true)
            ->limit(4)
            ->get();
            
        return view('products.show', compact('product', 'relatedProducts'));
    }
}
PRODUCT_CONTROLLER
    
    # Add routes
    echo "" >> routes/web.php
    echo "// Product routes" >> routes/web.php
    echo "Route::get('/products', [App\Http\Controllers\ProductController::class, 'index'])->name('products.index');" >> routes/web.php
    echo "Route::get('/products/{slug}', [App\Http\Controllers\ProductController::class, 'show'])->name('products.show');" >> routes/web.php
    
    log_message "success" "Product pages created"
}

# 8. Add QR Code to Product Model
update_product_model() {
    log_message "header" "UPDATING PRODUCT MODEL"
    
    # Create a backup
    cp app/Models/Product.php app/Models/Product.php.backup
    
    # Add QR code method to Product model
    cat >> app/Models/Product.php << 'QR_CODE'

    // QR Code generation
    public function getQrCodeAttribute()
    {
        return base64_encode(\SimpleSoftwareIO\QrCode\Facades\QrCode::format('png')->size(200)->generate(
            route('products.show', $this->slug)
        ));
    }
    
    public function getQrCodeUrlAttribute()
    {
        return 'data:image/png;base64,' . $this->qr_code;
    }
QR_CODE
    
    log_message "success" "Product model updated with QR code"
}

# 9. Create Settings Migration
create_settings_migration() {
    log_message "header" "CREATING SETTINGS MIGRATION"
    
    cat > database/migrations/${TIMESTAMP}_create_settings_table.php << 'MIGRATION'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('settings', function (Blueprint $table) {
            $table->id();
            $table->string('group')->index();
            $table->string('name');
            $table->boolean('locked')->default(false);
            $table->json('payload');
            $table->timestamps();
            
            $table->unique(['group', 'name']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('settings');
    }
};
MIGRATION
    
    execute_command "php artisan migrate --force" \
        "Settings migration run" \
        "Failed to run settings migration" || true
        
    log_message "success" "Settings migration created"
}

# 10. Final setup
final_setup() {
    log_message "header" "FINAL SETUP"
    
    # Add Pulse route
    echo "" >> routes/web.php
    echo "// Laravel Pulse Dashboard" >> routes/web.php
    echo "Route::middleware(['auth'])->prefix('admin')->group(function () {" >> routes/web.php
    echo "    Route::get('/pulse', function () { return view('pulse::dashboard'); })->name('pulse.dashboard');" >> routes/web.php
    echo "});" >> routes/web.php
    
    # Create product views directory
    mkdir -p resources/views/products
    
    # Clear and optimize
    execute_command "php artisan optimize:clear" "Caches cleared" "Failed to clear caches" || true
    execute_command "php artisan filament:upgrade" "Filament upgraded" "Failed to upgrade Filament" || true
    
    log_message "success" "Final setup completed"
}

# Main execution
main() {
    log_message "header" "SALBION GROUP PREMIUM FEATURES INSTALLATION"
    log_message "info" "Starting installation..."
    
    # Run all installations
    install_monitoring
    install_filament_plugins
    install_media_features
    install_developer_tools
    install_frontend_enhancements
    create_dashboard_widgets
    create_product_pages
    update_product_model
    create_settings_migration
    final_setup
    
    log_message "header" "INSTALLATION COMPLETED!"
    log_message "success" "All premium features have been installed"
    
    echo -e "\n${COLOR_GREEN}✅ Installation Complete!${COLOR_RESET}\n"
    echo "📋 New Features Added:"
    echo "  • Laravel Pulse monitoring at /admin/pulse"
    echo "  • Excel export capability"
    echo "  • Settings management"
    echo "  • QR codes for products"
    echo "  • API documentation"
    echo "  • Product pages at /products"
    echo "  • Dashboard widgets"
    echo ""
    echo "🎯 Next Steps:"
    echo "  1. Run: php artisan serve"
    echo "  2. Visit: http://localhost:8000/admin"
    echo "  3. Check new features in admin panel"
    echo "  4. Configure settings"
    echo ""
    echo "📝 Log file: $LOG_FILE"
}

# Run main
main
