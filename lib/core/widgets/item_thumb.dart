import 'package:flutter/material.dart';

import '../../features/item/domain/kategori.dart';
import '../../features/item/presentation/kategori_visual.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Tile kecil barang (warna kategori + ikon krem) sebagai pengganti foto.
class ItemThumb extends StatelessWidget {
  const ItemThumb({
    super.key,
    required this.kategori,
    this.size = AppSizes.iconTile,
    this.radius = AppRadius.input,
  });

  final Kategori kategori;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: kategori.tileColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Icon(kategori.icon, color: AppPalette.cream, size: size * 0.5),
      ),
    );
  }
}
