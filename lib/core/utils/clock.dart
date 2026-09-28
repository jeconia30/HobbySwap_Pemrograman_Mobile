import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sumber "sekarang" yang bisa di-override di test (tanggal tetap).
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
