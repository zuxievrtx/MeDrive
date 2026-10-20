<?php

namespace App\Policies;

use App\Models\User;

/**
 * Dasar policy dashboard: hanya admin aktif yang boleh; aturan bisnis per aksi ada di policy turunan.
 */
abstract class AdminPolicy
{
    public function before(User $user): ?bool
    {
        if (! $user->isAdmin() || ! $user->isActive()) {
            return false;
        }

        return null;
    }
}
