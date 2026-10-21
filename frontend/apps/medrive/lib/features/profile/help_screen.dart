import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/feedback.dart';
import 'settings_tile.dart';

/// Kontak admin pusat diisi lewat `--dart-define`; baris kontak disembunyikan bila kosong.
const _supportPhone = String.fromEnvironment('SUPPORT_PHONE');
const _supportEmail = String.fromEnvironment('SUPPORT_EMAIL');

const _faq = [
  (
    'Kapan sebaiknya memakai MeDrive?',
    'Saat ada keadaan darurat yang butuh ambulans: kecelakaan, kondisi medis mendadak, ibu hamil yang akan '
        'melahirkan, atau pengantaran jenazah. Untuk kebakaran atau kejahatan, hubungi 112.',
  ),
  (
    'Berapa lama sampai ambulans datang?',
    'Begitu laporan terkirim, driver terdekat yang sedang bertugas dihubungi otomatis dan radius pencarian '
        'diperluas bila belum ada yang mengambil. Perkiraan waktu tiba tampil di halaman Lacak setelah driver '
        'mengambil laporan.',
  ),
  (
    'Lokasi jemput saya tidak tepat.',
    'Geser peta sampai pin merah tepat di lokasi Anda, atau ketuk alamat di atas peta untuk mencari alamat. '
        'Setelah laporan terkirim, kirim patokan lokasi lewat chat ke driver.',
  ),
  (
    'Bisakah saya membatalkan laporan?',
    'Pembatalan hanya dilakukan oleh admin pusat agar laporan darurat tidak terhenti tanpa sengaja. Hubungi '
        'admin bila laporan perlu dibatalkan.',
  ),
  (
    'Kenapa chat tidak bisa dipakai?',
    'Chat terbuka setelah driver mengambil laporan dan ditutup otomatis saat laporan selesai atau dibatalkan. '
        'Riwayat pesan tetap bisa dibaca.',
  ),
  (
    'Saya lupa kata sandi.',
    'Hubungi admin pusat untuk mengatur ulang kata sandi. Anda akan diminta membuat kata sandi baru saat masuk.',
  ),
];

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _open(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri);
    if (!opened && context.mounted) {
      showMessage(context, 'Tidak ada aplikasi yang bisa membuka ${uri.path}.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Bantuan')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: MedSpace.xxl),
            children: [
              const PageIntro(text: 'Butuh bantuan? Jawaban pertanyaan umum dan nomor darurat ada di sini.'),
              const _Heading('Nomor darurat'),
              SettingsTile(
                icon: Icons.emergency_outlined,
                title: '112 · Panggilan Darurat',
                subtitle: 'Gratis, 24 jam, untuk semua keadaan darurat.',
                trailing: const Icon(Icons.call_rounded, color: MedColors.brand),
                onTap: () => _open(context, Uri(scheme: 'tel', path: '112')),
              ),
              SettingsTile(
                icon: Icons.local_hospital_outlined,
                title: '119 · Layanan Ambulans (PSC)',
                subtitle: 'Layanan gawat darurat medis Kementerian Kesehatan.',
                trailing: const Icon(Icons.call_rounded, color: MedColors.brand),
                onTap: () => _open(context, Uri(scheme: 'tel', path: '119')),
              ),
              if (_supportPhone.isNotEmpty || _supportEmail.isNotEmpty) ...[
                const _Heading('Hubungi admin MeDrive'),
                if (_supportPhone.isNotEmpty)
                  SettingsTile(
                    icon: Icons.support_agent_rounded,
                    title: 'Telepon admin',
                    subtitle: _supportPhone,
                    trailing: const Icon(Icons.call_rounded, color: MedColors.brand),
                    onTap: () => _open(context, Uri(scheme: 'tel', path: _supportPhone)),
                  ),
                if (_supportEmail.isNotEmpty)
                  SettingsTile(
                    icon: Icons.mail_outline_rounded,
                    title: 'Email admin',
                    subtitle: _supportEmail,
                    trailing: const Icon(Icons.open_in_new_rounded, color: MedColors.brand),
                    onTap: () => _open(context, Uri(scheme: 'mailto', path: _supportEmail)),
                  ),
              ],
              const _Heading('Pertanyaan umum'),
              for (final (question, answer) in _faq)
                ExpansionTile(
                  title: Text(question, style: const TextStyle(fontWeight: FontWeight.w700)),
                  childrenPadding: const EdgeInsets.fromLTRB(MedSpace.gutter, 0, MedSpace.gutter, MedSpace.lg),
                  expandedAlignment: Alignment.centerLeft,
                  shape: const Border(),
                  children: [Text(answer, style: const TextStyle(color: MedColors.inkMuted, height: 1.45))],
                ),
            ],
          ),
        ),
      );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(MedSpace.gutter, MedSpace.lg, MedSpace.gutter, MedSpace.sm),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}
