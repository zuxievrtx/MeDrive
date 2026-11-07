
import 'package:material_ui/material_ui.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Keamanan Akun',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              const Text(
                'Kelola keamanan akun agar tetap '
                'aman dan terlindungi.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 24),

              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),

                leading: const Icon(
                  Icons.phone_android_outlined,
                  color: Colors.black,
                  size: 26,
                ),

                title: const Text(
                  'Perangkat yang Terhubung',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),

                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Lihat dan kelola perangkat yang masuk '
                    'ke akun Anda.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),

                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                ),

                onTap: () {
                  // Fitur pengelolaan perangkat
                  // belum dihubungkan ke backend.
                },
              ),

              const Spacer(),

              const Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 24,
                  ),
                  child: Text(
                    'MeDrive v1.0.0',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
