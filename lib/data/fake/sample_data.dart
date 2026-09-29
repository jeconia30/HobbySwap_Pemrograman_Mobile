import '../../core/utils/dates.dart';
import '../../features/activity/domain/notification_item.dart';
import '../../features/auth/domain/user.dart';
import '../../features/booking/domain/booking.dart';
import '../../features/booking/domain/booking_rules.dart';
import '../../features/chat/domain/chat_message.dart';
import '../../features/chat/domain/chat_thread.dart';
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
      fakultas: 'Teknik',
      prodi: 'Teknik Mesin',
      bio: 'Suka naik gunung dan main game. Barangku selalu kurawat.',
      warnaAvatar: WarnaAvatar.hijau,
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
      prodi: 'Ilmu Komunikasi',
      warnaAvatar: WarnaAvatar.ungu,
    ),
    password: _demoPassword,
  ),
  SampleAccount(
    user: User(
      id: 'usr-003',
      nama: 'Rizky Nugraha',
      nim: '210401034',
      email: 'rizky@students.usu.ac.id',
      fakultas: 'Teknik',
      prodi: 'Teknik Sipil',
      bio: 'Fotografer acara kampus. Kamera selalu dicek sebelum disewakan.',
      warnaAvatar: WarnaAvatar.biru,
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
      prodi: 'Hubungan Internasional',
      warnaAvatar: WarnaAvatar.bata,
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
      prodi: 'Manajemen',
      warnaAvatar: WarnaAvatar.coklat,
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
/// Barang contoh tanpa denda keterlambatan (sisanya 50% harga sewa).
const _tanpaDenda = {'itm-006', 'itm-011', 'itm-016'};

/// Barang contoh yang menerima barter (M11) beserta kategori yang dicari.
const _minatBarter = <String, List<Kategori>>{
  'itm-001': [Kategori.camping], // Sony (Rizky)
  'itm-004': [Kategori.kamera, Kategori.game], // Tenda (Sarah)
  'itm-009': [Kategori.olahraga], // Stik PS5 (Rizky)
  'itm-012': [Kategori.olahraga], // Keyboard Yamaha (Sarah)
  'itm-013': [Kategori.kamera], // Carrier Eiger (Gregorian)
};

List<Item> sampleItemsFor(DateTime today) {
  final t = dateOnly(today);
  return [
    for (final item in sampleItems)
      item.copyWith(
        rentangTidakTersedia: [
          for (final r in _blokirPemilik[item.id] ?? const <(int, int)>[])
            _rentang(t, r),
        ],
        dendaPerHari:
            _tanpaDenda.contains(item.id) ? 0 : saranDenda(item.hargaPerHari),
        bisaBarter: _minatBarter.containsKey(item.id),
        minatBarter: _minatBarter[item.id] ?? const [],
      ),
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
    // Sewa yang sudah lewat serah terima sudah dibayar COD ke pemilik.
    final dibayar = status == StatusBooking.berlangsung ||
        status == StatusBooking.selesai;
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
      statusBayar: dibayar ? StatusBayar.lunas : StatusBayar.belum,
      metodeBayar: dibayar
          ? (n.isEven ? MetodeBayar.transfer : MetodeBayar.tunai)
          : null,
      dibayarPada: dibayar ? mulai.add(const Duration(hours: 9)) : null,
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

    // Barter (M11): tawaran masuk ke Gregorian (GoPro Dimas ⇄ Carrier Eiger)
    // dan barter berlangsung (Raket Gregorian ⇄ Keyboard Sarah).
    rel('itm-013', dimas, (8, 9), StatusBooking.menunggu,
            dibuat: 0,
            pesan: 'GoPro-ku buat dokumentasi, Carrier-mu buat naik '
                'Sibayak. Tukar pinjam ya, Kak!')
        .copyWith(
            jenis: JenisTransaksi.barter,
            itemTawaranId: 'itm-003',
            totalHarga: 0),
    rel('itm-012', sarah, (-1, 2), StatusBooking.berlangsung, dibuat: -5)
        .copyWith(
      penyewaId: gregorian,
      jenis: JenisTransaksi.barter,
      itemTawaranId: 'itm-015',
      totalHarga: 0,
      statusBayar: StatusBayar.belum,
      metodeBayar: null,
      dibayarPada: null,
    ),

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
  HandoverChecklist beres(Booking b, TahapChecklist tahap, {String? itemId}) {
    final tanggal = tahap == TahapChecklist.awal ? b.tanggalMulai : b.tanggalKembali;
    final jam = tahap == TahapChecklist.awal ? 9 : 16;
    final items = templateChecklist(_itemContoh(itemId ?? b.itemId).kategori);
    return HandoverChecklist(
      bookingId: b.id,
      tahap: tahap,
      itemId: itemId,
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
      // Barter: barang tawaran punya checklist sendiri.
      for (final itemId in [null, ?b.itemTawaranId])
        if (b.status == StatusBooking.berlangsung)
          beres(b, TahapChecklist.awal, itemId: itemId)
        else if (b.status == StatusBooking.selesai) ...[
          beres(b, TahapChecklist.awal, itemId: itemId),
          beres(b, TahapChecklist.akhir, itemId: itemId),
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

/// Notifikasi contoh untuk Gregorian, tersebar di hari ini, kemarin, minggu
/// ini, dan lebih lama (pengingat sewa dihitung terpisah dari data sewa).
List<NotificationItem> sampleNotificationsFor(DateTime today) {
  final t = dateOnly(today);
  DateTime at(int hari, int jam, int menit) =>
      addDays(t, hari).add(Duration(hours: jam, minutes: menit));
  NotificationItem n(String id, TipeNotifikasi tipe, String judul, String isi,
          DateTime tanggal,
          {bool dibaca = false, String? tautan}) =>
      NotificationItem(
        id: 'ntf-contoh-$id',
        userId: gregorian,
        tipe: tipe,
        judul: judul,
        isi: isi,
        tanggal: tanggal,
        sudahDibaca: dibaca,
        tautan: tautan,
      );

  return [
    n('1', TipeNotifikasi.pengajuanBaru, 'Pengajuan baru untuk Carrier Eiger',
        'Aulia Putri ingin menyewa 3 hari. Cek dan jawab, ya.', at(0, 9, 12),
        tautan: '/pengajuan'),
    n('2', TipeNotifikasi.pengajuanBaru, 'Pengajuan baru untuk Carrier Eiger',
        'Sarah Manurung ingin menyewa di tanggal yang bertumpuk.',
        at(-1, 19, 40),
        tautan: '/pengajuan'),
    n('3', TipeNotifikasi.pengajuanDisetujui, 'Pengajuanmu disetujui',
        'GoPro Hero 11 dari Dimas. Isi checklist saat ambil barang.',
        at(-1, 14, 5),
        dibaca: true, tautan: '/sewaan'),
    n('4', TipeNotifikasi.pengajuanBaru, 'Pengajuan baru untuk Raket Yonex',
        'Dimas Ramadhan ingin menyewa 1 hari.', at(-2, 16, 30),
        tautan: '/pengajuan'),
    n('5', TipeNotifikasi.pengajuanDitolak, 'Pengajuanmu ditolak',
        'Ukulele Soprano Mahoni: barang sedang dipakai.', at(-3, 10, 15),
        dibaca: true, tautan: '/sewaan?tab=riwayat'),
    n('6', TipeNotifikasi.ulasanBaru, 'Ulasan baru untukmu',
        'Rizky Nugraha memberi ★5 untuk Carrier Eiger.', at(-4, 20, 2),
        dibaca: true, tautan: '/profil/ulasan'),
    n('7', TipeNotifikasi.verifikasiDisetujui, 'Akunmu sudah terverifikasi',
        'Sekarang kamu bisa sewa dan menyewakan barang di HobbySwap.',
        at(-21, 11, 0),
        dibaca: true, tautan: '/beranda'),
  ];
}
/// Percakapan contoh Gregorian (relatif terhadap [now]); id sewa sesuai
/// urutan [sampleBookingsFor].
(List<ChatThread>, List<ChatMessage>) sampleChatsFor(DateTime now) {
  const rizky = 'usr-003', aulia = 'usr-002', dimas = 'usr-005';
  const sarah = 'usr-004';
  final t = dateOnly(now);
  DateTime at(int hari, int jam, int menit) =>
      addDays(t, hari).add(Duration(hours: jam, minutes: menit));
  DateTime lalu(int menit) => now.subtract(Duration(minutes: menit));

  final messages = <ChatMessage>[];
  var n = 0;
  void m(String thr, String? dari, String isi, DateTime waktu,
      {TipePesan tipe = TipePesan.teks,
      Map<String, dynamic> payload = const {},
      bool dibaca = true}) {
    messages.add(ChatMessage(
      id: 'msg-contoh-${(++n).toString().padLeft(3, '0')}',
      threadId: thr,
      senderId: dari,
      tipe: dari == null ? TipePesan.sistem : tipe,
      isi: isi,
      payload: payload,
      sentAt: waktu,
      readAt: dibaca ? waktu.add(const Duration(minutes: 3)) : null,
    ));
  }

  void sistem(String thr, KejadianSewa k, String bookingId, DateTime waktu) =>
      m(thr, null, k.teks, waktu,
          payload: {'kejadian': k.name, 'bookingId': bookingId});

  // Rizky · Sony A6400 · berlangsung.
  sistem('thr-001', KejadianSewa.dikirim, 'bkg-021', at(-4, 19, 0));
  m('thr-001', gregorian, 'Halo Kak Rizky, Sony-nya bisa dipakai buat '
      'liputan acara himpunan?', at(-4, 19, 2));
  m('thr-001', rizky, 'Bisa banget. Nanti aku setujui ya.', at(-4, 19, 15));
  sistem('thr-001', KejadianSewa.disetujui, 'bkg-021', at(-3, 8, 30));
  m('thr-001', rizky, 'Usulan titik COD', at(-3, 8, 32),
      tipe: TipePesan.lokasiCod,
      payload: UsulanCod(
        lokasi: 'FT USU',
        waktu: at(-1, 10, 0),
        status: StatusCod.disetujui,
      ).toPayload());
  m('thr-001', gregorian, 'Siap, sampai ketemu di FT!', at(-3, 9, 1));
  sistem('thr-001', KejadianSewa.serahTerima, 'bkg-021', at(-1, 10, 20));
  m('thr-001', rizky, 'Baterainya udah aku cas penuh ya. Charger ada di tas.',
      at(-1, 10, 24));

  // Aulia · Carrier Eiger (barang Gregorian) · menunggu, 2 belum dibaca.
  sistem('thr-002', KejadianSewa.dikirim, 'bkg-005', lalu(30));
  m('thr-002', aulia, 'Halo Kak, aku Aulia yang ngajuin Carrier Eiger.',
      lalu(25), dibaca: false);
  m('thr-002', aulia, 'Boleh ambil sehari sebelum tanggal mulai? Mau '
      'packing dulu.', lalu(24), dibaca: false);

  // Dimas · GoPro · disetujui, membahas jam ambil.
  sistem('thr-003', KejadianSewa.disetujui, 'bkg-022', at(-1, 14, 5));
  m('thr-003', dimas, 'Udah aku setujui ya. Ambilnya di FEB.', at(-1, 14, 6));
  m('thr-003', gregorian, 'Makasih Kak! Besok bisa ambil jam berapa?',
      at(-1, 14, 30));
  m('thr-003', dimas, 'Bisa, jam 4 sore gimana?', at(-1, 15, 2));

  // Sarah · Tenda Dome · selesai.
  sistem('thr-004', KejadianSewa.pengembalian, 'bkg-024', at(-8, 17, 0));
  m('thr-004', gregorian, 'Tendanya udah aku balikin ya Kak, makasih banyak!',
      at(-8, 17, 10));
  m('thr-004', sarah, 'Makasih ya, tendanya aman!', at(-8, 18, 2));

  DateTime terakhir(String thr) => messages
      .where((x) => x.threadId == thr)
      .map((x) => x.sentAt)
      .reduce((a, b) => a.isAfter(b) ? a : b);

  ChatThread thread(String id, String lawan, String itemId, String bookingId,
          {int unread = 0}) =>
      ChatThread(
        id: id,
        participantIds: [gregorian, lawan],
        itemId: itemId,
        bookingId: bookingId,
        lastMessageAt: terakhir(id),
        unreadCount: {gregorian: unread, lawan: 0},
      );

  return (
    [
      thread('thr-001', rizky, 'itm-001', 'bkg-021'),
      thread('thr-002', aulia, 'itm-013', 'bkg-005', unread: 2),
      thread('thr-003', dimas, 'itm-003', 'bkg-022'),
      thread('thr-004', sarah, 'itm-004', 'bkg-024'),
    ],
    messages,
  );
}
