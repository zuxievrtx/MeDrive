<?php

use App\Enums\ReportStatus;
use App\Events\DriverLocationUpdated;
use App\Events\ReportDriverLocationUpdated;
use App\Models\DriverLastLocation;
use App\Models\DriverLocationLog;
use App\Models\DriverProfile;
use App\Models\Report;
use App\Models\User;
use App\Services\LocationService;
use Database\Seeders\MasterDataSeeder;
use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\Event;

beforeEach(function () {
    $this->seed(MasterDataSeeder::class);
    $this->driver = onShiftDriver(-6.99, 110.42);
});

function ping(array $overrides = [], int $secondsAgo = 0): array
{
    return array_merge([
        'latitude' => -6.9901,
        'longitude' => 110.4201,
        'accuracy_m' => 5,
        'speed_kmh' => 30,
        'heading' => 90,
        'battery_level' => 80,
        'provider' => 'fused',
        'is_mock_location' => false,
        'recorded_at' => now()->subSeconds($secondsAgo)->toIso8601String(),
    ], $overrides);
}

it('buffers a batch, then flushes all points into the log and the snapshot', function () {
    Event::fake([DriverLocationUpdated::class]);
    actingAsMobile($this->driver);

    $this->postJson('/api/v1/driver/location', [
        'points' => [ping(secondsAgo: 10), ping(['latitude' => -6.9905, 'battery_level' => 79], 5), ping(['latitude' => -6.9910, 'battery_level' => 78])],
    ])->assertOk()->assertJsonPath('data.accepted', 3)->assertJsonPath('data.rejected', []);

    expect(DriverLocationLog::query()->count())->toBe(0);

    $result = app(LocationService::class)->flush();

    expect($result)->toBe(['logs' => 3, 'snapshots' => 1, 'broadcasts' => 1])
        ->and(DriverLocationLog::query()->where('driver_id', $this->driver->id)->count())->toBe(3);

    $snapshot = DriverLastLocation::query()->findOrFail($this->driver->id);
    expect((float) $snapshot->latitude)->toBe(-6.991)
        ->and($snapshot->battery_level)->toBe(78)
        ->and($snapshot->is_mock_location)->toBeFalse();

    Event::assertDispatched(DriverLocationUpdated::class, fn (DriverLocationUpdated $event) => $event->payload['battery_level'] === 78);
});

it('rejects invalid points individually without failing the batch', function () {
    actingAsMobile($this->driver);

    $this->postJson('/api/v1/driver/location', [
        'points' => [ping(), ping(['heading' => 360]), ping(['battery_level' => 150]), ping(['latitude' => 95])],
    ])->assertOk()
        ->assertJsonPath('data.accepted', 1)
        ->assertJsonCount(3, 'data.rejected')
        ->assertJsonPath('data.rejected.0.index', 1);
});

it('upserts the snapshot at most once per 15 seconds and throttles broadcasts to 5 seconds', function () {
    Event::fake([DriverLocationUpdated::class]);
    $service = app(LocationService::class);
    actingAsMobile($this->driver);

    $this->postJson('/api/v1/driver/location', ['points' => [ping(['latitude' => -6.9950])]]);
    $service->flush();

    $this->travel(3)->seconds();
    $this->postJson('/api/v1/driver/location', ['points' => [ping(['latitude' => -6.9960])]]);
    expect($service->flush())->toBe(['logs' => 1, 'snapshots' => 0, 'broadcasts' => 0]);
    expect((float) DriverLastLocation::query()->find($this->driver->id)->latitude)->toBe(-6.995);

    $this->travel(3)->seconds();
    $this->postJson('/api/v1/driver/location', ['points' => [ping(['latitude' => -6.9970])]]);
    expect($service->flush())->toBe(['logs' => 1, 'snapshots' => 0, 'broadcasts' => 1]);

    $this->travel(10)->seconds();
    $this->postJson('/api/v1/driver/location', ['points' => [ping(['latitude' => -6.9980])]]);
    expect($service->flush()['snapshots'])->toBe(1);
    expect((float) DriverLastLocation::query()->find($this->driver->id)->latitude)->toBe(-6.998);

    Event::assertDispatchedTimes(DriverLocationUpdated::class, 3);
});

it('tells the app the next ping interval for each state', function (array $points, bool $onDuty, int $expected) {
    actingAsMobile($this->driver);
    DriverProfile::query()->where('user_id', $this->driver->id)->update(['is_on_duty' => $onDuty]);

    $this->postJson('/api/v1/driver/location', ['points' => $points])
        ->assertOk()
        ->assertJsonPath('data.next_interval_seconds', $expected)
        ->assertJsonPath('data.distance_filter_m', 50);
})->with([
    'standby' => [[ping()], false, 25],
    'on duty' => [[ping()], true, 5],
    'stationary' => [[ping(['speed_kmh' => 0.5], 10), ping(['speed_kmh' => 1.2])], false, 60],
    'low battery standby' => [[ping(['battery_level' => 15])], false, 50],
    'low battery on duty' => [[ping(['battery_level' => 10])], true, 10],
]);

it('refuses pings when the driver has no open shift', function () {
    $offShift = User::factory()->driver()->create();
    DriverProfile::factory()->create(['user_id' => $offShift->id]);
    actingAsMobile($offShift);

    $this->postJson('/api/v1/driver/location', ['points' => [ping()]])
        ->assertStatus(409)->assertJsonPath('error.code', 'no_open_shift');
});

it('streams the ambulance position to the reporter of an active report only', function () {
    Event::fake([ReportDriverLocationUpdated::class, DriverLocationUpdated::class]);
    $reporter = User::factory()->reporter()->create();
    $report = Report::factory()->create(['reporter_id' => $reporter->id]);
    Report::query()->whereKey($report->id)->update(['status' => ReportStatus::DalamPerjalanan->value, 'driver_id' => $this->driver->id, 'taken_at' => now()]);
    DriverProfile::query()->where('user_id', $this->driver->id)->update(['is_on_duty' => true]);

    actingAsMobile($this->driver);
    $this->postJson('/api/v1/driver/location', ['points' => [ping(['latitude' => -6.9930, 'heading' => 180])]])->assertOk();
    app(LocationService::class)->flush();

    Event::assertDispatched(ReportDriverLocationUpdated::class, fn (ReportDriverLocationUpdated $event) => $event->reportId === $report->id
        && $event->location['lat'] === -6.993 && $event->location['heading'] === 180 && ! array_key_exists('battery_level', $event->location));
    expect(DriverLocationLog::query()->value('report_id'))->toBe($report->id);

    actingAsMobile($reporter);
    $this->getJson("/api/v1/reporter/reports/{$report->id}/driver-location")
        ->assertOk()
        ->assertJsonPath('data.location.lat', -6.993)
        ->assertJsonPath('data.channel', 'private-report.'.$report->id);

    actingAsMobile(User::factory()->reporter()->create());
    $this->getJson("/api/v1/reporter/reports/{$report->id}/driver-location")->assertForbidden();

    Report::query()->whereKey($report->id)->update(['status' => ReportStatus::Selesai->value, 'arrived_at' => now(), 'completed_at' => now()]);
    actingAsMobile($reporter);
    $this->getJson("/api/v1/reporter/reports/{$report->id}/driver-location")
        ->assertStatus(409)->assertJsonPath('error.code', 'tracking_unavailable');
});

it('authorizes the report channel only for the owner while the report is active', function () {
    $reporter = User::factory()->reporter()->create();
    $report = Report::factory()->create(['reporter_id' => $reporter->id]);
    $authorize = Broadcast::getChannels()->get('report.{report}');

    expect($authorize($reporter, $report))->toBeFalse();

    Report::query()->whereKey($report->id)->update(['status' => ReportStatus::Diambil->value, 'driver_id' => $this->driver->id, 'taken_at' => now()]);
    $report->refresh();

    expect($authorize($reporter, $report))->toBeTrue()
        ->and($authorize(User::factory()->reporter()->create(), $report))->toBeFalse();
});

it('prunes location logs older than the retention period', function () {
    $shiftId = $this->driver->openShift()->value('id');
    $base = ['driver_id' => $this->driver->id, 'shift_id' => $shiftId, 'latitude' => -6.99, 'longitude' => 110.42];

    DriverLocationLog::query()->insert([
        [...$base, 'recorded_at' => now()->subDays(15), 'received_at' => now()->subDays(15)],
        [...$base, 'recorded_at' => now()->subDays(2), 'received_at' => now()->subDays(2)],
    ]);

    $this->artisan('model:prune', ['--model' => [DriverLocationLog::class]])->assertSuccessful();

    expect(DriverLocationLog::query()->count())->toBe(1);
});
