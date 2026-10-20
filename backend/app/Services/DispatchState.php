<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;

/**
 * Status ronde broadcast per laporan (ronde ke berapa, kapan mulai, sudah dialarmkan atau belum).
 * Skema v3 tidak punya kolom ronde, jadi disimpan di cache (database/redis), bukan di tabel.
 */
class DispatchState
{
    private const TTL_SECONDS = 172800;

    /**
     * @return array{round: int, started_at: int, alarmed: bool}|null
     */
    public function get(int $reportId): ?array
    {
        return Cache::get($this->key($reportId));
    }

    public function startRound(int $reportId, int $round): void
    {
        Cache::put($this->key($reportId), ['round' => $round, 'started_at' => now()->getTimestamp(), 'alarmed' => false], self::TTL_SECONDS);
    }

    public function markAlarmed(int $reportId): void
    {
        $state = $this->get($reportId) ?? ['round' => count(config('medrive.dispatch.radius_rounds_km')), 'started_at' => now()->getTimestamp()];
        Cache::put($this->key($reportId), [...$state, 'alarmed' => true], self::TTL_SECONDS);
    }

    public function forget(int $reportId): void
    {
        Cache::forget($this->key($reportId));
    }

    private function key(int $reportId): string
    {
        return 'dispatch:state:'.$reportId;
    }
}
