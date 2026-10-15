<?php

namespace App\Providers;

use App\Enums\ReportStatus;
use App\Enums\UserRole;
use App\Models\DriverCertification;
use App\Models\DriverShift;
use App\Models\Report;
use App\Models\ReportDispatch;
use App\Models\ReportPatient;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;
use Illuminate\Pagination\Paginator;
use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\View;
use Illuminate\Support\ServiceProvider;
use Illuminate\View\View as ViewContract;
use Laravel\Sanctum\PersonalAccessToken;

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

        $this->configureApiRateLimits();

        Route::bind('driver', fn (string $value): User => User::query()->where('role', UserRole::Driver)->findOrFail($value));
        Route::bind('reporter', fn (string $value): User => User::query()->where('role', UserRole::Pelapor)->findOrFail($value));
        Route::model('shift', DriverShift::class);
        Route::model('certification', DriverCertification::class);
        Route::model('dispatch', ReportDispatch::class);
        Route::model('patient', ReportPatient::class);

        // Otorisasi kanal privat Reverb untuk aplikasi mobile (token Bearer): /api/v1/broadcasting/auth.
        Broadcast::routes(['prefix' => 'api/v1', 'middleware' => ['auth:sanctum']]);

        View::composer('admin.partials.topbar', function (ViewContract $view): void {
            $view->with([
                'pendingReportCount' => Report::query()->where('status', ReportStatus::Menunggu)->count(),
                'lastReportId' => (int) Report::query()->max('id'),
            ]);
        });
    }

    /**
     * Batas permintaan API per token (atau per IP untuk endpoint publik).
     */
    private function configureApiRateLimits(): void
    {
        // Token Bearer punya id sendiri; sesi cookie admin memakai TransientToken sehingga dikunci per user.
        $byToken = function (Request $request): string {
            $token = $request->user()?->currentAccessToken();

            return match (true) {
                $token instanceof PersonalAccessToken => 'token:'.$token->getKey(),
                $request->user() !== null => 'user:'.$request->user()->getKey(),
                default => 'ip:'.$request->ip(),
            };
        };

        RateLimiter::for('api-login', fn (Request $request): Limit => Limit::perMinute(5)
            ->by(mb_strtolower((string) $request->input('email')).'|'.$request->ip()));

        RateLimiter::for('api', fn (Request $request): Limit => Limit::perMinute(60)->by('api:'.$byToken($request)));

        RateLimiter::for('api-location', fn (Request $request): Limit => Limit::perMinute(60)->by('location:'.$byToken($request)));

        RateLimiter::for('api-reports', fn (Request $request): Limit => Limit::perMinute(10)->by('reports:'.$byToken($request)));

        // Dashboard memuat beberapa panel sekaligus dan mem-polling saat websocket putus, jadi batasnya lebih longgar.
        RateLimiter::for('api-admin', fn (Request $request): Limit => Limit::perMinute(300)->by('admin:'.$byToken($request)));
    }
}
