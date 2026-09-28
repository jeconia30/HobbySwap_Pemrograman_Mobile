abstract final class AuthValidators {
  static final _campusEmail =
      RegExp(r'^[^@\s]+@students\.usu\.ac\.id$', caseSensitive: false);
  static final _nim = RegExp(r'^\d{9}$');
  static final _letter = RegExp(r'\p{L}', unicode: true);
  static final _digit = RegExp(r'\d');

  static bool isCampusEmail(String value) => _campusEmail.hasMatch(value.trim());

  // Login

  static String? identifier(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Isi email kampus atau NIM';
    if (!_campusEmail.hasMatch(v) && !_nim.hasMatch(v)) {
      return 'Pakai email @students.usu.ac.id atau NIM 9 digit';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Isi password';
    return null;
  }

  // Daftar

  static String? nama(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Isi nama lengkap';
    if (_letter.allMatches(v).length < 3) return 'Nama minimal 3 huruf';
    return null;
  }

  static String? nim(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Isi NIM';
    if (!_nim.hasMatch(v)) return 'NIM harus 9 digit angka';
    return null;
  }

  static String? campusEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Isi email kampus';
    if (!_campusEmail.hasMatch(v)) return 'Pakai email @students.usu.ac.id';
    return null;
  }

  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Isi password';
    if (v.length < 8) return 'Password minimal 8 karakter';
    if (!_letter.hasMatch(v) || !_digit.hasMatch(v)) {
      return 'Password harus ada huruf dan angka';
    }
    return null;
  }

  static String? terms(bool? accepted) {
    if (accepted != true) return 'Centang persetujuan dulu ya';
    return null;
  }
}

abstract final class ItemValidators {
  static const hargaMin = 5000;
  static const hargaMaks = 1000000;
  static const judulMaks = 60;
  static const deskripsiMin = 20;
  static const deskripsiMaks = 500;

  static String? judul(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Isi nama barangnya dulu';
    if (v.length < 3) return 'Nama barang minimal 3 huruf';
    return null;
  }

  static String? harga(String? value) {
    final v = int.tryParse(value?.trim() ?? '');
    if (v == null) return 'Isi harga sewa per hari';
    if (v < hargaMin) return 'Minimal Rp5.000 per hari';
    if (v > hargaMaks) return 'Maksimal Rp1.000.000 per hari';
    return null;
  }

  static String? lokasi(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Isi lokasi ambil barang';
    return null;
  }

  static String? deskripsi(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < deskripsiMin) {
      return 'Ceritakan kondisi & kelengkapannya, minimal $deskripsiMin karakter';
    }
    return null;
  }
}
