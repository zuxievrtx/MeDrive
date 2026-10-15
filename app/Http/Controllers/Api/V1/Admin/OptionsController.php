<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\AmbulanceStatus;
use App\Enums\ClinicType;
use App\Enums\InstitutionType;
use App\Enums\LicenseClass;
use App\Enums\ReportStatus;
use App\Enums\UserRole;
use App\Http\Controllers\Api\ApiController;
use App\Models\AdminActivityLog;
use App\Models\AmbulanceType;
use App\Models\Clinic;
use App\Models\Institution;
use App\Models\ReportType;
use App\Models\User;
use BackedEnum;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Data pilihan untuk dropdown filter dan form dashboard. ?only=clinics,institutions membatasi isi.
 */
class OptionsController extends ApiController
{
    public function __invoke(Request $request): JsonResponse
    {
        $only = array_filter(explode(',', (string) $request->query('only')));

        $sources = [
            'clinics' => fn () => Clinic::query()->with('institution:id,name')->orderBy('name')->get(['id', 'institution_id', 'name', 'is_active'])
                ->map(fn (Clinic $clinic): array => [
                    'id' => $clinic->id,
                    'name' => $clinic->name,
                    'label' => $clinic->labelWithInstitution(),
                    'institution_id' => $clinic->institution_id,
                    'is_active' => $clinic->is_active,
                ]),
            'institutions' => fn () => Institution::query()->orderBy('name')->get(['id', 'name', 'is_active']),
            'ambulance_types' => fn () => AmbulanceType::query()->orderBy('id')->get(['id', 'code', 'name', 'description']),
            'report_types' => fn () => ReportType::query()->orderBy('sort_order')->get(['id', 'code', 'name', 'color', 'icon', 'priority']),
            'drivers' => fn () => User::query()->where('role', UserRole::Driver)->orderBy('name')->get(['id', 'name']),
            'admins' => fn () => User::query()->where('role', UserRole::Admin)->orderBy('name')->get(['id', 'name']),
            'activity_modules' => fn () => AdminActivityLog::query()->distinct()->pluck('action')
                ->map(fn (string $action): string => strtok($action, '.'))->unique()->sort()->values(),
            'report_statuses' => fn () => $this->enumOptions(ReportStatus::cases()),
            'ambulance_statuses' => fn () => $this->enumOptions(AmbulanceStatus::cases()),
            'license_classes' => fn () => $this->enumOptions(LicenseClass::cases()),
            'institution_types' => fn () => $this->enumOptions(InstitutionType::cases()),
            'clinic_types' => fn () => $this->enumOptions(ClinicType::cases()),
        ];

        $selected = $only === [] ? $sources : array_intersect_key($sources, array_flip($only));

        return $this->ok(array_map(fn (callable $source) => $source(), $selected));
    }

    /**
     * @param  list<BackedEnum>  $cases
     * @return list<array{value: string, label: string}>
     */
    private function enumOptions(array $cases): array
    {
        return array_map(fn (BackedEnum $case): array => ['value' => (string) $case->value, 'label' => $case->label()], $cases);
    }
}
