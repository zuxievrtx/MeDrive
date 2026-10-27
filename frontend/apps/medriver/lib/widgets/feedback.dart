import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

/// Ambil [ApiError] dari error apa pun (termasuk yang dibungkus Riverpod).
ApiError asApiError(Object error) {
  if (error is ProviderException) {
    return ApiError.unexpected(error.exception);
  }
  return ApiError.unexpected(error);
}

/// Snackbar berisi pesan server (sudah berbahasa Indonesia).
void showError(BuildContext context, Object error) {
  final apiError = asApiError(error);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(apiError.message)));
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Tampilan error data untuk `AsyncValue.error`.
class AsyncErrorView extends StatelessWidget {
  const AsyncErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final apiError = asApiError(error);
    return ErrorRetry(message: apiError.message, isNetwork: apiError.isNetwork, onRetry: onRetry);
  }
}
