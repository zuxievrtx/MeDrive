<?php

namespace App\Services;

use App\Enums\AccountStatus;
use App\Models\User;
use Illuminate\Support\Facades\DB;

/**
 * Akun pelapor: admin hanya bisa menonaktifkan atau mengaktifkan kembali.
 */
class ReporterAccountService
{
    public function __construct(private AdminLogger $logger) {}

    public function setStatus(User $reporter, AccountStatus $status): User
    {
        if ($reporter->account_status === $status) {
            return $reporter;
        }

        DB::transaction(function () use ($reporter, $status): void {
            $reporter->forceFill(['account_status' => $status])->save();

            if ($status === AccountStatus::Nonaktif) {
                $reporter->tokens()->delete();
            }

            $isActive = $status === AccountStatus::Aktif;
            $this->logger->log(
                $isActive ? 'reporter.activated' : 'reporter.deactivated',
                $reporter,
                ($isActive ? 'Mengaktifkan kembali' : 'Menonaktifkan').' akun pelapor '.$reporter->name,
            );
        });

        return $reporter;
    }
}
