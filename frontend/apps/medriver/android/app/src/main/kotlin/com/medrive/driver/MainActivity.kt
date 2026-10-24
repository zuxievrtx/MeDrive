package com.medrive.driver

import android.content.Context
import android.location.Location
import android.location.LocationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Channel kecil `com.medrive.driver/mock_location`: membaca bendera lokasi palsu dari lokasi
 * terakhir LocationManager (`Location.isMock` di Android 12+, `isFromMockProvider` sebelumnya).
 * Aplikasi menggabungkannya dengan `Position.isMocked` dari geolocator untuk `is_mock_location`.
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.medrive.driver/mock_location")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "lastLocationIsMock" -> result.success(lastLocationIsMock())
                    else -> result.notImplemented()
                }
            }
    }

    private fun lastLocationIsMock(): Boolean {
        val manager = getSystemService(Context.LOCATION_SERVICE) as? LocationManager ?: return false
        val providers = listOf(LocationManager.GPS_PROVIDER, LocationManager.NETWORK_PROVIDER, LocationManager.PASSIVE_PROVIDER)
        val latest = providers
            .mapNotNull { provider ->
                try {
                    manager.getLastKnownLocation(provider)
                } catch (_: SecurityException) {
                    null
                } catch (_: IllegalArgumentException) {
                    null
                }
            }
            .maxByOrNull { it.time } ?: return false
        return isMock(latest)
    }

    @Suppress("DEPRECATION")
    private fun isMock(location: Location): Boolean =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) location.isMock else location.isFromMockProvider
}
