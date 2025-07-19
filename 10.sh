#!/bin/bash

# ========================================
# UK Company Website Complete Setup Script
# Version: 1.0
# ========================================

set -e  # Exit on error

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Header
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}UK Company Website Setup${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if we're in a Laravel project
if [ ! -f "artisan" ]; then
    print_error "This doesn't appear to be a Laravel project root directory"
    exit 1
fi

# ========================================
# STEP 1: Remove Conflicting Packages
# ========================================
print_status "Removing conflicting packages..."
if composer show bumbummen99/shoppingcart 2>/dev/null; then
    composer remove bumbummen99/shoppingcart --no-update
    print_success "Removed conflicting shopping cart package"
fi

# ========================================
# STEP 2: Install Working Packages
# ========================================
print_status "Installing core UK packages..."

# Core packages that work
composer require \
    spatie/laravel-cookie-consent \
    soved/laravel-gdpr \
    spatie/laravel-honeypot \
    mpociot/vat-calculator \
    akaunting/laravel-money \
    propaganistas/laravel-phone \
    romanzipp/laravel-seo \
    spatie/laravel-newsletter \
    spatie/laravel-sitemap \
    barryvdh/laravel-dompdf \
    darryldecode/cart \
    --no-scripts

print_status "Installing additional utility packages..."

# Additional packages
composer require \
    spatie/laravel-backup \
    spatie/laravel-activitylog \
    spatie/laravel-image-optimizer \
    spatie/laravel-query-builder \
    spatie/laravel-data \
    intervention/image \
    simplesoftwareio/simple-qrcode \
    --no-scripts

# Run post-install scripts
composer dump-autoload

print_success "All packages installed successfully!"

# ========================================
# STEP 3: Create Directory Structure
# ========================================
print_status "Creating directory structure..."

mkdir -p app/Services
mkdir -p app/Helpers
mkdir -p app/Http/Controllers/UK
mkdir -p resources/views/letters
mkdir -p resources/views/shipping
mkdir -p resources/views/uk
mkdir -p database/migrations
mkdir -p config

print_success "Directory structure created"

# ========================================
# STEP 4: Create Service Classes
# ========================================
print_status "Creating UK service classes..."

# Postcode Service
cat > app/Services/PostcodeService.php << 'EOF'
<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;

class PostcodeService
{
    protected $baseUrl = 'https://api.postcodes.io';
    
    /**
     * Lookup postcode details
     */
    public function lookup($postcode)
    {
        $postcode = $this->formatPostcode($postcode);
        
        return Cache::remember("postcode_{$postcode}", 3600, function () use ($postcode) {
            $response = Http::get("{$this->baseUrl}/postcodes/{$postcode}");
            
            if ($response->successful()) {
                return $response->json()['result'];
            }
            
            return null;
        });
    }
    
    /**
     * Validate postcode
     */
    public function validate($postcode)
    {
        $response = Http::post("{$this->baseUrl}/postcodes", [
            'postcodes' => [$postcode]
        ]);
        
        return $response->successful() && 
               isset($response->json()['result'][0]['result']);
    }
    
    /**
     * Find nearest postcodes
     */
    public function findNearest($postcode, $limit = 5)
    {
        $postcode = $this->formatPostcode($postcode);
        
        $response = Http::get("{$this->baseUrl}/postcodes/{$postcode}/nearest", [
            'limit' => $limit
        ]);
        
        if ($response->successful()) {
            return $response->json()['result'] ?? [];
        }
        
        return [];
    }
    
    /**
     * Autocomplete postcodes
     */
    public function autocomplete($partial)
    {
        $response = Http::get("{$this->baseUrl}/postcodes/{$partial}/autocomplete");
        
        if ($response->successful()) {
            return $response->json()['result'] ?? [];
        }
        
        return [];
    }
    
    /**
     * Format postcode for API
     */
    protected function formatPostcode($postcode)
    {
        return str_replace(' ', '', strtoupper($postcode));
    }
}
EOF

# UK Bank Holiday Service
cat > app/Services/UKBankHolidayService.php << 'EOF'
<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;
use Carbon\Carbon;

class UKBankHolidayService
{
    protected $apiUrl = 'https://www.gov.uk/bank-holidays.json';
    
    /**
     * Get bank holidays for a specific division
     */
    public function getBankHolidays($division = 'england-and-wales')
    {
        return Cache::remember("uk_bank_holidays_{$division}", 86400, function () use ($division) {
            $response = Http::get($this->apiUrl);
            
            if ($response->successful()) {
                $data = $response->json();
                return $data[$division]['events'] ?? [];
            }
            
            return [];
        });
    }
    
    /**
     * Check if a date is a bank holiday
     */
    public function isBankHoliday($date, $division = 'england-and-wales')
    {
        if (!$date instanceof Carbon) {
            $date = Carbon::parse($date);
        }
        
        $holidays = $this->getBankHolidays($division);
        $dateString = $date->format('Y-m-d');
        
        return collect($holidays)->pluck('date')->contains($dateString);
    }
    
    /**
     * Get next bank holiday
     */
    public function getNextBankHoliday($division = 'england-and-wales')
    {
        $holidays = $this->getBankHolidays($division);
        $today = Carbon::today();
        
        foreach ($holidays as $holiday) {
            $holidayDate = Carbon::parse($holiday['date']);
            if ($holidayDate->isAfter($today)) {
                return $holiday;
            }
        }
        
        return null;
    }
    
    /**
     * Calculate working days between dates
     */
    public function getWorkingDays($startDate, $endDate, $division = 'england-and-wales')
    {
        $start = Carbon::parse($startDate);
        $end = Carbon::parse($endDate);
        $holidays = collect($this->getBankHolidays($division))->pluck('date');
        
        $workingDays = 0;
        
        while ($start->lte($end)) {
            if (!$start->isWeekend() && !$holidays->contains($start->format('Y-m-d'))) {
                $workingDays++;
            }
            $start->addDay();
        }
        
        return $workingDays;
    }
}
EOF

# Royal Mail Service
cat > app/Services/RoyalMailService.php << 'EOF'
<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class RoyalMailService
{
    protected $clientId;
    protected $clientSecret;
    protected $baseUrl = 'https://api.royalmail.net';
    
    public function __construct()
    {
        $this->clientId = config('services.royal_mail.client_id');
        $this->clientSecret = config('services.royal_mail.client_secret');
    }
    
    /**
     * Track a package
     */
    public function trackPackage($trackingNumber)
    {
        if (!$this->validateTrackingNumber($trackingNumber)) {
            return ['error' => 'Invalid tracking number format'];
        }
        
        try {
            $response = Http::withHeaders([
                'X-IBM-Client-Id' => $this->clientId,
                'X-IBM-Client-Secret' => $this->clientSecret,
            ])->get("{$this->baseUrl}/mailpieces/v2/{$trackingNumber}/events");
            
            if ($response->successful()) {
                return $response->json();
            }
            
            return ['error' => 'Failed to track package'];
        } catch (\Exception $e) {
            Log::error('Royal Mail tracking error: ' . $e->getMessage());
            return ['error' => 'Service unavailable'];
        }
    }
    
    /**
     * Calculate postage
     */
    public function calculatePostage($weight, $service = 'first-class')
    {
        $services = [
            'first-class' => '1',
            'second-class' => '2',
            'signed-for' => 'T',
            'special-delivery-9am' => 'SD1',
            'special-delivery-1pm' => 'SD2',
        ];
        
        // This is a simplified calculation
        // In reality, you'd call the Royal Mail API
        $basePrices = [
            'first-class' => ['letter' => 0.85, 'large-letter' => 1.29, 'parcel' => 3.85],
            'second-class' => ['letter' => 0.65, 'large-letter' => 0.96, 'parcel' => 3.35],
            'signed-for' => ['letter' => 2.25, 'large-letter' => 2.69, 'parcel' => 5.25],
            'special-delivery-9am' => ['letter' => 7.25, 'large-letter' => 8.20, 'parcel' => 12.50],
            'special-delivery-1pm' => ['letter' => 6.85, 'large-letter' => 7.65, 'parcel' => 11.00],
        ];
        
        $type = $this->getPackageType($weight);
        
        return [
            'service' => $service,
            'type' => $type,
            'price' => $basePrices[$service][$type] ?? 0,
            'weight' => $weight,
        ];
    }
    
    /**
     * Validate tracking number format
     */
    protected function validateTrackingNumber($trackingNumber)
    {
        return preg_match('/^[A-Z]{2}[0-9]{9}GB$/', $trackingNumber);
    }
    
    /**
     * Determine package type by weight
     */
    protected function getPackageType($weight)
    {
        if ($weight <= 100) return 'letter';
        if ($weight <= 750) return 'large-letter';
        return 'parcel';
    }
}
EOF

# Letter Generator Service
cat > app/Services/LetterGeneratorService.php << 'EOF'
<?php

namespace App\Services;

use Barryvdh\DomPDF\Facade\Pdf;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

class LetterGeneratorService
{
    /**
     * Generate formal UK business letter
     */
    public function generateLetter($data)
    {
        $pdf = PDF::loadView('letters.template', $data);
        $pdf->setPaper('A4', 'portrait');
        
        return $pdf;
    }
    
    /**
     * Generate envelope with window position
     */
    public function generateEnvelope($address, $type = 'DL')
    {
        $envelopeSizes = [
            'DL' => ['width' => 220, 'height' => 110],
            'C5' => ['width' => 229, 'height' => 162],
            'C4' => ['width' => 324, 'height' => 229],
        ];
        
        $size = $envelopeSizes[$type] ?? $envelopeSizes['DL'];
        
        $pdf = PDF::loadView('letters.envelope', [
            'address' => $address,
            'windowPosition' => $this->getWindowPosition($type),
            'size' => $size
        ]);
        
        $pdf->setPaper([$size['width'], $size['height']], 'landscape');
        
        return $pdf;
    }
    
    /**
     * Generate shipping label
     */
    public function generateShippingLabel($shipment)
    {
        // Generate QR code for tracking
        $qrCode = QrCode::format('png')
            ->size(150)
            ->generate($shipment['tracking_number']);
        
        $pdf = PDF::loadView('shipping.label', [
            'from' => $shipment['from_address'],
            'to' => $shipment['to_address'],
            'tracking' => $shipment['tracking_number'],
            'service' => $shipment['service_type'],
            'qrcode' => base64_encode($qrCode),
            'date' => now()->format('d/m/Y')
        ]);
        
        // Royal Mail label size: 6" x 4"
        $pdf->setPaper([432, 288], 'landscape');
        
        return $pdf;
    }
    
    /**
     * Get window position for windowed envelopes
     */
    protected function getWindowPosition($envelopeType)
    {
        $positions = [
            'DL' => ['left' => 20, 'bottom' => 15, 'width' => 90, 'height' => 35],
            'C5' => ['left' => 20, 'bottom' => 20, 'width' => 90, 'height' => 35],
            'C4' => ['left' => 30, 'bottom' => 30, 'width' => 100, 'height' => 40],
        ];
        
        return $positions[$envelopeType] ?? $positions['DL'];
    }
}
EOF

print_success "Service classes created"

# ========================================
# STEP 5: Create Models
# ========================================
print_status "Creating UK Address model..."

cat > app/Models/UKAddress.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class UKAddress extends Model
{
    use HasFactory;
    
    protected $table = 'uk_addresses';
    
    protected $fillable = [
        'organisation',
        'building_name',
        'building_number',
        'sub_building',
        'address_line_1',
        'address_line_2',
        'address_line_3',
        'town',
        'county',
        'postcode',
        'country',
        'latitude',
        'longitude',
        'uprn',
        'type'
    ];
    
    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
    ];
    
    /**
     * Format for Royal Mail
     */
    public function formatForRoyalMail()
    {
        $lines = array_filter([
            $this->organisation,
            $this->sub_building,
            trim($this->building_number . ' ' . $this->building_name),
            $this->address_line_1,
            $this->address_line_2,
            $this->address_line_3,
            strtoupper($this->town),
            $this->county,
            strtoupper($this->postcode)
        ]);
        
        return implode("\n", $lines);
    }
    
    /**
     * Format postcode correctly
     */
    public function setPostcodeAttribute($value)
    {
        $postcode = strtoupper(str_replace(' ', '', $value));
        
        if (strlen($postcode) === 6) {
            $postcode = substr($postcode, 0, 3) . ' ' . substr($postcode, 3);
        } elseif (strlen($postcode) === 7) {
            $postcode = substr($postcode, 0, 4) . ' ' . substr($postcode, 4);
        }
        
        $this->attributes['postcode'] = $postcode;
    }
    
    /**
     * Validate UK postcode format
     */
    public function isValidPostcode()
    {
        $pattern = '/^[A-Z]{1,2}[0-9]{1,2}[A-Z]?\s?[0-9][A-Z]{2}$/i';
        return preg_match($pattern, $this->postcode);
    }
    
    /**
     * Get formatted address lines
     */
    public function getFormattedAddressAttribute()
    {
        return collect([
            $this->address_line_1,
            $this->address_line_2,
            $this->town,
            $this->county,
            $this->postcode,
        ])->filter()->implode(', ');
    }
}
EOF

print_success "Models created"

# ========================================
# STEP 6: Create Helpers
# ========================================
print_status "Creating UK helper classes..."

cat > app/Helpers/UKFormat.php << 'EOF'
<?php

namespace App\Helpers;

use Carbon\Carbon;

class UKFormat
{
    /**
     * Format UK phone number
     */
    public static function phone($number)
    {
        $number = preg_replace('/[^0-9]/', '', $number);
        
        if (strlen($number) === 10 && substr($number, 0, 2) === '07') {
            // Mobile: 07XXX XXXXXX
            return substr($number, 0, 5) . ' ' . substr($number, 5);
        } elseif (strlen($number) === 11 && substr($number, 0, 1) === '0') {
            // Remove leading 0 for landlines
            $number = substr($number, 1);
        }
        
        if (strlen($number) === 10) {
            // Landline: 020 XXXX XXXX
            return '0' . substr($number, 0, 2) . ' ' . 
                   substr($number, 2, 4) . ' ' . 
                   substr($number, 6);
        }
        
        return $number;
    }
    
    /**
     * Format UK date
     */
    public static function date($date, $format = 'd/m/Y')
    {
        if (!$date instanceof Carbon) {
            $date = Carbon::parse($date);
        }
        
        return $date->format($format);
    }
    
    /**
     * Format UK currency
     */
    public static function currency($amount, $symbol = '£')
    {
        return $symbol . number_format($amount, 2);
    }
    
    /**
     * Format UK address
     */
    public static function address($address)
    {
        if (is_array($address)) {
            $address = (object) $address;
        }
        
        return implode("\n", array_filter([
            $address->line_1 ?? '',
            $address->line_2 ?? '',
            $address->town ?? '',
            $address->county ?? '',
            strtoupper($address->postcode ?? ''),
            'United Kingdom'
        ]));
    }
    
    /**
     * Format VAT number
     */
    public static function vatNumber($number)
    {
        $number = preg_replace('/[^0-9]/', '', $number);
        
        if (strlen($number) === 9) {
            return 'GB ' . substr($number, 0, 3) . ' ' . 
                   substr($number, 3, 4) . ' ' . 
                   substr($number, 7, 2);
        }
        
        return $number;
    }
}
EOF

print_success "Helper classes created"

# ========================================
# STEP 7: Create Controllers
# ========================================
print_status "Creating UK controllers..."

cat > app/Http/Controllers/UK/PostcodeController.php << 'EOF'
<?php

namespace App\Http\Controllers\UK;

use App\Http\Controllers\Controller;
use App\Services\PostcodeService;
use Illuminate\Http\Request;

class PostcodeController extends Controller
{
    protected $postcodeService;
    
    public function __construct(PostcodeService $postcodeService)
    {
        $this->postcodeService = $postcodeService;
    }
    
    /**
     * Lookup postcode
     */
    public function lookup(Request $request)
    {
        $request->validate([
            'postcode' => 'required|string|max:8'
        ]);
        
        $result = $this->postcodeService->lookup($request->postcode);
        
        if ($result) {
            return response()->json([
                'success' => true,
                'data' => $result
            ]);
        }
        
        return response()->json([
            'success' => false,
            'message' => 'Postcode not found'
        ], 404);
    }
    
    /**
     * Validate postcode
     */
    public function validate(Request $request)
    {
        $request->validate([
            'postcode' => 'required|string|max:8'
        ]);
        
        $isValid = $this->postcodeService->validate($request->postcode);
        
        return response()->json([
            'success' => true,
            'valid' => $isValid
        ]);
    }
    
    /**
     * Autocomplete postcode
     */
    public function autocomplete(Request $request)
    {
        $request->validate([
            'query' => 'required|string|min:2|max:6'
        ]);
        
        $results = $this->postcodeService->autocomplete($request->query);
        
        return response()->json([
            'success' => true,
            'data' => $results
        ]);
    }
}
EOF

cat > app/Http/Controllers/UK/LetterController.php << 'EOF'
<?php

namespace App\Http\Controllers\UK;

use App\Http\Controllers\Controller;
use App\Services\LetterGeneratorService;
use Illuminate\Http\Request;

class LetterController extends Controller
{
    protected $letterService;
    
    public function __construct(LetterGeneratorService $letterService)
    {
        $this->letterService = $letterService;
    }
    
    /**
     * Generate letter PDF
     */
    public function generateLetter(Request $request)
    {
        $request->validate([
            'sender' => 'required|array',
            'recipient' => 'required|array',
            'content' => 'required|string',
            'reference' => 'nullable|string'
        ]);
        
        $pdf = $this->letterService->generateLetter($request->all());
        
        return $pdf->download('letter-' . date('Y-m-d') . '.pdf');
    }
    
    /**
     * Generate envelope
     */
    public function generateEnvelope(Request $request)
    {
        $request->validate([
            'address' => 'required|array',
            'type' => 'nullable|in:DL,C5,C4'
        ]);
        
        $pdf = $this->letterService->generateEnvelope(
            $request->address,
            $request->type ?? 'DL'
        );
        
        return $pdf->download('envelope-' . date('Y-m-d') . '.pdf');
    }
    
    /**
     * Generate shipping label
     */
    public function generateShippingLabel(Request $request)
    {
        $request->validate([
            'from_address' => 'required|array',
            'to_address' => 'required|array',
            'tracking_number' => 'required|string',
            'service_type' => 'required|string'
        ]);
        
        $pdf = $this->letterService->generateShippingLabel($request->all());
        
        return $pdf->download('label-' . $request->tracking_number . '.pdf');
    }
}
EOF

print_success "Controllers created"

# ========================================
# STEP 8: Create Config Files
# ========================================
print_status "Creating configuration files..."

cat > config/uk-services.php << 'EOF'
<?php

return [
    /*
    |--------------------------------------------------------------------------
    | UK Services Configuration
    |--------------------------------------------------------------------------
    */
    
    'postcodes_io' => [
        'base_url' => 'https://api.postcodes.io',
        'cache_duration' => 3600, // 1 hour
    ],
    
    'bank_holidays' => [
        'api_url' => 'https://www.gov.uk/bank-holidays.json',
        'cache_duration' => 86400, // 24 hours
        'default_division' => 'england-and-wales',
    ],
    
    'royal_mail' => [
        'client_id' => env('ROYAL_MAIL_CLIENT_ID'),
        'client_secret' => env('ROYAL_MAIL_CLIENT_SECRET'),
        'account_number' => env('ROYAL_MAIL_ACCOUNT'),
    ],
    
    'vat' => [
        'rate' => 20, // UK standard VAT rate %
        'number' => env('VAT_NUMBER'),
        'validate_eu' => true,
    ],
    
    'currency' => [
        'default' => 'GBP',
        'symbol' => '£',
        'decimal_places' => 2,
    ],
    
    'date_format' => 'd/m/Y',
    'time_format' => 'H:i',
    'timezone' => 'Europe/London',
    
    'address_format' => [
        'require_county' => false,
        'postcode_regex' => '/^[A-Z]{1,2}[0-9]{1,2}[A-Z]?\s?[0-9][A-Z]{2}$/i',
    ],
    
    'phone_format' => [
        'country_code' => '+44',
        'mobile_prefix' => '07',
        'landline_prefixes' => ['01', '02', '03'],
    ],
];
EOF

print_success "Configuration files created"

# ========================================
# STEP 9: Create Views
# ========================================
print_status "Creating view templates..."

# Letter template
cat > resources/views/letters/template.blade.php << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        @page { margin: 2.54cm; }
        body { 
            font-family: Arial, sans-serif; 
            font-size: 12pt;
            line-height: 1.5;
            color: #333;
        }
        .sender-address { 
            text-align: right; 
            margin-bottom: 20px;
            font-size: 10pt;
        }
        .recipient-address { 
            margin: 40px 0;
            font-size: 11pt;
        }
        .date { 
            margin: 20px 0;
        }
        .reference {
            font-weight: bold;
            margin: 10px 0;
        }
        .content {
            text-align: justify;
            margin: 20px 0;
        }
        .closing {
            margin-top: 40px;
        }
        .signature-space {
            height: 60px;
        }
    </style>
</head>
<body>
    <div class="sender-address">
        @if(isset($sender['organisation']))
            <strong>{{ $sender['organisation'] }}</strong><br>
        @endif
        {{ $sender['address_line_1'] }}<br>
        @if(!empty($sender['address_line_2']))
            {{ $sender['address_line_2'] }}<br>
        @endif
        {{ $sender['town'] }}<br>
        @if(!empty($sender['county']))
            {{ $sender['county'] }}<br>
        @endif
        {{ strtoupper($sender['postcode']) }}
    </div>
    
    <div class="recipient-address">
        @if(isset($recipient['name']))
            {{ $recipient['name'] }}<br>
        @endif
        @if(isset($recipient['organisation']))
            {{ $recipient['organisation'] }}<br>
        @endif
        {{ $recipient['address_line_1'] }}<br>
        @if(!empty($recipient['address_line_2']))
            {{ $recipient['address_line_2'] }}<br>
        @endif
        {{ $recipient['town'] }}<br>
        @if(!empty($recipient['county']))
            {{ $recipient['county'] }}<br>
        @endif
        {{ strtoupper($recipient['postcode']) }}
    </div>
    
    <div class="date">
        {{ \Carbon\Carbon::now()->format('d F Y') }}
    </div>
    
    @if(!empty($reference))
    <div class="reference">
        Our ref: {{ $reference }}
    </div>
    @endif
    
    <div class="salutation">
        Dear {{ $recipient['name'] ?? 'Sir/Madam' }},
    </div>
    
    <div class="content">
        {!! nl2br(e($content)) !!}
    </div>
    
    <div class="closing">
        <p>Yours {{ isset($recipient['name']) ? 'sincerely' : 'faithfully' }},</p>
        
        <div class="signature-space"></div>
        
        @if(isset($sender['name']))
            <p>{{ $sender['name'] }}</p>
        @endif
        @if(isset($sender['title']))
            <p>{{ $sender['title'] }}</p>
        @endif
    </div>
</body>
</html>
EOF

# Shipping label template
cat > resources/views/shipping/label.blade.php << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        @page { 
            margin: 0.5cm; 
            size: 6in 4in landscape;
        }
        body { 
            font-family: Arial, sans-serif; 
            font-size: 10pt;
            margin: 0;
            padding: 10px;
        }
        .label-container {
            border: 2px solid #000;
            padding: 10px;
            height: calc(100% - 24px);
            position: relative;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #000;
        }
        .royal-mail-logo {
            font-weight: bold;
            font-size: 16pt;
            color: #e30613;
        }
        .service-type {
            font-weight: bold;
            font-size: 14pt;
            text-transform: uppercase;
        }
        .addresses {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
        }
        .from-section, .to-section {
            width: 48%;
        }
        .from-section {
            font-size: 9pt;
        }
        .to-section {
            font-size: 11pt;
            font-weight: bold;
        }
        .section-label {
            font-size: 8pt;
            text-transform: uppercase;
            margin-bottom: 5px;
            color: #666;
        }
        .tracking-section {
            text-align: center;
            margin-top: 20px;
        }
        .tracking-number {
            font-size: 14pt;
            font-weight: bold;
            letter-spacing: 2px;
            margin: 10px 0;
        }
        .qr-code {
            text-align: center;
            margin: 10px 0;
        }
        .qr-code img {
            width: 100px;
            height: 100px;
        }
    </style>
</head>
<body>
    <div class="label-container">
        <div class="header">
            <div class="royal-mail-logo">ROYAL MAIL</div>
            <div class="service-type">{{ strtoupper($service) }}</div>
        </div>
        
        <div class="addresses">
            <div class="from-section">
                <div class="section-label">FROM:</div>
                {!! nl2br(e(\App\Helpers\UKFormat::address($from))) !!}
            </div>
            
            <div class="to-section">
                <div class="section-label">TO:</div>
                {!! nl2br(e(\App\Helpers\UKFormat::address($to))) !!}
            </div>
        </div>
        
        <div class="tracking-section">
            <div class="section-label">TRACKING NUMBER:</div>
            <div class="tracking-number">{{ $tracking }}</div>
            
            @if(isset($qrcode))
            <div class="qr-code">
                <img src="data:image/png;base64,{{ $qrcode }}" alt="QR Code">
            </div>
            @endif
            
            <div class="date">{{ $date }}</div>
        </div>
    </div>
</body>
</html>
EOF

print_success "View templates created"

# ========================================
# STEP 10: Create Migration
# ========================================
print_status "Creating database migration..."

TIMESTAMP=$(date +%Y_%m_%d_%H%M%S)

cat > database/migrations/${TIMESTAMP}_create_uk_addresses_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('uk_addresses', function (Blueprint $table) {
            $table->id();
            $table->string('organisation')->nullable();
            $table->string('building_name')->nullable();
            $table->string('building_number')->nullable();
            $table->string('sub_building')->nullable();
            $table->string('address_line_1');
            $table->string('address_line_2')->nullable();
            $table->string('address_line_3')->nullable();
            $table->string('town');
            $table->string('county')->nullable();
            $table->string('postcode', 8);
            $table->string('country')->default('United Kingdom');
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->string('uprn')->nullable()->comment('Unique Property Reference Number');
            $table->enum('type', ['delivery', 'billing', 'return'])->default('delivery');
            $table->timestamps();
            
            $table->index('postcode');
            $table->index('type');
            $table->index(['latitude', 'longitude']);
        });
    }
    
    public function down()
    {
        Schema::dropIfExists('uk_addresses');
    }
};
EOF

print_success "Migration created"

# ========================================
# STEP 11: Create Service Provider
# ========================================
print_status "Creating service provider..."

cat > app/Providers/UKServicesProvider.php << 'EOF'
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Services\PostcodeService;
use App\Services\UKBankHolidayService;
use App\Services\RoyalMailService;
use App\Services\LetterGeneratorService;

class UKServicesProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register()
    {
        // Register services as singletons
        $this->app->singleton(PostcodeService::class);
        $this->app->singleton(UKBankHolidayService::class);
        $this->app->singleton(RoyalMailService::class);
        $this->app->singleton(LetterGeneratorService::class);
    }

    /**
     * Bootstrap services.
     */
    public function boot()
    {
        // Load config
        $this->mergeConfigFrom(
            __DIR__.'/../../config/uk-services.php', 'uk-services'
        );
        
        // Load views
        $this->loadViewsFrom(__DIR__.'/../../resources/views/uk', 'uk');
        
        // Register helper functions
        require_once app_path('Helpers/UKFormat.php');
    }
}
EOF

print_success "Service provider created"

# ========================================
# STEP 12: Add Routes
# ========================================
print_status "Adding routes..."

cat >> routes/web.php << 'EOF'

// UK Services Routes
Route::prefix('uk')->name('uk.')->group(function () {
    // Postcode routes
    Route::prefix('postcode')->name('postcode.')->group(function () {
        Route::post('lookup', [App\Http\Controllers\UK\PostcodeController::class, 'lookup'])->name('lookup');
        Route::post('validate', [App\Http\Controllers\UK\PostcodeController::class, 'validate'])->name('validate');
        Route::post('autocomplete', [App\Http\Controllers\UK\PostcodeController::class, 'autocomplete'])->name('autocomplete');
    });
    
    // Letter generation routes
    Route::prefix('letters')->name('letters.')->group(function () {
        Route::post('generate', [App\Http\Controllers\UK\LetterController::class, 'generateLetter'])->name('generate');
        Route::post('envelope', [App\Http\Controllers\UK\LetterController::class, 'generateEnvelope'])->name('envelope');
        Route::post('shipping-label', [App\Http\Controllers\UK\LetterController::class, 'generateShippingLabel'])->name('shipping-label');
    });
});
EOF

print_success "Routes added"

# ========================================
# STEP 13: Update .env.example
# ========================================
print_status "Updating .env.example..."

cat >> .env.example << 'EOF'

# UK Services Configuration
ROYAL_MAIL_CLIENT_ID=
ROYAL_MAIL_CLIENT_SECRET=
ROYAL_MAIL_ACCOUNT=

# UK Business Details
VAT_NUMBER=GB123456789
COMPANY_HOUSE_NUMBER=12345678

# Newsletter Service
MAILCHIMP_APIKEY=
MAILCHIMP_LIST_ID=
EOF

print_success ".env.example updated"

# ========================================
# STEP 14: Register Service Provider
# ========================================
print_status "Registering service provider..."

# Check if provider already exists in config/app.php
if ! grep -q "UKServicesProvider" config/app.php; then
    # Add to providers array
    sed -i "/App\\\\Providers\\\\RouteServiceProvider::class,/a\\        App\\\\Providers\\\\UKServicesProvider::class," config/app.php
fi

# ========================================
# STEP 15: Publish Vendor Assets
# ========================================
print_status "Publishing vendor assets..."

php artisan vendor:publish --provider="Spatie\CookieConsent\CookieConsentServiceProvider" --force
php artisan vendor:publish --provider="Soved\Laravel\Gdpr\GdprServiceProvider" --force
php artisan vendor:publish --provider="Spatie\Newsletter\NewsletterServiceProvider" --force
php artisan vendor:publish --provider="Spatie\Backup\BackupServiceProvider" --force
php artisan vendor:publish --provider="Intervention\Image\ImageServiceProvider" --force

print_success "Vendor assets published"

# ========================================
# STEP 16: Run Migrations
# ========================================
print_status "Running migrations..."
php artisan migrate

# ========================================
# STEP 17: Create Example Usage File
# ========================================
print_status "Creating example usage documentation..."

cat > UK_SERVICES_USAGE.md << 'EOF'
# UK Services Usage Guide

## 1. Postcode Lookup

```php
use App\Services\PostcodeService;

$postcodeService = app(PostcodeService::class);

// Lookup postcode
$details = $postcodeService->lookup('SW1A 1AA');

// Validate postcode
$isValid = $postcodeService->validate('SW1A 1AA');

// Find nearest postcodes
$nearest = $postcodeService->findNearest('SW1A 1AA', 5);

// Autocomplete
$suggestions = $postcodeService->autocomplete('SW1A');
