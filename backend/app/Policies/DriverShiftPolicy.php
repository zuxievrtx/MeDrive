<?php

namespace App\Policies;

use App\Models\DriverShift;
use App\Models\User;

class DriverShiftPolicy extends AdminPolicy
{
    /**
     * Peta Live dan Log Lokasi.
     */
    public function viewAny(User $user): bool
    {
        return true;
    }

    /**
     * Admin hanya bisa mengakhiri shift yang masih terbuka.
     */
    public function end(User $user, DriverShift $driverShift): bool
    {
        return $driverShift->isOpen();
    }
}
