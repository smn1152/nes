<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Helper function to check if index exists
        $indexExists = function($table, $index) {
            $indexes = DB::select("SHOW INDEX FROM $table WHERE Key_name = ?", [$index]);
            return count($indexes) > 0;
        };

        // Cache table indexes
        if (!$indexExists('cache', 'cache_key_index')) {
            Schema::table('cache', function (Blueprint $table) {
                $table->index('key');
            });
        }
        
        if (!$indexExists('cache', 'cache_expiration_index')) {
            Schema::table('cache', function (Blueprint $table) {
                $table->index('expiration');
            });
        }

        // Divisions table indexes (if columns exist)
        if (Schema::hasColumn('divisions', 'name') && !$indexExists('divisions', 'divisions_name_index')) {
            Schema::table('divisions', function (Blueprint $table) {
                $table->index('name');
            });
        }
        
        if (Schema::hasColumn('divisions', 'slug') && !$indexExists('divisions', 'divisions_slug_index')) {
            Schema::table('divisions', function (Blueprint $table) {
                $table->index('slug');
            });
        }

        // Locations table indexes (if columns exist)
        if (Schema::hasColumn('locations', 'name') && !$indexExists('locations', 'locations_name_index')) {
            Schema::table('locations', function (Blueprint $table) {
                $table->index('name');
            });
        }
        
        if (Schema::hasColumn('locations', 'country') && !$indexExists('locations', 'locations_country_index')) {
            Schema::table('locations', function (Blueprint $table) {
                $table->index('country');
            });
        }
    }

    public function down(): void
    {
        // Remove indexes if they exist
        $indexExists = function($table, $index) {
            $indexes = DB::select("SHOW INDEX FROM $table WHERE Key_name = ?", [$index]);
            return count($indexes) > 0;
        };

        // Cache
        if ($indexExists('cache', 'cache_key_index')) {
            Schema::table('cache', function (Blueprint $table) {
                $table->dropIndex('cache_key_index');
            });
        }
        
        if ($indexExists('cache', 'cache_expiration_index')) {
            Schema::table('cache', function (Blueprint $table) {
                $table->dropIndex('cache_expiration_index');
            });
        }

        // Divisions
        if ($indexExists('divisions', 'divisions_name_index')) {
            Schema::table('divisions', function (Blueprint $table) {
                $table->dropIndex('divisions_name_index');
            });
        }
        
        if ($indexExists('divisions', 'divisions_slug_index')) {
            Schema::table('divisions', function (Blueprint $table) {
                $table->dropIndex('divisions_slug_index');
            });
        }

        // Locations
        if ($indexExists('locations', 'locations_name_index')) {
            Schema::table('locations', function (Blueprint $table) {
                $table->dropIndex('locations_name_index');
            });
        }
        
        if ($indexExists('locations', 'locations_country_index')) {
            Schema::table('locations', function (Blueprint $table) {
                $table->dropIndex('locations_country_index');
            });
        }
    }
};
