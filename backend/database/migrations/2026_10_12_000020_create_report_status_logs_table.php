<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * C10. report_status_logs — riwayat setiap perubahan status (siapa, kapan, di mana)
 */
return new class extends Migration
{
    public function up(): void
    {
        $statuses = [
            'menunggu', 'diambil', 'dalam_perjalanan', 'tiba_di_lokasi',
            'mengantar_pasien', 'selesai', 'dibatalkan',
        ];

        Schema::create('report_status_logs', function (Blueprint $table) use ($statuses) {
            $table->id();
            $table->unsignedBigInteger('report_id');
            $table->enum('from_status', $statuses)->nullable()->comment('NULL = laporan baru');
            $table->enum('to_status', $statuses);
            $table->unsignedBigInteger('changed_by')->nullable()->comment('NULL = sistem');
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->string('note', 255)->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->index(['report_id', 'created_at'], 'idx_report_status_logs_report_time');

            $table->foreign('report_id', 'fk_report_status_logs_report')
                ->references('id')->on('reports')
                ->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreign('changed_by', 'fk_report_status_logs_user')
                ->references('id')->on('users')
                ->nullOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('report_status_logs');
    }
};
