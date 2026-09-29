import 'package:flutter/material.dart';

import '../../features/auth/domain/user.dart';
import '../theme/app_colors.dart';
import '../theme/avatar_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/formatters.dart';

/// Avatar inisial krem di atas warna pilihan user; badge centang `verified`\n/// bila akun terverifikasi.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.user,
    this.size = AppSizes.avatar,
    this.onTap,
    this.showBadge = true,
  });

  final User user;
  final double size;
  final VoidCallback? onTap;

  /// Matikan bila status terverifikasi sudah ditampilkan di dekatnya.
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final verified = user.statusVerifikasi == StatusVerifikasi.terverifikasi;
    final badge = size * 0.34;

    final avatar = SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: user.warnaAvatar.color,
              shape: BoxShape.circle,
            ),
            child: Text(
              initials(user.nama),
              textScaler: TextScaler.noScaling,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppPalette.cream,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.34,
              ),
            ),
          ),
          if (verified && showBadge)
            Positioned(
              right: -AppSpacing.xs / 2,
              bottom: -AppSpacing.xs / 2,
              child: Container(
                width: badge,
                height: badge,
                decoration: BoxDecoration(
                  color: colors.verified,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: AppSizes.dashedStroke),
                ),
                child: Icon(Icons.check_rounded,
                    size: badge * 0.7, color: theme.colorScheme.surface),
              ),
            ),
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      label: 'Profil ${user.nama}${verified ? ', terverifikasi' : ''}',
      child: ExcludeSemantics(
        child: onTap == null
            ? avatar
            : InkResponse(
                onTap: onTap,
                radius: AppSizes.minTapTarget / 2,
                child: SizedBox.square(
                  dimension: AppSizes.minTapTarget,
                  child: Center(child: avatar),
                ),
              ),
      ),
    );
  }
}
