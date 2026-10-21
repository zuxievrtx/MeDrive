import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../state/session.dart';
import '../../widgets/feedback.dart';
import '../../widgets/validators.dart';

/// Kata sandi lama → baru → konfirmasi. Dipakai layar Keamanan dan layar wajib ganti kata sandi.
class ChangePasswordForm extends ConsumerStatefulWidget {
  const ChangePasswordForm({super.key, required this.onChanged, this.submitLabel = 'Simpan kata sandi'});

  final VoidCallback onChanged;
  final String submitLabel;

  @override
  ConsumerState<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends ConsumerState<ChangePasswordForm> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _loading = false;
  ApiError? _error;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirmation.dispose();
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
      await ref.read(sessionProvider.notifier).changePassword(
            currentPassword: _current.text,
            password: _password.text,
            passwordConfirmation: _confirmation.text,
          );
      widget.onChanged();
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
  Widget build(BuildContext context) => Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MedTextField(
              label: 'Kata sandi saat ini',
              controller: _current,
              obscure: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.password],
              errorText: _error?.fieldError('current_password'),
              validator: requiredText('Kata sandi saat ini wajib diisi.'),
            ),
            const SizedBox(height: MedSpace.lg),
            MedTextField(
              label: 'Kata sandi baru',
              controller: _password,
              obscure: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              helperText: 'Minimal 8 karakter dan berbeda dari kata sandi lama.',
              errorText: _error?.fieldError('password'),
              validator: passwordValidator,
            ),
            const SizedBox(height: MedSpace.lg),
            MedTextField(
              label: 'Ulangi kata sandi baru',
              controller: _confirmation,
              obscure: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (value) => value != _password.text ? 'Kata sandi baru tidak sama.' : null,
            ),
            const SizedBox(height: MedSpace.xl),
            PrimaryButton(label: widget.submitLabel, loading: _loading, onPressed: _submit),
          ],
        ),
      );
}
