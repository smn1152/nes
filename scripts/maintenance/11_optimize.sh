cat > add_premium_features.sh << 'EOF'
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
        "Failed to install Laravel Pulse"
    
    execute_command "php artisan vendor:publish --provider=\"Laravel\Pulse\PulseServiceProvider\"" \
        "Pulse published" \
        "Failed to publish Pulse"
    
    execute_command "php artisan migrate" \
        "Pulse migrations run" \
        "Failed to run Pulse migrations"
    
    # Clockwork
    log_message "info" "Installing Clockwork..."
    execute_command "composer require itsgoingd/clockwork" \
        "Clockwork installed" \
        "Failed to install Clockwork"
    
    # Add Pulse route
    cat >> routes/web.php << 'PULSE_ROUTE'

// Laravel Pulse Dashboard
Route::middleware(['auth'])->prefix('admin')->group(function () {
    Route::get('/pulse', function () {
        return view('pulse::dashboard');
    })->name('pulse.dashboard');
});
PULSE_ROUTE
    
    log_message "success" "Monitoring tools installed"
}

# 2. Install Filament Plugins
install_filament_plugins() {
    log_message "header" "INSTALLING FILAMENT PLUGINS"
    
    # Excel Export
    execute_command "composer require pxlrbt/filament-excel" \
        "Filament Excel installed" \
        "Failed to install Filament Excel"
    
    # Settings
    execute_command "composer require spatie/laravel-settings" \
        "Laravel Settings installed" \
        "Failed to install Laravel Settings"
    
    execute_command "composer require filament/spatie-laravel-settings-plugin" \
        "Filament Settings Plugin installed" \
        "Failed to install Filament Settings Plugin"
    
    execute_command "php artisan vendor:publish --tag=\"settings\"" \
        "Settings published" \
        "Failed to publish settings"
    
    # Backup UI
    execute_command "composer require shuvroroy/filament-spatie-laravel-backup" \
        "Filament Backup UI installed" \
        "Failed to install Filament Backup UI"
    
    # Create settings migration
    cat > database/migrations/${TIMESTAMP}_create_settings_table.php << 'SETTINGS_MIGRATION'
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
SETTINGS_MIGRATION
    
    execute_command "php artisan migrate" \
        "Settings migration run" \
        "Failed to run settings migration"
    
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
    
    # Create Settings Page
    mkdir -p app/Filament/Pages
    cat > app/Filament/Pages/ManageSettings.php << 'SETTINGS_PAGE'
<?php

namespace App\Filament\Pages;

use App\Settings\GeneralSettings;
use Filament\Forms;
use Filament\Pages\SettingsPage;

class ManageSettings extends SettingsPage
{
    protected static ?string $navigationIcon = 'heroicon-o-cog';
    protected static ?string $navigationGroup = 'System';
    protected static ?int $navigationSort = 99;
    
    protected static string $settings = GeneralSettings::class;
    
    protected function getFormSchema(): array
    {
        return [
            Forms\Components\Section::make('Site Information')
                ->schema([
                    Forms\Components\TextInput::make('site_name')
                        ->label('Site Name')
                        ->required(),
                    Forms\Components\TextInput::make('site_description')
                        ->label('Site Description'),
                    Forms\Components\FileUpload::make('site_logo')
                        ->label('Site Logo')
                        ->image()
                        ->directory('logos'),
                ]),
            
            Forms\Components\Section::make('Contact Information')
                ->schema([
                    Forms\Components\TextInput::make('contact_email')
                        ->label('Contact Email')
                        ->email()
                        ->required(),
                    Forms\Components\TextInput::make('contact_phone')
                        ->label('Contact Phone')
                        ->tel(),
                    Forms\Components\Textarea::make('address')
                        ->label('Address')
                        ->rows(3),
                ]),
            
            Forms\Components\Section::make('Social Media')
                ->schema([
                    Forms\Components\KeyValue::make('social_links')
                        ->label('Social Media Links')
                        ->keyLabel('Platform')
                        ->valueLabel('URL'),
                ]),
            
            Forms\Components\Section::make('Maintenance')
                ->schema([
                    Forms\Components\Toggle::make('maintenance_mode')
                        ->label('Maintenance Mode')
                        ->helperText('Enable this to show a maintenance page to visitors'),
                ]),
        ];
    }
}
SETTINGS_PAGE
    
    log_message "success" "Filament plugins installed"
}

# 3. Update Filament Resources with Excel Export
update_filament_resources() {
    log_message "header" "UPDATING FILAMENT RESOURCES"
    
    # Update ProductResource
    if [[ -f "app/Filament/Resources/ProductResource.php" ]]; then
        # Add Excel export to ProductResource
        sed -i.bak '/use Filament\\Tables\\Table;/a\
use pxlrbt\\FilamentExcel\\Actions\\Tables\\ExportBulkAction;\
use pxlrbt\\FilamentExcel\\Columns\\Column;\
use pxlrbt\\FilamentExcel\\Exports\\ExcelExport;' app/Filament/Resources/ProductResource.php
        
        # Add export to bulk actions
        sed -i.bak '/->bulkActions(\[/,/\]);/c\
            ->bulkActions([\
                Tables\\Actions\\BulkActionGroup::make([\
                    Tables\\Actions\\DeleteBulkAction::make(),\
                ]),\
                ExportBulkAction::make()\
                    ->exports([\
                        ExcelExport::make()\
                            ->fromTable()\
                            ->withFilename(fn ($resource) => $resource::getModelLabel() . '-' . date('Y-m-d'))\
                            ->withWriterType(\\Maatwebsite\\Excel\\Excel::XLSX)\
                            ->withColumns([\
                                Column::make('name'),\
                                Column::make('sku'),\
                                Column::make('price'),\
                                Column::make('category.name'),\
                                Column::make('created_at'),\
                            ]),\
                    ]),\
            ]);' app/Filament/Resources/ProductResource.php
        
        log_message "success" "Updated ProductResource with Excel export"
    fi
}

# 4. Install Security Features
install_security() {
    log_message "header" "INSTALLING SECURITY FEATURES"
    
    # Laravel Fortify
    execute_command "composer require laravel/fortify" \
        "Laravel Fortify installed" \
        "Failed to install Laravel Fortify"
    
    execute_command "php artisan vendor:publish --provider=\"Laravel\Fortify\FortifyServiceProvider\"" \
        "Fortify published" \
        "Failed to publish Fortify"
    
    # Create FortifyServiceProvider
    cat > app/Providers/FortifyServiceProvider.php << 'FORTIFY_PROVIDER'
<?php

namespace App\Providers;

use App\Actions\Fortify\CreateNewUser;
use App\Actions\Fortify\ResetUserPassword;
use App\Actions\Fortify\UpdateUserPassword;
use App\Actions\Fortify\UpdateUserProfileInformation;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;
use Laravel\Fortify\Fortify;

class FortifyServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        Fortify::createUsersUsing(CreateNewUser::class);
        Fortify::updateUserProfileInformationUsing(UpdateUserProfileInformation::class);
        Fortify::updateUserPasswordsUsing(UpdateUserPassword::class);
        Fortify::resetUserPasswordsUsing(ResetUserPassword::class);

        RateLimiter::for('login', function (Request $request) {
            $email = (string) $request->email;
            return Limit::perMinute(5)->by($email.$request->ip());
        });

        RateLimiter::for('two-factor', function (Request $request) {
            return Limit::perMinute(5)->by($request->session()->get('login.id'));
        });
    }
}
FORTIFY_PROVIDER
    
    # Add to config/app.php providers
    log_message "info" "Remember to add FortifyServiceProvider to config/app.php"
    
    log_message "success" "Security features installed"
}

# 5. Install Media & Content Features
install_media_features() {
    log_message "header" "INSTALLING MEDIA & CONTENT FEATURES"
    
    # Image Optimizer
    execute_command "composer require spatie/laravel-image-optimizer" \
        "Image Optimizer installed" \
        "Failed to install Image Optimizer"
    
    execute_command "php artisan vendor:publish --provider=\"Spatie\LaravelImageOptimizer\ImageOptimizerServiceProvider\"" \
        "Image Optimizer config published" \
        "Failed to publish Image Optimizer config"
    
    # QR Code
    execute_command "composer require simplesoftwareio/simple-qrcode" \
        "QR Code generator installed" \
        "Failed to install QR Code generator"
    
    # Add QR Code to Product model
    if [[ -f "app/Models/Product.php" ]]; then
        # Add QR code generation method
        sed -i.bak '/class Product extends Model/,/^{/s/^{/{\
    use \\SimpleSoftwareIO\\QrCode\\Facades\\QrCode;\
/' app/Models/Product.php
        
        # Add QR code method before last closing brace
        sed -i.bak '/^}$/i\
\
    public function getQrCodeAttribute()\
    {\
        return base64_encode(QrCode::format("png")->size(200)->generate(\
            route("products.show", $this->slug)\
        ));\
    }\
\
    public function getQrCodeUrlAttribute()\
    {\
        return "data:image/png;base64," . $this->qr_code;\
    }' app/Models/Product.php
        
        log_message "success" "Added QR code generation to Product model"
    fi
}

# 6. Install Developer Tools
install_developer_tools() {
    log_message "header" "INSTALLING DEVELOPER TOOLS"
    
    # API Documentation
    execute_command "composer require dedoc/scramble" \
        "API Documentation installed" \
        "Failed to install API Documentation"
    
    # Query Builder
    execute_command "composer require spatie/laravel-query-builder" \
        "Query Builder installed" \
        "Failed to install Query Builder"
    
    # Add API documentation config
    cat > config/scramble.php << 'SCRAMBLE_CONFIG'
<?php

return [
    'api_path' => 'api',
    'api_docs_path' => 'docs/api',
    'export_path' => 'storage/api-docs',
    'info' => [
        'title' => 'Salbion Group API',
        'description' => 'API documentation for Salbion Group application',
        'version' => '1.0.0',
    ],
];
SCRAMBLE_CONFIG
}

# 7. Install Frontend Enhancement
install_frontend_enhancements() {
    log_message "header" "INSTALLING FRONTEND ENHANCEMENTS"
    
    # Livewire
    execute_command "composer require livewire/livewire" \
        "Livewire installed" \
        "Failed to install Livewire"
    
    # Wire UI
    execute_command "composer require wireui/wireui" \
        "Wire UI installed" \
        "Failed to install Wire UI"
    
    # Charts
    execute_command "composer require arielmejiadev/larapex-charts" \
        "Apex Charts installed" \
        "Failed to install Apex Charts"
    
    execute_command "php artisan vendor:publish --tag=larapex-charts-config" \
        "Charts config published" \
        "Failed to publish charts config"
    
    # Create a sample chart
    mkdir -p app/Charts
    cat > app/Charts/ProductSalesChart.php << 'SALES_CHART'
<?php

namespace App\Charts;

use ArielMejiaDev\LarapexCharts\LarapexChart;

class ProductSalesChart
{
    protected $chart;

    public function __construct(LarapexChart $chart)
    {
        $this->chart = $chart;
    }

    public function build(): \ArielMejiaDev\LarapexCharts\LineChart
    {
        return $this->chart->lineChart()
            ->setTitle('Product Sales')
            ->setSubtitle('Sales performance over time')
            ->addData('Sales', [40, 93, 35, 42, 18, 82, 65, 73])
            ->addData('Revenue', [70, 29, 77, 28, 55, 45, 82, 90])
            ->setXAxis(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'])
            ->setHeight(300);
    }
}
SALES_CHART
}

# 8. Create Dashboard Widgets
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
    
    # Chart Widget
    cat > app/Filament/Widgets/ProductChartWidget.php << 'CHART_WIDGET'
<?php

namespace App\Filament\Widgets;

use Filament\Widgets\ChartWidget;
use App\Models\Product;
use Illuminate\Support\Carbon;

class ProductChartWidget extends ChartWidget
{
    protected static ?string $heading = 'Products Created';
    protected static ?int $sort = 2;

    protected function getData(): array
    {
        $products = Product::selectRaw('DATE(created_at) as date, COUNT(*) as count')
            ->where('created_at', '>=', Carbon::now()->subDays(30))
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        return [
            'datasets' => [
                [
                    'label' => 'Products created',
                    'data' => $products->pluck('count')->toArray(),
                    'backgroundColor' => '#36A2EB',
                    'borderColor' => '#9BD0F5',
                ],
            ],
            'labels' => $products->pluck('date')->map(fn ($date) => Carbon::parse($date)->format('M d'))->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
CHART_WIDGET
}

# 9. Create Product Detail Page with QR Code
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
    
    # Create views
    mkdir -p resources/views/products
    
    # Product listing view
    cat > resources/views/products/index.blade.php << 'PRODUCT_INDEX'
@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-8">Our Products</h1>
    
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        @foreach($products as $product)
            <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow">
                @if($product->getFirstMediaUrl('hero_image'))
                    <img src="{{ $product->getFirstMediaUrl('hero_image', 'card') }}" 
                         alt="{{ $product->name }}" 
                         class="w-full h-48 object-cover">
                @else
                    <div class="w-full h-48 bg-gray-200 flex items-center justify-center">
                        <span class="text-gray-400">No image</span>
                    </div>
                @endif
                
                <div class="p-4">
                    <h2 class="text-xl font-semibold mb-2">{{ $product->name }}</h2>
                    <p class="text-gray-600 mb-4">{{ Str::limit($product->description, 100) }}</p>
                    <div class="flex justify-between items-center">
                        <span class="text-2xl font-bold text-blue-600">{{ $product->formatted_price }}</span>
                        <a href="{{ route('products.show', $product->slug) }}" 
                           class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 transition-colors">
                            View Details
                        </a>
                    </div>
                </div>
            </div>
        @endforeach
    </div>
    
    <div class="mt-8">
        {{ $products->links() }}
    </div>
</div>
@endsection
PRODUCT_INDEX'
    
    # Product detail view
    cat > resources/views/products/show.blade.php << 'PRODUCT_SHOW'
@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8">
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Product Images -->
        <div>
            @if($product->getFirstMediaUrl('hero_image'))
                <img src="{{ $product->getFirstMediaUrl('hero_image') }}" 
                     alt="{{ $product->name }}" 
                     class="w-full rounded-lg shadow-lg">
            @endif
            
            <!-- Gallery -->
            @if($product->getMedia('gallery')->count() > 0)
                <div class="mt-4 grid grid-cols-4 gap-2">
                    @foreach($product->getMedia('gallery') as $image)
                        <img src="{{ $image->getUrl('thumb') }}" 
                             alt="{{ $product->name }}" 
                             class="w-full rounded cursor-pointer hover:opacity-75">
                    @endforeach
                </div>
            @endif
        </div>
        
        <!-- Product Info -->
        <div>
            <h1 class="text-3xl font-bold mb-4">{{ $product->name }}</h1>
            <p class="text-gray-600 mb-6">{{ $product->tagline }}</p>
            
            <div class="mb-6">
                <span class="text-4xl font-bold text-blue-600">{{ $product->formatted_price }}</span>
            </div>
            
            <div class="prose max-w-none mb-6">
                {!! $product->description !!}
            </div>
            
            <!-- Features -->
            @if($product->features)
                <div class="mb-6">
                    <h3 class="text-xl font-semibold mb-3">Features</h3>
                    <ul class="list-disc list-inside space-y-2">
                        @foreach($product->features as $feature)
                            <li>{{ $feature['feature'] ?? $feature }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif
            
            <!-- QR Code -->
            <div class="mt-8 p-4 bg-gray-100 rounded-lg">
                <h3 class="text-lg font-semibold mb-3">Share Product</h3>
                <img src="{{ $product->qr_code_url }}" alt="QR Code" class="w-32 h-32">
                <p class="text-sm text-gray-600 mt-2">Scan to share this product</p>
            </div>
        </div>
    </div>
    
    <!-- Related Products -->
    @if($relatedProducts->count() > 0)
        <div class="mt-12">
            <h2 class="text-2xl font-bold mb-6">Related Products</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                @foreach($relatedProducts as $related)
                    <div class="bg-white rounded-lg shadow-md overflow-hidden">
                        @if($related->getFirstMediaUrl('hero_image'))
                            <img src="{{ $related->getFirstMediaUrl('hero_image', 'card') }}" 
                                 alt="{{ $related->name }}" 
                                 class="w-full h-48 object-cover">
                        @endif
                        <div class="p-4">
                            <h3 class="font-semibold">{{ $related->name }}</h3>
                            <p class="text-blue-600 font-bold">{{ $related->formatted_price }}</p>
                            <a href="{{ route('products.show', $related->slug) }}" 
                               class="text-blue-500 hover:underline">View</a>
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
    @endif
</div>
@endsection
PRODUCT_SHOW'
    
    # Add routes
    cat >> routes/web.php << 'PRODUCT_ROUTES'

// Product routes
Route::get('/products', [App\Http\Controllers\ProductController::class, 'index'])->name('products.index');
Route::get('/products/{slug}', [App\Http\Controllers\ProductController::class, 'show'])->name('products.show');
PRODUCT_ROUTES
}

# 10. Configure services
configure_services() {
    log_message "header" "CONFIGURING SERVICES"
    
    # Update config/app.php providers if needed
    log_message "info" "Add these providers to config/app.php if not auto-discovered:"
    log_message "info" "- App\Providers\FortifyServiceProvider::class"
    log_message "info" "- Dedoc\Scramble\ScrambleServiceProvider::class"
    
    # Update layout to include Livewire
    if [[ -f "resources/views/layouts/app.blade.php" ]]; then
        # Add Livewire styles before </head>
        sed -i.bak '/<\/head>/i\
    @livewireStyles\
    @wireUiScripts' resources/views/layouts/app.blade.php
        
        # Add Livewire scripts before </body>
        sed -i.bak '/<\/body>/i\
    @livewireScripts' resources/views/layouts/app.blade.php
    fi
    
    # Register settings
    cat > config/settings.php << 'SETTINGS_CONFIG'
<?php

return [
    'settings' => [
        App\Settings\GeneralSettings::class,
    ],
];
SETTINGS_CONFIG
}

# Main execution
main() {
    log_message "header" "SALBION GROUP PREMIUM FEATURES INSTALLATION"
    log_message "info" "Starting installation..."
    
    # Run all installations
    install_monitoring
    install_filament_plugins
    update_filament_resources
    install_security
    install_media_features
    install_developer_tools
    install_frontend_enhancements
    create_dashboard_widgets
    create_product_pages
    configure_services
    
    # Final optimizations
    log_message "header" "RUNNING FINAL OPTIMIZATIONS"
    execute_command "php artisan optimize:clear" "Caches cleared" "Failed to clear caches"
    execute_command "php artisan filament:upgrade" "Filament upgraded" "Failed to upgrade Filament"
    execute_command "npm run build" "Assets built" "Failed to build assets"
    
    log_message "header" "INSTALLATION COMPLETED!"
    log_message "success" "All premium features have been installed"
    
    echo -e "\n${COLOR_GREEN}✅ Installation Complete!${COLOR_RESET}\n"
    echo "📋 New Features Added:"
    echo "  • Laravel Pulse monitoring at /admin/pulse"
    echo "  • Excel export in Filament resources"
    echo "  • Settings management page in admin"
    echo "  • QR codes for products"
    echo "  • API documentation at /docs/api"
    echo "  • Product pages at /products"
    echo "  • Dashboard widgets"
    echo "  • Security features with Fortify"
    echo ""
    echo "🎯 Next Steps:"
    echo "  1. Add FortifyServiceProvider to config/app.php"
    echo "  2. Configure image optimization tools on your server"
    echo "  3. Set up your settings in /admin/manage-settings"
    echo "  4. Check Laravel Pulse dashboard"
    echo "  5. Test Excel export in Products"
    echo ""
    echo "📝 Log file: $LOG_FILE"
}

# Run main
main
EOF

# Make executable
chmod +x add_premium_features.sh

echo "✅ Premium features installation script created!"
echo ""
echo "Run the script with:"
echo "  ./add_premium_features.sh"
echo ""
echo "This will add:"
echo "  • Performance monitoring (Pulse, Clockwork)"
echo "  • Excel export/import"
echo "  • Settings management"
echo "  • QR code generation"
echo "  • API documentation"
echo "  • Security features"
echo "  • Charts and widgets"
echo "  • Product showcase pages"
