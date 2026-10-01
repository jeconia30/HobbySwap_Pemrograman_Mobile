import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/guards/require_verified.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_check_row.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_press_scale.dart';
import '../../../core/widgets/app_step_header.dart';
import '../../../core/widgets/app_sticky_bottom.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/availability_calendar.dart';
import '../../../core/widgets/item_thumb.dart';
import '../../item/data/item_providers.dart';
import '../../item/domain/item.dart';
import '../../../core/widgets/app_info_note.dart';
import '../data/barter_ai.dart';
import '../data/booking_providers.dart';
import '../domain/booking_repository.dart';
import '../domain/booking_rules.dart';
import 'barter_widgets.dart';
import 'sewa_refresh.dart';

/// Barang milik user yang bisa ditawarkan: yang kategorinya dicari pemilik
/// ditaruh paling atas.
List<ItemListing> urutkanTawaran(List<ItemListing> milikku, Item target) {
  final aktif = milikku.where((l) => l.item.aktif).toList();
  bool dicari(ItemListing l) => target.minatBarter.contains(l.item.kategori);
  return [...aktif.where(dicari), ...aktif.where((l) => !dicari(l))];
}

/// /barang/:id/barter — tawarkan barter dalam 3 langkah: pilih barangmu,
/// pilih tanggal (kosong di kedua barang), tinjau & kirim.
class TawarBarterPage extends ConsumerStatefulWidget {
  const TawarBarterPage({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<TawarBarterPage> createState() => _TawarBarterPageState();
}

class _TawarBarterPageState extends ConsumerState<TawarBarterPage> {
  final _pesan = TextEditingController();
  int _langkah = 1;
  ItemListing? _pilih;
  DateSelection _tanggal = DateSelection.empty;
  bool _komit = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _pesan.dispose();
    super.dispose();
  }

  void _back() {
    if (_langkah > 1) {
      setState(() {
        _langkah--;
        _error = null;
      });
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.barangDetail(widget.itemId));
    }
  }

  Future<void> _kirim() async {
    final pilih = _pilih;
    if (pilih == null || !_tanggal.isComplete) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final b = await ref.read(bookingRepositoryProvider).createBarter(
            itemId: widget.itemId,
            itemTawaranId: pilih.item.id,
            mulai: _tanggal.start!,
            kembali: _tanggal.end!,
            pesan: _pesan.text,
          );
      hapticAksiPenting();
      ref.refreshSewa();
      if (mounted) context.go(AppRoutes.pengajuanTerkirim(b.id));
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
    final target = ref.watch(itemByIdProvider(widget.itemId));
    final milikku = ref.watch(myItemsProvider);
    final theme = Theme.of(context);

    if (target.hasError || milikku.hasError) {
      return _layar(
        AppEmptyState(
          icon: Icons.wifi_off_rounded,
          title: AppTeks.koneksiPutus,
          actionLabel: AppTeks.cobaLagi,
          onAction: () => ref
            ..invalidate(itemByIdProvider(widget.itemId))
            ..invalidate(myItemsProvider),
        ),
      );
    }
    final t = target.value;
    final mine = milikku.value;
    if (target.hasValue && t == null) {
      return _layar(const AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Barang ini sudah tidak tersedia',
      ));
    }
    if (t == null || mine == null) {
      return _layar(const Skeletonizer(
        child: Column(children: [
          ListTile(title: Text('Memuat barangmu')),
          ListTile(title: Text('Memuat barangmu')),
        ]),
      ));
    }

    final (String judul, Widget isi, Widget? tombol) = switch (_langkah) {
      1 => (
          'Pilih barangmu',
          _LangkahPilih(
            target: t.item,
            pilihan: urutkanTawaran(mine, t.item),
            dipilih: _pilih?.item.id,
            onPilih: (l) => setState(() {
              _pilih = l;
              _tanggal = DateSelection.empty;
            }),
          ),
          mine.any((l) => l.item.aktif)
              ? AppButton(
                  key: const Key('barter-lanjut'),
                  label: 'Lanjut',
                  onPressed:
                      _pilih == null ? null : () => setState(() => _langkah = 2),
                )
              : null,
        ),
      2 => (
          'Pilih tanggal',
          _LangkahTanggal(
            itemId: t.item.id,
            tawaranId: _pilih!.item.id,
            selection: _tanggal,
            onChanged: (s) => setState(() => _tanggal = s),
          ),
          AppButton(
            key: const Key('barter-lanjut'),
            label: 'Lanjut',
            onPressed:
                _tanggal.isComplete ? () => setState(() => _langkah = 3) : null,
          ),
        ),
      _ => (
          'Tinjau tawaran',
          _LangkahTinjau(
            target: t.item,
            milikku: _pilih!.item,
            tanggal: _tanggal,
            pesan: _pesan,
            komit: _komit,
            enabled: !_busy,
            onKomit: (v) => setState(() => _komit = v),
          ),
          AppButton(
            key: const Key('barter-kirim'),
            label: 'Kirim tawaran',
            isLoading: _busy,
            onPressed: _komit ? _kirim : null,
          ),
        ),
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome,
                    AppSpacing.md, AppSpacing.pageHome, AppSpacing.xl),
                children: [
                  AppStepHeader(
                    current: _langkah,
                    total: 3,
                    onBack: _busy ? null : _back,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Semantics(
                    header: true,
                    child: Text(judul, style: theme.textTheme.headlineMedium),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Tawarkan barter untuk ${t.item.judul}. Barter = saling '
                    'pinjam untuk tanggal yang sama, lalu sama-sama '
                    'dikembalikan.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  isi,
                ],
              ),
            ),
            if (tombol != null)
              AppStickyBottom(children: [AppErrorSlot(message: _error), tombol]),
          ],
        ),
      ),
    );
  }

  Widget _layar(Widget isi) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pageHome),
            children: [
              AppStepHeader(current: _langkah, total: 3, onBack: _back),
              const SizedBox(height: AppSpacing.xxxl),
              isi,
            ],
          ),
        ),
      );
}

class _LangkahPilih extends ConsumerWidget {
  const _LangkahPilih({
    required this.target,
    required this.pilihan,
    required this.dipilih,
    required this.onPilih,
  });

  final Item target;
  final List<ItemListing> pilihan;
  final String? dipilih;
  final ValueChanged<ItemListing> onPilih;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pilihan.isEmpty) {
      return AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Kamu belum punya barang untuk ditukar.',
        message: 'Pasang barangmu dulu, lalu tawarkan barter.',
        actionLabel: 'Sewakan barang dulu',
        onAction: () => requireVerified(
          context,
          ref,
          onAllowed: () => context.push(AppRoutes.barangTambah),
        ),
      );
    }
    final baris = (pilihan.length / 2).ceil();
    final saran = ref.watch(saranBarterProvider(target.id)).value;
    final barangSaran =
        pilihan.where((l) => l.item.id == saran?.itemId).firstOrNull;
    return Column(
      children: [
        if (saran != null && barangSaran != null) ...[
          AppInfoNote(
            key: const Key('saran-barter-ai'),
            icon: Icons.auto_awesome_rounded,
            message:
                'Saran AI: ${barangSaran.item.judul}. ${saran.alasan}'.trim(),
            actionLabel: dipilih == saran.itemId ? null : 'Pilih ini',
            onAction: () => onPilih(barangSaran),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        for (var r = 0; r < baris; r++) ...[
          if (r > 0) const SizedBox(height: AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final i in [r * 2, r * 2 + 1]) ...[
                  if (i == r * 2 + 1) const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: i < pilihan.length
                        ? _KartuPilih(
                            listing: pilihan[i],
                            dicari: target.minatBarter
                                .contains(pilihan[i].item.kategori),
                            dipilih: pilihan[i].item.id == dipilih,
                            onTap: () => onPilih(pilihan[i]),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _KartuPilih extends StatelessWidget {
  const _KartuPilih({
    required this.listing,
    required this.dicari,
    required this.dipilih,
    required this.onTap,
  });

  final ItemListing listing;
  final bool dicari;
  final bool dipilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final item = listing.item;
    return Semantics(
      button: true,
      selected: dipilih,
      label: '${item.judul}${dicari ? ', dicari pemilik' : ''}',
      excludeSemantics: true,
      child: AppPressScale(
        child: Material(
          color: scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.cardAll,
            side: BorderSide(
              color: dipilih ? scheme.primary : colors.border,
              width: dipilih ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: Key('pilih-${item.id}'),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ItemThumb(kategori: item.kategori),
                      const Spacer(),
                      if (dipilih)
                        Icon(Icons.check_circle_rounded,
                            color: scheme.primary, size: AppSizes.iconMd),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    item.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${formatRupiah(item.hargaPerHari)}/hari',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  if (dicari) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      key: Key('dicari-${item.id}'),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs / 2),
                      decoration: BoxDecoration(
                        color: colors.accentSoft,
                        borderRadius: AppRadius.pillAll,
                      ),
                      child: Text(
                        'Dicari pemilik',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.accentText,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LangkahTanggal extends ConsumerWidget {
  const _LangkahTanggal({
    required this.itemId,
    required this.tawaranId,
    required this.selection,
    required this.onChanged,
  });

  final String itemId;
  final String tawaranId;
  final DateSelection selection;
  final ValueChanged<DateSelection> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final blocked = ref.watch(barterBlockedProvider((itemId, tawaranId)));
    final today = dateOnly(ref.watch(clockProvider)());
    final ranges = blocked.value ?? const <RentangTanggal>[];
    if (blocked.hasError) {
      return AppEmptyState(
        icon: Icons.event_busy_outlined,
        title: 'Jadwal belum bisa dimuat.',
        actionLabel: AppTeks.cobaLagi,
        onAction: () =>
            ref.invalidate(barterBlockedProvider((itemId, tawaranId))),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline_rounded,
                size: AppSizes.iconXs,
                color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Tanggal harus kosong di kedua barang.',
                key: const Key('barter-ket-tanggal'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Skeletonizer(
          enabled: blocked.isLoading && !blocked.hasValue,
          child: AvailabilityCalendar(
            today: today,
            selection: selection,
            onChanged: onChanged,
            isBlocked: (d) => tanggalTerblokir(d, ranges),
            validateRange: (s, e) => periksaRentang(
              mulai: s,
              kembali: e,
              hariIni: today,
              terblokir: ranges,
            )?.pesan,
          ),
        ),
      ],
    );
  }
}

class _LangkahTinjau extends StatelessWidget {
  const _LangkahTinjau({
    required this.target,
    required this.milikku,
    required this.tanggal,
    required this.pesan,
    required this.komit,
    required this.enabled,
    required this.onKomit,
  });

  final Item target;
  final Item milikku;
  final DateSelection tanggal;
  final TextEditingController pesan;
  final bool komit;
  final bool enabled;
  final ValueChanged<bool> onKomit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final muted = text.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final hari = hitungHari(tanggal.start!, tanggal.end!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BarterDuaKartu(
          key: const Key('barter-tinjau'),
          kiriLabel: 'Kamu pinjam',
          kiri: target,
          kananLabel: 'Kamu pinjamkan',
          kanan: milikku,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Nilai sewa setara ${formatRupiah(target.hargaPerHari)} vs '
          '${formatRupiah(milikku.hargaPerHari)} per hari',
          key: const Key('nilai-setara'),
          textAlign: TextAlign.center,
          style: muted,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Icon(Icons.event_outlined,
                size: AppSizes.iconSm, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${formatRentangPendek(tanggal.start!, tanggal.end!)} · '
                '$hari hari · tanpa biaya',
                style: text.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          key: const Key('barter-pesan'),
          label: 'Pesan untuk pemilik (opsional)',
          hint: 'Contoh: aku pakai buat camping akhir pekan.',
          controller: pesan,
          enabled: enabled,
          maxLength: 300,
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
        ),
        AppCheckRow(
          key: const Key('barter-komit'),
          label: 'Aku akan menjaga barang pinjaman dan mengembalikannya tepat '
              'waktu dalam kondisi yang sama.',
          value: komit,
          onChanged: onKomit,
        ),
      ],
    );
  }
}
