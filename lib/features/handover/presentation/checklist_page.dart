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
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_info_note.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/widgets/app_sticky_bottom.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/dashed_border.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../booking/data/booking_providers.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/booking_repository.dart';
import '../../booking/domain/booking_rules.dart';
import '../../booking/presentation/sewa_refresh.dart';
import '../data/checklist_providers.dart';
import '../domain/handover_checklist.dart';
import '../../../core/constants/app_strings.dart';
import '../../chat/presentation/chat_open.dart';
import '../../../core/widgets/app_icon_tile_button.dart';

class ChecklistPage extends ConsumerStatefulWidget {
  const ChecklistPage({
    super.key,
    required this.bookingId,
    this.initialTahap = TahapChecklist.awal,
  });

  final String bookingId;
  final TahapChecklist initialTahap;

  @override
  ConsumerState<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends ConsumerState<ChecklistPage> {
  late TahapChecklist _tahap = widget.initialTahap;

  /// Barang yang dicek: `null` = barang utama; untuk barter bisa id barang
  /// tawaran (tab "Yang kamu pinjam" / "Yang kamu pinjamkan").
  String? _barang;

  /// Per tahap & barang, supaya isi tidak hilang saat berpindah segmen.
  final _catatanPer = <(TahapChecklist, String?), TextEditingController>{};
  final _drafts = <(TahapChecklist, String?), List<KondisiItem>>{};

  TextEditingController get _catatan =>
      _catatanPer.putIfAbsent((_tahap, _barang), TextEditingController.new);

  /// Salinan yang sedang diedit (centang & foto); persetujuan dari stream.
  List<KondisiItem>? get _draft => _drafts[(_tahap, _barang)];
  set _draft(List<KondisiItem>? v) => v == null
      ? _drafts.remove((_tahap, _barang))
      : _drafts[(_tahap, _barang)] = v;
  bool _busy = false;
  bool _approvedHere = false;
  bool _bayarBusy = false;
  List<String> _masalah = const [];
  String? _error;

  (String, TahapChecklist, String?) get _key =>
      (widget.bookingId, _tahap, _barang);

  @override
  void dispose() {
    for (final c in _catatanPer.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.sewaan);

  void _gantiBarang(String? barang) => setState(() {
    _barang = barang;
    _masalah = const [];
    _error = null;
  });

  void _gantiTahap(TahapChecklist t) => setState(() {
    _tahap = t;
    _masalah = const [];
    _error = null;
  });

  HandoverChecklist _merged(HandoverChecklist remote) => remote.copyWith(
    daftarKondisi: _draft ?? remote.daftarKondisi,
    catatan: _catatan.text.trim().isEmpty ? null : _catatan.text.trim(),
  );

  void _edit(
    HandoverChecklist remote,
    int i,
    KondisiItem Function(KondisiItem) f,
  ) {
    final items = [...(_draft ?? remote.daftarKondisi)];
    items[i] = f(items[i]);
    setState(() {
      _draft = items;
      _masalah = const [];
    });
    ref.read(checklistRepositoryProvider).save(_merged(remote)).ignore();
  }

  Future<void> _approve(HandoverChecklist remote, String userId) async {
    final merged = _merged(remote);
    final masalah = periksaChecklist(merged);
    setState(() {
      _masalah = masalah;
      _error = null;
    });
    if (masalah.isNotEmpty) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(checklistRepositoryProvider);
      await repo.save(merged);
      _approvedHere = true;
      final result = await repo.approve(
        widget.bookingId,
        _tahap,
        userId,
        itemId: _barang,
      );
      hapticAksiPenting();
      if (!mounted) return;
      setState(() => _busy = false);
      if (result.selesai) _selesai();
    } on ChecklistException catch (e) {
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

  Future<void> _ubahBooking(Future<Booking> Function() f) async {
    setState(() {
      _bayarBusy = true;
      _error = null;
    });
    try {
      await f();
      ref.invalidate(bookingByIdProvider(widget.bookingId));
      ref.refreshSewa();
    } on BookingException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _bayarBusy = false);
    }
  }

  Future<void> _catatBayar(Booking b, MetodeBayar metode, bool diterima) =>
      _ubahBooking(
        () => ref
            .read(bookingRepositoryProvider)
            .catatPembayaran(b.id, metode: metode, diterima: diterima),
      );

  Future<void> _catatDenda(Booking b, bool diterima, {String? itemId}) =>
      _ubahBooking(
        () => ref
            .read(bookingRepositoryProvider)
            .catatDenda(b.id, diterima: diterima, itemId: itemId),
      );

  void _selesai() {
    if (!_approvedHere) return;
    _approvedHere = false;
    ref.refreshSewa();
    // Barter: checklist satu barang beres, barang satunya belum.
    final b = ref.read(bookingByIdProvider(widget.bookingId)).value?.booking;
    if (b != null && b.barter) {
      final lain = _barang == null ? b.itemTawaranId : null;
      final lainBeres =
          ref
              .read(checklistProvider((widget.bookingId, _tahap, lain)))
              .value
              ?.selesai ??
          false;
      if (!lainBeres) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Satu barang beres. Lanjutkan checklist barang '
                'satunya, ya.',
              ),
            ),
          );
        _gantiBarang(lain);
        return;
      }
    }
    if (_tahap == TahapChecklist.akhir) {
      context.pushReplacement(AppRoutes.rating(widget.bookingId));
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Serah terima beres. Selamat memakai!')),
      );
    _back();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(checklistProvider(_key), (prev, next) {
      final now = next.value;
      if (now != null && now.selesai && prev?.value?.selesai != true) {
        _selesai();
      }
    });

    final detail = ref.watch(bookingByIdProvider(widget.bookingId));
    final checklist = ref.watch(checklistProvider(_key));
    final awal = ref.watch(
      checklistProvider((widget.bookingId, TahapChecklist.awal, _barang)),
    );
    final user = ref.watch(authControllerProvider);

    if (detail.hasError || checklist.hasError) {
      return _message(
        icon: Icons.wifi_off_rounded,
        title: checklist.error is ChecklistException
            ? (checklist.error! as ChecklistException).message
            : AppTeks.koneksiPutus,
        onRetry: () => ref
          ..invalidate(bookingByIdProvider(widget.bookingId))
          ..invalidate(checklistProvider(_key)),
      );
    }
    if (detail.hasValue && detail.value == null) {
      return _message(
        icon: Icons.receipt_long_outlined,
        title: AppTeks.sewaTidakDitemukan,
      );
    }
    final d = detail.value;
    final remote = checklist.value;
    if (d == null || remote == null || user == null) {
      return Scaffold(
        body: SafeArea(
          child: Skeletonizer(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.pageHome),
              children: [
                const Text('Checklist serah terima'),
                const SizedBox(height: AppSpacing.xl),
                for (var i = 0; i < 5; i++)
                  const ListTile(title: Text('Memuat kondisi barang')),
              ],
            ),
          ),
        ),
      );
    }
    if (_draft == null) {
      _draft = remote.daftarKondisi;
      _catatan.text = remote.catatan ?? '';
    }
    // Barter: tahap akhir terbuka setelah checklist awal kedua barang beres.
    final awalSelesai = d.booking.barter
        ? d.booking.status == StatusBooking.berlangsung ||
              d.booking.status == StatusBooking.selesai
        : awal.value?.selesai ?? false;
    return _content(d, remote, user, awalSelesai: awalSelesai);
  }

  Widget _message({
    required IconData icon,
    required String title,
    VoidCallback? onRetry,
  }) {
    return Scaffold(
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
              icon: icon,
              title: title,
              actionLabel: onRetry == null ? null : AppTeks.cobaLagi,
              onAction: onRetry,
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(
    BookingDetail d,
    HandoverChecklist remote,
    User user, {
    required bool awalSelesai,
  }) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final barter = d.booking.barter;
    final tawaran = _barang != null;
    final barang = tawaran ? d.itemTawaran! : d.item;
    // Pemilik barang yang sedang dicek (barang tawaran = milik pengaju).
    final pemilikBarang = tawaran ? d.penyewa : d.pemilik;
    final isOwner = pemilikBarang.id == user.id;
    final lawan = d.lawanDari(user.id);
    final dendaTercatat = tawaran
        ? d.booking.dendaTawaran
        : d.booking.dendaTerlambat;
    final akuSetuju = isOwner
        ? remote.disetujuiPemilik
        : remote.disetujuiPenyewa;
    final lawanSetuju = isOwner
        ? remote.disetujuiPenyewa
        : remote.disetujuiPemilik;
    final lawanPada = isOwner
        ? remote.disetujuiPenyewaPada
        : remote.disetujuiPemilikPada;
    final items = _draft!;
    final dicek = items.where((k) => k.dicek).length;
    final editable = !akuSetuju && !remote.selesai && !_busy;
    final akhir = _tahap == TahapChecklist.akhir;
    final lawanNama = firstName(lawan.nama);
    final today = dateOnly(ref.watch(clockProvider)());
    final denda = hitungDenda(
      tanggalKembali: d.booking.tanggalKembali,
      hariKembali: today,
      dendaPerHari: barang.dendaPerHari,
    );
    // Syarat pemilik sebelum boleh menyetujui (pembayaran / denda).
    final String? syaratPemilik = !isOwner
        ? null
        : !akhir && !barter && d.booking.statusBayar != StatusBayar.lunas
        ? 'Aktifkan "Pembayaran sudah diterima" dulu, ya.'
        : akhir && denda.total > 0 && dendaTercatat < denda.total
        ? 'Konfirmasi denda keterlambatan dulu, ya.'
        : null;

    final status = switch ((remote.selesai, akuSetuju, lawanSetuju)) {
      (true, _, _) =>
        'Kalian berdua sudah menyetujui. '
            '${akhir ? 'Pengembalian' : 'Serah terima'} beres.',
      (_, false, true) =>
        '$lawanNama sudah menyetujui'
            '${lawanPada == null ? '' : ' pukul ${formatJam(lawanPada)}'}. '
            'Tinggal konfirmasi darimu.',
      (_, true, false) => 'Menunggu $lawanNama menyetujui…',
      _ => 'Cek barang bersama $lawanNama, lalu setujui.',
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHome,
                  AppSpacing.md,
                  AppSpacing.pageHome,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        AppBackButton(onPressed: _back),
                        const Spacer(),
                        AppIconTileButton(
                          key: const Key('chat-checklist'),
                          icon: Icons.chat_bubble_outline_rounded,
                          tooltip: 'Chat ${lawan.nama}',
                          onPressed: () => bukaObrolan(
                            context,
                            otherUserId: lawan.id,
                            itemId: d.item.id,
                            bookingId: d.booking.id,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Semantics(
                      header: true,
                      child: Text(
                        'Checklist serah terima',
                        style: text.headlineMedium?.merge(
                          AppTextStyles.checklistTitle,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${barang.judul} · '
                                '${isOwner ? (barter ? 'dipinjam' : 'disewa') : 'dari'} '
                                '${namaPendek(lawan.nama)} · ',
                          ),
                          TextSpan(
                            text: '$dicek dari ${items.length} dicek',
                            style: TextStyle(
                              color: colors.accentText,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      style: text.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (barter) ...[
                      const SizedBox(height: AppSpacing.lg),
                      // Tab per barang: yang kupinjam dulu.
                      Builder(
                        builder: (context) {
                          final sayaPengaju = user.id == d.penyewa.id;
                          final pinjam = sayaPengaju
                              ? null
                              : d.booking.itemTawaranId;
                          final pinjamkan = sayaPengaju
                              ? d.booking.itemTawaranId
                              : null;
                          return AppSegmentedControl(
                            selected: _barang == pinjam ? 0 : 1,
                            onChanged: (i) =>
                                _gantiBarang(i == 0 ? pinjam : pinjamkan),
                            segments: const [
                              AppSegment(
                                'Yang kamu pinjam',
                                key: Key('tab-pinjam'),
                              ),
                              AppSegment(
                                'Yang kamu pinjamkan',
                                key: Key('tab-pinjamkan'),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AppSegmentedControl(
                      selected: _tahap.index,
                      onChanged: (i) => _gantiTahap(TahapChecklist.values[i]),
                      segments: [
                        AppSegment(
                          'Awal · ${formatTanggalPendek(d.booking.tanggalMulai)}',
                          key: const Key('tahap-awal'),
                        ),
                        AppSegment(
                          'Akhir · saat kembali',
                          enabled: awalSelesai,
                          key: const Key('tahap-akhir'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < items.length; i++) ...[
                            if (i > 0) const Divider(),
                            _KondisiRow(
                              item: items[i],
                              index: i,
                              enabled: editable,
                              onToggle: () => _edit(
                                remote,
                                i,
                                (k) => k.copyWith(dicek: !k.dicek),
                              ),
                              onFoto: () => _edit(
                                remote,
                                i,
                                (k) => k.copyWith(
                                  foto: k.foto == null
                                      ? 'simulasi://checklist/'
                                            '${widget.bookingId}/${_tahap.name}/$i'
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      key: const Key('checklist-catatan'),
                      label: 'Catatan kondisi',
                      hint: 'Contoh: ada baret halus di sisi kiri sejak awal.',
                      controller: _catatan,
                      enabled: editable,
                      maxLength: 300,
                      minLines: 3,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    if (!akhir && !barter && isOwner) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _PembayaranCard(
                        booking: d.booking,
                        enabled: !akuSetuju && !remote.selesai && !_bayarBusy,
                        onUbah: (metode, diterima) =>
                            _catatBayar(d.booking, metode, diterima),
                      ),
                    ] else if (!akhir && !barter && !remote.selesai) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppInfoNote(
                        icon: Icons.payments_outlined,
                        message:
                            'Bayar ${formatRupiah(d.booking.totalHarga)} '
                            'langsung ke ${firstName(d.pemilik.nama)} saat '
                            'serah terima: tunai atau transfer.',
                      ),
                    ],
                    if (akhir && denda.total > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _DendaCard(
                        denda: denda,
                        dendaPerHari: barang.dendaPerHari,
                        pemilik: isOwner,
                        diterima: dendaTercatat >= denda.total,
                        enabled: !akuSetuju && !remote.selesai && !_bayarBusy,
                        onUbah: (v) =>
                            _catatDenda(d.booking, v, itemId: _barang),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      key: const Key('checklist-persetujuan'),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: colors.accentSoft,
                        borderRadius: AppRadius.noteAll,
                      ),
                      child: Row(
                        children: [
                          _AvatarPair(pemilik: d.pemilik, penyewa: d.penyewa),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Semantics(
                              liveRegion: true,
                              child: Text(status, style: text.bodyMedium),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (akhir && items.any((k) => !k.dicek)) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          key: const Key('laporkan-kerusakan'),
                          onPressed: () => context.push(
                            AppRoutes.laporanBaru(
                              bookingId: d.booking.id,
                              barangId: _barang,
                            ),
                          ),
                          icon: const Icon(Icons.flag_outlined),
                          label: const Text('Laporkan kerusakan'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            AppStickyBottom(
              children: [
                AppErrorSlot(
                  message: [..._masalah, ?_error].isEmpty
                      ? null
                      : [..._masalah, ?_error].join('\n'),
                ),
                if (syaratPemilik != null && !akuSetuju && !remote.selesai)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      syaratPemilik,
                      key: const Key('checklist-syarat'),
                      textAlign: TextAlign.center,
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (!remote.selesai)
                  AppButton(
                    key: const Key('checklist-setujui'),
                    label: akuSetuju
                        ? 'Menunggu $lawanNama…'
                        : akhir
                        ? 'Setujui pengembalian'
                        : 'Setujui serah terima',
                    isLoading: _busy,
                    onPressed: akuSetuju || syaratPemilik != null
                        ? null
                        : () => _approve(remote, user.id),
                  )
                else
                  AppButton(
                    label: AppTeks.kembali,
                    variant: AppButtonVariant.secondary,
                    onPressed: _back,
                  ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KondisiRow extends StatelessWidget {
  const _KondisiRow({
    required this.item,
    required this.index,
    required this.enabled,
    required this.onToggle,
    required this.onFoto,
  });

  final KondisiItem item;
  final int index;
  final bool enabled;
  final VoidCallback onToggle;
  final VoidCallback onFoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.checklistRow),
      child: Row(
        children: [
          Expanded(
            child: MergeSemantics(
              child: InkWell(
                key: Key('kondisi-$index'),
                onTap: enabled ? onToggle : null,
                borderRadius: AppRadius.inputAll,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppSizes.minTapTarget,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        SizedBox.square(
                          dimension: AppSizes.checkbox,
                          child: Checkbox(
                            value: item.dicek,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onChanged: enabled ? (_) => onToggle() : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            item.label,
                            style: theme.textTheme.bodyMedium?.merge(
                              AppTextStyles.checklistLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FotoSlot(
            key: Key('foto-$index'),
            label: item.label,
            filled: item.foto != null,
            enabled: enabled,
            onTap: onFoto,
          ),
        ],
      ),
    );
  }
}

class _FotoSlot extends StatelessWidget {
  const _FotoSlot({
    super.key,
    required this.label,
    required this.filled,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(AppRadius.filterButton));
    final visual = filled
        ? Container(
            width: AppSizes.fotoSlot,
            height: AppSizes.fotoSlot,
            decoration: const BoxDecoration(
              color: AppPalette.brandMid,
              borderRadius: radius,
            ),
            child: const Icon(
              Icons.image_rounded,
              color: AppPalette.cream,
              size: AppSizes.iconMd,
            ),
          )
        : DashedBorder(
            radius: AppRadius.filterButton,
            child: SizedBox.square(
              dimension: AppSizes.fotoSlot,
              child: Icon(
                Icons.add_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: AppSizes.iconMd,
              ),
            ),
          );

    return Semantics(
      button: true,
      enabled: enabled,
      label: filled
          ? 'Foto bukti $label, ketuk untuk menghapus'
          : 'Tambah foto bukti $label',
      excludeSemantics: true,
      child: InkResponse(
        onTap: enabled ? onTap : null,
        radius: AppSizes.minTapTarget / 2,
        child: SizedBox.square(
          dimension: AppSizes.minTapTarget,
          child: Center(child: visual),
        ),
      ),
    );
  }
}

class _AvatarPair extends StatelessWidget {
  const _AvatarPair({required this.pemilik, required this.penyewa});

  final User pemilik;
  final User penyewa;

  @override
  Widget build(BuildContext context) {
    const size = AppSizes.avatarSm;
    return ExcludeSemantics(
      child: SizedBox(
        width: size * 1.6,
        height: size,
        child: Stack(
          children: [
            AppAvatar(user: pemilik, size: size, showBadge: false),
            Positioned(
              left: size * 0.6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.of(context).accentSoft,
                    width: AppSizes.dashedStroke,
                  ),
                ),
                child: AppAvatar(user: penyewa, size: size, showBadge: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bagian "Pembayaran" di checklist awal, hanya untuk pemilik: metode dan
/// switch "Pembayaran sudah diterima" (syarat menyetujui serah terima).
class _PembayaranCard extends StatelessWidget {
  const _PembayaranCard({
    required this.booking,
    required this.enabled,
    required this.onUbah,
  });

  final Booking booking;
  final bool enabled;
  final void Function(MetodeBayar metode, bool diterima) onUbah;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final metode = booking.metodeBayar ?? MetodeBayar.tunai;
    final lunas = booking.statusBayar == StatusBayar.lunas;

    return AppCard(
      key: const Key('checklist-pembayaran'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Pembayaran', style: text.titleMedium)),
              BayarBadge(booking.statusBayar),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${formatRupiah(booking.totalHarga)} dibayar penyewa langsung '
            'kepadamu saat serah terima.',
            style: text.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final m in MetodeBayar.values)
                AppChip(
                  key: Key('metode-${m.name}'),
                  label: m.label,
                  selected: metode == m,
                  onTap: () {
                    if (enabled) onUbah(m, lunas);
                  },
                ),
            ],
          ),
          // Material sendiri: latar kartu tidak menutupi efek ink ListTile.
          Material(
            type: MaterialType.transparency,
            child: MergeSemantics(
              child: SwitchListTile(
                key: const Key('bayar-diterima'),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Pembayaran sudah diterima',
                  style: text.bodyMedium,
                ),
                value: lunas,
                onChanged: enabled ? (v) => onUbah(metode, v) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Denda keterlambatan di checklist akhir; pemilik mengonfirmasi diterima.
class _DendaCard extends StatelessWidget {
  const _DendaCard({
    required this.denda,
    required this.dendaPerHari,
    required this.pemilik,
    required this.diterima,
    required this.enabled,
    required this.onUbah,
  });

  final ({int hari, int total}) denda;
  final int dendaPerHari;
  final bool pemilik;
  final bool diterima;
  final bool enabled;
  final ValueChanged<bool> onUbah;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final error = theme.colorScheme.error;
    return AppCard(
      key: const Key('checklist-denda'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Denda keterlambatan', style: text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Terlambat ${denda.hari} hari × ${formatRupiah(dendaPerHari)} = '
            '${formatRupiah(denda.total)}',
            key: const Key('denda-total'),
            style: text.bodyMedium?.copyWith(
              color: error,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (pemilik)
            // Material sendiri: latar kartu tidak menutupi efek ink ListTile.
            Material(
              type: MaterialType.transparency,
              child: MergeSemantics(
                child: SwitchListTile(
                  key: const Key('denda-diterima'),
                  contentPadding: EdgeInsets.zero,
                  title: Text('Denda diterima', style: text.bodyMedium),
                  value: diterima,
                  onChanged: enabled ? onUbah : null,
                ),
              ),
            )
          else ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Bayar denda ke pemilik saat pengembalian.',
              style: text.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
