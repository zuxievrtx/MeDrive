<?php

namespace App\Exceptions;

use Illuminate\Http\JsonResponse;
use RuntimeException;

/**
 * Pelanggaran aturan bisnis yang dikembalikan ke klien dengan format error baku API.
 */
class ApiException extends RuntimeException
{
    /**
     * @param  array<string, mixed>  $details
     */
    public function __construct(
        public readonly string $errorCode,
        string $message,
        public readonly int $status = 422,
        public readonly array $details = [],
    ) {
        parent::__construct($message);
    }

    /**
     * @param  array<string, mixed>  $details
     */
    public static function conflict(string $code, string $message, array $details = []): self
    {
        return new self($code, $message, 409, $details);
    }

    /**
     * @param  array<string, mixed>  $details
     */
    public static function unprocessable(string $code, string $message, array $details = []): self
    {
        return new self($code, $message, 422, $details);
    }

    public static function forbidden(string $code, string $message): self
    {
        return new self($code, $message, 403);
    }

    public static function badRequest(string $code, string $message): self
    {
        return new self($code, $message, 400);
    }

    public function render(): JsonResponse
    {
        return ApiErrorResponse::make($this->errorCode, $this->getMessage(), $this->status, $this->details);
    }
}
