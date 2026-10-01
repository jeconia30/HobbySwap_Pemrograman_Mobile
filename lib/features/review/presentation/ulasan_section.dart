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
import '../../auth/presentation/auth_controller.dart';
import '../../item/data/item_providers.dart';
import '../../../core/widgets/app_info_note.dart';
import '../data/review_ai.dart';
import '../data/review_providers.dart';
import '../domain/review.dart';
import 'review_tile.dart';
import '../../../core/constants/app_strings.dart';

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
      TextSpan(
        children: [
          TextSpan(
            text: '★ ${formatRating(owner.rating)}',
            style: TextStyle(
              color: AppColors.of(context).warning,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: ' · ${owner.jumlahUlasan} ulasan untuk ${owner.nama}'),
        ],
      ),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
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
                  onPressed: () => context.push(AppRoutes.ulasanBarang(itemId)),
                  child: const Text('Lihat semua', textAlign: TextAlign.end),
                ),
              ),
          ],
        ),
        _Ringkasan(owner: owner),
        const SizedBox(height: AppSpacing.md),
        if (ref.watch(ringkasanUlasanProvider(owner.id)).value
            case final ringkasan?) ...[
          AppInfoNote(
            key: const Key('ringkasan-ulasan-ai'),
            icon: Icons.auto_awesome_rounded,
            message: 'Ringkasan AI: $ringkasan',
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (async.isLoading && !async.hasValue)
          const Skeletonizer(child: Text('Memuat ulasan dari penyewa'))
        else if (list.isEmpty)
          Text(
            'Belum ada ulasan',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
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
        child: Builder(
          builder: (context) {
            final kepala = <Widget>[
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
                      child: Text(
                        'Ulasan',
                        style: theme.textTheme.headlineMedium,
                      ),
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
                  title: AppTeks.koneksiPutus,
                  actionLabel: AppTeks.cobaLagi,
                  onAction: () => ref.invalidate(reviewsForUserProvider),
                )
              else if (!async.hasValue)
                const Skeletonizer(child: Text('Memuat ulasan dari penyewa'))
              else if (list.isEmpty)
                const AppEmptyState(
                  icon: Icons.rate_review_outlined,
                  title: 'Belum ada ulasan',
                ),
            ];
            final tampil = async.hasValue && !async.hasError
                ? list
                : const <ReviewDetail>[];
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHome,
                AppSpacing.md,
                AppSpacing.pageHome,
                AppSpacing.xxl,
              ),
              itemCount: kepala.length + tampil.length,
              itemBuilder: (context, i) {
                if (i < kepala.length) return kepala[i];
                final j = i - kepala.length;
                final tile = ReviewTile(detail: tampil[j]);
                return j == 0 ? tile : Column(children: [_pemisah, tile]);
              },
            );
          },
        ),
      ),
    );
  }
}

/// /profil/ulasan — semua ulasan yang diterima user yang sedang masuk
/// (sebagai pemilik maupun penyewa).
class UlasanTentangkuPage extends ConsumerWidget {
  const UlasanTentangkuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider);
    final async = user == null
        ? const AsyncValue<List<ReviewDetail>>.data([])
        : ref.watch(reviewsForUserProvider(user.id));
    final list = async.value ?? const <ReviewDetail>[];

    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final kepala = <Widget>[
              Row(
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
                      child: Text(
                        'Ulasan tentangku',
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (user != null) _Ringkasan(owner: user),
              const SizedBox(height: AppSpacing.xl),
              if (async.hasError)
                AppEmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: AppTeks.koneksiPutus,
                  actionLabel: AppTeks.cobaLagi,
                  onAction: () => ref.invalidate(reviewsForUserProvider),
                )
              else if (!async.hasValue)
                const Skeletonizer(child: Text('Memuat ulasan untukmu'))
              else if (list.isEmpty)
                const AppEmptyState(
                  icon: Icons.rate_review_outlined,
                  title: 'Belum ada ulasan tentangmu',
                  message: 'Ulasan muncul setelah sewa selesai.',
                ),
            ];
            final tampil = async.hasValue && !async.hasError
                ? list
                : const <ReviewDetail>[];
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHome,
                AppSpacing.md,
                AppSpacing.pageHome,
                AppSpacing.xxl,
              ),
              itemCount: kepala.length + tampil.length,
              itemBuilder: (context, i) {
                if (i < kepala.length) return kepala[i];
                final j = i - kepala.length;
                final tile = ReviewTile(detail: tampil[j]);
                return j == 0 ? tile : Column(children: [_pemisah, tile]);
              },
            );
          },
        ),
      ),
    );
  }
}

const _pemisah = Padding(
  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
  child: Divider(),
);
