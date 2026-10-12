<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * C5. report_medical_details — khusus jenis "medis darurat" (1:1 dengan reports)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('report_medical_details', function (Blueprint $table) {
            $table->unsignedBigInteger('report_id')->primary();
            $table->enum('medical_category', [
                'jantung', 'stroke', 'sesak_napas', 'kejang', 'tidak_sadar',
                'cedera', 'keracunan', 'lainnya',
            ]);
            $table->timestamp('symptom_onset_at')->nullable()->comment('Perkiraan waktu gejala mulai');
            $table->boolean('has_medical_history')->default(false);
            $table->string('medical_history_notes', 255)->nullable();

            $table->foreign('report_id', 'fk_report_medical_details_report')
                ->references('id')->on('reports')
                ->cascadeOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('report_medical_details');
    }
};
