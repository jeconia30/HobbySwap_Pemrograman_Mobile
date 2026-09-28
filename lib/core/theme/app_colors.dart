import 'package:flutter/material.dart';

/// Token warna DESIGN.md §2.1. Satu-satunya tempat nilai hex boleh ditulis.
abstract final class AppPalette {
  static const lightBg = Color(0xFFF2EFE6);
  static const lightSurface = Color(0xFFFBFAF5);
  static const lightSurfaceAlt = Color(0xFFE9E4D6);
  static const lightBorder = Color(0xFFDED8C7);
  static const lightTextPrimary = Color(0xFF1A2C24);
  static const lightTextSecondary = Color(0xFF5F6D62);
  static const lightAccent = Color(0xFF1E4638);
  static const lightOnAccent = Color(0xFFF4F1E8);
  static const lightAccentText = Color(0xFF1E4638);
  static const lightAccentSoft = Color(0xFFDDE7D5);
  static const lightVerified = Color(0xFF4E8C43);
  static const lightWarning = Color(0xFFB4832A);
  static const lightError = Color(0xFFC24A32);

  static const darkBg = Color(0xFF12211B);
  static const darkSurface = Color(0xFF1B2E26);
  static const darkSurfaceAlt = Color(0xFF254034);
  static const darkBorder = Color(0xFF2E4739);
  static const darkTextPrimary = Color(0xFFEEF2E9);
  static const darkTextSecondary = Color(0xFF9DB0A4);
  static const darkAccent = brandMid;
  static const darkOnAccent = Color(0xFF0F221A);
  static const darkAccentText = Color(0xFF8FBE86);
  static const darkAccentSoft = Color(0xFF22392E);
  static const darkVerified = Color(0xFF7FBF6E);
  static const darkWarning = Color(0xFFE5B860);
  static const darkError = Color(0xFFE8836F);

  /// Hijau daun pada huruf "S" logo; sama di kedua mode.
  static const brandLeaf = Color(0xFF8FBE86);

  /// Hijau sedang logo; warna ilustratif/sekunder.
  static const brandMid = Color(0xFF6B9E63);

  /// Splash: sama di mode terang & gelap.
  static const splashBg = darkBg;
  static const splashDecorDeep = lightAccent;
  static const splashDecorMid = brandMid;
  static const splashTitle = lightOnAccent;
  static const splashSubtitle = darkTextSecondary;
  static const splashDotInactive = Color(0xFF3C5A4B);

  /// Warna tile foto per kategori (sama di kedua mode).
  static const kategoriKamera = Color(0xFF2E5A47);
  static const kategoriCamping = brandMid;
  static const kategoriOlahraga = Color(0xFF7D7148);
  static const kategoriMusik = Color(0xFF8A6A3E);
  static const kategoriGame = Color(0xFF3F6A7A);
  static const kategoriLainnya = Color(0xFF7E8A80);

  /// Krem untuk ikon/teks di atas tile gelap.
  static const cream = lightBg;

  /// Hitam transparan 55% untuk chip di atas foto.
  static const scrim = Color(0x8C000000);

  /// Latar tombol di atas foto hero: krem 94% (terang) / bg gelap 82% (gelap).
  static const heroButtonLight = Color(0xF0F2EFE6);
  static const heroButtonDark = Color(0xD112211B);

  /// Kartu statistik Barang Saya (warna brand tetap di kedua mode).
  static const statsLabel = Color(0xFFA9C2B1);
  static const statsStar = darkWarning;
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surfaceAlt,
    required this.border,
    required this.accentSoft,
    required this.accentText,
    required this.accentMid,
    required this.verified,
    required this.warning,
    required this.brandLeaf,
    required this.heroButton,
  });

  final Color surfaceAlt;
  final Color border;
  final Color accentSoft;
  final Color accentText;

  /// Hijau sedang untuk ilustrasi; di dark dibuat lebih terang agar beda dari accent.
  final Color accentMid;
  final Color verified;
  final Color warning;
  final Color brandLeaf;

  /// Latar tombol bulat/kotak yang melayang di atas foto hero.
  final Color heroButton;

  static const light = AppColors(
    surfaceAlt: AppPalette.lightSurfaceAlt,
    border: AppPalette.lightBorder,
    accentSoft: AppPalette.lightAccentSoft,
    accentText: AppPalette.lightAccentText,
    accentMid: AppPalette.brandMid,
    verified: AppPalette.lightVerified,
    warning: AppPalette.lightWarning,
    brandLeaf: AppPalette.brandLeaf,
    heroButton: AppPalette.heroButtonLight,
  );

  static const dark = AppColors(
    surfaceAlt: AppPalette.darkSurfaceAlt,
    border: AppPalette.darkBorder,
    accentSoft: AppPalette.darkAccentSoft,
    accentText: AppPalette.darkAccentText,
    accentMid: AppPalette.darkAccentText,
    verified: AppPalette.darkVerified,
    warning: AppPalette.darkWarning,
    brandLeaf: AppPalette.brandLeaf,
    heroButton: AppPalette.heroButtonDark,
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? surfaceAlt,
    Color? border,
    Color? accentSoft,
    Color? accentText,
    Color? accentMid,
    Color? verified,
    Color? warning,
    Color? brandLeaf,
    Color? heroButton,
  }) {
    return AppColors(
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      accentSoft: accentSoft ?? this.accentSoft,
      accentText: accentText ?? this.accentText,
      accentMid: accentMid ?? this.accentMid,
      verified: verified ?? this.verified,
      warning: warning ?? this.warning,
      brandLeaf: brandLeaf ?? this.brandLeaf,
      heroButton: heroButton ?? this.heroButton,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      accentMid: Color.lerp(accentMid, other.accentMid, t)!,
      verified: Color.lerp(verified, other.verified, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      brandLeaf: Color.lerp(brandLeaf, other.brandLeaf, t)!,
      heroButton: Color.lerp(heroButton, other.heroButton, t)!,
    );
  }
}
