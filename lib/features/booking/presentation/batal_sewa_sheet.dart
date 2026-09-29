import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/booking_providers.dart';
import '../domain/booking.dart';
import '../domain/booking_repository.dart';
import '../domain/booking_rules.dart';
import 'sewa_refresh.dart';

const _alasanPenyewa = [
  'Rencana berubah',
  'Sudah dapat barang lain',
  'Tidak bisa datang ambil',
];
const _alasanPemilik = [
  'Barang dipakai sendiri',
  'Barang rusak',
  'Tidak bisa bertemu',
];

/// Bottom sheet "Batalkan sewa" untuk sewa yang sudah disetujui. Alasan
/// wajib (chip + teks opsional); di hari H tampil peringatan pembatalan
/// mendadak. Mengembalikan `true` bila dibatalkan.
Future<bool> showBatalSewaSheet(
  BuildContext context, {
  required BookingDetail detail,
  required DateTime hariIni,
  required bool sebagaiPemilik,
}) async =>
    await showAppBottomSheet<bool>(
      context,
      builder: (_) => _BatalSewaSheet(
        detail: detail,
        hariIni: hariIni,
        sebagaiPemilik: sebagaiPemilik,
      ),
    ) ??
    false;

class _BatalSewaSheet extends ConsumerStatefulWidget {
  const _BatalSewaSheet({
    required this.detail,
    required this.hariIni,
    required this.sebagaiPemilik,
  });

  final BookingDetail detail;
  final DateTime hariIni;
  final bool sebagaiPemilik;

  @override
  ConsumerState<_BatalSewaSheet> createState() => _BatalSewaSheetState();
}

class _BatalSewaSheetState extends ConsumerState<_BatalSewaSheet> {
  final _tambahan = TextEditingController();
  String? _alasan;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _tambahan.dispose();
    super.dispose();
  }

  Future<void> _batalkan() async {
    final pilih = _alasan;
    if (pilih == null) {
      setState(() => _error = 'Pilih alasannya dulu, ya.');
      return;
    }
    final tambahan = _tambahan.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(bookingRepositoryProvider).batalkanSewa(
            widget.detail.booking.id,
            tambahan.isEmpty ? pilih : '$pilih. $tambahan',
          );
      hapticAksiPenting();
      ref.refreshSewa();
      ref.read(authControllerProvider.notifier).refresh();
      if (mounted) Navigator.pop(context, true);
    } on BookingException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = AppTeks.koneksiPutus);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final colors = AppColors.of(context);
    final b = widget.detail.booking;
    final mendadak =
        aturanBatal(b, dateOnly(widget.hariIni)) == AturanBatal.mendadak;
    final pilihan =
        widget.sebagaiPemilik ? _alasanPemilik : _alasanPenyewa;
    final lawan = widget.sebagaiPemilik
        ? widget.detail.penyewa.nama
        : widget.detail.pemilik.nama;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSheetTitle('Batalkan sewa?'),
        Text(
          '${widget.detail.item.judul} · '
          '${formatRentangPendek(b.tanggalMulai, b.tanggalKembali)}. '
          '$lawan akan diberi tahu dan tanggalnya dibuka lagi.',
          style: text.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        if (mendadak) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            key: const Key('peringatan-hari-h'),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.warning.withValues(alpha: 0.16),
              borderRadius: AppRadius.noteAll,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: colors.warning, size: AppSizes.iconSm),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Pembatalan di hari H akan tercatat di profilmu sebagai '
                    'pembatalan mendadak.',
                    style: text.bodySmall?.copyWith(
                        color: colors.warning, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text('Alasan', style: text.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final (i, a) in pilihan.indexed)
              AppChip(
                key: Key('alasan-batal-$i'),
                label: a,
                selected: _alasan == a,
                onTap: () => setState(() {
                  _alasan = a;
                  _error = null;
                }),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          key: const Key('alasan-batal-teks'),
          label: 'Keterangan (opsional)',
          controller: _tambahan,
          enabled: !_busy,
          maxLength: 200,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: AppSpacing.md),
        AppErrorSlot(message: _error),
        AppButton(
          key: const Key('batal-sewa-konfirmasi'),
          label: 'Batalkan sewa',
          variant: AppButtonVariant.danger,
          isLoading: _busy,
          onPressed: _batalkan,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: const Text('Tidak jadi'),
        ),
      ],
    );
  }
}
