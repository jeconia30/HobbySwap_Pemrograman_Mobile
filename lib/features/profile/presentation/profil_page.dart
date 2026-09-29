import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/storage/session_storage.dart';
import '../../../core/storage/settings_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_menu.dart';
import '../../../core/widgets/batal_mendadak_label.dart';
import '../../../data/fake/fake_account_store.dart';
import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_chat_store.dart';
import '../../../data/fake/fake_favorite_store.dart';
import '../../../data/fake/fake_handover_review_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../../../data/fake/fake_laporan_store.dart';
import '../../../data/fake/fake_notification_store.dart';
import '../../../data/fake/fake_persistence.dart';
import '../../activity/data/notification_providers.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../booking/data/booking_providers.dart';
import '../../chat/data/chat_providers.dart';
import '../../booking/domain/booking.dart';
import '../../booking/presentation/sewa_refresh.dart';
import '../../item/data/fake_item_repository.dart';
import '../../item/data/item_providers.dart';
import '../../verification/presentation/verification_actions.dart';
import 'theme_sheet.dart';
import '../../../core/constants/app_strings.dart';

class ProfilPage extends ConsumerWidget {
  const ProfilPage({super.key});

  void _snack(BuildContext context, String msg) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final keluar = await showAppBottomSheet<bool>(
      context,
      builder: (sheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSheetTitle('Keluar dari HobbySwap?'),
          Text(
            'Kamu perlu masuk lagi pakai email kampus atau NIM.',
            style: Theme.of(sheet).textTheme.bodyMedium?.copyWith(
                color: Theme.of(sheet).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            key: const Key('keluar-konfirmasi'),
            label: 'Keluar',
            variant: AppButtonVariant.danger,
            onPressed: () => Navigator.pop(sheet, true),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => Navigator.pop(sheet, false),
            child: const Text(AppTeks.batal),
          ),
        ],
      ),
    );
    if (keluar != true) return;
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) context.go(AppRoutes.login);
  }

  Future<void> _resetDataContoh(BuildContext context, WidgetRef ref) async {
    await ref.read(fakePersistenceProvider).clear();
    ref
      ..invalidate(fakeAccountStoreProvider)
      ..invalidate(fakeItemStoreProvider)
      ..invalidate(fakeBookingStoreProvider)
      ..invalidate(fakeChecklistStoreProvider)
      ..invalidate(fakeReviewStoreProvider)
      ..invalidate(fakeNotificationStoreProvider)
      ..invalidate(fakeChatStoreProvider)
      ..invalidate(fakeLaporanStoreProvider)
      ..invalidate(fakeFavoriteStoreProvider);
    await ref.read(authControllerProvider.notifier).restoreSession();
    ref
      ..refreshSewa()
      ..invalidate(notificationsProvider);
    if (context.mounted) _snack(context, 'Data contoh dikembalikan ke awal.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final sewaAsync = ref.watch(myBookingsProvider);
    final disewakanAsync = ref.watch(ownerBookingsProvider);
    final sewa = sewaAsync.value ?? const <BookingDetail>[];
    final disewakan = disewakanAsync.value ?? const <BookingDetail>[];
    final statsMuat = !sewaAsync.hasValue || !disewakanAsync.hasValue;
    final statsGagal = statsMuat && (sewaAsync.hasError || disewakanAsync.hasError);
    final colors = AppColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (user == null) return const Scaffold();

    bool selesai(BookingDetail d) => d.booking.status == StatusBooking.selesai;
    final jumlahMenyewa = sewa
        .where((d) => selesai(d) && !d.booking.barter && d.penyewa.id == user.id)
        .length;
    final jumlahMenyewakan =
        disewakan.where((d) => selesai(d) && !d.booking.barter).length;
    final jumlahBarter = {
      for (final d in [...sewa, ...disewakan])
        if (selesai(d) && d.booking.barter) d.booking.id,
    }.length;

    final (String statusLabel, Color statusColor, String statusRoute) =
        switch (user.statusVerifikasi) {
      StatusVerifikasi.terverifikasi => (
          AppTeks.akunAktif,
          colors.verified,
          AppRoutes.verifikasiStatus
        ),
      StatusVerifikasi.menunggu => (
          AppTeks.akunDitinjau,
          colors.warning,
          AppRoutes.verifikasiStatus
        ),
      StatusVerifikasi.belum => (AppTeks.akunBelum, scheme.error, AppRoutes.verifikasi),
    };

    final itemRepo = ref.watch(itemRepositoryProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(AppSpacing.pageHome, AppSpacing.lg,
              AppSpacing.pageHome,
              MediaQuery.paddingOf(context).bottom + AppSpacing.xl),
          children: [
            _Header(user: user),
            const SizedBox(height: AppSpacing.xl),
            Skeletonizer(
              enabled: statsMuat && !statsGagal,
              child: _StatsCard(
                menyewa: jumlahMenyewa,
                menyewakan: jumlahMenyewakan,
                barter: jumlahBarter,
                user: user,
              ),
            ),
            if (statsGagal) ...[
              const SizedBox(height: AppSpacing.sm),
              AppErrorBanner(
                message: 'Riwayat sewamu belum termuat.',
                onRetry: () => ref
                  ..invalidate(myBookingsProvider)
                  ..invalidate(ownerBookingsProvider),
              ),
            ],
            const AppMenuLabel('Akun'),
            AppMenuCard(children: [
              AppMenuRow(
                key: const Key('menu-edit-profil'),
                icon: Icons.edit_outlined,
                label: 'Edit profil',
                onTap: () => context.push(AppRoutes.profilUbah),
              ),
              AppMenuRow(
                icon: Icons.rate_review_outlined,
                label: 'Ulasan tentangku',
                onTap: () => context.push(AppRoutes.profilUlasan),
              ),
              AppMenuRow(
                key: const Key('menu-favorit'),
                icon: Icons.favorite_border_rounded,
                label: 'Favoritku',
                onTap: () => context.push(AppRoutes.favoritku),
              ),
              AppMenuRow(
                key: const Key('menu-laporan'),
                icon: Icons.flag_outlined,
                label: 'Laporanku',
                onTap: () => context.push(AppRoutes.laporanku),
              ),
              AppMenuRow(
                icon: Icons.receipt_long_outlined,
                label: 'Riwayat transaksi',
                onTap: () => context.go(AppRoutes.sewaanTab('riwayat')),
              ),
              AppMenuRow(
                icon: Icons.badge_outlined,
                label: 'Status verifikasi KTM',
                value: statusLabel,
                valueColor: statusColor,
                onTap: () => context.push(statusRoute),
              ),
            ]),
            const AppMenuLabel('Preferensi'),
            AppMenuCard(children: [
              AppMenuRow(
                key: const Key('menu-tema'),
                icon: Icons.palette_outlined,
                label: 'Tema tampilan',
                value: labelTema(settings.themeMode),
                onTap: () => showThemeSheet(context),
              ),
              AppMenuRow(
                icon: Icons.notifications_none_rounded,
                label: 'Notifikasi sewa',
                onTap: () => ref
                    .read(settingsControllerProvider.notifier)
                    .setNotifSewa(!settings.notifSewa),
                trailing: Switch(
                  value: settings.notifSewa,
                  onChanged: ref
                      .read(settingsControllerProvider.notifier)
                      .setNotifSewa,
                ),
              ),
              AppMenuRow(
                icon: Icons.campaign_outlined,
                label: 'Info & promo kampus',
                onTap: () => ref
                    .read(settingsControllerProvider.notifier)
                    .setNotifPromo(!settings.notifPromo),
                trailing: Switch(
                  value: settings.notifPromo,
                  onChanged: ref
                      .read(settingsControllerProvider.notifier)
                      .setNotifPromo,
                ),
              ),
            ]),
            const AppMenuLabel('Lainnya'),
            AppMenuCard(children: [
              AppMenuRow(
                icon: Icons.help_outline_rounded,
                label: 'Bantuan & laporkan masalah',
                onTap: () => context.push(AppRoutes.bantuan),
              ),
              AppMenuRow(
                icon: Icons.info_outline_rounded,
                label: 'Tentang HobbySwap',
                onTap: () => context.push(AppRoutes.tentang),
              ),
              AppMenuRow(
                icon: Icons.description_outlined,
                label: 'Syarat Layanan',
                onTap: () => context.push(AppRoutes.syarat),
              ),
              AppMenuRow(
                icon: Icons.privacy_tip_outlined,
                label: 'Kebijakan Privasi',
                onTap: () => context.push(AppRoutes.privasi),
              ),
              AppMenuRow(
                key: const Key('menu-hapus-akun'),
                icon: Icons.delete_forever_outlined,
                label: 'Hapus akun',
                destructive: true,
                onTap: () => context.push(AppRoutes.hapusAkun),
              ),
            ]),
            if (kDebugMode) ...[
              const AppMenuLabel('Alat pengembang'),
              AppMenuCard(children: [
                AppMenuRow(
                  icon: Icons.replay_rounded,
                  label: 'Reset onboarding',
                  onTap: () async {
                    await ref.read(sessionStorageProvider).resetOnboarding();
                    if (context.mounted) {
                      _snack(context,
                          'Onboarding tampil lagi saat app dibuka ulang.');
                    }
                  },
                ),
                AppMenuRow(
                  icon: Icons.restart_alt_rounded,
                  label: 'Reset data contoh',
                  onTap: () => _resetDataContoh(context, ref),
                ),
                if (user.statusVerifikasi != StatusVerifikasi.terverifikasi)
                  AppMenuRow(
                    key: const Key('debug-setujui-ktm'),
                    icon: Icons.verified_outlined,
                    label: 'Simulasikan KTM disetujui',
                    onTap: () async {
                      await ref.read(verificationActionsProvider).debugApprove();
                      if (context.mounted) {
                        _snack(context, 'Akun disetujui (debug).');
                      }
                    },
                  ),
                AppMenuRow(
                  key: const Key('debug-balasan-otomatis'),
                  icon: Icons.smart_toy_outlined,
                  label: 'Balasan otomatis Pesan',
                  value: ref.watch(chatAutoBalasAktifProvider) ? 'Aktif' : 'Mati',
                  onTap: () =>
                      ref.read(chatAutoBalasAktifProvider.notifier).toggle(),
                ),
                if (itemRepo is FakeItemRepository)
                  AppMenuRow(
                    icon: Icons.wifi_off_rounded,
                    label: 'Gagalkan muat berikutnya',
                    onTap: () {
                      itemRepo.debugFailNext = true;
                      _snack(context, 'Muat barang berikutnya akan gagal.');
                    },
                  ),
              ]),
            ],
            const SizedBox(height: AppSpacing.xl),
            _LogoutButton(onPressed: () => _logout(context, ref)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final (String label, Color bg, Color fg) = switch (user.statusVerifikasi) {
      StatusVerifikasi.terverifikasi => (
          'Mahasiswa terverifikasi',
          colors.accentSoft,
          colors.verified
        ),
      StatusVerifikasi.menunggu => (
          'KTM sedang ditinjau',
          colors.warning.withValues(alpha: 0.16),
          colors.warning
        ),
      StatusVerifikasi.belum => (
          'Belum verifikasi',
          colors.surfaceAlt,
          theme.colorScheme.onSurfaceVariant
        ),
    };

    return Row(
      children: [
        AppAvatar(user: user, size: AppSizes.avatarProfile),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  user.nama,
                  key: const Key('profil-nama'),
                  style: theme.textTheme.titleLarge
                      ?.merge(AppTextStyles.profileName),
                ),
              ),
              Text(
                '${user.prodi ?? user.fakultas ?? 'Mahasiswa'} · '
                'Universitas Sumatera Utara',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              if (user.jumlahBatalMendadak > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                BatalMendadakLabel(user.jumlahBatalMendadak),
              ],
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + AppSpacing.xs / 2,
                    vertical: AppSpacing.xs),
                decoration:
                    BoxDecoration(color: bg, borderRadius: AppRadius.pillAll),
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: fg, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.menyewa,
    required this.menyewakan,
    required this.barter,
    required this.user,
  });

  final int menyewa;
  final int menyewakan;
  final int barter;
  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final value = theme.textTheme.titleLarge?.merge(AppTextStyles.statValue);
    final label = theme.textTheme.bodySmall
        ?.merge(AppTextStyles.statLabel)
        .copyWith(color: theme.colorScheme.onSurfaceVariant);

    Widget cell(Widget v, String l, {VoidCallback? onTap, Key? key}) =>
        InkWell(
          key: key,
          onTap: onTap,
          borderRadius: AppRadius.inputAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md, horizontal: AppSpacing.xs),
            child: Column(
              children: [
                FittedBox(fit: BoxFit.scaleDown, child: v),
                const SizedBox(height: AppSpacing.xs),
                Text(l, textAlign: TextAlign.center, style: label),
              ],
            ),
          ),
        );

    final sel = [
      cell(Text('$menyewa×', style: value), 'Menyewa'),
      cell(Text('$menyewakan×', style: value), 'Menyewakan'),
      cell(Text('$barter×', style: value), 'Barter', key: const Key('stat-barter')),
      cell(
        Text.rich(
          TextSpan(children: [
            const TextSpan(
                text: '★ ', style: TextStyle(color: AppPalette.statsStar)),
            TextSpan(text: formatRating(user.rating)),
          ]),
          style: value,
        ),
        '${user.jumlahUlasan} ulasan',
        key: const Key('profil-rating'),
        onTap: () => context.push(AppRoutes.profilUlasan),
      ),
    ];

    Widget baris(List<Widget> isi) => IntrinsicHeight(
          child: Row(
            children: [
              for (final (i, c) in isi.indexed) ...[
                if (i > 0) VerticalDivider(color: colors.border, width: 1),
                Expanded(child: c),
              ],
            ],
          ),
        );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xs),
      // Layar sempit (≤ 360 dp) atau font besar: grid 2×2.
      child: LayoutBuilder(
        builder: (context, box) {
          final sempit = box.maxWidth < AppSizes.statKolomMin * 4 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.2;
          if (!sempit) return baris(sel);
          return Column(
            children: [
              baris(sel.sublist(0, 2)),
              Divider(color: colors.border, height: 1),
              baris(sel.sublist(2)),
            ],
          );
        },
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.logoutButton),
      child: OutlinedButton.icon(
        key: const Key('profil-keluar'),
        onPressed: onPressed,
        icon: Icon(Icons.logout_rounded, color: error),
        label: Text('Keluar', style: TextStyle(color: error)),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.logoutButton),
          side: BorderSide(color: error.withValues(alpha: 0.4)),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
          foregroundColor: error,
        ),
      ),
    );
  }
}
