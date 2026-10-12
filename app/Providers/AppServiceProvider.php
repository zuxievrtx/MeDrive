<?php

namespace App\Providers;

use App\Enums\ReportStatus;
use App\Enums\UserRole;
use App\Models\DriverCertification;
use App\Models\DriverShift;
use App\Models\Report;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;
use Illuminate\Pagination\Paginator;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\View;
use Illuminate\Support\ServiceProvider;
use Illuminate\View\View as ViewContract;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Carbon::setLocale('id');
        Model::preventLazyLoading(! $this->app->isProduction());
        Paginator::defaultView('admin.partials.pagination');

        RateLimiter::for('admin-login', function (Request $request): Limit {
            return Limit::perMinute(5)->by(mb_strtolower((string) $request->input('email')).'|'.$request->ip());
        });

        Route::bind('driver', fn (string $value): User => User::query()->where('role', UserRole::Driver)->findOrFail($value));
        Route::bind('reporter', fn (string $value): User => User::query()->where('role', UserRole::Pelapor)->findOrFail($value));
        Route::model('shift', DriverShift::class);
        Route::model('certification', DriverCertification::class);

        View::composer('admin.partials.topbar', function (ViewContract $view): void {
            $view->with([
                'pendingReportCount' => Report::query()->where('status', ReportStatus::Menunggu)->count(),
                'lastReportId' => (int) Report::query()->max('id'),
            ]);
        });
    }
}
