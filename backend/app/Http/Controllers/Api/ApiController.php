<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Dasar controller API: semua respons memakai format baku { success, data, meta }.
 */
abstract class ApiController extends Controller
{
    /**
     * @param  array<string, mixed>  $meta
     */
    protected function ok(mixed $data = null, int $status = 200, array $meta = []): JsonResponse
    {
        if ($data instanceof JsonResource) {
            $data = $data->resolve(request());
        }

        $body = ['success' => true, 'data' => $data];

        if ($meta !== []) {
            $body['meta'] = $meta;
        }

        return response()->json($body, $status);
    }

    protected function created(mixed $data = null): JsonResponse
    {
        return $this->ok($data, 201);
    }

    protected function noContent(): JsonResponse
    {
        return response()->json(null, 204);
    }

    /**
     * @param  class-string<JsonResource>  $resource
     * @param  array<string, mixed>  $meta
     */
    protected function paginated(LengthAwarePaginator $paginator, string $resource, array $meta = []): JsonResponse
    {
        return $this->ok(
            $resource::collection($paginator->getCollection())->resolve(request()),
            meta: ['pagination' => [
                'current_page' => $paginator->currentPage(),
                'last_page' => $paginator->lastPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
            ], ...$meta],
        );
    }
}
