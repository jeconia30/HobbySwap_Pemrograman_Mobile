import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/core/utils/validators.dart';

void main() {
  group('AuthValidators.identifier', () {
    test('kosong atau spasi saja', () {
      expect(AuthValidators.identifier(null), 'Isi email kampus atau NIM');
      expect(AuthValidators.identifier(''), 'Isi email kampus atau NIM');
      expect(AuthValidators.identifier('   '), 'Isi email kampus atau NIM');
    });

    test('email kampus valid (tidak peka huruf besar, di-trim)', () {
      expect(AuthValidators.identifier('gregorian@students.usu.ac.id'), isNull);
      expect(AuthValidators.identifier(' Greg@Students.USU.ac.id '), isNull);
    });

    test('NIM 9 digit valid', () {
      expect(AuthValidators.identifier('220401087'), isNull);
    });

    test('format lain ditolak', () {
      const msg = 'Pakai email @students.usu.ac.id atau NIM 9 digit';
      for (final v in [
        'greg@gmail.com',
        'greg@usu.ac.id',
        'greg@students.usu.ac.id.evil.com',
        '@students.usu.ac.id',
        '22040108',
        '2204010871',
        '22040108a',
        'gregorian',
      ]) {
        expect(AuthValidators.identifier(v), msg, reason: v);
      }
    });
  });

  group('Validator daftar', () {
    test('nama minimal 3 huruf', () {
      expect(AuthValidators.nama(''), 'Isi nama lengkap');
      expect(AuthValidators.nama('  '), 'Isi nama lengkap');
      expect(AuthValidators.nama('Al'), 'Nama minimal 3 huruf');
      expect(AuthValidators.nama('A 1 2 3'), 'Nama minimal 3 huruf');
      expect(AuthValidators.nama('Ani'), isNull);
      expect(AuthValidators.nama('Siti Nurhaliza'), isNull);
    });

    test('NIM tepat 9 digit angka', () {
      expect(AuthValidators.nim(''), 'Isi NIM');
      for (final v in ['22040108', '2204010871', '22040108a', '2204 1087']) {
        expect(AuthValidators.nim(v), 'NIM harus 9 digit angka', reason: v);
      }
      expect(AuthValidators.nim('220401087'), isNull);
    });

    test('email harus @students.usu.ac.id', () {
      expect(AuthValidators.campusEmail(''), 'Isi email kampus');
      expect(AuthValidators.campusEmail('ani@gmail.com'),
          'Pakai email @students.usu.ac.id');
      expect(AuthValidators.campusEmail('ani@students.usu.ac.id'), isNull);
      expect(AuthValidators.isCampusEmail('ani@students.usu.ac.id'), isTrue);
      expect(AuthValidators.isCampusEmail('ani@usu.ac.id'), isFalse);
    });

    test('password minimal 8 karakter dengan huruf dan angka', () {
      expect(AuthValidators.newPassword(''), 'Isi password');
      expect(AuthValidators.newPassword('abc123'), 'Password minimal 8 karakter');
      expect(AuthValidators.newPassword('abcdefgh'),
          'Password harus ada huruf dan angka');
      expect(AuthValidators.newPassword('12345678'),
          'Password harus ada huruf dan angka');
      expect(AuthValidators.newPassword('hobby2026'), isNull);
    });

    test('persetujuan wajib dicentang', () {
      expect(AuthValidators.terms(null), 'Centang persetujuan dulu ya');
      expect(AuthValidators.terms(false), 'Centang persetujuan dulu ya');
      expect(AuthValidators.terms(true), isNull);
    });
  });

  group('AuthValidators.password', () {
    test('kosong ditolak, isi apa pun diterima', () {
      expect(AuthValidators.password(null), 'Isi password');
      expect(AuthValidators.password(''), 'Isi password');
      expect(AuthValidators.password('x'), isNull);
    });
  });
}
