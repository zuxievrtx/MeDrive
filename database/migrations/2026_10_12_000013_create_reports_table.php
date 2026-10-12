<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * C3. reports — data umum semua jenis laporan
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reports', function (Blueprint $table) {
            $table->id();
            $table->string('code', 20)->unique('uq_reports_code')->comment('Nomor laporan, mis. MDR-261009-0001');
            $table->unsignedBigInteger('report_type_id');
            $table->unsignedBigInteger('reporter_id');
            $table->unsignedBigInteger('driver_id')->nullable();
            $table->unsignedBigInteger('ambulance_id')->nullable();
            $table->decimal('latitude', 10, 7)->comment('Lokasi jemput / TKP');
            $table->decimal('longitude', 10, 7);
            $table->string('address', 255)->nullable()->comment('Alamat hasil reverse geocoding');
            $table->string('description', 500);
            $table->string('destination_name', 150)->nullable()->comment('Tujuan antar, mis. RS / rumah duka / makam');
            $table->string('destination_address', 255)->nullable();
            $table->decimal('destination_lat', 10, 7)->nullable();
            $table->decimal('destination_lng', 10, 7)->nullable();
            $table->enum('status', [
                'menunggu', 'diambil', 'dalam_perjalanan', 'tiba_di_lokasi',
                'mengantar_pasien', 'selesai', 'dibatalkan',
            ])->default('menunggu');
            $table->timestamp('taken_at')->nullable();
            $table->timestamp('arrived_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();

            $table->index(['status', 'created_at'], 'idx_reports_status_created');
            $table->index(['report_type_id', 'status'], 'idx_reports_type_status');
            $table->index(['reporter_id', 'created_at'], 'idx_reports_reporter_time');
            $table->index(['driver_id', 'created_at'], 'idx_reports_driver_time');
            $table->index('ambulance_id', 'idx_reports_ambulance');

            $table->foreign('report_type_id', 'fk_reports_type')
                ->references('id')->on('report_types')
                ->restrictOnDelete()->cascadeOnUpdate();
            $table->foreign('reporter_id', 'fk_reports_reporter')
                ->references('id')->on('users')
                ->restrictOnDelete()->cascadeOnUpdate();
            $table->foreign('driver_id', 'fk_reports_driver')
                ->references('id')->on('users')
                ->restrictOnDelete()->cascadeOnUpdate();
            $table->foreign('ambulance_id', 'fk_reports_ambulance')
                ->references('id')->on('ambulances')
                ->restrictOnDelete()->cascadeOnUpdate();
        });

        if (in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
            DB::statement(<<<'SQL'
                ALTER TABLE reports
                    ADD CONSTRAINT chk_reports_lat  CHECK (latitude  BETWEEN -90  AND 90),
                    ADD CONSTRAINT chk_reports_lng  CHECK (longitude BETWEEN -180 AND 180),
                    ADD CONSTRAINT chk_reports_dest CHECK (
                        (destination_lat IS NULL AND destination_lng IS NULL) OR
                        (destination_lat BETWEEN -90 AND 90 AND destination_lng BETWEEN -180 AND 180)
                    ),
                    ADD CONSTRAINT chk_reports_status_time CHECK (
                        (status IN ('menunggu','dibatalkan')
                            AND taken_at IS NULL AND arrived_at IS NULL AND completed_at IS NULL) OR
                        (status IN ('diambil','dalam_perjalanan')
                            AND taken_at IS NOT NULL AND arrived_at IS NULL AND completed_at IS NULL) OR
                        (status IN ('tiba_di_lokasi','mengantar_pasien')
                            AND taken_at IS NOT NULL AND arrived_at IS NOT NULL AND completed_at IS NULL) OR
                        (status = 'selesai'
                            AND taken_at IS NOT NULL AND arrived_at IS NOT NULL AND completed_at IS NOT NULL)
                    )
                SQL);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('reports');
    }
};
