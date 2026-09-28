import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan status aplikasi & sesi. Nanti `sessionUserId` diganti token JWT
/// di flutter_secure_storage tanpa mengubah pemakai kelas ini.
class SessionStorage {
  SessionStorage(this._prefs);

  static const onboardingSeenKey = 'onboardingSeen';
  static const sessionUserIdKey = 'sessionUserId';

  final SharedPreferences _prefs;

  static Future<SessionStorage> create() async =>
      SessionStorage(await SharedPreferences.getInstance());

  bool get onboardingSeen => _prefs.getBool(onboardingSeenKey) ?? false;

  Future<void> setOnboardingSeen() => _prefs.setBool(onboardingSeenKey, true);

  String? get sessionUserId => _prefs.getString(sessionUserIdKey);

  Future<void> saveSession(String userId) =>
      _prefs.setString(sessionUserIdKey, userId);

  Future<void> clearSession() => _prefs.remove(sessionUserIdKey);
}

/// Di-override di `main()` (dan di test) dengan instance yang sudah dimuat.
final sessionStorageProvider = Provider<SessionStorage>(
  (ref) => throw UnimplementedError('sessionStorageProvider belum di-override'),
);
