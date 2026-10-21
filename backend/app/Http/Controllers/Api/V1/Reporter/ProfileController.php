<?php

namespace App\Http\Controllers\Api\V1\Reporter;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\Reporter\UpdateProfileRequest;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;

/**
 * @group Pelapor
 */
class ProfileController extends ApiController
{
    /**
     * Ubah profil pelapor
     *
     * Hanya nama dan telepon. Email dan role tidak bisa diubah lewat endpoint ini.
     */
    public function __invoke(UpdateProfileRequest $request): JsonResponse
    {
        $user = $request->user();
        $user->update([
            'name' => trim($request->validated('name')),
            'phone' => preg_replace('/\s+/', ' ', trim($request->validated('phone'))),
        ]);

        return $this->ok(UserResource::make($user));
    }
}
