<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * D1. driver_last_locations — 1 baris per driver, posisi terakhir (snapshot maks. tiap 15 dtk)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('driver_last_locations', function (Blueprint $table) {
            $table->unsignedBigInteger('driver_id')->primary();
            $table->unsignedBigInteger('shift_id')->nullable();
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->decimal('accuracy_m', 6, 1)->nullable();
            $table->decimal('speed_kmh', 5, 1)->nullable();
            $table->unsignedSmallInteger('heading')->nullable();
            $table->timestamp('recorded_at', 3);
            $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();

            $table->foreign('driver_id', 'fk_driver_last_locations_driver')
                ->references('id')->on('users')
                ->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreign('shift_id', 'fk_driver_last_locations_shift')
                ->references('id')->on('driver_shifts')
                ->nullOnDelete()->cascadeOnUpdate();
        });

        if (in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
            DB::statement(<<<'SQL'
                ALTER TABLE driver_last_locations
                    ADD CONSTRAINT chk_dll_lat     CHECK (latitude  BETWEEN -90  AND 90),
                    ADD CONSTRAINT chk_dll_lng     CHECK (longitude BETWEEN -180 AND 180),
                    ADD CONSTRAINT chk_dll_heading CHECK (heading IS NULL OR heading < 360)
                SQL);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('driver_last_locations');
    }
};
