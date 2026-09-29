import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/item_card.dart';
import '../data/favorit_providers.dart';
import 'favorit_button.dart';

/// /profil/favorit — grid barang yang ditandai hati.
class FavoritkuPage extends ConsumerWidget {
  const FavoritkuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(favoritkuProvider);

    SliverToBoxAdapter padded(Widget child) => SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.pageHome),
            child: child,
          ),
        );

    final List<Widget> isi = switch (async) {
      AsyncValue(:final value?) when value.isEmpty => [
          padded(const Padding(
            padding: EdgeInsets.only(top: AppSpacing.xxl),
            child: AppEmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'Belum ada favorit.',
              message: 'Tekan ikon hati di barang yang kamu incar.',
            ),
          )),
        ],
      AsyncValue(:final value?) => [
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.pageHome),
            sliver: SliverItemGrid(
              listings: value,
              onTap: (l) =>
                  context.push(AppRoutes.barangDetail(l.item.id), extra: l),
              aksiPojok: (l) =>
                  FavoritButton(itemId: l.item.id, diFoto: true),
            ),
          ),
        ],
      AsyncError() => [
          padded(AppEmptyState(
            icon: Icons.wifi_off_rounded,
            title: AppTeks.koneksiPutus,
            actionLabel: AppTeks.cobaLagi,
            onAction: () => ref.invalidate(favoritkuProvider),
          )),
        ],
      _ => [
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.pageHome),
            sliver: SliverSkeletonizer(
              child: SliverItemGrid(
                listings: List.filled(2, ItemCard.placeholder),
              ),
            ),
          ),
        ],
    };

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome,
                  AppSpacing.md, AppSpacing.pageHome, AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    AppBackButton(
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go(AppRoutes.profil),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text('Favoritku',
                            style: theme.textTheme.headlineMedium),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...isi,
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }
}
