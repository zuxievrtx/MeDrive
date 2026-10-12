<?php

namespace App\Policies;

use App\Models\ReportType;
use App\Models\User;

class ReportTypePolicy extends AdminPolicy
{
    public function viewAny(User $user): bool
    {
        return true;
    }

    public function update(User $user, ReportType $reportType): bool
    {
        return true;
    }
}
