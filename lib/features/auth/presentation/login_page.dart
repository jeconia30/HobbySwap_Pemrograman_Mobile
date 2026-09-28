import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_redirect.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/hs_logo_mark.dart';
import '../domain/auth_repository.dart';
import 'auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  bool _obscure = true;
  bool _submitting = false;
  bool _submittedOnce = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  void _comingSoon(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

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
      final user = await ref
          .read(authControllerProvider.notifier)
          .login(_identifier.text, _password.text);
      if (!mounted) return;
      HapticFeedback.lightImpact();
      context.go(postAuthDestination(user.statusVerifikasi));
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Koneksi lagi putus. Coba lagi ya.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              AppSpacing.pageTop,
              AppSpacing.pageHorizontal,
              AppSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight -
                        AppSpacing.pageTop -
                        AppSpacing.xl)
                    .clamp(0, double.infinity),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Form(
                    key: _formKey,
                    autovalidateMode: _submittedOnce
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: HsLogoMark(),
                          ),
                          const SizedBox(height: AppSpacing.group),
                          Semantics(
                            header: true,
                            child: Text('Selamat datang lagi',
                                style: text.headlineLarge),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Masuk pakai email kampus atau NIM kamu.',
                            style: text.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: AppSpacing.group),
                          AppTextField(
                            key: const Key('login-identifier'),
                            label: 'Email kampus / NIM',
                            hint: 'nama@students.usu.ac.id',
                            controller: _identifier,
                            enabled: !_submitting,
                            validator: AuthValidators.identifier,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.email,
                              AutofillHints.username,
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            key: const Key('login-password'),
                            label: 'Password',
                            hint: 'Masukkan password',
                            controller: _password,
                            enabled: !_submitting,
                            obscureText: _obscure,
                            validator: AuthValidators.password,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            autofillHints: const [AutofillHints.password],
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _submitting
                                  ? null
                                  : () => _comingSoon('Fitur ini segera hadir'),
                              child: const Text('Lupa password?'),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppErrorSlot(
                            message: _errorMessage,
                            spacing: AppSpacing.lg,
                          ),
                          AppButton(
                            key: const Key('login-submit'),
                            label: 'Masuk',
                            isLoading: _submitting,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: AppSpacing.group),
                          const _OrDivider(),
                          const SizedBox(height: AppSpacing.group),
                          AppButton(
                            label: 'Masuk dengan Google',
                            variant: AppButtonVariant.outline,
                            icon: const _GoogleGlyph(),
                            onPressed: _submitting
                                ? null
                                : () => _comingSoon('Segera hadir'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.group),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun?',
                          style: text.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: _submitting
                              ? null
                              : () => context.go(AppRoutes.daftar),
                          child: const Text('Daftar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'atau',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExcludeSemantics(
      child: Text(
        'G',
        textScaler: TextScaler.noScaling,
        style: theme.textTheme.titleLarge?.copyWith(
          color: AppColors.of(context).accentText,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
