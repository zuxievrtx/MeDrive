import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../state/session.dart';
import '../../widgets/feedback.dart';
import '../../widgets/validators.dart';

/// Ubah nama dan nomor telepon (`PUT /reporter/profile`). Email tidak bisa diubah dari aplikasi.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  bool _saving = false;
  ApiError? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(sessionProvider).user;
    _name = TextEditingController(text: user?.name);
    _phone = TextEditingController(text: user?.phone);
    _email = TextEditingController(text: user?.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).updateProfile(name: _name.text.trim(), phone: _phone.text.trim());
      if (mounted) {
        showMessage(context, 'Profil tersimpan.');
        Navigator.of(context).pop();
      }
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
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(MedSpace.gutter),
            children: [
              MedTextField(
                label: 'Nama lengkap',
                controller: _name,
                textInputAction: TextInputAction.next,
                errorText: _error?.fieldError('name'),
                validator: requiredText('Nama wajib diisi.'),
              ),
              const SizedBox(height: MedSpace.lg),
              MedTextField(
                label: 'Nomor telepon',
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]'))],
                helperText: 'Driver memakai nomor ini untuk menghubungi Anda.',
                errorText: _error?.fieldError('phone'),
                validator: phoneValidator,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: MedSpace.lg),
              MedTextField(
                label: 'Email',
                controller: _email,
                enabled: false,
                helperText: 'Email dipakai untuk masuk dan tidak bisa diubah dari aplikasi.',
              ),
              const SizedBox(height: MedSpace.xxl),
              PrimaryButton(label: 'Simpan', loading: _saving, onPressed: _saving ? null : _save),
            ],
          ),
        ),
      ),
    );
  }
}
