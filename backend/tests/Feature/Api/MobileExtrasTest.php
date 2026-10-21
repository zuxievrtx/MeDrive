<?php

use App\Jobs\SendFcmNotification;
use App\Models\DriverCertification;
use App\Models\DriverLastLocation;
use App\Models\ReportDispatch;
use App\Models\User;
use Illuminate\Http\Client\Request as HttpRequest;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Queue;

/*
 * Rute/ETA (OSRM), geocoding (Nominatim), badge terverifikasi, profil pelapor, dan push status ke pelapor.
 * Data contoh: laporan #3 milik Budi (#1) sedang ditangani Rina (#4); laporan #4 milik Sari (#2) menunggu.
 */
beforeEach(function () {
    $this->admin = seedDemoAndGetAdmin();
    Queue::fake([SendFcmNotification::class]);
    $this->budi = User::query()->findOrFail(1);
    $this->sari = User::query()->findOrFail(2);
    $this->andi = User::query()->findOrFail(3);
    $this->rina = User::query()->findOrFail(4);
});

function fakeOsrm(int $status = 200): void
{
    Http::fake([
        '*/route/v1/driving/*' => $status === 200
            ? Http::response([
                'code' => 'Ok',
                'routes' => [[
                    'distance' => 3456.7,
                    'duration' => 431.0,
                    'geometry' => ['type' => 'LineString', 'coordinates' => [[110.4203, -6.9932], [110.4220, -6.9950], [110.4251, -6.9981]]],
                ]],
            ])
            : Http::response(['code' => 'InvalidUrl'], $status),
    ]);
}

function fakeNominatim(): void
{
    Http::fake([
        '*/reverse*' => Http::response(['display_name' => 'Jl. Pahlawan, Pleburan, Semarang, Jawa Tengah']),
        '*/search*' => Http::response([
            ['display_name' => 'Simpang Lima, Semarang', 'lat' => '-6.9902', 'lon' => '110.4229'],
            ['display_name' => 'Simpang Lima, Jalan Pahlawan', 'lat' => '-6.9912', 'lon' => '110.4219'],
        ]),
    ]);
}

function osrmCalls(): int
{
    return Http::recorded(fn (HttpRequest $request): bool => str_contains($request->url(), '/route/v1/driving/'))->count();
}

describe('route and ETA', function () {
    it('serves the reporter a route from the ambulance to the pickup point and caches it', function () {
        fakeOsrm();
        actingAsMobile($this->budi);

        $this->getJson('/api/v1/reporter/reports/3/route')
            ->assertOk()
            ->assertJsonPath('data.distance_km', 3.46)
            ->assertJsonPath('data.duration_min', 7.2)
            ->assertJsonPath('data.geometry.0', [-6.9932, 110.4203])
            ->assertJsonPath('data.target', 'pickup')
            ->assertJsonPath('data.stale', false);

        $this->getJson('/api/v1/reporter/reports/3/route')->assertOk();

        expect(osrmCalls())->toBe(1);
        Http::assertSent(fn (HttpRequest $request): bool => str_contains($request->url(), 'overview=simplified')
            && str_contains($request->url(), 'geometries=geojson'));
    });

    it('calls OSRM at most once per report every 30 seconds even when the ambulance moves', function () {
        fakeOsrm();
        actingAsMobile($this->rina);

        $this->getJson('/api/v1/driver/route')->assertOk()->assertJsonPath('data.report_id', 3);

        DriverLastLocation::query()->whereKey(4)->update(['latitude' => DB::raw('latitude + 0.002')]);
        $this->getJson('/api/v1/driver/route')->assertOk()->assertJsonPath('data.stale', false);
        expect(osrmCalls())->toBe(1);

        $this->travel(31)->seconds();
        $this->getJson('/api/v1/driver/route')->assertOk();
        expect(osrmCalls())->toBe(2);
    });

    it('falls back to the last route marked stale when OSRM fails, and 502 without one', function () {
        Http::fake(['*/route/v1/driving/*' => Http::sequence()
            ->push(['code' => 'InvalidUrl'], 503)
            ->push(['code' => 'Ok', 'routes' => [['distance' => 1000, 'duration' => 120, 'geometry' => ['coordinates' => [[110.42, -6.99]]]]]])
            ->push(['code' => 'InvalidUrl'], 500)]);
        actingAsMobile($this->budi);

        $this->getJson('/api/v1/reporter/reports/3/route')
            ->assertStatus(502)
            ->assertJsonPath('error.code', 'route_unavailable');

        $this->travel(31)->seconds();
        $this->getJson('/api/v1/reporter/reports/3/route')->assertOk()->assertJsonPath('data.stale', false);

        DriverLastLocation::query()->whereKey(4)->update(['latitude' => DB::raw('latitude + 0.002')]);
        $this->travel(31)->seconds();
        $this->getJson('/api/v1/reporter/reports/3/route')
            ->assertOk()
            ->assertJsonPath('data.stale', true)
            ->assertJsonPath('data.distance_km', 1);

        expect(osrmCalls())->toBe(3);
    });

    it('refuses other reporters, reports without a driver, and drivers without an active report', function () {
        fakeOsrm();

        actingAsMobile($this->sari);
        $this->getJson('/api/v1/reporter/reports/3/route')->assertForbidden()->assertJsonPath('error.code', 'not_your_report');
        $this->getJson('/api/v1/reporter/reports/4/route')->assertStatus(409)->assertJsonPath('error.code', 'route_unavailable_status');

        actingAsMobile($this->andi);
        $this->getJson('/api/v1/driver/route')->assertStatus(409)->assertJsonPath('error.code', 'no_active_report');

        expect(osrmCalls())->toBe(0);
    });
});

describe('geocoding', function () {
    beforeEach(function () {
        config(['medrive.geocoding.upstream_per_second' => 100]);
    });

    it('reverse geocodes through the proxy with the app User-Agent and caches the result', function () {
        fakeNominatim();
        actingAsMobile($this->budi);

        foreach (range(1, 2) as $attempt) {
            $this->getJson('/api/v1/geocode/reverse?lat=-6.99321&lng=110.42034')
                ->assertOk()
                ->assertJsonPath('data.address', 'Jl. Pahlawan, Pleburan, Semarang, Jawa Tengah');
        }

        Http::assertSentCount(1);
        Http::assertSent(fn (HttpRequest $request): bool => str_starts_with($request->header('User-Agent')[0] ?? '', 'MedriveBackend/')
            && $request['format'] === 'jsonv2');
    });

    it('searches places, normalising the query for the 10 minute cache', function () {
        fakeNominatim();
        actingAsMobile($this->rina);

        $this->getJson('/api/v1/geocode/search?q='.urlencode('  Simpang   Lima ').'&limit=2')
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.label', 'Simpang Lima, Semarang')
            ->assertJsonPath('data.0.latitude', -6.9902)
            ->assertJsonPath('data.0.longitude', 110.4229);
        $this->getJson('/api/v1/geocode/search?q=simpang+lima&limit=2')->assertOk();

        Http::assertSentCount(1);

        $this->travel(11)->minutes();
        $this->getJson('/api/v1/geocode/search?q=simpang+lima&limit=2')->assertOk();
        Http::assertSentCount(2);
    });

    it('reports upstream failures without caching them and validates input', function () {
        Http::fake(['*' => Http::response('Bad gateway', 502)]);
        actingAsMobile($this->budi);

        $this->getJson('/api/v1/geocode/reverse?lat=-6.99&lng=110.42')->assertStatus(502)->assertJsonPath('error.code', 'geocode_unavailable');
        $this->getJson('/api/v1/geocode/reverse?lat=-6.99&lng=110.42')->assertStatus(502);
        Http::assertSentCount(2);

        $this->getJson('/api/v1/geocode/reverse?lat=120&lng=110.42')->assertStatus(400);
        $this->getJson('/api/v1/geocode/search?q=ab')->assertStatus(400);
    });

    it('keeps the public Nominatim limit of one upstream request per second', function () {
        fakeNominatim();
        config(['medrive.geocoding.upstream_per_second' => 1]);
        actingAsMobile($this->budi);

        $this->getJson('/api/v1/geocode/reverse?lat=-6.99&lng=110.42')->assertOk();
        $this->getJson('/api/v1/geocode/reverse?lat=-6.98&lng=110.41')->assertStatus(429)->assertJsonPath('error.code', 'geocode_busy');
    });

    it('does not open the proxy to other browser origins', function () {
        fakeNominatim();
        actingAsMobile($this->budi);

        $allowedOrigin = $this->getJson('/api/v1/geocode/reverse?lat=-6.99&lng=110.42', ['Origin' => 'https://situs-lain.example'])
            ->assertOk()
            ->headers->get('Access-Control-Allow-Origin');

        // Browser hanya menerima respons bila header ini sama dengan origin pemanggil (atau "*").
        expect($allowedOrigin)->not->toBe('*')->not->toBe('https://situs-lain.example');
    });

    it('is not available to admins', function () {
        fakeNominatim();
        $this->actingAs($this->admin)->getJson('/api/v1/geocode/reverse?lat=-6.99&lng=110.42')->assertForbidden();
    });
});

describe('verified driver badge', function () {
    it('marks drivers with at least one valid certification as verified on all three endpoints', function () {
        actingAsMobile($this->rina);
        $this->getJson('/api/v1/driver/profile')->assertOk()->assertJsonPath('data.is_verified', true);

        actingAsMobile($this->budi);
        $this->getJson('/api/v1/reporter/reports/3')->assertOk()->assertJsonPath('data.driver.is_verified', true);

        $this->actingAs($this->admin)->getJson('/api/v1/admin/drivers/4')->assertOk()->assertJsonPath('data.is_verified', true);
    });

    it('drops the badge when every certification has expired and keeps it for lifetime ones', function () {
        DriverCertification::query()->where('driver_id', 4)->update(['expires_at' => today()->subDay()]);

        actingAsMobile($this->rina);
        $this->getJson('/api/v1/driver/profile')->assertJsonPath('data.is_verified', false);
        actingAsMobile($this->budi);
        $this->getJson('/api/v1/reporter/reports/3')->assertJsonPath('data.driver.is_verified', false);
        $this->actingAs($this->admin)->getJson('/api/v1/admin/drivers/4')->assertJsonPath('data.is_verified', false);

        DriverCertification::query()->where('driver_id', 4)->update(['expires_at' => today()]);
        $this->getJson('/api/v1/admin/drivers/4')->assertJsonPath('data.is_verified', true);

        // Dedi (#5): sertifikat tanpa masa berlaku.
        $this->getJson('/api/v1/admin/drivers/5')->assertJsonPath('data.is_verified', true);

        DriverCertification::query()->where('driver_id', 5)->delete();
        $this->getJson('/api/v1/admin/drivers/5')->assertJsonPath('data.is_verified', false);
    });
});

describe('reporter profile', function () {
    it('updates name and phone but never email or role', function () {
        actingAsMobile($this->budi);
        $email = $this->budi->email;

        $this->putJson('/api/v1/reporter/profile', ['name' => 'Budi Santoso S.', 'phone' => '0812 3456 7000', 'email' => 'baru@medrive.test', 'role' => 'admin'])
            ->assertOk()
            ->assertJsonPath('data.name', 'Budi Santoso S.')
            ->assertJsonPath('data.phone', '0812 3456 7000')
            ->assertJsonPath('data.email', $email);

        $fresh = $this->budi->fresh();
        expect($fresh->email)->toBe($email)->and($fresh->role->value)->toBe('pelapor');

        $this->putJson('/api/v1/reporter/profile', ['name' => '', 'phone' => 'abc'])
            ->assertStatus(400)
            ->assertJsonStructure(['error' => ['details' => ['name', 'phone']]]);
    });

    it('is only for reporters', function () {
        actingAsMobile($this->rina);
        $this->putJson('/api/v1/reporter/profile', ['name' => 'Rina', 'phone' => '081200000000'])->assertForbidden();
    });
});

it('pushes taken, arrived and finished statuses to the reporter devices', function () {
    $driver = onShiftDriver(...pointNorthOf(-6.99, 110.42, 1));
    actingAsMobile($this->budi);
    $reportId = $this->postJson('/api/v1/reporter/reports', [
        'report_type_code' => 'medis_darurat',
        'latitude' => -6.99,
        'longitude' => 110.42,
        'description' => 'Uji push status',
        'details' => ['medical_category' => 'jantung'],
    ])->assertCreated()->json('data.id');

    actingAsMobile($driver);
    $this->postJson('/api/v1/driver/dispatches/'.ReportDispatch::query()->where('report_id', $reportId)->where('driver_id', $driver->id)->value('id').'/accept')->assertOk();
    $this->postJson("/api/v1/driver/reports/{$reportId}/status", ['status' => 'dalam_perjalanan'])->assertOk();
    $this->postJson("/api/v1/driver/reports/{$reportId}/status", ['status' => 'tiba_di_lokasi'])->assertOk();
    $patientId = $this->postJson("/api/v1/driver/reports/{$reportId}/patients", ['gender' => 'L', 'consciousness' => 'sadar'])->assertCreated()->json('data.id');
    $this->putJson("/api/v1/driver/patients/{$patientId}", ['handed_over_to' => 'IGD RSUP Kariadi'])->assertOk();
    $this->postJson("/api/v1/driver/reports/{$reportId}/status", ['status' => 'selesai'])->assertOk();

    $statuses = Queue::pushed(SendFcmNotification::class)
        ->filter(fn (SendFcmNotification $job): bool => $job->userId === $this->budi->id && ($job->data['report_id'] ?? null) === $reportId)
        ->map(fn (SendFcmNotification $job): string => $job->data['status'])
        ->values()
        ->all();

    expect($statuses)->toBe(['diambil', 'dalam_perjalanan', 'tiba_di_lokasi', 'selesai']);
});
