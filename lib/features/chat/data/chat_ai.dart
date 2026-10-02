import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/groq_client.dart';

/// Kata/pola yang sering muncul di modus penipuan jual-beli. Hanya pesan yang
/// cocok yang dikirim ke AI, jadi obrolan biasa tidak memakai token.
final _polaRawan = RegExp(
  r'transfer|\btf\b|\bdp\b|rekening|\bnorek\b|\brek\b|bayar dulu|'
  r'di ?luar (aplikasi|app|hobbyswap)|\bovo\b|\bdana\b|gopay|shopeepay|'
  r'pulsa|\botp\b|kode verifikasi|https?://|wa\.me|bit\.ly|\b\d{9,}\b',
  caseSensitive: false,
);

bool perluCekPenipuan(String teks) => _polaRawan.hasMatch(teks);

/// Alasan singkat bila AI menilai [teks] mencurigakan; `null` = aman / AI mati.
final peringatanPenipuanProvider = FutureProvider.autoDispose
    .family<String?, String>((ref, teks) async {
      final ai = ref.watch(groqClientProvider);
      if (!ai.aktif || !perluCekPenipuan(teks)) return null;
      try {
        final hasil = await ai.json(
          instruksi:
              'Kamu penjaga keamanan aplikasi sewa barang antar mahasiswa. '
              'Pembayaran yang aman hanya lewat aplikasi atau tunai saat COD. '
              'Nilai apakah pesan dari lawan bicara ini mencurigakan (minta '
              'transfer/DP di luar aplikasi, minta OTP, link aneh, desakan). '
              'Balas JSON: {"curiga": true/false, "alasan": "maks 12 kata"}',
          data: teks,
          maxTokens: 60,
        );
        ref.keepAlive();
        if (hasil['curiga'] != true) return null;
        final alasan = '${hasil['alasan'] ?? ''}'.trim();
        return alasan.isEmpty ? 'Pesan ini mirip modus penipuan.' : alasan;
      } on AiException {
        return null;
      }
    });
