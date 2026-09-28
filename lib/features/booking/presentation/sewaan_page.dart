import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_icon_tile_button.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/widgets/dashed_border.dart';
import '../../../core/widgets/item_card.dart';
import '../../../core/widgets/item_thumb.dart';
import '../../../core/widgets/status_badge.dart';
import '../../review/data/review_providers.dart';
import '../data/booking_providers.dart';
import '../domain/booking.dart';
import '../domain/booking_repository.dart';
import '../domain/booking_rules.dart';
import 'sewa_refresh.dart';

enum SewaanTab { aktif, menunggu, riwayat }

SewaanTab? _tabFrom(String? name) =>
    SewaanTab.values.where((t) => t.name == name).firstOrNull;

class SewaanPage extends ConsumerStatefulWidget {
  const SewaanPage({super.key, this.initialTab});

  /// Dari query `?tab=` (mis. setelah memberi rating → riwayat).
  final String? initialTab;

  @override
  ConsumerState<SewaanPage> createState() => _SewaanPageState();
}

class _SewaanPageState extends ConsumerState<SewaanPage> {
  late SewaanTab _tab = _tabFrom(widget.initialTab) ?? SewaanTab.aktif;

  @override
  void didUpdateWidget(SewaanPage old) {
    super.didUpdateWidget(old);
    final tab = _tabFrom(widget.initialTab);
    if (tab != null && widget.initialTab != old.initialTab) _tab = tab;
  }

  Future<void> _refresh() => Future.wait([
        ref.refresh(myBookingsProvider.future),
        ref.refresh(myReviewedBookingIdsProvider.future),
      ]).then<void>((_) {}, onError: (Object _) {});

  Future<void> _batalkan(BookingDetail d) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showAppBottomSheet<String>(
      context,
      builder: (_) => _CancelSheet(detail: d),
    );
    if (result != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookings = ref.watch(myBookingsProvider);
    final reviewed = ref.watch(myReviewedBookingIdsProvider);
    final today = dateOnly(ref.watch(clockProvider)());
    final all = bookings.value ?? const <BookingDetail>[];

    List<BookingDetail> where(bool Function(StatusBooking s) test) =>
        all.where((d) => test(d.booking.status)).toList();
    final aktif = where((s) =>
        s == StatusBooking.disetujui || s == StatusBooking.berlangsung)
      ..sort((a, b) => a.booking.tanggalMulai.compareTo(b.booking.tanggalMulai));
    final menunggu = where((s) => s == StatusBooking.menunggu);
    final riwayat = where((s) =>
        s == StatusBooking.selesai ||
        s == StatusBooking.ditolak ||
        s == StatusBooking.dibatalkan)
      ..sort((a, b) =>
          b.booking.tanggalKembali.compareTo(a.booking.tanggalKembali));

    SliverPadding padded(Widget child) => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHome),
          sliver: SliverToBoxAdapter(child: child),
        );

    final List<Widget> content;
    if (bookings.hasError && !bookings.isLoading) {
      content = [
        padded(AppEmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Koneksi lagi putus. Coba lagi ya.',
          actionLabel: 'Coba lagi',
          onAction: () => ref.invalidate(myBookingsProvider),
        )),
      ];
    } else if (!bookings.hasValue || !reviewed.hasValue) {
      content = [
        padded(Skeletonizer(
          child: _ActiveCard(detail: _placeholder, today: today),
        )),
      ];
    } else {
      final ratedIds = reviewed.value!;
      final perluRating = [
        for (final d in riwayat)
          if (d.booking.status == StatusBooking.selesai &&
              !ratedIds.contains(d.booking.id))
            d,
      ];
      final cards = switch (_tab) {
        SewaanTab.aktif => [
            for (final d in aktif) _ActiveCard(detail: d, today: today),
          ],
        SewaanTab.menunggu => [
            for (final d in menunggu)
              _CompactCard(detail: d, onBatalkan: () => _batalkan(d)),
          ],
        SewaanTab.riwayat => [
            for (final d in perluRating) _RatingPromptCard(detail: d),
            for (final d in riwayat) _CompactCard(detail: d),
          ],
      };
      content = cards.isEmpty
          ? [padded(_empty(context))]
          : [
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.pageHome),
                sliver: SliverList.separated(
                  itemCount: cards.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.cardCompact),
                  itemBuilder: (_, i) => cards[i],
                ),
              ),
            ];
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              padded(Padding(
                padding: const EdgeInsets.only(
                    top: AppSpacing.md, bottom: AppSpacing.lg),
                child: Semantics(
                  header: true,
                  child: Text('Sewaan Saya',
                      style: theme.textTheme.headlineMedium
                          ?.merge(AppTextStyles.pageTitle)),
                ),
              )),
              padded(Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: AppSegmentedControl(
                  selected: _tab.index,
                  onChanged: (i) => setState(() => _tab = SewaanTab.values[i]),
                  segments: [
                    AppSegment('Aktif · ${aktif.length}',
                        key: const Key('segmen-aktif')),
                    AppSegment('Menunggu · ${menunggu.length}',
                        key: const Key('segmen-menunggu')),
                    const AppSegment('Riwayat', key: Key('segmen-riwayat')),
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

  Widget _empty(BuildContext context) {
    final (IconData icon, String title) = switch (_tab) {
      SewaanTab.aktif => (
          Icons.inventory_2_outlined,
          'Belum ada sewa aktif. Yuk cari barang yang kamu butuhkan.'
        ),
      SewaanTab.menunggu => (
          Icons.hourglass_empty_rounded,
          'Belum ada pengajuan yang menunggu jawaban.'
        ),
      SewaanTab.riwayat => (
          Icons.history_rounded,
          'Belum ada riwayat sewa. Sewa pertamamu akan tercatat di sini.'
        ),
    };
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: AppEmptyState(
        icon: icon,
        title: title,
        actionLabel: 'Cari barang',
        onAction: () => context.go(AppRoutes.beranda),
      ),
    );
  }
}

final _placeholder = BookingDetail(
  booking: Booking(
    id: '',
    itemId: '',
    penyewaId: '',
    tanggalMulai: DateTime(2026, 1, 1),
    tanggalKembali: DateTime(2026, 1, 3),
    totalHarga: 0,
    status: StatusBooking.berlangsung,
    dibuatPada: DateTime(2026),
  ),
  item: ItemCard.placeholder.item,
  penyewa: ItemCard.placeholder.owner,
  pemilik: ItemCard.placeholder.owner.copyWith(nama: 'Nama Pemilik'),
);

String _sub(BookingDetail d) =>
    '${formatRentangPendek(d.booking.tanggalMulai, d.booking.tanggalKembali)}'
    ' · dari ${namaPendek(d.pemilik.nama)}';

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.detail, required this.thumb});

  final BookingDetail detail;
  final double thumb;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ItemThumb(
            kategori: detail.item.kategori, size: thumb, radius: AppRadius.note),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.item.judul,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium
                    ?.merge(AppTextStyles.bookingTitle),
              ),
              const SizedBox(height: AppSpacing.xs / 2),
              Text(
                _sub(detail),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.sm),
              StatusBadge(detail.booking.status),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({required this.detail, required this.today});

  final BookingDetail detail;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final b = detail.booking;
    final berlangsung = b.status == StatusBooking.berlangsung;
    final sisa = sisaHariSewa(b.tanggalKembali, today);
    final terlambat = sisa < 0;
    final progres =
        terlambat ? 1.0 : progresSewa(b.tanggalMulai, b.tanggalKembali, today);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.cardCompact),
      child: Column(
        key: Key('sewa-${b.id}'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(detail: detail, thumb: AppSizes.bookingTile),
          if (berlangsung) ...[
            const SizedBox(height: AppSpacing.cardCompact),
            Row(
              children: [
                Expanded(
                  child: Text(
                    teksSisaHari(sisa),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: terlambat ? scheme.error : scheme.onSurfaceVariant,
                      fontWeight: terlambat ? FontWeight.w700 : null,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  formatTanggalPendek(b.tanggalKembali),
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: terlambat ? scheme.error : scheme.onSurface,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              label: 'Progres sewa ${(progres * 100).round()} persen',
              excludeSemantics: true,
              child: ClipRRect(
                borderRadius: AppRadius.pillAll,
                child: SizedBox(
                  height: AppSizes.progressThick,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: colors.surfaceAlt),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progres,
                        child: ColoredBox(
                            color: terlambat ? scheme.error : colors.accentMid),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.cardCompact),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  key: Key('checklist-${b.id}'),
                  label: berlangsung
                      ? 'Checklist pengembalian'
                      : 'Checklist ambil barang',
                  onPressed: () => context.push(
                      AppRoutes.checklist(b.id, akhir: berlangsung)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppIconTileButton(
                icon: Icons.chat_bubble_outline_rounded,
                tooltip: 'Chat ${detail.pemilik.nama}',
                size: AppSizes.chatButtonLg,
                backgroundColor: colors.surfaceAlt,
                onPressed: () => ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                      const SnackBar(content: Text('Chat segera hadir'))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  const _CompactCard({required this.detail, this.onBatalkan});

  final BookingDetail detail;
  final VoidCallback? onBatalkan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = detail.booking;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.cardCompact),
      child: Column(
        key: Key('sewa-${b.id}'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(detail: detail, thumb: AppSizes.countBox),
          if (b.status == StatusBooking.ditolak && b.alasanTolak != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Alasan pemilik: ${b.alasanTolak}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          if (onBatalkan != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: Key('batalkan-${b.id}'),
                onPressed: onBatalkan,
                child: const Text('Batalkan pengajuan'),
              ),
            ),
        ],
      ),
    );
  }
}

class _RatingPromptCard extends StatelessWidget {
  const _RatingPromptCard({required this.detail});

  final BookingDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return DashedBorder(
      radius: AppRadius.card,
      color: colors.warning,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: Key('rating-prompt-${detail.booking.id}'),
          borderRadius: AppRadius.cardAll,
          onTap: () => context.push(AppRoutes.rating(detail.booking.id)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardCompact),
            child: Row(
              children: [
                Container(
                  width: AppSizes.countBox,
                  height: AppSizes.countBox,
                  decoration: BoxDecoration(
                    color: colors.warning.withValues(alpha: 0.18),
                    borderRadius: AppRadius.inputAll,
                  ),
                  child: Icon(Icons.star_rounded,
                      color: colors.warning, size: AppSizes.iconMd),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Beri rating untuk ${detail.item.judul}',
                          style: theme.textTheme.titleMedium),
                      Text(
                        'Bantu mahasiswa lain memilih dengan aman',
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
      ),
    );
  }
}

/// Konfirmasi batal; hasil pop = pesan SnackBar.
class _CancelSheet extends ConsumerStatefulWidget {
  const _CancelSheet({required this.detail});

  final BookingDetail detail;

  @override
  ConsumerState<_CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends ConsumerState<_CancelSheet> {
  bool _busy = false;
  String? _error;

  Future<void> _cancel() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(bookingRepositoryProvider)
          .cancel(widget.detail.booking.id);
      ref.refreshSewa();
      if (mounted) Navigator.pop(context, 'Pengajuan dibatalkan.');
    } on BookingException catch (e) {
      ref.refreshSewa();
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
          _error = 'Koneksi lagi putus. Coba lagi ya.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = widget.detail.booking;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSheetTitle('Batalkan pengajuan?'),
        Text(
          '${widget.detail.item.judul} · '
          '${formatRentangPendek(b.tanggalMulai, b.tanggalKembali)}. '
          'Pemilik tidak perlu menjawab lagi.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppErrorSlot(message: _error),
        AppButton(
          key: const Key('batalkan-konfirmasi'),
          label: 'Ya, batalkan',
          variant: AppButtonVariant.danger,
          isLoading: _busy,
          onPressed: _cancel,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Tidak jadi'),
        ),
      ],
    );
  }
}
