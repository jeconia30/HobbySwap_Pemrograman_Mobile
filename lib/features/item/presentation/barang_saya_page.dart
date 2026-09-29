import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/guards/require_verified.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_press_scale.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/item_card.dart';
import '../../../core/widgets/item_thumb.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../booking/data/booking_providers.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/owner_stats.dart';
import '../../review/data/review_providers.dart';
import '../data/item_providers.dart';
import '../domain/item.dart';
import '../domain/item_repository.dart';
import 'item_status_chip.dart';
import '../../../core/constants/app_strings.dart';
import '../../booking/presentation/batal_sewa_sheet.dart';

class BarangSayaPage extends ConsumerWidget {
  const BarangSayaPage({super.key});

  Future<void> _refresh(WidgetRef ref) => Future.wait([
        ref.refresh(myItemsProvider.future),
        ref.refresh(ownerBookingsProvider.future),
      ]).then<void>((_) {}, onError: (Object _) {});

  void _tambah(BuildContext context, WidgetRef ref) => requireVerified(
        context,
        ref,
        onAllowed: () => context.push(AppRoutes.barangTambah),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(myItemsProvider);
    final bookings = ref.watch(ownerBookingsProvider);
    // Dipakai sheet aksi untuk tahu sewa mana yang sudah dinilai pemilik.
    ref.watch(myReviewedBookingIdsProvider);
    final user = ref.watch(authControllerProvider);
    final today = dateOnly(ref.watch(clockProvider)());
    final theme = Theme.of(context);

    final list = items.value;
    final details = bookings.value;
    final loading = items.isLoading || bookings.isLoading;
    final error = items.hasError || bookings.hasError;

    final pending = [
      for (final d in details ?? const <BookingDetail>[])
        if (d.booking.status == StatusBooking.menunggu) d,
    ];
    final stats = hitungStatistikPemilik(
        (details ?? const <BookingDetail>[]).map((d) => d.booking), today);

    SliverPadding padded(Widget sliver) => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHome),
          sliver: sliver,
        );
    Widget box(Widget child) => padded(SliverToBoxAdapter(child: child));

    final List<Widget> content;
    if (error && !loading) {
      content = [
        box(Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xl),
          child: AppEmptyState(
            icon: Icons.wifi_off_rounded,
            title: AppTeks.koneksiPutus,
            actionLabel: AppTeks.cobaLagi,
            onAction: () => ref
              ..invalidate(myItemsProvider)
              ..invalidate(ownerBookingsProvider),
          ),
        )),
      ];
    } else if (loading || list == null || details == null) {
      content = [
        box(Skeletonizer(
          child: Column(children: [
            const _StatsCard(stats: (pendapatanBulanIni: 420000, jumlahDisewakan: 12), rating: 4.8),
            const SizedBox(height: AppSpacing.xl),
            for (var i = 0; i < 3; i++) ...[
              _ItemRow(listing: ItemCard.placeholder, onTap: () {}),
              const SizedBox(height: AppSpacing.md),
            ],
          ]),
        )),
      ];
    } else {
      content = [
        box(_StatsCard(stats: stats, rating: user?.rating ?? 0)),
        if (pending.isNotEmpty)
          box(Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: _PendingCard(pending: pending),
          )),
        box(Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xl),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text('Barangmu · ${list.length}',
                      style: theme.textTheme.titleLarge),
                ),
              ),
              TextButton(
                key: const Key('barang-saya-tambah'),
                onPressed: () => _tambah(context, ref),
                child: const Text('+ Tambah'),
              ),
            ],
          ),
        )),
        if (list.isEmpty)
          box(Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Belum ada barang.',
              message: 'Sewakan barang nganggurmu, lumayan buat uang jajan.',
              actionLabel: 'Sewakan barang',
              onAction: () => _tambah(context, ref),
            ),
          ))
        else
          padded(SliverList.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) => _ItemRow(
              listing: list[i],
              onTap: () => _openActions(
                context,
                list[i],
                [
                  for (final d in details)
                    if (d.item.id == list[i].item.id) d,
                ],
                ref.read(myReviewedBookingIdsProvider).value ?? const {},
              ),
            ),
          )),
      ];
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              box(Padding(
                padding: const EdgeInsets.only(
                    top: AppSpacing.md, bottom: AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text('Barang Saya',
                            style: theme.textTheme.headlineMedium
                                ?.merge(AppTextStyles.pageTitle)),
                      ),
                    ),
                    Text(
                      formatBulan(today),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              )),
              ...content,
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openActions(
    BuildContext context,
    ItemListing listing,
    List<BookingDetail> sewa,
    Set<String> sudahDinilai,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showAppBottomSheet<Object>(
      context,
      builder: (_) => _ItemActionsSheet(
          listing: listing, sewa: sewa, sudahDinilai: sudahDinilai),
    );
    if (result == null || !context.mounted) return;
    switch (result) {
      // Pindah halaman setelah sheet tertutup (push dari dalam sheet yang
      // sedang ditutup membuat halaman tujuan tidak memuat data).
      case _Go(:final location):
        context.push(location);
      case _Batal(:final detail):
        final ok = await showBatalSewaSheet(
          context,
          detail: detail,
          hariIni: ProviderScope.containerOf(context).read(clockProvider)(),
          sebagaiPemilik: true,
        );
        if (ok) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('Sewa dibatalkan.')));
        }
      case final String message:
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

/// Hasil sheet: buka sheet pembatalan untuk [detail] setelah sheet tertutup.
class _Batal {
  const _Batal(this.detail);

  final BookingDetail detail;
}

/// Hasil sheet: buka [location] setelah sheet tertutup.
class _Go {
  const _Go(this.location);

  final String location;
}

/// Kartu statistik: warna brand tetap di kedua mode.
class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats, required this.rating});

  final OwnerStats stats;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final value = text.titleLarge
        ?.merge(AppTextStyles.statValue)
        .copyWith(color: AppPalette.cream);
    final label = text.bodySmall
        ?.merge(AppTextStyles.statLabel)
        .copyWith(color: AppPalette.statsLabel);

    Widget cell(Widget v, String l) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(fit: BoxFit.scaleDown, child: v),
                const SizedBox(height: AppSpacing.xs),
                Text(l, style: label),
              ],
            ),
          ),
        );

    final divider = VerticalDivider(
      width: 1,
      thickness: 1,
      color: AppPalette.cream.withValues(alpha: 0.16),
    );

    return Semantics(
      label: 'Pendapatan bulan ini ${formatRupiah(stats.pendapatanBulanIni)}, '
          'disewakan ${stats.jumlahDisewakan} kali, '
          'rating pemilik ${formatRating(rating)}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg, horizontal: AppSpacing.sm),
        decoration: const BoxDecoration(
          color: AppPalette.lightAccent,
          borderRadius: AppRadius.cardAll,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              cell(
                Text(formatRupiah(stats.pendapatanBulanIni),
                    style: value),
                'Pendapatan',
              ),
              divider,
              cell(Text('${stats.jumlahDisewakan}×', style: value),
                  'Disewakan'),
              divider,
              cell(
                Text.rich(
                  TextSpan(children: [
                    const TextSpan(
                        text: '★ ',
                        style: TextStyle(color: AppPalette.statsStar)),
                    TextSpan(text: formatRating(rating)),
                  ]),
                  style: value,
                ),
                'Rating pemilik',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.pending});

  final List<BookingDetail> pending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final names = <String>{for (final d in pending) d.penyewa.nama}.toList();

    final row = Material(
      color: colors.warning.withValues(alpha: 0.18),
      borderRadius: AppRadius.cardAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('pending-card'),
        onTap: () => context.push(AppRoutes.pengajuanMasuk),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: AppSizes.countBox,
                height: AppSizes.countBox,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.warning,
                  borderRadius: AppRadius.previewAll,
                ),
                child: Text(
                  '${pending.length}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.surface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pengajuan baru menunggu',
                        style: theme.textTheme.titleMedium),
                    Text(
                      ringkasPeminta(names),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
    return AppPressScale(child: row);
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.listing, required this.onTap});

  final ItemListing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final item = listing.item;
    final nonaktif = listing.status == ItemStatus.nonaktif;
    final sub = [
      '${formatRupiah(item.hargaPerHari)}/hari',
      'disewa ${item.jumlahDisewa}×',
      if (listing.status == ItemStatus.disewa && listing.disewaSampai != null)
        'kembali ${formatTanggalPendek(listing.disewaSampai!)}',
    ].join(' · ');

    final row = Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.listRow)),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('item-row-${item.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Opacity(
                opacity: nonaktif ? 0.5 : 1,
                child: ItemThumb(kategori: item.kategori),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.merge(AppTextStyles.rowTitle)
                          .copyWith(
                              color: nonaktif ? scheme.onSurfaceVariant : null),
                    ),
                    const SizedBox(height: AppSpacing.xs / 2),
                    Text(
                      sub,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Flexible: label panjang (Dibarter · kembali …) terbungkus, bukan overflow.
              Flexible(
                child: ItemStatusChip(listing.status,
                    sampai: listing.disewaSampai),
              ),
            ],
          ),
        ),
      ),
    );
    return AppPressScale(child: row);
  }
}

/// Aksi per barang. Hapus dikonfirmasi di sheet yang sama (bukan dialog).
/// Hasil pop = pesan SnackBar ([String]), [_Go], atau `null` bila ditutup.
class _ItemActionsSheet extends ConsumerStatefulWidget {
  const _ItemActionsSheet({
    required this.listing,
    required this.sewa,
    required this.sudahDinilai,
  });

  final ItemListing listing;

  /// Semua sewa atas barang ini (terbaru dulu).
  final List<BookingDetail> sewa;

  /// Id sewa yang sudah dinilai pemilik.
  final Set<String> sudahDinilai;

  @override
  ConsumerState<_ItemActionsSheet> createState() => _ItemActionsSheetState();
}

class _ItemActionsSheetState extends ConsumerState<_ItemActionsSheet> {
  bool _confirmDelete = false;
  bool _busy = false;
  String? _error;

  Item get _item => widget.listing.item;

  /// Sewa berlangsung (diutamakan) atau disetujui terdekat untuk checklist.
  BookingDetail? get _sewaAktif {
    final aktif = widget.sewa.where((d) =>
        d.booking.status == StatusBooking.berlangsung ||
        d.booking.status == StatusBooking.disetujui);
    return aktif
            .where((d) => d.booking.status == StatusBooking.berlangsung)
            .firstOrNull ??
        (aktif.toList()
              ..sort((a, b) =>
                  a.booking.tanggalMulai.compareTo(b.booking.tanggalMulai)))
            .firstOrNull;
  }

  /// Sewa selesai terbaru yang belum dinilai pemilik.
  BookingDetail? get _perluDinilai => widget.sewa
      .where((d) =>
          d.booking.status == StatusBooking.selesai &&
          !widget.sudahDinilai.contains(d.booking.id))
      .firstOrNull;

  void _refreshLists() => ref
    ..invalidate(myItemsProvider)
    ..invalidate(itemByIdProvider(_item.id));

  Future<void> _run(Future<void> Function() action, String success) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      _refreshLists();
      if (mounted) Navigator.pop(context, success);
    } on ItemException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = AppTeks.koneksiPutus;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(itemRepositoryProvider);
    final aktif = _item.aktif;

    if (_confirmDelete) {
      final theme = Theme.of(context);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetTitle('Hapus ${_item.judul}?'),
          Text(
            'Barang ini akan hilang dari HobbySwap dan tidak bisa '
            'dikembalikan.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppErrorSlot(message: _error),
          AppButton(
            key: const Key('hapus-konfirmasi'),
            label: 'Ya, hapus',
            variant: AppButtonVariant.danger,
            isLoading: _busy,
            onPressed: () => _run(() => repo.delete(_item.id), 'Barang dihapus.'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: _busy
                ? null
                : () => setState(() {
                      _confirmDelete = false;
                      _error = null;
                    }),
            child: const Text(AppTeks.batal),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetTitle(_item.judul),
        AppErrorSlot(message: _error),
        AppSheetAction(
          icon: Icons.edit_outlined,
          label: 'Ubah barang',
          onTap: () =>
              Navigator.pop(context, _Go(AppRoutes.barangUbah(_item.id))),
        ),
        AppSheetAction(
          icon: aktif ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          label: aktif ? 'Nonaktifkan' : 'Aktifkan lagi',
          onTap: () {
            if (_busy) return;
            _run(
              () => repo.setAktif(_item.id, !aktif),
              aktif
                  ? 'Barang dinonaktifkan. Tidak tampil di Beranda.'
                  : 'Barang aktif lagi.',
            );
          },
        ),
        AppSheetAction(
          icon: Icons.storefront_outlined,
          label: 'Lihat seperti penyewa',
          onTap: () =>
              Navigator.pop(context, _Go(AppRoutes.barangDetail(_item.id))),
        ),
        if (_sewaAktif case final aktif?)
          AppSheetAction(
            icon: Icons.fact_check_outlined,
            label: 'Checklist serah terima',
            onTap: () => Navigator.pop(
              context,
              _Go(AppRoutes.checklist(aktif.booking.id,
                  akhir: aktif.booking.status == StatusBooking.berlangsung)),
            ),
          ),
        if (_perluDinilai case final selesai?)
          AppSheetAction(
            icon: Icons.star_outline_rounded,
            label: 'Beri rating penyewa',
            onTap: () => Navigator.pop(
                context, _Go(AppRoutes.rating(selesai.booking.id))),
          ),
        if (_sewaAktif case final s?
            when s.booking.status == StatusBooking.disetujui)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: Key('batalkan-sewa-${s.booking.id}'),
              onPressed: () => Navigator.pop(context, _Batal(s)),
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error),
              child: Text('Batalkan sewa ${firstName(s.penyewa.nama)}'),
            ),
          ),
        AppSheetAction(
          icon: Icons.delete_outline_rounded,
          label: 'Hapus barang',
          destructive: true,
          onTap: () => setState(() {
            _confirmDelete = true;
            _error = null;
          }),
        ),
      ],
    );
  }
}
