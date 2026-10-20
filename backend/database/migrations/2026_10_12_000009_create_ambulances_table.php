<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * B6. ambulances — armada kendaraan milik klinik
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ambulances', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('clinic_id');
            $table->unsignedBigInteger('ambulance_type_id');
            $table->string('plate_number', 15)->unique('uq_ambulances_plate');
            $table->string('vehicle_name', 100)->nullable()->comment('Merek & model, mis. Toyota HiAce');
            $table->unsignedSmallInteger('year')->nullable();
            $table->enum('status', ['tersedia', 'perawatan', 'nonaktif'])->default('tersedia');
            $table->string('notes', 255)->nullable();
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();

            $table->index(['clinic_id', 'status'], 'idx_ambulances_clinic_status');

            $table->foreign('clinic_id', 'fk_ambulances_clinic')
                ->references('id')->on('clinics')
                ->restrictOnDelete()->cascadeOnUpdate();
            $table->foreign('ambulance_type_id', 'fk_ambulances_type')
                ->references('id')->on('ambulance_types')
                ->restrictOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ambulances');
    }
};
