<?php

namespace App\Http\Controllers\Admin;

use App\Enums\ReportStatus;
use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\CancelReportRequest;
use App\Models\Clinic;
use App\Models\Report;
use App\Models\ReportAttachment;
use App\Models\ReportStatusLog;
use App\Models\ReportType;
use App\Models\User;
use App\Services\AdminLogger;
use App\Services\ReportQuery;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends Controller
{
    public function index(Request $request): View
    {
        Gate::authorize('viewAny', Report::class);

        $filters = $request->validate(ReportQuery::rules());

        $reports = ReportQuery::filtered($filters)
            ->with(['reportType:id,name,icon,color', 'reporter:id,name,phone', 'driver:id,name', 'ambulance:id,plate_number'])
            ->latest()
            ->orderByDesc('id')
            ->paginate(20)
            ->withQueryString();

        return view('admin.reports.index', [
            'reports' => $reports,
            'filters' => $filters,
            'reportTypes' => ReportType::query()->orderBy('sort_order')->get(['id', 'name']),
            'statuses' => ReportStatus::cases(),
            'drivers' => User::query()->where('role', UserRole::Driver)->orderBy('name')->get(['id', 'name']),
            'clinics' => Clinic::query()->orderBy('name')->get(['id', 'name']),
        ]);
    }

    public function show(Report $report): View
    {
        Gate::authorize('view', $report);

        $report->load([
            'reportType.ambulanceTypes:id,name',
            'reporter.devices',
            'driver.driverProfile.clinic.institution',
            'driver.lastLocation',
            'ambulance.ambulanceType',
            'ambulance.clinic',
            'accidentDetail',
            'medicalDetail',
            'maternityDetail.destinationClinic',
            'funeralDetail',
            'patients',
            'attachments',
            'statusLogs' => fn ($query) => $query->with('changer:id,name,role')->orderBy('created_at')->orderBy('id'),
            'dispatches' => fn ($query) => $query->with('driver:id,name', 'shift.ambulance:id,plate_number')->orderBy('distance_km'),
        ]);

        return view('admin.reports.show', ['report' => $report]);
    }

    /**
     * Admin hanya boleh membatalkan laporan yang masih menunggu. UPDATE bersyarat mencegah balapan
     * dengan driver yang menekan "ambil" di saat bersamaan (constraint DB: dibatalkan wajib taken_at NULL).
     */
    public function cancel(CancelReportRequest $request, Report $report, AdminLogger $logger): RedirectResponse
    {
        $decision = Gate::inspect('cancel', $report);

        if ($decision->denied()) {
            return back()->with('error', $decision->message());
        }

        $cancelled = DB::transaction(function () use ($request, $report, $logger): bool {
            $updated = Report::query()
                ->whereKey($report->id)
                ->where('status', ReportStatus::Menunggu)
                ->whereNull('taken_at')
                ->update(['status' => ReportStatus::Dibatalkan, 'updated_at' => now()]);

            if ($updated !== 1) {
                return false;
            }

            ReportStatusLog::create([
                'report_id' => $report->id,
                'from_status' => ReportStatus::Menunggu,
                'to_status' => ReportStatus::Dibatalkan,
                'changed_by' => $request->user()->id,
                'note' => 'Dibatalkan admin: '.$request->validated('reason'),
            ]);

            $logger->log('report.cancelled', $report, "Membatalkan laporan {$report->code}: ".$request->validated('reason'));

            return true;
        });

        if (! $cancelled) {
            return back()->with('error', "Laporan {$report->code} sudah diambil driver sehingga tidak bisa dibatalkan.");
        }

        return redirect()->route('admin.reports.show', $report)->with('success', "Laporan {$report->code} dibatalkan.");
    }

    public function export(Request $request): StreamedResponse
    {
        Gate::authorize('export', Report::class);

        $filters = $request->validate(ReportQuery::rules());
        $query = ReportQuery::filtered($filters)
            ->with(['reportType:id,name', 'reporter:id,name,phone', 'driver:id,name', 'ambulance:id,plate_number,clinic_id', 'ambulance.clinic:id,name'])
            ->latest()
            ->orderByDesc('id');

        $filename = 'laporan-medrive-'.now()->format('Ymd-His').'.csv';

        return response()->streamDownload(function () use ($query): void {
            $output = fopen('php://output', 'w');
            // BOM agar Excel membaca UTF-8 dengan benar.
            fwrite($output, "\xEF\xBB\xBF");
            fputcsv($output, ['Kode', 'Jenis', 'Status', 'Pelapor', 'Telepon pelapor', 'Driver', 'Nopol', 'Klinik armada', 'Alamat', 'Dibuat', 'Diambil', 'Tiba', 'Selesai', 'Respons (menit)']);

            foreach ($query->lazy(500) as $report) {
                fputcsv($output, [
                    $report->code,
                    $report->reportType->name,
                    $report->status->label(),
                    $report->reporter->name,
                    $report->reporter->phone,
                    $report->driver?->name,
                    $report->ambulance?->plate_number,
                    $report->ambulance?->clinic?->name,
                    $report->address,
                    $report->created_at?->format('Y-m-d H:i:s'),
                    $report->taken_at?->format('Y-m-d H:i:s'),
                    $report->arrived_at?->format('Y-m-d H:i:s'),
                    $report->completed_at?->format('Y-m-d H:i:s'),
                    $report->response_time_minutes,
                ]);
            }

            fclose($output);
        }, $filename, ['Content-Type' => 'text/csv; charset=UTF-8']);
    }

    /**
     * Lampiran (foto korban, surat kematian) hanya dibuka lewat route ber-otorisasi, tidak lewat URL publik.
     */
    public function attachment(Request $request, Report $report, ReportAttachment $attachment): StreamedResponse
    {
        Gate::authorize('view', $report);

        abort_unless(Storage::disk('local')->exists($attachment->file_path), 404, 'Berkas lampiran tidak ditemukan di penyimpanan.');

        $filename = $report->code.'-'.$attachment->type.'.'.pathinfo($attachment->file_path, PATHINFO_EXTENSION);
        $headers = ['Content-Type' => $attachment->mime_type, 'Cache-Control' => 'private, max-age=600'];

        return $attachment->isImage() && ! $request->boolean('download')
            ? Storage::disk('local')->response($attachment->file_path, $filename, $headers)
            : Storage::disk('local')->download($attachment->file_path, $filename, $headers);
    }
}
