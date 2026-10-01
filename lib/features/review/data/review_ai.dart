import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/groq_client.dart';
import '../domain/review.dart';
import 'review_providers.dart';

/// Minimal ulasan sebelum diringkas; di bawah ini cukup dibaca langsung.
const minimalUlasanDiringkas = 3;

/// Ringkasan AI 1–2 kalimat atas ulasan penyewa untuk seorang pemilik.
/// `null` = AI mati, ulasan terlalu sedikit, atau AI gagal (bagian disembunyikan).
/// Hasil disimpan selama sesi agar token tidak terpakai ulang.
final ringkasanUlasanProvider = FutureProvider.autoDispose
    .family<String?, String>((ref, ownerId) async {
      final ai = ref.watch(groqClientProvider);
      if (!ai.aktif) return null;
      final semua = await ref.watch(reviewsForUserProvider(ownerId).future);
      final ulasan = [
        for (final d in semua)
          if (d.review.peran == PeranUlasan.penyewaMenilaiPemilik) d.review,
      ];
      if (ulasan.length < minimalUlasanDiringkas) return null;

      try {
        final hasil = await ai.json(
          instruksi:
              'Ringkas ulasan penyewa tentang seorang pemilik barang sewaan '
              'jadi 1-2 kalimat bahasa Indonesia santai (maks 160 karakter). '
              'Sebut hal yang paling sering dipuji dan keluhan bila ada. '
              'Balas JSON: {"ringkasan": "..."}',
          // ponytail: 20 ulasan terbaru cukup untuk ringkasan & hemat token.
          data: ulasan
              .take(20)
              .map((r) => '${r.bintang}★ ${[...r.tag, r.teks].join('. ')}')
              .join('\n'),
          maxTokens: 120,
        );
        final teks = '${hasil['ringkasan'] ?? ''}'.trim();
        ref.keepAlive();
        return teks.isEmpty ? null : teks;
      } on AiException {
        return null;
      }
    });
