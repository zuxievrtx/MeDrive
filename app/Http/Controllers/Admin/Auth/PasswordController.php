<?php

namespace App\Http\Controllers\Admin\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\UpdatePasswordRequest;
use App\Services\AdminLogger;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class PasswordController extends Controller
{
    public function edit(Request $request): View
    {
        return view('admin.auth.password', ['isForced' => $request->user()->must_change_password]);
    }

    public function update(UpdatePasswordRequest $request, AdminLogger $logger): RedirectResponse
    {
        $user = $request->user();

        $user->forceFill([
            'password' => $request->validated('password'),
            'must_change_password' => false,
        ])->save();

        $logger->log('admin.password_changed', $user, 'Mengganti password akun sendiri');

        return redirect()->route('admin.dashboard')->with('success', 'Password berhasil diganti.');
    }
}
