import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Pratinjau simulasi (UI-first): digambar dengan widget, bukan foto asli.
/// Ukuran mengikuti induk (slot memberi 96×64); geometri berupa pecahan.

class KtmPreviewArt extends StatelessWidget {
  const KtmPreviewArt({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);

    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;
      Widget line(double width) => Container(
            width: w * width,
            height: h * 0.08,
            margin: EdgeInsets.only(bottom: h * 0.09),
            decoration: const BoxDecoration(
              color: AppPalette.lightBg,
              borderRadius: AppRadius.pillAll,
            ),
          );

      return ColoredBox(
        color: scheme.primary,
        child: Padding(
          padding: EdgeInsets.all(h * 0.14),
          child: Row(
            children: [
              Container(
                width: w * 0.26,
                decoration: BoxDecoration(
                  color: colors.accentMid,
                  borderRadius: BorderRadius.circular(h * 0.08),
                ),
              ),
              SizedBox(width: w * 0.08),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [line(0.4), line(0.32), line(0.22)],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class SelfiePreviewArt extends StatelessWidget {
  const SelfiePreviewArt({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);

    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;
      final head = h * 0.34;

      return ColoredBox(
        color: colors.accentSoft,
        child: Stack(
          children: [
            Positioned(
              left: w * 0.2,
              bottom: -h * 0.18,
              child: Container(
                width: w * 0.42,
                height: h * 0.5,
                decoration: BoxDecoration(
                  color: colors.accentMid,
                  borderRadius: BorderRadius.circular(w * 0.2),
                ),
              ),
            ),
            Positioned(
              left: w * 0.41 - head / 2,
              top: h * 0.14,
              child: Container(
                width: head,
                height: head,
                decoration: BoxDecoration(
                    color: colors.accentMid, shape: BoxShape.circle),
              ),
            ),
            Positioned(
              right: w * 0.1,
              top: h * 0.38,
              child: Transform.rotate(
                angle: -0.12,
                child: Container(
                  width: w * 0.32,
                  height: h * 0.34,
                  padding: EdgeInsets.all(h * 0.05),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(h * 0.06),
                  ),
                  child: Row(
                    children: [
                      Container(width: w * 0.08, color: colors.accentMid),
                      SizedBox(width: w * 0.03),
                      Expanded(
                        child: Container(
                          height: h * 0.05,
                          color: AppPalette.lightBg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
