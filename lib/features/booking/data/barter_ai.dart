import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/groq_client.dart';
import '../../item/data/item_providers.dart';

typedef SaranBarter = ({String itemId, String alasan});

/// Barang milikku yang paling cocok ditawarkan untuk barter barang [targetId].
/// `null` = AI mati, pilihan kurang dari 2, atau AI gagal (saran disembunyikan).
final saranBarterProvider = FutureProvider.autoDispose
    .family<SaranBarter?, String>((ref, targetId) async {
      final ai = ref.watch(groqClientProvider);
      if (!ai.aktif) return null;
      final target = (await ref.watch(itemByIdProvider(targetId).future))?.item;
      final milikku = [
        for (final l in await ref.watch(myItemsProvider.future))
          if (l.item.aktif) l.item,
      ];
      if (target == null || milikku.length < 2) return null;

      try {
        final hasil = await ai.json(
          instruksi:
              'Pilih SATU barang dari "barangku" yang paling cocok ditukar '
              '(barter) dengan "incaran". Utamakan kategori yang ada di '
              'minat_barter pemilik incaran, lalu harga sewa yang mirip. '
              'Balas JSON: {"id": "...", "alasan": "maks 15 kata, bahasa '
              'Indonesia santai"}',
          data: jsonEncode({
            'incaran': {
              'judul': target.judul,
              'kategori': target.kategori.name,
              'harga_per_hari': target.hargaPerHari,
              'minat_barter': [for (final k in target.minatBarter) k.name],
            },
            'barangku': [
              for (final i in milikku)
                {
                  'id': i.id,
                  'judul': i.judul,
                  'kategori': i.kategori.name,
                  'harga_per_hari': i.hargaPerHari,
                },
            ],
          }),
          maxTokens: 80,
        );
        ref.keepAlive();
        final id = '${hasil['id'] ?? ''}';
        // Jangan percaya id karangan AI: harus salah satu barangku.
        if (!milikku.any((i) => i.id == id)) return null;
        return (itemId: id, alasan: '${hasil['alasan'] ?? ''}'.trim());
      } on AiException {
        return null;
      }
    });
