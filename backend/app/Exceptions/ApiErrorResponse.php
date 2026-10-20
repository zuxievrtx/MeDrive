<?php

namespace App\Exceptions;

use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Session\TokenMismatchException;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
use Throwable;

/**
 * Menerjemahkan exception menjadi format error baku API:
 * { "success": false, "error": { "code", "message", "details" } }.
 */
class ApiErrorResponse
{
    /**
     * @param  array<string, mixed>  $details
     */
    public static function make(string $code, string $message, int $status, array $details = []): JsonResponse
    {
        $error = ['code' => $code, 'message' => $message];

        if ($details !== []) {
            $error['details'] = $details;
        }

        return response()->json(['success' => false, 'error' => $error], $status);
    }

    public static function isApiRequest(Request $request): bool
    {
        return $request->is('api/*');
    }

    public static function render(Throwable $exception, Request $request): ?JsonResponse
    {
        if (! self::isApiRequest($request)) {
            return null;
        }

        return match (true) {
            $exception instanceof ApiException => $exception->render(),
            $exception instanceof ValidationException => self::make('validation_failed', 'Data tidak valid.', 400, $exception->errors()),
            $exception instanceof AuthenticationException => self::make('unauthenticated', 'Silakan masuk terlebih dahulu.', 401),
            $exception instanceof AuthorizationException => self::make('forbidden', $exception->getMessage() !== 'This action is unauthorized.' ? $exception->getMessage() : 'Anda tidak berhak melakukan aksi ini.', 403),
            $exception instanceof ModelNotFoundException => self::make('not_found', 'Data tidak ditemukan.', 404),
            $exception instanceof TokenMismatchException => self::make('csrf_mismatch', 'Sesi kedaluwarsa. Muat ulang halaman lalu coba lagi.', 419),
            $exception instanceof HttpExceptionInterface => self::fromHttpException($exception),
            default => self::make(
                'server_error',
                'Terjadi kesalahan pada server. Coba lagi beberapa saat lagi.',
                500,
                config('app.debug') ? ['exception' => $exception::class, 'detail' => $exception->getMessage()] : [],
            ),
        };
    }

    private static function fromHttpException(HttpExceptionInterface $exception): JsonResponse
    {
        $status = $exception->getStatusCode();

        [$code, $default] = match ($status) {
            400 => ['bad_request', 'Permintaan tidak valid.'],
            401 => ['unauthenticated', 'Silakan masuk terlebih dahulu.'],
            403 => ['forbidden', 'Anda tidak berhak mengakses data ini.'],
            404 => ['not_found', 'Data tidak ditemukan.'],
            405 => ['method_not_allowed', 'Metode HTTP tidak didukung untuk endpoint ini.'],
            409 => ['conflict', 'Permintaan bertentangan dengan kondisi data saat ini.'],
            419 => ['csrf_mismatch', 'Sesi kedaluwarsa. Muat ulang halaman lalu coba lagi.'],
            429 => ['too_many_requests', 'Terlalu banyak permintaan. Coba lagi sebentar lagi.'],
            default => ['http_error', 'Permintaan tidak dapat diproses.'],
        };

        $message = $exception->getMessage();
        // Pesan bawaan Symfony berbahasa Inggris; pakai pesan Indonesia kecuali pesan sudah diset aplikasi.
        $isFrameworkMessage = $message === '' || preg_match('/^(No query results|The route|Too Many Attempts|Unauthorized|This action|Not Found|Forbidden)/i', $message);

        $response = self::make($code, $isFrameworkMessage ? $default : $message, $status);

        foreach ($exception->getHeaders() as $name => $value) {
            $response->headers->set($name, $value);
        }

        return $response;
    }
}
