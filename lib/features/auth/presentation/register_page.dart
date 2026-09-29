import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_checkbox_field.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_step_header.dart';
import '../../../core/widgets/app_sticky_bottom.dart';
import '../../../core/widgets/app_text_field.dart';
import '../domain/auth_repository.dart';
import 'auth_controller.dart';
import '../../../core/constants/app_strings.dart';

typedef _Taken = ({String value, String message});

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _nim = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _obscure = true;
  bool _submitting = false;
  bool _submittedOnce = false;
  String? _errorMessage;

  /// NIM/email yang ditolak repository karena sudah terdaftar; hilang saat diubah.
  _Taken? _takenNim;
  _Taken? _takenEmail;

  late final _syaratTap = TapGestureRecognizer()
    ..onTap = () => context.push(AppRoutes.syarat);
  late final _privasiTap = TapGestureRecognizer()
    ..onTap = () => context.push(AppRoutes.privasi);

  @override
  void dispose() {
    _syaratTap.dispose();
    _privasiTap.dispose();
    _nama.dispose();
    _nim.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  static String? _takenError(_Taken? taken, String? value) =>
      taken != null && taken.value == value ? taken.message : null;

  String? _validateNim(String? v) =>
      AuthValidators.nim(v) ?? _takenError(_takenNim, v?.trim());

  String? _validateEmail(String? v) =>
      AuthValidators.campusEmail(v) ??
      _takenError(_takenEmail, v?.trim().toLowerCase());

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _submittedOnce = true;
      _errorMessage = null;
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).register(
            nama: _nama.text,
            nim: _nim.text,
            email: _email.text,
            password: _password.text,
          );
      if (!mounted) return;
      context.go(AppRoutes.verifikasi);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        switch (e.field) {
          case AuthField.nim:
            _takenNim = (value: _nim.text.trim(), message: e.message);
          case AuthField.email:
            _takenEmail =
                (value: _email.text.trim().toLowerCase(), message: e.message);
          case null:
            _errorMessage = e.message;
        }
      });
      _formKey.currentState!.validate();
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
    final colors = AppColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _submittedOnce
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.md,
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl,
                  ),
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppStepHeader(
                          current: 1,
                          total: 3,
                          backTooltip: 'Kembali ke halaman masuk',
                          onBack: _submitting
                              ? null
                              : () => context.go(AppRoutes.login),
                        ),
                        const SizedBox(height: AppSpacing.group),
                        Semantics(
                          header: true,
                          child: Text('Buat akun HobbySwap',
                              style: text.headlineMedium),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Khusus mahasiswa aktif. Setelah ini kamu tinggal '
                          'verifikasi KTM.',
                          style: text.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppSpacing.group),
                        AppTextField(
                          key: const Key('register-nama'),
                          label: 'Nama lengkap',
                          hint: 'Sesuai KTM',
                          controller: _nama,
                          enabled: !_submitting,
                          validator: AuthValidators.nama,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          key: const Key('register-nim'),
                          label: 'NIM',
                          hint: '9 digit, mis. 220401087',
                          controller: _nim,
                          enabled: !_submitting,
                          validator: _validateNim,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _email,
                          builder: (context, value, _) => AppTextField(
                            key: const Key('register-email'),
                            label: 'Email kampus',
                            hint: 'nama@students.usu.ac.id',
                            controller: _email,
                            enabled: !_submitting,
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            suffix: AuthValidators.isCampusEmail(value.text)
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    key: const Key('register-email-valid'),
                                    color: colors.verified,
                                    semanticLabel: 'Email kampus valid',
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          key: const Key('register-password'),
                          label: 'Password',
                          hint: 'Minimal 8 karakter, huruf & angka',
                          controller: _password,
                          enabled: !_submitting,
                          obscureText: _obscure,
                          validator: AuthValidators.newPassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          suffix: IconButton(
                            tooltip: _obscure
                                ? 'Tampilkan password'
                                : 'Sembunyikan password',
                            onPressed: _submitting
                                ? null
                                : () => setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppCheckboxField(
                          key: const Key('register-terms'),
                          validator: AuthValidators.terms,
                          enabled: !_submitting,
                          label: TextSpan(children: [
                            const TextSpan(text: 'Saya setuju dengan '),
                            TextSpan(
                              text: 'Syarat Layanan',
                              style: AppCheckboxField.linkStyle(context),
                              recognizer: _syaratTap,
                            ),
                            const TextSpan(text: ' dan '),
                            TextSpan(
                              text: 'Kebijakan Privasi',
                              style: AppCheckboxField.linkStyle(context),
                              recognizer: _privasiTap,
                            ),
                            const TextSpan(text: ' HobbySwap.'),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _BottomArea(
                errorMessage: _errorMessage,
                submitting: _submitting,
                onSubmit: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomArea extends StatelessWidget {
  const _BottomArea({
    required this.errorMessage,
    required this.submitting,
    required this.onSubmit,
  });

  final String? errorMessage;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppStickyBottom(
      children: [
        AppErrorSlot(message: errorMessage),
        AppButton(
          key: const Key('register-submit'),
          label: 'Lanjut ke verifikasi KTM',
          isLoading: submitting,
          onPressed: onSubmit,
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Sudah punya akun?',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            TextButton(
              onPressed: submitting ? null : () => context.go(AppRoutes.login),
              child: const Text('Masuk'),
            ),
          ],
        ),
      ],
    );
  }
}
