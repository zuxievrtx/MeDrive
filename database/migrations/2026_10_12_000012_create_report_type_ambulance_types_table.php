<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * C2. report_type_ambulance_types — jenis ambulans yang boleh melayani tiap jenis laporan (M:N)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('report_type_ambulance_types', function (Blueprint $table) {
            $table->unsignedBigInteger('report_type_id');
            $table->unsignedBigInteger('ambulance_type_id');

            $table->primary(['report_type_id', 'ambulance_type_id']);

            $table->foreign('report_type_id', 'fk_rtat_report_type')
                ->references('id')->on('report_types')
                ->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreign('ambulance_type_id', 'fk_rtat_ambulance_type')
                ->references('id')->on('ambulance_types')
                ->cascadeOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('report_type_ambulance_types');
    }
};
