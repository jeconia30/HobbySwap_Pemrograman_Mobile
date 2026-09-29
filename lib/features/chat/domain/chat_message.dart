import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum TipePesan { teks, foto, lokasiCod, sistem }

/// Kejadian sewa yang otomatis dicatat sebagai pesan sistem.
enum KejadianSewa {
  dikirim('Pengajuan sewa dikirim'),
  disetujui('Pengajuan sewa disetujui'),
  ditolak('Pengajuan sewa ditolak'),
  serahTerima('Serah terima selesai. Selamat memakai!'),
  pengembalian('Pengembalian selesai. Terima kasih!'),
  dibatalkan('Sewa dibatalkan'),
  barterDikirim('Tawaran barter dikirim'),
  barterDiminta('Pemilik meminta barang lain untuk barter'),
  barterDisetujui('Barter disepakati');

  const KejadianSewa(this.teks);

  final String teks;
}

/// Status usulan titik COD.
enum StatusCod { menunggu, disetujui, usulLain }

@freezed
abstract class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required String id,
    required String threadId,

    /// `null` = pesan sistem.
    String? senderId,
    required TipePesan tipe,
    required String isi,

    /// Data tambahan: lokasi/waktu/status COD, atau jenis kejadian sistem.
    @Default(<String, dynamic>{}) Map<String, dynamic> payload,
    required DateTime sentAt,

    /// `null` = belum dibaca lawan bicara.
    DateTime? readAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  bool get sistem => tipe == TipePesan.sistem;

  /// Usulan COD dari [payload] (null bila bukan pesan COD).
  UsulanCod? get cod => tipe == TipePesan.lokasiCod
      ? UsulanCod.fromPayload(payload)
      : null;

  KejadianSewa? get kejadian => switch (payload['kejadian']) {
        final String nama => KejadianSewa.values.asNameMap()[nama],
        _ => null,
      };
}

/// Isi pesan `lokasiCod`: tempat, waktu, dan jawaban penerima.
class UsulanCod {
  const UsulanCod({
    required this.lokasi,
    required this.waktu,
    this.status = StatusCod.menunggu,
  });

  factory UsulanCod.fromPayload(Map<String, dynamic> p) => UsulanCod(
        lokasi: p['lokasi'] as String? ?? '',
        waktu: DateTime.tryParse(p['waktu'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        status: StatusCod.values.asNameMap()[p['status']] ?? StatusCod.menunggu,
      );

  final String lokasi;
  final DateTime waktu;
  final StatusCod status;

  Map<String, dynamic> toPayload() => {
        'lokasi': lokasi,
        'waktu': waktu.toIso8601String(),
        'status': status.name,
      };
}
