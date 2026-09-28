import 'package:freezed_annotation/freezed_annotation.dart';

import '../../item/domain/kategori.dart';

part 'handover_checklist.freezed.dart';
part 'handover_checklist.g.dart';

enum TahapChecklist { awal, akhir }

/// Satu baris kondisi: dicek atau tidak, dengan foto bukti opsional.
@freezed
abstract class KondisiItem with _$KondisiItem {
  const factory KondisiItem({
    required String label,
    @Default(false) bool dicek,
    String? foto,
  }) = _KondisiItem;

  factory KondisiItem.fromJson(Map<String, dynamic> json) =>
      _$KondisiItemFromJson(json);
}

@freezed
abstract class HandoverChecklist with _$HandoverChecklist {
  const HandoverChecklist._();

  const factory HandoverChecklist({
    required String bookingId,
    required TahapChecklist tahap,
    @Default(<KondisiItem>[]) List<KondisiItem> daftarKondisi,
    @Default(false) bool disetujuiPemilik,
    @Default(false) bool disetujuiPenyewa,
    String? catatan,
    DateTime? disetujuiPemilikPada,
    DateTime? disetujuiPenyewaPada,
  }) = _HandoverChecklist;

  factory HandoverChecklist.fromJson(Map<String, dynamic> json) =>
      _$HandoverChecklistFromJson(json);

  /// Foto bukti = foto yang menempel di tiap baris kondisi.
  List<String> get daftarFoto => [
        for (final k in daftarKondisi)
          if (k.foto != null) k.foto!,
      ];

  int get jumlahDicek => daftarKondisi.where((k) => k.dicek).length;

  bool get selesai => disetujuiPemilik && disetujuiPenyewa;
}

class ChecklistException implements Exception {
  const ChecklistException(this.message);

  final String message;

  @override
  String toString() => 'ChecklistException: $message';
}

const minimalFotoBukti = 2;

/// Pelanggaran aturan sebelum boleh menyetujui (kosong = boleh).
List<String> periksaChecklist(HandoverChecklist c) {
  final catatanKosong = (c.catatan ?? '').trim().isEmpty;
  final belumDicek = c.daftarKondisi.where((k) => !k.dicek).toList();
  return [
    if (c.daftarFoto.length < minimalFotoBukti)
      'Tambahkan minimal $minimalFotoBukti foto bukti.',
    if (belumDicek.isNotEmpty && catatanKosong)
      'Jelaskan di catatan kenapa ${belumDicek.length} item belum dicentang.',
  ];
}

/// Template 5 item per kategori.
List<KondisiItem> templateChecklist(Kategori kategori) => [
      for (final label in switch (kategori) {
        Kategori.kamera => const [
            'Body mulus, tanpa goresan baru',
            'Lensa bersih, tidak berjamur',
            'Baterai & charger lengkap',
            'Kartu memori (kalau ada)',
            'Tas & strap',
          ],
        Kategori.camping => const [
            'Tidak ada sobek atau bolong',
            'Resleting & gesper berfungsi',
            'Frame, pasak, atau tali lengkap',
            'Bersih & kering (tidak lembap)',
            'Tas penyimpan / cover',
          ],
        Kategori.olahraga => const [
            'Tidak retak atau patah',
            'Grip / tali masih bagus',
            'Senar / sol dalam kondisi baik',
            'Bersih dari lumpur & noda',
            'Tas atau cover',
          ],
        Kategori.musik => const [
            'Body tanpa retak atau goresan baru',
            'Senar / tuts lengkap & berfungsi',
            'Suara normal saat dicoba',
            'Kabel / adaptor lengkap',
            'Softcase / stand',
          ],
        Kategori.game => const [
            'Layar / body tanpa goresan baru',
            'Tombol & analog berfungsi',
            'Baterai terisi & bisa dicas',
            'Kabel charger lengkap',
            'Game / aksesori sesuai daftar',
          ],
        Kategori.lainnya => const [
            'Kondisi fisik sesuai foto',
            'Berfungsi normal saat dicoba',
            'Aksesori lengkap',
            'Bersih',
            'Kemasan / tas penyimpan',
          ],
      })
        KondisiItem(label: label),
    ];
