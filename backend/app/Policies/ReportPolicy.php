<?php

namespace App\Policies;

use App\Models\Report;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class ReportPolicy extends AdminPolicy
{
    public function viewAny(User $user): bool
    {
        return true;
    }

    public function view(User $user, Report $report): bool
    {
        return true;
    }

    public function export(User $user): bool
    {
        return true;
    }

    /**
     * Hanya laporan berstatus menunggu (belum diambil driver) yang boleh dibatalkan admin.
     */
    public function cancel(User $user, Report $report): Response
    {
        return $report->isCancellable()
            ? Response::allow()
            : Response::deny('Laporan yang sudah diambil driver tidak bisa dibatalkan admin.');
    }
}
