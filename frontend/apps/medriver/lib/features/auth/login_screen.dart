import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../state/session.dart';
import '../../widgets/brand.dart';
import '../../widgets/feedback.dart';

/// Masuk driver (Figma: logo + "Login" + dua field + tombol). Tidak ada tautan daftar karena akun
/// driver hanya dibuat admin pusat.
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
              'Kata sandi driver diatur ulang oleh admin pusat MeDrive. Hubungi admin klinik atau admin pusat, '
              'lalu masuk dengan kata sandi sementara yang diberikan. Aplikasi akan meminta Anda membuat '
              'kata sandi baru.',
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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(MedSpace.xl, MedSpace.xl, MedSpace.xl, MedSpace.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const DriverLogo(markWidth: 120, wordmarkSize: 36),
                      const SizedBox(height: MedSpace.xxl + MedSpace.lg),
                      Text('Masuk', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: MedSpace.xs),
                      const Text(
                        'Akun driver dibuat oleh admin pusat',
                        key: Key('login-helper'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: MedSpace.xl),
                      MedTextField(
                        key: const Key('login-email'),
                        label: 'Email',
                        hint: 'nama@klinik.id',
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
            ),
          ),
        ),
      ),
    );
  }
}
