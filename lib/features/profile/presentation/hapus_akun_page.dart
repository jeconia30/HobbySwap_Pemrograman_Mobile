import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_info_note.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/domain/auth_repository.dart';
import '../../auth/presentation/auth_controller.dart';

/// Kata yang harus diketik untuk mengonfirmasi penghapusan akun.
const kataHapus = 'HAPUS';

const _yangDihapus = [
  'Profil, email kampus, dan NIM-mu',
  'Foto KTM dan selfie verifikasi',
  'Barang yang kamu sewakan (tidak tampil lagi di Beranda)',
  'Favorit, pesan, dan notifikasi',
];

/// /profil/hapus-akun — penjelasan + ketik "HAPUS" (simulasi).
class HapusAkunPage extends ConsumerStatefulWidget {
  const HapusAkunPage({super.key});

  @override
  ConsumerState<HapusAkunPage> createState() => _HapusAkunPageState();
}

class _HapusAkunPageState extends ConsumerState<HapusAkunPage> {
  final _konfirmasi = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _konfirmasi.dispose();
    super.dispose();
  }

  Future<void> _hapus() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).hapusAkun();
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      context.go(AppRoutes.login);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Akunmu sudah dihapus.')));
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = AppTeks.koneksiPutus);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome,
                    AppSpacing.md, AppSpacing.pageHome, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppBackButton(
                        onPressed: _busy
                            ? null
                            : () => context.canPop()
                                ? context.pop()
                                : context.go(AppRoutes.profil),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Semantics(
                      header: true,
                      child: Text('Hapus akun', style: text.headlineMedium),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Ini tidak bisa dibatalkan. Yang akan dihapus:',
                      style: text.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    for (final t in _yangDihapus)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.remove_circle_outline_rounded,
                                size: AppSizes.iconSm,
                                color: theme.colorScheme.error),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: Text(t, style: text.bodyMedium)),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    const AppInfoNote(
                      icon: Icons.info_outline_rounded,
                      message: 'Catatan transaksi yang sudah terjadi disimpan '
                          'seperlunya untuk penyelesaian sengketa, sesuai '
                          'Kebijakan Privasi. Untuk sekarang ini masih '
                          'simulasi.',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      key: const Key('hapus-konfirmasi-teks'),
                      label: 'Ketik $kataHapus untuk konfirmasi',
                      controller: _konfirmasi,
                      enabled: !_busy,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppErrorSlot(message: _error),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageHome, 0,
                  AppSpacing.pageHome, AppSpacing.lg),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _konfirmasi,
                builder: (context, v, _) => AppButton(
                  key: const Key('hapus-akun-kirim'),
                  label: 'Hapus akun permanen',
                  variant: AppButtonVariant.danger,
                  isLoading: _busy,
                  onPressed: v.text.trim() == kataHapus ? _hapus : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
