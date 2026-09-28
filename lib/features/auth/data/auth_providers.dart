import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/session_storage.dart';
import '../../../data/fake/fake_account_store.dart';
import '../domain/auth_repository.dart';
import 'fake_auth_repository.dart';

/// Ganti implementasi di sini (atau override di ProviderScope) saat API siap.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FakeAuthRepository(
    storage: ref.watch(sessionStorageProvider),
    store: ref.watch(fakeAccountStoreProvider),
  ),
);
