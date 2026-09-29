import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/item_thumb.dart';
import '../../item/domain/item.dart';

/// Chip berlatar accentSoft dengan ikon panah bolak-balik ("Barter",
/// "Tawaran barter").
class BarterChip extends StatelessWidget {
  const BarterChip(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs / 2),
      decoration: BoxDecoration(
        color: colors.accentSoft,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.swap_horiz_rounded,
              size: AppSizes.iconXs, color: colors.accentText),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.accentText, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dua tile kecil bertumpuk dengan ikon panah bolak-balik (kartu Sewaan,
/// kartu transaksi chat).
class BarterTileTumpuk extends StatelessWidget {
  const BarterTileTumpuk({
    super.key,
    required this.atas,
    required this.bawah,
    this.size = AppSizes.bookingTile,
  });

  final Item atas;
  final Item bawah;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final kecil = size * 0.72;
    return Semantics(
      label: '${atas.judul} ditukar dengan ${bawah.judul}',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          children: [
            ItemThumb(kategori: atas.kategori, size: kecil),
            Positioned(
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.inputAll,
                  border: Border.all(
                      color: Theme.of(context).colorScheme.surface, width: 2),
                ),
                child: ItemThumb(kategori: bawah.kategori, size: kecil),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs / 2),
                decoration: BoxDecoration(
                  color: colors.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.swap_horiz_rounded,
                    size: AppSpacing.md, color: colors.accentText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu sisi barter: label ("Kamu pinjam"), tile, judul, lokasi.
class _SisiBarter extends StatelessWidget {
  const _SisiBarter({required this.label, required this.item});

  final String label;
  final Item item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: muted),
          const SizedBox(height: AppSpacing.sm),
          ItemThumb(kategori: item.kategori),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.judul,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(item.lokasiKampus,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: muted),
        ],
      ),
    );
  }
}

/// Dua kartu berdampingan dengan ikon panah bolak-balik di tengah.
class BarterDuaKartu extends StatelessWidget {
  const BarterDuaKartu({
    super.key,
    required this.kiriLabel,
    required this.kiri,
    required this.kananLabel,
    required this.kanan,
  });

  final String kiriLabel;
  final Item kiri;
  final String kananLabel;
  final Item kanan;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _SisiBarter(label: kiriLabel, item: kiri)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Center(
              child: ExcludeSemantics(
                child: Icon(Icons.swap_horiz_rounded,
                    color: colors.accentText, size: AppSizes.iconMd),
              ),
            ),
          ),
          Expanded(child: _SisiBarter(label: kananLabel, item: kanan)),
        ],
      ),
    );
  }
}
