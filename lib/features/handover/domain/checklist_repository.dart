import 'handover_checklist.dart';

/// Kontrak checklist serah terima. Melempar [ChecklistException] bila ditolak.
abstract interface class ChecklistRepository {
  /// Checklist tahap ini; dibuat dari template kategori bila belum ada.
  Future<HandoverChecklist> get(String bookingId, TahapChecklist tahap);

  /// Perubahan terbaru (termasuk persetujuan pihak lawan).
  Stream<HandoverChecklist> watch(String bookingId, TahapChecklist tahap);

  /// Menyimpan isi (centang, foto, catatan). Ditolak bila sudah disetujui
  /// kedua pihak.
  Future<HandoverChecklist> save(HandoverChecklist checklist);

  /// [userId] (pemilik atau penyewa) menyetujui. Bila kedua pihak setuju:
  /// awal → sewa berlangsung; akhir → sewa selesai.
  Future<HandoverChecklist> approve(
      String bookingId, TahapChecklist tahap, String userId);
}
