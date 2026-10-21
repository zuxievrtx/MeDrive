import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// Field teks bergaya Figma (latar abu, sudut membulat) dengan label di atas field agar tetap
/// terbaca saat field terisi, plus pesan error dari server per field.
class MedTextField extends StatefulWidget {
  const MedTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.obscure = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.autofillHints,
    this.enabled = true,
    this.optional = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscure;
  final int maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final bool enabled;

  /// Menambahkan "(Opsional)" di label, seperti Figma.
  final bool optional;

  @override
  State<MedTextField> createState() => _MedTextFieldState();
}

class _MedTextFieldState extends State<MedTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text.rich(
            TextSpan(
              text: widget.label,
              children: [
                if (widget.optional)
                  const TextSpan(
                    text: ' (Opsional)',
                    style: TextStyle(color: MedColors.inkFaint, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            style: theme.textTheme.titleSmall,
          ),
        ),
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _hidden,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          minLines: widget.maxLines > 1 ? 3 : null,
          maxLength: widget.maxLength,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          autofillHints: widget.autofillHints,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            helperText: widget.helperText,
            helperMaxLines: 3,
            prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon, color: MedColors.inkMuted),
            suffixIcon: widget.obscure
                ? IconButton(
                    tooltip: _hidden ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
                    icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
