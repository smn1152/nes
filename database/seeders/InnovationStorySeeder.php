<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\InnovationStory;

class InnovationStorySeeder extends Seeder
{
    public function run(): void
    {
        $stories = [
            [
                'title' => 'Revolutionizing Urban Mobility',
                'slug' => 'revolutionizing-urban-mobility',
                'tagline' => 'How our autonomous systems reduced London traffic by 25%',
                'content' => '<div class="story-content">
                    <h1>The London Transformation</h1>
                    <p>In partnership with Transport for London, we deployed our Vision Pro systems across 50 key intersections, creating the world\'s most advanced traffic management network.</p>
                    
                    <h2>The Challenge</h2>
                    <p>London\'s traffic congestion was costing the economy £9.5 billion annually while contributing significantly to air pollution.</p>
                    
                    <h2>Our Solution</h2>
                    <p>AI-powered traffic optimization that learns and adapts in real-time, coordinating signals across the entire network.</p>
                    
                    <h2>Results</h2>
                    <ul>
                        <li>25% reduction in average journey times</li>
                        <li>40% decrease in traffic-related emissions</li>
                        <li>£2.3B annual economic benefit</li>
                        <li>99.9% system uptime</li>
                    </ul>
                </div>',
                'category' => 'Smart Cities',
                'impact_metrics' => [
                    'traffic_reduction' => '25%',
                    'emission_decrease' => '40%',
                    'economic_benefit' => '£2.3B annually',
                    'system_uptime' => '99.9%'
                ],
                'technologies_used' => [
                    'Vision Pro AI', 'Real-time Analytics', 'Edge Computing', 'IoT Sensors'
                ],
                'timeline' => [
                    '2022-Q1' => 'Project initiation and planning',
                    '2022-Q3' => 'Pilot deployment at 5 intersections',
                    '2023-Q1' => 'Full rollout across 50 locations',
                    '2023-Q4' => 'Results verification and optimization'
                ],
                'is_featured' => true,
                'published_at' => now()->subMonths(2)
            ],
            [
                'title' => 'Zero-Carbon Manufacturing Reality',
                'slug' => 'zero-carbon-manufacturing',
                'tagline' => 'Achieving carbon neutrality in heavy industry',
                'content' => '<div class="story-content">
                    <h1>The Net-Zero Factory</h1>
                    <p>Our Factory Mind platform helped Siemens achieve complete carbon neutrality in their Amberg facility.</p>
                </div>',
                'category' => 'Sustainability',
                'impact_metrics' => [
                    'carbon_reduction' => '100%',
                    'energy_efficiency' => '45%',
                    'waste_reduction' => '80%'
                ],
                'technologies_used' => [
                    'Factory Mind Platform', 'Energy AI', 'Digital Twin', 'Predictive Analytics'
                ],
                'is_featured' => true,
                'published_at' => now()->subMonths(4)
            ]
        ];

        foreach ($stories as $story) {
            InnovationStory::create($story);
        }
    }
}
