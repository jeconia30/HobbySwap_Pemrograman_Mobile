import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_press_scale.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/item_card.dart';
import '../../../core/widgets/item_thumb.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/chat_providers.dart';
import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';
import '../domain/chat_thread.dart';
import 'chat_open.dart';

/// /pesan — kotak masuk semua obrolan user yang sedang masuk.
class PesanPage extends ConsumerStatefulWidget {
  const PesanPage({super.key});

  @override
  ConsumerState<PesanPage> createState() => _PesanPageState();
}

class _PesanPageState extends ConsumerState<PesanPage> {
  final _cari = TextEditingController();
  String _kata = '';

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.beranda);

  Future<bool> _toggleBisu(ChatThreadView v) async {
    final bisu = !v.dibisukan;
    await ref
        .read(chatRepositoryProvider)
        .setMuted(v.id, v.viewerId, muted: bisu);
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              bisu
                  ? 'Obrolan dengan ${v.lawan.nama} dibisukan'
                  : 'Obrolan dengan ${v.lawan.nama} dibunyikan lagi',
            ),
          ),
        );
    }
    // Baris tidak dihapus, hanya status bisunya yang berubah.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final async = ref.watch(chatThreadsProvider);
    final today = dateOnly(ref.watch(clockProvider)());
    final kata = _kata.trim().toLowerCase();
    final semua = async.value ?? const <ChatThreadView>[];
    final list = kata.isEmpty
        ? semua
        : [
            for (final v in semua)
              if (v.lawan.nama.toLowerCase().contains(kata) ||
                  v.item.judul.toLowerCase().contains(kata))
                v,
          ];

    final Widget? body;
    if (async.hasError && !async.hasValue) {
      body = AppEmptyState(
        icon: Icons.wifi_off_rounded,
        title: AppTeks.koneksiPutus,
        actionLabel: AppTeks.cobaLagi,
        onAction: () => ref.invalidate(chatThreadsProvider),
      );
    } else if (!async.hasValue) {
      body = Skeletonizer(
        child: Column(
          children: [
            for (var i = 0; i < 4; i++)
              _ThreadRow(view: _placeholder, today: today, onTap: () {}),
          ],
        ),
      );
    } else if (semua.isEmpty) {
      body = const Padding(
        padding: EdgeInsets.only(top: AppSpacing.xxl),
        child: AppEmptyState(
          icon: Icons.forum_outlined,
          title: 'Belum ada pesan.',
          message: 'Obrolan dengan pemilik atau penyewa akan muncul di sini.',
        ),
      );
    } else if (list.isEmpty) {
      body = const Padding(
        padding: EdgeInsets.only(top: AppSpacing.xxl),
        child: AppEmptyState(
          icon: Icons.search_off_rounded,
          title: 'Tidak ada obrolan yang cocok.',
          message: 'Coba cari nama lain atau nama barang.',
        ),
      );
    } else {
      body = null;
    }

    final kepala = <Widget>[
      Row(
        children: [
          AppBackButton(onPressed: _back),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Semantics(
              header: true,
              child: Text('Pesan', style: theme.textTheme.headlineMedium),
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
      AppSearchField(
        fieldKey: const Key('pesan-cari'),
        controller: _cari,
        hint: 'Cari nama atau barang',
        onChanged: (v) => setState(() => _kata = v),
        onClear: () => setState(() {
          _cari.clear();
          _kata = '';
        }),
      ),
      const SizedBox(height: AppSpacing.sm),
    ];

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(chatThreadsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHome,
              AppSpacing.md,
              AppSpacing.pageHome,
              AppSpacing.xxl,
            ),
            itemCount: kepala.length + (body == null ? list.length : 1),
            itemBuilder: (context, i) {
              if (i < kepala.length) return kepala[i];
              if (body != null) return body;
              final v = list[i - kepala.length];
              return _SwipeBisu(
                view: v,
                onSwipe: () => _toggleBisu(v),
                child: _ThreadRow(
                  view: v,
                  today: today,
                  onTap: () => context.push(AppRoutes.pesanThread(v.id)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

final _placeholder = ChatThreadView(
  thread: ChatThread(
    id: 'skeleton',
    participantIds: const ['a', 'b'],
    itemId: ItemCard.placeholder.item.id,
    lastMessageAt: DateTime(2026),
  ),
  viewerId: 'a',
  lawan: ItemCard.placeholder.owner.copyWith(nama: 'Nama Pengguna'),
  item: ItemCard.placeholder.item,
  terakhir: ChatMessage(
    id: 'skeleton',
    threadId: 'skeleton',
    senderId: 'b',
    tipe: TipePesan.teks,
    isi: 'Memuat pesan terakhir dari obrolan',
    sentAt: DateTime(2026),
  ),
);

/// Geser ke kiri untuk membisukan / membunyikan obrolan.
class _SwipeBisu extends StatelessWidget {
  const _SwipeBisu({
    required this.view,
    required this.onSwipe,
    required this.child,
  });

  final ChatThreadView view;
  final Future<bool> Function() onSwipe;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final label = view.dibisukan ? 'Bunyikan' : 'Bisukan';
    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: label): () => onSwipe(),
      },
      child: Dismissible(
        key: ValueKey('thread-${view.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => onSwipe(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          color: colors.accentSoft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                view.dibisukan
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                color: colors.accentText,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: colors.accentText),
              ),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}

class _ThreadRow extends StatelessWidget {
  const _ThreadRow({
    required this.view,
    required this.today,
    required this.onTap,
  });

  final ChatThreadView view;
  final DateTime today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final unread = view.unread;
    final tebal = unread > 0;
    final terakhir = view.terakhir;
    final pratinjau = terakhir == null
        ? 'Mulai obrolan tentang ${view.item.judul}'
        : pratinjauPesan(terakhir, view.viewerId);
    final waktu = formatWaktuRelatif(view.thread.lastMessageAt, today);
    final booking = view.booking;

    final row = Semantics(
      button: true,
      label:
          '${view.lawan.nama}, ${view.item.judul}. '
          '${unread > 0 ? '$unread pesan belum dibaca. ' : ''}'
          '${view.dibisukan ? 'Dibisukan. ' : ''}$pratinjau. $waktu',
      excludeSemantics: true,
      child: InkWell(
        key: Key('thread-row-${view.id}'),
        onTap: onTap,
        borderRadius: AppRadius.inputAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.chatRow),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                AppAvatar(user: view.lawan, size: AppSizes.avatarChat),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    view.lawan.nama,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.titleMedium?.merge(
                                      AppTextStyles.chatName,
                                    ),
                                  ),
                                ),
                                if (view.dibisukan) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  Icon(
                                    Icons.notifications_off_outlined,
                                    key: Key('bisu-${view.id}'),
                                    size: AppSizes.iconXs,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // Waktu rata kanan; di font besar terbungkus, bukan overflow.
                          Expanded(
                            flex: 2,
                            child: Text(
                              waktu,
                              textAlign: TextAlign.end,
                              style: text.bodySmall
                                  ?.merge(AppTextStyles.chatMeta)
                                  .copyWith(
                                    color: tebal
                                        ? AppColors.of(context).accentText
                                        : scheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs / 2),
                      Row(
                        children: [
                          ItemThumb(
                            kategori: view.item.kategori,
                            size: AppSizes.chatMiniTile,
                            radius: AppRadius.bubbleTail,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              view.item.judul,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (booking != null) ...[
                            const SizedBox(width: AppSpacing.xs),
                            // Flexible: badge mengecil (FittedBox) di layar sempit.
                            Flexible(
                              child: StatusBadge(booking.status, compact: true),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs / 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pratinjau,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall
                                  ?.merge(AppTextStyles.chatPreview)
                                  .copyWith(
                                    color: tebal
                                        ? scheme.onSurface
                                        : scheme.onSurfaceVariant,
                                    fontWeight: tebal
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    fontStyle: terakhir?.sistem ?? false
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                            ),
                          ),
                          if (unread > 0) ...[
                            const SizedBox(width: AppSpacing.sm),
                            _UnreadBadge(unread, key: Key('unread-${view.id}')),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return AppPressScale(child: row);
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge(this.count, {super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(
        minWidth: AppSizes.chatUnreadBadge,
        minHeight: AppSizes.chatUnreadBadge,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.tight),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w800),
      ),
    );
  }
}
