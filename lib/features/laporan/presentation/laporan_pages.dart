import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_info_note.dart';
import '../../../core/widgets/app_press_scale.dart';
import '../../../core/widgets/app_timeline.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/laporan_providers.dart';
import '../domain/laporan.dart';
import '../domain/laporan_repository.dart';

/// Pill status laporan (label teks + warna).
class LaporanStatusBadge extends StatelessWidget {
  const LaporanStatusBadge(this.status, {super.key, this.compact = false});

  final StatusLaporan status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AppStatusPill(
      label: status.label,
      color: switch (status) {
        StatusLaporan.menungguTanggapan => colors.warning,
        StatusLaporan.diterima => colors.accentText,
        StatusLaporan.dibanding => Theme.of(context).colorScheme.error,
        StatusLaporan.selesai => colors.verified,
      },
      selesai: status == StatusLaporan.selesai,
      compact: compact,
    );
  }
}

String _judulLaporan(LaporanView v) =>
    v.item == null ? 'Laporan pengguna' : 'Laporan ${v.laporan.jenis.label.toLowerCase()}';

String _usulanTeks(Laporan l) => switch (l.usulan) {
      UsulanPenyelesaian.gantiRugi =>
        'Ganti rugi ${formatRupiah(l.nominal ?? 0)}',
      final u? => u.label,
      null => 'Ditinjau tim HobbySwap',
    };

/// /laporan — laporan yang kubuat dan laporan terkait sewa tentang aku.
class LaporankuPage extends ConsumerWidget {
  const LaporankuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(laporankuProvider);
    final list = async.value ?? const <LaporanView>[];

    final Widget? body = switch (async) {
      AsyncError() when !async.hasValue => AppEmptyState(
          icon: Icons.wifi_off_rounded,
          title: AppTeks.koneksiPutus,
          actionLabel: AppTeks.cobaLagi,
          onAction: () => ref.invalidate(laporankuProvider),
        ),
      _ when !async.hasValue => const Skeletonizer(
          child: Column(children: [
            ListTile(title: Text('Memuat laporan'), subtitle: Text('Sebentar')),
            ListTile(title: Text('Memuat laporan'), subtitle: Text('Sebentar')),
          ]),
        ),
      _ when list.isEmpty => const Padding(
          padding: EdgeInsets.only(top: AppSpacing.xxl),
          child: AppEmptyState(
            icon: Icons.flag_outlined,
            title: 'Belum ada laporan.',
            message: 'Laporan kerusakan atau pengguna yang kamu buat akan '
                'muncul di sini.',
          ),
        ),
      _ => null,
    };

    final kepala = [
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
              child: Text('Laporanku', style: theme.textTheme.headlineMedium),
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome,
              AppSpacing.md, AppSpacing.pageHome, AppSpacing.xxl),
          itemCount: kepala.length + (body == null ? list.length : 1),
          itemBuilder: (context, i) {
            if (i < kepala.length) return kepala[i];
            if (body != null) return body;
            final v = list[i - kepala.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _LaporanRow(view: v),
            );
          },
        ),
      ),
    );
  }
}

class _LaporanRow extends StatelessWidget {
  const _LaporanRow({required this.view});

  final LaporanView view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = view.laporan;
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final siapa = view.sayaPelapor
        ? 'Kamu melaporkan ${view.terlapor.nama}'
        : 'Dilaporkan ${view.pelapor.nama}';

    return AppPressScale(
      child: AppCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          key: Key('laporan-row-${l.id}'),
          borderRadius: AppRadius.cardAll,
          onTap: () => context.push(AppRoutes.laporanDetail(l.id)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        view.item?.judul ?? _judulLaporan(view),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: LaporanStatusBadge(l.status, compact: true),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('${l.jenis.label} · $siapa', style: muted),
                Text(formatTanggalPendek(l.dibuatPada), style: muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// /laporan/:id — ringkasan, timeline, dan tanggapan pihak terlapor.
class LaporanDetailPage extends ConsumerStatefulWidget {
  const LaporanDetailPage({super.key, required this.laporanId});

  final String laporanId;

  @override
  ConsumerState<LaporanDetailPage> createState() => _LaporanDetailPageState();
}

class _LaporanDetailPageState extends ConsumerState<LaporanDetailPage> {
  bool _busy = false;

  void _back() => context.canPop()
      ? context.pop()
      : context.go(AppRoutes.laporanku);

  Future<void> _aksi(Future<Laporan> Function(LaporanRepository r) f,
      String pesan) async {
    setState(() => _busy = true);
    try {
      await f(ref.read(laporanRepositoryProvider));
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(pesan)));
      }
    } on LaporanException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(laporanProvider(widget.laporanId));
    final v = async.value;
    if (v == null) {
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
              if (async.hasError)
                AppEmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: AppTeks.koneksiPutus,
                  actionLabel: AppTeks.cobaLagi,
                  onAction: () =>
                      ref.invalidate(laporanProvider(widget.laporanId)),
                )
              else if (async.hasValue)
                const AppEmptyState(
                  icon: Icons.report_off_outlined,
                  title: 'Laporan ini tidak ditemukan.',
                )
              else
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final l = v.laporan;
    final muted = text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);
    final today = dateOnly(ref.watch(clockProvider)());
    final selesai = l.status == StatusLaporan.selesai;
    final menunggu = switch (l.status) {
      StatusLaporan.menungguTanggapan => l.usulan == null
          ? 'Ditinjau tim HobbySwap'
          : 'Menunggu tanggapan ${v.terlapor.nama}',
      StatusLaporan.diterima => 'Menunggu ${v.pelapor.nama} menandai selesai',
      StatusLaporan.dibanding => 'Ditinjau tim HobbySwap',
      StatusLaporan.selesai => null,
    };

    Widget? aksi;
    if (v.bisaDitanggapi) {
      aksi = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            key: const Key('laporan-terima'),
            label: 'Terima usulan',
            isLoading: _busy,
            onPressed: () => _aksi((r) => r.terimaUsulan(l.id),
                'Usulan diterima. Selesaikan bersama pemilik, ya.'),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            key: const Key('laporan-banding'),
            label: 'Ajukan banding',
            variant: AppButtonVariant.secondary,
            onPressed: _busy
                ? null
                : () => _aksi((r) => r.ajukanBanding(l.id),
                    'Diteruskan ke tim HobbySwap untuk ditinjau.'),
          ),
        ],
      );
    } else if (v.sayaPelapor && l.status == StatusLaporan.diterima) {
      aksi = AppButton(
        key: const Key('laporan-selesai'),
        label: 'Tandai selesai',
        isLoading: _busy,
        onPressed: () =>
            _aksi((r) => r.tandaiSelesai(l.id), 'Laporan ditandai selesai.'),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome,
                    AppSpacing.md, AppSpacing.pageHome, AppSpacing.xl),
                children: [
                  Row(
                    children: [
                      AppBackButton(onPressed: _back),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(_judulLaporan(v),
                              style: text.headlineMedium),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                v.item?.judul ?? v.terlapor.nama,
                                style: text.titleMedium,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Flexible(child: LaporanStatusBadge(l.status)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${v.pelapor.nama} → ${v.terlapor.nama} · '
                          '${formatTanggalPendek(l.dibuatPada)}',
                          style: muted,
                        ),
                        if (l.usulan != null || l.jenis.terkaitSewa) ...[
                          const Divider(height: AppSpacing.xl),
                          Text('Usulan penyelesaian', style: muted),
                          Text(
                            _usulanTeks(l),
                            key: const Key('laporan-usulan'),
                            style: text.titleMedium
                                ?.copyWith(color: colors.accentText),
                          ),
                        ],
                        if (l.itemChecklistBermasalah.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text('Item bermasalah', style: muted),
                          for (final i in l.itemChecklistBermasalah)
                            Text('• $i', style: text.bodyMedium),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Text('Cerita pelapor', style: muted),
                        Text(l.deskripsi, style: text.bodyMedium),
                      ],
                    ),
                  ),
                  if (l.status == StatusLaporan.dibanding) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const AppInfoNote(
                      icon: Icons.gavel_rounded,
                      message: 'Diteruskan ke tim HobbySwap untuk ditinjau.',
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Text('Riwayat', style: text.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  AppTimeline(
                    steps: [
                      for (final r in l.riwayat)
                        AppTimelineStep(
                          '${r.judul} · ${formatWaktuRelatif(r.waktu, today)}',
                          AppTimelineState.done,
                        ),
                      if (!selesai && menunggu != null)
                        AppTimelineStep(menunggu, AppTimelineState.current),
                    ],
                  ),
                ],
              ),
            ),
            if (aksi != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome,
                    AppSpacing.sm, AppSpacing.pageHome, AppSpacing.lg),
                child: aksi,
              ),
          ],
        ),
      ),
    );
  }
}
