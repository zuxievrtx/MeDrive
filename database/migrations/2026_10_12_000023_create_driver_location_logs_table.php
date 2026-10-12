<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * D2. driver_location_logs — log detail SETIAP ping (tiap 3 detik)
 * Ditulis berkelompok (bulk insert) dari buffer Redis tiap 10 detik.
 * Disimpan 14 hari lalu dihapus otomatis.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('driver_location_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('driver_id');
            $table->unsignedBigInteger('shift_id');
            $table->unsignedBigInteger('report_id')->nullable()->comment('Terisi saat driver sedang bertugas');
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->decimal('accuracy_m', 6, 1)->nullable()->comment('Akurasi GPS (meter)');
            $table->decimal('altitude_m', 7, 1)->nullable();
            $table->decimal('speed_kmh', 5, 1)->nullable();
            $table->unsignedSmallInteger('heading')->nullable()->comment('0-359 derajat');
            $table->unsignedTinyInteger('battery_level')->nullable()->comment('0-100 persen');
            $table->enum('provider', ['gps', 'network', 'fused'])->nullable();
            $table->boolean('is_mock_location')->default(false)->comment('TRUE = terdeteksi GPS palsu');
            $table->timestamp('recorded_at', 3)->comment('Waktu dari perangkat');
            $table->timestamp('received_at', 3)->comment('Waktu diterima server');

            $table->index(['driver_id', 'recorded_at'], 'idx_dlog_driver_time');
            $table->index(['shift_id', 'recorded_at'], 'idx_dlog_shift_time');
            $table->index(['report_id', 'recorded_at'], 'idx_dlog_report_time');
            $table->index('received_at', 'idx_dlog_received');

            $table->foreign('driver_id', 'fk_dlog_driver')
                ->references('id')->on('users')
                ->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreign('shift_id', 'fk_dlog_shift')
                ->references('id')->on('driver_shifts')
                ->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreign('report_id', 'fk_dlog_report')
                ->references('id')->on('reports')
                ->nullOnDelete()->cascadeOnUpdate();
        });

        if (in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
            DB::statement(<<<'SQL'
                ALTER TABLE driver_location_logs
                    ADD CONSTRAINT chk_dlog_lat     CHECK (latitude  BETWEEN -90  AND 90),
                    ADD CONSTRAINT chk_dlog_lng     CHECK (longitude BETWEEN -180 AND 180),
                    ADD CONSTRAINT chk_dlog_heading CHECK (heading IS NULL OR heading < 360),
                    ADD CONSTRAINT chk_dlog_battery CHECK (battery_level IS NULL OR battery_level <= 100)
                SQL);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('driver_location_logs');
    }
};
