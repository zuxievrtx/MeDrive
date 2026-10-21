import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../router.dart';
import '../../state/session.dart';
import '../../widgets/feedback.dart';
import '../../widgets/validators.dart';
import 'auth_scaffold.dart';

/// Daftar akun pelapor. Server selalu membuat role pelapor; tidak ada pilihan role di aplikasi.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _loading = false;
  ApiError? _error;

  @override
  void dispose() {
    for (final controller in [_name, _phone, _email, _password, _confirmation]) {
      controller.dispose();
    }
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
      await ref.read(sessionProvider.notifier).register(
            name: _name.text,
            phone: _phone.text,
            email: _email.text,
            password: _password.text,
            passwordConfirmation: _confirmation.text,
          );
    } catch (error) {
      if (!mounted) {
        return;
      }
      final apiError = asApiError(error);
      setState(() => _error = apiError);
      if (!apiError.isValidation) {
        showError(context, apiError);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
        title: 'Buat Akun',
        showBack: true,
        footer: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Sudah punya akun?', style: TextStyle(fontWeight: FontWeight.w700)),
            TextButton(onPressed: () => context.pushReplacement(Routes.login), child: const Text('Masuk')),
          ],
        ),
        child: AutofillGroup(
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MedTextField(
                  label: 'Nama lengkap',
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  errorText: _error?.fieldError('name'),
                  validator: requiredText('Nama wajib diisi.'),
                ),
                const SizedBox(height: MedSpace.lg),
                MedTextField(
                  label: 'Nomor telepon',
                  hint: '08xx xxxx xxxx',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]'))],
                  errorText: _error?.fieldError('phone'),
                  helperText: 'Dipakai driver untuk menghubungi Anda.',
                  validator: phoneValidator,
                ),
                const SizedBox(height: MedSpace.lg),
                MedTextField(
                  label: 'Email',
                  hint: 'nama@email.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  errorText: _error?.fieldError('email'),
                  validator: emailValidator,
                ),
                const SizedBox(height: MedSpace.lg),
                MedTextField(
                  label: 'Kata sandi',
                  controller: _password,
                  obscure: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  helperText: 'Minimal 8 karakter.',
                  errorText: _error?.fieldError('password'),
                  validator: passwordValidator,
                ),
                const SizedBox(height: MedSpace.lg),
                MedTextField(
                  label: 'Ulangi kata sandi',
                  controller: _confirmation,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: (value) => value != _password.text ? 'Kata sandi tidak sama.' : null,
                ),
                const SizedBox(height: MedSpace.xl),
                PrimaryButton(label: 'Buat Akun', loading: _loading, onPressed: _submit),
              ],
            ),
          ),
        ),
      );
}
