import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/ai/groq_client.dart';
import 'package:hobby_swab/features/chat/data/chat_ai.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Klien tiruan: membalas [isi] sebagai jawaban model dan menghitung panggilan.
({GroqClient client, List<http.Request> calls}) fakeGroq(
  Map<String, dynamic> isi, {
  int status = 200,
}) {
  final calls = <http.Request>[];
  final client = GroqClient(
    apiKey: 'test-key',
    client: MockClient((req) async {
      calls.add(req);
      return http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {'content': jsonEncode(isi)},
            },
          ],
        }),
        status,
      );
    }),
  );
  return (client: client, calls: calls);
}

void main() {
  test('filter kata rawan: hanya pesan mencurigakan yang dikirim ke AI', () {
    expect(perluCekPenipuan('Transfer DP 50rb dulu ya ke rekening BCA'), isTrue);
    expect(perluCekPenipuan('kirim kode OTP yang masuk'), isTrue);
    expect(perluCekPenipuan('cek https://bit.ly/abc'), isTrue);
    expect(perluCekPenipuan('Bisa ambil jam 4 sore di FT?'), isFalse);
    expect(perluCekPenipuan('Danau Toba seru buat camping'), isFalse);
    // Balasan demo di simulasi chat harus lolos filter.
    expect(
      perluCekPenipuan('Transfer DP 50rb dulu ya ke rekening BCA 8210123456'),
      isTrue,
    );
  });

  test('GroqClient mengirim key dan membaca JSON', () async {
    final g = fakeGroq({'ok': true});
    final hasil = await g.client.json(instruksi: 'x', data: 'y');
    expect(hasil, {'ok': true});
    expect(g.calls.single.headers['Authorization'], 'Bearer test-key');
  });

  test('GroqClient: error HTTP dan tanpa key jadi AiException', () {
    expect(fakeGroq({}, status: 429).client.json(instruksi: 'x', data: 'y'),
        throwsA(isA<AiException>()));
    final tanpaKey = GroqClient(apiKey: '');
    expect(tanpaKey.aktif, isFalse);
    expect(tanpaKey.json(instruksi: 'x', data: 'y'),
        throwsA(isA<AiException>()));
  });

  test('peringatan penipuan: pesan rawan dinilai AI, pesan biasa tidak',
      () async {
    final g = fakeGroq({'curiga': true, 'alasan': 'Minta transfer di luar app.'});
    final c = ProviderContainer(
      overrides: [groqClientProvider.overrideWithValue(g.client)],
    );
    addTearDown(c.dispose);

    expect(
      await c.read(peringatanPenipuanProvider('TF dulu ke rek aku ya').future),
      'Minta transfer di luar app.',
    );
    expect(
      await c.read(peringatanPenipuanProvider('Oke sampai jumpa').future),
      isNull,
    );
    expect(g.calls.length, 1); // pesan biasa tidak memakai token
  });
}
