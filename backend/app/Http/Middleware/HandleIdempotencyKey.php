<?php

namespace App\Http\Middleware;

use App\Exceptions\ApiException;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Symfony\Component\HttpFoundation\Response;

/**
 * Header Idempotency-Key (opsional): respons pertama disimpan 24 jam dan dikirim ulang apa adanya
 * bila klien Flutter mengulang permintaan yang sama karena jaringan putus.
 */
class HandleIdempotencyKey
{
    private const TTL_SECONDS = 86400;

    public function handle(Request $request, Closure $next): Response
    {
        $key = $request->header('Idempotency-Key');

        if ($key === null || $key === '') {
            return $next($request);
        }

        if (strlen($key) > 100 || ! preg_match('/^[A-Za-z0-9._:\-]+$/', $key)) {
            throw ApiException::badRequest('invalid_idempotency_key', 'Idempotency-Key maksimal 100 karakter dan hanya huruf, angka, titik, titik dua, garis bawah, atau tanda hubung.');
        }

        $cacheKey = 'idempotency:'.$request->user()?->getKey().':'.$request->method().':'.$request->path().':'.hash('sha256', $key);
        $fingerprint = hash('sha256', json_encode($request->except(['_token'])) ?: '');

        if ($stored = Cache::get($cacheKey)) {
            return $this->replay($stored, $fingerprint);
        }

        $lock = Cache::lock($cacheKey.':lock', 30);

        if (! $lock->get()) {
            throw ApiException::conflict('idempotency_in_progress', 'Permintaan dengan Idempotency-Key yang sama masih diproses.');
        }

        try {
            if ($stored = Cache::get($cacheKey)) {
                return $this->replay($stored, $fingerprint);
            }

            $response = $next($request);

            if ($response->getStatusCode() < 500) {
                Cache::put($cacheKey, [
                    'fingerprint' => $fingerprint,
                    'status' => $response->getStatusCode(),
                    'body' => $response->getContent(),
                    'content_type' => $response->headers->get('Content-Type'),
                ], self::TTL_SECONDS);
            }

            return $response;
        } finally {
            $lock->release();
        }
    }

    /**
     * @param  array{fingerprint: string, status: int, body: string, content_type: ?string}  $stored
     */
    private function replay(array $stored, string $fingerprint): Response
    {
        if (! hash_equals($stored['fingerprint'], $fingerprint)) {
            throw ApiException::unprocessable('idempotency_key_reused', 'Idempotency-Key ini sudah dipakai untuk data yang berbeda.');
        }

        return response($stored['body'], $stored['status'], [
            'Content-Type' => $stored['content_type'] ?? 'application/json',
            'Idempotent-Replayed' => 'true',
        ]);
    }
}
