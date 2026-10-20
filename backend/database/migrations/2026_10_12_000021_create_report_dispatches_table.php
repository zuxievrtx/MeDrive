<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * C11. report_dispatches — siapa saja yang menerima broadcast laporan & responsnya
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('report_dispatches', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('report_id');
            $table->unsignedBigInteger('driver_id');
            $table->unsignedBigInteger('shift_id')->comment('Shift (dan ambulans) saat notifikasi dikirim');
            $table->decimal('distance_km', 6, 2);
            $table->timestamp('sent_at')->useCurrent();
            $table->timestamp('opened_at')->nullable()->comment('Driver membuka detail laporan');
            $table->enum('response', ['menunggu', 'diambil', 'kalah_cepat', 'diabaikan', 'kedaluwarsa'])->default('menunggu');
            $table->timestamp('responded_at')->nullable();

            $table->unique(['report_id', 'driver_id'], 'uq_report_dispatches_report_driver');
            $table->index(['driver_id', 'sent_at'], 'idx_report_dispatches_driver_time');

            $table->foreign('report_id', 'fk_report_dispatches_report')
                ->references('id')->on('reports')
                ->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreign('driver_id', 'fk_report_dispatches_driver')
                ->references('id')->on('users')
                ->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreign('shift_id', 'fk_report_dispatches_shift')
                ->references('id')->on('driver_shifts')
                ->cascadeOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('report_dispatches');
    }
};
