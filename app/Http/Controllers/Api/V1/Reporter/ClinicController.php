<?php

namespace App\Http\Controllers\Api\V1\Reporter;

use App\Http\Controllers\Api\ApiController;
use App\Http\Resources\ClinicResource;
use App\Models\Clinic;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Daftar faskes tujuan (klinik aktif) untuk form ibu hamil dan pengantaran jenazah.
 */
class ClinicController extends ApiController
{
    public function __invoke(Request $request): JsonResponse
    {
        $search = trim((string) $request->query('search', ''));

        $clinics = Clinic::query()
            ->where('is_active', true)
            ->when($search !== '', fn (Builder $query) => $query->where(fn (Builder $query) => $query
                ->where('name', 'like', "%{$search}%")
                ->orWhere('address', 'like', "%{$search}%")))
            ->orderBy('name')
            ->paginate(20);

        return $this->paginated($clinics, ClinicResource::class);
    }
}
