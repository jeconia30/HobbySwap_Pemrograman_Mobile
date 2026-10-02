import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// API key Groq dari `--dart-define=GROQ_API_KEY=...` (tidak ditulis di kode).
/// ponytail: key ikut terbawa di APK; untuk rilis publik pindahkan panggilan
/// ini ke server/cloud function agar key tidak bisa dibongkar.
const _apiKey = String.fromEnvironment('GROQ_API_KEY');

/// Model kecil & cepat: tugas AI di app ini pendek (ringkas, klasifikasi).
/// Pengganti resmi llama-3.1-8b-instant yang dimatikan Groq 16 Agu 2026.
/// Daftar model: https://console.groq.com/docs/models
const _model = 'openai/gpt-oss-20b';

/// Token "berpikir" model reasoning ikut dihitung; sisakan ruang agar
/// jawaban JSON tidak terpotong.
const _ruangPenalaran = 300;
final _endpoint = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

class AiException implements Exception {
  AiException(this.message) {
    // Fitur AI disembunyikan saat gagal; log ini menjelaskan alasannya.
    if (kDebugMode) debugPrint('[AI Groq] $message');
  }

  final String message;

  @override
  String toString() => 'AiException: $message';
}

/// Klien Groq minimal: kirim instruksi + data, terima balasan JSON.
class GroqClient {
  GroqClient({http.Client? client, String apiKey = _apiKey})
    : _client = client ?? http.Client(),
      _key = apiKey;

  final http.Client _client;
  final String _key;

  /// `false` = app dijalankan tanpa API key; fitur AI disembunyikan.
  bool get aktif => _key.isNotEmpty;

  Future<Map<String, dynamic>> json({
    required String instruksi,
    required String data,
    int maxTokens = 200,
  }) async {
    if (!aktif) throw AiException('API key Groq belum diatur.');
    final http.Response res;
    try {
      res = await _client
          .post(
            _endpoint,
            headers: {
              'Authorization': 'Bearer $_key',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'temperature': 0.2,
              'reasoning_effort': 'low',
              'include_reasoning': false,
              'max_completion_tokens': maxTokens + _ruangPenalaran,
              'response_format': {'type': 'json_object'},
              'messages': [
                {'role': 'system', 'content': instruksi},
                {'role': 'user', 'content': data},
              ],
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw AiException('AI tidak bisa dihubungi.');
    }
    if (res.statusCode != 200) {
      // Sertakan pesan error Groq (mis. model_not_found) agar mudah dilacak.
      final detail = utf8.decode(res.bodyBytes);
      throw AiException(
        'AI gagal (HTTP ${res.statusCode}): '
        '${detail.length > 200 ? detail.substring(0, 200) : detail}',
      );
    }
    try {
      final body =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final content = body['choices'][0]['message']['content'] as String;
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      throw AiException('Jawaban AI tidak terbaca.');
    }
  }
}

final groqClientProvider = Provider<GroqClient>((ref) {
  final client = GroqClient();
  if (!client.aktif && kDebugMode) {
    debugPrint(
      '[AI Groq] API key kosong, fitur AI nonaktif. '
      'Jalankan dengan --dart-define=GROQ_API_KEY=...',
    );
  }
  return client;
});
