<?php

namespace App\Policies;

use App\Models\Ambulance;
use App\Models\User;

class AmbulancePolicy extends AdminPolicy
{
    public function viewAny(User $user): bool
    {
        return true;
    }

    public function create(User $user): bool
    {
        return true;
    }

    public function update(User $user, Ambulance $ambulance): bool
    {
        return true;
    }

    public function delete(User $user, Ambulance $ambulance): bool
    {
        return true;
    }
}
