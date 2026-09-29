import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/dates.dart';
import '../../booking/domain/booking.dart';
import '../../item/domain/item.dart';

part 'notification_item.freezed.dart';
part 'notification_item.g.dart';

enum TipeNotifikasi {
  pengajuanBaru,
  pengajuanDisetujui,
  pengajuanDitolak,
  pengingatAmbil,
  pengingatKembali,
  terlambat,
  giliranChecklist,
  ulasanBaru,
  verifikasiDisetujui,
  sewaDibatalkan,
  barterDiminta,
  laporanBaru,
  laporanDitanggapi,
}

@freezed
abstract class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    required String userId,
    required TipeNotifikasi tipe,
    required String judul,
    required String isi,
    required DateTime tanggal,
    @Default(false) bool sudahDibaca,

    /// Rute tujuan saat notifikasi ditekan.
    String? tautan,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
}

/// Pengingat untuk penyewa, dihitung dari status & tanggal sewa relatif ke
/// [today]: H-1 ambil (disetujui), H-1 & hari H kembali, dan terlambat
/// (berlangsung). Id deterministik supaya tidak dobel.
List<NotificationItem> hitungPengingat(
  Iterable<Booking> bookings,
  Item? Function(String itemId) itemById,
  DateTime today,
) {
  final t = dateOnly(today);
  final pagi = t.add(const Duration(hours: 7));
  final hasil = <NotificationItem>[];
  for (final b in bookings) {
    final judul = itemById(b.itemId)?.judul ?? 'barang sewaan';
    final checklist = '/sewa/${b.id}/checklist';
    NotificationItem n(TipeNotifikasi tipe, String j, String isi,
            {String? tautan}) =>
        NotificationItem(
          id: 'ntf-${tipe.name}-${b.id}-${t.year}${t.month}${t.day}',
          userId: b.penyewaId,
          tipe: tipe,
          judul: j,
          isi: isi,
          tanggal: pagi,
          tautan: tautan ?? checklist,
        );

    if (b.status == StatusBooking.disetujui &&
        daysBetween(t, b.tanggalMulai) == 1) {
      hasil.add(n(TipeNotifikasi.pengingatAmbil, 'Besok ambil $judul',
          'Jangan lupa isi checklist ambil barang bersama pemilik.'));
    }
    if (b.status == StatusBooking.berlangsung) {
      final sisa = daysBetween(t, b.tanggalKembali);
      if (sisa == 1) {
        hasil.add(n(TipeNotifikasi.pengingatKembali, 'Besok kembalikan $judul',
            'Siapkan barangnya dan isi checklist pengembalian, ya.',
            tautan: '$checklist?tahap=akhir'));
      } else if (sisa == 0) {
        hasil.add(n(TipeNotifikasi.pengingatKembali,
            'Hari ini kembalikan $judul',
            'Batas pengembalian hari ini. Isi checklist bersama pemilik.',
            tautan: '$checklist?tahap=akhir'));
      } else if (sisa < 0) {
        hasil.add(n(TipeNotifikasi.terlambat,
            'Terlambat ${-sisa} hari: $judul',
            'Segera kembalikan dan hubungi pemilik supaya tidak jadi masalah.',
            tautan: '$checklist?tahap=akhir'));
      }
    }
  }
  return hasil;
}
