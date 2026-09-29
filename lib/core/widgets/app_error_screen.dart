import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_strings.dart';
import '../router/app_routes.dart';
import '../theme/app_spacing.dart';
import 'app_empty_state.dart';

/// Pengganti layar merah di release build (lihat [pasangPenangananError]).
/// Aman dipakai di mana saja: bisa mengisi area kecil (tetap bisa digulir).
class AppErrorScreen extends StatelessWidget {
  const AppErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppEmptyState(
              icon: Icons.sentiment_dissatisfied_outlined,
              title: AppTeks.errorJudul,
              message: AppTeks.errorPesan,
              actionLabel: router == null ? null : AppTeks.kembaliKeBeranda,
              onAction: router == null
                  ? null
                  : () => router.go(AppRoutes.beranda),
            ),
          ),
        ),
      ),
    );
  }
}
