<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Exceptions\ApiException;
use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Admin\StoreDriverRequest;
use App\Http\Requests\Admin\UpdateDriverRequest;
use App\Http\Resources\DriverCertificationResource;
use App\Http\Resources\DriverShiftResource;
use App\Http\Resources\ReportResource;
use App\Http\Resources\UserResource;
use App\Models\Clinic;
use App\Models\DriverCertification;
use App\Models\DriverProfile;
use App\Models\DriverShift;
use App\Models\User;
use App\Services\AdminLogger;
use App\Services\DriverAccountService;
use App\Services\ShiftService;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rules\Password;

/**
 * Manajemen driver oleh admin pusat. Driver tidak bisa registrasi mandiri.
 *
 * @group Admin
 */
class DriverController extends ApiController
{
    /**
     * @var array<string, string>
     */
    private const SORTABLE = [
        'name' => 'users.name',
        'clinic' => 'clinics.name',
        'employee_number' => 'driver_profiles.employee_number',
        'license_expires_at' => 'driver_profiles.license_expires_at',
        'last_login_at' => 'users.last_login_at',
        'created_at' => 'users.created_at',
    ];

    public function __construct(private DriverAccountService $accounts) {}

    public function index(Request $request): JsonResponse
    {
        Gate::authorize('viewAny', User::class);

        $filters = $request->validate([
            'q' => ['nullable', 'string', 'max:100'],
            'clinic_id' => ['nullable', 'integer'],
            'institution_id' => ['nullable', 'integer'],
            'shift' => ['nullable', 'in:aktif,tidak'],
            'status' => ['nullable', 'in:aktif,nonaktif'],
            'sort' => ['nullable', 'in:'.implode(',', array_keys(self::SORTABLE))],
            'direction' => ['nullable', 'in:asc,desc'],
        ]);

        $drivers = User::query()
            ->drivers()
            ->select('users.*')
            ->join('driver_profiles', 'driver_profiles.user_id', '=', 'users.id')
            ->join('clinics', 'clinics.id', '=', 'driver_profiles.clinic_id')
            ->with(['driverProfile.clinic.institution', 'openShift.ambulance.ambulanceType', 'lastLocation'])
            ->when($filters['q'] ?? null, function (Builder $query, string $search): void {
                $query->where(fn (Builder $query) => $query
                    ->where('users.name', 'like', "%{$search}%")
                    ->orWhere('users.email', 'like', "%{$search}%")
                    ->orWhere('users.phone', 'like', "%{$search}%")
                    ->orWhere('driver_profiles.employee_number', 'like', "%{$search}%"));
            })
            ->when($filters['clinic_id'] ?? null, fn (Builder $query, int $clinicId) => $query->where('driver_profiles.clinic_id', $clinicId))
            ->when($filters['institution_id'] ?? null, fn (Builder $query, int $institutionId) => $query->where('clinics.institution_id', $institutionId))
            ->when($filters['status'] ?? null, fn (Builder $query, string $status) => $query->where('users.account_status', $status))
            ->when(($filters['shift'] ?? null) === 'aktif', fn (Builder $query) => $query->whereHas('openShift'))
            ->when(($filters['shift'] ?? null) === 'tidak', fn (Builder $query) => $query->whereDoesntHave('openShift'))
            ->orderBy(self::SORTABLE[$filters['sort'] ?? 'name'], $filters['direction'] ?? 'asc')
            ->orderBy('users.id')
            ->paginate(20);

        return $this->paginated($drivers, UserResource::class, ['summary' => $this->summary()]);
    }

    /**
     * Kredensial sementara dikembalikan sekali di respons ini; tidak bisa dibaca lagi setelahnya.
     */
    public function store(StoreDriverRequest $request): JsonResponse
    {
        $data = $request->validated();
        $certifications = collect($data['certifications'] ?? [])
            ->map(fn (array $certification, int $index): array => [
                'data' => $certification,
                'file' => $request->file("certifications.{$index}.file"),
            ])
            ->values()
            ->all();

        $driver = $this->accounts->create($data, $request->file('photo'), $certifications, $request->user());

        return $this->created([
            'driver' => UserResource::make($driver->load('driverProfile.clinic.institution'))->resolve($request),
            'credentials' => ['email' => $driver->email, 'password' => $data['password']],
        ]);
    }

    public function show(Request $request, User $driver): JsonResponse
    {
        Gate::authorize('view', $driver);

        $driver->load([
            'driverProfile.clinic.institution',
            'driverProfile.creator',
            'openShift.ambulance.ambulanceType',
            'lastLocation',
            'devices' => fn ($query) => $query->latest('last_seen_at'),
            'certifications' => fn ($query) => $query->orderByDesc('issued_at'),
        ]);

        return $this->ok([
            ...UserResource::make($driver)->resolve($request),
            'is_verified' => $driver->is_verified_driver,
            'certifications' => DriverCertificationResource::collection($driver->certifications)->resolve($request),
        ]);
    }

    public function update(UpdateDriverRequest $request, User $driver): JsonResponse
    {
        $updated = $this->accounts->update($driver, $request->validated(), $request->file('photo'));

        return $this->ok(UserResource::make($updated->load('driverProfile.clinic.institution')));
    }

    public function shifts(User $driver): JsonResponse
    {
        Gate::authorize('view', $driver);

        return $this->paginated(
            $driver->shifts()->with('ambulance.ambulanceType')->latest('started_at')->paginate(20),
            DriverShiftResource::class,
        );
    }

    public function reports(User $driver): JsonResponse
    {
        Gate::authorize('view', $driver);

        return $this->paginated(
            $driver->reportsTaken()->with(['reportType', 'ambulance:id,plate_number'])->latest()->paginate(20),
            ReportResource::class,
        );
    }

    public function resetPassword(Request $request, User $driver): JsonResponse
    {
        Gate::authorize('update', $driver);

        $request->validate(['password' => ['nullable', 'string', Password::min(8)]]);
        $password = $this->accounts->resetPassword($driver, $request->input('password'));

        return $this->ok(['credentials' => ['email' => $driver->email, 'password' => $password], 'must_change_password' => true]);
    }

    public function deactivate(User $driver): JsonResponse
    {
        Gate::authorize('toggleStatus', $driver);

        return $this->ok(UserResource::make($this->accounts->deactivate($driver)));
    }

    public function activate(User $driver): JsonResponse
    {
        Gate::authorize('toggleStatus', $driver);

        return $this->ok(UserResource::make($this->accounts->activate($driver)));
    }

    public function endShift(User $driver, DriverShift $shift, ShiftService $shifts, AdminLogger $logger): JsonResponse
    {
        if ($shift->driver_id !== $driver->id) {
            throw new ApiException('not_found', 'Shift tidak ditemukan untuk driver ini.', 404);
        }

        // Shift yang sudah selesai adalah konflik aturan bisnis (409), bukan masalah hak akses.
        Gate::authorize('viewAny', DriverShift::class);

        return $this->ok(DriverShiftResource::make($shifts->endByAdmin($shift, $logger)->load('ambulance')));
    }

    /**
     * @return array<string, mixed>
     */
    private function summary(): array
    {
        $today = now()->toDateString();
        $warningLimit = now()->addDays(config('medrive.expiry_warning_days'))->toDateString();

        return [
            'per_clinic' => Clinic::query()->whereHas('driverProfiles')->withCount('driverProfiles')->orderByDesc('driver_profiles_count')->get(['id', 'name'])
                ->map(fn (Clinic $clinic): array => ['id' => $clinic->id, 'name' => $clinic->name, 'drivers' => $clinic->driver_profiles_count]),
            'licenses_expired' => DriverProfile::query()->whereDate('license_expires_at', '<', $today)->count(),
            'licenses_expiring' => DriverProfile::query()->whereDate('license_expires_at', '>=', $today)->whereDate('license_expires_at', '<=', $warningLimit)->count(),
            'certifications_expired' => DriverCertification::query()->whereNotNull('expires_at')->whereDate('expires_at', '<', $today)->count(),
            'certifications_expiring' => DriverCertification::query()->whereDate('expires_at', '>=', $today)->whereDate('expires_at', '<=', $warningLimit)->count(),
        ];
    }
}
