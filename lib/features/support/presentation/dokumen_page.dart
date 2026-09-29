import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_press_scale.dart';
import '../domain/dokumen_hukum.dart';

/// /syarat & /privasi — dokumen panjang yang nyaman dibaca: daftar isi yang
/// bisa ditekan, subjudul bernomor, baris ±65 karakter, line-height 1.6.
class DokumenPage extends StatefulWidget {
  const DokumenPage({super.key, required this.dokumen});

  final DokumenHukum dokumen;

  @override
  State<DokumenPage> createState() => _DokumenPageState();
}

class _DokumenPageState extends State<DokumenPage> {
  late final _kunci = [
    for (final _ in widget.dokumen.bagian) GlobalKey(),
  ];

  void _lompat(int i) {
    final ctx = _kunci[i].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppDurations.page,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final d = widget.dokumen;
    final paragraf = text.bodyLarge?.merge(AppTextStyles.dokumen);

    return Scaffold(
      body: SafeArea(
        // Isi dokumen pendek (±20 blok) dan harus bisa dilompati lewat
        // daftar isi, jadi dibangun sekaligus dalam satu kolom.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome,
              AppSpacing.md, AppSpacing.pageHome, AppSpacing.xxl),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppSizes.lebarBacaan),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go(AppRoutes.login),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    key: const Key('banner-draf'),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(alpha: 0.16),
                      borderRadius: AppRadius.noteAll,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit_note_rounded,
                            color: colors.warning, size: AppSizes.iconSm),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Draf — belum ditinjau ahli hukum',
                            style: text.labelMedium
                                ?.copyWith(color: colors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Semantics(
                    header: true,
                    child: Text(d.judul, style: text.headlineMedium),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Berlaku sejak ${formatTanggalPanjang(d.berlakuSejak)}',
                    style: text.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Daftar isi', style: text.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  for (final (i, b) in d.bagian.indexed)
                    AppPressScale(
                      child: InkWell(
                        key: Key('isi-$i'),
                        onTap: () => _lompat(i),
                        borderRadius: AppRadius.inputAll,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              minHeight: AppSizes.minTapTarget),
                          child: Row(
                            children: [
                              SizedBox(
                                width: AppSizes.nomorBagian,
                                child: Text('${i + 1}.',
                                    style: text.bodyMedium?.copyWith(
                                        color: colors.accentText,
                                        fontWeight: FontWeight.w700)),
                              ),
                              Expanded(
                                child: Text(b.judul,
                                    style: text.bodyMedium?.copyWith(
                                        color: colors.accentText)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  for (final (i, b) in d.bagian.indexed) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Semantics(
                      header: true,
                      child: Text(
                        '${i + 1}. ${b.judul}',
                        key: _kunci[i],
                        style: text.titleLarge,
                      ),
                    ),
                    for (final p in b.paragraf) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(p, style: paragraf),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
