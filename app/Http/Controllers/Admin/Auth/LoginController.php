<?php

namespace App\Http\Controllers\Admin\Auth;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\LoginRequest;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

class LoginController extends Controller
{
    public function create(): View
    {
        return view('admin.auth.login');
    }

    /**
     * Hanya role admin dengan akun aktif yang boleh masuk; percobaan dibatasi throttle admin-login.
     */
    public function store(LoginRequest $request): RedirectResponse
    {
        $user = User::query()->where('email', $request->string('email'))->first();

        if (! $user || ! Hash::check($request->string('password'), $user->password)) {
            throw ValidationException::withMessages(['email' => 'Email atau password salah.']);
        }

        if ($user->role !== UserRole::Admin) {
            throw ValidationException::withMessages([
                'email' => 'Akun ini bukan akun admin. Driver dan pelapor masuk lewat aplikasi mobile.',
            ]);
        }

        if (! $user->isActive()) {
            throw ValidationException::withMessages(['email' => 'Akun admin ini sedang nonaktif. Hubungi admin pusat lain.']);
        }

        Auth::login($user);
        $request->session()->regenerate();

        $user->forceFill(['last_login_at' => now()])->save();

        if ($user->must_change_password) {
            return redirect()->route('admin.password.edit');
        }

        return redirect()->intended(route('admin.dashboard'));
    }

    public function destroy(Request $request): RedirectResponse
    {
        Auth::guard('web')->logout();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.login');
    }
}
