import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_spacing.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.suffix,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.prefixText,
  });

  /// Teks tetap di depan isian, mis. "Rp ".
  final String? prefixText;

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final Widget? suffix;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  /// Batas karakter; penghitung "n/maks" tampil di bawah field.
  final int? maxLength;
  final int? minLines;

  /// Lebih dari 1 = multiline.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Text(
            label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: theme.colorScheme.onSurface),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          label: label,
          child: TextFormField(
            controller: controller,
            validator: validator,
            obscureText: obscureText,
            enabled: enabled,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onFieldSubmitted: onFieldSubmitted,
            autofillHints: enabled ? autofillHints : null,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            maxLength: maxLength,
            minLines: minLines,
            maxLines: obscureText ? 1 : maxLines,
            autocorrect: !obscureText,
            enableSuggestions: !obscureText,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hint,
              prefixText: prefixText,
              prefixStyle: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              suffixIcon: suffix,
              constraints:
                  const BoxConstraints(minHeight: AppSizes.fieldHeight),
            ),
          ),
        ),
      ],
    );
  }
}
