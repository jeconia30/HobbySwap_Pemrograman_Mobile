import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_sticky_bottom.dart';
import '../../../core/widgets/item_card.dart';
import '../../../core/widgets/item_thumb.dart';
import '../../../core/widgets/status_badge.dart';
import '../../item/domain/item.dart';
import '../data/booking_providers.dart';
import '../domain/booking.dart';
import '../domain/booking_rules.dart';
import '../../../core/constants/app_strings.dart';

class PengajuanTerkirimPage extends ConsumerWidget {
  const PengajuanTerkirimPage({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(myBookingsProvider);
    final detail =
        bookings.value?.where((d) => d.booking.id == bookingId).firstOrNull;

    final Widget content;
    if (bookings.hasValue && detail == null) {
      content = const Padding(
        padding: EdgeInsets.only(top: AppSpacing.xxxl),
        child: AppEmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Pengajuan ini tidak ditemukan',
          message: 'Cek daftar lengkapnya di Sewaan Saya.',
        ),
      );
    } else if (detail != null) {
      content = _Body(
        booking: detail.booking,
        listing: ItemListing(item: detail.item, owner: detail.pemilik),
      );
    } else if (bookings.hasError) {
      content = Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxxl),
        child: AppEmptyState(
          icon: Icons.wifi_off_rounded,
          title: AppTeks.koneksiPutus,
          actionLabel: AppTeks.cobaLagi,
          onAction: () => ref.invalidate(myBookingsProvider),
        ),
      );
    } else {
      content = Skeletonizer(
        child: _Body(
          booking: Booking(
            id: '',
            itemId: '',
            penyewaId: '',
            tanggalMulai: DateTime(2026),
            tanggalKembali: DateTime(2026, 1, 3),
            totalHarga: 135000,
            dibuatPada: DateTime(2026),
          ),
          listing: ItemCard.placeholder,
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.beranda);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome,
                      AppSpacing.xxl, AppSpacing.pageHome, AppSpacing.xl),
                  child: content,
                ),
              ),
              AppStickyBottom(
                children: [
                  AppButton(
                    label: 'Lihat Sewaan Saya',
                    onPressed: () => context.go(AppRoutes.sewaan),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.beranda),
                    child: const Text('Kembali ke Beranda'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.booking, required this.listing});

  final Booking booking;
  final ItemListing listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final muted = text.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    final hari = hitungHari(booking.tanggalMulai, booking.tanggalKembali);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: _SuccessArt()),
        const SizedBox(height: AppSpacing.xl),
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            booking.barter ? 'Tawaran barter terkirim!' : 'Pengajuan terkirim!',
            textAlign: TextAlign.center,
            style: text.headlineMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${listing.owner.nama} biasanya membalas kurang dari 1 jam. '
          'Kami kabari begitu ada jawaban.',
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.group),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ItemThumb(kategori: listing.item.kategori),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.item.judul,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs / 2),
                        Text(
                          '${formatTanggalPendek(booking.tanggalMulai)} – '
                          '${formatTanggalPendek(booking.tanggalKembali)}'
                          ' · $hari hari',
                          style: muted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(),
              ),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(booking.barter ? 'Jenis' : 'Total', style: muted),
                      Text(
                        booking.barter
                            ? 'Barter · tanpa biaya'
                            : formatRupiah(booking.totalHarga),
                        style: text.titleMedium?.copyWith(
                          color: colors.accentText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(booking.status),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuccessArt extends StatelessWidget {
  const _SuccessArt();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduceMotion ? 1 : 0.6, end: 1),
      duration: reduceMotion ? Duration.zero : AppDurations.page,
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        width: AppSizes.statusArt,
        height: AppSizes.statusArt,
        decoration: BoxDecoration(
          color: colors.accentSoft,
          shape: BoxShape.circle,
        ),
        child: ExcludeSemantics(
          child: Icon(Icons.check_rounded,
              color: colors.accentText, size: AppSizes.iconTile),
        ),
      ),
    );
  }
}
