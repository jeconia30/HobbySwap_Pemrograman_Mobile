import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/storage/session_storage.dart';
import 'core/storage/settings_storage.dart';
import 'core/utils/error_handling.dart';
import 'core/utils/dates.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  pasangPenangananError();
  await initializeDateFormatting(appLocale);
  final storage = await SessionStorage.create();
  final settings = await SettingsStorage.create();
  runApp(ProviderScope(
    overrides: [
      sessionStorageProvider.overrideWithValue(storage),
      settingsStorageProvider.overrideWithValue(settings),
    ],
    child: const HobbySwapApp(),
  ));
}
