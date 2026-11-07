
import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const Color _ink = Color(0xFF171717);
  static const Color _muted = Color(0xFF777777);

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title akan segera tersedia.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Bantuan',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  MedSpace.gutter,
                  0,
                  MedSpace.gutter,
                  MedSpace.xl,
                ),
                children: [
                  const Text(
                    'Butuh bantuan? Kami siap membantu '
                    'Anda dengan cepat.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),

                  _HelpMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Pusat Bantuan',
                    subtitle: 'Temukan jawaban dari pertanyaan umum.',
                    onTap: () => _showComingSoon(context, 'Pusat Bantuan'),
                  ),

                  _HelpMenuTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Hubungi Kami',
                    subtitle: 'Kirim pesan ke tim dukungan kami.',
                    onTap: () => _showComingSoon(context, 'Hubungi Kami'),
                  ),

                  _HelpMenuTile(
                    icon: Icons.fact_check_outlined,
                    title: 'Syarat dan Ketentuan',
                    subtitle: 'Baca ketentuan penggunaan aplikasi.',
                    onTap: () =>
                        _showComingSoon(context, 'Syarat dan Ketentuan'),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'MeDrive v1.0.0',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpMenuTile extends StatelessWidget {
  const _HelpMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 8,
      ),
      leading: SizedBox(
        width: 32,
        child: Icon(
          icon,
          size: 22,
          color: Colors.black,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF171717),
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF777777),
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF777777),
        size: 22,
      ),
      onTap: onTap,
    );
  }
}
