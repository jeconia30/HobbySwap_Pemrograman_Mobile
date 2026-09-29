import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferensi aplikasi di perangkat (tema & notifikasi).
class SettingsStorage {
  SettingsStorage(this._prefs);

  static const themeModeKey = 'themeMode';
  static const notifSewaKey = 'notifSewa';
  static const notifPromoKey = 'notifPromo';

  final SharedPreferences _prefs;

  static Future<SettingsStorage> create() async =>
      SettingsStorage(await SharedPreferences.getInstance());

  ThemeMode get themeMode => ThemeMode.values.firstWhere(
        (m) => m.name == _prefs.getString(themeModeKey),
        orElse: () => ThemeMode.system,
      );

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(themeModeKey, mode.name);

  bool get notifSewa => _prefs.getBool(notifSewaKey) ?? true;

  Future<void> setNotifSewa(bool value) => _prefs.setBool(notifSewaKey, value);

  bool get notifPromo => _prefs.getBool(notifPromoKey) ?? false;

  Future<void> setNotifPromo(bool value) =>
      _prefs.setBool(notifPromoKey, value);
}

/// Di-override di `main()` (dan di test) dengan instance yang sudah dimuat.
final settingsStorageProvider = Provider<SettingsStorage>(
  (ref) => throw UnimplementedError('settingsStorageProvider belum di-override'),
);

@immutable
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.notifSewa,
    required this.notifPromo,
  });

  final ThemeMode themeMode;
  final bool notifSewa;
  final bool notifPromo;

  AppSettings copyWith({ThemeMode? themeMode, bool? notifSewa, bool? notifPromo}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        notifSewa: notifSewa ?? this.notifSewa,
        notifPromo: notifPromo ?? this.notifPromo,
      );
}

/// Pengaturan yang langsung dipakai UI (tema berubah tanpa restart).
final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  SettingsStorage get _storage => ref.read(settingsStorageProvider);

  @override
  AppSettings build() {
    final s = ref.watch(settingsStorageProvider);
    return AppSettings(
      themeMode: s.themeMode,
      notifSewa: s.notifSewa,
      notifPromo: s.notifPromo,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _storage.setThemeMode(mode);
  }

  Future<void> setNotifSewa(bool value) async {
    state = state.copyWith(notifSewa: value);
    await _storage.setNotifSewa(value);
  }

  Future<void> setNotifPromo(bool value) async {
    state = state.copyWith(notifPromo: value);
    await _storage.setNotifPromo(value);
  }
}
