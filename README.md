# HobbySwap

Aplikasi mobile untuk menyewa dan menyewakan barang hobi antar mahasiswa dalam satu kampus, aman lewat verifikasi KTM. Dibangun dengan **Flutter**, dengan backend **Java Spring Boot** (REST API) menyusul.

> Aturan tampilan lengkap ada di [`DESIGN.md`](DESIGN.md). README ini adalah konsep produk dan arsitektur; keduanya wajib dibaca sebelum membuat layar atau fitur baru.

## 1. Visi Produk

- **Untuk siapa:** mahasiswa (17-25) dalam satu lingkungan kampus, pengguna Android sehari-hari.
- **Masalah:** banyak barang hobi (kamera, alat camping, alat olahraga) mahal dan jarang dipakai; mahasiswa butuh cara pinjam jangka pendek yang aman tanpa membeli.
- **Solusi:** marketplace penyewaan antar mahasiswa dengan identitas terverifikasi KTM, jadwal yang tidak bentrok, dan checklist serah terima untuk mencegah sengketa.
- **Pengalaman yang dituju:** modern dan profesional, terasa aman dan terpercaya, tetap enak dipakai satu tangan.
- **Bukan:** aplikasi latihan pemula, dan bukan jual-beli. Standarnya produk yang layak dipakai kampus sungguhan.

## 2. Peran Pengguna

Satu akun, dua kemampuan. Setiap mahasiswa terverifikasi otomatis bisa **menyewa** dan **menyewakan** tanpa berganti mode.

- Saat melihat barang orang lain, ia berperan sebagai **penyewa**.
- Saat mengelola barang miliknya sendiri, ia berperan sebagai **pemilik**.
- Kedua peran hidup berdampingan di satu antarmuka. "Barang Saya" dan "Sewaan Saya" hanyalah dua bagian berbeda, bukan dua aplikasi.

Admin (peninjau KTM dan sengketa) **tidak** ada di app mobile ini; direncanakan sebagai dashboard terpisah nanti. App ini fokus penuh ke sisi mahasiswa.

## 3. Status MVP: UI-First

> **Fokus proyek: UI/UX frontend dulu; integrasi backend menyusul.** MVP UI-first selesai (v0.9.0); Pesan (M9) serta aturan transaksi & placeholder (M10) sudah menyusul. Barter (M11) juga sudah menyusul; integrasi Spring Boot jadi milestone terakhir (M12).

Rilis pertama fokus membangun **seluruh tampilan dengan data contoh (mock/dummy)**, belum tersambung backend. Tujuannya: alur dan tampilan bisa dilihat, diklik, dan dipresentasikan lebih dulu; integrasi API menyusul tanpa mengubah tampilan.

Konsekuensi teknis (penting untuk Claude Code):
- Semua data berasal dari **repository palsu** (`FakeRepository`) yang mengembalikan data contoh dengan sedikit jeda buatan (agar skeleton loading terlihat).
- Kontrak repository (`interface`/abstract class) dibuat sejak awal, sehingga nanti tinggal mengganti implementasi palsu dengan yang memanggil API, tanpa menyentuh UI.
- Aksi yang butuh server (login, ajukan sewa, setujui) cukup mengubah state lokal dan menampilkan hasil yang meyakinkan.
- Tidak perlu memanggil Spring Boot, kamera asli, atau upload nyata di tahap ini; cukup layar dan alurnya.

## 4. Fitur (MVP)

| Modul | Isi | Catatan |
|---|---|---|
| Splash & Onboarding | 3 layar ringkas nilai jual, bisa dilewati | Tampil sekali |
| Autentikasi | Daftar, masuk (email kampus/NIM), lupa password | Data contoh |
| Verifikasi KTM | Form data diri, "upload" KTM, "selfie" pegang KTM, status akun | Simulasi: langsung ke status Menunggu Peninjauan |
| Status Akun | Belum Terverifikasi / Menunggu Peninjauan / Terverifikasi | Membatasi aksi tertentu |
| Beranda | Pencarian, filter kategori, "Populer di Kampus", kartu barang | Layar penyewa |
| Detail Barang | Foto, deskripsi, rating pemilik, kalender ketersediaan | Kalender menandai tanggal terpakai |
| Ajukan Sewa | Pilih tanggal mulai & kembali, ringkasan biaya, konfirmasi | Validasi bentrok jadwal di UI |
| Sewaan Saya | Daftar pengajuan & sewa aktif sebagai penyewa, status per tahap | Menunggu / Disetujui / Berlangsung / Selesai |
| Barang Saya | Tambah/ubah/hapus barang, daftar pengajuan masuk, setujui/tolak | Sisi pemilik |
| Checklist Serah Terima | Checklist kondisi awal & akhir, "foto" bukti, persetujuan dua pihak | Simulasi tanda tangan/persetujuan |
| Rating & Ulasan | Beri 1-5 bintang + ulasan pasca-sewa | Muncul di profil |
| Profil | Avatar, badge "Terverifikasi", reputasi, riwayat, edit profil | Personalisasi |
| Pengaturan | Tema (gelap/terang/ikuti sistem), notifikasi, akun, tentang, keluar | Konfirmasi sebelum keluar |
| Aktivitas | Notifikasi & riwayat (pengajuan, persetujuan, pengingat kembali) | Dikelompokkan per hari |
| Pesan | Chat penyewa–pemilik per barang, usulan titik COD, pesan sistem dari kejadian sewa | M9; balasan lawan disimulasikan |

### Setelah MVP (integrasi & lanjutan)
- Integrasi REST API Spring Boot, autentikasi JWT, RBAC.
- Upload KTM & foto barang sungguhan (kamera/galeri, kompresi).
- Validasi bentrok jadwal otoritatif di backend.
- Pelaporan & sengketa ke admin, push notification.
- Dashboard admin terpisah (di luar app ini).

### Aturan transaksi

Keputusan M10 yang berlaku di aplikasi (dan di draf Syarat Layanan):

- **Pembayaran COD ke pemilik.** Tidak ada pembayaran di aplikasi. Penyewa membayar tunai atau transfer langsung ke pemilik saat serah terima. Pemilik mencatatnya di checklist ambil barang (metode + "Pembayaran sudah diterima"); tanpa itu pemilik tidak bisa menyetujui serah terima. Status tampil sebagai badge "Belum bayar" / "Lunas".
- **Denda keterlambatan.** Pemilik menetapkan denda per hari saat menambah barang (saran 50% harga sewa, atau tanpa denda). Denda = hari terlambat × denda per hari, dihitung dari tanggal kembali. Sewaan Saya menampilkan denda sementara; di checklist pengembalian pemilik mengonfirmasi "Denda diterima" sebelum menyetujui, lalu nilainya disimpan di sewa.
- **Pembatalan setelah disetujui.** Penyewa (Sewaan Saya) atau pemilik (Barang Saya) boleh membatalkan dengan alasan wajib. Sampai H-1 sebelum tanggal ambil: bebas. Hari H: tetap boleh, tetapi tercatat sebagai pembatalan mendadak di profil yang membatalkan dan terlihat oleh pengguna lain. Sewa yang sudah berlangsung tidak bisa dibatalkan. Pihak lain mendapat notifikasi dan pesan sistem, dan tanggalnya terbuka lagi.
- **Laporan kerusakan & sengketa.** Kalau ada item checklist pengembalian yang tidak dicentang, pihak mana pun bisa membuat laporan kerusakan dengan foto sebelum/sesudah dan usulan penyelesaian (perbaikan ditanggung penyewa, ganti rugi + nominal, atau diskusi). Pihak terlapor menerima usulan atau mengajukan banding; banding diteruskan ke tim HobbySwap. Laporan perilaku pengguna (dari chat/profil) langsung ditinjau tim.
- **Barter (M11): tukar pinjam sementara.** Dua mahasiswa saling meminjamkan barang untuk tanggal yang sama, lalu keduanya mengembalikan. Tanpa uang: totalHarga 0 dan tidak ada pembayaran COD. Pemilik menandai barang "Terima tawaran barter" dan kategori yang dicari. Pengaju memilih barang aktif miliknya dan tanggal yang kosong di kedua barang. Pemilik bisa menerima, menolak, atau meminta barang lain (pengaju lalu menyetujui atau membatalkan). Barter yang disetujui mengunci tanggal di kedua barang. Checklist diisi per barang oleh kedua pihak: berlangsung setelah checklist awal kedua barang beres, selesai setelah checklist akhir keduanya. Denda telat berlaku untuk masing-masing barang, pembatalan dan laporan kerusakan mengikuti aturan yang sama, dan keduanya saling memberi rating.
- **Data demo tersimpan.** Semua repository palsu menyimpan datanya di perangkat (shared_preferences + JSON), jadi tidak kembali ke awal saat app dibuka ulang. Profil → Alat pengembang → Reset data contoh mengembalikannya.

## 5. Navigasi

Bottom navigation 4 tab, ditambah FAB untuk menyewakan barang:

```text
Beranda      Sewaan Saya      Barang Saya      Profil
                                  (+)  FAB "Sewakan Barang"
```

```text
Splash
 └─ Onboarding (sekali)
     └─ Auth ── Masuk / Daftar / Lupa Password
         └─ Verifikasi KTM (jika belum) ── Status Akun
             └─ Shell (bottom nav)
                 ├─ Beranda ── Detail Barang ── Ajukan Sewa ── Konfirmasi
                 │   └─ Pesan (kotak masuk) ── Ruang obrolan
                 ├─ Sewaan Saya ── Detail Sewa ── Checklist ── Rating
                 ├─ Barang Saya ── Tambah/Ubah Barang
                 │                └─ Pengajuan Masuk ── Setujui/Tolak
                 └─ Profil ── Edit Profil / Pengaturan / Aktivitas
```

Pilihan, filter, dan konfirmasi memakai bottom sheet. Kedalaman navigasi maksimal 3 level dari tab. Aksi utama tiap layar ada di bawah (tombol lebar penuh atau FAB).

## 6. Entitas Data (model)

Dibuat sebagai model Dart (freezed) sejak awal, dipakai oleh data contoh maupun API nanti.

- **User** — id, nama, nim, email, fotoProfil, **fakultas** (nullable; M4), **prodi**, **bio** (nullable, maks. 120), **warnaAvatar** (salah satu dari 6 preset; avatar inisial) (M7), statusVerifikasi (`belum`/`menunggu`/`terverifikasi`), rating rata-rata, jumlahUlasan. **jumlahBatalMendadak** (M10; pembatalan di hari H).
- **Item** (barang) — id, ownerId, judul, deskripsi, kategori, hargaPerHari, daftarFoto, lokasiKampus, rentangTidakTersedia, **jumlahDisewa** (berapa kali pernah disewa; untuk urutan "Populer", M3), **aktif** (bool, diatur pemilik; `false` = tidak tampil di Beranda & tidak bisa disewa; menggantikan field `tersedia` M3 di M5). Status tampil **tidak disimpan**, tetapi diturunkan menjadi `ItemStatus`: `nonaktif` (aktif = false) → `disewa` (ada sewa `berlangsung` yang mencakup hari ini) → `tersedia`. **dendaPerHari** (M10; 0 = tanpa denda). **bisaBarter**, **minatBarter** (daftar kategori yang dicari; M11).
- **Category** — id, nama, ikon.
- **Booking** (sewa) — id, itemId, penyewaId, tanggalMulai, tanggalKembali, totalHarga, status (`menunggu`/`disetujui`/`ditolak`/`berlangsung`/`selesai`/`dibatalkan`), **pesan** (nullable; pesan penyewa untuk pemilik), **dibuatPada** (M4), **alasanTolak** (nullable; diisi pemilik saat menolak, atau sistem saat pengajuan bertumpuk otomatis ditolak karena pengajuan lain disetujui; M5). Tanggal disimpan tanpa jam; rentang inklusif (9–11 Okt = 3 hari); hanya status `disetujui`/`berlangsung` yang mengunci tanggal. **M10:** statusBayar (`belum`/`lunas`), metodeBayar (`tunai`/`transfer`), dibayarPada, dendaTerlambat (Rp, dicatat saat pengembalian), dibatalkanOleh, alasanBatal. **M11:** jenis (`sewa`/`barter`), itemTawaranId (barang milik pengaju), perluTanggapanPengaju (pemilik meminta barang lain), dendaTawaran.
- **HandoverChecklist** — bookingId, tahap, **itemId** (M11; null = barang utama, id barang tawaran untuk barter) (`awal`/`akhir`), daftarKondisi (tiap item: label, dicek, foto opsional), daftarFoto (diturunkan dari foto di tiap item), disetujuiPemilik, disetujuiPenyewa, **catatan**, **disetujuiPemilikPada**, **disetujuiPenyewaPada** (M6). Minimal 2 foto bukti; item yang tidak dicentang wajib dijelaskan di catatan. Kedua pihak setuju di tahap awal → sewa `berlangsung`; di tahap akhir → `selesai`. Template 5 item per kategori.
- **Review** — id, bookingId, dariUserId, keUserId, itemId, bintang (1-5), teks, tanggal, **peran** (`penyewaMenilaiPemilik`/`pemilikMenilaiPenyewa`), **tag** (list) (M6). Satu ulasan per pihak per sewa selesai; bintang 1–2 wajib cerita minimal 10 karakter. Ulasan memperbarui rating rata-rata & jumlahUlasan user yang dinilai.
- **NotificationItem** — id, **userId**, tipe (`pengajuanBaru`/`pengajuanDisetujui`/`pengajuanDitolak`/`pengingatAmbil`/`pengingatKembali`/`terlambat`/`giliranChecklist`/`ulasanBaru`/`verifikasiDisetujui`), judul, isi, tanggal, sudahDibaca, **tautan** (rute tujuan) (M7). Dibuat otomatis dari kejadian (pengajuan, persetujuan/penolakan, checklist, ulasan, verifikasi); pengingat H-1 ambil, H-1/hari H kembali, dan terlambat dihitung dari tanggal sewa.
- **ChatThread** (M9) — id, participantIds (tepat 2 user), itemId, bookingId (nullable; sewa terbaru pasangan ini untuk barang tsb.), lastMessageAt, unreadCount (per user), muted (per user). Satu thread per pasangan user + barang; `openOrCreate` tidak membuat ganda.
- **ChatMessage** (M9) — id, threadId, senderId (null = pesan sistem), tipe (`teks`/`foto`/`lokasiCod`/`sistem`), isi, payload (Map: lokasi & waktu COD serta status usulan `menunggu`/`disetujui`/`usulLain`; jenis kejadian untuk pesan sistem), sentAt, readAt (null = belum dibaca lawan). Pesan sistem otomatis masuk saat pengajuan dikirim, disetujui, ditolak, serah terima selesai, dan pengembalian selesai.
- **Laporan** (M10) — id, bookingId (nullable; laporan pengguna tanpa sewa), pelaporId, terlaporId, jenis (`kerusakan`/`keterlambatan`/`perilaku`/`lainnya`), itemChecklistBermasalah, deskripsi (20–500 karakter), fotoBukti, usulan (`perbaikanPenyewa`/`gantiRugi`/`diskusi`), nominal, status (`menungguTanggapan`/`diterima`/`dibanding`/`selesai`), riwayat (daftar kejadian untuk timeline).
- **Favorit** (M10) — daftar id barang per user, tersimpan di perangkat.

## 7. Teknologi & Struktur

| Kebutuhan | Pilihan |
|---|---|
| Framework | Flutter (stable terbaru), Dart 3, Material 3 |
| State management | Riverpod |
| Routing | go_router |
| Model | freezed + json_serializable |
| Data (MVP) | Repository palsu di memori dengan data contoh |
| Backend (nanti) | Java Spring Boot REST API, MySQL/PostgreSQL, JWT |
| Penyimpanan lokal | shared_preferences (tema, onboarding), flutter_secure_storage (token, nanti) |
| Lint | flutter_lints atau very_good_analysis |
| Pengujian | flutter_test, mocktail |

```text
lib/
├── main.dart
├── app.dart                      # MaterialApp.router + tema
├── core/
│   ├── theme/                    # token dari DESIGN.md → ThemeData + ThemeExtension
│   ├── router/                   # go_router
│   ├── widgets/                  # AppButton, AppCard, AppTextField, AppChip,
│   │                             # AppBottomSheet, AppSkeleton, AppEmptyState, AppBottomNav
│   ├── utils/                    # formatter tanggal/harga, validator
│   └── constants/
├── features/
│   ├── onboarding/
│   ├── auth/                     # data / domain / presentation
│   ├── verification/             # verifikasi KTM & status akun
│   ├── home/                     # beranda + pencarian + filter
│   ├── item/                     # detail barang, tambah/ubah barang (Barang Saya)
│   ├── booking/                  # ajukan sewa, Sewaan Saya, pengajuan masuk
│   ├── handover/                 # checklist serah terima
│   ├── review/                   # rating & ulasan
│   ├── activity/                 # notifikasi & riwayat
│   └── profile/                  # profil + pengaturan
├── data/
│   └── fake/                     # FakeRepository + data contoh (sample_data.dart)
└── l10n/
```

Aturan: satu fitur = folder dengan lapisan `data`/`domain`/`presentation`; widget lintas fitur di `core/widgets`; warna/ukuran/font hanya lewat `core/theme`.

## 8. Roadmap

| | Milestone | Isi | Hasil |
|---|---|---|---|
| ✅ | M0 Fondasi | Project, lint, tema (token DESIGN.md), router, komponen dasar, model freezed, FakeRepository + data contoh | Kerangka siap, data contoh mengalir |
| ✅ | M1 Onboarding & Auth | Splash, onboarding, daftar, masuk, lupa password | Pengguna bisa masuk (simulasi) |
| ✅ | M2 Verifikasi KTM | Form, "upload" KTM & selfie, status akun, pembatasan aksi | Alur verifikasi utuh |
| ✅ | M3 Shell & Beranda | Bottom nav, beranda bento, pencarian, filter, skeleton | Navigasi utama & jelajah jalan |
| ✅ | M4 Detail & Ajukan Sewa | Detail barang, kalender ketersediaan, ajukan sewa, validasi bentrok di UI | Penyewa bisa mengajukan |
| ✅ | M5 Barang Saya & Pengajuan | Tambah/ubah/hapus barang, pengajuan masuk, setujui/tolak | Sisi pemilik jalan |
| ✅ | M6 Sewaan, Checklist, Rating | Sewaan Saya, checklist serah terima, rating & ulasan | Siklus sewa lengkap |
| ✅ | M7 Profil, Pengaturan, Aktivitas | Profil, edit, tema, notifikasi, aktivitas | Personalisasi lengkap |
| ✅ | M8 Polesan | Animasi, haptic, aksesibilitas, empty/error state, uji | Siap demo/presentasi |
| ✅ | M9 Pesan | Kotak masuk, ruang obrolan, usulan COD, pesan sistem sewa, titik masuk dari Beranda/Detail/Sewaan/Pengajuan/Checklist | Penyewa & pemilik bisa berkoordinasi |
| ✅ | M10 Aturan transaksi & placeholder | COD, denda, pembatalan, laporan & sengketa, lupa password, masuk dengan Google (simulasi), Syarat & Privasi, hapus akun, favorit, data demo tersimpan | Tidak ada jalan buntu di UI |
| ✅ | M11 Barter | Tukar pinjam sementara: tawarkan barter 3 langkah, counter "minta barang lain", checklist per barang, rating dua arah | Alternatif selain sewa |
| ⬜ | M12 Integrasi backend (terakhir) | Ganti FakeRepository dengan API Spring Boot, JWT, upload nyata, chat real-time | Tersambung backend |

## 9. Standar Kualitas

- Setiap layar punya state: loading (skeleton), kosong, error, sukses.
- Data contoh dibuat realistis (nama barang, foto placeholder, harga wajar) agar demo meyakinkan.
- Kontrak repository memisahkan UI dari sumber data sejak awal.
- Tap target minimal 48 dp; kontras teks minimal 4.5:1; dark & light diuji tiap layar.
- Tidak ada rahasia (API key/token) di repositori.
- `flutter analyze` bersih sebelum commit; logika penting diberi unit test.

## 10. Menjalankan Project

```bash
flutter doctor
flutter pub get
flutter run
```

Di tahap MVP tidak perlu menjalankan backend; semua data dari `data/fake/`.

### Akun contoh

Semua akun memakai password `hobbyswap2026`. Jadwal sewa contoh dibuat relatif terhadap hari ini.

| Nama | Email | NIM | Status | Catatan |
|---|---|---|---|---|
| Gregorian | gregorian@students.usu.ac.id | 220401087 | Terverifikasi | Pemilik 4 barang; ada 3 pengajuan masuk, 1 barang disewa, 1 nonaktif |
| Aulia Putri | aulia@students.usu.ac.id | 220402011 | Belum | Uji alur verifikasi KTM |
| Rizky Nugraha | rizky@students.usu.ac.id | 210401034 | Terverifikasi | Pemilik barang contoh |
| Sarah Manurung | sarah@students.usu.ac.id | 210903052 | Terverifikasi | Pemilik barang contoh |
| Dimas Ramadhan | dimas@students.usu.ac.id | 220503019 | Terverifikasi | Pemilik barang contoh |

### Build rilis

```bash
flutter build apk --release   # hasil: build/app/outputs/flutter-apk/app-release.apk
# Kalau Windows memblokir gen_snapshot x64 (Smart App Control), cukup build untuk HP:
flutter build apk --release --target-platform android-arm,android-arm64
```

Ikon & splash native dibuat dari `assets/icon/`, `assets/brand/`, dan `assets/splash/`; setelah mengubahnya jalankan `dart run flutter_launcher_icons` dan `dart run flutter_native_splash:create`.

### Cara demo (5 menit)

Jalankan versi debug (`flutter run`) supaya menu **Alat pengembang** di tab Profil tersedia; menu itu disembunyikan di APK rilis. Kalau data sudah terpakai, buka Profil → Alat pengembang → **Reset data contoh**.

1. **Daftar (± 45 detik).** Lewati onboarding → **Daftar**. Isi nama, NIM 9 digit, email `…@students.usu.ac.id`, dan password (huruf + angka) → *Lanjut ke verifikasi KTM*.
2. **Verifikasi (± 45 detik).** Ketuk slot KTM dan selfie (foto contoh) → *Kirim untuk ditinjau* → layar status "sedang ditinjau". Ketuk *Jelajah barang dulu* → tab **Profil** → Alat pengembang → *Simulasikan KTM disetujui*.
3. **Sewa (± 1 menit).** Tab **Beranda** → pilih **Sony A6400** → pilih tanggal mulai & kembali yang tidak dicoret di kalender → *Ajukan Sewa* → tulis pesan singkat → *Kirim pengajuan*.
4. **Pemilik menyetujui (± 1 menit).** Profil → *Keluar* → masuk sebagai pemilik `rizky@students.usu.ac.id` / `hobbyswap2026` → lonceng Beranda menampilkan pengajuan baru → tab **Barang** → kartu *Pengajuan baru menunggu* → *Terima*. Keluar lagi.
5. **Checklist (± 1 menit).** Masuk dengan akun baru tadi → notifikasi "Pengajuanmu disetujui" → tab **Sewaan** → *Checklist serah terima*: centang kelima kondisi, tambahkan minimal 2 foto bukti → *Setujui serah terima*. Pemilik menyetujui otomatis (simulasi ± 2 detik) dan sewa menjadi **Berlangsung**. Buka lagi checklist-nya untuk pengembalian → *Setujui pengembalian* → sewa **Selesai**.
6. **Rating (± 30 detik).** Segmen **Riwayat** → *Beri rating* → pilih bintang, tag, dan cerita singkat → *Kirim ulasan*. Ulasan tampil di profil pemilik.

Jalur singkat tanpa daftar: masuk sebagai `gregorian@students.usu.ac.id` (sudah terverifikasi, punya sewa aktif, pengajuan masuk, dan sewa selesai yang belum dirating). Ikon pesan di Beranda membuka 4 obrolan contoh; kirim pesan dan lawan membalas otomatis dalam 1,5–3 detik.

## 11. Instruksi untuk Claude Code

- Baca `README.md` dan `DESIGN.md` sebelum mengerjakan apa pun.
- Kerjakan **per milestone berurutan**; jangan melompat ke milestone berikutnya kecuali diminta.
- Tahap ini **UI-first**: sumber data adalah `FakeRepository`, bukan API. Selalu lewat kontrak repository, jangan hardcode data di widget.
- Pakai ulang komponen di `core/widgets`; jangan buat duplikat.
- Setiap layar baru: dukung dark & light, pakai safe area, sediakan state loading/empty/error.
- Jangan menambah package tanpa alasan; sebutkan alasannya saat menambah.
- Setelah mengubah kode, jalankan `flutter analyze` (dan test bila ada), lalu laporkan hasilnya.
- Jika instruksi pengguna bertentangan dengan dokumen ini, ikuti pengguna dan sebutkan konfliknya secara singkat.
