<?php

namespace App\Console\Commands;

use App\Services\LocationService;
use Illuminate\Console\Attributes\Description;
use Illuminate\Console\Attributes\Signature;
use Illuminate\Console\Command;

#[Signature('medrive:flush-locations')]
#[Description('Pindahkan ping lokasi dari buffer ke driver_location_logs, perbarui snapshot, dan broadcast posisi')]
class FlushLocationBuffer extends Command
{
    public function handle(LocationService $locations): int
    {
        $result = $locations->flush();

        if ($result['logs'] > 0) {
            $this->info("{$result['logs']} titik disimpan, {$result['snapshots']} snapshot, {$result['broadcasts']} broadcast.");
        }

        return self::SUCCESS;
    }
}
