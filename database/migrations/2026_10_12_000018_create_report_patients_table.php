<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * C8. report_patients — data pasien/korban per laporan (diisi pelapor, dilengkapi driver)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('report_patients', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('report_id');
            $table->string('name', 100)->nullable();
            $table->enum('gender', ['L', 'P'])->nullable();
            $table->unsignedTinyInteger('age_estimate')->nullable();
            $table->enum('consciousness', ['sadar', 'tidak_sadar', 'tidak_diketahui'])->default('tidak_diketahui');
            $table->boolean('is_breathing')->nullable();
            $table->string('condition_note', 255)->nullable();
            $table->string('handed_over_to', 150)->nullable()->comment('Faskes/petugas penerima pasien');
            $table->timestamp('handed_over_at')->nullable();
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();

            $table->index('report_id', 'idx_report_patients_report');

            $table->foreign('report_id', 'fk_report_patients_report')
                ->references('id')->on('reports')
                ->cascadeOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('report_patients');
    }
};
