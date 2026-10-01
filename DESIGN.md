# DESIGN.md — Panduan Desain UI Mobile (Gen-Z)

> Dokumen ini adalah sumber kebenaran untuk tampilan aplikasi. Saat membuat atau mengubah UI, ikuti aturan di sini. Kalau ada konflik antara dokumen ini dan kebiasaan bawaan framework, dokumen ini menang. Kalau sebuah keputusan desain belum tercakup, pilih opsi paling sederhana yang konsisten dengan prinsip di bawah dan catat asumsinya.

## 0. Konteks Aplikasi

- Nama aplikasi: HobbySwap
- Tujuan satu kalimat: menyewa & menyewakan barang hobi antar mahasiswa satu kampus, aman lewat verifikasi KTM
- Target pengguna: mahasiswa (17-25), pengguna utama HP Android, layar 360-412 dp
- Fitur inti: verifikasi KTM, jelajah & sewa barang, kelola barang sendiri, checklist serah terima, rating
- Platform: Flutter (Dart 3), Material 3, Android-first
- Karakter visual: modern, profesional, terpercaya (bukan main-main), tetap enak dipakai satu tangan
- Identitas warna: mengikuti logo — hijau tua, hijau sedang, dan krem. Krem adalah ciri khas dan menjadi latar utama di light mode.
- Konteks lengkap produk dan arsitektur: lihat `README.md`
- Bahasa UI: Indonesia, nada santai tapi sopan (kamu, bukan Anda)

## 1. Prinsip Utama

1. **Satu layar, satu tujuan.** Jangan menumpuk banyak aksi setara di satu layar.
2. **Satu jempol.** Aksi utama harus terjangkau di bagian bawah layar.
3. **Visual dulu, teks belakangan.** Gunakan gambar, ikon, dan kartu sebelum paragraf.
4. **Terasa hidup.** Setiap sentuhan punya feedback (animasi kecil, haptic).
5. **Personal.** Pengguna bisa mengekspresikan diri (avatar, tema, profil).
6. **Cepat.** Onboarding singkat, form pendek, tidak ada langkah yang tidak perlu.

## 2. Design Tokens

Gunakan token ini sebagai konstanta terpusat (theme file). Jangan hardcode nilai di widget/komponen.

### 2.1 Warna

Aplikasi wajib mendukung **dark mode dan light mode**. Tema mengikuti pengaturan sistem (bisa diganti di Pengaturan). Light mode berlatar krem adalah wajah utama brand.

Palet diambil dari logo: hijau tua, hijau sedang, dan krem.

| Token | Dark | Light | Kegunaan |
|---|---|---|---|
| `bg` | `#12211B` | `#F2EFE6` | Latar layar (light = krem khas logo) |
| `surface` | `#1B2E26` | `#FBFAF5` | Kartu, sheet (krem lebih terang) |
| `surface-alt` | `#254034` | `#E9E4D6` | Input nonaktif, chip, tombol sekunder |
| `border` | `#2E4739` | `#DED8C7` | Garis tepi kartu, input, pembatas |
| `text-primary` | `#EEF2E9` | `#1A2C24` | Teks utama |
| `text-secondary` | `#9DB0A4` | `#546056` | Teks pendukung |
| `accent` | `#6B9E63` | `#1E4638` | Hijau — identitas HobbySwap, latar tombol utama, tab aktif |
| `on-accent` | `#0F221A` | `#F4F1E8` | Teks/ikon di atas `accent` |
| `accent-text` | `#8FBE86` | `#1E4638` | Link, harga, teks hijau di atas `bg`/`surface` |
| `accent-soft` | `#22392E` | `#DDE7D5` | Latar lembut untuk chip aktif, ikon, highlight hijau |
| `verified` | `#7FBF6E` | `#396631` | Badge terverifikasi, status sukses transaksi |
| `success` | `#7FBF6E` | `#396631` | Berhasil |
| `warning` | `#E5B860` | `#77561C` | Peringatan |
| `error` | `#EB917F` | `#9D3C29` | Gagal (warna tanah, selaras palet hangat) |

Catatan aksen:
- Di **light mode**, `accent` memakai hijau tua logo (`#1E4638`) agar kontras di atas krem terjaga.
- Di **dark mode**, `accent` memakai hijau sedang logo (`#6B9E63`) agar cukup terang di atas latar gelap.
- Hijau sedang (`#6B9E63`) boleh dipakai sebagai warna sekunder/ilustratif; hijau tua adalah warna aksi utama.
- Nilai `text-secondary`, `verified`, `warning`, dan `error` di light mode (serta `error` dark) digelapkan/diterangkan di M8 supaya kontras teks ≥ 4.5:1, termasuk di atas latar badge (tint 16%). Diuji di `test/core/contrast_test.dart`.

Aturan warna:
- Hijau (`accent`) adalah identitas dan warna aksi utama; **satu** aksi primer per layar.
- `verified` hanya untuk badge terverifikasi dan status sukses transaksi, jangan dipakai sebagai warna dekorasi umum. Karena senada dengan hijau aksen, bedakan dengan bentuk (badge + ikon centang), bukan hanya warna.
- Status sewa punya warna sendiri yang konsisten di seluruh app: Menunggu → `warning`, Disetujui/Berlangsung → `accent`, Selesai → `verified`, Ditolak/Dibatalkan → `error`. Sertakan juga label teks, jangan mengandalkan warna saja.
- Krem (`bg` light) adalah ciri khas; jangan menimpanya dengan putih murni. Jangan pakai hitam murni `#000000` atau putih murni `#FFFFFF` untuk latar.
- Kontras teks terhadap latar minimal 4.5:1 (WCAG AA).
- Nilai hex di atas adalah default awal; boleh diganti asal tetap konsisten lewat token.

### 2.2 Tipografi

- Font utama: `Plus Jakarta Sans` (fallback: `Inter`, `system-ui`)
- Judul layar: 28-32 sp, bobot 700-800
- Judul bagian: 20 sp, bobot 700
- Body: 15-16 sp, bobot 400-500
- Caption: 12-13 sp, bobot 500
- Line-height body: 1.4-1.5
- Judul dibuat besar dan tebal; jangan pakai teks di bawah 12 sp.

### 2.3 Spacing dan Bentuk

- Skala spacing (dp): `4, 8, 12, 16, 24, 32, 48`
- Padding horizontal layar: `16`
- Radius: kartu `20`, tombol `16` atau pill (`999`), input `14`, bottom sheet atas `28`
- Ukuran tap target minimal: `48 x 48 dp`
- Bayangan: lembut dan halus (blur besar, opasitas rendah). Di dark mode, utamakan perbedaan warna `surface` daripada bayangan.

## 3. Layout dan Navigasi

- **Bottom navigation bar** dengan 3-5 tab (ikon + label pendek). Tab aktif memakai `accent`.
- Aksi utama layar ditaruh di bawah: tombol lebar penuh atau **Floating Action Button** kanan bawah.
- Menu sekunder dan pilihan memakai **bottom sheet**, bukan dialog tengah atau menu berlapis.
- Dukung gesture: swipe untuk kembali, pull-to-refresh, long-press untuk opsi tambahan.
- Kedalaman navigasi maksimal 3 level dari tab utama.
- Gunakan safe area (notch, gesture bar); jangan ada konten yang terpotong.
- Konten scroll vertikal. Hindari scroll horizontal kecuali carousel kartu/story yang jelas terlihat bisa digeser.

## 4. Komponen

### Kartu (Card)
- Latar `surface`, radius 20, padding 16.
- Boleh memakai **bento grid**: kartu berukuran beda (1x1, 2x1, 2x2) untuk dashboard/beranda.
- Efek glassmorphism (blur + transparan) hanya untuk elemen melayang (bottom bar, header saat scroll), jangan untuk semua kartu.

### Tombol
- Primer: latar `accent`, teks putih, tinggi 52, radius 16 atau pill, satu per layar.
- Sekunder: latar `surface-alt`, teks `text-primary`.
- Teks/ghost: tanpa latar, teks `accent`.
- State wajib: default, pressed (skala 0.97), disabled (opasitas 0.4), loading (spinner kecil di dalam tombol).

### Input dan Form
- Latar `surface-alt`, radius 14, label mengambang atau placeholder jelas.
- Maksimal 4-5 field per layar; pecah form panjang menjadi beberapa langkah.
- Error ditampilkan inline di bawah field dengan warna `error` dan teks yang ramah.

### Chip dan Tag
- Bentuk pill, tinggi 32-36, dipakai untuk filter dan kategori.

### Loading
- Pakai **skeleton** (kotak abu berkilau halus) untuk daftar dan kartu; spinner hanya untuk aksi singkat.

### Empty State
- Ilustrasi sederhana + satu kalimat + satu tombol aksi. Nada santai.

### Avatar dan Profil
- Avatar bulat, bisa diganti; profil bisa dipersonalisasi (bio, warna tema, banner).
- Badge "Terverifikasi": ikon centang + teks, warna `verified`, ukuran kecil di sebelah nama.

### Pola Khusus HobbySwap

**Kartu Barang (ItemCard)**
- Foto barang rasio 4:3 di atas, radius mengikuti kartu, dengan chip kategori kecil melayang di pojok foto.
- Di bawah: judul (1-2 baris, dipotong), harga per hari (tebal, warna `accent`), lokasi kampus, dan rating pemilik (bintang + angka).
- Dipakai di beranda (grid 2 kolom) dan hasil pencarian.

**Badge Status Sewa (StatusBadge)**
- Bentuk pill kecil dengan titik warna + label teks, warna mengikuti aturan status di bagian 2.1.
- Wajib muncul di kartu Sewaan Saya, Pengajuan Masuk, dan detail sewa.

**Kalender Ketersediaan**
- Tandai tanggal yang sudah terpakai dengan jelas (misalnya dicoret/redup) sehingga tidak bisa dipilih.
- Rentang tanggal terpilih diberi warna `accent-soft` dengan ujung `accent`.
- Tampilkan ringkasan "X hari × harga = total" tepat sebelum tombol ajukan.

**Status Verifikasi Akun**
- Banner tipis di atas beranda saat akun `belum` atau `menunggu` terverifikasi, dengan ajakan menyelesaikan verifikasi.
- Aksi yang butuh verifikasi (ajukan sewa, tambah barang) menampilkan alasan yang ramah saat akun belum terverifikasi, bukan sekadar tombol nonaktif tanpa penjelasan.

**Checklist Serah Terima**
- Daftar item kondisi dengan toggle/checkbox besar dan slot "foto" bukti per item.
- Bagian persetujuan dua pihak di bawah, jelas siapa yang sudah menyetujui.

**Layar "Upload" (KTM, selfie, foto barang) di tahap UI-first**
- Tampilkan area unggah dengan ikon kamera dan garis putus-putus; saat ditekan, gunakan foto contoh/placeholder (belum kamera asli).
- Setelah "terisi", tampilkan pratinjau gambar dengan tombol ganti/hapus.

## 5. Motion dan Feedback

- Durasi transisi: 150-300 ms. Easing: `easeOutCubic` atau spring ringan.
- Tap: skala turun ke 0.97, lalu kembali. Sertakan **haptic ringan** untuk aksi penting (suka, kirim, konfirmasi).
- Transisi antar layar: halaman baru geser penuh dari kanan (gaya iOS, bisa swipe dari tepi kiri untuk kembali). Pindah tab bottom nav: geser 30% + fade dari arah tab tujuan. Bukan lompatan mendadak.
- Aksi berhasil: animasi kecil (centang, konfeti ringan untuk momen spesial saja).
- Hormati pengaturan sistem "reduce motion": kurangi atau matikan animasi.

## 6. Nada Bahasa (Copywriting)

- Santai, singkat, hangat. Gunakan "kamu".
- Judul tombol berupa kata kerja pendek: "Lanjut", "Simpan", "Kirim".
- Pesan error menjelaskan solusi, bukan menyalahkan. Contoh: "Koneksi lagi putus. Coba lagi ya."
- Boleh memakai emoji secukupnya di tempat yang ringan; jangan di pesan error serius atau transaksi.

## 7. Aksesibilitas (Wajib)

- Kontras 4.5:1 untuk teks; jangan mengandalkan warna saja untuk menyampaikan status.
- Semua ikon interaktif punya label aksesibilitas (`semanticLabel` / `contentDescription`).
- Dukung ukuran font sistem yang membesar tanpa merusak layout.
- Urutan fokus dan pembaca layar masuk akal.

## 8. Larangan (Anti-Pattern)

- Jangan menaruh lebih dari satu tombol primer di satu layar.
- Jangan memakai lebih dari satu warna aksen dominan.
- Jangan memakai hitam/putih murni sebagai latar.
- Jangan membuat dialog bertumpuk atau menu bersarang lebih dari 2 level.
- Jangan memakai paragraf panjang di layar utama.
- Jangan hardcode warna, ukuran, atau font di komponen; selalu lewat token.
- Jangan membuat form lebih dari 5 field dalam satu layar.
- Jangan menambah animasi berat yang membuat aplikasi terasa lambat.

## 9. Referensi Gaya (untuk inspirasi, bukan untuk disalin)

TikTok/Instagram (feed vertikal), Spotify (kartu besar), Duolingo (playful), BeReal (sederhana), Gojek/Dana/Jenius (fintech bersih).

## 10. Implementasi Flutter

- Pakai Material 3 (`useMaterial3: true`) dengan `ColorScheme` dan `ThemeData` untuk dark dan light dibuat dari token di atas, disimpan di `lib/core/theme/`.
- Buat `ThemeExtension` bernama `AppColors` untuk token yang tidak ada di `ColorScheme` (`surfaceAlt`, `border`, `accentSoft`, `accentText`, `verified`, `warning`), plus konstanta spacing dan radius terpusat.
- Font lewat package `google_fonts` (Plus Jakarta Sans) atau di-bundle sebagai aset.
- Haptic: `HapticFeedback.lightImpact()` untuk aksi penting.
- Skeleton: package `skeletonizer` atau `shimmer`.
- Animasi implisit (`AnimatedContainer`, `AnimatedSwitcher`) lebih diutamakan daripada animasi kustom yang rumit.
- Ikuti safe area dengan `SafeArea`; hormati `MediaQuery.disableAnimations` dan skala teks sistem.
- Mode tema: `ThemeMode.system` secara default.

## 11. Instruksi untuk Claude Code

- Sebelum membuat layar baru, baca dokumen ini lalu cek apakah token dan komponen yang dibutuhkan sudah ada di kode. Pakai ulang, jangan buat duplikat.
- Buat theme terpusat dulu (warna, tipografi, spacing, radius) sebelum membuat layar.
- Buat komponen reusable: `AppButton`, `AppCard`, `AppTextField`, `AppChip`, `AppBottomSheet`, `AppSkeleton`, `AppEmptyState`, `AppBottomNav`.
- Setiap layar baru harus: mendukung dark dan light, memakai safe area, punya state loading/empty/error.
- Kalau instruksi pengguna bertentangan dengan dokumen ini, ikuti pengguna dan sebutkan konflik itu secara singkat.
- Setelah selesai membuat UI, cek daftar berikut:
  - [ ] Semua warna/ukuran berasal dari token
  - [ ] Dark dan light mode sama-sama rapi
  - [ ] Tap target minimal 48 dp
  - [ ] Hanya satu tombol primer di layar
  - [ ] State loading, empty, dan error tersedia
  - [ ] Teks terbaca di ukuran font besar