<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsurePasswordIsChanged
{
    /**
     * Akun dengan must_change_password wajib mengganti password sebelum membuka halaman lain.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()?->must_change_password) {
            if ($request->expectsJson()) {
                abort(423, 'Ganti password terlebih dahulu.');
            }

            return redirect()->route('admin.password.edit');
        }

        return $next($request);
    }
}
