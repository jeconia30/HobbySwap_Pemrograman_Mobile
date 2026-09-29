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
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_menu.dart';
import '../../../core/widgets/app_press_scale.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/notification_providers.dart';
import '../domain/notification_item.dart';
import '../../../core/constants/app_strings.dart';

class AktivitasPage extends ConsumerStatefulWidget {
  const AktivitasPage({super.key});

  @override
  ConsumerState<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends ConsumerState<AktivitasPage> {
  /// Sudah digeser; disembunyikan segera supaya Dismissible tidak tertinggal.
  final _dihapus = <String>{};

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.beranda);

  Future<void> _buka(NotificationItem n) async {
    await ref.read(notificationRepositoryProvider).markRead(n.id);
    ref.invalidate(notificationsProvider);
    final tautan = n.tautan;
    if (tautan == null || !mounted) return;
    AppRoutes.isTab(tautan) ? context.go(tautan) : context.push(tautan);
  }

  Future<void> _hapus(NotificationItem n) async {
    setState(() => _dihapus.add(n.id));
    final repo = ref.read(notificationRepositoryProvider);
    await repo.delete(n.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Dihapus'),
          action: SnackBarAction(
            label: 'Urungkan',
            onPressed: () async {
              await repo.restore(n);
              if (!mounted) return;
              setState(() => _dihapus.remove(n.id));
              ref.invalidate(notificationsProvider);
            },
          ),
        ),
      );
  }

  Future<void> _tandaiSemua() async {
    final userId = ref.read(authControllerProvider)?.id;
    if (userId == null) return;
    await ref.read(notificationRepositoryProvider).markAllRead(userId);
    ref.invalidate(notificationsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final async = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadCountProvider).value ?? 0;
    final today = dateOnly(ref.watch(clockProvider)());
    final items = [
      for (final n in async.value ?? const <NotificationItem>[])
        if (!_dihapus.contains(n.id)) n,
    ];

    String grup(NotificationItem n) {
      final selisih = daysBetween(n.tanggal, today);
      if (selisih <= 0) return 'Hari ini';
      if (selisih == 1) return 'Kemarin';
      if (selisih < 7) return 'Minggu ini';
      return 'Lebih lama';
    }

    final grouped = <String, List<NotificationItem>>{};
    for (final n in items) {
      grouped.putIfAbsent(grup(n), () => []).add(n);
    }

    final Widget? body;
    if (async.hasError) {
      body = AppEmptyState(
        icon: Icons.wifi_off_rounded,
        title: AppTeks.koneksiPutus,
        actionLabel: AppTeks.cobaLagi,
        onAction: () => ref.invalidate(notificationsProvider),
      );
    } else if (!async.hasValue) {
      body = Skeletonizer(
        child: Column(
          children: [
            for (var i = 0; i < 4; i++)
              _NotifRow(
                item: NotificationItem(
                  id: '$i',
                  userId: '',
                  tipe: TipeNotifikasi.pengajuanBaru,
                  judul: 'Memuat aktivitas terbaru',
                  isi: 'Kabar soal sewa dan barangmu',
                  tanggal: today,
                ),
                today: today,
                onTap: () {},
              ),
          ],
        ),
      );
    } else if (items.isEmpty) {
      body = const Padding(
        padding: EdgeInsets.only(top: AppSpacing.xxl),
        child: AppEmptyState(
          icon: Icons.notifications_none_rounded,
          title: 'Belum ada aktivitas.',
          message: 'Kabar soal sewa dan barangmu akan muncul di sini.',
        ),
      );
    } else {
      body = null;
    }

    // Baris datar: judul grup (String) atau notifikasi, dibangun malas.
    final baris = <Object>[
      for (final g in const ['Hari ini', 'Kemarin', 'Minggu ini', 'Lebih lama'])
        if (grouped[g] case final list?) ...[g, ...list],
    ];
    Widget barisKe(Object e) {
      if (e is String) return AppMenuLabel(e);
      final n = e as NotificationItem;
      return Dismissible(
        key: ValueKey('notif-${n.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _hapus(n),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          color: theme.colorScheme.error.withValues(alpha: 0.15),
          child: Icon(
            Icons.delete_outline_rounded,
            color: theme.colorScheme.error,
          ),
        ),
        child: _NotifRow(item: n, today: today, onTap: () => _buka(n)),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref
              .refresh(notificationsProvider.future)
              .then<void>((_) {}, onError: (Object _) {}),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHome,
              AppSpacing.md,
              AppSpacing.pageHome,
              AppSpacing.xxl,
            ),
            itemCount: 1 + (body == null ? baris.length : 1),
            itemBuilder: (context, i) => switch (i) {
              0 => Row(
                children: [
                  AppBackButton(onPressed: _back),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Aktivitas',
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  if (unread > 0)
                    Flexible(
                      child: TextButton(
                        key: const Key('tandai-semua'),
                        onPressed: _tandaiSemua,
                        child: const Text(
                          'Tandai semua dibaca',
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                ],
              ),
              _ => body ?? barisKe(baris[i - 1]),
            },
          ),
        ),
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  const _NotifRow({
    required this.item,
    required this.today,
    required this.onTap,
  });

  final NotificationItem item;
  final DateTime today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);

    final (IconData icon, Color bg, Color fg) = switch (item.tipe) {
      TipeNotifikasi.barterDiminta => (
        Icons.swap_horiz_rounded,
        colors.accentSoft,
        colors.accentText,
      ),
      TipeNotifikasi.pengajuanBaru => (
        Icons.inbox_outlined,
        colors.accentSoft,
        colors.accentText,
      ),
      TipeNotifikasi.giliranChecklist => (
        Icons.fact_check_outlined,
        colors.accentSoft,
        colors.accentText,
      ),
      TipeNotifikasi.pengingatAmbil || TipeNotifikasi.pengingatKembali => (
        Icons.alarm_rounded,
        colors.warning.withValues(alpha: 0.18),
        colors.warning,
      ),
      TipeNotifikasi.pengajuanDitolak || TipeNotifikasi.sewaDibatalkan => (
        Icons.cancel_outlined,
        scheme.error.withValues(alpha: 0.15),
        scheme.error,
      ),
      TipeNotifikasi.terlambat => (
        Icons.warning_amber_rounded,
        scheme.error.withValues(alpha: 0.15),
        scheme.error,
      ),
      TipeNotifikasi.laporanBaru || TipeNotifikasi.laporanDitanggapi => (
        Icons.flag_outlined,
        colors.warning.withValues(alpha: 0.18),
        colors.warning,
      ),
      TipeNotifikasi.pengajuanDisetujui => (
        Icons.check_circle_outline_rounded,
        colors.verified.withValues(alpha: 0.16),
        colors.verified,
      ),
      TipeNotifikasi.ulasanBaru => (
        Icons.star_outline_rounded,
        colors.verified.withValues(alpha: 0.16),
        colors.verified,
      ),
      TipeNotifikasi.verifikasiDisetujui => (
        Icons.verified_outlined,
        colors.verified.withValues(alpha: 0.16),
        colors.verified,
      ),
    };

    final waktu = formatWaktuRelatif(item.tanggal, today);
    final unread = !item.sudahDibaca;

    final row = Semantics(
      button: true,
      label:
          '${unread ? 'Belum dibaca. ' : ''}${item.judul}. ${item.isi}. $waktu',
      excludeSemantics: true,
      child: InkWell(
        key: Key('notif-row-${item.id}'),
        onTap: onTap,
        borderRadius: AppRadius.inputAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSizes.notifIcon,
                height: AppSizes.notifIcon,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: AppRadius.previewAll,
                ),
                child: Icon(icon, color: fg, size: AppSizes.iconSm),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.judul,
                            style: theme.textTheme.bodyMedium
                                ?.merge(AppTextStyles.notifTitle)
                                .copyWith(
                                  fontWeight: unread
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Container(
                              key: Key('unread-${item.id}'),
                              width: AppSizes.unreadDot,
                              height: AppSizes.unreadDot,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: AppSpacing.sm),
                        // Flexible: di font besar waktu turun baris, bukan overflow.
                        Flexible(
                          flex: 2,
                          child: Text(
                            waktu,
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs / 2),
                    Text(
                      item.isi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.merge(AppTextStyles.notifBody)
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return AppPressScale(child: row);
  }
}
