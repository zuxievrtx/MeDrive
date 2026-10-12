<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * A1. users — akun semua pengguna (pelapor, driver, admin)
 * Menggantikan migration bawaan 0001_01_01_000000_create_users_table.php
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name', 100);
            $table->string('phone', 20);
            $table->string('email', 100)->unique('uq_users_email');
            $table->string('password', 255)->comment('Hash bcrypt');
            $table->enum('role', ['pelapor', 'driver', 'admin'])->default('pelapor');
            $table->enum('account_status', ['aktif', 'nonaktif'])->default('aktif');
            $table->boolean('must_change_password')->default(false);
            $table->timestamp('last_login_at')->nullable();
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();

            $table->index(['role', 'account_status'], 'idx_users_role_status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
