<?php

use App\Events\ReportCreated;
use App\Models\DriverLocationLog;
use App\Models\Report;
use App\Models\User;
use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\Event;

beforeEach(function () {
    $this->admin = seedDemoAndGetAdmin();
});

it('returns active drivers from driver_last_locations for the live map', function () {
    $response = $this->actingAs($this->admin)->getJson(route('admin.tracking.data'))->assertOk();

    $drivers = collect($response->json('drivers'))->keyBy('driver_id');

    expect($drivers->keys()->sort()->values()->all())->toBe([3, 4])
        ->and($drivers[4]['is_on_duty'])->toBeTrue()
        ->and($drivers[4]['report_code'])->toBe('MDR-261009-0001')
        ->and($drivers[4]['plate_number'])->toBe('H 5678 CD')
        ->and($drivers[4]['heading'])->toBe(160)
        ->and($drivers[3]['is_on_duty'])->toBeFalse();

    expect($response->json('reports.0.code'))->toBe('MDR-261009-0001');
});

it('returns the route of a report from the location logs', function () {
    $response = $this->actingAs($this->admin)
        ->getJson(route('admin.location-logs.data', ['driver_id' => 4, 'report_id' => 3]))
        ->assertOk();

    expect($response->json('summary.points'))->toBe(4)
        ->and($response->json('summary.distance_km'))->toBeGreaterThan(0)
        ->and($response->json('summary.max_speed_kmh'))->toEqual(38.5)
        ->and($response->json('summary.last_battery'))->toBe(77)
        ->and($response->json('points'))->toHaveCount(4);
});

it('limits location log ranges to the retention period', function () {
    $this->actingAs($this->admin)
        ->getJson(route('admin.location-logs.data', ['driver_id' => 4, 'from' => now()->subDays(20)->toDateTimeString(), 'to' => now()->toDateTimeString()]))
        ->assertUnprocessable()
        ->assertJsonValidationErrors('from');
});

it('flags mock locations in the ping table', function () {
    DriverLocationLog::query()->where('driver_id', 4)->limit(1)->update(['is_mock_location' => true]);

    $this->actingAs($this->admin)
        ->get(route('admin.location-logs.index', ['driver_id' => 4, 'report_id' => 3]))
        ->assertOk()
        ->assertSee('GPS PALSU')
        ->assertSee('Terdeteksi 1 titik GPS palsu');
});

it('serves statistics for every range', function (array $params) {
    $this->actingAs($this->admin)
        ->getJson(route('admin.statistics.data', $params))
        ->assertOk()
        ->assertJsonStructure([
            'range' => ['label', 'granularity'],
            'labels',
            'summary' => ['total' => ['value', 'previous', 'delta'], 'completed', 'cancelled', 'avg_duration_minutes', 'avg_response_minutes'],
            'series' => ['current', 'previous'],
            'by_type', 'by_type_series', 'response_times' => ['taken', 'arrived'],
            'top_drivers', 'by_clinic', 'by_institution', 'by_hour', 'by_status',
        ]);
})->with([
    'today' => [['range' => 'today']],
    '7 days' => [['range' => '7d']],
    '30 days' => [['range' => '30d']],
    'this month' => [['range' => 'this_month']],
    'this year' => [['range' => 'this_year']],
    'chosen year' => [['range' => 'year', 'year' => 2026]],
    'custom' => [['range' => 'custom', 'from' => '2026-09-01', 'to' => '2026-10-31']],
]);

it('aggregates the demo reports correctly for 2026', function () {
    $response = $this->actingAs($this->admin)->getJson(route('admin.statistics.data', ['range' => 'year', 'year' => 2026]))->assertOk();

    expect($response->json('range.granularity'))->toBe('month')
        ->and($response->json('summary.total.value'))->toBe(4)
        ->and($response->json('summary.completed.value'))->toBe(2)
        ->and(collect($response->json('by_type'))->pluck('total', 'name')->all())->toBe([
            'Kecelakaan' => 1, 'Medis Darurat' => 1, 'Ibu Hamil' => 1, 'Pengantaran Jenazah' => 1,
        ])
        ->and(array_sum($response->json('by_hour')))->toBe(4)
        ->and($response->json('by_hour.8'))->toBe(2);

    $rina = collect($response->json('top_drivers'))->firstWhere('driver_id', 4);
    expect($rina['won'])->toBe(1)->and($rina['win_ratio'])->toEqual(100);

    $andi = collect($response->json('top_drivers'))->firstWhere('driver_id', 3);
    expect($andi['lost'])->toBe(1);
});

it('uses hourly buckets for today and daily buckets for 30 days', function () {
    expect($this->actingAs($this->admin)->getJson(route('admin.statistics.data', ['range' => 'today']))->json('range.granularity'))->toBe('hour');
    expect($this->actingAs($this->admin)->getJson(route('admin.statistics.data', ['range' => '30d']))->json('labels'))->toHaveCount(30);
});

it('rejects a custom range without dates', function () {
    $this->actingAs($this->admin)->getJson(route('admin.statistics.data', ['range' => 'custom']))->assertUnprocessable();
});

it('exports statistics as csv', function () {
    $csv = $this->actingAs($this->admin)->get(route('admin.statistics.export', ['range' => 'year', 'year' => 2026]))->assertOk()->streamedContent();

    expect($csv)->toContain('Total laporan')->toContain('Kecelakaan');
});

it('broadcasts ReportCreated when a reporter creates a report', function () {
    Event::fake([ReportCreated::class]);

    Report::factory()->create(['reporter_id' => 1]);

    Event::assertDispatched(ReportCreated::class);
});

it('authorizes the private admin channels only for admins', function (string $channel) {
    $authorize = Broadcast::getChannels()->get($channel);

    expect($authorize($this->admin))->toBeTrue()
        ->and($authorize(User::query()->find(3)))->toBeFalse()
        ->and($authorize(User::factory()->admin()->inactive()->create()))->toBeFalse();
})->with(['admin', 'admin.tracking']);
