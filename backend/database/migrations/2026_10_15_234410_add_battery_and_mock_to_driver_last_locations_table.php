<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Whitelist additive ERD v3: snapshot lokasi ikut menyimpan baterai dan flag GPS palsu dari ping terakhir,
 * supaya Peta Live bisa memberi peringatan tanpa membaca driver_location_logs.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('driver_last_locations', function (Blueprint $table) {
            $table->unsignedTinyInteger('battery_level')->nullable()->after('heading')->comment('0-100 persen');
            $table->boolean('is_mock_location')->default(false)->after('battery_level')->comment('TRUE = terdeteksi GPS palsu');
        });
    }

    public function down(): void
    {
        Schema::table('driver_last_locations', function (Blueprint $table) {
            $table->dropColumn(['battery_level', 'is_mock_location']);
        });
    }
};
