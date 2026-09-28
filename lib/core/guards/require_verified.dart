import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/user.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/app_button.dart';

/// Menjalankan [onAllowed] hanya untuk akun terverifikasi; selain itu
/// menjelaskan alasannya lewat bottom sheet (bukan tombol mati tanpa penjelasan).
Future<void> requireVerified(
  BuildContext context,
  WidgetRef ref, {
  required VoidCallback onAllowed,
}) async {
  final user = ref.read(authControllerProvider);
  if (user == null) {
    context.go(AppRoutes.login);
    return;
  }

  final (IconData icon, String title, String body, String action, String route) =
      switch (user.statusVerifikasi) {
    StatusVerifikasi.terverifikasi => (Icons.check, '', '', '', ''),
    StatusVerifikasi.belum => (
        Icons.badge_outlined,
        'Verifikasi KTM dulu, ya',
        'Biar aman, cuma mahasiswa terverifikasi yang bisa sewa dan '
            'menyewakan barang. Cukup foto KTM dan selfie, kurang dari 2 menit.',
        'Verifikasi sekarang',
        AppRoutes.verifikasi,
      ),
    StatusVerifikasi.menunggu => (
        Icons.hourglass_top_rounded,
        'KTM-mu masih ditinjau',
        'Biasanya kurang dari 1×24 jam. Kami kabari lewat notifikasi begitu '
            'akunmu aktif.',
        'Lihat status',
        AppRoutes.verifikasiStatus,
      ),
  };

  if (user.statusVerifikasi == StatusVerifikasi.terverifikasi) {
    onAllowed();
    return;
  }

  final go = await showAppBottomSheet<bool>(
    context,
    builder: (sheet) => _GuardSheet(
      icon: icon,
      title: title,
      body: body,
      actionLabel: action,
      onAction: () => Navigator.pop(sheet, true),
      onDismiss: () => Navigator.pop(sheet, false),
    ),
  );
  if (go == true && context.mounted) context.push(route);
}

class _GuardSheet extends StatelessWidget {
  const _GuardSheet({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    required this.onDismiss,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: AppSizes.iconTile,
            height: AppSizes.iconTile,
            decoration: BoxDecoration(
              color: colors.accentSoft,
              borderRadius: AppRadius.inputAll,
            ),
            child: Icon(icon, color: colors.accentText, size: AppSizes.iconLg),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Semantics(
          header: true,
          child: Text(title, style: theme.textTheme.titleLarge),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          body,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: actionLabel, onPressed: onAction),
        const SizedBox(height: AppSpacing.sm),
        TextButton(onPressed: onDismiss, child: const Text('Nanti saja')),
      ],
    );
  }
}
