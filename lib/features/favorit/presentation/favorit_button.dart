import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_icon_tile_button.dart';
import '../data/favorit_providers.dart';

/// Tombol hati. Hanya tombol ini yang rebuild saat status favorit berubah.
/// [diFoto] = versi kecil di pojok foto ItemCard; selain itu tombol kotak
/// di atas hero Detail Barang.
class FavoritButton extends ConsumerWidget {
  const FavoritButton({
    super.key,
    required this.itemId,
    this.diFoto = false,
    this.enabled = true,
  });

  final String itemId;
  final bool diFoto;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorit = ref.watch(favoritIdsProvider
        .select((v) => v.value?.contains(itemId) ?? false));
    final tooltip = favorit ? 'Hapus dari favorit' : 'Simpan ke favorit';

    void toggle() {
      hapticAksiPenting();
      ref
          .read(favoriteRepositoryProvider)
          .setFavorit(itemId, favorit: !favorit);
    }

    if (!diFoto) {
      return AppIconTileButton(
        key: Key('favorit-$itemId'),
        icon: favorit ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        tooltip: tooltip,
        backgroundColor: AppColors.of(context).heroButton,
        iconColor: favorit ? Theme.of(context).colorScheme.error : null,
        onPressed: enabled ? toggle : null,
      );
    }
    // Bentuk ikon (penuh/garis) yang membedakan status, bukan warna saja.
    return IconButton(
      key: Key('favorit-kartu-$itemId'),
      tooltip: tooltip,
      onPressed: enabled ? toggle : null,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(AppSizes.favoritKartu),
        minimumSize: const Size.square(AppSizes.favoritKartu),
        tapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: AppPalette.scrim,
        foregroundColor: AppPalette.cream,
      ),
      icon: Icon(
        favorit ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: AppSizes.iconXs,
      ),
    );
  }
}
