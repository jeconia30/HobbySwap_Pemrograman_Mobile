import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/avatar_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_sticky_bottom.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/domain/auth_repository.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../booking/presentation/sewa_refresh.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';

class EditProfilPage extends ConsumerStatefulWidget {
  const EditProfilPage({super.key});

  @override
  ConsumerState<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends ConsumerState<EditProfilPage> {
  final _formKey = GlobalKey<FormState>();
  late final User _awal = ref.read(authControllerProvider)!;
  late final _nama = TextEditingController(text: _awal.nama);
  late final _bio = TextEditingController(text: _awal.bio ?? '');
  late final _nim = TextEditingController(text: _awal.nim);
  late final _email = TextEditingController(text: _awal.email);
  late WarnaAvatar _warna = _awal.warnaAvatar;
  bool _pilihWarna = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nama.addListener(_rebuild);
    _bio.addListener(_rebuild);
  }

  /// Rebuild halaman hanya saat yang tampil berubah (status "Simpan" atau
  /// inisial avatar), bukan di setiap ketikan.
  late (bool, String) _tampil = _jejak();

  (bool, String) _jejak() => (_berubah, initials(_namaPreview));

  String get _namaPreview =>
      _nama.text.trim().isEmpty ? _awal.nama : _nama.text.trim();

  void _rebuild() {
    final baru = _jejak();
    if (baru != _tampil) setState(() => _tampil = baru);
  }

  @override
  void dispose() {
    _nama.dispose();
    _bio.dispose();
    _nim.dispose();
    _email.dispose();
    super.dispose();
  }

  bool get _berubah =>
      _nama.text.trim() != _awal.nama ||
      _bio.text.trim() != (_awal.bio ?? '') ||
      _warna != _awal.warnaAvatar;

  void _tutup() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.profil);

  Future<void> _kembali() async {
    if (!_berubah) {
      _tutup();
      return;
    }
    final buang = await showAppBottomSheet<bool>(
      context,
      builder: (sheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSheetTitle('Buang perubahan?'),
          Text(
            'Perubahan profil yang belum disimpan akan hilang.',
            style: Theme.of(sheet).textTheme.bodyMedium
                ?.copyWith(color: Theme.of(sheet).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            key: const Key('buang-perubahan'),
            label: 'Buang',
            variant: AppButtonVariant.danger,
            onPressed: () => Navigator.pop(sheet, true),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => Navigator.pop(sheet, false),
            child: const Text('Lanjut edit'),
          ),
        ],
      ),
    );
    if (buang == true && mounted) _tutup();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .updateProfile(nama: _nama.text, bio: _bio.text, warnaAvatar: _warna);
      ref.refreshSewa();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Profil diperbarui')));
      _tutup();
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = AppTeks.koneksiPutus;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final preview = _awal.copyWith(nama: _namaPreview, warnaAvatar: _warna);

    return PopScope(
      canPop: !_berubah || _busy,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _kembali();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHome,
                    AppSpacing.md,
                    AppSpacing.pageHome,
                    AppSpacing.xl,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            AppBackButton(onPressed: _busy ? null : _kembali),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Semantics(
                                header: true,
                                child: Text(
                                  'Edit profil',
                                  style: text.headlineMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Center(
                          child: AppAvatar(
                            user: preview,
                            size: AppSizes.avatarEdit,
                            showBadge: false,
                          ),
                        ),
                        Center(
                          child: TextButton(
                            key: const Key('ganti-warna'),
                            onPressed: () =>
                                setState(() => _pilihWarna = !_pilihWarna),
                            child: const Text('Ganti warna'),
                          ),
                        ),
                        if (_pilihWarna)
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              for (final w in WarnaAvatar.values)
                                Semantics(
                                  button: true,
                                  selected: w == _warna,
                                  label: 'Warna ${w.label}',
                                  excludeSemantics: true,
                                  child: InkResponse(
                                    key: Key('warna-${w.name}'),
                                    onTap: () => setState(() {
                                      _warna = w;
                                      _tampil = _jejak();
                                    }),
                                    radius: AppSizes.minTapTarget / 2,
                                    child: SizedBox.square(
                                      dimension: AppSizes.minTapTarget,
                                      child: Center(
                                        child: Container(
                                          width: AppSizes.colorSwatch,
                                          height: AppSizes.colorSwatch,
                                          decoration: BoxDecoration(
                                            color: w.color,
                                            shape: BoxShape.circle,
                                            border: w == _warna
                                                ? Border.all(
                                                    color: scheme.primary,
                                                    width: 3,
                                                  )
                                                : null,
                                          ),
                                          child: w == _warna
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  color: AppPalette.cream,
                                                  size: AppSizes.iconSm,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          key: const Key('edit-nama'),
                          label: 'Nama',
                          controller: _nama,
                          enabled: !_busy,
                          validator: ProfileValidators.nama,
                          maxLength: ProfileValidators.namaMaks,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppTextField(
                          key: const Key('edit-bio'),
                          label: 'Bio (opsional)',
                          hint: 'Ceritakan hobimu dalam satu kalimat.',
                          controller: _bio,
                          enabled: !_busy,
                          maxLength: maksBio,
                          minLines: 2,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _ReadOnly(label: 'NIM', controller: _nim),
                        const SizedBox(height: AppSpacing.lg),
                        _ReadOnly(label: 'Email kampus', controller: _email),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: AppSizes.iconXs,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                'Terhubung dengan KTM, tidak bisa diubah.',
                                style: text.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppStickyBottom(
                children: [
                  AppErrorSlot(message: _error),
                  AppButton(
                    key: const Key('edit-simpan'),
                    label: 'Simpan',
                    isLoading: _busy,
                    onPressed: _berubah ? _simpan : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadOnly extends StatelessWidget {
  const _ReadOnly({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      enabled: false,
      suffix: const Icon(Icons.lock_outline_rounded, size: AppSizes.iconSm),
    );
  }
}
