<?php

namespace App\Http\Controllers\Admin;

use App\Enums\ShiftEndReason;
use App\Http\Controllers\Controller;
use App\Models\DriverShift;
use App\Services\AdminLogger;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;

class DriverShiftController extends Controller
{
    /**
     * Admin mengakhiri shift terbuka (end_reason dihentikan_admin). Laporan yang sedang ditangani tidak diubah.
     */
    public function end(DriverShift $shift, AdminLogger $logger): RedirectResponse
    {
        $shift->load(['driver', 'ambulance']);

        if (Gate::denies('end', $shift)) {
            return back()->with('error', 'Shift ini sudah berakhir sebelumnya.');
        }

        DB::transaction(function () use ($shift, $logger): void {
            $updated = DriverShift::query()
                ->whereKey($shift->id)
                ->whereNull('ended_at')
                ->update(['ended_at' => now(), 'end_reason' => ShiftEndReason::DihentikanAdmin]);

            if ($updated === 1) {
                $logger->log(
                    'shift.ended',
                    $shift,
                    "Mengakhiri shift {$shift->driver->name} ({$shift->ambulance->plate_number}) dengan alasan dihentikan admin",
                );
            }
        });

        return back()->with('success', "Shift {$shift->driver->name} telah diakhiri.");
    }
}
