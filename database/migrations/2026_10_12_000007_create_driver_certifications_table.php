<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * B4. driver_certifications — sertifikat pelatihan driver (BTCLS, PPGD, BHD, dsb.)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('driver_certifications', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('driver_id');
            $table->string('name', 100);
            $table->string('certificate_number', 50)->nullable();
            $table->string('issuer', 150)->nullable();
            $table->date('issued_at');
            $table->date('expires_at')->nullable();
            $table->string('file_path', 255)->nullable();
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();

            $table->index('driver_id', 'idx_driver_certifications_driver');
            $table->index('expires_at', 'idx_driver_certifications_expiry');

            $table->foreign('driver_id', 'fk_driver_certifications_driver')
                ->references('id')->on('users')
                ->cascadeOnDelete()->cascadeOnUpdate();
        });

        if (in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
            DB::statement(<<<'SQL'
                ALTER TABLE driver_certifications
                    ADD CONSTRAINT chk_driver_cert_dates CHECK (expires_at IS NULL OR expires_at > issued_at)
                SQL);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('driver_certifications');
    }
};
