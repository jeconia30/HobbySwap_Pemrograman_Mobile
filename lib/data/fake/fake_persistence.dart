import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/storage/session_storage.dart';

/// Menyimpan isi store palsu ke perangkat supaya data demo tidak kembali ke
/// awal saat app dibuka ulang (M10).
///
/// Memakai shared_preferences + JSON: paketnya sudah dipakai untuk sesi &
/// tema, semua model freezed sudah punya toJson/fromJson, dan datanya kecil
/// (puluhan entri) sehingga tidak perlu database seperti Hive. Nanti diganti
/// API tanpa mengubah UI.
class FakePersistence {
  FakePersistence(this._prefs);

  /// Tanpa penyimpanan (unit test yang membuat store langsung).
  const FakePersistence.none() : _prefs = null;

  static const _prefix = 'fakeDb.';

  final SharedPreferences? _prefs;

  /// Isi tersimpan untuk [key], atau `null` bila belum pernah disimpan /
  /// rusak (store lalu memakai data contoh).
  List<T>? load<T>(String key, T Function(Map<String, dynamic> json) fromJson) {
    final raw = _prefs?.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      return [
        for (final e in jsonDecode(raw) as List)
          fromJson(Map<String, dynamic>.from(e as Map)),
      ];
    } catch (e) {
      debugPrint('FakePersistence: data "$key" rusak, pakai data contoh ($e)');
      return null;
    }
  }

  void save<T>(
    String key,
    Iterable<T> items,
    Map<String, dynamic> Function(T item) toJson,
  ) {
    final prefs = _prefs;
    if (prefs == null) return;
    prefs.setString('$_prefix$key', jsonEncode([for (final i in items) toJson(i)]));
  }

  /// "Reset data contoh": hapus semua data demo tersimpan.
  Future<void> clear() async {
    final prefs = _prefs;
    if (prefs == null) return;
    for (final k in prefs.getKeys().where((k) => k.startsWith(_prefix))) {
      await prefs.remove(k);
    }
  }
}

final fakePersistenceProvider = Provider<FakePersistence>(
  (ref) => FakePersistence(ref.watch(sessionStorageProvider).prefs),
);
