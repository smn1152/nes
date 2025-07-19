<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;

class Location extends Model implements HasMedia
{
    use InteractsWithMedia;

    protected $fillable = [
        'name', 'type', 'address', 'coordinates', 'functions', 
        'description', 'contact_info', 'capabilities', 'is_active'
    ];

    protected $casts = [
        'functions' => 'array',
        'contact_info' => 'array',
        'capabilities' => 'array',
        'is_active' => 'boolean',
    ];

    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('images');
        $this->addMediaCollection('featured_image')->singleFile();
    }
}
