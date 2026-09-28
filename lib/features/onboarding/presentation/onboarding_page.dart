import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/storage/session_storage.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_page_dots.dart';
import 'onboarding_illustrations.dart';

typedef _Slide = ({OnboardingIllustration art, String title, String body});

const _slides = <_Slide>[
  (
    art: OnboardingIllustration.rent,
    title: 'Pinjam alat hobi, tanpa harus beli.',
    body: 'Kamera, tenda, sampai stik game. Sewa dari sesama mahasiswa di '
        'kampusmu, aman dengan verifikasi KTM.',
  ),
  (
    art: OnboardingIllustration.verified,
    title: 'Semua penggunanya mahasiswa terverifikasi.',
    body: 'Setiap akun dicek lewat KTM, jadi kamu tahu barangmu disewa siapa.',
  ),
  (
    art: OnboardingIllustration.lend,
    title: 'Punya barang nganggur? Sewakan.',
    body: 'Pasang barangmu dalam semenit dan dapat tambahan uang jajan dari '
        'teman sekampus.',
  ),
];

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;
  bool _finishing = false;

  bool get _isLast => _index == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    await ref.read(sessionStorageProvider).setOnboardingSeen();
    if (mounted) context.go(AppRoutes.login);
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(_index + 1);
    } else {
      _controller.nextPage(
          duration: AppDurations.page, curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontal - AppSpacing.sm,
                  0,
                ),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Lewati'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _SlideView(_slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.lg,
                AppSpacing.pageHorizontal,
                AppSpacing.xl,
              ),
              child: Column(
                children: [
                  AppPageDots(count: _slides.length, index: _index),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    key: const Key('onboarding-next'),
                    label: _isLast ? 'Mulai' : 'Lanjut',
                    trailingIcon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView(this.slide);

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: OnboardingArt(slide.art),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.group),
          Semantics(
            header: true,
            child: Text(slide.title, style: text.headlineLarge),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            slide.body,
            style: text.bodyMedium
                ?.merge(AppTextStyles.lead)
                .copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
