# CLAUDE.md

Wajib baca `README.md` (produk, arsitektur, roadmap) dan `DESIGN.md` (token & aturan UI) sebelum mengerjakan apa pun. Kerjakan per milestone; jangan melompat kecuali diminta.

## Perintah

```bash
flutter pub get
dart run build_runner build   # setelah mengubah model freezed/json
flutter analyze               # harus bersih
flutter test
flutter run
```

Catatan: `--delete-conflicting-outputs` sudah dihapus di build_runner 2.16+; jangan dipakai.

Setelah mengubah blok `flutter_native_splash:` di pubspec: `dart run flutter_native_splash:create`.

Reset onboarding & sesi di HP/emulator: `adb shell pm clear com.example.hobby_swab` (atau hapus data aplikasi).

## Gaya kerja

- Jangan narasikan proses ("oke, sekarang saya cek…", "saya akan membaca…"). Langsung kerjakan.
- Jangan tampilkan rencana, dan jangan tempel ulang kode di chat.
- Bertanya hanya kalau benar-benar buntu atau keputusannya tidak bisa dibatalkan.
- Laporan akhir maksimal 5 baris:
  1. flutter analyze: OK/GAGAL
  2. flutter test: OK/GAGAL (jumlah lulus/gagal)
  3. Jumlah file dibuat/diubah/dihapus (tanpa daftar)
  4. Hal yang butuh keputusanku (kalau ada)
  5. Cara mencoba (maks 2 baris, kalau perlu)

## Aturan

- Warna, ukuran, radius, spacing, dan font **hanya lewat token** di `lib/core/theme/` (`AppColors`, `AppSpacing`, `AppRadius`, `AppSizes`, `textTheme`). Tidak ada hex/angka ukuran di widget. Token baru ditambahkan di sana dulu.
- Semua teks UI berbahasa Indonesia, nada santai sopan ("kamu").
- Data selalu lewat kontrak repository di `features/*/domain/` + provider Riverpod; implementasi palsu memakai `lib/data/fake/sample_data.dart`. Jangan hardcode data di widget.
- Pakai ulang `lib/core/widgets/` (AppButton, AppTextField, HsLogoMark, ...); jangan buat duplikat.
- Rute didefinisikan di `lib/core/router/` (`AppRoutes`), navigasi pakai `context.go`/`context.push`.
- Setiap layar: dark & light, `SafeArea`, tap target ≥ 48, state loading/empty/error.
- `legacy/v0/` berisi kode versi awal untuk referensi saja (dikecualikan dari analyzer, tidak di-build).

## Akun demo

Password keduanya `hobbyswap2026`:

- Terverifikasi: `gregorian@students.usu.ac.id` / NIM `220401087`
- Belum verifikasi (uji alur KTM): `aulia@students.usu.ac.id` / NIM `220402011`
- Pemilik barang contoh (terverifikasi): `rizky@`, `sarah@`, `dimas@students.usu.ac.id`

Alat bantu debug (hanya debug build) ada di tab Profil: setujui verifikasi, dan gagalkan muat barang berikutnya untuk menguji state error.

Aksi yang butuh akun terverifikasi (ajukan sewa, sewakan barang) wajib lewat `requireVerified()` di `lib/core/guards/`.
