import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_menu.dart';
import '../../../core/widgets/hs_logo_mark.dart';
import '../data/support_providers.dart';

class TentangPage extends ConsumerWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final versi = switch (ref.watch(packageInfoProvider)) {
      AsyncData(:final value) => 'Versi ${value.version} (${value.buildNumber})',
      AsyncError() => 'Versi tidak diketahui',
      _ => ' ',
    };

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome, AppSpacing.md,
              AppSpacing.pageHome, AppSpacing.xxl),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: AppBackButton(
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.profil),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            const Center(child: HsLogoMark(size: AppSizes.avatarEdit)),
            const SizedBox(height: AppSpacing.xl),
            Semantics(
              header: true,
              child: Text('HobbySwap',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(versi,
                key: const Key('tentang-versi'),
                textAlign: TextAlign.center,
                style: muted),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Membantu mahasiswa saling menyewa barang hobi dengan aman, '
              'supaya barang nganggur jadi berguna dan hobi tidak harus mahal.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Dibuat untuk mahasiswa USU',
                textAlign: TextAlign.center, style: muted),
            const SizedBox(height: AppSpacing.xl),
            AppMenuCard(children: [
              AppMenuRow(
                key: const Key('tentang-syarat'),
                icon: Icons.description_outlined,
                label: 'Syarat Layanan',
                onTap: () => context.push(AppRoutes.syarat),
              ),
              AppMenuRow(
                key: const Key('tentang-privasi'),
                icon: Icons.privacy_tip_outlined,
                label: 'Kebijakan Privasi',
                onTap: () => context.push(AppRoutes.privasi),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
