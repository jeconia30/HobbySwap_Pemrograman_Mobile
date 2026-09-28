import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import '../theme/app_spacing.dart';
import 'app_back_button.dart';
import 'app_empty_state.dart';

/// Halaman sementara untuk fitur milestone berikutnya.
/// [showBack] untuk halaman penuh (di luar tab); tab utama tanpa tombol kembali.
class AppPlaceholderPage extends StatelessWidget {
  const AppPlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    this.message = 'Fitur ini segera hadir.',
    this.showBack = false,
    this.children = const [],
  });

  final String title;
  final IconData icon;
  final String message;
  final bool showBack;

  /// Konten tambahan di bawah pesan (mis. tombol).
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageHome,
            AppSpacing.md,
            AppSpacing.pageHome,
            MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
          ),
          children: [
            if (showBack)
              Align(
                alignment: Alignment.centerLeft,
                child: AppBackButton(
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.beranda),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              header: true,
              child: Text(title, style: theme.textTheme.headlineMedium),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            AppEmptyState(icon: icon, title: 'Segera hadir', message: message),
            if (children.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              ...children,
            ],
          ],
        ),
      ),
    );
  }
}
