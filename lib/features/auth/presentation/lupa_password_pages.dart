import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/auth_providers.dart';
import '../domain/auth_repository.dart';

/// Kerangka layar alur lupa password: tombol kembali, judul, subjudul.
class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({
    required this.onBack,
    required this.children,
    this.bottom,
  });

  final VoidCallback? onBack;
  final List<Widget> children;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
                    AppSpacing.md, AppSpacing.pageHorizontal, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppBackButton(onPressed: onBack),
                    ),
                    const SizedBox(height: AppSpacing.group),
                    ...children,
                  ],
                ),
              ),
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
                    0, AppSpacing.pageHorizontal, AppSpacing.lg),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}

class _Judul extends StatelessWidget {
  const _Judul(this.judul, this.sub);

  final String judul;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(judul, style: text.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(sub,
            style: text.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: AppSpacing.group),
      ],
    );
  }
}

/// /lupa-password — minta tautan reset ke email kampus.
class LupaPasswordPage extends ConsumerStatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  ConsumerState<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends ConsumerState<LupaPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _busy = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    setState(() {
      _submitted = true;
      _error = null;
    });
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final email = _email.text.trim().toLowerCase();
      await ref.read(authRepositoryProvider).kirimTautanReset(email);
      if (mounted) context.go(AppRoutes.cekEmail(email));
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
    return Form(
      key: _formKey,
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: _AuthScaffold(
        onBack: _busy ? null : () => context.go(AppRoutes.login),
        bottom: AppButton(
          key: const Key('lupa-kirim'),
          label: 'Kirim tautan reset',
          isLoading: _busy,
          onPressed: _kirim,
        ),
        children: [
          const _Judul(
            'Lupa password?',
            'Masukkan email kampusmu. Kami kirim tautan untuk membuat '
                'password baru.',
          ),
          AppTextField(
            key: const Key('lupa-email'),
            label: 'Email kampus',
            hint: 'nama@students.usu.ac.id',
            controller: _email,
            enabled: !_busy,
            validator: AuthValidators.campusEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _kirim(),
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: AppSpacing.md),
          AppErrorSlot(message: _error),
        ],
      ),
    );
  }
}

/// /lupa-password/cek — "Cek email kampusmu" dengan kirim ulang (60 detik).
class CekEmailPage extends ConsumerStatefulWidget {
  const CekEmailPage({super.key, required this.email});

  final String email;

  @override
  ConsumerState<CekEmailPage> createState() => _CekEmailPageState();
}

class _CekEmailPageState extends ConsumerState<CekEmailPage> {
  Timer? _timer;
  int _sisa = AppDurations.kirimUlang.inSeconds;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _mulaiHitung();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _mulaiHitung() {
    _timer?.cancel();
    setState(() => _sisa = AppDurations.kirimUlang.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _sisa--);
      if (_sisa <= 0) t.cancel();
    });
  }

  Future<void> _kirimUlang() async {
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).kirimTautanReset(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Tautan baru terkirim.')));
      _mulaiHitung();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text(AppTeks.koneksiPutus)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final menunggu = _sisa > 0;
    final jam = '${_sisa ~/ 60}:${(_sisa % 60).toString().padLeft(2, '0')}';

    return _AuthScaffold(
      onBack: () => context.go(AppRoutes.lupaPassword),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            key: const Key('kirim-ulang'),
            label: menunggu ? 'Kirim ulang ($jam)' : 'Kirim ulang',
            variant: AppButtonVariant.secondary,
            isLoading: _busy,
            onPressed: menunggu ? null : _kirimUlang,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            key: const Key('buka-tautan-reset'),
            onPressed: () =>
                context.push(AppRoutes.resetPasswordUntuk(widget.email)),
            child: const Text('Buka tautan reset (simulasi)'),
          ),
        ],
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: AppSizes.statusArt,
            height: AppSizes.statusArt,
            decoration: BoxDecoration(
              color: colors.accentSoft,
              borderRadius: BorderRadius.circular(AppRadius.sheet),
            ),
            child: Icon(Icons.mark_email_unread_outlined,
                color: colors.accentText, size: AppSizes.iconTile * 0.8),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Semantics(
          header: true,
          child: Text('Cek email kampusmu',
              style: theme.textTheme.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'Tautan reset sudah dikirim ke '),
            TextSpan(
              text: widget.email,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const TextSpan(
                text: '. Buka dalam 30 menit. Tidak ada? Cek folder spam.'),
          ]),
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// /reset-password — password baru + konfirmasi dengan indikator kekuatan.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _baru = TextEditingController();
  final _ulang = TextEditingController();
  bool _busy = false;
  bool _submitted = false;
  bool _berhasil = false;
  bool _sembunyi = true;
  String? _error;

  @override
  void dispose() {
    _baru.dispose();
    _ulang.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    setState(() {
      _submitted = true;
      _error = null;
    });
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(email: widget.email, passwordBaru: _baru.text);
      if (mounted) setState(() => _berhasil = true);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = AppTeks.koneksiPutus);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _keLogin() => context.go(AppRoutes.loginDengan(widget.email));

  @override
  Widget build(BuildContext context) {
    if (_berhasil) return _Sukses(onLanjut: _keLogin);

    return Form(
      key: _formKey,
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: _AuthScaffold(
        onBack: _busy ? null : () => context.go(AppRoutes.login),
        bottom: AppButton(
          key: const Key('reset-simpan'),
          label: 'Simpan password baru',
          isLoading: _busy,
          onPressed: _simpan,
        ),
        children: [
          _Judul('Buat password baru',
              'Untuk ${widget.email}. Minimal 8 karakter, ada huruf dan angka.'),
          AppTextField(
            key: const Key('reset-baru'),
            label: 'Password baru',
            controller: _baru,
            enabled: !_busy,
            obscureText: _sembunyi,
            validator: AuthValidators.newPassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            suffix: IconButton(
              tooltip: _sembunyi ? 'Tampilkan password' : 'Sembunyikan password',
              onPressed: () => setState(() => _sembunyi = !_sembunyi),
              icon: Icon(_sembunyi
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _baru,
            builder: (context, v, _) => IndikatorKekuatan(v.text),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const Key('reset-ulang'),
            label: 'Ulangi password baru',
            controller: _ulang,
            enabled: !_busy,
            obscureText: _sembunyi,
            validator: (v) => AuthValidators.konfirmasi(v, _baru.text),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _simpan(),
          ),
          const SizedBox(height: AppSpacing.md),
          AppErrorSlot(message: _error),
        ],
      ),
    );
  }
}

/// Bar 3 segmen: Lemah (error) / Sedang (warning) / Kuat (verified).
class IndikatorKekuatan extends StatelessWidget {
  const IndikatorKekuatan(this.password, {super.key});

  final String password;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final kosong = password.isEmpty;
    final k = AuthValidators.kekuatan(password);
    final (int isi, Color warna) = switch (k) {
      KekuatanPassword.lemah => (1, theme.colorScheme.error),
      KekuatanPassword.sedang => (2, colors.warning),
      KekuatanPassword.kuat => (3, colors.verified),
    };

    return Semantics(
      label: kosong ? null : 'Kekuatan password: ${k.label}',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Container(
                key: Key('kekuatan-segmen-$i'),
                height: AppSizes.progressBar,
                decoration: BoxDecoration(
                  color: !kosong && i < isi ? warna : colors.border,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
            ),
          ],
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: AppSizes.kekuatanLabel,
            child: Text(
              kosong ? '' : k.label,
              key: const Key('kekuatan-label'),
              textAlign: TextAlign.end,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: kosong ? null : warna),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sukses extends StatelessWidget {
  const _Sukses({required this.onLanjut});

  final VoidCallback onLanjut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return _AuthScaffold(
      onBack: onLanjut,
      bottom: AppButton(
        key: const Key('reset-ke-login'),
        label: 'Masuk sekarang',
        onPressed: onLanjut,
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: AppSizes.statusArt,
            height: AppSizes.statusArt,
            decoration: BoxDecoration(
              color: colors.verified.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.sheet),
            ),
            child: Icon(Icons.lock_reset_rounded,
                color: colors.verified, size: AppSizes.iconTile * 0.8),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Semantics(
          header: true,
          child: Text('Password berhasil diganti',
              style: theme.textTheme.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Masuk lagi pakai password barumu.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
