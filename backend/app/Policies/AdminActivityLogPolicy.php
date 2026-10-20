<?php

namespace App\Policies;

use App\Models\User;

class AdminActivityLogPolicy extends AdminPolicy
{
    public function viewAny(User $user): bool
    {
        return true;
    }
}
