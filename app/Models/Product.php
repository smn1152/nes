<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;
use Spatie\MediaLibrary\MediaCollections\Models\Media;
use Spatie\Sluggable\HasSlug;
use Spatie\Sluggable\SlugOptions;

class Product extends Model implements HasMedia
{
    use HasSlug, InteractsWithMedia;

    protected $fillable = [
        'name', 'slug', 'tagline', 'description', 'price', 'sku',
        'specifications', 'features', 'use_cases', 'comparison_points',
        'technical_docs', 'meta_title', 'meta_description', 'keywords',
        'is_featured', 'is_active', 'launch_date', 'category_id', 
        'division_id', 'user_id', 'product_family', 'innovation_score'
    ];

    protected $casts = [
        'specifications' => 'array',
        'features' => 'array',
        'use_cases' => 'array',
        'comparison_points' => 'array',
        'technical_docs' => 'array',
        'keywords' => 'array',
        'is_featured' => 'boolean',
        'is_active' => 'boolean',
        'launch_date' => 'datetime',
        'price' => 'decimal:2',
        'innovation_score' => 'integer',
    ];

    public function getSlugOptions(): SlugOptions
    {
        return SlugOptions::create()
            ->generateSlugsFrom('name')
            ->saveSlugsTo('slug');
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function division(): BelongsTo
    {
        return $this->belongsTo(Division::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('hero_image')->singleFile();
        $this->addMediaCollection('gallery');
        $this->addMediaCollection('hero_video')->singleFile();
        $this->addMediaCollection('ar_preview')->singleFile();
        $this->addMediaCollection('technical_drawings');
        $this->addMediaCollection('case_studies');
    }

    public function registerMediaConversions(Media $media = null): void
    {
        $this->addMediaConversion('hero')
            ->width(1920)->height(1080)->performOnCollections('hero_image');
        
        $this->addMediaConversion('card')
            ->width(600)->height(400)->performOnCollections('hero_image', 'gallery');
        
        $this->addMediaConversion('thumb')
            ->width(300)->height(200)->performOnCollections('gallery');
    }

    public function getFormattedPriceAttribute(): string
    {
        return $this->price ? '£' . number_format($this->price, 0) : 'Contact for pricing';
    }
}

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
