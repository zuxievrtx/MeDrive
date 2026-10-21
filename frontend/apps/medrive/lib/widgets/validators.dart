import 'package:material_ui/material_ui.dart';

/// Validasi sisi klien yang sama dengan aturan backend (RegisterRequest / UpdateProfileRequest).
FormFieldValidator<String> requiredText(String message) =>
    (value) => (value == null || value.trim().isEmpty) ? message : null;

String? emailValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return 'Email wajib diisi.';
  }
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text) ? null : 'Format email tidak valid.';
}

String? phoneValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return 'Nomor telepon wajib diisi.';
  }
  return RegExp(r'^[0-9+\-\s]{8,20}$').hasMatch(text) ? null : 'Nomor telepon 8-20 digit.';
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Kata sandi wajib diisi.';
  }
  return value.length < 8 ? 'Kata sandi minimal 8 karakter.' : null;
}
