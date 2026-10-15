<?php

namespace App\Services;

use App\Jobs\SendFcmNotification;
use App\Models\UserDevice;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

/**
 * Push notification lewat FCM HTTP v1. Semua pengiriman masuk antrean (SendFcmNotification).
 * Tanpa kredensial service account, layanan berjalan dalam mode log-only agar demo tetap jalan.
 */
class FcmService
{
    private const SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';

    private const TOKEN_URL = 'https://oauth2.googleapis.com/token';

    public function isConfigured(): bool
    {
        return filled(config('medrive.fcm.project_id'))
            && filled(config('medrive.fcm.client_email'))
            && filled(config('medrive.fcm.private_key'));
    }

    /**
     * Antrekan notifikasi ke semua perangkat milik user.
     *
     * @param  array<string, scalar|null>  $data
     */
    public function queueForUser(int $userId, string $title, string $body, array $data = []): void
    {
        SendFcmNotification::dispatch($userId, $title, $body, $data);
    }

    /**
     * Kirim satu pesan ke satu token. Token yang sudah tidak terdaftar di FCM dihapus dari user_devices.
     *
     * @param  array<string, scalar|null>  $data
     */
    public function sendToToken(string $token, string $title, string $body, array $data = []): void
    {
        // FCM hanya menerima nilai data bertipe string.
        $data = array_map(fn ($value): string => (string) $value, array_filter($data, fn ($value) => $value !== null));

        if (! $this->isConfigured()) {
            Log::info('[FCM log-only] notifikasi tidak dikirim karena kredensial kosong', [
                'token' => substr($token, 0, 12).'...',
                'title' => $title,
                'body' => $body,
                'data' => $data,
            ]);

            return;
        }

        $response = Http::withToken($this->accessToken())
            ->timeout(10)
            ->post(sprintf('https://fcm.googleapis.com/v1/projects/%s/messages:send', config('medrive.fcm.project_id')), [
                'message' => [
                    'token' => $token,
                    'notification' => ['title' => $title, 'body' => $body],
                    'data' => $data,
                    'android' => ['priority' => 'high'],
                    'apns' => ['headers' => ['apns-priority' => '10']],
                ],
            ]);

        if ($response->successful()) {
            return;
        }

        $errorCode = $response->json('error.details.0.errorCode') ?? $response->json('error.status');

        if (in_array($errorCode, ['UNREGISTERED', 'INVALID_ARGUMENT'], true) && in_array($response->status(), [400, 404], true)) {
            UserDevice::query()->where('fcm_token', $token)->delete();
            Log::notice('Token FCM tidak valid, perangkat dihapus', ['error' => $errorCode]);

            return;
        }

        // Error sementara (5xx/429) dilempar agar job dicoba ulang oleh queue worker.
        throw new RuntimeException('FCM gagal: HTTP '.$response->status().' '.$errorCode);
    }

    /**
     * Access token OAuth2 dari JWT service account (RS256), disimpan di cache hampir satu jam.
     */
    private function accessToken(): string
    {
        return Cache::remember('fcm:access_token', 3300, function (): string {
            $now = time();
            $header = $this->base64Url(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
            $claims = $this->base64Url(json_encode([
                'iss' => config('medrive.fcm.client_email'),
                'scope' => self::SCOPE,
                'aud' => self::TOKEN_URL,
                'iat' => $now,
                'exp' => $now + 3600,
            ]));

            $privateKey = str_replace('\n', "\n", (string) config('medrive.fcm.private_key'));
            $signature = '';

            if (! openssl_sign($header.'.'.$claims, $signature, $privateKey, OPENSSL_ALGO_SHA256)) {
                throw new RuntimeException('FCM_PRIVATE_KEY tidak valid.');
            }

            $response = Http::asForm()->timeout(10)->post(self::TOKEN_URL, [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $header.'.'.$claims.'.'.$this->base64Url($signature),
            ])->throw();

            return (string) $response->json('access_token');
        });
    }

    private function base64Url(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }
}
