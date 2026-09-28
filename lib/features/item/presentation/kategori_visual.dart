import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/kategori.dart';

extension KategoriVisual on Kategori {
  IconData get icon => switch (this) {
        Kategori.kamera => Icons.photo_camera_rounded,
        Kategori.camping => Icons.festival_rounded,
        Kategori.olahraga => Icons.sports_tennis_rounded,
        Kategori.musik => Icons.music_note_rounded,
        Kategori.game => Icons.sports_esports_rounded,
        Kategori.lainnya => Icons.category_rounded,
      };

  Color get tileColor => switch (this) {
        Kategori.kamera => AppPalette.kategoriKamera,
        Kategori.camping => AppPalette.kategoriCamping,
        Kategori.olahraga => AppPalette.kategoriOlahraga,
        Kategori.musik => AppPalette.kategoriMusik,
        Kategori.game => AppPalette.kategoriGame,
        Kategori.lainnya => AppPalette.kategoriLainnya,
      };
}
