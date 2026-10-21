import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../widgets/feedback.dart';
import 'change_password_form.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Ubah Kata Sandi')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(MedSpace.gutter),
            children: [
              Text(
                'Setelah diganti, perangkat lain yang masuk dengan akun ini akan keluar otomatis.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MedColors.inkMuted),
              ),
              const SizedBox(height: MedSpace.xl),
              ChangePasswordForm(
                onChanged: () {
                  showMessage(context, 'Kata sandi berhasil diganti.');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      );
}
