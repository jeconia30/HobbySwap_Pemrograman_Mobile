class Validators {
  static String? validateRequired(String? value, [String fieldName = 'Field ini']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, [String fieldName = 'Field ini']) {
    final requiredError = validateRequired(value, fieldName);
    if (requiredError != null) return requiredError;

    if (value!.trim().length < minLength) {
      return '$fieldName minimal $minLength karakter';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    final requiredError = validateRequired(value, 'Nomor WhatsApp');
    if (requiredError != null) return requiredError;

    final trimmed = value!.trim();
    final phoneRegex = RegExp(r'^(?:\+62|62|0)8[1-9][0-9]{7,11}$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Format nomor WhatsApp tidak valid (contoh: 081234567890)';
    }
    return null;
  }

  static String? validateDates(DateTime? startDate, DateTime? endDate) {
    if (startDate == null) return 'Tanggal mulai wajib diisi';
    if (endDate == null) return 'Tanggal selesai wajib diisi';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(startDate.year, startDate.month, startDate.day);

    if (startDay.isBefore(today)) {
      return 'Tanggal mulai tidak boleh tanggal lampau';
    }

    if (endDate.isBefore(startDate)) {
      return 'Tanggal selesai harus setelah atau sama dengan tanggal mulai';
    }

    final duration = endDate.difference(startDate).inDays;
    if (duration > 30) {
      return 'Durasi peminjaman maksimal 30 hari';
    }

    return null;
  }

  static String? validateCategory(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      return 'Silakan pilih kategori';
    }
    return null;
  }

  static String? validateTerms(bool accepted) {
    if (!accepted) {
      return 'Anda harus menyetujui syarat & ketentuan peminjaman';
    }
    return null;
  }
}
