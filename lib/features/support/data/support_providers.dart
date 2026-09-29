import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../domain/support_repository.dart';

/// Laporan palsu: hanya jeda, belum terkirim ke mana pun (UI-first).
class FakeSupportRepository implements SupportRepository {
  FakeSupportRepository({this.delay = const Duration(milliseconds: 800)});

  final Duration delay;

  @override
  Future<void> kirimLaporan(KategoriLaporan kategori, String deskripsi) =>
      Future<void>.delayed(delay);
}

final supportRepositoryProvider =
    Provider<SupportRepository>((ref) => FakeSupportRepository());

/// Versi aplikasi dari build (pubspec), untuk layar Tentang.
final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);
