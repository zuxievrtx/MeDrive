import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../router.dart';
import '../../state/session.dart';
import '../../widgets/feedback.dart';
import 'auth_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  ApiError? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(sessionProvider.notifier).login(email: _email.text, password: _password.text);
    } catch (error) {
      if (mounted) {
        setState(() => _error = asApiError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _forgotPassword() {
    showAppBottomSheet<void>(
      context,
      title: 'Lupa kata sandi?',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(MedSpace.gutter, 0, MedSpace.gutter, MedSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Atur ulang kata sandi dilakukan oleh admin pusat MeDrive. Hubungi admin lewat halaman Bantuan setelah '
              'masuk, atau minta bantuan petugas yang mendaftarkan akun Anda.\n\n'
              'Dalam keadaan darurat, jangan menunggu: hubungi 112 atau 119.',
              style: Theme.of(sheetContext).textTheme.bodyLarge,
            ),
            const SizedBox(height: MedSpace.xl),
            PrimaryButton(label: 'Mengerti', onPressed: () => Navigator.of(sheetContext).pop()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final general = _error != null && !_error!.isValidation ? _error!.message : null;

    return AuthScaffold(
      title: 'Masuk',
      showBack: true,
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Belum punya akun?', style: TextStyle(fontWeight: FontWeight.w700)),
          TextButton(onPressed: () => context.pushReplacement(Routes.register), child: const Text('Buat Akun')),
        ],
      ),
      child: AutofillGroup(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MedTextField(
                key: const Key('login-email'),
                label: 'Email',
                hint: 'nama@email.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                errorText: _error?.fieldError('email'),
                validator: (value) => (value == null || !value.contains('@')) ? 'Masukkan email yang valid.' : null,
              ),
              const SizedBox(height: MedSpace.lg),
              MedTextField(
                key: const Key('login-password'),
                label: 'Kata sandi',
                controller: _password,
                obscure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                errorText: _error?.fieldError('password'),
                onSubmitted: (_) => _submit(),
                validator: (value) => (value == null || value.isEmpty) ? 'Kata sandi wajib diisi.' : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _forgotPassword, child: const Text('Lupa kata sandi?')),
              ),
              if (general != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: MedSpace.md),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      general,
                      key: const Key('login-error'),
                      style: const TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              const SizedBox(height: MedSpace.sm),
              PrimaryButton(key: const Key('login-submit'), label: 'Masuk', loading: _loading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
