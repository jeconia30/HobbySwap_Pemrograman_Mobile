import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/guards/require_verified.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_icon_tile_button.dart';
import '../../../core/widgets/app_page_dots.dart';
import '../../../core/widgets/app_sticky_bottom.dart';
import '../../../core/widgets/app_verified_chip.dart';
import '../../../core/widgets/availability_calendar.dart';
import '../../../core/widgets/item_card.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../booking/data/booking_providers.dart';
import '../../booking/domain/booking_rules.dart';
import '../../review/presentation/ulasan_section.dart';
import '../data/item_providers.dart';
import '../domain/item.dart';
import 'kategori_visual.dart';
import '../../../core/constants/app_strings.dart';
import '../../chat/presentation/chat_open.dart';
import '../../favorit/presentation/favorit_button.dart';

/// Jumlah slide foto placeholder selama barang belum punya foto asli.
const _placeholderPhotos = 3;

class ItemDetailPage extends ConsumerStatefulWidget {
  const ItemDetailPage({super.key, required this.itemId, this.preview});

  final String itemId;

  /// Data kartu asal (Beranda) supaya foto hero langsung tampil selama detail
  /// dimuat dan animasi Hero mendarat mulus.
  final ItemListing? preview;

  @override
  ConsumerState<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends ConsumerState<ItemDetailPage> {
  final _calendarKey = GlobalKey();
  DateSelection _selection = DateSelection.empty;

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.beranda);

  void _scrollToCalendar() {
    final ctx = _calendarKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppDurations.page,
      curve: Curves.easeOutCubic,
    );
  }

  void _tawarBarter() => requireVerified(
        context,
        ref,
        onAllowed: () => context.push(AppRoutes.tawarBarter(widget.itemId)),
      );

  void _ajukan() {
    final s = _selection;
    if (!s.isComplete) return;
    requireVerified(
      context,
      ref,
      onAllowed: () =>
          context.push(AppRoutes.ajukanSewa(widget.itemId, s.start!, s.end!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(itemByIdProvider(widget.itemId));

    return switch (async) {
      AsyncData(value: final listing?) => _content(listing),
      AsyncData() => _message(
        icon: Icons.inventory_2_outlined,
        title: 'Barang ini sudah tidak tersedia',
        actionLabel: AppTeks.keBeranda,
        onAction: () => context.go(AppRoutes.beranda),
      ),
      AsyncError() => _message(
        icon: Icons.wifi_off_rounded,
        title: AppTeks.koneksiPutus,
        actionLabel: AppTeks.cobaLagi,
        onAction: () => ref.invalidate(itemByIdProvider(widget.itemId)),
      ),
      _ => _content(widget.preview ?? ItemCard.placeholder, loading: true),
    };
  }

  Widget _message({
    required IconData icon,
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageHome),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: AppBackButton(onPressed: _back),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            AppEmptyState(
              icon: icon,
              title: title,
              actionLabel: actionLabel,
              onAction: onAction,
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(ItemListing listing, {bool loading = false}) {
    final item = listing.item;
    final userId = ref.watch(authControllerProvider)?.id;
    final isOwn = !loading && item.ownerId == userId;
    final blocked = loading
        ? const AsyncValue<List<RentangTanggal>>.loading()
        : ref.watch(blockedDatesProvider(item.id));
    final today = dateOnly(ref.watch(clockProvider)());
    final ranges = blocked.value ?? const <RentangTanggal>[];

    final body = SingleChildScrollView(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: AppSizes.detailHero,
            child: Skeleton.keep(
              keep: !loading || widget.preview != null,
              child: ItemPhotoHero(
                itemId: widget.itemId,
                kategori: listing.item.kategori,
                enabled: !loading || widget.preview != null,
                child: _Hero(listing: listing),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: AppSizes.detailHero - AppSizes.detailSheetOverlap,
            ),
            child: _Sheet(
              listing: listing,
              calendar: KeyedSubtree(
                key: _calendarKey,
                child: blocked.hasError
                    ? AppEmptyState(
                        icon: Icons.event_busy_outlined,
                        title: 'Jadwal belum bisa dimuat.',
                        actionLabel: AppTeks.cobaLagi,
                        onAction: () =>
                            ref.invalidate(blockedDatesProvider(item.id)),
                      )
                    : Skeletonizer(
                        enabled: blocked.isLoading,
                        child: AvailabilityCalendar(
                          today: today,
                          selection: _selection,
                          onChanged: (s) => setState(() => _selection = s),
                          isBlocked: (d) => tanggalTerblokir(d, ranges),
                          validateRange: (s, e) => periksaRentang(
                            mulai: s,
                            kembali: e,
                            hariIni: today,
                            terblokir: ranges,
                          )?.pesan,
                        ),
                      ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  AppIconTileButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: AppTeks.kembali,
                    backgroundColor: AppColors.of(context).heroButton,
                    onPressed: _back,
                  ),
                  const Spacer(),
                  FavoritButton(itemId: widget.itemId, enabled: !loading),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(child: loading ? Skeletonizer(child: body) : body),
            _BottomBar(
              listing: listing,
              selection: _selection,
              isOwn: isOwn,
              enabled: !loading,
              onPickDates: _scrollToCalendar,
              onAjukan: _ajukan,
              onBarter: _tawarBarter,
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatefulWidget {
  const _Hero({required this.listing});

  final ItemListing listing;

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final item = widget.listing.item;
    final count = item.daftarFoto.isEmpty
        ? _placeholderPhotos
        : item.daftarFoto.length;

    return Semantics(
      label: 'Foto ${item.judul}, ${_page + 1} dari $count',
      child: ColoredBox(
        color: item.kategori.tileColor,
        child: Stack(
          children: [
            Positioned(
              right: -AppSizes.detailHeroDecor * 0.25,
              bottom: -AppSizes.detailHeroDecor * 0.2,
              child: Container(
                width: AppSizes.detailHeroDecor,
                height: AppSizes.detailHeroDecor,
                decoration: BoxDecoration(
                  color: AppPalette.brandMid.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            ExcludeSemantics(
              child: PageView.builder(
                itemCount: count,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, _) => Center(
                  child: Icon(
                    item.kategori.icon,
                    color: AppPalette.cream,
                    size: AppSizes.detailHeroIcon,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSizes.detailSheetOverlap + AppSpacing.md,
              child: Center(
                child: ExcludeSemantics(
                  child: AppPageDots(
                    count: count,
                    index: _page,
                    activeColor: AppPalette.cream,
                    inactiveColor: AppPalette.cream.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.listing, required this.calendar});

  final ItemListing listing;
  final Widget calendar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final item = listing.item;
    final owner = listing.owner;
    final muted = text.bodySmall?.copyWith(color: scheme.onSurfaceVariant);

    Widget dot() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.tight),
      child: Text('·', style: muted),
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.detailSheet),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHome,
        AppSpacing.xl,
        AppSpacing.pageHome,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            item.kategori.label.toUpperCase(),
            style: text.labelSmall
                ?.merge(AppTextStyles.kategoriLabel)
                .copyWith(color: colors.accentText),
          ),
          const SizedBox(height: AppSpacing.tight),
          Semantics(
            header: true,
            child: Text(
              item.judul,
              style: text.headlineMedium?.merge(AppTextStyles.detailTitle),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: AppSpacing.xs,
            children: [
              if (owner.jumlahUlasan > 0)
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '★ ${formatRating(owner.rating)}',
                        style: TextStyle(
                          color: colors.warning,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(text: ' (${owner.jumlahUlasan})'),
                    ],
                  ),
                  style: muted,
                )
              else
                Text('Pemilik baru', style: muted),
              dot(),
              Text('Disewa ${item.jumlahDisewa}×', style: muted),
              dot(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: AppSizes.iconXs,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs / 2),
                  Flexible(child: Text(item.lokasiKampus, style: muted)),
                ],
              ),
            ],
          ),
          if (item.bisaBarter) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              key: const Key('detail-barter'),
              children: [
                Icon(Icons.swap_horiz_rounded,
                    size: AppSizes.iconSm, color: colors.accentText),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    teksMinatBarter(item.minatBarter),
                    style: text.bodyMedium?.copyWith(
                        color: colors.accentText, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          _OwnerCard(owner: owner, itemId: item.id),
          const SizedBox(height: AppSpacing.xl),
          Text('Tentang barang ini', style: text.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _ExpandableText(item.deskripsi),
          const SizedBox(height: AppSpacing.xl),
          UlasanSection(itemId: item.id, owner: owner),
          const SizedBox(height: AppSpacing.xl),
          calendar,
        ],
      ),
    );
  }
}

class _OwnerCard extends ConsumerWidget {
  const _OwnerCard({required this.owner, required this.itemId});

  final User owner;
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Barang sendiri: tidak ada lawan untuk diajak ngobrol.
    final sendiri = ref.watch(authControllerProvider)?.id == owner.id;
    final theme = Theme.of(context);
    final verified = owner.statusVerifikasi == StatusVerifikasi.terverifikasi;
    final asal = owner.fakultas ?? 'Kampus USU';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      radius: AppRadius.ownerCard,
      child: Row(
        children: [
          AppAvatar(user: owner, showBadge: false),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(owner.nama, style: theme.textTheme.titleMedium),
                    if (verified) const AppVerifiedChip(),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs / 2),
                Text(
                  '$asal · biasa balas < 1 jam',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!sendiri)
            AppIconTileButton(
              key: const Key('chat-pemilik'),
              icon: Icons.chat_bubble_outline_rounded,
              tooltip: 'Chat ${owner.nama}',
              size: AppSizes.chatButton,
              backgroundColor: AppColors.of(context).surfaceAlt,
              onPressed: () =>
                  bukaObrolan(context, otherUserId: owner.id, itemId: itemId),
            ),
        ],
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText(this.text);

  final String text;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  static const _maxLines = 4;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium
        ?.merge(AppTextStyles.lead)
        .copyWith(color: theme.colorScheme.onSurfaceVariant);

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: _maxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : AppDurations.short,
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                style: style,
                maxLines: _expanded ? null : _maxLines,
                overflow: _expanded ? null : TextOverflow.ellipsis,
              ),
            ),
            if (overflows)
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(_expanded ? 'Lebih sedikit' : 'Selengkapnya'),
              ),
          ],
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.listing,
    required this.selection,
    required this.isOwn,
    required this.enabled,
    required this.onPickDates,
    required this.onAjukan,
    required this.onBarter,
  });

  final ItemListing listing;
  final DateSelection selection;
  final bool isOwn;
  final bool enabled;
  final VoidCallback onPickDates;
  final VoidCallback onAjukan;
  final VoidCallback onBarter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final harga = listing.item.hargaPerHari;
    final inset = MediaQuery.paddingOf(context).bottom;
    // Tombol barter hanya untuk barang orang lain yang menerima barter.
    final bisaBarter = listing.item.bisaBarter &&
        !isOwn &&
        listing.status != ItemStatus.nonaktif;

    final Widget info;
    final Widget button;
    if (selection.isComplete) {
      final hari = hitungHari(selection.start!, selection.end!);
      final total = hitungTotal(harga, selection.start!, selection.end!);
      info = Column(
        key: const Key('detail-summary'),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$hari hari × ${formatRupiah(harga)}',
            style: text.bodySmall
                ?.merge(AppTextStyles.small)
                .copyWith(color: scheme.onSurfaceVariant),
          ),
          Text(
            formatRupiah(total),
            style: text.titleLarge?.merge(AppTextStyles.totalBig),
          ),
        ],
      );
    } else {
      final denda = listing.item.dendaPerHari;
      info = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: formatRupiah(harga),
                  style:
                      AppTextStyles.price.copyWith(color: colors.accentText),
                ),
                TextSpan(
                  text: '/hari',
                  style: AppTextStyles.priceUnit.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            style: text.bodyMedium,
          ),
          Text(
            teksDenda(denda),
            key: const Key('detail-denda'),
            style: text.bodySmall
                ?.merge(AppTextStyles.small)
                .copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      );
    }

    if (isOwn) {
      button = const AppButton(label: 'Ini barangmu', onPressed: null);
    } else if (listing.status == ItemStatus.nonaktif) {
      button = const AppButton(label: 'Tidak disewakan', onPressed: null);
    } else if (selection.isComplete) {
      button = AppButton(
        key: const Key('detail-ajukan'),
        label: 'Ajukan Sewa',
        onPressed: enabled ? onAjukan : null,
      );
    } else {
      button = AppButton(
        key: const Key('detail-pilih-tanggal'),
        label: 'Pilih tanggal',
        onPressed: enabled ? onPickDates : null,
      );
    }

    return AppStickyBottom(
      color: scheme.surface,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHome,
        AppSpacing.detailBarTop,
        AppSpacing.pageHome,
        math.max(AppSpacing.detailBarBottom, inset + AppSpacing.md),
      ),
      children: [
        if (bisaBarter) ...[
          info,
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  key: const Key('detail-tawar-barter'),
                  label: 'Tawarkan barter',
                  variant: AppButtonVariant.outline,
                  icon: const Icon(Icons.swap_horiz_rounded),
                  onPressed: enabled ? onBarter : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: button),
            ],
          ),
        ] else
          Row(
            children: [
              Expanded(child: info),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: button),
            ],
          ),
      ],
    );
  }
}
