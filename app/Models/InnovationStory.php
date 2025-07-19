<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;
use Spatie\Sluggable\HasSlug;
use Spatie\Sluggable\SlugOptions;

class InnovationStory extends Model implements HasMedia
{
    use HasSlug, InteractsWithMedia;

    protected $fillable = [
        'title', 'slug', 'tagline', 'content', 'category', 'impact_metrics',
        'technologies_used', 'timeline', 'is_featured', 'published_at'
    ];

    protected $casts = [
        'impact_metrics' => 'array',
        'technologies_used' => 'array',
        'timeline' => 'array',
        'is_featured' => 'boolean',
        'published_at' => 'datetime',
    ];

    public function getSlugOptions(): SlugOptions
    {
        return SlugOptions::create()
            ->generateSlugsFrom('title')
            ->saveSlugsTo('slug');
    }

    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('hero_media')->singleFile();
        $this->addMediaCollection('gallery');
        $this->addMediaCollection('before_after');
    }
}
