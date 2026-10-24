/// Aplikasi yang sedang berjalan. Menentukan role yang boleh masuk, prefix grup endpoint
/// (`/reporter/...` atau `/driver/...`), dan nama perangkat untuk token Sanctum.
enum AppRole {
  reporter(
    userRole: 'pelapor',
    pathPrefix: 'reporter',
    deviceName: 'MeDrive Android',
    wrongAppMessage: 'Akun ini bukan akun pelapor. Driver memakai aplikasi MeDrive Driver.',
  ),
  driver(
    userRole: 'driver',
    pathPrefix: 'driver',
    deviceName: 'MeDriveR Android',
    wrongAppMessage: 'Akun ini bukan akun driver. Pelapor memakai aplikasi MeDrive.',
  );

  const AppRole({
    required this.userRole,
    required this.pathPrefix,
    required this.deviceName,
    required this.wrongAppMessage,
  });

  /// Nilai `users.role` yang diterima aplikasi ini.
  final String userRole;
  final String pathPrefix;
  final String deviceName;
  final String wrongAppMessage;
}
