import 'package:freezed_annotation/freezed_annotation.dart';

part 'laporan.freezed.dart';
part 'laporan.g.dart';

enum JenisLaporan {
  kerusakan('Kerusakan'),
  keterlambatan('Keterlambatan'),
  perilaku('Perilaku'),
  lainnya('Lainnya');

  const JenisLaporan(this.label);

  final String label;

  /// Laporan terkait sewa: pihak terlapor diminta menanggapi usulan.
  bool get terkaitSewa => this == kerusakan || this == keterlambatan;
}

enum UsulanPenyelesaian {
  perbaikanPenyewa('Perbaikan ditanggung penyewa'),
  gantiRugi('Ganti rugi'),
  diskusi('Diskusikan dulu');

  const UsulanPenyelesaian(this.label);

  final String label;
}

enum StatusLaporan {
  menungguTanggapan('Menunggu tanggapan'),
  diterima('Diterima'),
  dibanding('Dibanding'),
  selesai('Selesai');

  const StatusLaporan(this.label);

  final String label;
}

/// Satu kejadian di riwayat laporan (untuk timeline).
@freezed
abstract class RiwayatLaporan with _$RiwayatLaporan {
  const factory RiwayatLaporan({
    required DateTime waktu,
    required String judul,
    String? isi,
    String? olehUserId,
  }) = _RiwayatLaporan;

  factory RiwayatLaporan.fromJson(Map<String, dynamic> json) =>
      _$RiwayatLaporanFromJson(json);
}

/// Laporan kerusakan/keterlambatan (terkait sewa) atau laporan pengguna.
@freezed
abstract class Laporan with _$Laporan {
  const factory Laporan({
    required String id,
    String? bookingId,
    required String pelaporId,
    required String terlaporId,
    required JenisLaporan jenis,

    /// Label item checklist yang bermasalah (laporan kerusakan).
    @Default(<String>[]) List<String> itemChecklistBermasalah,
    required String deskripsi,

    /// Foto bukti (simulasi) dari checklist pengembalian.
    @Default(<String>[]) List<String> fotoBukti,
    UsulanPenyelesaian? usulan,

    /// Nominal ganti rugi (Rp) bila [usulan] = ganti rugi.
    int? nominal,
    @Default(StatusLaporan.menungguTanggapan) StatusLaporan status,
    @Default(<RiwayatLaporan>[]) List<RiwayatLaporan> riwayat,
    required DateTime dibuatPada,
  }) = _Laporan;

  factory Laporan.fromJson(Map<String, dynamic> json) =>
      _$LaporanFromJson(json);
}
