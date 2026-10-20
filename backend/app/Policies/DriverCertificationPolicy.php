<?php

namespace App\Policies;

use App\Models\DriverCertification;
use App\Models\User;

class DriverCertificationPolicy extends AdminPolicy
{
    public function create(User $user): bool
    {
        return true;
    }

    public function update(User $user, DriverCertification $driverCertification): bool
    {
        return true;
    }

    public function delete(User $user, DriverCertification $driverCertification): bool
    {
        return true;
    }

    public function download(User $user, DriverCertification $driverCertification): bool
    {
        return true;
    }
}
