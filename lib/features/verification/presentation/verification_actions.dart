import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/verification_providers.dart';
import '../domain/verification_repository.dart';

/// Aksi verifikasi yang juga menyegarkan sesi, supaya semua layar yang membaca
/// `authControllerProvider` langsung melihat status baru.
final verificationActionsProvider =
    Provider<VerificationActions>(VerificationActions.new);

class VerificationActions {
  VerificationActions(this._ref);

  final Ref _ref;

  Future<void> submit(VerificationPhoto ktm, VerificationPhoto selfie) async {
    await _ref.read(verificationRepositoryProvider).submit(ktm, selfie);
    _ref.read(authControllerProvider.notifier).refresh();
  }

  Future<void> debugApprove() async {
    await _ref.read(verificationRepositoryProvider).debugApprove();
    _ref.read(authControllerProvider.notifier).refresh();
  }
}
