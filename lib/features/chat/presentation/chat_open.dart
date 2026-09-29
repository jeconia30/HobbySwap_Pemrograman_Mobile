import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../data/chat_providers.dart';
import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';

/// Membuka (atau membuat) obrolan dengan [otherUserId] tentang [itemId], lalu
/// pindah ke ruang obrolannya. Dipakai dari Detail, Sewaan, Pengajuan, dan
/// Checklist.
Future<void> bukaObrolan(
  BuildContext context, {
  required String otherUserId,
  required String itemId,
  String? bookingId,
}) async {
  final repo = ProviderScope.containerOf(context, listen: false)
      .read(chatRepositoryProvider);
  try {
    final thread = await repo.openOrCreate(
      otherUserId: otherUserId,
      itemId: itemId,
      bookingId: bookingId,
    );
    if (context.mounted) context.push(AppRoutes.pesanThread(thread.id));
  } on ChatException catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(e.message)));
  }
}

/// Satu baris ringkasan pesan untuk kotak masuk.
String pratinjauPesan(ChatMessage m, String viewerId) {
  final isi = switch (m.tipe) {
    TipePesan.sistem || TipePesan.teks => m.isi,
    TipePesan.foto => 'Foto',
    TipePesan.lokasiCod => 'Usulan titik COD: ${m.cod!.lokasi}',
  };
  return m.senderId == viewerId ? 'Kamu: $isi' : isi;
}
