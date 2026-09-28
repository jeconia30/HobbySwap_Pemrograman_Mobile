import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/storage/session_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';

void main() {
  test('nilai awal: onboarding belum dilihat, tanpa sesi', () async {
    final storage = await mockStorage();
    expect(storage.onboardingSeen, isFalse);
    expect(storage.sessionUserId, isNull);
  });

  test('membaca nilai yang sudah tersimpan', () async {
    final storage = await mockStorage({
      SessionStorage.onboardingSeenKey: true,
      SessionStorage.sessionUserIdKey: 'usr-001',
    });
    expect(storage.onboardingSeen, isTrue);
    expect(storage.sessionUserId, 'usr-001');
  });

  test('menyimpan & menghapus, dan tersimpan ke SharedPreferences', () async {
    final storage = await mockStorage();
    await storage.setOnboardingSeen();
    await storage.saveSession('usr-002');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(SessionStorage.onboardingSeenKey), isTrue);
    expect(prefs.getString(SessionStorage.sessionUserIdKey), 'usr-002');

    await storage.clearSession();
    expect(storage.sessionUserId, isNull);
    expect(storage.onboardingSeen, isTrue, reason: 'onboarding tidak ikut terhapus');
  });
}
