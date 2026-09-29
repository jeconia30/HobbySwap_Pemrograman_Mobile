import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hobby_swab/core/theme/app_colors.dart';
import 'package:hobby_swab/core/theme/app_theme.dart';
import 'package:hobby_swab/core/theme/avatar_colors.dart';
import 'package:hobby_swab/features/auth/domain/user.dart';
import 'package:hobby_swab/features/item/domain/kategori.dart';
import 'package:hobby_swab/features/item/presentation/kategori_visual.dart';

/// Rasio kontras WCAG 2.1.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Warna tint (mis. latar badge 16–20%) di atas [bg].
Color tint(Color c, double alpha, Color bg) =>
    Color.alphaBlend(c.withValues(alpha: alpha), bg);

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  const minimum = 4.5;

  for (final (nama, theme) in [
    ('terang', AppTheme.light()),
    ('gelap', AppTheme.dark()),
  ]) {
    group('kontras mode $nama', () {
      final s = theme.colorScheme;
      final c = theme.extension<AppColors>()!;
      final bg = theme.scaffoldBackgroundColor;
      final latar = {'bg': bg, 'surface': s.surface, 'surfaceAlt': c.surfaceAlt};

      void cek(String label, Color fg, Color bgColor) {
        test(label, () {
          expect(contrast(fg, bgColor), greaterThanOrEqualTo(minimum),
              reason: '$label = ${contrast(fg, bgColor).toStringAsFixed(2)}');
        });
      }

      for (final MapEntry(key: n, value: b) in latar.entries) {
        cek('teks utama di $n', s.onSurface, b);
        cek('teks sekunder di $n', s.onSurfaceVariant, b);
        cek('teks aksen di $n', c.accentText, b);
      }
      for (final b in [bg, s.surface]) {
        final n = b == bg ? 'bg' : 'surface';
        cek('error di $n', s.error, b);
        cek('peringatan di $n', c.warning, b);
        cek('terverifikasi di $n', c.verified, b);
        // Badge status: label berwarna di atas tint warna yang sama (16%, lihat StatusBadge).
        cek('badge menunggu di $n', c.warning, tint(c.warning, 0.16, b));
        cek('badge disetujui di $n', c.accentText, tint(c.accentText, 0.16, b));
        cek('badge selesai di $n', c.verified, tint(c.verified, 0.16, b));
        cek('badge ditolak di $n', s.error, tint(s.error, 0.16, b));
      }
      cek('teks di tombol primer', s.onPrimary, s.primary);
      cek('teks di tombol danger', s.onError, s.error);
      cek('chip aktif', s.onPrimary, s.primary);
      cek('chip nonaktif', s.onSurfaceVariant, s.surface);
      cek('chip terverifikasi', c.verified, c.accentSoft);
      cek('teks aksen di accentSoft', c.accentText, c.accentSoft);
      cek('status Nonaktif', s.onSurfaceVariant, c.surfaceAlt);
    });
  }

  group('tile tetap (sama di kedua mode)', () {
    for (final k in Kategori.values) {
      test('krem di tile kategori ${k.name}', () {
        expect(contrast(AppPalette.cream, k.tileColor),
            greaterThanOrEqualTo(minimum));
      });
    }
    for (final w in WarnaAvatar.values) {
      test('inisial krem di avatar ${w.name}', () {
        expect(contrast(AppPalette.cream, w.color),
            greaterThanOrEqualTo(minimum));
      });
    }
    test('teks Splash', () {
      expect(contrast(AppPalette.splashSubtitle, AppPalette.splashBg),
          greaterThanOrEqualTo(minimum));
    });
  });
}
