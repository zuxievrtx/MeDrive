<?php

namespace App\Policies;

use App\Models\AmbulanceType;
use App\Models\User;

class AmbulanceTypePolicy extends AdminPolicy
{
    public function viewAny(User $user): bool
    {
        return true;
    }

    public function update(User $user, AmbulanceType $ambulanceType): bool
    {
        return true;
    }
}
