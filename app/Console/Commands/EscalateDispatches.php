<?php

namespace App\Console\Commands;

use App\Services\EscalationService;
use Illuminate\Console\Attributes\Description;
use Illuminate\Console\Attributes\Signature;
use Illuminate\Console\Command;

#[Signature('medrive:escalate-dispatches')]
#[Description('Perluas radius broadcast laporan yang belum diambil dan kirim peringatan ke admin')]
class EscalateDispatches extends Command
{
    public function handle(EscalationService $escalation): int
    {
        $result = $escalation->run();

        if (array_sum($result) > 0) {
            $this->info("Eskalasi {$result['escalated']}, alarm {$result['alarmed']}, tawaran diabaikan {$result['ignored']}.");
        }

        return self::SUCCESS;
    }
}
