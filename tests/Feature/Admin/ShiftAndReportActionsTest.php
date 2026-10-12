<?php

use App\Enums\ReportStatus;
use App\Enums\ShiftEndReason;
use App\Models\AdminActivityLog;
use App\Models\DriverShift;
use App\Models\Report;
use App\Models\ReportStatusLog;

beforeEach(function () {
    $this->admin = seedDemoAndGetAdmin();
});

it('ends an open shift as admin', function () {
    $this->actingAs($this->admin)->post(route('admin.shifts.end', 2))->assertSessionHas('success');

    $shift = DriverShift::query()->findOrFail(2);
    expect($shift->ended_at)->not->toBeNull()
        ->and($shift->end_reason)->toBe(ShiftEndReason::DihentikanAdmin)
        ->and(AdminActivityLog::query()->where('action', 'shift.ended')->where('subject_id', 2)->exists())->toBeTrue();
});

it('does not end a shift that is already closed', function () {
    $endedAt = DriverShift::query()->findOrFail(1)->ended_at;

    $this->actingAs($this->admin)->post(route('admin.shifts.end', 1))->assertSessionHas('error');

    expect(DriverShift::query()->findOrFail(1)->ended_at->equalTo($endedAt))->toBeTrue()
        ->and(AdminActivityLog::query()->where('action', 'shift.ended')->exists())->toBeFalse();
});

it('cancels a waiting report with a status log and activity log', function () {
    $this->actingAs($this->admin)
        ->post(route('admin.reports.cancel', 4), ['reason' => 'Laporan ganda dari pelapor yang sama'])
        ->assertRedirect(route('admin.reports.show', 4));

    $report = Report::query()->findOrFail(4);
    expect($report->status)->toBe(ReportStatus::Dibatalkan)
        ->and($report->taken_at)->toBeNull();

    $log = ReportStatusLog::query()->where('report_id', 4)->latest('id')->first();
    expect($log->from_status)->toBe(ReportStatus::Menunggu)
        ->and($log->to_status)->toBe(ReportStatus::Dibatalkan)
        ->and($log->changed_by)->toBe($this->admin->id)
        ->and($log->note)->toContain('Laporan ganda');

    expect(AdminActivityLog::query()->where('action', 'report.cancelled')->where('subject_id', 4)->exists())->toBeTrue();
});

it('never cancels a report that a driver already took', function () {
    $this->actingAs($this->admin)
        ->post(route('admin.reports.cancel', 3), ['reason' => 'Coba batalkan laporan aktif'])
        ->assertSessionHas('error');

    expect(Report::query()->findOrFail(3)->status)->toBe(ReportStatus::DalamPerjalanan)
        ->and(AdminActivityLog::query()->where('action', 'report.cancelled')->exists())->toBeFalse();
});

it('requires a cancellation reason', function () {
    $this->actingAs($this->admin)
        ->post(route('admin.reports.cancel', 4), ['reason' => ''])
        ->assertSessionHasErrors('reason');

    expect(Report::query()->findOrFail(4)->status)->toBe(ReportStatus::Menunggu);
});

it('disables the cancel button for reports that are not waiting', function () {
    $this->actingAs($this->admin)->get(route('admin.reports.show', 3))->assertSee('Tidak tersedia: laporan berstatus dalam perjalanan');
    $this->actingAs($this->admin)->get(route('admin.reports.show', 4))->assertDontSee('Tidak tersedia: laporan berstatus');
});

it('exports the filtered report list as csv', function () {
    $response = $this->actingAs($this->admin)->get(route('admin.reports.export', ['status' => 'selesai']));

    $response->assertOk()->assertHeader('content-type', 'text/csv; charset=UTF-8');
    $csv = $response->streamedContent();

    expect($csv)->toContain('MDR-260928-0001')
        ->toContain('MDR-261008-0001')
        ->not->toContain('MDR-261009-0002');
});

it('returns 404 for attachments that are missing from storage and keeps them off public urls', function () {
    $this->actingAs($this->admin)->get(route('admin.reports.attachments.show', [1, 1]))->assertNotFound();
    $this->get('/storage/reports/2026/09/1/kejadian-1.jpg')->assertNotFound();
});

it('scopes attachments to their report', function () {
    $this->actingAs($this->admin)->get(route('admin.reports.attachments.show', [2, 1]))->assertNotFound();
});
