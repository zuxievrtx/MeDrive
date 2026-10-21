<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\ApiController;
use App\Services\GeocodeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Proxy geocoding untuk aplikasi Pelapor dan Driver. Aplikasi tidak boleh memanggil Nominatim langsung.
 *
 * @group Geocoding
 */
class GeocodeController extends ApiController
{
    public function __construct(private GeocodeService $geocode) {}

    /**
     * Alamat dari koordinat
     *
     * Hasil di-cache 24 jam per titik (5 desimal). address bernilai null bila Nominatim tidak menemukan alamat.
     */
    public function reverse(Request $request): JsonResponse
    {
        $data = $request->validate([
            'lat' => ['required', 'numeric', 'between:-90,90'],
            'lng' => ['required', 'numeric', 'between:-180,180'],
        ], attributes: ['lat' => 'latitude', 'lng' => 'longitude']);

        return $this->ok($this->geocode->reverse((float) $data['lat'], (float) $data['lng']));
    }

    /**
     * Cari tempat
     *
     * Dibatasi wilayah Indonesia, di-cache 10 menit per kata kunci.
     */
    public function search(Request $request): JsonResponse
    {
        $data = $request->validate([
            'q' => ['required', 'string', 'min:3', 'max:200'],
            'limit' => ['nullable', 'integer', 'between:1,10'],
        ], attributes: ['q' => 'kata kunci', 'limit' => 'jumlah hasil']);

        return $this->ok($this->geocode->search($data['q'], (int) ($data['limit'] ?? 5)));
    }
}
