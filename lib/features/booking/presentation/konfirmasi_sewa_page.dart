import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_checkbox_field.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_sticky_bottom.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/item_card.dart';
import '../../../core/widgets/item_thumb.dart';
import '../../item/data/item_providers.dart';
import '../../item/domain/item.dart';
import '../data/booking_providers.dart';
import '../domain/booking_repository.dart';
import '../domain/booking_rules.dart';

const _maxPesan = 200;

class KonfirmasiSewaPage extends ConsumerStatefulWidget {
  const KonfirmasiSewaPage({
    super.key,
    required this.itemId,
    required this.mulai,
    required this.kembali,
  });

  final String itemId;
  final DateTime? mulai;
  final DateTime? kembali;

  @override
  ConsumerState<KonfirmasiSewaPage> createState() => _KonfirmasiSewaPageState();
}

class _KonfirmasiSewaPageState extends ConsumerState<KonfirmasiSewaPage> {
  final _formKey = GlobalKey<FormState>();
  final _pesan = TextEditingController();
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pesan.dispose();
    super.dispose();
  }

  void _toDetail() => context.canPop()
      ? context.pop()
      : context.go(AppRoutes.barangDetail(widget.itemId));

  Future<void> _submit(DateTime mulai, DateTime kembali) async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final booking = await ref.read(bookingRepositoryProvider).create(
            itemId: widget.itemId,
            mulai: mulai,
            kembali: kembali,
            pesan: _pesan.text,
          );
      ref
        ..invalidate(blockedDatesProvider(widget.itemId))
        ..invalidate(myBookingsProvider);
      if (!mounted) return;
      HapticFeedback.lightImpact();
      context.go(AppRoutes.pengajuanTerkirim(booking.id));
    } on BookingException catch (e) {
      if (e is BookingConflictException) {
        ref.invalidate(blockedDatesProvider(widget.itemId));
      }
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = 'Koneksi lagi putus. Coba lagi ya.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mulai = widget.mulai;
    final kembali = widget.kembali;
    final today = dateOnly(ref.watch(clockProvider)());
    final datesValid = mulai != null &&
        kembali != null &&
        periksaRentang(mulai: mulai, kembali: kembali, hariIni: today) == null;
    final listing = ref.watch(itemByIdProvider(widget.itemId));

    final Widget body;
    if (!datesValid) {
      body = _message(
        icon: Icons.event_outlined,
        title: 'Pilih tanggal sewanya dulu, ya',
        actionLabel: 'Kembali ke detail',
        onAction: _toDetail,
      );
    } else {
      body = switch (listing) {
        AsyncData(value: final l?) => _form(l, mulai, kembali),
        AsyncData() => _message(
            icon: Icons.inventory_2_outlined,
            title: 'Barang ini sudah tidak tersedia',
            actionLabel: 'Ke Beranda',
            onAction: () => context.go(AppRoutes.beranda),
          ),
        AsyncError() => _message(
            icon: Icons.wifi_off_rounded,
            title: 'Koneksi lagi putus. Coba lagi ya.',
            actionLabel: 'Coba lagi',
            onAction: () => ref.invalidate(itemByIdProvider(widget.itemId)),
          ),
        _ => Skeletonizer(child: _form(ItemCard.placeholder, mulai, kembali)),
      };
    }

    return Scaffold(body: SafeArea(child: body));
  }

  Widget _header() {
    return Row(
      children: [
        AppBackButton(onPressed: _submitting ? null : _toDetail),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Semantics(
            header: true,
            child: Text('Konfirmasi sewa',
                style: Theme.of(context).textTheme.headlineMedium),
          ),
        ),
      ],
    );
  }

  Widget _message({
    required IconData icon,
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageHome),
      children: [
        _header(),
        const SizedBox(height: AppSpacing.xxxl),
        AppEmptyState(
          icon: icon,
          title: title,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      ],
    );
  }

  Widget _form(ItemListing listing, DateTime mulai, DateTime kembali) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final item = listing.item;
    final hari = hitungHari(mulai, kembali);
    final total = hitungTotal(item.hargaPerHari, mulai, kembali);
    final muted = text.bodySmall?.copyWith(color: scheme.onSurfaceVariant);

    Widget label(String s) => Text(s, style: muted);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome,
                AppSpacing.md, AppSpacing.pageHome, AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    child: Row(
                      children: [
                        ItemThumb(kategori: item.kategori),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.judul,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.titleMedium),
                              const SizedBox(height: AppSpacing.xs / 2),
                              Text('Pemilik: ${listing.owner.nama}',
                                  style: muted),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  label('Ambil'),
                                  Text(formatTanggalPendek(mulai),
                                      style: text.titleMedium),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  label('Kembali'),
                                  Text(formatTanggalPendek(kembali),
                                      style: text.titleMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(child: Text('$hari hari', style: muted)),
                            TextButton(
                              onPressed: _submitting ? null : _toDetail,
                              child: const Text('Ubah'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: Row(
                      children: [
                        Icon(Icons.place_outlined,
                            color: colors.accentText, size: AppSizes.iconMd),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              label('Lokasi ambil'),
                              Text(item.lokasiKampus, style: text.titleMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Rincian biaya', style: text.titleMedium),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Sewa $hari hari × '
                                '${formatRupiah(item.hargaPerHari)}',
                                style: text.bodyMedium,
                              ),
                            ),
                            Flexible(
                              child: Text(formatRupiah(total),
                                  textAlign: TextAlign.end,
                                  style: text.bodyMedium),
                            ),
                          ],
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppSpacing.md),
                          child: Divider(),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text('Total',
                                  style: text.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800)),
                            ),
                            Flexible(
                              child: Text(
                                formatRupiah(total),
                                key: const Key('konfirmasi-total'),
                                textAlign: TextAlign.end,
                                style: text.titleMedium?.copyWith(
                                  color: colors.accentText,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Pembayaran langsung ke pemilik saat serah terima.',
                          style: muted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    key: const Key('konfirmasi-pesan'),
                    label: 'Pesan untuk pemilik (opsional)',
                    hint: 'Contoh: buat liputan acara himpunan, aku ambil '
                        'sore ya.',
                    controller: _pesan,
                    enabled: !_submitting,
                    maxLength: _maxPesan,
                    minLines: 3,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppCheckboxField(
                    key: const Key('konfirmasi-janji'),
                    enabled: !_submitting,
                    validator: (v) =>
                        v == true ? null : 'Centang dulu, ya.',
                    label: const TextSpan(
                      text: 'Aku akan menjaga barang ini dan mengembalikannya '
                          'tepat waktu.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AppStickyBottom(
          children: [
            AppErrorSlot(message: _errorMessage),
            AppButton(
              key: const Key('konfirmasi-kirim'),
              label: 'Kirim pengajuan',
              isLoading: _submitting,
              onPressed: () => _submit(mulai, kembali),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ],
    );
  }
}
