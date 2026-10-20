<?php

namespace App\Http\Resources;

use App\Enums\ReportStatus;
use App\Models\Report;
use Illuminate\Http\Request;

/**
 * Ringkasan laporan untuk daftar. Detail lengkap ada di ReportDetailResource.
 *
 * @mixin Report
 */
class ReportResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $waitingMinutes = $this->status === ReportStatus::Menunggu
            ? (int) $this->created_at->diffInMinutes(now())
            : null;

        return [
            'id' => $this->id,
            'code' => $this->code,
            'status' => $this->enum($this->status),
            'report_type' => ReportTypeResource::make($this->whenLoaded('reportType')),
            'address' => $this->address,
            'short_address' => $this->shortAddress(),
            'latitude' => (float) $this->latitude,
            'longitude' => (float) $this->longitude,
            'destination' => $this->destination_name || $this->destination_lat !== null ? [
                'name' => $this->destination_name,
                'address' => $this->destination_address,
                'latitude' => $this->destination_lat !== null ? (float) $this->destination_lat : null,
                'longitude' => $this->destination_lng !== null ? (float) $this->destination_lng : null,
            ] : null,
            'reporter' => $this->whenLoaded('reporter', fn (): array => [
                'id' => $this->reporter->id,
                'name' => $this->reporter->name,
                'phone' => $this->reporter->phone,
            ]),
            'driver' => $this->whenLoaded('driver', fn (): ?array => $this->driver ? [
                'id' => $this->driver->id,
                'name' => $this->driver->name,
                'phone' => $this->driver->phone,
            ] : null),
            'ambulance' => $this->whenLoaded('ambulance', fn (): ?array => $this->ambulance ? [
                'id' => $this->ambulance->id,
                'plate_number' => $this->ambulance->plate_number,
            ] : null),
            'created_at' => $this->date($this->created_at),
            'taken_at' => $this->date($this->taken_at),
            'arrived_at' => $this->date($this->arrived_at),
            'completed_at' => $this->date($this->completed_at),
            'response_time_minutes' => $this->response_time_minutes,
            'waiting_minutes' => $waitingMinutes,
            'is_stale' => $waitingMinutes !== null && $waitingMinutes > config('medrive.stale_pending_minutes'),
        ];
    }
}
