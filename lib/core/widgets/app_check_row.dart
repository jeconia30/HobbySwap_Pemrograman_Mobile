import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Baris centang: kotak centang + teks, area sentuh selebar baris (min 48).
class AppCheckRow extends StatelessWidget {
  const AppCheckRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: AppRadius.inputAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
          child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(label,
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
