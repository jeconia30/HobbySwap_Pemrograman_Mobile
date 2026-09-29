import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_info_note.dart';
import '../../../core/widgets/app_step_header.dart';
import '../../../core/widgets/app_sticky_bottom.dart';
import '../../../core/widgets/app_upload_slot.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/verification_repository.dart';
import 'verification_actions.dart';
import 'verification_previews.dart';
import '../../../core/constants/app_strings.dart';

enum _Slot { ktm, selfie }

enum _SheetChoice { camera, gallery, remove }

class VerifikasiPage extends ConsumerStatefulWidget {
  const VerifikasiPage({super.key});

  @override
  ConsumerState<VerifikasiPage> createState() => _VerifikasiPageState();
}

class _VerifikasiPageState extends ConsumerState<VerifikasiPage> {
  VerificationPhoto? _ktm;
  VerificationPhoto? _selfie;
  bool _submitting = false;
  String? _errorMessage;

  bool get _complete => _ktm != null && _selfie != null;

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.beranda);

  Future<void> _pick(_Slot slot) async {
    final filled = (slot == _Slot.ktm ? _ktm : _selfie) != null;
    final choice = await showAppBottomSheet<_SheetChoice>(
      context,
      builder: (sheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetTitle(slot == _Slot.ktm ? 'Foto KTM' : 'Selfie dengan KTM'),
          AppSheetAction(
            icon: Icons.photo_camera_outlined,
            label: 'Ambil foto',
            onTap: () => Navigator.pop(sheet, _SheetChoice.camera),
          ),
          AppSheetAction(
            icon: Icons.photo_library_outlined,
            label: 'Pilih dari galeri',
            onTap: () => Navigator.pop(sheet, _SheetChoice.gallery),
          ),
          if (filled)
            AppSheetAction(
              icon: Icons.delete_outline_rounded,
              label: 'Hapus foto',
              destructive: true,
              onTap: () => Navigator.pop(sheet, _SheetChoice.remove),
            ),
        ],
      ),
    );
    if (choice == null || !mounted) return;

    // UI-first: kamera/galeri belum dipakai; slot langsung diisi pratinjau simulasi.
    final photo = switch (choice) {
      _SheetChoice.camera => const VerificationPhoto(source: PhotoSource.camera),
      _SheetChoice.gallery =>
        const VerificationPhoto(source: PhotoSource.gallery),
      _SheetChoice.remove => null,
    };
    setState(() {
      if (slot == _Slot.ktm) {
        _ktm = photo;
      } else {
        _selfie = photo;
      }
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    final ktm = _ktm;
    final selfie = _selfie;
    if (_submitting || ktm == null || selfie == null) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(verificationActionsProvider).submit(ktm, selfie);
      if (!mounted) return;
      context.go(AppRoutes.verifikasiStatus);
    } on VerificationException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = AppTeks.koneksiPutus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final user = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.md,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppStepHeader(
                      current: 2,
                      total: 3,
                      onBack: _submitting ? null : _back,
                    ),
                    const SizedBox(height: AppSpacing.group),
                    Semantics(
                      header: true,
                      child:
                          Text('Verifikasi KTM kamu', style: text.headlineMedium),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Biar semua yang sewa-menyewa di HobbySwap benar-benar '
                      'mahasiswa. Datamu hanya dilihat tim peninjau.',
                      style: text.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    if (user != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _AccountLine(user: user),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AppUploadSlot(
                      key: const Key('slot-ktm'),
                      icon: Icons.badge_outlined,
                      emptyTitle: 'Unggah foto KTM',
                      emptySubtitle: 'Foto bagian depan, semua tulisan terbaca',
                      filledTitle: 'Foto KTM',
                      filledStatus: 'Terunggah · jelas terbaca',
                      preview: _ktm == null ? null : const KtmPreviewArt(),
                      enabled: !_submitting,
                      onTap: () => _pick(_Slot.ktm),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppUploadSlot(
                      key: const Key('slot-selfie'),
                      icon: Icons.face_retouching_natural_outlined,
                      emptyTitle: 'Ambil selfie sambil pegang KTM',
                      emptySubtitle: 'Pastikan wajah dan KTM terlihat jelas, '
                          'tanpa masker atau kacamata hitam.',
                      filledTitle: 'Selfie dengan KTM',
                      filledStatus: 'Terunggah · wajah & KTM jelas',
                      preview: _selfie == null ? null : const SelfiePreviewArt(),
                      enabled: !_submitting,
                      onTap: () => _pick(_Slot.selfie),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const AppInfoNote(
                      icon: Icons.shield_outlined,
                      message: 'Peninjauan biasanya selesai kurang dari 1×24 '
                          'jam. Sambil menunggu, kamu tetap bisa jelajah barang.',
                    ),
                  ],
                ),
              ),
            ),
            AppStickyBottom(
              children: [
                AppErrorSlot(message: _errorMessage),
                AppButton(
                  key: const Key('verification-submit'),
                  label: 'Kirim untuk ditinjau',
                  isLoading: _submitting,
                  onPressed: _complete ? _submit : null,
                ),
                if (_complete)
                  const SizedBox(height: AppSpacing.sm)
                else
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Lengkapi foto KTM dan selfie dulu, atau',
                        textAlign: TextAlign.center,
                        style: text.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.beranda),
                        child: const Text('jelajah barang dulu'),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountLine extends StatelessWidget {
  const _AccountLine({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.person_outline_rounded, size: AppSizes.iconXs, color: muted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text.rich(
            TextSpan(children: [
              const TextSpan(
                  text: 'Nama dan NIM di KTM harus sama dengan akunmu: '),
              TextSpan(
                text: '${user.nama} · ${user.nim}',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ]),
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ),
      ],
    );
  }
}
