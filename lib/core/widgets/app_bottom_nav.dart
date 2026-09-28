import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

@immutable
class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Bottom nav 4 tab dengan FAB di tengah yang naik [AppSizes.fabLift] di atas bar.
/// Pakai bersama `Scaffold(extendBody: true)` agar area di samping FAB
/// tetap menampilkan (dan meneruskan sentuhan ke) konten di belakangnya.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    required this.onFabPressed,
    this.fabTooltip = 'Sewakan barang',
    this.fabKey,
    this.badges = const {},
  }) : assert(items.length == 4);

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onFabPressed;
  final String fabTooltip;
  final Key? fabKey;

  /// Angka badge per indeks tab (0 = tidak tampil).
  final Map<int, int> badges;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final inset = MediaQuery.paddingOf(context).bottom;
    final barHeight =
        math.max(AppSizes.bottomNav, AppSizes.bottomNavMinContent + inset);

    Widget tab(int i) => Expanded(
          child: _NavTab(
            item: items[i],
            selected: i == currentIndex,
            badge: badges[i] ?? 0,
            onTap: () => onSelected(i),
          ),
        );

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: SizedBox(
        height: barHeight + AppSizes.fabLift,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: barHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(
                      top: BorderSide(color: AppColors.of(context).border)),
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: inset),
                  child: Row(
                    children: [
                      tab(0),
                      tab(1),
                      const SizedBox(width: AppSizes.fab + AppSpacing.lg),
                      tab(2),
                      tab(3),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: _Fab(
                  key: fabKey,
                  tooltip: fabTooltip,
                  onPressed: onFabPressed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final AppNavItem item;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: badge > 0 ? '${item.label}, $badge baru' : item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              isLabelVisible: badge > 0,
              label: Text('$badge'),
              child: Icon(selected ? item.activeIcon : item.icon,
                  color: color, size: AppSizes.iconMd),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall
                  ?.merge(AppTextStyles.navLabel)
                  .copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  const _Fab({super.key, required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const radius = BorderRadius.all(Radius.circular(AppRadius.card));

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: scheme.primary,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox.square(
                dimension: AppSizes.fab,
                child: Icon(Icons.add_rounded,
                    color: scheme.onPrimary, size: AppSizes.iconLg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
