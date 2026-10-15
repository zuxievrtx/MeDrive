<?php

namespace App\Services;

use App\Enums\AccountStatus;
use App\Enums\UserRole;
use App\Exceptions\ApiException;
use App\Models\User;
use App\Models\UserDevice;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

/**
 * Autentikasi aplikasi mobile (Pelapor & Driver) memakai token Sanctum.
 * Admin tidak bisa mendapat token: dashboard memakai session web.
 */
class MobileAuthService
{
    /**
     * Ability token per peran, dicek middleware "abilities" di grup route.
     *
     * @var array<string, string>
     */
    private const ABILITIES = [
        'pelapor' => 'reporter',
        'driver' => 'driver',
    ];

    /**
     * Registrasi mandiri hanya untuk pelapor. Peran dipaksa di server, tidak dibaca dari request.
     *
     * @param  array{name: string, phone: string, email: string, password: string}  $data
     * @return array{user: User, token: string}
     */
    public function registerReporter(array $data, ?string $deviceName = null): array
    {
        $user = User::create([
            'name' => $data['name'],
            'phone' => $data['phone'],
            'email' => $data['email'],
            'password' => $data['password'],
            'role' => UserRole::Pelapor,
            'account_status' => AccountStatus::Aktif,
            'must_change_password' => false,
        ]);

        $user->forceFill(['last_login_at' => now()])->save();

        return ['user' => $user, 'token' => $this->issueToken($user, $deviceName)];
    }

    /**
     * @return array{user: User, token: string}
     */
    public function login(string $email, string $password, ?string $deviceName = null): array
    {
        $user = User::query()->where('email', mb_strtolower(trim($email)))->first();

        if (! $user || ! Hash::check($password, $user->password)) {
            throw new ApiException('invalid_credentials', 'Email atau password salah.', 401);
        }

        if ($user->isAdmin()) {
            throw ApiException::forbidden('admin_use_dashboard', 'Akun admin hanya bisa masuk lewat dashboard web.');
        }

        if (! $user->isActive()) {
            throw ApiException::forbidden('account_inactive', 'Akun Anda sudah dinonaktifkan. Hubungi admin pusat.');
        }

        $user->forceFill(['last_login_at' => now()])->save();

        return ['user' => $user, 'token' => $this->issueToken($user, $deviceName)];
    }

    /**
     * Daftarkan/perbarui perangkat FCM. Token FCM unik global: bila pindah akun, perangkat dipindahkan.
     *
     * @param  array{fcm_token: string, platform: string, device_model?: ?string, app_version?: ?string}  $data
     */
    public function registerDevice(User $user, array $data): UserDevice
    {
        return UserDevice::query()->updateOrCreate(
            ['fcm_token' => $data['fcm_token']],
            [
                'user_id' => $user->id,
                'platform' => $data['platform'],
                'device_model' => $data['device_model'] ?? null,
                'app_version' => $data['app_version'] ?? null,
                'last_seen_at' => now(),
            ],
        );
    }

    /**
     * Ganti password, matikan flag wajib-ganti, dan cabut token lain selain token yang sedang dipakai.
     */
    public function changePassword(User $user, string $newPassword): void
    {
        DB::transaction(function () use ($user, $newPassword): void {
            $user->forceFill(['password' => $newPassword, 'must_change_password' => false])->save();

            $currentTokenId = $user->currentAccessToken()?->getKey();
            $user->tokens()->when($currentTokenId, fn ($query) => $query->whereKeyNot($currentTokenId))->delete();
        });
    }

    public function logout(User $user): void
    {
        $user->currentAccessToken()?->delete();
    }

    private function issueToken(User $user, ?string $deviceName): string
    {
        $ability = self::ABILITIES[$user->role->value];

        return $user->createToken($deviceName ?: 'mobile-'.$ability, [$ability])->plainTextToken;
    }
}
