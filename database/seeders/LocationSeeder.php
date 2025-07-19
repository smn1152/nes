<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Location;

class LocationSeeder extends Seeder
{
    public function run(): void
    {
        $locations = [
            [
                'name' => 'Global Headquarters',
                'type' => 'headquarters',
                'address' => 'Salbion House, 1 Innovation Way, London, UK EC2A 4NE',
                'coordinates' => '51.5074,-0.1278',
                'functions' => ['Executive Leadership', 'Global Strategy', 'Corporate Innovation', 'Investor Relations'],
                'description' => 'Our flagship headquarters houses executive leadership and drives global innovation strategy.',
                'contact_info' => [
                    'phone' => '+44 20 7946 0958',
                    'email' => 'headquarters@salbiongroup.com',
                    'linkedin' => 'salbion-group-hq'
                ],
                'capabilities' => [
                    'Executive Boardroom', 'Innovation Showcase', 'Customer Experience Center', 
                    'Global Communication Hub', 'Strategic Planning Facilities'
                ]
            ],
            [
                'name' => 'Silicon Valley AI Lab',
                'type' => 'rnd',
                'address' => '3000 AI Boulevard, Palo Alto, CA 94301, USA',
                'coordinates' => '37.4419,-122.1430',
                'functions' => ['Artificial Intelligence', 'Machine Learning', 'Computer Vision', 'Autonomous Systems'],
                'description' => 'Leading-edge AI research facility developing next-generation autonomous technologies.',
                'contact_info' => [
                    'phone' => '+1 650 555 0123',
                    'email' => 'ai-lab@salbiongroup.com',
                    'twitter' => 'salbion_ai'
                ],
                'capabilities' => [
                    'AI Research Labs', 'Autonomous Vehicle Testing', 'Neural Network Development',
                    'Computer Vision Studios', 'Edge Computing Research'
                ]
            ],
            [
                'name' => 'Nordic Energy Center',
                'type' => 'rnd',
                'address' => 'Renewable Energy Park, Copenhagen, Denmark',
                'coordinates' => '55.6761,12.5683',
                'functions' => ['Renewable Energy', 'Smart Grid', 'Energy Storage', 'Sustainability'],
                'description' => 'Pioneering sustainable energy solutions and smart grid technologies.',
                'contact_info' => [
                    'phone' => '+45 33 12 34 56',
                    'email' => 'energy@salbiongroup.com'
                ],
                'capabilities' => [
                    'Wind Energy Research', 'Grid Integration Testing', 'Battery Technology Lab',
                    'Smart Meter Development', 'Carbon Footprint Analysis'
                ]
            ],
            [
                'name' => 'Asia-Pacific Manufacturing Hub',
                'type' => 'manufacturing',
                'address' => '88 Industry 4.0 Avenue, Singapore 138777',
                'coordinates' => '1.3521,103.8198',
                'functions' => ['Advanced Manufacturing', 'Quality Control', 'Supply Chain', 'Distribution'],
                'description' => 'State-of-the-art manufacturing facility with full Industry 4.0 automation.',
                'contact_info' => [
                    'phone' => '+65 6789 1234',
                    'email' => 'manufacturing@salbiongroup.com'
                ],
                'capabilities' => [
                    'Automated Production Lines', 'Quality 4.0 Systems', 'Digital Twin Manufacturing',
                    'Predictive Maintenance', 'Sustainable Production'
                ]
            ],
            [
                'name' => 'Medical Innovation Campus',
                'type' => 'rnd',
                'address' => 'Health Tech Quarter, Boston, MA 02115, USA',
                'coordinates' => '42.3601,-71.0589',
                'functions' => ['Medical Devices', 'AI Diagnostics', 'Biomedical Engineering', 'Clinical Research'],
                'description' => 'Advanced medical technology research and development facility.',
                'contact_info' => [
                    'phone' => '+1 617 555 0156',
                    'email' => 'medical@salbiongroup.com'
                ],
                'capabilities' => [
                    'Medical AI Development', 'Clinical Testing Labs', 'Biomedical Research',
                    'Regulatory Compliance', 'Medical Device Prototyping'
                ]
            ],
            [
                'name' => 'Marine Technology Institute',
                'type' => 'rnd',
                'address' => 'Maritime Innovation Park, Hamburg, Germany',
                'coordinates' => '53.5511,9.9937',
                'functions' => ['Marine Engineering', 'Autonomous Vessels', 'Ocean Monitoring', 'Port Automation'],
                'description' => 'Maritime technology research facility focusing on sustainable shipping solutions.',
                'contact_info' => [
                    'phone' => '+49 40 1234 5678',
                    'email' => 'marine@salbiongroup.com'
                ],
                'capabilities' => [
                    'Ship Design Lab', 'Navigation Systems Testing', 'Ocean Simulation Tank',
                    'Autonomous Vessel Development', 'Port Automation Research'
                ]
            ]
        ];

        foreach ($locations as $location) {
            Location::create($location);
        }
    }
}
