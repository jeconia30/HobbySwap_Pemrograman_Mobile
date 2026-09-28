import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/booking/data/booking_providers.dart';
import '../guards/require_verified.dart';
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

/// Kerangka tab utama. Tiap tab hidup di IndexedStack, jadi posisi scroll-nya
/// tetap tersimpan saat berpindah tab.
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
