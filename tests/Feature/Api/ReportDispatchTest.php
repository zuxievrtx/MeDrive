<?php

use App\Enums\DispatchResponse;
use App\Enums\ReportStatus;
use App\Events\DispatchEscalated;
use App\Events\ReportCreated;
use App\Jobs\SendFcmNotification;
use App\Models\DriverProfile;
use App\Models\Report;
use App\Models\ReportDispatch;
use App\Models\ReportStatusLog;
use App\Models\User;
use App\Services\EscalationService;
use App\Services\ReportService;
use Database\Seeders\MasterDataSeeder;
use Illuminate\Broadcasting\BroadcastManager;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\Storage;

const SITE_LAT = -6.9900;
const SITE_LNG = 110.4200;

beforeEach(function () {
    $this->seed(MasterDataSeeder::class);
    Storage::fake('local');
    Queue::fake([SendFcmNotification::class]);
    $this->reporter = User::factory()->reporter()->create();
});

function medicalReportPayload(array $overrides = []): array
{
    return array_merge([
        'report_type_code' => 'medis_darurat',
        'latitude' => SITE_LAT,
        'longitude' => SITE_LNG,
        'address' => 'Jl. Pemuda, Semarang',
        'description' => 'Pria 55 tahun pingsan di trotoar.',
        'details' => ['medical_category' => 'tidak_sadar', 'has_medical_history' => false],
    ], $overrides);
}

it('creates a report with detail, status log and attachments in one go', function () {
    Event::fake([ReportCreated::class]);
    actingAsMobile($this->reporter);

    $response = $this->post('/api/v1/reporter/reports', medicalReportPayload([
        'photos' => [UploadedFile::fake()->image('tkp-1.jpg'), UploadedFile::fake()->image('tkp-2.jpg')],
    ]), ['Accept' => 'application/json']);

    $response->assertCreated()
        ->assertJsonPath('data.status.value', 'menunggu')
        ->assertJsonPath('data.details.kind', 'medis')
        ->assertJsonPath('data.details.medical_category.value', 'tidak_sadar')
        ->assertJsonCount(2, 'data.attachments')
        ->assertJsonPath('data.timeline.0.to_status.value', 'menunggu');

    expect($response->json('data.code'))->toMatch('/^MDR-\d{6}-0001$/');
    Event::assertDispatched(ReportCreated::class);
});

it('requires a destination for report types that need one', function () {
    actingAsMobile($this->reporter);

    $this->postJson('/api/v1/reporter/reports', [
        'report_type_code' => 'ibu_hamil',
        'latitude' => SITE_LAT,
        'longitude' => SITE_LNG,
        'description' => 'Kontraksi tiap 5 menit.',
    ])->assertStatus(400)->assertJsonValidationErrors(['destination_name', 'destination_lat'], 'error.details');

    $this->postJson('/api/v1/reporter/reports', [
        'report_type_code' => 'ibu_hamil',
        'latitude' => SITE_LAT,
        'longitude' => SITE_LNG,
        'description' => 'Kontraksi tiap 5 menit.',
        'destination_clinic_id' => 1,
        'details' => ['gestational_age_weeks' => 38],
    ])->assertCreated()->assertJsonPath('data.destination.name', 'Puskesmas Tembalang');
});

it('generates unique sequential codes even when the next number is already taken', function () {
    $service = app(ReportService::class);
    $code = $service->nextCode();

    // Simulasi balapan: kode berikutnya sudah dipakai proses lain sesaat sebelum insert.
    Report::factory()->create(['code' => $code, 'reporter_id' => $this->reporter->id]);

    actingAsMobile($this->reporter);
    $created = $this->postJson('/api/v1/reporter/reports', medicalReportPayload())->assertCreated()->json('data.code');

    expect($created)->not->toBe($code)->and(substr($created, -4))->toBe('0002');
});

it('still creates and dispatches a report when the Reverb server is down', function () {
    config([
        'broadcasting.default' => 'reverb',
        'broadcasting.connections.reverb.options.host' => '127.0.0.1',
        'broadcasting.connections.reverb.options.port' => 1,
        'broadcasting.connections.reverb.options.scheme' => 'http',
    ]);
    app(BroadcastManager::class)->purge('reverb');
    Log::spy();
    $driver = onShiftDriver(...pointNorthOf(SITE_LAT, SITE_LNG, 1));

    actingAsMobile($this->reporter);
    $reportId = $this->postJson('/api/v1/reporter/reports', medicalReportPayload())->assertCreated()->json('data.id');

    expect(ReportDispatch::query()->where('report_id', $reportId)->where('driver_id', $driver->id)->exists())->toBeTrue();
    Log::shouldHaveReceived('warning')->withArgs(fn (string $message): bool => str_contains($message, 'Broadcast realtime gagal'))->atLeast()->once();
});

it('replays the same response for a repeated Idempotency-Key', function () {
    actingAsMobile($this->reporter);
    $headers = ['Idempotency-Key' => 'laporan-abc-123'];

    $first = $this->postJson('/api/v1/reporter/reports', medicalReportPayload(), $headers)->assertCreated();
    $second = $this->postJson('/api/v1/reporter/reports', medicalReportPayload(), $headers)->assertCreated();

    $second->assertHeader('Idempotent-Replayed', 'true');
    expect($second->json('data.code'))->toBe($first->json('data.code'))
        ->and(Report::query()->count())->toBe(1);

    $this->postJson('/api/v1/reporter/reports', medicalReportPayload(['description' => 'Berbeda']), $headers)
        ->assertUnprocessable()->assertJsonPath('error.code', 'idempotency_key_reused');
});

it('broadcasts only to eligible drivers, nearest first', function () {
    [$nearLat, $nearLng] = pointNorthOf(SITE_LAT, SITE_LNG, 1);
    [$midLat, $midLng] = pointNorthOf(SITE_LAT, SITE_LNG, 3);

    $near = onShiftDriver($nearLat, $nearLng);
    $mid = onShiftDriver($midLat, $midLng);
    $funeralOnly = onShiftDriver(SITE_LAT, SITE_LNG, ambulanceTypeId: 3);
    $busy = onShiftDriver(SITE_LAT, SITE_LNG);
    DriverProfile::query()->where('user_id', $busy->id)->update(['is_on_duty' => true]);
    $inactive = onShiftDriver(SITE_LAT, SITE_LNG, userAttributes: ['account_status' => 'nonaktif']);
    $offShift = User::factory()->driver()->create();
    DriverProfile::factory()->create(['user_id' => $offShift->id]);

    actingAsMobile($this->reporter);
    $reportId = $this->postJson('/api/v1/reporter/reports', medicalReportPayload())->assertCreated()->json('data.id');

    $dispatches = ReportDispatch::query()->where('report_id', $reportId)->orderBy('distance_km')->get();

    expect($dispatches->pluck('driver_id')->all())->toBe([$near->id, $mid->id])
        ->and((float) $dispatches[0]->distance_km)->toEqualWithDelta(1.0, 0.05)
        ->and($dispatches->pluck('response')->unique()->all())->toBe([DispatchResponse::Menunggu]);

    Queue::assertPushed(SendFcmNotification::class, fn (SendFcmNotification $job) => $job->userId === $near->id && $job->data['distance_km'] == 1.0);
    Queue::assertNotPushed(SendFcmNotification::class, fn (SendFcmNotification $job) => in_array($job->userId, [$funeralOnly->id, $busy->id, $inactive->id], true));
});

it('never sends funeral reports to emergency ambulances', function () {
    $emergency = onShiftDriver(SITE_LAT, SITE_LNG, ambulanceTypeId: 1);
    $hearse = onShiftDriver(...pointNorthOf(SITE_LAT, SITE_LNG, 2), ambulanceTypeId: 3);

    actingAsMobile($this->reporter);
    $reportId = $this->postJson('/api/v1/reporter/reports', [
        'report_type_code' => 'pengantaran_jenazah',
        'latitude' => SITE_LAT,
        'longitude' => SITE_LNG,
        'description' => 'Antar jenazah ke rumah duka.',
        'destination_name' => 'Rumah duka',
        'destination_lat' => -7.0,
        'destination_lng' => 110.45,
        'details' => [
            'deceased_name' => 'Alm. Budi',
            'pickup_place_type' => 'rumah_sakit',
            'family_contact_name' => 'Sari',
            'family_contact_phone' => '0812000000',
        ],
    ])->assertCreated()->json('data.id');

    expect(ReportDispatch::query()->where('report_id', $reportId)->pluck('driver_id')->all())->toBe([$hearse->id])
        ->and(ReportDispatch::query()->where('driver_id', $emergency->id)->exists())->toBeFalse();
});

it('escalates immediately when nobody is inside the first radius', function () {
    Event::fake([DispatchEscalated::class]);
    $far = onShiftDriver(...pointNorthOf(SITE_LAT, SITE_LNG, 8));

    actingAsMobile($this->reporter);
    $reportId = $this->postJson('/api/v1/reporter/reports', medicalReportPayload())->assertCreated()->json('data.id');

    expect(ReportDispatch::query()->where('report_id', $reportId)->pluck('driver_id')->all())->toBe([$far->id]);
    Event::assertDispatched(DispatchEscalated::class, fn (DispatchEscalated $event) => $event->round === 2 && $event->radiusKm === 10.0 && $event->recipients === 1);
});

it('escalates to a wider radius and only to new drivers after the round interval', function () {
    Event::fake([DispatchEscalated::class]);
    $near = onShiftDriver(...pointNorthOf(SITE_LAT, SITE_LNG, 2));
    $far = onShiftDriver(...pointNorthOf(SITE_LAT, SITE_LNG, 8));

    actingAsMobile($this->reporter);
    $reportId = $this->postJson('/api/v1/reporter/reports', medicalReportPayload())->assertCreated()->json('data.id');

    expect(ReportDispatch::query()->where('report_id', $reportId)->pluck('driver_id')->all())->toBe([$near->id]);

    // Medis darurat prioritas 1: jeda ronde 60 detik.
    $this->travel(30)->seconds();
    app(EscalationService::class)->run();
    expect(ReportDispatch::query()->where('report_id', $reportId)->count())->toBe(1);

    $this->travel(31)->seconds();
    app(EscalationService::class)->run();

    $dispatches = ReportDispatch::query()->where('report_id', $reportId)->get()->keyBy('driver_id');
    expect($dispatches)->toHaveCount(2)
        ->and($dispatches[$near->id]->response)->toBe(DispatchResponse::Kedaluwarsa)
        ->and($dispatches[$far->id]->response)->toBe(DispatchResponse::Menunggu);

    Event::assertDispatched(DispatchEscalated::class, fn (DispatchEscalated $event) => $event->round === 2 && $event->radiusKm === 10.0 && ! $event->isFinal);
});

it('raises the final alarm when no driver exists in any round', function () {
    Event::fake([DispatchEscalated::class]);

    actingAsMobile($this->reporter);
    $this->postJson('/api/v1/reporter/reports', medicalReportPayload())->assertCreated();

    Event::assertDispatched(DispatchEscalated::class, fn (DispatchEscalated $event) => $event->round === 4 && $event->radiusKm === null && $event->isFinal);
});

it('lets exactly one driver win when two accept the same report', function () {
    $first = onShiftDriver(...pointNorthOf(SITE_LAT, SITE_LNG, 1));
    $second = onShiftDriver(...pointNorthOf(SITE_LAT, SITE_LNG, 2));

    actingAsMobile($this->reporter);
    $reportId = $this->postJson('/api/v1/reporter/reports', medicalReportPayload())->assertCreated()->json('data.id');
    $dispatches = ReportDispatch::query()->where('report_id', $reportId)->get()->keyBy('driver_id');

    actingAsMobile($second);
    $this->postJson("/api/v1/driver/dispatches/{$dispatches[$second->id]->id}/accept")
        ->assertOk()
        ->assertJsonPath('data.status.value', 'diambil');

    actingAsMobile($first);
    $this->postJson("/api/v1/driver/dispatches/{$dispatches[$first->id]->id}/accept")
        ->assertStatus(409)
        ->assertJsonPath('error.code', 'too_late');

    $report = Report::query()->findOrFail($reportId);
    expect($report->status)->toBe(ReportStatus::Diambil)
        ->and($report->driver_id)->toBe($second->id)
        ->and($report->ambulance_id)->toBe($second->openShift()->value('ambulance_id'))
        ->and(DriverProfile::query()->where('user_id', $second->id)->value('is_on_duty'))->toBeTrue()
        ->and(DriverProfile::query()->where('user_id', $first->id)->value('is_on_duty'))->toBeFalse()
        ->and($dispatches[$second->id]->fresh()->response)->toBe(DispatchResponse::Diambil)
        ->and($dispatches[$first->id]->fresh()->response)->toBe(DispatchResponse::KalahCepat)
        ->and(ReportStatusLog::query()->where('report_id', $reportId)->where('to_status', 'diambil')->value('changed_by'))->toBe($second->id);
});

it('walks a report through the driver status flow', function () {
    $driver = onShiftDriver(...pointNorthOf(SITE_LAT, SITE_LNG, 1));
    actingAsMobile($this->reporter);
    $reportId = $this->postJson('/api/v1/reporter/reports', medicalReportPayload())->assertCreated()->json('data.id');
    $dispatchId = ReportDispatch::query()->where('report_id', $reportId)->value('id');

    actingAsMobile($driver);
    $this->postJson("/api/v1/driver/dispatches/{$dispatchId}/accept")->assertOk();

    $this->postJson("/api/v1/driver/reports/{$reportId}/status", ['status' => 'tiba_di_lokasi'])
        ->assertStatus(409)->assertJsonPath('error.code', 'invalid_transition');

    $this->postJson("/api/v1/driver/reports/{$reportId}/status", ['status' => 'dalam_perjalanan'])->assertOk();
    $this->postJson("/api/v1/driver/reports/{$reportId}/status", ['status' => 'tiba_di_lokasi'])->assertOk()
        ->assertJsonPath('data.status.value', 'tiba_di_lokasi');

    $this->postJson("/api/v1/driver/reports/{$reportId}/status", ['status' => 'selesai'])
        ->assertUnprocessable()->assertJsonPath('error.code', 'patient_handover_required');

    $patientId = $this->postJson("/api/v1/driver/reports/{$reportId}/patients", ['gender' => 'L', 'age_estimate' => 55, 'consciousness' => 'tidak_sadar'])
        ->assertCreated()->json('data.id');
    $this->putJson("/api/v1/driver/patients/{$patientId}", ['handed_over_to' => 'IGD RS Kariadi'])->assertOk()
        ->assertJsonPath('data.handed_over_to', 'IGD RS Kariadi');

    $this->post("/api/v1/driver/reports/{$reportId}/attachments", ['photos' => [UploadedFile::fake()->image('tangani.jpg')]], ['Accept' => 'application/json'])
        ->assertCreated()->assertJsonPath('data.0.type.value', 'foto_penanganan');

    $this->postJson("/api/v1/driver/reports/{$reportId}/status", ['status' => 'selesai'])->assertOk();

    $report = Report::query()->findOrFail($reportId);
    expect($report->status)->toBe(ReportStatus::Selesai)
        ->and($report->arrived_at)->not->toBeNull()
        ->and($report->completed_at)->not->toBeNull()
        ->and(DriverProfile::query()->where('user_id', $driver->id)->value('is_on_duty'))->toBeFalse()
        ->and(ReportStatusLog::query()->where('report_id', $reportId)->count())->toBe(5);
});

it('replays a repeated driver status change instead of failing on the second tap', function () {
    $driver = onShiftDriver(...pointNorthOf(SITE_LAT, SITE_LNG, 1));
    actingAsMobile($this->reporter);
    $reportId = $this->postJson('/api/v1/reporter/reports', medicalReportPayload())->assertCreated()->json('data.id');

    actingAsMobile($driver);
    $this->postJson('/api/v1/driver/dispatches/'.ReportDispatch::query()->where('report_id', $reportId)->value('id').'/accept')->assertOk();

    $headers = ['Idempotency-Key' => 'status-berangkat-1'];
    $this->postJson("/api/v1/driver/reports/{$reportId}/status", ['status' => 'dalam_perjalanan'], $headers)->assertOk();
    $this->postJson("/api/v1/driver/reports/{$reportId}/status", ['status' => 'dalam_perjalanan'], $headers)
        ->assertOk()
        ->assertHeader('Idempotent-Replayed', 'true');

    expect(ReportStatusLog::query()->where('report_id', $reportId)->where('to_status', 'dalam_perjalanan')->count())->toBe(1);
});

it('requires the delivery step for report types with a destination', function () {
    $driver = onShiftDriver(...pointNorthOf(SITE_LAT, SITE_LNG, 1));
    actingAsMobile($this->reporter);
    $reportId = $this->postJson('/api/v1/reporter/reports', [
        'report_type_code' => 'ibu_hamil',
        'latitude' => SITE_LAT,
        'longitude' => SITE_LNG,
        'description' => 'Ketuban pecah.',
        'destination_clinic_id' => 1,
    ])->assertCreated()->json('data.id');

    actingAsMobile($driver);
    $this->postJson('/api/v1/driver/dispatches/'.ReportDispatch::query()->where('report_id', $reportId)->value('id').'/accept')->assertOk();
    $this->postJson("/api/v1/driver/reports/{$reportId}/status", ['status' => 'dalam_perjalanan'])->assertOk();
    $this->postJson("/api/v1/driver/reports/{$reportId}/status", ['status' => 'tiba_di_lokasi'])->assertOk();
    $this->postJson("/api/v1/driver/reports/{$reportId}/patients", ['name' => 'Bu Ani', 'handed_over_to' => 'Bidan'])->assertCreated();

    $this->postJson("/api/v1/driver/reports/{$reportId}/status", ['status' => 'selesai'])
        ->assertUnprocessable()->assertJsonPath('error.code', 'destination_required');
});

it('only shows reporters their own reports', function () {
    $mine = Report::factory()->create(['reporter_id' => $this->reporter->id]);
    $other = Report::factory()->create();

    actingAsMobile($this->reporter);
    $this->getJson('/api/v1/reporter/reports')->assertOk()->assertJsonCount(1, 'data')->assertJsonPath('meta.pagination.total', 1);
    $this->getJson("/api/v1/reporter/reports/{$mine->id}")->assertOk();
    $this->getJson("/api/v1/reporter/reports/{$other->id}")->assertForbidden()->assertJsonPath('error.code', 'not_your_report');
});
