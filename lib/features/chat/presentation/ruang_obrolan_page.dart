import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
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
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_verified_chip.dart';
import '../../../core/widgets/batal_mendadak_label.dart';
import '../../auth/domain/user.dart';
import '../../booking/domain/booking.dart';
import '../../review/data/review_providers.dart';
import '../data/chat_ai.dart';
import '../data/chat_providers.dart';
import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';
import 'chat_bubbles.dart';
import 'chat_transaksi.dart';
import 'cod_sheet.dart';

/// Jarak gulir (dari pesan terbaru) yang dianggap "sedang membaca ke atas".
const _ambangGulir = 80.0;

/// Pesan berurutan dari pengirim yang sama dalam jeda ini dirapatkan.
const _jedaRapat = Duration(minutes: 10);

/// /pesan/:threadId — ruang obrolan satu thread.
class RuangObrolanPage extends ConsumerStatefulWidget {
  const RuangObrolanPage({super.key, required this.threadId});

  final String threadId;

  @override
  ConsumerState<RuangObrolanPage> createState() => _RuangObrolanPageState();
}

class _RuangObrolanPageState extends ConsumerState<RuangObrolanPage> {
  final _scroll = ScrollController();
  final _input = TextEditingController();
  bool _adaBaru = false;
  bool _mengirim = false;

  /// Banner keamanan: tampil selama kunjungan ini bila thread belum punya
  /// pesan pengguna saat dibuka.
  bool? _banner;

  String get _id => widget.threadId;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_adaBaru && _scroll.offset < _ambangGulir) {
        setState(() => _adaBaru = false);
      }
    });
  }

  @override
  void didUpdateWidget(RuangObrolanPage old) {
    super.didUpdateWidget(old);
    if (old.threadId != widget.threadId) {
      _banner = null;
      _adaBaru = false;
      _input.clear();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.pesan);

  void _snack(String pesan) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(pesan)));

  void _keTerbaru() {
    if (!_scroll.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(0);
    } else {
      _scroll.animateTo(0,
          duration: AppDurations.short, curve: Curves.easeOutCubic);
    }
    setState(() => _adaBaru = false);
  }

  Future<void> _kirim(
    TipePesan tipe,
    String isi, {
    Map<String, dynamic> payload = const {},
  }) async {
    if (_mengirim) return;
    setState(() => _mengirim = true);
    try {
      await ref
          .read(chatRepositoryProvider)
          .send(_id, tipe, isi, payload: payload);
      hapticAksiPenting();
      if (tipe == TipePesan.teks && isi == _input.text) _input.clear();
      if (mounted) _keTerbaru();
    } on ChatException catch (e) {
      if (mounted) _snack(e.message);
    } finally {
      if (mounted) setState(() => _mengirim = false);
    }
  }

  Future<void> _usulCod(ChatThreadView v) async {
    final hariIni = dateOnly(ref.read(clockProvider)());
    final mulai = v.booking?.tanggalMulai;
    final usulan = await showUsulCodSheet(
      context,
      lokasiAwal: v.item.lokasiKampus,
      tanggalAwal: mulai != null && !mulai.isBefore(hariIni)
          ? mulai
          : addDays(hariIni, 1),
      hariIni: hariIni,
    );
    if (usulan == null || !mounted) return;
    await _kirim(TipePesan.lokasiCod, 'Usulan titik COD',
        payload: usulan.toPayload());
  }

  Future<void> _lampiran(ChatThreadView v) async {
    final pilihan = await showAppBottomSheet<String>(
      context,
      builder: (sheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSheetTitle('Kirim ke obrolan'),
          AppSheetAction(
            key: const Key('lampiran-cod'),
            icon: Icons.location_on_outlined,
            label: 'Usulkan titik COD',
            onTap: () => Navigator.pop(sheet, 'cod'),
          ),
          AppSheetAction(
            key: const Key('lampiran-foto'),
            icon: Icons.photo_outlined,
            label: 'Kirim foto',
            onTap: () => Navigator.pop(sheet, 'foto'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    switch (pilihan) {
      case 'cod':
        await _usulCod(v);
      case 'foto':
        await _kirim(TipePesan.foto, 'Foto');
    }
  }

  Future<void> _jawabCod(ChatThreadView v, ChatMessage m, bool setuju) async {
    try {
      await ref.read(chatRepositoryProvider).respondCod(m.id, setuju: setuju);
      if (setuju) {
        hapticAksiPenting();
      } else if (mounted) {
        await _usulCod(v);
      }
    } on ChatException catch (e) {
      if (mounted) _snack(e.message);
    }
  }

  Future<void> _menu(ChatThreadView v) async {
    final pilihan = await showAppBottomSheet<String>(
      context,
      builder: (sheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetAction(
            key: const Key('menu-profil'),
            icon: Icons.person_outline_rounded,
            label: 'Lihat profil',
            onTap: () => Navigator.pop(sheet, 'profil'),
          ),
          AppSheetAction(
            key: const Key('menu-bisu'),
            icon: v.dibisukan
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
            label: v.dibisukan ? 'Bunyikan notifikasi' : 'Bisukan notifikasi',
            onTap: () => Navigator.pop(sheet, 'bisu'),
          ),
          AppSheetAction(
            key: const Key('menu-lapor'),
            icon: Icons.flag_outlined,
            label: 'Laporkan pengguna',
            destructive: true,
            onTap: () => Navigator.pop(sheet, 'lapor'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    switch (pilihan) {
      case 'profil':
        final lapor = await showAppBottomSheet<bool>(
          context,
          builder: (sheet) => _ProfilSingkat(
            user: v.lawan,
            onLapor: () => Navigator.pop(sheet, true),
          ),
        );
        if (lapor == true && mounted) {
          context.push(AppRoutes.laporanBaru(terlaporId: v.lawan.id));
        }
      case 'bisu':
        await ref
            .read(chatRepositoryProvider)
            .setMuted(_id, v.viewerId, muted: !v.dibisukan);
        if (mounted) {
          _snack(v.dibisukan ? 'Notifikasi dibunyikan' : 'Notifikasi dibisukan');
        }
      case 'lapor':
        context.push(AppRoutes.laporanBaru(terlaporId: v.lawan.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewAsync = ref.watch(chatThreadProvider(_id));
    final pesanAsync = ref.watch(chatMessagesProvider(_id));
    final mengetik = ref.watch(chatTypingProvider(_id)).value ?? false;
    final today = dateOnly(ref.watch(clockProvider)());

    // Membuka thread = membaca semua pesan; pesan yang masuk selama ruang
    // terbuka juga langsung dibaca.
    ref.listen(chatThreadProvider(_id), (_, next) {
      final v = next.value;
      if (v != null && v.unread > 0) {
        ref.read(chatRepositoryProvider).markRead(_id, v.viewerId);
      }
    });
    ref.listen(chatMessagesProvider(_id), (prev, next) {
      final lama = prev?.value?.length ?? 0;
      final baru = next.value ?? const <ChatMessage>[];
      final me = ref.read(chatThreadProvider(_id)).value?.viewerId;
      if (lama == 0 || baru.length <= lama || me == null) return;
      final dariLawan = baru.last.senderId != me;
      if (dariLawan &&
          _scroll.hasClients &&
          _scroll.offset > _ambangGulir &&
          !_adaBaru) {
        setState(() => _adaBaru = true);
      }
    });

    final view = viewAsync.value;
    if (viewAsync.hasError && view == null) {
      return _pesanLayar(
        icon: Icons.wifi_off_rounded,
        title: AppTeks.koneksiPutus,
        actionLabel: AppTeks.cobaLagi,
        onAction: () => ref.invalidate(chatThreadProvider(_id)),
      );
    }
    if (!viewAsync.hasValue) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
    if (view == null) {
      return _pesanLayar(
        icon: Icons.forum_outlined,
        title: 'Obrolan ini tidak ditemukan.',
        actionLabel: 'Ke Pesan',
        onAction: () => context.go(AppRoutes.pesan),
      );
    }

    final pesan = pesanAsync.value;
    final pengguna = pesan?.where((m) => !m.sistem).toList();
    if (pengguna != null) _banner ??= pengguna.isEmpty;
    final tampilCepat = pengguna != null &&
        (pengguna.isEmpty || pengguna.last.senderId == view.lawan.id);
    final dinilai = view.booking?.status == StatusBooking.selesai
        ? ref.watch(myReviewedBookingIdsProvider).value ?? const <String>{}
        : const <String>{};

    final Widget daftar;
    if (pesanAsync.hasError && pesan == null) {
      daftar = Center(
        child: AppEmptyState(
          icon: Icons.wifi_off_rounded,
          title: AppTeks.koneksiPutus,
          actionLabel: AppTeks.cobaLagi,
          onAction: () => ref.invalidate(chatMessagesProvider(_id)),
        ),
      );
    } else if (pesan == null) {
      daftar = const Center(child: CircularProgressIndicator());
    } else {
      final entri = _susunEntri(pesan, today, banner: _banner ?? false);
      daftar = ListView.builder(
        key: const Key('daftar-pesan'),
        controller: _scroll,
        reverse: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHome, vertical: AppSpacing.md),
        itemCount: entri.length,
        itemBuilder: (context, i) {
          final e = entri[entri.length - 1 - i];
          return switch (e) {
            _Banner() => const ChatBannerKeamanan(),
            _Tanggal(:final label) => ChatTanggalPill(label),
            _Pesan(:final m) when m.sistem => ChatSistemPill(m),
            _Pesan(:final m, :final rapatAtas, :final rapatBawah) => Padding(
                padding: EdgeInsets.only(
                    top: rapatAtas ? AppSpacing.bubbleRapat : AppSpacing.sm),
                child: ChatGelembung(
                  message: m,
                  milikku: m.senderId == view.viewerId,
                  kategori: view.item.kategori,
                  rapatAtas: rapatAtas,
                  rapatBawah: rapatBawah,
                  onSetujuCod: () => _jawabCod(view, m, true),
                  onUsulLainCod: () => _jawabCod(view, m, false),
                  bawah: m.senderId != view.viewerId &&
                          m.tipe == TipePesan.teks &&
                          perluCekPenipuan(m.isi)
                      ? _PeringatanPenipuan(teks: m.isi)
                      : null,
                ),
              ),
          };
        },
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              view: view,
              mengetik: mengetik,
              onBack: _back,
              onMenu: () => _menu(view),
            ),
            ChatKartuTransaksi(view: view, dinilai: dinilai),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: daftar),
                  if (_adaBaru)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: AppSpacing.md,
                      child: Center(
                        child: ActionChip(
                          key: const Key('pesan-baru'),
                          avatar: const Icon(Icons.arrow_downward_rounded,
                              size: AppSizes.iconXs),
                          label: const Text('Pesan baru'),
                          onPressed: _keTerbaru,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (tampilCepat)
              _BalasanCepat(
                pilihan: view.sayaPemilik
                    ? [
                        'Bisa ambil sore ini',
                        'Aku tunggu di ${view.item.lokasiKampus}',
                        'Jangan lupa bawa KTM ya',
                      ]
                    : const [
                        'Masih tersedia?',
                        'Bisa ambil jam berapa?',
                        'Titik COD-nya di mana?',
                      ],
                onPilih: (t) => _kirim(TipePesan.teks, t),
              ),
            _Composer(
              controller: _input,
              mengirim: _mengirim,
              onLampiran: () => _lampiran(view),
              onKirim: () => _kirim(TipePesan.teks, _input.text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pesanLayar({
    required IconData icon,
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
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
              actionLabel: actionLabel,
              onAction: onAction,
            ),
          ],
        ),
      ),
    );
  }
}

/// Peringatan AI di bawah pesan masuk yang mirip modus penipuan.
class _PeringatanPenipuan extends ConsumerWidget {
  const _PeringatanPenipuan({required this.teks});

  final String teks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alasan = ref.watch(peringatanPenipuanProvider(teks)).value;
    if (alasan == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final warna = theme.colorScheme.error;
    return Padding(
      key: const Key('peringatan-penipuan'),
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Semantics(
        liveRegion: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.gpp_maybe_rounded, size: AppSizes.iconXs, color: warna),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                'Hati-hati: $alasan Bayar hanya lewat HobbySwap atau tunai '
                'saat COD.',
                style: theme.textTheme.bodySmall?.copyWith(color: warna),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

sealed class _Entri {
  const _Entri();
}

class _Banner extends _Entri {
  const _Banner();
}

class _Tanggal extends _Entri {
  const _Tanggal(this.label);

  final String label;
}

class _Pesan extends _Entri {
  const _Pesan(this.m, {this.rapatAtas = false, this.rapatBawah = false});

  final ChatMessage m;
  final bool rapatAtas;
  final bool rapatBawah;
}

/// Urutan lama → baru: banner, pemisah tanggal, lalu pesan (dirapatkan bila
/// bersambung dari pengirim yang sama).
List<_Entri> _susunEntri(List<ChatMessage> pesan, DateTime today,
    {required bool banner}) {
  bool sambung(ChatMessage a, ChatMessage b) =>
      !a.sistem &&
      !b.sistem &&
      a.senderId == b.senderId &&
      isSameDay(a.sentAt, b.sentAt) &&
      b.sentAt.difference(a.sentAt).abs() <= _jedaRapat;

  final hasil = <_Entri>[if (banner) const _Banner()];
  for (var i = 0; i < pesan.length; i++) {
    final m = pesan[i];
    final prev = i > 0 ? pesan[i - 1] : null;
    final next = i + 1 < pesan.length ? pesan[i + 1] : null;
    if (prev == null || !isSameDay(prev.sentAt, m.sentAt)) {
      hasil.add(_Tanggal(labelHari(m.sentAt, today)));
    }
    hasil.add(_Pesan(
      m,
      rapatAtas: prev != null && sambung(prev, m),
      rapatBawah: next != null && sambung(m, next),
    ));
  }
  return hasil;
}

class _Header extends StatelessWidget {
  const _Header({
    required this.view,
    required this.mengetik,
    required this.onBack,
    required this.onMenu,
  });

  final ChatThreadView view;
  final bool mengetik;
  final VoidCallback onBack;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final lawan = view.lawan;
    final verified = lawan.statusVerifikasi == StatusVerifikasi.terverifikasi;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.xs, AppSpacing.sm),
      child: Row(
        children: [
          AppBackButton(onPressed: onBack),
          const SizedBox(width: AppSpacing.sm),
          AppAvatar(
              user: lawan, size: AppSizes.avatarChatHeader, showBadge: false),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Semantics(
                        header: true,
                        child: Text(
                          lawan.nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium
                              ?.merge(AppTextStyles.chatName),
                        ),
                      ),
                    ),
                    if (verified) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Semantics(
                        label: 'Terverifikasi',
                        child: Icon(Icons.verified_rounded,
                            size: AppSizes.iconXs, color: colors.verified),
                      ),
                    ],
                  ],
                ),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    mengetik ? 'sedang mengetik…' : 'Biasanya balas < 1 jam',
                    key: const Key('status-lawan'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: mengetik
                          ? colors.accentText
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('chat-menu'),
            tooltip: 'Menu lainnya',
            onPressed: onMenu,
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }
}

class _BalasanCepat extends StatelessWidget {
  const _BalasanCepat({required this.pilihan, required this.onPilih});

  final List<String> pilihan;
  final ValueChanged<String> onPilih;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('balasan-cepat'),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHome),
      child: Row(
        children: [
          for (final (i, t) in pilihan.indexed) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            AppChip(
              key: Key('cepat-$i'),
              label: t,
              selected: false,
              onTap: () => onPilih(t),
            ),
          ],
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.mengirim,
    required this.onLampiran,
    required this.onKirim,
  });

  final TextEditingController controller;
  final bool mengirim;
  final VoidCallback onLampiran;
  final VoidCallback onKirim;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              key: const Key('chat-lampiran'),
              tooltip: 'Lampirkan (usulan COD atau foto)',
              onPressed: onLampiran,
              style: IconButton.styleFrom(
                fixedSize: const Size.square(AppSizes.chatSend),
                minimumSize: const Size.square(AppSizes.chatSend),
                tapTargetSize: MaterialTapTargetSize.padded,
                backgroundColor: colors.surfaceAlt,
                foregroundColor: scheme.onSurface,
              ),
              icon: const Icon(Icons.add_rounded),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs / 2),
                child: TextField(
                  key: const Key('chat-input'),
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Tulis pesan…',
                    fillColor: theme.scaffoldBackgroundColor,
                    border: const OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(AppRadius.composer)),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(AppRadius.composer)),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                          Radius.circular(AppRadius.composer)),
                      borderSide: BorderSide(color: scheme.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final aktif = value.text.trim().isNotEmpty && !mengirim;
                return IconButton(
                  key: const Key('chat-kirim'),
                  tooltip: 'Kirim',
                  onPressed: aktif ? onKirim : null,
                  style: IconButton.styleFrom(
                    fixedSize: const Size.square(AppSizes.chatSend),
                    minimumSize: const Size.square(AppSizes.chatSend),
                    tapTargetSize: MaterialTapTargetSize.padded,
                    shape: const CircleBorder(),
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    disabledBackgroundColor:
                        scheme.primary.withValues(alpha: 0.4),
                    disabledForegroundColor:
                        scheme.onPrimary.withValues(alpha: 0.7),
                  ),
                  icon: const Icon(Icons.send_rounded, size: AppSizes.iconSm),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Profil singkat lawan bicara (dari menu titik tiga).
class _ProfilSingkat extends StatelessWidget {
  const _ProfilSingkat({required this.user, required this.onLapor});

  final User user;
  final VoidCallback onLapor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final verified = user.statusVerifikasi == StatusVerifikasi.terverifikasi;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppAvatar(user: user, size: AppSizes.avatarProfile),
        const SizedBox(height: AppSpacing.md),
        Text(user.nama,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge
                ?.merge(AppTextStyles.profileName)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${user.prodi ?? user.fakultas ?? 'Mahasiswa'} · '
          'Universitas Sumatera Utara',
          textAlign: TextAlign.center,
          style: muted,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            if (verified) const AppVerifiedChip(),
            Text(
              user.jumlahUlasan > 0
                  ? '★ ${formatRating(user.rating)} · ${user.jumlahUlasan} ulasan'
                  : 'Belum ada ulasan',
              style: muted,
            ),
          ],
        ),
        if (user.bio case final bio? when bio.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(bio, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
        ],
        if (user.jumlahBatalMendadak > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          BatalMendadakLabel(user.jumlahBatalMendadak),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppSheetAction(
          key: const Key('profil-lapor'),
          icon: Icons.flag_outlined,
          label: 'Laporkan pengguna',
          destructive: true,
          onTap: onLapor,
        ),
      ],
    );
  }
}
