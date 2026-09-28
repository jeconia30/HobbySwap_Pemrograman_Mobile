import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_info_note.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_controller.dart';

/// Banner status verifikasi; kosong bila akun sudah terverifikasi.
class VerificationBanner extends ConsumerWidget {
  const VerificationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(authControllerProvider)?.statusVerifikasi) {
      StatusVerifikasi.belum => AppInfoNote(
          key: const Key('verification-banner'),
          icon: Icons.badge_outlined,
          message: 'Akunmu belum terverifikasi. Verifikasi KTM supaya bisa '
              'sewa dan menyewakan barang.',
          actionLabel: 'Verifikasi sekarang',
          onAction: () => context.push(AppRoutes.verifikasi),
        ),
      StatusVerifikasi.menunggu => AppInfoNote(
          key: const Key('verification-banner'),
          icon: Icons.hourglass_top_rounded,
          message: 'KTM-mu sedang ditinjau. Biasanya kurang dari 1×24 jam.',
          actionLabel: 'Lihat status',
          onAction: () => context.push(AppRoutes.verifikasiStatus),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
