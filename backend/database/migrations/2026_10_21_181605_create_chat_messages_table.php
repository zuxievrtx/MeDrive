<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Whitelist fase 3: chat pelapor ↔ driver per laporan. Room chat = laporan itu sendiri.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('chat_messages', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('report_id');
            $table->unsignedBigInteger('sender_id');
            $table->enum('type', ['text', 'image'])->default('text');
            $table->string('body', 1000)->nullable()->comment('Teks pesan (wajib bila type=text)');
            $table->string('file_path', 255)->nullable()->comment('Gambar (wajib bila type=image)');
            $table->string('mime_type', 50)->nullable();
            $table->unsignedInteger('size_kb')->nullable();
            $table->timestamp('read_at')->nullable()->comment('Waktu dibaca penerima');
            $table->timestamp('created_at')->useCurrent();

            $table->index(['report_id', 'created_at'], 'idx_chat_report_time');
            $table->index(['report_id', 'sender_id', 'read_at'], 'idx_chat_unread');

            $table->foreign('report_id', 'fk_chat_report')
                ->references('id')->on('reports')
                ->cascadeOnDelete()->cascadeOnUpdate();
            $table->foreign('sender_id', 'fk_chat_sender')
                ->references('id')->on('users')
                ->restrictOnDelete()->cascadeOnUpdate();
        });

        if (in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
            DB::statement(<<<'SQL'
                ALTER TABLE chat_messages
                    ADD CONSTRAINT chk_chat_type CHECK (
                        (type = 'text' AND body IS NOT NULL) OR
                        (type = 'image' AND file_path IS NOT NULL)
                    )
                SQL);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('chat_messages');
    }
};
