import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_menu.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/support_providers.dart';
import '../domain/support_repository.dart';
import '../../../core/constants/app_strings.dart';

const _faq = [
  (
    'Kenapa harus verifikasi KTM?',
    'Supaya semua yang sewa-menyewa di HobbySwap benar-benar mahasiswa USU. '
        'Pemilik jadi tahu barangnya disewa siapa, dan penyewa tahu barangnya '
        'dari siapa.',
  ),
  (
    'Bagaimana kalau barang rusak saat disewa?',
    'Karena itu ada checklist serah terima. Kondisi awal dan akhir dicatat '
        'bersama lengkap dengan foto, jadi kerusakan baru bisa dibicarakan '
        'dengan adil. Laporkan lewat form di bawah kalau butuh bantuan.',
  ),
  (
    'Bagaimana cara membatalkan pengajuan?',
    'Buka Sewaan Saya, pilih segmen Menunggu, lalu tekan "Batalkan pengajuan". '
        'Pengajuan yang sudah disetujui pemilik tidak bisa dibatalkan dari '
        'aplikasi; hubungi pemiliknya.',
  ),
  (
    'Bagaimana cara pembayarannya?',
    'Tidak ada pembayaran di aplikasi. Bayar tunai atau transfer langsung ke '
        'pemilik saat COD serah terima di kampus. Pemilik mencatatnya di '
        'checklist ambil barang, lalu statusnya jadi "Lunas".',
  ),
  (
    'Kalau telat mengembalikan, kena denda?',
    'Kalau pemilik memasang denda, besarnya tertulis di halaman barang. '
        'Denda = hari terlambat × denda per hari, dibayar ke pemilik saat '
        'pengembalian.',
  ),
  (
    'Bisakah membatalkan sewa yang sudah disetujui?',
    'Bisa, dari Sewaan Saya (penyewa) atau Barang Saya (pemilik), dengan '
        'alasan. Sampai H-1 bebas; di hari H tetap boleh tapi tercatat '
        'sebagai pembatalan mendadak di profilmu.',
  ),
  (
    'Apakah data KTM-ku aman?',
    'Foto KTM dan selfie hanya dilihat tim peninjau untuk verifikasi, tidak '
        'ditampilkan ke pengguna lain.',
  ),
];

class BantuanPage extends ConsumerStatefulWidget {
  const BantuanPage({super.key});

  @override
  ConsumerState<BantuanPage> createState() => _BantuanPageState();
}

class _BantuanPageState extends ConsumerState<BantuanPage> {
  final _formKey = GlobalKey<FormState>();
  final _deskripsi = TextEditingController();
  KategoriLaporan? _kategori;
  bool _busy = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _deskripsi.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    setState(() {
      _submitted = true;
      _error = null;
    });
    final valid = _formKey.currentState!.validate();
    if (!valid || _kategori == null) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(supportRepositoryProvider)
          .kirimLaporan(_kategori!, _deskripsi.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Laporanmu terkirim. Tim HobbySwap akan menghubungi '
              'lewat email kampus.',
            ),
          ),
        );
      setState(() {
        _busy = false;
        _submitted = false;
        _kategori = null;
        _deskripsi.clear();
      });
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
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHome,
              AppSpacing.md,
              AppSpacing.pageHome,
              AppSpacing.xxl,
            ),
            children: [
              Row(
                children: [
                  AppBackButton(
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRoutes.profil),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Bantuan',
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                  ),
                ],
              ),
              const AppMenuLabel('Pertanyaan umum'),
              AppCard(
                padding: EdgeInsets.zero,
                // Material sendiri supaya latar kartu tidak menutupi efek ink ListTile.
                child: Material(
                  type: MaterialType.transparency,
                  child: Theme(
                    data: theme.copyWith(dividerColor: AppPalette.transparent),
                    child: Column(
                      children: [
                        for (final (i, (q, a)) in _faq.indexed) ...[
                          if (i > 0) const Divider(),
                          ExpansionTile(
                            key: Key('faq-$i'),
                            title: Text(q, style: theme.textTheme.titleMedium),
                            iconColor: colors.accentText,
                            collapsedIconColor:
                                theme.colorScheme.onSurfaceVariant,
                            childrenPadding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              0,
                              AppSpacing.lg,
                              AppSpacing.lg,
                            ),
                            expandedAlignment: Alignment.centerLeft,
                            children: [
                              Text(
                                a,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const AppMenuLabel('Laporkan masalah'),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final k in KategoriLaporan.values)
                    AppChip(
                      key: Key('laporan-${k.name}'),
                      label: k.label,
                      selected: _kategori == k,
                      onTap: () => setState(() => _kategori = k),
                    ),
                ],
              ),
              if (_submitted && _kategori == null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    'Pilih kategori masalahnya dulu',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                key: const Key('laporan-deskripsi'),
                label: 'Ceritakan masalahnya',
                hint: 'Apa yang terjadi, kapan, dan di layar mana.',
                controller: _deskripsi,
                enabled: !_busy,
                validator: LaporanValidators.deskripsi,
                maxLength: LaporanValidators.maks,
                minLines: 4,
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSpacing.md),
              AppErrorSlot(message: _error),
              AppButton(
                key: const Key('laporan-kirim'),
                label: 'Kirim laporan',
                isLoading: _busy,
                onPressed: _kirim,
              ),
              const AppMenuLabel('Dokumen'),
              AppMenuCard(children: [
                AppMenuRow(
                  key: const Key('bantuan-syarat'),
                  icon: Icons.description_outlined,
                  label: 'Syarat Layanan',
                  onTap: () => context.push(AppRoutes.syarat),
                ),
                AppMenuRow(
                  key: const Key('bantuan-privasi'),
                  icon: Icons.privacy_tip_outlined,
                  label: 'Kebijakan Privasi',
                  onTap: () => context.push(AppRoutes.privasi),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
