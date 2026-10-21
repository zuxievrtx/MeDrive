<?php

namespace App\Jobs;

use App\Models\UserDevice;
use App\Services\FcmService;
use Illuminate\Contracts\Queue\ShouldBeEncrypted;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

/**
 * Payload dienkripsi di tabel jobs/failed_jobs karena cuplikan chat ikut di isi notifikasi.
 */
class SendFcmNotification implements ShouldBeEncrypted, ShouldQueue
{
    use Queueable;

    public int $tries = 3;

    /**
     * @param  array<string, scalar|null>  $data
     */
    public function __construct(
        public int $userId,
        public string $title,
        public string $body,
        public array $data = [],
    ) {}

    /**
     * @return list<int>
     */
    public function backoff(): array
    {
        return [5, 30];
    }

    public function handle(FcmService $fcm): void
    {
        UserDevice::query()
            ->where('user_id', $this->userId)
            ->pluck('fcm_token')
            ->each(fn (string $token) => $fcm->sendToToken($token, $this->title, $this->body, $this->data));
    }
}
