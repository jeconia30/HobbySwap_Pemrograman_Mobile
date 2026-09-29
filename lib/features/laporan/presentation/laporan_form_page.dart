import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_check_row.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../booking/data/booking_providers.dart';
import '../../booking/domain/booking.dart';
import '../../handover/data/checklist_providers.dart';
import '../../handover/domain/handover_checklist.dart';
import '../../item/domain/item.dart';
import '../../item/domain/kategori.dart';
import '../../item/presentation/kategori_visual.dart';
import '../data/laporan_providers.dart';
import '../domain/laporan.dart';
import '../domain/laporan_repository.dart';

/// /laporan/baru — laporan kerusakan/keterlambatan (dari checklist akhir,
/// [bookingId] diisi) atau laporan pengguna umum ([terlaporId] diisi).
class LaporanFormPage extends ConsumerStatefulWidget {
  const LaporanFormPage({
    super.key,
    this.bookingId,
    this.terlaporId,
    this.barangId,
  });

  final String? bookingId;
  final String? terlaporId;

  /// Barter: barang tawaran yang dilaporkan (null = barang utama).
  final String? barangId;

  @override
  ConsumerState<LaporanFormPage> createState() => _LaporanFormPageState();
}

class _LaporanFormPageState extends ConsumerState<LaporanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _deskripsi = TextEditingController();
  final _nominal = TextEditingController();
  late JenisLaporan _jenis = widget.bookingId == null
      ? JenisLaporan.perilaku
      : JenisLaporan.kerusakan;
  Set<String>? _item;
  UsulanPenyelesaian? _usulan;
  bool _busy = false;
  bool _submitted = false;
  String? _error;

  bool get _sewa => widget.bookingId != null;

  /// Barang yang dilaporkan (barter: bisa barang tawaran).
  Item _barangDari(BookingDetail d) =>
      widget.barangId != null && d.itemTawaran?.id == widget.barangId
          ? d.itemTawaran!
          : d.item;

  @override
  void dispose() {
    _deskripsi.dispose();
    _nominal.dispose();
    super.dispose();
  }

  void _back() => context.canPop()
      ? context.pop()
      : context.go(_sewa ? AppRoutes.sewaan : AppRoutes.profil);

  Future<void> _kirim({
    required String terlaporId,
    required List<String> foto,
  }) async {
    setState(() {
      _submitted = true;
      _error = null;
    });
    final valid = _formKey.currentState!.validate();
    if (_jenis == JenisLaporan.kerusakan && (_item?.isEmpty ?? true)) {
      setState(() => _error = 'Pilih item yang bermasalah dulu, ya.');
      return;
    }
    if (_jenis.terkaitSewa && _usulan == null) {
      setState(() => _error = 'Pilih usulan penyelesaiannya dulu, ya.');
      return;
    }
    if (!valid) return;
    setState(() => _busy = true);
    try {
      final laporan = await ref.read(laporanRepositoryProvider).kirim(
            bookingId: widget.bookingId,
            terlaporId: terlaporId,
            jenis: _jenis,
            itemBermasalah: _jenis == JenisLaporan.kerusakan
                ? (_item?.toList() ?? const [])
                : const [],
            deskripsi: _deskripsi.text,
            fotoBukti: foto,
            usulan: _usulan,
            nominal: int.tryParse(_nominal.text.trim()),
          );
      hapticAksiPenting();
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      context.pushReplacement(AppRoutes.laporanDetail(laporan.id));
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Laporan terkirim.')));
    } on LaporanException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = AppTeks.koneksiPutus);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(authControllerProvider)?.id;
    final id = widget.bookingId;
    if (id == null) {
      final terlapor = widget.terlaporId;
      if (terlapor == null || me == null) return _gagal();
      return _form(terlaporId: terlapor, foto: const []);
    }

    final detail = ref.watch(bookingByIdProvider(id));
    final awal = ref.watch(checklistProvider((id, TahapChecklist.awal, widget.barangId)));
    final akhir = ref.watch(checklistProvider((id, TahapChecklist.akhir, widget.barangId)));
    if (detail.hasError || awal.hasError || akhir.hasError) {
      return _gagal(onRetry: () {
        ref
          ..invalidate(bookingByIdProvider(id))
          ..invalidate(checklistProvider((id, TahapChecklist.awal, widget.barangId)))
          ..invalidate(checklistProvider((id, TahapChecklist.akhir, widget.barangId)));
      });
    }
    final d = detail.value;
    final ca = awal.value;
    final ck = akhir.value;
    if (d == null || ca == null || ck == null || me == null) {
      return detail.hasValue && d == null
          ? _gagal()
          : const Scaffold(
              body: SafeArea(child: Center(child: CircularProgressIndicator())),
            );
    }
    // Default: item yang tidak dicentang saat pengembalian.
    _item ??= {for (final k in ck.daftarKondisi) if (!k.dicek) k.label};
    final terlapor = me == d.pemilik.id ? d.penyewa.id : d.pemilik.id;
    final foto = [
      for (final k in ck.daftarKondisi)
        if (_item!.contains(k.label) && k.foto != null) k.foto!,
    ];
    return _form(
      terlaporId: terlapor,
      foto: foto,
      detail: d,
      awal: ca,
      akhir: ck,
    );
  }

  Widget _gagal({VoidCallback? onRetry}) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pageHome),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: AppBackButton(onPressed: _back),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppEmptyState(
                icon: onRetry == null
                    ? Icons.report_off_outlined
                    : Icons.wifi_off_rounded,
                title: onRetry == null
                    ? 'Laporan ini belum bisa dibuat.'
                    : AppTeks.koneksiPutus,
                actionLabel: onRetry == null ? null : AppTeks.cobaLagi,
                onAction: onRetry,
              ),
            ],
          ),
        ),
      );

  Widget _form({
    required String terlaporId,
    required List<String> foto,
    BookingDetail? detail,
    HandoverChecklist? awal,
    HandoverChecklist? akhir,
  }) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final muted = text.bodyMedium
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final pilihanJenis = _sewa
        ? const [JenisLaporan.kerusakan, JenisLaporan.keterlambatan]
        : const [JenisLaporan.perilaku, JenisLaporan.lainnya];

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome,
                      AppSpacing.md, AppSpacing.pageHome, AppSpacing.xl),
                  children: [
                    Row(
                      children: [
                        AppBackButton(onPressed: _busy ? null : _back),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Text(
                              _sewa ? 'Laporkan kerusakan' : 'Laporkan pengguna',
                              style: text.headlineMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _sewa
                          ? '${_barangDari(detail!).judul} · pengembalian bersama '
                              '${detail.pemilik.id == terlaporId ? detail.pemilik.nama : detail.penyewa.nama}'
                          : 'Laporanmu dirahasiakan dan ditinjau tim '
                              'HobbySwap.',
                      style: muted,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Jenis masalah', style: text.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        for (final j in pilihanJenis)
                          AppChip(
                            key: Key('jenis-${j.name}'),
                            label: j.label,
                            selected: _jenis == j,
                            onTap: () => setState(() => _jenis = j),
                          ),
                      ],
                    ),
                    if (_sewa && _jenis == JenisLaporan.kerusakan) ...[
                      const SizedBox(height: AppSpacing.xl),
                      Text('Item yang bermasalah', style: text.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      for (final (i, k) in akhir!.daftarKondisi.indexed)
                        AppCheckRow(
                          key: Key('item-bermasalah-$i'),
                          label: k.label,
                          value: _item!.contains(k.label),
                          onChanged: (v) => setState(() => v
                              ? _item!.add(k.label)
                              : _item!.remove(k.label)),
                        ),
                      for (final k in akhir.daftarKondisi)
                        if (_item!.contains(k.label)) ...[
                          const SizedBox(height: AppSpacing.md),
                          _BandingFoto(
                            label: k.label,
                            kategori: _barangDari(detail!).kategori,
                            saatAmbil: awal!.daftarKondisi
                                .where((a) => a.label == k.label)
                                .firstOrNull
                                ?.foto,
                            saatKembali: k.foto,
                          ),
                        ],
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      key: const Key('lapor-deskripsi'),
                      label: 'Ceritakan masalahnya',
                      hint: _sewa
                          ? 'Apa yang rusak/kurang, sejak kapan, dan '
                              'bagaimana kondisinya sekarang.'
                          : 'Apa yang terjadi dan kapan.',
                      controller: _deskripsi,
                      enabled: !_busy,
                      validator: (v) {
                        final n = v?.trim().length ?? 0;
                        if (n < laporanMin) {
                          return 'Minimal $laporanMin karakter, ya.';
                        }
                        return n > laporanMaks
                            ? 'Maksimal $laporanMaks karakter.'
                            : null;
                      },
                      maxLength: laporanMaks,
                      minLines: 4,
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    if (_jenis.terkaitSewa) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text('Usulan penyelesaian', style: text.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          for (final u in UsulanPenyelesaian.values)
                            AppChip(
                              key: Key('usulan-${u.name}'),
                              label: u.label,
                              selected: _usulan == u,
                              onTap: () => setState(() => _usulan = u),
                            ),
                        ],
                      ),
                      if (_usulan == UsulanPenyelesaian.gantiRugi) ...[
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          key: const Key('lapor-nominal'),
                          label: 'Nominal ganti rugi',
                          hint: '50000',
                          prefixText: 'Rp ',
                          controller: _nominal,
                          enabled: !_busy,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                          ],
                          validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0
                              ? 'Isi nominal ganti ruginya'
                              : null,
                        ),
                      ],
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppErrorSlot(message: _error),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome, 0,
                    AppSpacing.pageHome, AppSpacing.lg),
                child: AppButton(
                  key: const Key('lapor-kirim'),
                  label: 'Kirim laporan',
                  isLoading: _busy,
                  onPressed: () => _kirim(terlaporId: terlaporId, foto: foto),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Foto "Saat ambil" vs "Saat kembali" berdampingan (simulasi).
class _BandingFoto extends StatelessWidget {
  const _BandingFoto({
    required this.label,
    required this.kategori,
    required this.saatAmbil,
    required this.saatKembali,
  });

  final String label;
  final Kategori kategori;
  final String? saatAmbil;
  final String? saatKembali;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget tile(String judul, String? foto) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(judul,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.xs),
              Semantics(
                label: foto == null
                    ? '$judul: belum ada foto'
                    : '$judul: foto $label',
                image: foto != null,
                child: AspectRatio(
                  aspectRatio: AppSizes.fotoPesan.aspectRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: foto == null
                          ? AppColors.of(context).surfaceAlt
                          : kategori.tileColor,
                      borderRadius: AppRadius.previewAll,
                    ),
                    child: Icon(
                      foto == null
                          ? Icons.hide_image_outlined
                          : Icons.image_outlined,
                      color: foto == null
                          ? theme.colorScheme.onSurfaceVariant
                          : AppPalette.cream,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            tile('Saat ambil', saatAmbil),
            const SizedBox(width: AppSpacing.md),
            tile('Saat kembali', saatKembali),
          ],
        ),
      ],
    );
  }
}

