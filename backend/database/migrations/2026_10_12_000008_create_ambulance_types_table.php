<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * B5. ambulance_types — jenis ambulans (gawat darurat, transport, jenazah)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ambulance_types', function (Blueprint $table) {
            $table->id();
            $table->string('code', 30)->unique('uq_ambulance_types_code');
            $table->string('name', 100);
            $table->string('description', 255)->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ambulance_types');
    }
};
