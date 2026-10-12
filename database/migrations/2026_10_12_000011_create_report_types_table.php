<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * C1. report_types — jenis layanan: kecelakaan, medis darurat, ibu hamil, pengantaran jenazah
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('report_types', function (Blueprint $table) {
            $table->id();
            $table->string('code', 30)->unique('uq_report_types_code');
            $table->string('name', 100);
            $table->string('description', 255)->nullable();
            $table->unsignedTinyInteger('priority')->comment('1 = paling mendesak');
            $table->boolean('is_emergency')->default(true)->comment('FALSE = boleh dijadwalkan');
            $table->boolean('requires_destination')->default(false)->comment('TRUE = wajib isi tujuan antar');
            $table->string('icon', 50)->nullable();
            $table->char('color', 7)->nullable()->comment('Hex, mis. #B5523B');
            $table->boolean('is_active')->default(true);
            $table->unsignedTinyInteger('sort_order')->default(0);
        });

        if (in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
            DB::statement(<<<'SQL'
                ALTER TABLE report_types
                    ADD CONSTRAINT chk_report_types_priority CHECK (priority BETWEEN 1 AND 5)
                SQL);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('report_types');
    }
};
