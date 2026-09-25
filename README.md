# HobbySwap

Aplikasi pinjam-meminjam barang hobi antar mahasiswa. Frontend Flutter dengan data simulasi (tanpa backend).

## Persona utama

**Rani Putri, mahasiswi rantau semester 3.** Ingin mencoba hobi baru (camping, fotografi, musik) tanpa harus membeli alat mahal. Ia juga punya beberapa barang yang jarang dipakai dan mau meminjamkannya ke teman sekampus.

## Alur pengguna

| Alur | Layar terlibat | Hasil akhir |
|---|---|---|
| Meminjam barang | Katalog → Detail barang → Form pengajuan | Pengajuan muncul di "Pinjaman saya" |
| Mengelola pengajuan | Pinjaman saya → Detail pengajuan → Edit / Konfirmasi hapus | Status dan jumlah per status diperbarui |
| Mengelola barang sendiri | Barang saya → Tambah/Edit barang → Detail → Hapus | Katalog memakai data terbaru |
| Preferensi pengguna | Profil → Edit profil & pengaturan | Profil, mode gelap, simulasi gagal tersimpan selama sesi |

## Peta layar & rute

| Layar | Rute |
|---|---|
| Splash | `/` |
| Beranda (Katalog, Pinjaman saya, Barang saya, Profil) | `/home` |
| Detail barang | `/item/:id` |
| Form pengajuan (tambah) | `/item/:id/borrow` |
| Form barang (tambah / edit) | `/items/new`, `/item/:id/edit` |
| Detail pengajuan | `/loan/:id` |
| Form pengajuan (edit) | `/loan/:id/edit` |
| Edit profil & pengaturan | `/profile/edit` |
| Halaman tidak ditemukan | rute lain / ID salah |

Semua rute bisa dibuka langsung (misalnya lewat URL di web). ID yang salah menampilkan pesan "tidak ditemukan" dan tombol kembali ke beranda.

## Struktur kode

```
lib/
  models.dart               Category, Item, Loan, UserProfile (relasi lewat ID)
  validators.dart           Validasi form (fungsi murni, mudah diuji)
  data/seed_data.dart       5 kategori, 20 barang, 4 pengajuan
  data/mock_repository.dart Repository simulasi: jeda 700 ms + opsi gagal
  data/app_store.dart       State bersama (ChangeNotifier) + AppScope
  widgets/common.dart       Komponen bersama: kartu, tombol utama, empty/error/loading state, dialog
  screens/                  Semua layar
  main.dart                 Tema, peta rute
```

- **CRUD 1: Pengajuan pinjaman** (`Loan.itemId` → `Item.id`)
- **CRUD 2: Barang milik sendiri** (`Item.categoryId` → `Category.id`)
- **State async:** loading saat memuat, empty state dengan petunjuk tindakan, error state dengan tombol **Coba lagi**. Aktifkan *Simulasi gagal jaringan* di Profil → Edit profil & pengaturan, lalu tarik untuk memuat ulang katalog.
- **Cegah data ganda:** tombol submit nonaktif selama proses, store menolak aksi yang sama saat masih berjalan, dan satu barang hanya boleh punya satu pengajuan aktif.
- **Responsif:** grid katalog menyesuaikan lebar. Di layar ≥ 900 px, navigasi pindah ke NavigationRail dan form dibatasi lebarnya.

## Menjalankan

```bash
flutter pub get
flutter run
flutter test
```

## Matriks uji

Tes otomatis ada di `test/store_test.dart` (logika) dan `test/widget_test.dart` (UI), total 28 tes.

| Area | Skenario |
|---|---|
| CRUD | Tambah pengajuan valid, edit pengajuan, hapus pengajuan, batal hapus (dialog), tambah/edit/hapus barang |
| Validasi | Field kosong, batas panjang, format nomor WA, tanggal lampau / > 30 hari, pilihan wajib, persetujuan syarat |
| Data & state | Filter gabungan (kategori + tersedia + kata kunci), hasil kosong + reset, relasi ID valid, jumlah per status ikut berubah |
| Navigasi | Back dari detail, ID salah, rute tak dikenal, akses rute langsung |
| Async simulasi | Loading tampil, gagal memuat, Coba lagi berhasil, simpan gagal tidak mengubah data, ketukan ganda hanya menyimpan 1 data |
| Tampilan | Katalog tanpa overflow di lebar 360, 768, 1280 px; nama panjang dipotong dengan ellipsis |

## Pembagian kerja (usulan)

- **Penjaga kontrak data:** `models.dart`, `data/`, `validators.dart`, `test/store_test.dart`
- **Fitur Katalog & Detail barang:** `catalog_tab.dart`, `item_detail_screen.dart`
- **Fitur Pengajuan:** `loan_form_screen.dart`, `my_loans_tab.dart`, `loan_detail_screen.dart`
- **Fitur Barang saya & Profil:** `my_items_tab.dart`, `item_form_screen.dart`, `profile_tab.dart`, `edit_profile_screen.dart`
