import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_info_note.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_verified_chip.dart';
import '../../../core/widgets/item_card.dart';
import '../../../core/widgets/item_thumb.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/domain/user.dart';
import '../../item/data/item_providers.dart';
import '../data/booking_providers.dart';
import '../domain/booking.dart';
import '../domain/booking_repository.dart';
import '../domain/booking_rules.dart';

/// Pengajuan menunggu lain untuk barang yang sama dengan rentang bertumpuk.
int _bentrokLain(BookingDetail d, List<BookingDetail> all) => all
    .where((o) =>
        o.booking.id != d.booking.id &&
        o.booking.itemId == d.booking.itemId &&
        o.booking.status == StatusBooking.menunggu &&
        rentangBertumpuk(o.booking.tanggalMulai, o.booking.tanggalKembali,
            d.booking.tanggalMulai, d.booking.tanggalKembali))
    .length;

class PengajuanMasukPage extends ConsumerStatefulWidget {
  const PengajuanMasukPage({super.key});

  @override
  ConsumerState<PengajuanMasukPage> createState() =>
      _PengajuanMasukPageState();
}

class _PengajuanMasukPageState extends ConsumerState<PengajuanMasukPage> {
  bool _riwayat = false;

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.barangSaya);

  Future<void> _terima(BookingDetail d, List<BookingDetail> all) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showAppBottomSheet<String>(
      context,
      builder: (_) => _TerimaSheet(detail: d, bentrok: _bentrokLain(d, all)),
    );
    if (result != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result)));
    }
  }

  Future<void> _tolak(BookingDetail d) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showAppBottomSheet<String>(
      context,
      builder: (_) => _TolakSheet(detail: d),
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
    final async = ref.watch(ownerBookingsProvider);
    final all = async.value ?? const <BookingDetail>[];
    final menunggu = [
      for (final d in all)
        if (d.booking.status == StatusBooking.menunggu) d,
    ];
    final riwayat = [
      for (final d in all)
        if (d.booking.status != StatusBooking.menunggu) d,
    ];
    final shown = _riwayat ? riwayat : menunggu;

    final Widget body;
    if (async.hasError && !async.isLoading) {
      body = AppEmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Koneksi lagi putus. Coba lagi ya.',
        actionLabel: 'Coba lagi',
        onAction: () => ref.invalidate(ownerBookingsProvider),
      );
    } else if (!async.hasValue) {
      body = Skeletonizer(
        child: _RequestCard(
          detail: BookingDetail(
            booking: Booking(
              id: '',
              itemId: '',
              penyewaId: '',
              tanggalMulai: DateTime(2026),
              tanggalKembali: DateTime(2026, 1, 3),
              totalHarga: 75000,
              dibuatPada: DateTime(2026),
            ),
            item: ItemCard.placeholder.item,
            penyewa: ItemCard.placeholder.owner.copyWith(nama: 'Nama Penyewa'),
            pemilik: ItemCard.placeholder.owner,
          ),
          bentrok: 0,
        ),
      );
    } else if (shown.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: AppEmptyState(
          icon: _riwayat ? Icons.history_rounded : Icons.inbox_outlined,
          title: _riwayat
              ? 'Belum ada riwayat pengajuan.'
              : 'Belum ada pengajuan masuk.',
          message: _riwayat
              ? null
              : 'Kami kabari begitu ada yang ingin menyewa barangmu.',
        ),
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final d in shown) ...[
            _RequestCard(
              detail: d,
              bentrok: _riwayat ? 0 : _bentrokLain(d, all),
              onTerima: _riwayat ? null : () => _terima(d, all),
              onTolak: _riwayat ? null : () => _tolak(d),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref
              .refresh(ownerBookingsProvider.future)
              .then<void>((_) {}, onError: (Object _) {}),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome,
                AppSpacing.md, AppSpacing.pageHome, AppSpacing.xxl),
            children: [
              Row(
                children: [
                  AppBackButton(onPressed: _back),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text('Pengajuan masuk',
                          style: theme.textTheme.headlineMedium),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  AppChip(
                    label: 'Menunggu (${menunggu.length})',
                    selected: !_riwayat,
                    onTap: () => setState(() => _riwayat = false),
                  ),
                  AppChip(
                    label: 'Riwayat',
                    selected: _riwayat,
                    onTap: () => setState(() => _riwayat = true),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              body,
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.detail,
    required this.bentrok,
    this.onTerima,
    this.onTolak,
  });

  final BookingDetail detail;
  final int bentrok;
  final VoidCallback? onTerima;
  final VoidCallback? onTolak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final b = detail.booking;
    final muted = text.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    final hari = hitungHari(b.tanggalMulai, b.tanggalKembali);
    final verified =
        detail.penyewa.statusVerifikasi == StatusVerifikasi.terverifikasi;

    return AppCard(
      child: Column(
        key: Key('request-${b.id}'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppAvatar(user: detail.penyewa, showBadge: false),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(detail.penyewa.nama, style: text.titleMedium),
                        if (verified) const AppVerifiedChip(),
                      ],
                    ),
                    Text('Diajukan ${formatTanggalPendek(b.dibuatPada)}',
                        style: muted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              ItemThumb(kategori: detail.item.kategori, size: AppSizes.countBox),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detail.item.judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall ?? text.titleMedium),
                    Text(
                      '${formatTanggalPendek(b.tanggalMulai)} – '
                      '${formatTanggalPendek(b.tanggalKembali)} · $hari hari',
                      style: muted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              Text.rich(
                TextSpan(children: [
                  const TextSpan(text: 'Total '),
                  TextSpan(
                    text: formatRupiah(b.totalHarga),
                    style: TextStyle(
                        color: colors.accentText, fontWeight: FontWeight.w800),
                  ),
                ]),
                style: text.bodyMedium,
              ),
              if (onTerima == null) StatusBadge(b.status),
            ],
          ),
          if (b.pesan != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: AppRadius.inputAll,
              ),
              child: Text('“${b.pesan}”', style: text.bodyMedium),
            ),
          ],
          if (b.alasanTolak != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Alasan: ${b.alasanTolak}', style: muted),
          ],
          if (bentrok > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: AppSizes.iconXs, color: colors.warning),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Bentrok dengan $bentrok pengajuan lain di tanggal yang sama',
                    style: muted,
                  ),
                ),
              ],
            ),
          ],
          if (onTerima != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    key: Key('tolak-${b.id}'),
                    label: 'Tolak',
                    variant: AppButtonVariant.outline,
                    onPressed: onTolak,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    key: Key('terima-${b.id}'),
                    label: 'Terima',
                    onPressed: onTerima,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Konfirmasi terima; hasil pop = pesan SnackBar.
class _TerimaSheet extends ConsumerStatefulWidget {
  const _TerimaSheet({required this.detail, required this.bentrok});

  final BookingDetail detail;
  final int bentrok;

  @override
  ConsumerState<_TerimaSheet> createState() => _TerimaSheetState();
}

class _TerimaSheetState extends ConsumerState<_TerimaSheet> {
  bool _busy = false;
  String? _error;

  Future<void> _approve() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final b = widget.detail.booking;
    try {
      final ditolak = await ref.read(bookingRepositoryProvider).approve(b.id);
      ref
        ..invalidate(ownerBookingsProvider)
        ..invalidate(myItemsProvider)
        ..invalidate(blockedDatesProvider(b.itemId));
      HapticFeedback.lightImpact();
      if (!mounted) return;
      Navigator.pop(
        context,
        ditolak > 0
            ? 'Pengajuan diterima. $ditolak pengajuan lain otomatis ditolak.'
            : 'Pengajuan diterima.',
      );
    } on BookingException catch (e) {
      ref.invalidate(ownerBookingsProvider);
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
        AppSheetTitle('Terima pengajuan ${widget.detail.penyewa.nama}?'),
        Text(
          '${widget.detail.item.judul} · '
          '${formatTanggalPendek(b.tanggalMulai)} – '
          '${formatTanggalPendek(b.tanggalKembali)} · '
          '${formatRupiah(b.totalHarga)}',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        if (widget.bentrok > 0) ...[
          const SizedBox(height: AppSpacing.lg),
          AppInfoNote(
            icon: Icons.info_outline_rounded,
            message: '${widget.bentrok} pengajuan lain di tanggal yang sama '
                'akan otomatis ditolak.',
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        AppErrorSlot(message: _error),
        AppButton(
          key: const Key('terima-konfirmasi'),
          label: 'Terima',
          isLoading: _busy,
          onPressed: _approve,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
      ],
    );
  }
}

const _alasanCepat = ['Barangnya lagi dipakai', 'Tanggalnya nggak cocok'];

/// Tolak dengan alasan; hasil pop = pesan SnackBar.
class _TolakSheet extends ConsumerStatefulWidget {
  const _TolakSheet({required this.detail});

  final BookingDetail detail;

  @override
  ConsumerState<_TolakSheet> createState() => _TolakSheetState();
}

class _TolakSheetState extends ConsumerState<_TolakSheet> {
  final _lainnya = TextEditingController();
  String? _pilihan;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _lainnya.dispose();
    super.dispose();
  }

  String get _alasan =>
      _pilihan == null ? _lainnya.text.trim() : _pilihan!;

  Future<void> _reject() async {
    if (_alasan.isEmpty) {
      setState(() => _error = 'Pilih atau tulis alasannya dulu, ya.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(bookingRepositoryProvider)
          .reject(widget.detail.booking.id, _alasan);
      ref.invalidate(ownerBookingsProvider);
      if (mounted) Navigator.pop(context, 'Pengajuan ditolak.');
    } on BookingException catch (e) {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetTitle('Tolak pengajuan ${widget.detail.penyewa.nama}?'),
        Text(
          'Alasannya akan dikirim ke penyewa supaya dia bisa cari tanggal '
          'atau barang lain.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final a in _alasanCepat)
              AppChip(
                label: a,
                selected: _pilihan == a,
                onTap: () => setState(() {
                  _pilihan = a;
                  _error = null;
                }),
              ),
            AppChip(
              label: 'Lainnya',
              selected: _pilihan == null,
              onTap: () => setState(() => _pilihan = null),
            ),
          ],
        ),
        if (_pilihan == null) ...[
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const Key('tolak-alasan'),
            label: 'Alasan',
            hint: 'Contoh: lagi dibawa pulang kampung minggu itu.',
            controller: _lainnya,
            enabled: !_busy,
            maxLength: 120,
            minLines: 2,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppErrorSlot(message: _error),
        AppButton(
          key: const Key('tolak-konfirmasi'),
          label: 'Tolak pengajuan',
          variant: AppButtonVariant.danger,
          isLoading: _busy,
          onPressed: _reject,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
      ],
    );
  }
}
