import 'package:flutter/services.dart';

/// Haptic ringan (DESIGN §5), hanya untuk aksi penting: kirim pengajuan,
/// setujui (pengajuan, checklist & usulan COD), terbitkan barang, kirim ulasan,
/// kirim pesan, favorit.
Future<void> hapticAksiPenting() => HapticFeedback.lightImpact();
