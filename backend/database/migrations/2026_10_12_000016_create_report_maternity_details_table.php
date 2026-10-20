<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * C6. report_maternity_details — khusus jenis "ibu hamil" (1:1 dengan reports)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('report_maternity_details', function (Blueprint $table) {
            $table->unsignedBigInteger('report_id')->primary();
            $table->unsignedTinyInteger('gestational_age_weeks')->nullable()->comment('Usia kehamilan (minggu)');
            $table->unsignedTinyInteger('contraction_interval_minutes')->nullable()->comment('Jarak kontraksi (menit)');
            $table->boolean('is_water_broken')->default(false);
            $table->boolean('has_bleeding')->default(false);
            $table->unsignedTinyInteger('pregnancy_number')->nullable()->comment('Kehamilan ke-');
            $table->unsignedBigInteger('destination_clinic_id')->nullable()->comment('Faskes tujuan bila sudah terdaftar');

            $table->foreign('report_id', 'fk_report_maternity_details_report')
                ->references('id')->on('reports')
                ->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreign('destination_clinic_id', 'fk_report_maternity_details_clinic')
                ->references('id')->on('clinics')
                ->nullOnDelete()->cascadeOnUpdate();
        });

        if (in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
            DB::statement(<<<'SQL'
                ALTER TABLE report_maternity_details
                    ADD CONSTRAINT chk_maternity_weeks CHECK (gestational_age_weeks IS NULL OR gestational_age_weeks BETWEEN 1 AND 45)
                SQL);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('report_maternity_details');
    }
};
