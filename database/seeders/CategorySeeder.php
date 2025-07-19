<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Artificial Intelligence',
                'slug' => 'artificial-intelligence',
                'description' => 'Advanced AI systems and machine learning solutions',
                'color' => '#667eea',
                'icon' => 'heroicon-o-cpu-chip',
                'is_active' => true,
                'sort_order' => 1,
            ],
            [
                'name' => 'Autonomous Systems',
                'slug' => 'autonomous-systems',
                'description' => 'Self-driving and autonomous control technologies',
                'color' => '#f56565',
                'icon' => 'heroicon-o-cog-6-tooth',
                'is_active' => true,
                'sort_order' => 2,
            ],
            [
                'name' => 'Energy Solutions',
                'slug' => 'energy-solutions',
                'description' => 'Smart grid and renewable energy systems',
                'color' => '#38b2ac',
                'icon' => 'heroicon-o-bolt',
                'is_active' => true,
                'sort_order' => 3,
            ],
            [
                'name' => 'Medical Technology',
                'slug' => 'medical-technology',
                'description' => 'Healthcare innovations and diagnostic tools',
                'color' => '#ed8936',
                'icon' => 'heroicon-o-heart',
                'is_active' => true,
                'sort_order' => 4,
            ],
            [
                'name' => 'Industrial IoT',
                'slug' => 'industrial-iot',
                'description' => 'Connected industrial systems and sensors',
                'color' => '#9f7aea',
                'icon' => 'heroicon-o-signal',
                'is_active' => true,
                'sort_order' => 5,
            ],
            [
                'name' => 'Marine Systems',
                'slug' => 'marine-systems',
                'description' => 'Maritime automation and navigation solutions',
                'color' => '#48bb78',
                'icon' => 'heroicon-o-beaker',
                'is_active' => true,
                'sort_order' => 6,
            ],
        ];

        foreach ($categories as $category) {
            Category::create($category);
        }
    }
}
