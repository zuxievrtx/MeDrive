<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * C4. report_accident_details — khusus jenis "kecelakaan" (1:1 dengan reports)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('report_accident_details', function (Blueprint $table) {
            $table->unsignedBigInteger('report_id')->primary();
            $table->enum('accident_type', ['tunggal', 'tabrakan', 'tertabrak', 'lainnya']);
            $table->unsignedTinyInteger('estimated_victim_count')->default(1);
            $table->boolean('has_trapped_victim')->default(false);
            $table->boolean('has_fire_hazard')->default(false);
            $table->boolean('is_road_blocked')->default(false);

            $table->foreign('report_id', 'fk_report_accident_details_report')
                ->references('id')->on('reports')
                ->cascadeOnDelete()->cascadeOnUpdate();
        });

        if (in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
            DB::statement(<<<'SQL'
                ALTER TABLE report_accident_details
                    ADD CONSTRAINT chk_accident_victims CHECK (estimated_victim_count >= 1)
                SQL);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('report_accident_details');
    }
};
