<?php

use App\Enums\ReportStatus;
use App\Models\Report;
use App\Models\User;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

// Dashboard admin: laporan baru, perubahan status, dan peringatan eskalasi dispatch.
Broadcast::channel('admin', fn (User $user): bool => $user->isAdmin() && $user->isActive());

Broadcast::channel('admin.tracking', fn (User $user): bool => $user->isAdmin() && $user->isActive());

// Pelapor pemilik laporan, hanya selama laporan aktif (sudah diambil sampai mengantar pasien).
Broadcast::channel('report.{report}', function (User $user, Report $report): bool {
    return $user->isActive()
        && $report->reporter_id === $user->id
        && in_array($report->status, ReportStatus::active(), true);
});
