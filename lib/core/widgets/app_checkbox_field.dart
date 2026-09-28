import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Checkbox persetujuan yang ikut validasi `Form`. Seluruh baris bisa ditekan
/// (tap target ≥ 48); pesan error tampil di bawahnya.
class AppCheckboxField extends StatelessWidget {
  const AppCheckboxField({
    super.key,
    required this.label,
    this.validator,
    this.enabled = true,
  });

  /// Teks label; pakai [linkStyle] untuk bagian yang ditonjolkan.
  final InlineSpan label;
  final FormFieldValidator<bool>? validator;
  final bool enabled;

  static TextStyle linkStyle(BuildContext context) => TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.of(context).accentText,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormField<bool>(
      initialValue: false,
      validator: validator,
      builder: (field) {
        final value = field.value ?? false;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MergeSemantics(
              child: InkWell(
                borderRadius: AppRadius.inputAll,
                onTap: enabled ? () => field.didChange(!value) : null,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minHeight: AppSizes.minTapTarget),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox.square(
                          dimension: AppSpacing.xl,
                          child: Checkbox(
                            value: value,
                            isError: field.hasError,
                            onChanged: enabled
                                ? (v) => field.didChange(v ?? false)
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text.rich(label,
                              style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (field.errorText != null)
              Padding(
                padding:
                    const EdgeInsets.only(left: AppSpacing.xl + AppSpacing.md),
                child: Text(
                  field.errorText!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ),
          ],
        );
      },
    );
  }
}
