import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Kolom cari bergaya Beranda: ikon kaca pembesar, tombol hapus saat terisi,
/// dan [trailing] opsional (mis. tombol filter).
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
    this.fieldKey,
    this.trailing,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final Key? fieldKey;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: AppSizes.searchField),
      padding: const EdgeInsets.only(left: AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.noteAll,
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded,
              color: scheme.onSurfaceVariant, size: AppSizes.iconMd),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              key: fieldKey,
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: hint,
                filled: false,
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Hapus pencarian',
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm),
            ),
          ?trailing,
        ],
      ),
    );
  }
}
