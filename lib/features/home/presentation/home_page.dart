import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_icon_tile_button.dart';
import '../../../core/widgets/item_card.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../item/domain/item.dart';
import '../../item/domain/item_filter.dart';
import '../../item/domain/kategori.dart';
import '../../verification/presentation/verification_banner.dart';
import 'home_controller.dart';
import 'home_filter_sheet.dart';

const _searchDebounce = Duration(milliseconds: 300);
const _popularCount = 4;

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _search = TextEditingController();
  Timer? _debounce;
  bool _showAll = false;

  HomeFilterController get _filter => ref.read(homeFilterProvider.notifier);

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () => _filter.setQuery(value));
  }

  void _clearSearch() {
    _debounce?.cancel();
    _search.clear();
    _filter.setQuery('');
    setState(() {});
  }

  void _resetAll() {
    _debounce?.cancel();
    _search.clear();
    _filter.reset();
    setState(() => _showAll = false);
  }

  Future<void> _openFilter() async {
    final result = await showHomeFilterSheet(context, ref.read(homeFilterProvider));
    if (result == null) return;
    _filter.applySheet(
      sort: result.sort,
      hargaMaks: result.hargaMaks,
      hanyaTersedia: result.hanyaTersedia,
    );
  }

  void _openItem(ItemListing l) => context.push(AppRoutes.barangDetail(l.item.id));

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider);
    final filter = ref.watch(homeFilterProvider);
    final items = ref.watch(homeItemsProvider);
    final status = user?.statusVerifikasi;
    final showBanner = status == StatusVerifikasi.belum ||
        status == StatusVerifikasi.menunggu;

    SliverPadding padded(Widget sliver) => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHome),
          sliver: sliver,
        );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          // Kegagalan ditampilkan sebagai state error di daftar, bukan dilempar.
          onRefresh: () => ref
              .refresh(homeItemsProvider.future)
              .then<void>((_) {}, onError: (Object _) {}),
          child: CustomScrollView(
            key: const Key('home-scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome,
                    AppSpacing.md, AppSpacing.pageHome, 0),
                sliver: SliverList.list(children: [
                  if (user != null) _Header(user: user),
                  const SizedBox(height: AppSpacing.lg),
                  if (showBanner) ...[
                    const VerificationBanner(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  _SearchField(
                    controller: _search,
                    onChanged: _onSearchChanged,
                    onClear: _clearSearch,
                    filterCount: filter.sheetFilterCount,
                    onFilter: _openFilter,
                  ),
                ]),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: _KategoriChips(
                    selected: filter.kategori,
                    onSelected: _filter.setKategori,
                  ),
                ),
              ),
              if (!filter.isActive)
                padded(SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    child: _PromoCard(
                      onTap: () => _filter.setKategori(Kategori.camping),
                    ),
                  ),
                )),
              ..._results(items, filter, padded),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _results(
    AsyncValue<List<ItemListing>> items,
    ItemFilter filter,
    SliverPadding Function(Widget) padded,
  ) {
    if (items.isLoading) return [padded(const _SkeletonGrid())];

    if (items.hasError) {
      return [
        padded(SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: AppEmptyState(
              icon: Icons.wifi_off_rounded,
              title: 'Koneksi lagi putus. Coba lagi ya.',
              actionLabel: 'Coba lagi',
              onAction: () => ref.invalidate(homeItemsProvider),
            ),
          ),
        )),
      ];
    }

    final list = items.value ?? const <ItemListing>[];
    if (list.isEmpty) {
      return [
        padded(SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: AppEmptyState(
              key: const Key('home-empty'),
              icon: Icons.search_off_rounded,
              title: 'Belum ada barang yang cocok',
              message: 'Coba kata kunci lain atau longgarkan filternya.',
              actionLabel: 'Hapus filter',
              onAction: _resetAll,
            ),
          ),
        )),
      ];
    }

    Widget grid(List<ItemListing> l) =>
        padded(SliverItemGrid(listings: l, onTap: _openItem));

    if (filter.isActive) {
      return [
        padded(_SectionTitle('${list.length} barang ditemukan')),
        grid(list),
      ];
    }
    if (_showAll) {
      return [
        padded(_SectionTitle(
          'Semua barang',
          actionLabel: 'Ringkas',
          onAction: () => setState(() => _showAll = false),
        )),
        grid(list),
      ];
    }

    final popular = list.take(_popularCount).toList();
    // Id sampel berurutan: id lebih besar = ditambahkan lebih baru.
    final newest = list.skip(_popularCount).toList()
      ..sort((a, b) => b.item.id.compareTo(a.item.id));
    return [
      padded(_SectionTitle(
        'Populer di kampus',
        actionLabel: 'Lihat semua',
        onAction: () => setState(() => _showAll = true),
      )),
      grid(popular),
      if (newest.isNotEmpty) ...[
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        padded(const _SectionTitle('Baru ditambahkan')),
        grid(newest),
      ],
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kampusLabel,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              Semantics(
                header: true,
                child: Text(
                  'Halo, ${firstName(user.nama)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineLarge
                      ?.merge(AppTextStyles.greeting),
                ),
              ),
            ],
          ),
        ),
        AppIconTileButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Aktivitas, ada notifikasi baru',
          showDot: true,
          onPressed: () => context.push(AppRoutes.aktivitas),
        ),
        AppAvatar(user: user, onTap: () => context.go(AppRoutes.profil)),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.filterCount,
    required this.onFilter,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final int filterCount;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: AppSizes.searchField),
      padding: const EdgeInsets.only(left: AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.noteAll,
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded,
              color: scheme.onSurfaceVariant, size: AppSizes.iconMd),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              key: const Key('home-search'),
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: theme.textTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Cari kamera, tenda, sepeda…',
                filled: false,
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Hapus pencarian',
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm),
            ),
          IconButton(
            key: const Key('home-filter'),
            tooltip: filterCount > 0 ? 'Filter, $filterCount aktif' : 'Filter',
            onPressed: onFilter,
            style: IconButton.styleFrom(
              fixedSize: const Size.square(AppSizes.filterButton),
              minimumSize: const Size.square(AppSizes.filterButton),
              tapTargetSize: MaterialTapTargetSize.padded,
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(AppRadius.filterButton)),
              ),
            ),
            icon: Badge(
              isLabelVisible: filterCount > 0,
              label: Text('$filterCount'),
              backgroundColor: scheme.onSurface,
              textColor: scheme.surface,
              child: const Icon(Icons.tune_rounded, size: AppSizes.iconSm),
            ),
          ),
        ],
      ),
    );
  }
}

class _KategoriChips extends StatelessWidget {
  const _KategoriChips({required this.selected, required this.onSelected});

  final Kategori? selected;
  final ValueChanged<Kategori?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHome),
      child: Row(
        children: [
          AppChip(
            label: 'Semua',
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final k in Kategori.values) ...[
            const SizedBox(width: AppSpacing.sm),
            AppChip(
              key: Key('chip-${k.name}'),
              label: k.label,
              selected: selected == k,
              onTap: () => onSelected(k),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kartu promo brand; warnanya tetap sama di mode terang & gelap.
class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const message = 'Musim camping! Tenda & carrier mulai Rp25rb/hari';

    return Semantics(
      button: true,
      label: 'Minggu ini. $message. Lihat kategori Camping',
      excludeSemantics: true,
      child: Material(
        color: AppPalette.lightAccent,
        borderRadius: AppRadius.cardAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                right: -AppSizes.promoDecor * 0.3,
                top: -AppSizes.promoDecor * 0.35,
                child: Container(
                  width: AppSizes.promoDecor,
                  height: AppSizes.promoDecor,
                  decoration: BoxDecoration(
                    color: AppPalette.brandMid.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.pageHome),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MINGGU INI',
                            style: text.labelSmall
                                ?.merge(AppTextStyles.overline)
                                .copyWith(color: AppPalette.brandLeaf),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            message,
                            style: text.titleMedium?.copyWith(
                              color: AppPalette.lightOnAccent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Container(
                      width: AppSizes.tileButton,
                      height: AppSizes.tileButton,
                      decoration: const BoxDecoration(
                        color: AppPalette.cream,
                        borderRadius: AppRadius.inputAll,
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          color: AppPalette.lightAccent, size: AppSizes.iconSm),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            if (actionLabel != null)
              Flexible(
                child: TextButton(
                  onPressed: onAction,
                  child: Text(actionLabel!, textAlign: TextAlign.end),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);
    final effect = MediaQuery.disableAnimationsOf(context)
        ? SolidColorEffect(color: colors.surfaceAlt)
        : ShimmerEffect(
            baseColor: colors.surfaceAlt,
            highlightColor: scheme.surface,
          );

    return SliverSemantics(
      label: 'Memuat barang',
      sliver: SliverSkeletonizer(
        effect: effect,
        child: SliverItemGrid(
          listings: List.filled(_popularCount, ItemCard.placeholder),
        ),
      ),
    );
  }
}
