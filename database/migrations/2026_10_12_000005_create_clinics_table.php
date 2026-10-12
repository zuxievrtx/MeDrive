<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * B2. clinics — klinik / puskesmas / RS / pos ambulans (pangkalan driver & armada)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('clinics', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('institution_id');
            $table->string('code', 20)->unique('uq_clinics_code');
            $table->string('name', 150);
            $table->enum('type', ['klinik', 'puskesmas', 'rumah_sakit', 'pos_ambulans']);
            $table->string('phone', 20)->nullable();
            $table->string('address', 255);
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->boolean('is_active')->default(true);
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();

            $table->index('institution_id', 'idx_clinics_institution');

            $table->foreign('institution_id', 'fk_clinics_institution')
                ->references('id')->on('institutions')
                ->restrictOnDelete()->cascadeOnUpdate();
        });

        if (in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
            DB::statement(<<<'SQL'
                ALTER TABLE clinics
                    ADD CONSTRAINT chk_clinics_lat CHECK (latitude  BETWEEN -90  AND 90),
                    ADD CONSTRAINT chk_clinics_lng CHECK (longitude BETWEEN -180 AND 180)
                SQL);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('clinics');
    }
};
