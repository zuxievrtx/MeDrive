<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\ReportStatus;
use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\Chat\SendChatMessageRequest;
use App\Http\Resources\ChatMessageResource;
use App\Models\Report;
use App\Services\ChatService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Chat pelapor ↔ driver per laporan. Dipasang identik di grup /reporter dan /driver; admin tidak punya rute ini.
 *
 * @group Chat
 */
class ChatController extends ApiController
{
    public function __construct(private ChatService $chat) {}

    /**
     * Riwayat chat
     *
     * Urut lama → baru, 30 pesan per halaman. Kirim before_id = meta.cursor.next_before_id untuk memuat pesan yang lebih lama.
     *
     * @queryParam before_id integer ID pesan tertua yang sudah dimuat. Example: 120
     */
    public function index(Request $request, Report $report): JsonResponse
    {
        $this->chat->ensureParticipant($request->user(), $report);
        $beforeId = $request->validate(['before_id' => ['nullable', 'integer', 'min:1']])['before_id'] ?? null;

        ['messages' => $messages, 'has_more' => $hasMore] = $this->chat->history($report, $beforeId);

        return $this->ok(ChatMessageResource::collection($messages)->resolve($request), meta: [
            'cursor' => [
                'per_page' => (int) config('medrive.chat.per_page'),
                'has_more' => $hasMore,
                'next_before_id' => $hasMore ? $messages->first()?->id : null,
            ],
            'is_open' => in_array($report->status, ReportStatus::active(), true),
        ]);
    }

    /**
     * Kirim pesan
     *
     * Hanya selama laporan aktif (diambil sampai mengantar pasien); selain itu 409 chat_closed. Maksimal 30 pesan/menit.
     */
    public function store(SendChatMessageRequest $request, Report $report): JsonResponse
    {
        $message = $this->chat->send($request->user(), $report, $request->validated(), $request->file('image'));

        return $this->created(ChatMessageResource::make($message)->resolve($request));
    }

    /**
     * Tandai pesan lawan bicara sudah dibaca
     */
    public function read(Request $request, Report $report): JsonResponse
    {
        return $this->ok(['marked' => $this->chat->markRead($request->user(), $report)]);
    }

    /**
     * Jumlah pesan belum dibaca
     */
    public function unreadCount(Request $request): JsonResponse
    {
        return $this->ok($this->chat->unreadCount($request->user()));
    }
}
