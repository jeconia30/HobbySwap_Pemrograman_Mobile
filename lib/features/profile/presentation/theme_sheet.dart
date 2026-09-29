import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/settings_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_press_scale.dart';

String labelTema(ThemeMode mode) => switch (mode) {
  ThemeMode.system => 'Ikuti sistem',
  ThemeMode.light => 'Terang',
  ThemeMode.dark => 'Gelap',
};

Future<void> showThemeSheet(BuildContext context) =>
    showAppBottomSheet<void>(context, builder: (_) => const _ThemeSheet());

/// Pilihan tema; perubahan langsung diterapkan & disimpan.
class _ThemeSheet extends ConsumerWidget {
  const _ThemeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(
      settingsControllerProvider.select((s) => s.themeMode),
    );
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSheetTitle('Tema tampilan'),
        for (final mode in const [
          ThemeMode.system,
          ThemeMode.light,
          ThemeMode.dark,
        ])
          AppPressScale(
            child: Semantics(
              inMutuallyExclusiveGroup: true,
              checked: mode == current,
              button: true,
              label: labelTema(mode),
              excludeSemantics: true,
              child: InkWell(
                key: Key('tema-${mode.name}'),
                borderRadius: AppRadius.inputAll,
                onTap: () => ref
                    .read(settingsControllerProvider.notifier)
                    .setThemeMode(mode),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppSizes.menuRow + AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      _ThemePreview(mode),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Text(
                          labelTema(mode),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Icon(
                        mode == current
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: mode == current
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Pratinjau mini: terang (krem + garis hijau tua), gelap (latar gelap + garis
/// hijau sedang), sistem (dibelah dua).
class _ThemePreview extends StatelessWidget {
  const _ThemePreview(this.mode);

  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    Widget half(bool dark) => Expanded(
      child: ColoredBox(
        color: dark ? AppPalette.darkBg : AppPalette.lightBg,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm - 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final w in const [1.0, 0.6])
                FractionallySizedBox(
                  widthFactor: w,
                  child: Container(
                    height: AppSpacing.xs,
                    margin: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: dark
                          ? AppPalette.brandMid
                          : AppPalette.lightAccent,
                      borderRadius: AppRadius.pillAll,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return ExcludeSemantics(
      child: Container(
        width: AppSizes.themePreview.width,
        height: AppSizes.themePreview.height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(AppRadius.menuIcon),
          ),
          border: Border.all(color: AppColors.of(context).border),
        ),
        child: Row(
          children: switch (mode) {
            ThemeMode.light => [half(false)],
            ThemeMode.dark => [half(true)],
            ThemeMode.system => [half(false), half(true)],
          },
        ),
      ),
    );
  }
}
