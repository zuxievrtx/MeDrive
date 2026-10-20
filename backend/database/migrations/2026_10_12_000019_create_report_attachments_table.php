<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * C9. report_attachments — foto & dokumen laporan
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('report_attachments', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('report_id');
            $table->unsignedBigInteger('uploaded_by');
            $table->enum('type', ['foto_kejadian', 'foto_penanganan', 'surat_kematian', 'lainnya']);
            $table->string('file_path', 255);
            $table->string('mime_type', 50);
            $table->unsignedInteger('size_kb');
            $table->timestamp('created_at')->useCurrent();

            $table->index('report_id', 'idx_report_attachments_report');

            $table->foreign('report_id', 'fk_report_attachments_report')
                ->references('id')->on('reports')
                ->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreign('uploaded_by', 'fk_report_attachments_user')
                ->references('id')->on('users')
                ->restrictOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('report_attachments');
    }
};
