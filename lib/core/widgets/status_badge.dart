import 'package:flutter/material.dart';

import '../../features/booking/domain/booking.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Pill status umum: titik (atau ikon centang bila [selesai]) + label, latar
/// warna status 16%. Label teks selalu ada (bukan warna saja).
class AppStatusPill extends StatelessWidget {
  const AppStatusPill({
    super.key,
    required this.label,
    required this.color,
    this.selesai = false,
    this.compact = false,
    this.semanticPrefix = 'Status',
  });

  final String label;
  final Color color;

  /// Tampilkan ikon centang, bukan titik.
  final bool selesai;

  /// Versi kecil untuk baris padat.
  final bool compact;
  final String semanticPrefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$semanticPrefix: $label',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.sm : AppSpacing.md,
            vertical: compact ? AppSpacing.xs / 2 : AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: AppRadius.pillAll,
        ),
        // Mengecil (bukan overflow) di kolom sempit dengan font besar.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selesai)
                Icon(Icons.check_rounded,
                    size: compact ? AppSpacing.md : AppSizes.iconXs,
                    color: color)
              else
                Container(
                  width: compact ? AppSpacing.tight : AppSpacing.sm,
                  height: compact ? AppSpacing.tight : AppSpacing.sm,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              SizedBox(width: compact ? AppSpacing.xs : AppSpacing.tight),
              Text(
                label,
                style: (compact
                        ? theme.textTheme.labelSmall
                        : theme.textTheme.labelMedium)
                    ?.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill status sewa. Warna mengikuti DESIGN §2.1.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.compact = false});

  final StatusBooking status;

  /// Versi kecil untuk baris padat (kotak masuk Pesan).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = switch (status) {
      StatusBooking.menunggu => colors.warning,
      StatusBooking.disetujui || StatusBooking.berlangsung =>
        colors.accentText,
      StatusBooking.selesai => colors.verified,
      StatusBooking.ditolak || StatusBooking.dibatalkan =>
        Theme.of(context).colorScheme.error,
    };
    return AppStatusPill(
      label: status.label,
      color: color,
      selesai: status == StatusBooking.selesai,
      compact: compact,
    );
  }
}

/// Badge pembayaran COD: "Belum bayar" (warning) atau "Lunas" (verified).
class BayarBadge extends StatelessWidget {
  const BayarBadge(this.status, {super.key});

  final StatusBayar status;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final lunas = status == StatusBayar.lunas;
    return AppStatusPill(
      key: Key('bayar-${status.name}'),
      label: lunas ? 'Lunas' : 'Belum bayar',
      color: lunas ? colors.verified : colors.warning,
      selesai: lunas,
      compact: true,
      semanticPrefix: 'Pembayaran',
    );
  }
}
