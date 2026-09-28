import 'package:flutter/foundation.dart';

import '../../auth/domain/user.dart';

enum PhotoSource { camera, gallery }

/// Foto dokumen. Di tahap UI-first [path] masih `null` (pratinjau simulasi);
/// nanti berisi file dari kamera/galeri untuk diunggah.
@immutable
class VerificationPhoto {
  const VerificationPhoto({required this.source, this.path});

  final PhotoSource source;
  final String? path;
}

class VerificationException implements Exception {
  const VerificationException(this.message);

  final String message;

  @override
  String toString() => 'VerificationException: $message';
}

/// Kontrak verifikasi KTM untuk user yang sedang masuk.
abstract interface class VerificationRepository {
  /// Mengirim dokumen; mengembalikan status baru. Melempar [VerificationException].
  Future<StatusVerifikasi> submit(
      VerificationPhoto ktmPhoto, VerificationPhoto selfiePhoto);

  Future<StatusVerifikasi> statusFor(String userId);

  /// Hanya untuk debug build: anggap peninjau sudah menyetujui.
  Future<StatusVerifikasi> debugApprove();
}
