<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Division;

class DivisionSeeder extends Seeder
{
    public function run(): void
    {
        $divisions = [
            [
                'name' => 'Autonomous Systems',
                'slug' => 'autonomous-systems',
                'description' => 'Pioneering self-driving technologies and intelligent automation across industries',
                'icon' => 'heroicon-o-cpu-chip',
                'color' => 'bg-gradient-to-r from-blue-600 to-purple-600',
                'sort_order' => 1,
                'stats' => [
                    'r_and_d_investment' => '£45M annually',
                    'patents_filed' => 127,
                    'ai_models_deployed' => 23,
                    'safety_miles' => '2.5M autonomous miles'
                ],
                'key_technologies' => [
                    'Computer Vision', 'Machine Learning', 'Sensor Fusion', 
                    'Real-time Decision Making', 'Edge Computing'
                ]
            ],
            [
                'name' => 'Energy Intelligence',
                'slug' => 'energy-intelligence',
                'description' => 'Smart grid solutions and renewable energy optimization systems',
                'icon' => 'heroicon-o-lightning-bolt',
                'color' => 'bg-gradient-to-r from-yellow-500 to-orange-500',
                'sort_order' => 2,
                'stats' => [
                    'grid_efficiency_improvement' => '35%',
                    'renewable_integration' => '90%',
                    'carbon_reduction' => '2.1M tons CO2',
                    'smart_meters_deployed' => '150K+'
                ],
                'key_technologies' => [
                    'Smart Grid Analytics', 'Renewable Integration', 'Energy Storage',
                    'Demand Response', 'Grid Cybersecurity'
                ]
            ],
            [
                'name' => 'Healthcare Innovation',
                'slug' => 'healthcare-innovation',
                'description' => 'Advanced medical devices and diagnostic solutions for better patient outcomes',
                'icon' => 'heroicon-o-heart',
                'color' => 'bg-gradient-to-r from-red-500 to-pink-500',
                'sort_order' => 3,
                'stats' => [
                    'patients_impacted' => '500K+ annually',
                    'diagnostic_accuracy' => '99.2%',
                    'treatment_time_reduction' => '40%',
                    'hospitals_equipped' => '250+'
                ],
                'key_technologies' => [
                    'AI Diagnostics', 'Precision Medicine', 'Robotic Surgery',
                    'Wearable Health Tech', 'Telemedicine Platforms'
                ]
            ],
            [
                'name' => 'Industrial Intelligence',
                'slug' => 'industrial-intelligence',
                'description' => 'Industry 4.0 solutions transforming manufacturing and production',
                'icon' => 'heroicon-o-cog-8-tooth',
                'color' => 'bg-gradient-to-r from-gray-700 to-gray-900',
                'sort_order' => 4,
                'stats' => [
                    'productivity_increase' => '45%',
                    'predictive_accuracy' => '96%',
                    'downtime_reduction' => '60%',
                    'factories_digitized' => '180+'
                ],
                'key_technologies' => [
                    'Digital Twins', 'Predictive Maintenance', 'IoT Sensors',
                    'Robotic Process Automation', 'Quality 4.0'
                ]
            ],
            [
                'name' => 'Marine Technologies',
                'slug' => 'marine-technologies',
                'description' => 'Sustainable maritime solutions and offshore energy systems',
                'icon' => 'heroicon-o-beaker',
                'color' => 'bg-gradient-to-r from-teal-600 to-blue-800',
                'sort_order' => 5,
                'stats' => [
                    'fuel_efficiency_improvement' => '30%',
                    'emission_reduction' => '50%',
                    'vessels_equipped' => '400+',
                    'offshore_installations' => '25'
                ],
                'key_technologies' => [
                    'Hybrid Propulsion', 'Smart Navigation', 'Ocean Monitoring',
                    'Autonomous Vessels', 'Offshore Automation'
                ]
            ]
        ];

        foreach ($divisions as $division) {
            Division::create($division);
        }
    }
}
