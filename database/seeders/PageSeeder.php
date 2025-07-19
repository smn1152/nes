<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Page;
use App\Models\User;

class PageSeeder extends Seeder
{
    public function run(): void
    {
        $user = User::first();

        $pages = [
            [
                'title' => 'Innovation Philosophy',
                'slug' => 'innovation',
                'content' => '<div class="innovation-page">
                    <section class="hero-section">
                        <h1 class="text-6xl font-thin mb-6">Innovation Through Integration</h1>
                        <p class="text-2xl text-gray-600 mb-12">We don\'t just build products. We orchestrate technological symphonies that transform entire industries.</p>
                    </section>
                    
                    <section class="philosophy-grid">
                        <div class="philosophy-card">
                            <h2>Cross-Pollination</h2>
                            <p>Medical AI algorithms enhance autonomous vehicle safety. Marine efficiency innovations power smart grids. We break down silos to create breakthrough solutions.</p>
                        </div>
                        
                        <div class="philosophy-card">
                            <h2>Human-Centered AI</h2>
                            <p>Our artificial intelligence amplifies human capabilities rather than replacing them. Every algorithm is designed to augment human intelligence and decision-making.</p>
                        </div>
                        
                        <div class="philosophy-card">
                            <h2>Sustainable by Design</h2>
                            <p>Sustainability isn\'t an afterthought—it\'s embedded in every design decision. From energy efficiency to circular economy principles, we build for a better tomorrow.</p>
                        </div>
                    </section>
                    
                    <section class="impact-metrics">
                        <h2 class="text-4xl font-light mb-8">Global Impact</h2>
                        <div class="metrics-grid">
                            <div class="metric">
                                <span class="number">2.5M</span>
                                <span class="label">Tons CO2 Reduced</span>
                            </div>
                            <div class="metric">
                                <span class="number">500K+</span>
                                <span class="label">Lives Improved</span>
                            </div>
                            <div class="metric">
                                <span class="number">£45M</span>
                                <span class="label">Annual R&D Investment</span>
                            </div>
                        </div>
                    </section>
                </div>',
                'excerpt' => 'Our philosophy of cross-industry innovation and human-centered AI',
                'template' => 'innovation',
                'meta_title' => 'Innovation Philosophy | Salbion Group',
                'meta_description' => 'Discover how Salbion Group\'s cross-industry innovation approach creates breakthrough solutions that transform entire industries.',
                'meta_keywords' => ['innovation', 'AI', 'sustainability', 'cross-industry'],
                'status' => 'published',
                'is_featured' => true,
                'published_at' => now(),
                'user_id' => $user->id,
            ],
            [
                'title' => 'Global Presence',
                'slug' => 'locations',
                'content' => '<div class="locations-page">
                    <h1 class="text-5xl font-light mb-8">Where Innovation Happens</h1>
                    <p class="text-xl text-gray-600 mb-12">Six continents. Twelve innovation centers. One vision: transforming industries through technology.</p>
                    
                    <div class="location-highlights">
                        <div class="location-card">
                            <h3>Silicon Valley AI Lab</h3>
                            <p>Pushing the boundaries of artificial intelligence and autonomous systems.</p>
                        </div>
                        <div class="location-card">
                            <h3>Nordic Energy Center</h3>
                            <p>Pioneering sustainable energy solutions for the renewable future.</p>
                        </div>
                        <div class="location-card">
                            <h3>Medical Innovation Campus</h3>
                            <p>Advancing healthcare through AI-powered diagnostics and treatment.</p>
                        </div>
                    </div>
                </div>',
                'excerpt' => 'Global innovation centers driving technological transformation',
                'template' => 'locations',
                'meta_title' => 'Global Locations | Salbion Group',
                'meta_description' => 'Discover Salbion Group\'s global network of innovation centers and manufacturing facilities across six continents.',
                'meta_keywords' => ['locations', 'global', 'innovation centers', 'R&D'],
                'status' => 'published',
                'is_featured' => false,
                'published_at' => now()->subDays(5),
                'user_id' => $user->id,
            ],
            [
                'title' => 'Sustainability Commitment',
                'slug' => 'sustainability',
                'content' => '<div class="sustainability-page">
                    <h1 class="text-5xl font-light mb-8">Building Tomorrow, Responsibly</h1>
                    <p class="text-xl text-gray-600 mb-12">Our commitment to sustainability goes beyond compliance—it\'s the foundation of everything we create.</p>
                </div>',
                'excerpt' => 'Our comprehensive approach to sustainable innovation',
                'template' => 'sustainability',
                'meta_title' => 'Sustainability | Salbion Group',
                'meta_description' => 'Learn about Salbion Group\'s commitment to sustainable innovation and our environmental impact initiatives.',
                'meta_keywords' => ['sustainability', 'environment', 'carbon neutral', 'green technology'],
                'status' => 'published',
                'is_featured' => true,
                'published_at' => now()->subDays(10),
                'user_id' => $user->id,
            ]
        ];

        foreach ($pages as $page) {
            Page::create($page);
        }
    }
}
