<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Product;
use App\Models\Category;
use App\Models\Division;
use App\Models\User;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $user = User::first();
        $autonomousDivision = Division::where('slug', 'autonomous-systems')->first();
        $energyDivision = Division::where('slug', 'energy-intelligence')->first();
        $healthDivision = Division::where('slug', 'healthcare-innovation')->first();
        $industrialDivision = Division::where('slug', 'industrial-intelligence')->first();
        $marineDivision = Division::where('slug', 'marine-technologies')->first();

        $automationCategory = Category::where('slug', 'industrial-automation')->first();
        $powerCategory = Category::where('slug', 'power-electronics')->first();
        $controlCategory = Category::where('slug', 'control-systems')->first();

        $products = [
            // Flagship Autonomous Systems
            [
                'name' => 'SLB Vision Pro',
                'tagline' => 'The most advanced autonomous perception system ever created',
                'description' => '<div class="space-y-8">
                    <section class="hero-section">
                        <h1 class="text-5xl font-light mb-4">Vision Pro</h1>
                        <p class="text-2xl text-gray-600 mb-8">Revolutionary AI vision that sees, understands, and predicts with human-like intelligence.</p>
                    </section>
                    
                    <section class="capabilities">
                        <h2 class="text-3xl font-light mb-6">Breakthrough Capabilities</h2>
                        <div class="grid grid-cols-2 gap-8">
                            <div class="capability-card">
                                <h3 class="text-xl font-medium mb-2">360° Perception</h3>
                                <p>Advanced sensor fusion processes 50GB of data per second with 250-meter detection range.</p>
                            </div>
                            <div class="capability-card">
                                <h3 class="text-xl font-medium mb-2">Predictive Intelligence</h3>
                                <p>Machine learning models predict scenarios 8 seconds ahead with 99.7% accuracy.</p>
                            </div>
                        </div>
                    </section>
                    
                    <section class="technology-deep-dive">
                        <h2 class="text-3xl font-light mb-6">Advanced Technology Stack</h2>
                        <p class="text-lg mb-4">Built on our proprietary neural processing architecture, Vision Pro combines multiple AI models for real-time decision making.</p>
                    </section>
                </div>',
                'short_description' => 'AI-powered autonomous perception system with 360° awareness and predictive intelligence',
                'price' => 125000,
                'sku' => 'SLB-VP-2024',
                'division_id' => $autonomousDivision->id,
                'category_id' => $automationCategory->id,
                'product_family' => 'Vision Systems',
                'innovation_score' => 98,
                'specifications' => [
                    ['name' => 'Processing Power', 'value' => '500 TOPS AI Compute', 'type' => 'text'],
                    ['name' => 'Detection Range', 'value' => '250 meters', 'type' => 'dimension'],
                    ['name' => 'Latency', 'value' => '<5ms', 'type' => 'text'],
                    ['name' => 'Operating Temperature', 'value' => '-40°C to +85°C', 'type' => 'temperature'],
                    ['name' => 'Power Consumption', 'value' => '150W nominal', 'type' => 'power'],
                    ['name' => 'Sensors', 'value' => '8x LIDAR, 12x Cameras, 6x Radar', 'type' => 'text'],
                ],
                'features' => [
                    'Neural Processing Unit' => 'Custom silicon designed for autonomous applications',
                    'Real-time Mapping' => 'HD semantic mapping with centimeter accuracy',
                    'Weather Adaptation' => 'All-weather operation with adaptive algorithms',
                    'OTA Updates' => 'Continuous improvement through cloud intelligence',
                    'Privacy by Design' => 'On-device processing with encrypted communication'
                ],
                'use_cases' => [
                    'Autonomous Vehicles' => 'Level 4/5 self-driving capabilities',
                    'Industrial Robots' => 'Warehouse automation and navigation',
                    'Smart Infrastructure' => 'Traffic management and crowd monitoring',
                    'Security Systems' => 'Perimeter protection and threat detection'
                ],
                'comparison_points' => [
                    'Detection Accuracy' => '99.7% vs industry 95%',
                    'Processing Speed' => '5ms vs industry 50ms',
                    'Energy Efficiency' => '60% more efficient than competitors',
                    'Weather Performance' => 'Operates in all conditions vs fair weather only'
                ],
                'is_featured' => true,
                'is_active' => true,
                'launch_date' => now()->subMonths(3),
                'user_id' => $user->id,
            ],

            // Energy Intelligence Flagship
            [
                'name' => 'SLB Grid Master AI',
                'tagline' => 'Intelligent energy orchestration for the renewable future',
                'description' => '<div class="space-y-8">
                    <section class="hero-section">
                        <h1 class="text-5xl font-light mb-4">Grid Master AI</h1>
                        <p class="text-2xl text-gray-600 mb-8">The brain of tomorrow\'s energy grid, seamlessly balancing renewable sources with real-time demand.</p>
                    </section>
                    
                    <section class="innovation-highlight">
                        <h2 class="text-3xl font-light mb-6">Revolutionary Grid Intelligence</h2>
                        <p class="text-lg mb-6">Our AI algorithms process millions of data points every second, optimizing energy distribution while integrating up to 90% renewable sources.</p>
                        
                        <div class="stats-grid grid grid-cols-3 gap-6">
                            <div class="stat-card text-center">
                                <div class="text-4xl font-light text-green-600">35%</div>
                                <div class="text-sm text-gray-600">Grid Efficiency Increase</div>
                            </div>
                            <div class="stat-card text-center">
                                <div class="text-4xl font-light text-blue-600">90%</div>
                                <div class="text-sm text-gray-600">Renewable Integration</div>
                            </div>
                            <div class="stat-card text-center">
                                <div class="text-4xl font-light text-purple-600">99.9%</div>
                                <div class="text-sm text-gray-600">Grid Stability</div>
                            </div>
                        </div>
                    </section>
                </div>',
                'short_description' => 'AI-powered smart grid controller for optimal renewable energy integration',
                'price' => 89000,
                'sku' => 'SLB-GMA-2024',
                'division_id' => $energyDivision->id,
                'category_id' => $powerCategory->id,
                'product_family' => 'Grid Solutions',
                'innovation_score' => 95,
                'specifications' => [
                    ['name' => 'Grid Capacity', 'value' => 'Up to 1GW', 'type' => 'power'],
                    ['name' => 'Response Time', 'value' => '<100ms', 'type' => 'text'],
                    ['name' => 'Renewable Sources', 'value' => 'Solar, Wind, Hydro, Storage', 'type' => 'text'],
                    ['name' => 'Forecasting Accuracy', 'value' => '97% for 24h ahead', 'type' => 'text'],
                    ['name' => 'Communication', 'value' => 'IEC 61850, DNP3, Modbus', 'type' => 'text'],
                ],
                'features' => [
                    'Predictive Analytics' => 'Weather-aware demand and generation forecasting',
                    'Dynamic Pricing' => 'Real-time tariff optimization based on supply/demand',
                    'Storage Optimization' => 'Intelligent battery and pumped hydro management',
                    'Grid Resilience' => 'Automatic islanding and self-healing capabilities',
                    'Carbon Tracking' => 'Real-time emissions monitoring and reporting'
                ],
                'use_cases' => [
                    'Utility Companies' => 'Smart grid transformation and renewable integration',
                    'Industrial Microgrids' => 'Campus-wide energy optimization',
                    'Smart Cities' => 'Municipal energy management and sustainability',
                    'Data Centers' => 'Energy-efficient cloud infrastructure'
                ],
                'is_featured' => true,
                'is_active' => true,
                'launch_date' => now()->subMonths(6),
                'user_id' => $user->id,
            ],

            // Healthcare Innovation
            [
                'name' => 'SLB MedScan Pro',
                'tagline' => 'AI-powered diagnostic imaging that sees what humans cannot',
                'description' => '<div class="space-y-8">
                    <section class="hero-section">
                        <h1 class="text-5xl font-light mb-4">MedScan Pro</h1>
                        <p class="text-2xl text-gray-600 mb-8">Revolutionary medical imaging with AI that detects conditions years before traditional methods.</p>
                    </section>
                </div>',
                'short_description' => 'Advanced AI diagnostic imaging system with early detection capabilities',
                'price' => 275000,
                'sku' => 'SLB-MSP-2024',
                'division_id' => $healthDivision->id,
                'category_id' => $automationCategory->id,
                'product_family' => 'Medical Imaging',
                'innovation_score' => 97,
                'specifications' => [
                    ['name' => 'Resolution', 'value' => '0.1mm precision', 'type' => 'dimension'],
                    ['name' => 'Scan Time', 'value' => '<30 seconds', 'type' => 'text'],
                    ['name' => 'AI Models', 'value' => '15 specialized algorithms', 'type' => 'text'],
                    ['name' => 'Detection Accuracy', 'value' => '99.2% sensitivity', 'type' => 'text'],
                ],
                'features' => [
                    'Early Detection' => 'Identifies conditions 3-5 years before symptoms',
                    'Multi-Modal AI' => '15 specialized neural networks for different conditions',
                    'Real-time Analysis' => 'Instant results with confidence scoring',
                    'HIPAA Compliant' => 'End-to-end encryption and privacy protection'
                ],
                'is_featured' => true,
                'is_active' => true,
                'user_id' => $user->id,
            ],

            // Industrial Intelligence
            [
                'name' => 'SLB Factory Mind',
                'tagline' => 'Digital twin intelligence for the smart factory of tomorrow',
                'description' => '<div class="space-y-6">
                    <h1 class="text-4xl font-light">Factory Mind</h1>
                    <p class="text-xl text-gray-600">Complete digital transformation platform with real-time optimization and predictive insights.</p>
                </div>',
                'short_description' => 'Comprehensive Industry 4.0 platform with digital twin technology',
                'price' => 180000,
                'sku' => 'SLB-FM-2024',
                'division_id' => $industrialDivision->id,
                'category_id' => $controlCategory->id,
                'product_family' => 'Digital Factory',
                'innovation_score' => 93,
                'specifications' => [
                    ['name' => 'Data Points', 'value' => 'Unlimited IoT sensors', 'type' => 'text'],
                    ['name' => 'Prediction Accuracy', 'value' => '96% for failures', 'type' => 'text'],
                    ['name' => 'Update Rate', 'value' => 'Real-time (10ms)', 'type' => 'text'],
                ],
                'features' => [
                    'Digital Twin' => 'Real-time virtual factory representation',
                    'Predictive Maintenance' => 'AI-powered equipment health monitoring',
                    'Quality 4.0' => 'Automated quality control with machine vision',
                    'Energy Optimization' => 'Smart energy management and peak shaving'
                ],
                'is_featured' => false,
                'is_active' => true,
                'user_id' => $user->id,
            ],

            // Marine Technologies
            [
                'name' => 'SLB Ocean Navigator',
                'tagline' => 'Autonomous maritime intelligence for sustainable shipping',
                'description' => '<div class="space-y-6">
                    <h1 class="text-4xl font-light">Ocean Navigator</h1>
                    <p class="text-xl text-gray-600">Advanced autonomous navigation system reducing fuel consumption by 30% while ensuring safety.</p>
                </div>',
                'short_description' => 'Intelligent maritime navigation with autonomous capabilities',
                'price' => 320000,
                'sku' => 'SLB-ON-2024',
                'division_id' => $marineDivision->id,
                'category_id' => $automationCategory->id,
                'product_family' => 'Marine Automation',
                'innovation_score' => 91,
                'specifications' => [
                    ['name' => 'Navigation Range', 'value' => 'Global coverage', 'type' => 'text'],
                    ['name' => 'Fuel Efficiency', 'value' => '30% improvement', 'type' => 'text'],
                    ['name' => 'Weather Capability', 'value' => 'All weather conditions', 'type' => 'text'],
                ],
                'features' => [
                    'Route Optimization' => 'AI-powered fuel-efficient routing',
                    'Weather Integration' => 'Real-time weather-aware navigation',
                    'Collision Avoidance' => 'Advanced maritime radar and AI',
                    'Emission Monitoring' => 'Real-time environmental compliance'
                ],
                'is_featured' => false,
                'is_active' => true,
                'user_id' => $user->id,
            ],
        ];

        foreach ($products as $productData) {
            Product::create($productData);
        }
    }
}
