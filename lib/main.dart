import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/storage/session_storage.dart';
import 'core/utils/dates.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(appLocale);
  final storage = await SessionStorage.create();
  runApp(ProviderScope(
    overrides: [sessionStorageProvider.overrideWithValue(storage)],
    child: const HobbySwapApp(),
  ));
}
