import '../../core/utils/dates.dart';
import '../../features/auth/domain/user.dart';
import '../../features/booking/domain/booking.dart';
import '../../features/booking/domain/booking_rules.dart';
import '../../features/handover/domain/handover_checklist.dart';
import '../../features/review/domain/review.dart';
import '../../features/item/domain/item.dart';
import '../../features/item/domain/kategori.dart';

/// Akun demo untuk repository palsu. Bukan kredensial sungguhan.
class SampleAccount {
  const SampleAccount({required this.user, required this.password});

  final User user;
  final String password;
}

const _demoPassword = 'hobbyswap2026';

const sampleAccounts = <SampleAccount>[
  SampleAccount(
    user: User(
      id: 'usr-001',
      nama: 'Gregorian',
      nim: '220401087',
      email: 'gregorian@students.usu.ac.id',
      fakultas: 'Fasilkom-TI',
      statusVerifikasi: StatusVerifikasi.terverifikasi,
      rating: 4.8,
      jumlahUlasan: 12,
    ),
    password: _demoPassword,
  ),
  SampleAccount(
    user: User(
      id: 'usr-002',
      nama: 'Aulia Putri',
      nim: '220402011',
      email: 'aulia@students.usu.ac.id',
      fakultas: 'FISIP',
    ),
    password: _demoPassword,
  ),
  SampleAccount(
    user: User(
      id: 'usr-003',
      nama: 'Rizky Nugraha',
      nim: '210401034',
      email: 'rizky@students.usu.ac.id',
      fakultas: 'FT USU',
      statusVerifikasi: StatusVerifikasi.terverifikasi,
      rating: 4.9,
      jumlahUlasan: 41,
    ),
    password: _demoPassword,
  ),
  SampleAccount(
    user: User(
      id: 'usr-004',
      nama: 'Sarah Manurung',
      nim: '210903052',
      email: 'sarah@students.usu.ac.id',
      fakultas: 'FISIP',
      statusVerifikasi: StatusVerifikasi.terverifikasi,
      rating: 4.8,
      jumlahUlasan: 36,
    ),
    password: _demoPassword,
  ),
  SampleAccount(
    user: User(
      id: 'usr-005',
      nama: 'Dimas Ramadhan',
      nim: '220503019',
      email: 'dimas@students.usu.ac.id',
      fakultas: 'FEB',
      statusVerifikasi: StatusVerifikasi.terverifikasi,
      rating: 4.7,
      jumlahUlasan: 18,
    ),
    password: _demoPassword,
  ),
];

/// Urutan daftar = urutan ditambahkan (paling akhir = paling baru).
const sampleItems = <Item>[
  Item(
    id: 'itm-001',
    ownerId: 'usr-003',
    judul: 'Sony A6400 + Lensa Kit 16–50mm',
    deskripsi: 'Mirrorless 24MP, autofokus cepat. Termasuk 2 baterai, '
        'charger, dan SD card 64GB.',
    kategori: Kategori.kamera,
    hargaPerHari: 45000,
    lokasiKampus: 'FT USU',
    jumlahDisewa: 58,
  ),
  Item(
    id: 'itm-002',
    ownerId: 'usr-004',
    judul: 'Canon EOS M50 Mark II',
    deskripsi: 'Cocok buat vlog dan foto acara kampus. Layar bisa diputar.',
    kategori: Kategori.kamera,
    hargaPerHari: 40000,
    lokasiKampus: 'FISIP',
    jumlahDisewa: 31,
  ),
  Item(
    id: 'itm-003',
    ownerId: 'usr-005',
    judul: 'GoPro Hero 11 + Mounting',
    deskripsi: 'Tahan air sampai 10 m. Lengkap dengan chest mount dan '
        'helmet mount.',
    kategori: Kategori.kamera,
    hargaPerHari: 35000,
    lokasiKampus: 'FEB',
    jumlahDisewa: 22,
  ),
  Item(
    id: 'itm-004',
    ownerId: 'usr-004',
    judul: 'Tenda Dome 4 Orang',
    deskripsi: 'Double layer, anti bocor. Sudah termasuk pasak dan flysheet.',
    kategori: Kategori.camping,
    hargaPerHari: 30000,
    lokasiKampus: 'Asrama USU',
    jumlahDisewa: 44,
  ),
  Item(
    id: 'itm-005',
    ownerId: 'usr-003',
    judul: 'Carrier Consina 60L',
    deskripsi: 'Backsystem nyaman untuk pendakian 2–3 hari. Ada raincover.',
    kategori: Kategori.camping,
    hargaPerHari: 25000,
    lokasiKampus: 'FT USU',
    jumlahDisewa: 19,
  ),
  Item(
    id: 'itm-006',
    ownerId: 'usr-005',
    judul: 'Kompor Portable + Nesting',
    deskripsi: 'Kompor lipat gas kaleng dan nesting 3 panci. Gas tidak termasuk.',
    kategori: Kategori.camping,
    hargaPerHari: 15000,
    lokasiKampus: 'FMIPA',
    jumlahDisewa: 12,
  ),
  Item(
    id: 'itm-007',
    ownerId: 'usr-002',
    judul: 'Raket Li-Ning Axforce 80',
    deskripsi: 'Head heavy, senar baru dipasang 26 lbs. Termasuk tas raket.',
    kategori: Kategori.olahraga,
    hargaPerHari: 15000,
    lokasiKampus: 'Pintu 4',
    jumlahDisewa: 9,
  ),
  Item(
    id: 'itm-008',
    ownerId: 'usr-005',
    judul: 'Sepatu Futsal Specs ukuran 42',
    deskripsi: 'Sol karet non-marking, cocok untuk lapangan indoor.',
    kategori: Kategori.olahraga,
    hargaPerHari: 12000,
    lokasiKampus: 'FKM',
    jumlahDisewa: 6,
  ),
  Item(
    id: 'itm-009',
    ownerId: 'usr-003',
    judul: 'Stik PS5 DualSense',
    deskripsi: 'Kondisi mulus, haptic dan adaptive trigger normal. '
        'Termasuk kabel USB-C.',
    kategori: Kategori.game,
    hargaPerHari: 15000,
    lokasiKampus: 'Pintu 4',
    jumlahDisewa: 37,
  ),
  Item(
    id: 'itm-010',
    ownerId: 'usr-004',
    judul: 'Nintendo Switch Lite',
    deskripsi: 'Termasuk Mario Kart 8 dan Animal Crossing. Ada case.',
    kategori: Kategori.game,
    hargaPerHari: 35000,
    lokasiKampus: 'FISIP',
    jumlahDisewa: 15,
  ),
  Item(
    id: 'itm-011',
    ownerId: 'usr-002',
    judul: 'Ukulele Soprano Mahoni',
    deskripsi: 'Suara hangat, senar Aquila. Termasuk tuner jepit dan softcase.',
    kategori: Kategori.musik,
    hargaPerHari: 12000,
    lokasiKampus: 'FISIP',
    jumlahDisewa: 8,
  ),
  Item(
    id: 'itm-012',
    ownerId: 'usr-004',
    judul: 'Keyboard Yamaha PSR-E373',
    deskripsi: '61 tuts touch-sensitive. Termasuk adaptor dan stand lipat.',
    kategori: Kategori.musik,
    hargaPerHari: 30000,
    lokasiKampus: 'FIB',
    jumlahDisewa: 5,
  ),
  Item(
    id: 'itm-013',
    ownerId: 'usr-001',
    judul: 'Carrier Eiger Rhinos 45L',
    deskripsi: 'Ringan, cocok untuk tektok atau camping semalam.',
    kategori: Kategori.camping,
    hargaPerHari: 25000,
    lokasiKampus: 'FT USU',
    jumlahDisewa: 14,
  ),
  Item(
    id: 'itm-014',
    ownerId: 'usr-001',
    judul: 'Nintendo Switch OLED',
    deskripsi: 'Layar OLED 7 inci, 2 Joy-Con, dan dock.',
    kategori: Kategori.game,
    hargaPerHari: 40000,
    lokasiKampus: 'FT USU',
    jumlahDisewa: 21,
  ),
  Item(
    id: 'itm-015',
    ownerId: 'usr-001',
    judul: 'Raket Yonex Astrox 88',
    deskripsi: 'Untuk pemain depan-belakang. Grip baru.',
    kategori: Kategori.olahraga,
    hargaPerHari: 15000,
    lokasiKampus: 'Pintu 4',
    jumlahDisewa: 7,
  ),
  Item(
    id: 'itm-016',
    ownerId: 'usr-001',
    judul: 'Hammock ENO Single',
    deskripsi: 'Termasuk strap pohon. Muat 1 orang sampai 180 kg.',
    kategori: Kategori.camping,
    hargaPerHari: 10000,
    lokasiKampus: 'FT USU',
    jumlahDisewa: 4,
    aktif: false,
  ),
];

// ---------------------------------------------------------------------------
// Jadwal contoh RELATIF terhadap hari ini, supaya kalender demo selalu masuk
// akal kapan pun aplikasi dijalankan. Pasangan = (hari+mulai, hari+selesai).

const _blokirPemilik = <String, List<(int, int)>>{
  'itm-001': [(2, 3), (9, 10)], // Sony A6400
  'itm-002': [(5, 6)], // Canon EOS M50
  'itm-004': [(12, 13)], // Tenda Dome
  'itm-010': [(1, 1)], // Switch Lite
};

RentangTanggal _rentang(DateTime today, (int, int) r) => RentangTanggal(
      mulai: addDays(today, r.$1),
      selesai: addDays(today, r.$2),
    );

/// [sampleItems] dengan `rentangTidakTersedia` terisi relatif ke [today].
List<Item> sampleItemsFor(DateTime today) {
  final t = dateOnly(today);
  return [
    for (final item in sampleItems)
      item.copyWith(rentangTidakTersedia: [
        for (final r in _blokirPemilik[item.id] ?? const <(int, int)>[])
          _rentang(t, r),
      ]),
  ];
}

/// Sewa contoh relatif ke [today]: mengisi kalender, Barang Saya (pengajuan,
/// barang disewa, pendapatan), dan nanti Sewaan Saya.
List<Booking> sampleBookingsFor(DateTime today) {
  final t = dateOnly(today);
  final awalBulan = DateTime(t.year, t.month);
  var n = 0;

  Booking b(
    String itemId,
    String penyewa,
    DateTime mulai,
    DateTime kembali,
    StatusBooking status, {
    String? pesan,
    DateTime? dibuat,
  }) {
    final item = sampleItems.firstWhere((i) => i.id == itemId);
    n++;
    return Booking(
      id: 'bkg-${n.toString().padLeft(3, '0')}',
      itemId: itemId,
      penyewaId: penyewa,
      tanggalMulai: mulai,
      tanggalKembali: kembali,
      totalHarga: hitungTotal(item.hargaPerHari, mulai, kembali),
      status: status,
      pesan: pesan,
      dibuatPada: dibuat ?? addDays(mulai, -3),
    );
  }

  Booking rel(String itemId, String penyewa, (int, int) r, StatusBooking s,
          {String? pesan, int? dibuat}) =>
      b(itemId, penyewa, addDays(t, r.$1), addDays(t, r.$2), s,
          pesan: pesan, dibuat: dibuat == null ? null : addDays(t, dibuat));

  /// Sewa selesai bulan ini (mulai tetap di bulan berjalan).
  Booking selesaiBulanIni(String itemId, String penyewa, int mundur) {
    final m = addDays(t, -mundur);
    final mulai = m.isBefore(awalBulan) ? awalBulan : m;
    return b(itemId, penyewa, mulai, addDays(mulai, 1), StatusBooking.selesai);
  }

  const aulia = 'usr-002', rizky = 'usr-003', sarah = 'usr-004';
  const dimas = 'usr-005';

  return [
    // Barang orang lain.
    rel('itm-004', rizky, (4, 6), StatusBooking.disetujui),
    rel('itm-008', rizky, (-1, 2), StatusBooking.berlangsung),
    rel('itm-009', sarah, (3, 4), StatusBooking.disetujui),
    rel('itm-001', dimas, (6, 6), StatusBooking.menunggu),

    // Pengajuan masuk ke barang Gregorian (Aulia & Sarah bentrok).
    rel('itm-013', aulia, (20, 22), StatusBooking.menunggu,
        dibuat: 0,
        pesan: 'Buat pendakian Sibayak bareng anak himpunan. Aku jaga '
            'baik-baik ya, Kak!'),
    rel('itm-015', dimas, (17, 17), StatusBooking.menunggu, dibuat: -2),
    rel('itm-013', sarah, (21, 23), StatusBooking.menunggu, dibuat: -1),

    // Sedang disewa dari Gregorian.
    rel('itm-014', sarah, (-1, 2), StatusBooking.berlangsung),

    // Selesai bulan ini (pendapatan).
    selesaiBulanIni('itm-013', rizky, 3),
    selesaiBulanIni('itm-014', dimas, 5),
    selesaiBulanIni('itm-015', sarah, 7),

    // Riwayat lama (jumlah disewakan sepanjang waktu).
    for (final (i, itemId) in const [
      'itm-013', 'itm-014', 'itm-015', 'itm-016', 'itm-013', //
      'itm-014', 'itm-013', 'itm-015', 'itm-014',
    ].indexed)
      rel(itemId, [rizky, sarah, dimas][i % 3], (-40 - i * 9, -39 - i * 9),
          StatusBooking.selesai),

    // Gregorian sebagai penyewa (Sewaan Saya).
    rel('itm-001', rizky, (-1, 1), StatusBooking.berlangsung, dibuat: -4)
        .copyWith(penyewaId: gregorian),
    rel('itm-003', dimas, (1, 2), StatusBooking.disetujui, dibuat: -2)
        .copyWith(penyewaId: gregorian),
    rel('itm-009', rizky, (14, 15), StatusBooking.menunggu, dibuat: 0)
        .copyWith(penyewaId: gregorian),
    rel('itm-004', sarah, (-10, -8), StatusBooking.selesai)
        .copyWith(penyewaId: gregorian),
    rel('itm-011', aulia, (5, 6), StatusBooking.ditolak, dibuat: -3)
        .copyWith(penyewaId: gregorian, alasanTolak: 'Barang sedang dipakai'),

    // Riwayat lama pemilik lain (sumber ulasan di Detail Barang).
    rel('itm-001', sarah, (-30, -29), StatusBooking.selesai),
    rel('itm-001', dimas, (-50, -48), StatusBooking.selesai),
    rel('itm-004', rizky, (-35, -33), StatusBooking.selesai),
    rel('itm-004', dimas, (-60, -59), StatusBooking.selesai),
    rel('itm-003', sarah, (-25, -24), StatusBooking.selesai),
    rel('itm-003', rizky, (-45, -44), StatusBooking.selesai),
  ];
}

const gregorian = 'usr-001';

/// Id sewa contoh yang sengaja belum dinilai (untuk kartu "Beri rating").
const sewaBelumDinilaiPenyewa = 'bkg-024'; // Tenda Dome, Gregorian penyewa
const sewaBelumDinilaiPemilik = 'bkg-009'; // Carrier Eiger, Gregorian pemilik

Item _itemContoh(String id) => sampleItems.firstWhere((i) => i.id == id);

/// Checklist contoh yang konsisten dengan status sewa: sewa berlangsung sudah
/// lewat tahap awal; sewa selesai sudah lewat awal & akhir.
List<HandoverChecklist> sampleChecklistsFor(List<Booking> bookings) {
  HandoverChecklist beres(Booking b, TahapChecklist tahap) {
    final tanggal = tahap == TahapChecklist.awal ? b.tanggalMulai : b.tanggalKembali;
    final jam = tahap == TahapChecklist.awal ? 9 : 16;
    final items = templateChecklist(_itemContoh(b.itemId).kategori);
    return HandoverChecklist(
      bookingId: b.id,
      tahap: tahap,
      daftarKondisi: [
        for (final (i, k) in items.indexed)
          k.copyWith(
              dicek: true,
              foto: i < 2 ? 'simulasi://checklist/${b.id}/$i' : null),
      ],
      disetujuiPemilik: true,
      disetujuiPenyewa: true,
      disetujuiPemilikPada: tanggal.add(Duration(hours: jam, minutes: 12)),
      disetujuiPenyewaPada: tanggal.add(Duration(hours: jam, minutes: 20)),
    );
  }

  return [
    for (final b in bookings)
      if (b.status == StatusBooking.berlangsung)
        beres(b, TahapChecklist.awal)
      else if (b.status == StatusBooking.selesai) ...[
        beres(b, TahapChecklist.awal),
        beres(b, TahapChecklist.akhir),
      ],
  ];
}

const _ulasanPenyewa = [
  (5, 'Barangnya persis kayak di foto, pemiliknya fast response. '
      'Bakal sewa lagi!', ['Sesuai foto', 'Pemilik ramah']),
  (5, 'Serah terimanya gampang, dijelasin cara pakainya juga.',
      ['Mudah diambil', 'Pemilik ramah']),
  (4, 'Kondisi bagus dan bersih. Cuma ambilnya agak jauh dari fakultasku.',
      ['Bersih & rapi', 'Sesuai foto']),
  (5, 'Tepat waktu dan barangnya terawat banget.',
      ['Tepat waktu', 'Bersih & rapi']),
];

const _ulasanPemilik = [
  (5, 'Barang balik dalam kondisi sama persis. Recommended!',
      ['Barang dijaga baik', 'Tepat waktu']),
  (4, 'Komunikasinya enak, cuma telat balikin 1 jam.',
      ['Komunikatif', 'Ramah']),
  (5, 'Penyewa yang rapi dan tepat waktu.', ['Tepat waktu', 'Ramah']),
];

/// Ulasan dua arah untuk sewa selesai, kecuali yang sengaja belum dinilai.
List<Review> sampleReviewsFor(List<Booking> bookings) {
  final reviews = <Review>[];
  var n = 0;
  for (final b in bookings.where((b) => b.status == StatusBooking.selesai)) {
    final ownerId = _itemContoh(b.itemId).ownerId;
    final tanggal = addDays(b.tanggalKembali, 1);
    if (b.id != sewaBelumDinilaiPenyewa) {
      final (bintang, teks, tag) = _ulasanPenyewa[n % _ulasanPenyewa.length];
      reviews.add(Review(
        id: 'rvw-${(++n).toString().padLeft(3, '0')}',
        bookingId: b.id,
        dariUserId: b.penyewaId,
        keUserId: ownerId,
        itemId: b.itemId,
        peran: PeranUlasan.penyewaMenilaiPemilik,
        bintang: bintang,
        teks: teks,
        tag: tag,
        tanggal: tanggal,
      ));
    }
    if (b.id != sewaBelumDinilaiPemilik) {
      final (bintang, teks, tag) = _ulasanPemilik[n % _ulasanPemilik.length];
      reviews.add(Review(
        id: 'rvw-${(++n).toString().padLeft(3, '0')}',
        bookingId: b.id,
        dariUserId: ownerId,
        keUserId: b.penyewaId,
        itemId: b.itemId,
        peran: PeranUlasan.pemilikMenilaiPenyewa,
        bintang: bintang,
        teks: teks,
        tag: tag,
        tanggal: tanggal,
      ));
    }
  }
  return reviews;
}
