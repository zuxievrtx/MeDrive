<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * A2. user_devices — perangkat & token FCM (1 user bisa punya beberapa HP)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_devices', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->string('fcm_token', 255)->unique('uq_user_devices_fcm_token');
            $table->enum('platform', ['android', 'ios', 'web'])->default('android');
            $table->string('device_model', 100)->nullable();
            $table->string('app_version', 20)->nullable();
            $table->timestamp('last_seen_at')->nullable();
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();

            $table->index('user_id', 'idx_user_devices_user');

            $table->foreign('user_id', 'fk_user_devices_user')
                ->references('id')->on('users')
                ->cascadeOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_devices');
    }
};
