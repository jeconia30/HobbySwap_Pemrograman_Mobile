import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_icon_tile_button.dart';
import '../../../core/widgets/app_sticky_bottom.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/item_thumb.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../booking/data/booking_providers.dart';
import '../../booking/domain/booking.dart';
import '../../booking/presentation/sewa_refresh.dart';
import '../data/review_providers.dart';
import '../domain/review.dart';
import '../../../core/constants/app_strings.dart';

class RatingPage extends ConsumerStatefulWidget {
  const RatingPage({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends ConsumerState<RatingPage> {
  final _cerita = TextEditingController();
  final _tags = <String>{};
  int _bintang = 0;
  bool _busy = false;
  String? _ceritaError;
  String? _error;

  @override
  void dispose() {
    _cerita.dispose();
    super.dispose();
  }

  void _close() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.sewaan);

  Future<void> _submit(bool sebagaiPenyewa) async {
    final masalah = periksaCerita(_bintang, _cerita.text);
    setState(() {
      _ceritaError = masalah;
      _error = null;
    });
    if (masalah != null) return;

    setState(() => _busy = true);
    try {
      await ref.read(reviewRepositoryProvider).submit(
            bookingId: widget.bookingId,
            bintang: _bintang,
            teks: _cerita.text,
            tag: _tags.toList(),
          );
      ref.refreshSewa();
      ref.read(authControllerProvider.notifier).refresh();
      hapticAksiPenting();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
            content: Text('Makasih! Ulasanmu membantu mahasiswa lain.')));
      context.go(sebagaiPenyewa
          ? AppRoutes.sewaanTab('riwayat')
          : AppRoutes.barangSaya);
    } on ReviewException catch (e) {
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
    final detail = ref.watch(bookingByIdProvider(widget.bookingId));
    final reviewed = ref.watch(myReviewedBookingIdsProvider);
    final userId = ref.watch(authControllerProvider)?.id;

    final Widget body;
    Widget? bottom;
    final d = detail.value;
    if (detail.hasError || reviewed.hasError) {
      body = _message(Icons.wifi_off_rounded, AppTeks.koneksiPutus);
    } else if (!detail.hasValue || !reviewed.hasValue) {
      body = const SizedBox.shrink();
    } else if (d == null) {
      body = _message(Icons.receipt_long_outlined, AppTeks.sewaTidakDitemukan);
    } else if (d.booking.status != StatusBooking.selesai) {
      body = _message(Icons.hourglass_empty_rounded,
          'Ulasan bisa diberikan setelah sewa selesai.');
    } else if (reviewed.value!.contains(d.booking.id) && !_busy) {
      body = _message(Icons.check_circle_outline_rounded,
          'Kamu sudah memberi ulasan untuk sewa ini.');
    } else {
      final sebagaiPenyewa = d.penyewa.id == userId;
      body = _form(d, sebagaiPenyewa);
      bottom = AppStickyBottom(
        children: [
          AppErrorSlot(message: _error),
          AppButton(
            key: const Key('rating-kirim'),
            label: 'Kirim ulasan',
            isLoading: _busy,
            onPressed: _bintang == 0 ? null : () => _submit(sebagaiPenyewa),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(AppSpacing.pageRating,
                    AppSpacing.md, AppSpacing.pageRating, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppIconTileButton(
                        icon: Icons.close_rounded,
                        tooltip: 'Tutup',
                        onPressed: _busy ? null : _close,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    body,
                  ],
                ),
              ),
            ),
            ?bottom,
          ],
        ),
      ),
    );
  }

  Widget _message(IconData icon, String title) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxl),
        child: AppEmptyState(
          icon: icon,
          title: title,
          actionLabel: 'Ke Sewaan Saya',
          onAction: () => context.go(AppRoutes.sewaan),
        ),
      );

  Widget _form(BookingDetail d, bool sebagaiPenyewa) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final b = d.booking;
    final tags = [
      ...(sebagaiPenyewa ? tagPenyewaMenilai : tagPemilikMenilai),
      if (b.barter) ...tagBarter,
    ];
    final rentang = formatRentangPendek(b.tanggalMulai, b.tanggalKembali);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ItemThumb(kategori: d.item.kategori, size: AppSizes.ratingTile),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.item.judul,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium),
                    Text(
                      sebagaiPenyewa
                          ? '$rentang · disewakan ${d.pemilik.nama}'
                          : '$rentang · disewa ${d.penyewa.nama}',
                      style: text.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Semantics(
          header: true,
          child: Text('Gimana sewanya?', style: text.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Ulasanmu membantu mahasiswa lain memilih dengan aman.',
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++)
              _Star(
                value: i,
                filled: i <= _bintang,
                onTap: _busy
                    ? null
                    : () => setState(() {
                          _bintang = i;
                          _ceritaError = null;
                        }),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          liveRegion: true,
          child: Text.rich(
            _bintang == 0
                ? const TextSpan(text: 'Ketuk bintang untuk menilai')
                : TextSpan(children: [
                    TextSpan(
                      text: labelBintang[_bintang - 1],
                      style: TextStyle(
                          color: colors.warning, fontWeight: FontWeight.w800),
                    ),
                    TextSpan(text: ' · $_bintang dari 5'),
                  ]),
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Yang kamu suka', style: text.titleMedium),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final t in tags)
              AppChip(
                label: t,
                showCheck: true,
                selected: _tags.contains(t),
                onTap: () => setState(
                    () => _tags.contains(t) ? _tags.remove(t) : _tags.add(t)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          key: const Key('rating-cerita'),
          label: 'Cerita singkat (opsional)',
          hint: _bintang > 0 && _bintang <= 2
              ? 'Ceritakan apa yang kurang supaya bisa diperbaiki'
              : 'Contoh: barangnya bersih dan persis seperti di foto.',
          controller: _cerita,
          enabled: !_busy,
          maxLength: 300,
          minLines: 3,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
        ),
        if (_ceritaError != null)
          Semantics(
            liveRegion: true,
            child: Text(
              _ceritaError!,
              key: const Key('rating-cerita-error'),
              style: text.bodySmall?.copyWith(color: scheme.error),
            ),
          ),
      ],
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({required this.value, required this.filled, this.onTap});

  final int value;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      button: true,
      selected: filled,
      label: 'Beri $value dari 5 bintang',
      excludeSemantics: true,
      child: InkResponse(
        key: Key('bintang-$value'),
        onTap: onTap,
        radius: AppSizes.starArea / 2,
        child: SizedBox.square(
          dimension: AppSizes.starArea,
          child: Center(
            child: filled
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppPalette.statsStar, size: AppSizes.starIcon),
                      Icon(Icons.star_border_rounded,
                          color: colors.warning, size: AppSizes.starIcon),
                    ],
                  )
                : Icon(Icons.star_border_rounded,
                    color: colors.border, size: AppSizes.starIcon),
          ),
        ),
      ),
    );
  }
}
