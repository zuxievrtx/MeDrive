<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * A3. admin_activity_logs — jejak aksi admin di dashboard (audit)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('admin_activity_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('admin_id')->nullable();
            $table->string('action', 50)->comment('mis. driver.created, driver.deactivated, ambulance.updated');
            $table->string('subject_type', 50)->comment('Nama tabel objek, mis. users, ambulances');
            $table->unsignedBigInteger('subject_id');
            $table->string('description', 255)->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->index(['subject_type', 'subject_id'], 'idx_admin_activity_subject');
            $table->index(['admin_id', 'created_at'], 'idx_admin_activity_admin_time');

            $table->foreign('admin_id', 'fk_admin_activity_logs_admin')
                ->references('id')->on('users')
                ->nullOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('admin_activity_logs');
    }
};
