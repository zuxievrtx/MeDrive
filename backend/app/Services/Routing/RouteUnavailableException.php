<?php

namespace App\Services\Routing;

use RuntimeException;

/**
 * Penyedia rute gagal dihubungi atau tidak menemukan rute.
 */
class RouteUnavailableException extends RuntimeException {}
