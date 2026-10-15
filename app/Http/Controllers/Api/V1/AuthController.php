<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\ChangePasswordRequest;
use App\Http\Requests\Api\V1\LoginRequest;
use App\Http\Requests\Api\V1\RegisterDeviceRequest;
use App\Http\Requests\Api\V1\RegisterRequest;
use App\Http\Resources\DeviceResource;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Services\MobileAuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * @group Autentikasi
 */
class AuthController extends ApiController
{
    public function __construct(private MobileAuthService $auth) {}

    /**
     * Daftar akun pelapor
     *
     * Role selalu pelapor; driver hanya didaftarkan admin. Mengembalikan token Sanctum (ability reporter).
     *
     * @unauthenticated
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $result = $this->auth->registerReporter($request->safe()->except('device_name'), $request->validated('device_name'));

        return $this->created($this->tokenPayload($result['user'], $result['token']));
    }

    /**
     * Masuk (pelapor / driver)
     *
     * Akun admin ditolak (admin_use_dashboard). Token membawa ability sesuai role: reporter atau driver.
     *
     * @unauthenticated
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->auth->login($request->validated('email'), $request->validated('password'), $request->validated('device_name'));

        return $this->ok($this->tokenPayload($result['user'], $result['token']));
    }

    /**
     * Keluar (mencabut token yang dipakai)
     */
    public function logout(Request $request): JsonResponse
    {
        $this->auth->logout($request->user());

        return $this->noContent();
    }

    /**
     * Daftarkan / perbarui token FCM perangkat
     */
    public function registerDevice(RegisterDeviceRequest $request): JsonResponse
    {
        return $this->ok(DeviceResource::make($this->auth->registerDevice($request->user(), $request->validated())));
    }

    /**
     * Ganti password
     *
     * Wajib saat must_change_password = true. Token lain milik akun dicabut.
     */
    public function changePassword(ChangePasswordRequest $request): JsonResponse
    {
        $this->auth->changePassword($request->user(), $request->validated('password'));

        return $this->ok(['message' => 'Password berhasil diganti.', 'must_change_password' => false]);
    }

    /**
     * Profil akun yang sedang masuk
     */
    public function me(Request $request): JsonResponse
    {
        return $this->ok(UserResource::make($this->loadProfile($request->user())));
    }

    /**
     * @return array<string, mixed>
     */
    private function tokenPayload(User $user, string $token): array
    {
        return [
            'token' => $token,
            'token_type' => 'Bearer',
            'must_change_password' => (bool) $user->must_change_password,
            'user' => UserResource::make($this->loadProfile($user))->resolve(request()),
        ];
    }

    private function loadProfile(User $user): User
    {
        if ($user->isDriver()) {
            $user->loadMissing(['driverProfile.clinic.institution', 'openShift.ambulance.ambulanceType']);
        }

        return $user;
    }
}
