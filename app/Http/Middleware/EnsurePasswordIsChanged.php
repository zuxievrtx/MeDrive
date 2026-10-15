<?php

namespace App\Http\Middleware;

use App\Exceptions\ApiErrorResponse;
use App\Exceptions\ApiException;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsurePasswordIsChanged
{
    /**
     * Akun dengan must_change_password wajib mengganti password sebelum memakai fitur lain.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()?->must_change_password) {
            if (ApiErrorResponse::isApiRequest($request) || $request->expectsJson()) {
                throw new ApiException(
                    'password_change_required',
                    'Ganti password terlebih dahulu sebelum memakai fitur ini.',
                    403,
                    ['must_change_password' => true],
                );
            }

            return redirect()->route('admin.password.edit');
        }

        return $next($request);
    }
}
