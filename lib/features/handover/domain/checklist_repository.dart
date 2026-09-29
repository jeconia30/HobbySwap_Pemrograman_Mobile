import 'handover_checklist.dart';

/// Kontrak checklist serah terima. Melempar [ChecklistException] bila ditolak.
///
/// [itemId] `null` = barang utama sewa. Untuk barter (M11), barang tawaran
/// punya checklist sendiri: `itemId` = id barang tawaran, dengan peran
/// "pemilik" = pengaju (pemilik barang tawaran).
abstract interface class ChecklistRepository {
  /// Checklist tahap ini; dibuat dari template kategori bila belum ada.
  Future<HandoverChecklist> get(String bookingId, TahapChecklist tahap,
      {String? itemId});

  /// Perubahan terbaru (termasuk persetujuan pihak lawan).
  Stream<HandoverChecklist> watch(String bookingId, TahapChecklist tahap,
      {String? itemId});

  /// Menyimpan isi (centang, foto, catatan). Ditolak bila sudah disetujui
  /// kedua pihak.
  Future<HandoverChecklist> save(HandoverChecklist checklist);

  /// [userId] (pemilik atau peminjam barang itu) menyetujui. Bila semua
  /// checklist tahap ini (dua barang untuk barter) disetujui kedua pihak:
  /// awal → berlangsung; akhir → selesai.
  Future<HandoverChecklist> approve(
      String bookingId, TahapChecklist tahap, String userId,
      {String? itemId});
}
