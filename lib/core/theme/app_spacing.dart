import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Jarak antarkelompok konten di layar auth (di luar skala dasar).
  static const double group = 28;
  static const double pageHorizontal = 24;
  static const double pageTop = 40;

  /// Padding samping Beranda & tab utama.
  static const double pageHome = 20;

  /// Jarak rapat antarbaris di kartu barang.
  static const double tight = 6;
  static const EdgeInsets itemCardInfo = EdgeInsets.fromLTRB(12, 11, 12, 13);

  /// Bar bawah menempel di Detail: atas 14, samping 20, bawah minimal 32.
  static const double detailBarTop = 14;
  static const double detailBarBottom = 32;

  /// Padding kartu ringkas (slot unggah terisi, kartu sewa).
  static const double cardCompact = 14;

  /// Padding samping layar rating.
  static const double pageRating = 24;

  /// Jarak konten bawah Splash dari tepi layar.
  static const double splashBottom = 64;
}

abstract final class AppRadius {
  static const double card = 20;
  static const double button = 16;
  static const double input = 14;
  static const double sheet = 28;
  static const double logoMark = 17;
  static const double logoMarkLarge = 32;
  static const double checkbox = 6;
  static const double note = 16;
  static const double preview = 12;
  static const double filterButton = 11;
  static const double calendarCell = 12;
  static const double ownerCard = 18;
  static const double listRow = 18;
  static const double detailSheet = 26;
  static const double pill = 999;

  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius noteAll = BorderRadius.all(Radius.circular(note));
  static const BorderRadius previewAll =
      BorderRadius.all(Radius.circular(preview));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius sheetTop =
      BorderRadius.vertical(top: Radius.circular(sheet));
  static const BorderRadius buttonAll =
      BorderRadius.all(Radius.circular(button));
  static const BorderRadius inputAll = BorderRadius.all(Radius.circular(input));
}

abstract final class AppSizes {
  static const double buttonHeight = 56;
  static const double fieldHeight = 54;
  static const double minTapTarget = 48;
  static const double logoMark = 56;
  static const double logoMarkLarge = 112;

  /// Indikator halaman: titik [pageDot] & pill aktif [pageDotActive] lebar.
  static const double pageDot = 8;
  static const double pageDotActive = 26;
  static const double splashDot = 7;
  static const double splashDotActive = 22;

  /// Lingkaran dekoratif Splash.
  static const double splashDecorLarge = 520;
  static const double splashDecorSmall = 380;

  /// Kotak visual tombol kembali; area sentuhnya tetap [minTapTarget].
  static const double backButton = 44;
  static const double progressBar = 6;
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 28;

  /// Tile ikon (slot unggah kosong, bottom sheet).
  static const double iconTile = 56;

  /// Pratinjau dokumen di slot unggah.
  static const double previewWidth = 96;
  static const double previewHeight = 64;
  static const double dashedStroke = 2;

  /// Shell: tinggi bar termasuk safe area, FAB, dan jarak FAB naik di atas bar.
  static const double bottomNav = 86;
  static const double bottomNavMinContent = 60;
  static const double fab = 58;
  static const double fabLift = 26;

  /// Beranda.
  static const double tileButton = 44;
  static const double avatar = 44;
  static const double searchField = 52;
  static const double filterButton = 38;
  static const double chip = 38;
  static const double itemPhoto = 112;
  static const double itemPhotoIcon = 44;
  static const double emptyArt = 88;
  static const double promoDecor = 150;

  /// Detail barang.
  static const double detailHero = 300;
  static const double detailHeroIcon = 120;
  static const double detailHeroDecor = 240;
  static const double detailSheetOverlap = 22;
  static const double chatButton = 42;

  /// Barang Saya.
  static const double countBox = 40;

  /// Sewaan Saya, checklist, rating.
  static const double bookingTile = 60;
  static const double chatButtonLg = 46;
  static const double progressThick = 7;
  static const double checklistRow = 56;
  static const double checkbox = 22;
  static const double fotoSlot = 44;
  static const double ratingTile = 52;
  static const double starArea = 52;
  static const double starIcon = 44;
  static const double avatarSm = 32;
  static const double avatarReview = 36;
  static const double calendarCell = 40;

  /// Ilustrasi layar status.
  static const double statusArt = 104;
  static const double timelineMarker = 24;
  static const double spinner = 20;
}

abstract final class AppDurations {
  static const Duration press = Duration(milliseconds: 120);
  static const Duration short = Duration(milliseconds: 200);
  static const Duration page = Duration(milliseconds: 300);
  static const Duration splashMinimum = Duration(milliseconds: 1200);
}
