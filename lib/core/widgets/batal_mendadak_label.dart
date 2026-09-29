import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// "{n} pembatalan mendadak" (text-secondary + ikon peringatan); kosong bila 0.
class BatalMendadakLabel extends StatelessWidget {
  const BatalMendadakLabel(this.jumlah, {super.key});

  final int jumlah;

  @override
  Widget build(BuildContext context) {
    if (jumlah <= 0) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Row(
      key: const Key('batal-mendadak'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.warning_amber_rounded, size: AppSizes.iconXs, color: muted),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            '$jumlah pembatalan mendadak',
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ),
      ],
    );
  }
}
