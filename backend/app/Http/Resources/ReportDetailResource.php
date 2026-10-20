<?php

namespace App\Http\Resources;

use App\Enums\ReportStatus;
use App\Models\Report;
use App\Support\Label;
use Illuminate\Http\Request;

/**
 * Detail laporan. Relasi yang ikut tampil ditentukan pemanggil lewat eager loading,
 * mis. daftar dispatch hanya dimuat untuk admin.
 *
 * @mixin Report
 */
class ReportDetailResource extends ReportResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            ...parent::toArray($request),
            'description' => $this->description,
            'is_cancellable' => $this->isCancellable(),
            'details' => $this->typeDetails(),
            'driver' => $this->whenLoaded('driver', fn (): ?array => $this->driver ? [
                'id' => $this->driver->id,
                'name' => $this->driver->name,
                'phone' => $this->driver->phone,
                'photo_url' => $this->driver->driverProfile?->photo_path ? route('api.v1.media', ['type' => 'driver-photo', 'id' => $this->driver->id]) : null,
                'clinic' => $this->driver->driverProfile?->relationLoaded('clinic') ? $this->driver->driverProfile->clinic?->name : null,
                'last_location' => $this->driver->relationLoaded('lastLocation') && $this->driver->lastLocation
                    ? DriverLocationResource::make($this->driver->lastLocation)->resolve($request)
                    : null,
            ] : null),
            'ambulance' => $this->whenLoaded('ambulance', fn (): ?array => $this->ambulance ? [
                'id' => $this->ambulance->id,
                'plate_number' => $this->ambulance->plate_number,
                'vehicle_name' => $this->ambulance->vehicle_name,
                'type' => $this->ambulance->relationLoaded('ambulanceType') ? $this->ambulance->ambulanceType->name : null,
                'map_icon' => $this->ambulance->relationLoaded('ambulanceType') ? $this->ambulance->ambulanceType->mapIcon() : null,
                'clinic' => $this->ambulance->relationLoaded('clinic') ? $this->ambulance->clinic->name : null,
            ] : null),
            'reporter' => $this->whenLoaded('reporter', fn (): array => [
                'id' => $this->reporter->id,
                'name' => $this->reporter->name,
                'phone' => $this->reporter->phone,
                'email' => $this->reporter->email,
                'account_status' => $this->enum($this->reporter->account_status),
                'devices_count' => $this->reporter->relationLoaded('devices') ? $this->reporter->devices->count() : null,
            ]),
            'patients' => ReportPatientResource::collection($this->whenLoaded('patients')),
            'attachments' => ReportAttachmentResource::collection($this->whenLoaded('attachments')),
            'timeline' => ReportStatusLogResource::collection($this->whenLoaded('statusLogs')),
            'dispatches' => ReportDispatchResource::collection($this->whenLoaded('dispatches')),
            'is_tracking_available' => in_array($this->status, ReportStatus::active(), true) && $this->driver_id !== null,
        ];
    }

    /**
     * Detail khusus jenis laporan (tepat satu dari empat tabel detail).
     *
     * @return array<string, mixed>|null
     */
    private function typeDetails(): ?array
    {
        if ($this->relationLoaded('accidentDetail') && $detail = $this->accidentDetail) {
            return [
                'kind' => 'kecelakaan',
                'accident_type' => ['value' => $detail->accident_type, 'label' => Label::humanize($detail->accident_type)],
                'estimated_victim_count' => $detail->estimated_victim_count,
                'has_trapped_victim' => $detail->has_trapped_victim,
                'has_fire_hazard' => $detail->has_fire_hazard,
                'is_road_blocked' => $detail->is_road_blocked,
            ];
        }

        if ($this->relationLoaded('medicalDetail') && $detail = $this->medicalDetail) {
            return [
                'kind' => 'medis',
                'medical_category' => ['value' => $detail->medical_category, 'label' => Label::humanize($detail->medical_category)],
                'symptom_onset_at' => $this->date($detail->symptom_onset_at),
                'has_medical_history' => $detail->has_medical_history,
                'medical_history_notes' => $detail->medical_history_notes,
            ];
        }

        if ($this->relationLoaded('maternityDetail') && $detail = $this->maternityDetail) {
            return [
                'kind' => 'ibu_hamil',
                'gestational_age_weeks' => $detail->gestational_age_weeks,
                'contraction_interval_minutes' => $detail->contraction_interval_minutes,
                'is_water_broken' => $detail->is_water_broken,
                'has_bleeding' => $detail->has_bleeding,
                'pregnancy_number' => $detail->pregnancy_number,
                'destination_clinic' => $detail->relationLoaded('destinationClinic') && $detail->destinationClinic
                    ? ['id' => $detail->destinationClinic->id, 'name' => $detail->destinationClinic->name]
                    : null,
            ];
        }

        if ($this->relationLoaded('funeralDetail') && $detail = $this->funeralDetail) {
            return [
                'kind' => 'jenazah',
                'deceased_name' => $detail->deceased_name,
                'pickup_place_type' => ['value' => $detail->pickup_place_type, 'label' => Label::humanize($detail->pickup_place_type)],
                'scheduled_pickup_at' => $this->date($detail->scheduled_pickup_at),
                'has_death_certificate' => $detail->has_death_certificate,
                'family_contact_name' => $detail->family_contact_name,
                'family_contact_phone' => $detail->family_contact_phone,
            ];
        }

        return null;
    }
}
