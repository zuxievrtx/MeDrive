<?php

namespace App\Policies;

use App\Models\User;

/**
 * Akun driver dan pelapor yang dikelola admin; akun admin lain tidak bisa diubah dari dashboard.
 */
class UserPolicy extends AdminPolicy
{
    public function viewAny(User $user): bool
    {
        return true;
    }

    public function view(User $user, User $subject): bool
    {
        return ! $subject->isAdmin();
    }

    public function create(User $user): bool
    {
        return true;
    }

    public function update(User $user, User $subject): bool
    {
        return ! $subject->isAdmin();
    }

    public function toggleStatus(User $user, User $subject): bool
    {
        return ! $subject->isAdmin();
    }
}
