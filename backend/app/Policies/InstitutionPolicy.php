<?php

namespace App\Policies;

use App\Models\Institution;
use App\Models\User;

class InstitutionPolicy extends AdminPolicy
{
    public function viewAny(User $user): bool
    {
        return true;
    }

    public function create(User $user): bool
    {
        return true;
    }

    public function update(User $user, Institution $institution): bool
    {
        return true;
    }

    public function delete(User $user, Institution $institution): bool
    {
        return true;
    }
}
