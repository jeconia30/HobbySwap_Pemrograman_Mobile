import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_redirect.dart';
import '../../../core/storage/session_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_page_dots.dart';
import '../../../core/widgets/hs_logo_mark.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_controller.dart';

/// Layar brand; tampil sama di mode terang & gelap.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    Future<User?> restore() async {
      try {
        return await ref.read(authControllerProvider.notifier).restoreSession();
      } catch (_) {
        return null;
      }
    }

    final (user, _) = await (
      restore(),
      Future<void>.delayed(AppDurations.splashMinimum),
    ).wait;
    if (!mounted) return;
    context.go(splashDestination(
      onboardingSeen: ref.read(sessionStorageProvider).onboardingSeen,
      status: user?.statusVerifikasi,
    ));
  }


  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    const large = AppSizes.splashDecorLarge;
    const small = AppSizes.splashDecorSmall;

    // Logo tampil penuh sejak frame pertama di tengah layar, persis seperti
    // splash native; hanya elemen pendukung yang muncul perlahan.
    Widget fadeIn(Widget child) => TweenAnimationBuilder<double>(
          tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
          duration: reduceMotion ? Duration.zero : AppDurations.page,
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => Opacity(opacity: t, child: child),
          child: child,
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: AppPalette.transparent,
        systemNavigationBarColor: AppPalette.splashBg,
      ),
      child: Scaffold(
        backgroundColor: AppPalette.splashBg,
        body: LayoutBuilder(
          builder: (context, box) => Stack(
            children: [
              Positioned(
                left: -large * 0.42,
                top: -large * 0.34,
                child: fadeIn(_DecorCircle(
                  diameter: large,
                  color: AppPalette.splashDecorDeep.withValues(alpha: 0.55),
                )),
              ),
              Positioned(
                right: -small * 0.42,
                bottom: -small * 0.3,
                child: fadeIn(_DecorCircle(
                  diameter: small,
                  color: AppPalette.splashDecorMid.withValues(alpha: 0.18),
                )),
              ),
              const Center(child: HsLogoMark.splash()),
              Positioned(
                left: AppSpacing.pageHorizontal,
                right: AppSpacing.pageHorizontal,
                top: box.maxHeight / 2 + AppSizes.splashLogo / 2 + AppSpacing.lg,
                child: fadeIn(Column(
                  mainAxisSize: MainAxisSize.min,
                  // Nama "HobbySwap" sudah ada di logo; di bawahnya cukup tagline.
                  children: [
                    Text(
                      'Sewa alat hobi antar mahasiswa',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium
                          ?.copyWith(color: AppPalette.splashSubtitle),
                    ),
                  ],
                )),
              ),
              Positioned(
                left: AppSpacing.pageHorizontal,
                right: AppSpacing.pageHorizontal,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: fadeIn(Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppPageDots.splash(count: 3, index: 0),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Khusus mahasiswa terverifikasi',
                        textAlign: TextAlign.center,
                        style: text.bodySmall
                            ?.copyWith(color: AppPalette.splashSubtitle),
                      ),
                      const SizedBox(height: AppSpacing.splashBottom),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
