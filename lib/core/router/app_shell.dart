import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/booking/data/booking_providers.dart';
import '../guards/require_verified.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_bottom_nav.dart';
import 'app_routes.dart';

const _tabs = [
  AppNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Beranda',
  ),
  AppNavItem(
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
    label: 'Sewaan',
  ),
  AppNavItem(
    icon: Icons.inventory_2_outlined,
    activeIcon: Icons.inventory_2_rounded,
    label: 'Barang',
  ),
  AppNavItem(
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'Profil',
  ),
];

/// Wadah tab: semua tab tetap hidup (state & scroll tersimpan). Tab tujuan
/// bergeser masuk dari arah posisinya di bottom nav, tab lama bergeser keluar.
class AnimatedBranchContainer extends StatelessWidget {
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppDurations.page;
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < children.length; i++)
          IgnorePointer(
            ignoring: i != currentIndex,
            // Tab yang tidak terlibat ikut bergeser tapi tak terlihat (opacity 0).
            // TickerMode hanya membungkus isi tab: animasi geser/fade tab yang
            // ditinggalkan harus tetap jalan sampai selesai.
            child: AnimatedOpacity(
              opacity: i == currentIndex ? 1 : 0,
              duration: duration,
              curve: Curves.easeOutCubic,
              child: AnimatedSlide(
                offset: Offset((i - currentIndex).sign * 0.3, 0),
                duration: duration,
                curve: Curves.easeOutCubic,
                child: TickerMode(
                    enabled: i == currentIndex, child: children[i]),
              ),
            ),
          ),
      ],
    );
  }
}

/// Kerangka tab utama.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        items: _tabs,
        currentIndex: navigationShell.currentIndex,
        fabKey: const Key('nav-fab'),
        badges: {2: ref.watch(pendingIncomingCountProvider)},
        onSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        onFabPressed: () => requireVerified(
          context,
          ref,
          onAllowed: () => context.push(AppRoutes.barangTambah),
        ),
      ),
    );
  }
}
