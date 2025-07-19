<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // استفاده از Schema Builder به جای Raw Queries
        Schema::table('cache', function (Blueprint $table) {
            if (!Schema::hasIndex('cache', 'cache_key_index')) {
                $table->index('key', 'cache_key_index');
            }
            if (!Schema::hasIndex('cache', 'cache_expiration_index')) {
                $table->index('expiration', 'cache_expiration_index');
            }
        });
        
        // سایر جداول...
    }
    
    // Helper method برای بررسی وجود index
    private function hasIndex($table, $index): bool
    {
        $connection = Schema::getConnection();
        $dbName = $connection->getDatabaseName();
        
        $result = $connection->select(
            "SELECT COUNT(*) as count FROM information_schema.statistics 
             WHERE table_schema = ? AND table_name = ? AND index_name = ?",
            [$dbName, $table, $index]
        );
        
        return $result[0]->count > 0;
    }
};
