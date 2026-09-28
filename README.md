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

### Setelah MVP (integrasi & lanjutan)
- Integrasi REST API Spring Boot, autentikasi JWT, RBAC.
- Upload KTM & foto barang sungguhan (kamera/galeri, kompresi).
- Validasi bentrok jadwal otoritatif di backend.
- Pelaporan & sengketa ke admin, push notification, chat penyewa-pemilik.
- Dashboard admin terpisah (di luar app ini).

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
                 ├─ Sewaan Saya ── Detail Sewa ── Checklist ── Rating
                 ├─ Barang Saya ── Tambah/Ubah Barang
                 │                └─ Pengajuan Masuk ── Setujui/Tolak
                 └─ Profil ── Edit Profil / Pengaturan / Aktivitas
```

Pilihan, filter, dan konfirmasi memakai bottom sheet. Kedalaman navigasi maksimal 3 level dari tab. Aksi utama tiap layar ada di bawah (tombol lebar penuh atau FAB).

## 6. Entitas Data (model)

Dibuat sebagai model Dart (freezed) sejak awal, dipakai oleh data contoh maupun API nanti.

- **User** — id, nama, nim, email, fotoProfil, **fakultas** (nullable; ditampilkan di kartu pemilik, ditambahkan di M4), statusVerifikasi (`belum`/`menunggu`/`terverifikasi`), rating rata-rata, jumlahUlasan.
- **Item** (barang) — id, ownerId, judul, deskripsi, kategori, hargaPerHari, daftarFoto, lokasiKampus, rentangTidakTersedia, **jumlahDisewa** (berapa kali pernah disewa; untuk urutan "Populer", M3), **aktif** (bool, diatur pemilik; `false` = tidak tampil di Beranda & tidak bisa disewa; menggantikan field `tersedia` M3 di M5). Status tampil **tidak disimpan**, tetapi diturunkan menjadi `ItemStatus`: `nonaktif` (aktif = false) → `disewa` (ada sewa `berlangsung` yang mencakup hari ini) → `tersedia`.
- **Category** — id, nama, ikon.
- **Booking** (sewa) — id, itemId, penyewaId, tanggalMulai, tanggalKembali, totalHarga, status (`menunggu`/`disetujui`/`ditolak`/`berlangsung`/`selesai`/`dibatalkan`), **pesan** (nullable; pesan penyewa untuk pemilik), **dibuatPada** (M4), **alasanTolak** (nullable; diisi pemilik saat menolak, atau sistem saat pengajuan bertumpuk otomatis ditolak karena pengajuan lain disetujui; M5). Tanggal disimpan tanpa jam; rentang inklusif (9–11 Okt = 3 hari); hanya status `disetujui`/`berlangsung` yang mengunci tanggal.
- **HandoverChecklist** — bookingId, tahap (`awal`/`akhir`), daftarKondisi (tiap item: label, dicek, foto opsional), daftarFoto (diturunkan dari foto di tiap item), disetujuiPemilik, disetujuiPenyewa, **catatan**, **disetujuiPemilikPada**, **disetujuiPenyewaPada** (M6). Minimal 2 foto bukti; item yang tidak dicentang wajib dijelaskan di catatan. Kedua pihak setuju di tahap awal → sewa `berlangsung`; di tahap akhir → `selesai`. Template 5 item per kategori.
- **Review** — id, bookingId, dariUserId, keUserId, itemId, bintang (1-5), teks, tanggal, **peran** (`penyewaMenilaiPemilik`/`pemilikMenilaiPenyewa`), **tag** (list) (M6). Satu ulasan per pihak per sewa selesai; bintang 1–2 wajib cerita minimal 10 karakter. Ulasan memperbarui rating rata-rata & jumlahUlasan user yang dinilai.
- **NotificationItem** — id, tipe, judul, isi, tanggal, sudahDibaca.

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

| Milestone | Isi | Hasil |
|---|---|---|
| M0 Fondasi | Project, lint, tema (token DESIGN.md), router, komponen dasar, model freezed, FakeRepository + data contoh | Kerangka siap, data contoh mengalir |
| M1 Onboarding & Auth | Splash, onboarding, daftar, masuk, lupa password | Pengguna bisa masuk (simulasi) |
| M2 Verifikasi KTM | Form, "upload" KTM & selfie, status akun, pembatasan aksi | Alur verifikasi utuh |
| M3 Shell & Beranda | Bottom nav, beranda bento, pencarian, filter, skeleton | Navigasi utama & jelajah jalan |
| M4 Detail & Ajukan Sewa | Detail barang, kalender ketersediaan, ajukan sewa, validasi bentrok di UI | Penyewa bisa mengajukan |
| M5 Barang Saya & Pengajuan | Tambah/ubah/hapus barang, pengajuan masuk, setujui/tolak | Sisi pemilik jalan |
| M6 Sewaan, Checklist, Rating | Sewaan Saya, checklist serah terima, rating & ulasan | Siklus sewa lengkap |
| M7 Profil, Pengaturan, Aktivitas | Profil, edit, tema, notifikasi, aktivitas | Personalisasi lengkap |
| M8 Polesan | Animasi, haptic, aksesibilitas, empty/error state, uji | Siap demo/presentasi |
| M9 Integrasi (pasca-MVP) | Ganti FakeRepository dengan API Spring Boot, JWT, upload nyata | Tersambung backend |

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

## 11. Instruksi untuk Claude Code

- Baca `README.md` dan `DESIGN.md` sebelum mengerjakan apa pun.
- Kerjakan **per milestone berurutan**; jangan melompat ke milestone berikutnya kecuali diminta.
- Tahap ini **UI-first**: sumber data adalah `FakeRepository`, bukan API. Selalu lewat kontrak repository, jangan hardcode data di widget.
- Pakai ulang komponen di `core/widgets`; jangan buat duplikat.
- Setiap layar baru: dukung dark & light, pakai safe area, sediakan state loading/empty/error.
- Jangan menambah package tanpa alasan; sebutkan alasannya saat menambah.
- Setelah mengubah kode, jalankan `flutter analyze` (dan test bila ada), lalu laporkan hasilnya.
- Jika instruksi pengguna bertentangan dengan dokumen ini, ikuti pengguna dan sebutkan konfliknya secara singkat.
