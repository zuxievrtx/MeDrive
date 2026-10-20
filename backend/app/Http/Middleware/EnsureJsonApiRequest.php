<?php

namespace App\Http\Middleware;

use App\Exceptions\ApiException;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureJsonApiRequest
{
    /**
     * Semua endpoint /api/v1 wajib dipanggil dengan header Accept: application/json.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (! $request->wantsJson()) {
            throw ApiException::badRequest('accept_header_required', 'Sertakan header Accept: application/json pada setiap permintaan API.');
        }

        return $next($request);
    }
}
