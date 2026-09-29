import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_step_header.dart';
import '../../../core/widgets/app_sticky_bottom.dart';
import '../../../core/widgets/app_timeline.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_controller.dart';

/// Status verifikasi. Simulasi persetujuan (debug) ada di Profil → Alat pengembang.
class VerifikasiStatusPage extends ConsumerWidget {
  const VerifikasiStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final colors = AppColors.of(context);
    final active = ref.watch(authControllerProvider)?.statusVerifikasi ==
        StatusVerifikasi.terverifikasi;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.md,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppStepHeader(current: 3, total: 3),
                    const SizedBox(height: AppSpacing.xxl),
                    Center(
                      child: Container(
                        width: AppSizes.statusArt,
                        height: AppSizes.statusArt,
                        decoration: BoxDecoration(
                          color: colors.accentSoft,
                          borderRadius:
                              BorderRadius.circular(AppRadius.sheet),
                        ),
                        child: Icon(
                          active
                              ? Icons.verified_rounded
                              : Icons.hourglass_top_rounded,
                          color: active ? colors.verified : colors.accentText,
                          size: AppSizes.iconTile,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(
                        active
                            ? 'Akunmu sudah aktif!'
                            : 'KTM-mu sedang ditinjau',
                        textAlign: TextAlign.center,
                        style: text.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      active
                          ? 'Sekarang kamu bisa sewa dan menyewakan barang '
                              'dengan teman sekampus.'
                          : 'Kami kabari lewat notifikasi begitu akunmu aktif. '
                              'Biasanya kurang dari 1×24 jam.',
                      textAlign: TextAlign.center,
                      style: text.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.group),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: AppRadius.cardAll,
                        border: Border.all(color: colors.border),
                      ),
                      child: AppTimeline(steps: [
                        const AppTimelineStep(
                            'Akun dibuat', AppTimelineState.done),
                        const AppTimelineStep(
                            'Dokumen dikirim', AppTimelineState.done),
                        AppTimelineStep(
                          'Ditinjau tim HobbySwap',
                          active
                              ? AppTimelineState.done
                              : AppTimelineState.current,
                        ),
                        AppTimelineStep(
                          'Akun aktif',
                          active
                              ? AppTimelineState.done
                              : AppTimelineState.pending,
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            AppStickyBottom(
              children: [
                AppButton(
                  label: active ? 'Mulai jelajah' : 'Jelajah barang dulu',
                  onPressed: () => context.go(AppRoutes.beranda),
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
