import 'package:flutter/material.dart';

import '../../features/auth/domain/user.dart';
import 'app_colors.dart';

extension WarnaAvatarColor on WarnaAvatar {
  Color get color => switch (this) {
        WarnaAvatar.hijau => AppPalette.avatarHijau,
        WarnaAvatar.pinus => AppPalette.avatarPinus,
        WarnaAvatar.biru => AppPalette.avatarBiru,
        WarnaAvatar.ungu => AppPalette.avatarUngu,
        WarnaAvatar.coklat => AppPalette.avatarCoklat,
        WarnaAvatar.bata => AppPalette.avatarBata,
      };

  String get label => switch (this) {
        WarnaAvatar.hijau => 'Hijau tua',
        WarnaAvatar.pinus => 'Hijau pinus',
        WarnaAvatar.biru => 'Biru laut',
        WarnaAvatar.ungu => 'Ungu',
        WarnaAvatar.coklat => 'Cokelat',
        WarnaAvatar.bata => 'Merah bata',
      };
}
