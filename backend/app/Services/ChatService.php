<?php

namespace App\Services;

use App\Enums\ReportStatus;
use App\Events\ChatMessageRead;
use App\Events\ChatMessageSent;
use App\Exceptions\ApiException;
use App\Models\ChatMessage;
use App\Models\Report;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Chat pelapor ↔ driver per laporan. Peserta hanya pelapor pemilik dan driver yang ditugaskan;
 * admin sengaja tidak punya jalur baca apa pun (endpoint, kanal, media, maupun log).
 */
class ChatService
{
    public function __construct(private FcmService $fcm) {}

    public function isParticipant(User $user, Report $report): bool
    {
        return $user->isActive()
            && ($report->reporter_id === $user->id || ($report->driver_id !== null && $report->driver_id === $user->id));
    }

    public function ensureParticipant(User $user, Report $report): void
    {
        if (! $this->isParticipant($user, $report)) {
            throw ApiException::forbidden('chat_forbidden', 'Anda bukan peserta chat laporan ini.');
        }
    }

    /**
     * Riwayat urut lama → baru. before_id memuat halaman yang lebih lama (scroll ke atas).
     *
     * @return array{messages: Collection<int, ChatMessage>, has_more: bool}
     */
    public function history(Report $report, ?int $beforeId = null): array
    {
        $perPage = (int) config('medrive.chat.per_page');

        $page = ChatMessage::query()
            ->where('report_id', $report->id)
            ->when($beforeId, fn (Builder $query, int $id) => $query->where('id', '<', $id))
            ->with('sender:id,name')
            ->orderByDesc('id')
            ->limit($perPage + 1)
            ->get();

        return [
            'messages' => $page->take($perPage)->reverse()->values(),
            'has_more' => $page->count() > $perPage,
        ];
    }

    /**
     * @param  array{type: string, body?: ?string}  $data
     */
    public function send(User $sender, Report $report, array $data, ?UploadedFile $image = null): ChatMessage
    {
        $this->ensureParticipant($sender, $report);
        $this->ensureOpen($report);

        $attributes = ['report_id' => $report->id, 'sender_id' => $sender->id, 'type' => $data['type']];

        if ($data['type'] === ChatMessage::TYPE_IMAGE) {
            $attributes += [
                'file_path' => $image->store('chat/'.$report->id, 'local'),
                'mime_type' => $image->getMimeType(),
                'size_kb' => (int) ceil($image->getSize() / 1024),
            ];
        } else {
            $attributes['body'] = trim((string) $data['body']);
        }

        $message = ChatMessage::query()->create($attributes)->refresh()->setRelation('sender', $sender);

        ChatMessageSent::dispatch($message);
        $this->notifyCounterpart($sender, $report, $message);

        return $message;
    }

    /**
     * Tandai semua pesan dari lawan bicara sebagai dibaca. Tetap boleh setelah laporan selesai.
     */
    public function markRead(User $reader, Report $report): int
    {
        $this->ensureParticipant($reader, $report);

        $unread = ChatMessage::query()
            ->where('report_id', $report->id)
            ->where('sender_id', '!=', $reader->id)
            ->whereNull('read_at');

        $lastId = (clone $unread)->max('id');

        if ($lastId === null) {
            return 0;
        }

        $readAt = now();
        $count = $unread->where('id', '<=', $lastId)->update(['read_at' => $readAt]);

        ChatMessageRead::dispatch($report->id, $reader->id, (int) $lastId, $readAt->toIso8601String());

        return $count;
    }

    /**
     * Jumlah pesan belum dibaca per laporan untuk badge aplikasi.
     *
     * @return array{total: int, reports: list<array{report_id: int, code: string, count: int}>}
     */
    public function unreadCount(User $user): array
    {
        $rows = DB::table('chat_messages')
            ->join('reports', 'reports.id', '=', 'chat_messages.report_id')
            ->where(fn ($query) => $query->where('reports.reporter_id', $user->id)->orWhere('reports.driver_id', $user->id))
            ->where('chat_messages.sender_id', '!=', $user->id)
            ->whereNull('chat_messages.read_at')
            ->groupBy('reports.id', 'reports.code')
            ->orderByDesc('reports.id')
            ->get(['reports.id as report_id', 'reports.code', DB::raw('COUNT(*) as count')])
            ->map(fn (object $row): array => ['report_id' => (int) $row->report_id, 'code' => $row->code, 'count' => (int) $row->count])
            ->values();

        return ['total' => (int) $rows->sum('count'), 'reports' => $rows->all()];
    }

    private function ensureOpen(Report $report): void
    {
        $status = Report::query()->whereKey($report->id)->value('status');
        $status = $status instanceof ReportStatus ? $status : ReportStatus::from($status);

        if (in_array($status, ReportStatus::active(), true)) {
            return;
        }

        $message = match ($status) {
            ReportStatus::Menunggu => 'Chat dibuka setelah driver mengambil laporan.',
            ReportStatus::Dibatalkan => 'Chat ditutup karena laporan sudah dibatalkan.',
            default => 'Chat ditutup karena laporan sudah selesai.',
        };

        throw ApiException::conflict('chat_closed', $message);
    }

    /**
     * Push ke lawan bicara. Isi teks dipotong; payload job dienkripsi (SendFcmNotification).
     */
    private function notifyCounterpart(User $sender, Report $report, ChatMessage $message): void
    {
        $recipientId = $sender->id === $report->reporter_id ? $report->driver_id : $report->reporter_id;

        if ($recipientId === null) {
            return;
        }

        $preview = $message->type === ChatMessage::TYPE_IMAGE
            ? 'Mengirim foto'
            : Str::limit((string) $message->body, (int) config('medrive.chat.push_preview_chars'));

        $this->fcm->queueForUser($recipientId, $sender->name, $preview, [
            'type' => 'chat',
            'report_id' => $report->id,
            'report_code' => $report->code,
            'message_id' => $message->id,
        ]);
    }
}
