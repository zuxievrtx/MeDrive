<?php

namespace App\Http\Middleware;

use App\Exceptions\ApiErrorResponse;
use App\Exceptions\ApiException;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserHasRole
{
    /**
     * Hanya akun aktif dengan peran yang diminta yang boleh lewat (web dan API).
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();
        $isApi = ApiErrorResponse::isApiRequest($request);

        if (! $user || ! in_array($user->role->value, $roles, true)) {
            if ($isApi) {
                throw ApiException::forbidden('role_forbidden', 'Endpoint ini tidak tersedia untuk peran akun Anda.');
            }

            abort(403, 'Halaman ini khusus admin pusat.');
        }

        if (! $user->isActive()) {
            if ($isApi) {
                $user->currentAccessToken()?->delete();

                throw ApiException::forbidden('account_inactive', 'Akun Anda sudah dinonaktifkan. Hubungi admin pusat.');
            }

            Auth::guard('web')->logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            return redirect()->route('admin.login')->withErrors(['email' => 'Akun Anda sudah dinonaktifkan.']);
        }

        return $next($request);
    }
}
