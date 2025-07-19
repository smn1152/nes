<?php

namespace App\Settings;

use Spatie\LaravelSettings\Settings;

class GeneralSettings extends Settings
{
    public string $site_name;
    public string $site_description;
    public string $site_logo;
    public string $contact_email;
    public string $contact_phone;
    public string $address;
    public array $social_links;
    public bool $maintenance_mode;
    
    public static function group(): string
    {
        return 'general';
    }
}
