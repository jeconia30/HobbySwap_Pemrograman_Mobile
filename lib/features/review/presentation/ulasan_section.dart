import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../auth/domain/user.dart';
import '../../item/data/item_providers.dart';
import '../data/review_providers.dart';
import '../domain/review.dart';
import 'review_tile.dart';

/// Ulasan penyewa untuk pemilik barang (yang membentuk rating di kartu).
List<ReviewDetail> _untukPemilik(List<ReviewDetail> all) => [
      for (final r in all)
        if (r.review.peran == PeranUlasan.penyewaMenilaiPemilik) r,
    ];

class _Ringkasan extends StatelessWidget {
  const _Ringkasan({required this.owner});

  final User owner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (owner.jumlahUlasan == 0) return const SizedBox.shrink();
    return Text.rich(
      TextSpan(children: [
        TextSpan(
          text: '★ ${formatRating(owner.rating)}',
          style: TextStyle(
              color: AppColors.of(context).warning,
              fontWeight: FontWeight.w800),
        ),
        TextSpan(text: ' · ${owner.jumlahUlasan} ulasan untuk ${owner.nama}'),
      ]),
      style: theme.textTheme.bodySmall
          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

/// Bagian "Ulasan" di Detail Barang: ringkasan + 2 ulasan terbaru.
class UlasanSection extends ConsumerWidget {
  const UlasanSection({super.key, required this.itemId, required this.owner});

  final String itemId;
  final User owner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(reviewsForUserProvider(owner.id));
    final list = _untukPemilik(async.value ?? const []);

    return Column(
      key: const Key('ulasan-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text('Ulasan', style: theme.textTheme.titleMedium),
              ),
            ),
            if (list.isNotEmpty)
              Flexible(
                child: TextButton(
                  onPressed: () =>
                      context.push(AppRoutes.ulasanBarang(itemId)),
                  child: const Text('Lihat semua', textAlign: TextAlign.end),
                ),
              ),
          ],
        ),
        _Ringkasan(owner: owner),
        const SizedBox(height: AppSpacing.md),
        if (async.isLoading && !async.hasValue)
          const Skeletonizer(child: Text('Memuat ulasan dari penyewa'))
        else if (list.isEmpty)
          Text(
            'Belum ada ulasan',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          )
        else
          for (final (i, r) in list.take(2).indexed) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(),
              ),
            ReviewTile(detail: r),
          ],
      ],
    );
  }
}

/// /barang/:id/ulasan — semua ulasan untuk pemilik barang.
class UlasanPage extends ConsumerWidget {
  const UlasanPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final owner = ref.watch(itemByIdProvider(itemId)).value?.owner;
    final async = owner == null
        ? const AsyncValue<List<ReviewDetail>>.loading()
        : ref.watch(reviewsForUserProvider(owner.id));
    final list = _untukPemilik(async.value ?? const []);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome, AppSpacing.md,
              AppSpacing.pageHome, AppSpacing.xxl),
          children: [
            Row(
              children: [
                AppBackButton(
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.barangDetail(itemId)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Semantics(
                    header: true,
                    child:
                        Text('Ulasan', style: theme.textTheme.headlineMedium),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (owner != null) _Ringkasan(owner: owner),
            const SizedBox(height: AppSpacing.xl),
            if (async.hasError)
              AppEmptyState(
                icon: Icons.wifi_off_rounded,
                title: 'Koneksi lagi putus. Coba lagi ya.',
                actionLabel: 'Coba lagi',
                onAction: () => ref.invalidate(reviewsForUserProvider),
              )
            else if (!async.hasValue)
              const Skeletonizer(child: Text('Memuat ulasan dari penyewa'))
            else if (list.isEmpty)
              const AppEmptyState(
                  icon: Icons.rate_review_outlined, title: 'Belum ada ulasan')
            else
              for (final (i, r) in list.indexed) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Divider(),
                  ),
                ReviewTile(detail: r),
              ],
          ],
        ),
      ),
    );
  }
}
