import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_spacing.dart';

/// Tempat [AppErrorBanner] yang muncul/hilang dengan animasi ukuran.
class AppErrorSlot extends StatelessWidget {
  const AppErrorSlot({
    super.key,
    required this.message,
    this.spacing = AppSpacing.md,
  });

  /// `null` = tidak ada error.
  final String? message;

  /// Jarak ke elemen di bawahnya saat banner tampil.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppDurations.short,
      curve: Curves.easeOutCubic,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: AppErrorBanner(message: message!),
            ),
    );
  }
}

/// Kotak pesan error lembut (bukan dialog); dibacakan otomatis oleh pembaca layar.
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({super.key, required this.message, this.onRetry});

  final String message;

  /// Bila diisi, tampil tombol "Coba lagi" di ujung kanan.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: scheme.error.withValues(alpha: 0.12),
          borderRadius: AppRadius.inputAll,
          border: Border.all(color: scheme.error.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: scheme.error,
              size: AppSizes.iconSm,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurface),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: const Text(AppTeks.cobaLagi),
              ),
          ],
        ),
      ),
    );
  }
}
