import 'package:flutter/material.dart';

import '../../features/auth/domain/user.dart';
import '../../features/item/domain/item.dart';
import '../../features/item/domain/kategori.dart';
import '../../features/item/presentation/kategori_visual.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'app_press_scale.dart';

/// Kartu barang untuk grid 2 kolom (Beranda, hasil cari).
class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.listing,
    this.onTap,
    this.aksiPojok,
  });

  final ItemListing listing;
  final VoidCallback? onTap;

  /// Tombol di pojok kanan atas foto (mis. hati favorit); di luar semantics
  /// kartu supaya terbaca sebagai tombol tersendiri.
  final Widget? aksiPojok;

  /// Data palsu untuk kerangka skeleton.
  static const placeholder = ItemListing(
    item: Item(
      id: 'skeleton',
      ownerId: '',
      judul: 'Memuat nama barang yang cukup panjang',
      deskripsi: '',
      kategori: Kategori.lainnya,
      hargaPerHari: 25000,
      lokasiKampus: 'Kampus USU',
    ),
    owner: User(
      id: '',
      nama: '',
      nim: '',
      email: '',
      rating: 4.8,
      jumlahUlasan: 1,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final item = listing.item;
    final owner = listing.owner;
    final hasRating = owner.jumlahUlasan > 0;
    final disewa = listing.status == ItemStatus.disewa;
    final price = formatRupiah(item.hargaPerHari);
    final ratingText = hasRating ? formatRating(owner.rating) : 'Baru';

    final kartu = Semantics(
      button: onTap != null,
      label:
          '${item.judul}, $price per hari, ${item.lokasiKampus}, '
          '${hasRating ? 'rating $ratingText' : 'pemilik baru'}'
          '${disewa ? ', sedang disewa' : ''}'
          '${item.bisaBarter ? ', menerima barter' : ''}',
      child: ExcludeSemantics(
        child: AppPressScale(
          enabled: onTap != null,
          child: Material(
            color: scheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.cardAll,
              side: BorderSide(color: colors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: AppSizes.itemPhoto,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Opacity(
                          opacity: disewa ? 0.45 : 1,
                          child: ItemPhotoHero(
                            itemId: item.id,
                            kategori: item.kategori,
                            enabled: onTap != null,
                            child: ColoredBox(
                              color: item.kategori.tileColor,
                              child: Icon(
                                item.kategori.icon,
                                color: AppPalette.cream,
                                size: AppSizes.itemPhotoIcon,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: AppSpacing.sm,
                          top: AppSpacing.sm,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _PhotoChip(item.kategori.label),
                              if (item.bisaBarter) ...[
                                const SizedBox(height: AppSpacing.xs),
                                const _PhotoChip(
                                  'Barter',
                                  key: Key('chip-barter'),
                                  icon: Icons.swap_horiz_rounded,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (disewa)
                          const Positioned(
                            left: AppSpacing.sm,
                            bottom: AppSpacing.sm,
                            child: _PhotoChip('Sedang disewa'),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: AppSpacing.itemCardInfo,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.judul,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium?.merge(
                            AppTextStyles.cardTitle,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.tight),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: price,
                                style: AppTextStyles.price.copyWith(
                                  color: colors.accentText,
                                ),
                              ),
                              TextSpan(
                                text: '/hari',
                                style: AppTextStyles.priceUnit.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          style: text.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.tight),
                        // Wrap: di font besar rating turun ke baris baru.
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.xs,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.place_outlined,
                                  size: AppSizes.iconXs,
                                  color: scheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: AppSpacing.xs / 2),
                                Flexible(
                                  child: Text(
                                    item.lokasiKampus,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              hasRating ? '★ $ratingText' : ratingText,
                              style: text.bodySmall?.copyWith(
                                color: hasRating
                                    ? colors.warning
                                    : scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (aksiPojok == null) return kartu;
    return Stack(
      children: [
        kartu,
        Positioned(top: 0, right: 0, child: aksiPojok!),
      ],
    );
  }
}

/// Hero foto barang dari kartu ke Detail. Selama terbang yang digambar hanya
/// tile kategori + ikon yang membesar (ringan, tanpa PageView/semantics).
/// Mati saat animasi sistem dimatikan.
class ItemPhotoHero extends StatelessWidget {
  const ItemPhotoHero({
    super.key,
    required this.itemId,
    required this.kategori,
    required this.child,
    this.enabled = true,
  });

  final String itemId;
  final Kategori kategori;
  final Widget child;

  /// Kartu skeleton/tanpa aksi tidak ikut (hindari tag kembar).
  final bool enabled;

  static Object tag(String itemId) => 'item-foto-$itemId';

  @override
  Widget build(BuildContext context) {
    if (!enabled || MediaQuery.disableAnimationsOf(context)) return child;
    return Hero(
      tag: tag(itemId),
      flightShuttleBuilder: (context, animation, _, _, _) => ColoredBox(
        color: kategori.tileColor,
        child: Center(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) => Icon(
              kategori.icon,
              color: AppPalette.cream,
              size: Tween(
                begin: AppSizes.itemPhotoIcon,
                end: AppSizes.detailHeroIcon,
              ).transform(animation.value),
            ),
          ),
        ),
      ),
      child: child,
    );
  }
}

class _PhotoChip extends StatelessWidget {
  const _PhotoChip(this.label, {super.key, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: AppPalette.scrim,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSpacing.md, color: AppPalette.cream),
            const SizedBox(width: AppSpacing.xs / 2),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.merge(AppTextStyles.photoChip)
                .copyWith(color: AppPalette.cream),
          ),
        ],
      ),
    );
  }
}

/// Grid 2 kolom sebagai sliver. Tinggi kartu per baris disamakan dan ikut
/// membesar dengan ukuran font sistem (tanpa rasio tetap yang bisa overflow).
class SliverItemGrid extends StatelessWidget {
  const SliverItemGrid({
    super.key,
    required this.listings,
    this.onTap,
    this.aksiPojok,
  });

  final List<ItemListing> listings;
  final void Function(ItemListing listing)? onTap;
  final Widget Function(ItemListing listing)? aksiPojok;

  @override
  Widget build(BuildContext context) {
    final rows = (listings.length / 2).ceil();
    Widget cell(int i) => i < listings.length
        ? ItemCard(
            listing: listings[i],
            onTap: onTap == null ? null : () => onTap!(listings[i]),
            aksiPojok: aksiPojok?.call(listings[i]),
          )
        : const SizedBox.shrink();

    return SliverList.separated(
      itemCount: rows,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, r) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: cell(r * 2)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: cell(r * 2 + 1)),
          ],
        ),
      ),
    );
  }
}
