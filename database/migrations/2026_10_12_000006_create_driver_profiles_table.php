<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * B3. driver_profiles — data kepegawaian & SIM driver (1:1 dengan users role driver)
 * Instansi driver = clinics.institution_id (tidak disimpan ulang agar tetap 3NF)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('driver_profiles', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('clinic_id');
            $table->string('employee_number', 30)->nullable()->comment('Nomor pegawai di instansi');
            $table->string('license_number', 30)->comment('Nomor SIM');
            $table->enum('license_class', ['A', 'A_umum', 'B1', 'B1_umum', 'B2', 'B2_umum']);
            $table->date('license_expires_at');
            $table->string('photo_path', 255)->nullable()->comment('Foto driver, ditampilkan ke pelapor');
            $table->boolean('is_on_duty')->default(false)->comment('Sedang menangani laporan');
            $table->unsignedBigInteger('created_by')->nullable()->comment('Admin yang mendaftarkan');
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();

            $table->unique('user_id', 'uq_driver_profiles_user');
            $table->unique(['clinic_id', 'employee_number'], 'uq_driver_profiles_employee');

            $table->foreign('user_id', 'fk_driver_profiles_user')
                ->references('id')->on('users')
                ->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreign('clinic_id', 'fk_driver_profiles_clinic')
                ->references('id')->on('clinics')
                ->restrictOnDelete()->cascadeOnUpdate();
            $table->foreign('created_by', 'fk_driver_profiles_creator')
                ->references('id')->on('users')
                ->nullOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('driver_profiles');
    }
};
