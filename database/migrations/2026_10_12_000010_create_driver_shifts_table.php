<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * B7. driver_shifts — sesi kerja: driver X memakai ambulans Y dari jam A s.d. B
 * Shift terbuka (ended_at NULL) = driver berstatus "Aktif".
 * Kolom generated menjamin: 1 driver & 1 ambulans hanya punya 1 shift terbuka.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('driver_shifts', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('driver_id');
            $table->unsignedBigInteger('ambulance_id');
            $table->timestamp('started_at')->useCurrent();
            $table->timestamp('ended_at')->nullable();
            $table->enum('end_reason', ['selesai_shift', 'otomatis', 'dihentikan_admin'])->nullable();
            $table->unsignedBigInteger('open_driver_id')->storedAs('IF(ended_at IS NULL, driver_id, NULL)');
            $table->unsignedBigInteger('open_ambulance_id')->storedAs('IF(ended_at IS NULL, ambulance_id, NULL)');

            $table->unique('open_driver_id', 'uq_driver_shifts_open_driver');
            $table->unique('open_ambulance_id', 'uq_driver_shifts_open_ambulance');
            $table->index(['driver_id', 'started_at'], 'idx_driver_shifts_driver_time');
            $table->index(['ambulance_id', 'started_at'], 'idx_driver_shifts_ambulance_time');

            // base column generated tidak boleh memakai CASCADE/SET NULL (aturan MySQL)
            $table->foreign('driver_id', 'fk_driver_shifts_driver')
                ->references('id')->on('users')
                ->restrictOnDelete()->restrictOnUpdate();
            $table->foreign('ambulance_id', 'fk_driver_shifts_ambulance')
                ->references('id')->on('ambulances')
                ->restrictOnDelete()->restrictOnUpdate();
        });

        if (in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
            DB::statement(<<<'SQL'
                ALTER TABLE driver_shifts
                    ADD CONSTRAINT chk_driver_shifts_end CHECK (
                        (ended_at IS NULL AND end_reason IS NULL) OR
                        (ended_at IS NOT NULL AND end_reason IS NOT NULL AND ended_at >= started_at)
                    )
                SQL);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('driver_shifts');
    }
};
