<?php

namespace App\Http\Controllers\Admin;

use App\Enums\AccountStatus;
use App\Enums\LicenseClass;
use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreDriverRequest;
use App\Http\Requests\Admin\UpdateDriverRequest;
use App\Models\Clinic;
use App\Models\DriverCertification;
use App\Models\DriverProfile;
use App\Models\Institution;
use App\Models\User;
use App\Services\AdminLogger;
use App\Services\DriverFileStorage;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Throwable;

class DriverController extends Controller
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

    private const TABS = ['profil', 'sertifikat', 'shift', 'laporan', 'lokasi'];

    public function index(Request $request): View
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

        $sort = $filters['sort'] ?? 'name';
        $direction = $filters['direction'] ?? 'asc';

        $drivers = User::query()
            ->drivers()
            ->select('users.*')
            ->join('driver_profiles', 'driver_profiles.user_id', '=', 'users.id')
            ->join('clinics', 'clinics.id', '=', 'driver_profiles.clinic_id')
            ->with(['driverProfile.clinic.institution', 'openShift.ambulance.ambulanceType', 'lastLocation'])
            ->when($filters['q'] ?? null, function (Builder $query, string $search): void {
                $query->where(function (Builder $query) use ($search): void {
                    $query->where('users.name', 'like', "%{$search}%")
                        ->orWhere('users.email', 'like', "%{$search}%")
                        ->orWhere('users.phone', 'like', "%{$search}%")
                        ->orWhere('driver_profiles.employee_number', 'like', "%{$search}%");
                });
            })
            ->when($filters['clinic_id'] ?? null, fn (Builder $query, int $clinicId) => $query->where('driver_profiles.clinic_id', $clinicId))
            ->when($filters['institution_id'] ?? null, fn (Builder $query, int $institutionId) => $query->where('clinics.institution_id', $institutionId))
            ->when($filters['status'] ?? null, fn (Builder $query, string $status) => $query->where('users.account_status', $status))
            ->when(($filters['shift'] ?? null) === 'aktif', fn (Builder $query) => $query->whereHas('openShift'))
            ->when(($filters['shift'] ?? null) === 'tidak', fn (Builder $query) => $query->whereDoesntHave('openShift'))
            ->orderBy(self::SORTABLE[$sort], $direction)
            ->orderBy('users.id')
            ->paginate(20)
            ->withQueryString();

        return view('admin.drivers.index', [
            'drivers' => $drivers,
            'filters' => $filters,
            'sort' => $sort,
            'direction' => $direction,
            'clinics' => $this->clinicOptions(),
            'institutions' => Institution::query()->orderBy('name')->get(['id', 'name']),
            'summary' => $this->summary(),
        ]);
    }

    public function create(): View
    {
        Gate::authorize('create', User::class);

        return view('admin.drivers.create', [
            'clinics' => $this->clinicOptions(activeOnly: true),
            'licenseClasses' => LicenseClass::cases(),
        ]);
    }

    /**
     * Mendaftarkan driver: akun users (role driver) + driver_profiles (+ sertifikat) dalam satu transaksi.
     */
    public function store(StoreDriverRequest $request, AdminLogger $logger, DriverFileStorage $files): RedirectResponse
    {
        $data = $request->validated();
        $clinic = Clinic::query()->findOrFail($data['clinic_id']);

        try {
            $driver = DB::transaction(function () use ($request, $data, $clinic, $logger, $files): User {
                $driver = User::create([
                    'name' => $data['name'],
                    'phone' => $data['phone'],
                    'email' => $data['email'],
                    'password' => $data['password'],
                    'role' => UserRole::Driver,
                    'account_status' => AccountStatus::Aktif,
                    'must_change_password' => $data['must_change_password'] ?? true,
                ]);

                $driver->driverProfile()->create([
                    'clinic_id' => $clinic->id,
                    'employee_number' => $data['employee_number'],
                    'license_number' => $data['license_number'],
                    'license_class' => $data['license_class'],
                    'license_expires_at' => $data['license_expires_at'],
                    'photo_path' => $request->hasFile('photo') ? $files->storePhoto($driver->id, $request->file('photo')) : null,
                    'created_by' => $request->user()->id,
                ]);

                $logger->log('driver.created', $driver, "Mendaftarkan driver {$driver->name} ({$clinic->name})");

                foreach ($data['certifications'] ?? [] as $index => $certificationData) {
                    $upload = $request->file("certifications.{$index}.file");

                    $certification = $driver->certifications()->create([
                        ...collect($certificationData)->only(['name', 'certificate_number', 'issuer', 'issued_at', 'expires_at'])->all(),
                        'file_path' => $upload ? $files->storeCertification($driver->id, $upload) : null,
                    ]);

                    $logger->log('certification.created', $certification, "Menambah sertifikat {$certification->name} untuk driver {$driver->name}");
                }

                return $driver;
            });
        } catch (Throwable $exception) {
            $files->rollback();

            throw $exception;
        }

        return redirect()
            ->route('admin.drivers.show', $driver)
            ->with('success', "Driver {$driver->name} berhasil didaftarkan.")
            ->with('driver_credentials', Crypt::encrypt(['email' => $driver->email, 'password' => $data['password']]));
    }

    public function show(Request $request, User $driver): Response
    {
        Gate::authorize('view', $driver);

        $tab = in_array($request->query('tab'), self::TABS, true) ? $request->query('tab') : 'profil';

        $driver->load(['driverProfile.clinic.institution', 'driverProfile.creator', 'openShift.ambulance.ambulanceType', 'lastLocation']);

        $credentials = $request->session()->has('driver_credentials')
            ? Crypt::decrypt($request->session()->get('driver_credentials'))
            : null;

        $view = view('admin.drivers.show', [
            'driver' => $driver,
            'profile' => $driver->driverProfile,
            'tab' => $tab,
            'credentials' => $credentials,
            'devices' => $tab === 'profil' ? $driver->devices()->latest('last_seen_at')->get() : collect(),
            'certifications' => $tab === 'sertifikat' ? $driver->certifications()->orderByDesc('issued_at')->get() : collect(),
            'shifts' => $tab === 'shift'
                ? $driver->shifts()->with('ambulance.ambulanceType')->latest('started_at')->paginate(20)->withQueryString()
                : null,
            'reports' => $tab === 'laporan'
                ? $driver->reportsTaken()->with(['reportType', 'ambulance'])->latest()->paginate(20)->withQueryString()
                : null,
        ]);

        // Halaman yang memuat kredensial sementara tidak boleh disimpan cache browser.
        return response($view)->header('Cache-Control', 'no-store, private');
    }

    public function edit(User $driver): View
    {
        Gate::authorize('update', $driver);

        $driver->load('driverProfile.clinic.institution');

        return view('admin.drivers.edit', [
            'driver' => $driver,
            'profile' => $driver->driverProfile,
            'clinics' => $this->clinicOptions(),
            'licenseClasses' => LicenseClass::cases(),
        ]);
    }

    public function update(UpdateDriverRequest $request, User $driver, AdminLogger $logger, DriverFileStorage $files): RedirectResponse
    {
        $data = $request->validated();
        $profile = $driver->driverProfile;
        $oldPhotoPath = $profile->photo_path;

        try {
            DB::transaction(function () use ($request, $data, $driver, $profile, $logger, $files): void {
                $driver->fill(collect($data)->only(['name', 'phone', 'email'])->all());
                $profile->fill(collect($data)->only(['clinic_id', 'employee_number', 'license_number', 'license_class', 'license_expires_at'])->all());

                $changes = array_filter([
                    AdminLogger::describeChanges($driver->getOriginal(), $driver->getDirty()),
                    AdminLogger::describeChanges($profile->getOriginal(), $profile->getDirty()),
                ]);

                if (filled($data['new_password'] ?? null)) {
                    $driver->password = $data['new_password'];
                    $driver->must_change_password = true;
                    $changes[] = 'password direset (wajib ganti saat login)';
                }

                if ($request->hasFile('photo')) {
                    $profile->photo_path = $files->storePhoto($driver->id, $request->file('photo'));
                    $changes[] = 'foto diganti';
                }

                $driver->save();
                $profile->save();

                $logger->log(
                    'driver.updated',
                    $driver,
                    "Mengubah data driver {$driver->name}: ".($changes ? implode('; ', $changes) : 'tanpa perubahan'),
                );
            });
        } catch (Throwable $exception) {
            $files->rollback();

            throw $exception;
        }

        if ($request->hasFile('photo')) {
            $files->delete($oldPhotoPath);
        }

        return redirect()->route('admin.drivers.show', $driver)->with('success', 'Data driver berhasil diperbarui.');
    }

    /**
     * Nonaktifkan/aktifkan akun. Driver dengan shift terbuka harus diakhiri shift-nya terlebih dahulu.
     */
    public function toggleStatus(User $driver, AdminLogger $logger): RedirectResponse
    {
        Gate::authorize('toggleStatus', $driver);

        if ($driver->isActive()) {
            if ($driver->openShift()->exists()) {
                return redirect()
                    ->route('admin.drivers.show', ['driver' => $driver, 'tab' => 'shift'])
                    ->with('error', "{$driver->name} masih memiliki shift terbuka. Akhiri shift terlebih dahulu sebelum menonaktifkan akun.");
            }

            $driver->forceFill(['account_status' => AccountStatus::Nonaktif])->save();
            $logger->log('driver.deactivated', $driver, "Menonaktifkan akun driver {$driver->name}");

            return back()->with('success', "Akun {$driver->name} dinonaktifkan. Driver tidak bisa login ke aplikasi.");
        }

        $driver->forceFill(['account_status' => AccountStatus::Aktif])->save();
        $logger->log('driver.activated', $driver, "Mengaktifkan kembali akun driver {$driver->name}");

        return back()->with('success', "Akun {$driver->name} diaktifkan kembali.");
    }

    public function photo(User $driver): StreamedResponse
    {
        Gate::authorize('view', $driver);

        $path = DriverProfile::query()->where('user_id', $driver->id)->value('photo_path');

        abort_unless($path && Storage::disk('local')->exists($path), 404);

        return Storage::disk('local')->response($path, null, ['Cache-Control' => 'private, max-age=600']);
    }

    /**
     * @return Collection<int, Clinic>
     */
    private function clinicOptions(bool $activeOnly = false): Collection
    {
        return Clinic::query()
            ->with('institution:id,name')
            ->when($activeOnly, fn (Builder $query) => $query->where('is_active', true))
            ->orderBy('name')
            ->get(['id', 'institution_id', 'name', 'is_active']);
    }

    /**
     * Ringkasan di atas tabel: jumlah driver per klinik dan dokumen kedaluwarsa.
     *
     * @return array<string, mixed>
     */
    private function summary(): array
    {
        $today = now()->toDateString();
        $warningLimit = now()->addDays(config('medrive.expiry_warning_days'))->toDateString();

        return [
            'per_clinic' => Clinic::query()
                ->whereHas('driverProfiles')
                ->withCount('driverProfiles')
                ->orderByDesc('driver_profiles_count')
                ->get(['id', 'name']),
            'licenses_expired' => DriverProfile::query()->whereDate('license_expires_at', '<', $today)->count(),
            'licenses_expiring' => DriverProfile::query()->whereDate('license_expires_at', '>=', $today)->whereDate('license_expires_at', '<=', $warningLimit)->count(),
            'certifications_expired' => DriverCertification::query()->whereNotNull('expires_at')->whereDate('expires_at', '<', $today)->count(),
            'certifications_expiring' => DriverCertification::query()->whereDate('expires_at', '>=', $today)->whereDate('expires_at', '<=', $warningLimit)->count(),
        ];
    }
}
