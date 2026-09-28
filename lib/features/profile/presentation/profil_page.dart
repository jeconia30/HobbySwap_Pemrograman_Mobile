import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_placeholder_page.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../item/data/fake_item_repository.dart';
import '../../item/data/item_providers.dart';
import '../../verification/presentation/verification_actions.dart';

/// Placeholder sampai M7: Keluar + alat bantu debug.
class ProfilPage extends ConsumerWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final repo = ref.watch(itemRepositoryProvider);

    void snack(String msg) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));

    return AppPlaceholderPage(
      title: user == null ? 'Profil' : user.nama,
      icon: Icons.person_outline_rounded,
      message: 'Profil, reputasi, dan pengaturan akan tampil di sini.',
      children: [
        if (kDebugMode &&
            user?.statusVerifikasi == StatusVerifikasi.menunggu) ...[
          TextButton(
            onPressed: () async {
              await ref.read(verificationActionsProvider).debugApprove();
              snack('Akun disetujui (debug).');
            },
            child: const Text('Simulasikan disetujui (debug)'),
          ),
        ],
        if (kDebugMode && repo is FakeItemRepository)
          TextButton(
            onPressed: () {
              repo.debugFailNext = true;
              snack('Muat barang berikutnya akan gagal (debug).');
            },
            child: const Text('Gagalkan muat berikutnya (debug)'),
          ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Keluar',
          variant: AppButtonVariant.outline,
          onPressed: () async {
            await ref.read(authControllerProvider.notifier).logout();
            if (context.mounted) context.go(AppRoutes.login);
          },
        ),
      ],
    );
  }
}
