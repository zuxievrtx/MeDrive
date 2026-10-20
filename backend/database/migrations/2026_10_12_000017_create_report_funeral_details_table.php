<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * C7. report_funeral_details — khusus jenis "pengantaran jenazah" (1:1, bisa dijadwalkan)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('report_funeral_details', function (Blueprint $table) {
            $table->unsignedBigInteger('report_id')->primary();
            $table->string('deceased_name', 100);
            $table->enum('pickup_place_type', ['rumah_sakit', 'rumah_duka', 'lainnya']);
            $table->timestamp('scheduled_pickup_at')->nullable()->comment('NULL = segera');
            $table->boolean('has_death_certificate')->default(false);
            $table->string('family_contact_name', 100);
            $table->string('family_contact_phone', 20);

            $table->foreign('report_id', 'fk_report_funeral_details_report')
                ->references('id')->on('reports')
                ->cascadeOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('report_funeral_details');
    }
};
