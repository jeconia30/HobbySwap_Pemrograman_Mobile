import '../../auth/domain/user.dart';
import '../../item/domain/item.dart';
import 'laporan.dart';

class LaporanException implements Exception {
  const LaporanException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Batas panjang deskripsi laporan.
const laporanMin = 20;
const laporanMaks = 500;

/// Laporan beserta data tampilannya, dilihat dari [viewerId].
class LaporanView {
  const LaporanView({
    required this.laporan,
    required this.viewerId,
    required this.pelapor,
    required this.terlapor,
    this.item,
  });

  final Laporan laporan;
  final String viewerId;
  final User pelapor;
  final User terlapor;

  /// Barang yang disewa (laporan terkait sewa).
  final Item? item;

  bool get sayaPelapor => laporan.pelaporId == viewerId;
  bool get sayaTerlapor => laporan.terlaporId == viewerId;

  /// Terlapor bisa menerima usulan atau mengajukan banding.
  bool get bisaDitanggapi =>
      sayaTerlapor &&
      laporan.status == StatusLaporan.menungguTanggapan &&
      laporan.usulan != null;
}

abstract interface class LaporanRepository {
  /// Laporan yang kubuat, dan laporan terkait sewa tentang aku.
  Stream<List<LaporanView>> laporanku(String userId);

  Stream<LaporanView?> watch(String id, String userId);

  /// Kirim laporan sebagai user yang sedang masuk.
  Future<Laporan> kirim({
    String? bookingId,
    required String terlaporId,
    required JenisLaporan jenis,
    List<String> itemBermasalah = const [],
    required String deskripsi,
    List<String> fotoBukti = const [],
    UsulanPenyelesaian? usulan,
    int? nominal,
  });

  /// Terlapor menerima usulan penyelesaian.
  Future<Laporan> terimaUsulan(String id);

  /// Terlapor tidak setuju: diteruskan ke tim HobbySwap.
  Future<Laporan> ajukanBanding(String id);

  /// Pelapor menandai laporan beres (setelah usulan diterima).
  Future<Laporan> tandaiSelesai(String id);
}
