import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/session_storage.dart';
import '../../../data/fake/fake_account_store.dart';
import '../domain/verification_repository.dart';
import 'fake_verification_repository.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>(
  (ref) => FakeVerificationRepository(
    storage: ref.watch(sessionStorageProvider),
    store: ref.watch(fakeAccountStoreProvider),
  ),
);
