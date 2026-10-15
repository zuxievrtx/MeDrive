<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Ambulance;
use App\Models\AmbulanceType;
use App\Models\Clinic;
use App\Models\Institution;
use App\Models\Report;
use App\Models\ReportType;
use App\Models\User;
use Illuminate\View\View;

/**
 * Halaman dashboard admin hanya kerangka Blade; seluruh data dibaca dan ditulis lewat /api/v1/admin
 * oleh Alpine.js. Binding model di sini sekadar memastikan URL yang tidak valid menghasilkan 404.
 */
class AdminPageController extends Controller
{
    public function dashboard(): View
    {
        return view('admin.dashboard');
    }

    public function drivers(): View
    {
        return view('admin.drivers.index');
    }

    public function createDriver(): View
    {
        return view('admin.drivers.create');
    }

    public function showDriver(User $driver): View
    {
        return view('admin.drivers.show', ['driverId' => $driver->id]);
    }

    public function editDriver(User $driver): View
    {
        return view('admin.drivers.edit', ['driverId' => $driver->id]);
    }

    public function institutions(): View
    {
        return view('admin.institutions.index');
    }

    public function institutionForm(?Institution $institution = null): View
    {
        return view('admin.institutions.form', ['institutionId' => $institution?->id]);
    }

    public function clinics(): View
    {
        return view('admin.clinics.index');
    }

    public function clinicForm(?Clinic $clinic = null): View
    {
        return view('admin.clinics.form', ['clinicId' => $clinic?->id]);
    }

    public function ambulances(): View
    {
        return view('admin.ambulances.index');
    }

    public function ambulanceForm(?Ambulance $ambulance = null): View
    {
        return view('admin.ambulances.form', ['ambulanceId' => $ambulance?->id]);
    }

    public function ambulanceTypes(): View
    {
        return view('admin.ambulance-types.index');
    }

    public function editAmbulanceType(AmbulanceType $ambulanceType): View
    {
        return view('admin.ambulance-types.edit', ['ambulanceTypeId' => $ambulanceType->id]);
    }

    public function reportTypes(): View
    {
        return view('admin.report-types.index');
    }

    public function editReportType(ReportType $reportType): View
    {
        return view('admin.report-types.edit', ['reportTypeId' => $reportType->id]);
    }

    public function reports(): View
    {
        return view('admin.reports.index');
    }

    public function showReport(Report $report): View
    {
        return view('admin.reports.show', ['reportId' => $report->id]);
    }

    public function tracking(): View
    {
        return view('admin.tracking.index');
    }

    public function locationLogs(): View
    {
        return view('admin.location-logs.index');
    }

    public function statistics(): View
    {
        return view('admin.statistics.index');
    }

    public function activityLogs(): View
    {
        return view('admin.activity-logs.index');
    }

    public function reporters(): View
    {
        return view('admin.users.index');
    }

    public function showReporter(User $reporter): View
    {
        return view('admin.users.show', ['reporterId' => $reporter->id]);
    }
}
